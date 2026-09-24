-- Copia consolidada para pegar en SQL Editor de Supabase.
-- Ejecuta después de objetivo-1-supabase.sql, objetivo-2-supabase.sql y objetivo-3-supabase.sql.
-- Objective 4. Auditable clinical case context prepared after an alert.
begin;

create table if not exists public.clinical_case_contexts (
  id uuid primary key default gen_random_uuid(),
  clinical_task_id uuid references public.clinical_tasks(id) on delete cascade,
  source_alert_id uuid not null references public.alerts(id) on delete cascade,
  patient_id uuid not null references public.patients(id) on delete cascade,
  assigned_professional_id uuid references public.professionals(id) on delete set null,
  context_version text not null check (length(trim(context_version)) between 1 and 40),
  status text not null check (status in ('prepared', 'partial', 'waiting_professional', 'failed')),
  snapshot jsonb not null default '{}'::jsonb check (jsonb_typeof(snapshot) = 'object'),
  missing_data jsonb not null default '[]'::jsonb check (jsonb_typeof(missing_data) = 'array'),
  prepared_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (source_alert_id),
  unique (clinical_task_id)
);

create index if not exists clinical_case_context_patient_idx
  on public.clinical_case_contexts(patient_id, created_at desc);
create index if not exists clinical_case_context_professional_idx
  on public.clinical_case_contexts(assigned_professional_id, created_at desc)
  where assigned_professional_id is not null;

create unique index if not exists clinical_tasks_source_alert_idx
  on public.clinical_tasks(source_alert_id)
  where source_alert_id is not null;

create or replace function private.touch_clinical_case_context() returns trigger
language plpgsql security invoker set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists clinical_case_context_touch on public.clinical_case_contexts;
create trigger clinical_case_context_touch
  before update on public.clinical_case_contexts
  for each row execute function private.touch_clinical_case_context();

alter table public.clinical_case_contexts enable row level security;
create policy clinical_case_context_read on public.clinical_case_contexts
  for select to authenticated
  using (private.my_professional_id() is not null and private.can_view_patient(patient_id));

revoke all on public.clinical_case_contexts from anon, authenticated;
grant select on public.clinical_case_contexts to authenticated;
grant all on public.clinical_case_contexts to service_role;

comment on table public.clinical_case_contexts is
  'Versioned, auditable snapshot prepared for professional review after an alert. It is not an AI recommendation.';
comment on column public.clinical_case_contexts.snapshot is
  'Structured evidence snapshot: alert, triggering reading, history, recent readings, daily context and adherence summaries.';
comment on column public.clinical_case_contexts.missing_data is
  'Array of named fields that were unavailable when the snapshot was prepared.';
comment on column public.clinical_case_contexts.status is
  'prepared when the minimum evidence is present, partial when optional evidence is missing, waiting_professional when no active link exists, or failed when preparation could not be completed.';

notify pgrst, 'reload schema';
commit;
