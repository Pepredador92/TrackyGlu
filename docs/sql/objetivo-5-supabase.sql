-- Copia consolidada para pegar en SQL Editor de Supabase.
-- Ejecuta después de objetivo-1, objetivo-2, objetivo-3 y objetivo-4.
begin;

create table if not exists public.clinical_guideline_sources (
  id uuid primary key default gen_random_uuid(), source_key text not null unique,
  title text not null, organization text not null, version_label text not null default '',
  url text not null, topics jsonb not null default '[]'::jsonb check (jsonb_typeof(topics) = 'array'),
  evidence_scope text not null default '', active boolean not null default true,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table if not exists public.clinical_task_drafts (
  id uuid primary key default gen_random_uuid(),
  clinical_task_id uuid not null unique references public.clinical_tasks(id) on delete cascade,
  clinical_case_context_id uuid references public.clinical_case_contexts(id) on delete set null,
  patient_id uuid not null references public.patients(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','generated','edited','approved','discarded','failed')),
  draft_text text check (draft_text is null or length(trim(draft_text)) between 1 and 12000),
  structured_output jsonb not null default '{}'::jsonb check (jsonb_typeof(structured_output) = 'object'),
  source_keys jsonb not null default '[]'::jsonb check (jsonb_typeof(source_keys) = 'array'),
  model text, provider text not null default 'openai', prompt_version text not null default 'clinical-support-v1',
  workflow_run_id uuid references public.workflow_runs(id) on delete set null, error_message text,
  generated_at timestamptz, reviewed_by_professional_id uuid references public.professionals(id) on delete set null,
  reviewed_at timestamptz, review_note text, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  constraint clinical_task_draft_state_check check ((status in ('generated','edited','approved') and draft_text is not null) or status in ('pending','discarded','failed'))
);

create table if not exists public.clinical_task_draft_revisions (
  id uuid primary key default gen_random_uuid(), draft_id uuid not null references public.clinical_task_drafts(id) on delete cascade,
  revision integer not null check (revision > 0), action text not null check (action in ('generated','edited','approved','discarded','failed')),
  draft_text text, structured_output jsonb not null default '{}'::jsonb check (jsonb_typeof(structured_output) = 'object'),
  actor_profile_id uuid references public.profiles(id) on delete set null, metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  created_at timestamptz not null default now(), unique (draft_id, revision)
);

create index if not exists clinical_task_drafts_patient_idx on public.clinical_task_drafts(patient_id, updated_at desc);
create index if not exists clinical_task_draft_revisions_draft_idx on public.clinical_task_draft_revisions(draft_id, revision desc);

insert into public.clinical_guideline_sources (source_key,title,organization,version_label,url,topics,evidence_scope) values
('nom-004-ssa3-2012','NOM-004-SSA3-2012, Del expediente clínico','Secretaría de Salud / DOF','2012','https://dof.gob.mx/normasOficiales/4909/SALUD/SALUD.html','["historia_clinica","expediente","confidencialidad"]','Identificación, integración y confidencialidad del expediente clínico.'),
('nom-015-ssa2-2010','NOM-015-SSA2-2010, prevención, tratamiento y control de la diabetes mellitus','Secretaría de Salud / DOF','2010','https://dof.gob.mx/normasOficiales/4215/salud/salud.htm','["diabetes","seguimiento","tratamiento"]','Referencia nacional para el seguimiento de personas con diabetes.'),
('ada-2026-section-4','Standards of Care in Diabetes—2026, sección 4','American Diabetes Association','2026','https://doi.org/10.2337/dc26-S004','["evaluacion_integral","comorbilidades","tratamiento"]','Evaluación médica integral centrada en la persona.'),
('ada-2026-section-6','Standards of Care in Diabetes—2026, sección 6','American Diabetes Association','2026','https://diabetesjournals.org/care/article/49/Supplement_1/S132/163927','["objetivos_glucemicos","hiperglucemia","hipoglucemia"]','Objetivos glucémicos y crisis hipo/hiperglucémicas.'),
('ada-2026-section-7','Standards of Care in Diabetes—2026, sección 7','American Diabetes Association','2026','https://diabetesjournals.org/care/article/49/Supplement_1/S150/163922','["tecnologia","monitoreo_glucosa"]','Tecnología y monitoreo de glucosa.'),
('openai-structured-outputs','Structured model outputs','OpenAI','API guide','https://developers.openai.com/api/docs/guides/structured-outputs','["salida_estructurada","validacion"]','Validación técnica del formato JSON; no es una guía clínica.')
on conflict (source_key) do update set title=excluded.title, organization=excluded.organization, version_label=excluded.version_label, url=excluded.url, topics=excluded.topics, evidence_scope=excluded.evidence_scope, active=true, updated_at=now();

create or replace function private.touch_clinical_task_draft() returns trigger language plpgsql security invoker set search_path='' as $$ begin new.updated_at:=now(); return new; end $$;
drop trigger if exists clinical_task_draft_touch on public.clinical_task_drafts;
create trigger clinical_task_draft_touch before update on public.clinical_task_drafts for each row execute function private.touch_clinical_task_draft();

create or replace function private.audit_service_ai_draft() returns trigger language plpgsql security definer set search_path='' as $$
declare next_revision integer;
begin
  if auth.uid() is not null then return new; end if;
  if tg_op='UPDATE' and old.status is not distinct from new.status and old.draft_text is not distinct from new.draft_text and old.error_message is not distinct from new.error_message then return new; end if;
  select coalesce(max(revision),0)+1 into next_revision from public.clinical_task_draft_revisions where draft_id=new.id;
  insert into public.clinical_task_draft_revisions(draft_id,revision,action,draft_text,structured_output,metadata)
  values(new.id,next_revision,case when new.status='failed' then 'failed' else 'generated' end,new.draft_text,new.structured_output,jsonb_build_object('actor','service_role','error_message',new.error_message));
  return new;
end $$;
drop trigger if exists clinical_task_draft_service_audit on public.clinical_task_drafts;
create trigger clinical_task_draft_service_audit after insert or update on public.clinical_task_drafts for each row execute function private.audit_service_ai_draft();

create or replace function private.record_clinical_transition() returns trigger language plpgsql security definer set search_path='' as $$
begin
  if auth.uid() is null then return new; end if;
  if tg_table_name='alerts' then
    if old.status<>'open' or new.status<>'acknowledged' then raise exception 'Invalid alert transition'; end if;
    new.acknowledged_at:=now(); new.acknowledged_by_professional_id:=private.my_professional_id();
  elsif old.status in ('pending_review','draft_ready') and new.status='in_review' then
    if new.final_decision is distinct from old.final_decision or new.review_note is distinct from old.review_note then raise exception 'Decision requires review'; end if;
    new.first_review_at:=coalesce(old.first_review_at,now());
  elsif old.status='in_review' and new.status='closed' then
    if new.final_decision is null or length(trim(coalesce(new.review_note,'')))=0 then raise exception 'Decision and note required'; end if;
    new.closed_at:=now();
  else raise exception 'Invalid task transition'; end if;
  return new;
end $$;

alter table public.clinical_task_drafts enable row level security;
alter table public.clinical_task_draft_revisions enable row level security;
alter table public.clinical_guideline_sources enable row level security;
create policy clinical_task_drafts_read on public.clinical_task_drafts for select to authenticated using (private.my_professional_id() is not null and private.can_view_patient(patient_id));
create policy clinical_task_draft_revisions_read on public.clinical_task_draft_revisions for select to authenticated using (exists(select 1 from public.clinical_task_drafts d where d.id=draft_id and private.my_professional_id() is not null and private.can_view_patient(d.patient_id)));
revoke all on public.clinical_guideline_sources,public.clinical_task_drafts,public.clinical_task_draft_revisions from anon,authenticated;
grant select on public.clinical_task_drafts,public.clinical_task_draft_revisions to authenticated;
grant all on public.clinical_guideline_sources,public.clinical_task_drafts,public.clinical_task_draft_revisions to service_role;

create or replace function private.review_clinical_ai_draft(target_draft uuid,next_status text,next_text text,p_review_note text default null) returns public.clinical_task_drafts
language plpgsql security definer set search_path='' as $$
declare professional uuid:=private.my_professional_id(); profile uuid:=private.my_profile_id(); current_draft public.clinical_task_drafts; updated_draft public.clinical_task_drafts; next_revision integer;
begin
  if auth.uid() is null or professional is null then raise exception 'Professional account required'; end if;
  if next_status not in ('edited','approved','discarded') then raise exception 'Invalid draft review status'; end if;
  if next_status in ('edited','approved') and length(trim(coalesce(next_text,''))) not between 1 and 12000 then raise exception 'Draft text is required'; end if;
  select d.* into current_draft from public.clinical_task_drafts d join public.clinical_tasks t on t.id=d.clinical_task_id where d.id=target_draft and t.assigned_professional_id=professional and private.can_view_patient(d.patient_id) for update;
  if current_draft.id is null then raise exception 'Draft not found or not allowed'; end if;
  if current_draft.status='discarded' then raise exception 'Draft already discarded'; end if;
  update public.clinical_task_drafts set status=next_status,draft_text=case when next_status='discarded' then draft_text else trim(next_text) end,reviewed_by_professional_id=professional,reviewed_at=now(),review_note=nullif(trim(coalesce(p_review_note,'')),'') where id=target_draft returning * into updated_draft;
  select coalesce(max(revision),0)+1 into next_revision from public.clinical_task_draft_revisions where draft_id=target_draft;
  insert into public.clinical_task_draft_revisions(draft_id,revision,action,draft_text,structured_output,actor_profile_id,metadata) values(target_draft,next_revision,next_status,updated_draft.draft_text,updated_draft.structured_output,profile,jsonb_build_object('review_note',updated_draft.review_note));
  return updated_draft;
end $$;
create or replace function public.review_clinical_ai_draft(target_draft uuid,next_status text,next_text text,review_note text default null) returns public.clinical_task_drafts language sql security invoker set search_path='' as $$ select private.review_clinical_ai_draft(target_draft,next_status,next_text,review_note) $$;
revoke all on function private.review_clinical_ai_draft(uuid,text,text,text),public.review_clinical_ai_draft(uuid,text,text,text) from public,anon;
grant execute on function private.review_clinical_ai_draft(uuid,text,text,text),public.review_clinical_ai_draft(uuid,text,text,text) to authenticated;

notify pgrst,'reload schema';
commit;
