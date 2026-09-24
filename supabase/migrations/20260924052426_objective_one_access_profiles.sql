-- Objective 1. Bootstrap for a fresh Supabase installation.
-- Existing self-hosted deployments must reconcile their schema before applying (see docs).
begin;
create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

create table public.profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  role text not null check (role in ('patient','professional','admin')),
  display_name text not null check (char_length(trim(display_name)) between 2 and 120),
  created_at timestamptz not null default now()
);
create table public.patients (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null unique references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);
create table public.professionals (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null unique references public.profiles(id) on delete cascade,
  specialty text not null default '',
  license_number text not null default '',
  institution text not null default '',
  phone text not null default '',
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  constraint professional_completion check (completed_at is null or
    (length(trim(specialty)) > 0 and length(trim(license_number)) > 0 and length(trim(institution)) > 0))
);
create table public.professional_patients (
  professional_id uuid not null references public.professionals(id) on delete cascade,
  patient_id uuid not null references public.patients(id) on delete cascade,
  active boolean not null default true,
  linked_at timestamptz not null default now(),
  ended_at timestamptz,
  primary key (professional_id, patient_id)
);
create index professional_patients_patient_idx on public.professional_patients(patient_id, professional_id) where active;
create table public.patient_histories (
  patient_id uuid primary key references public.patients(id) on delete cascade,
  data jsonb not null default '{}' check (jsonb_typeof(data) = 'object'),
  current_step integer not null default 0 check (current_step between 0 and 3),
  revision integer not null default 0,
  completed_at timestamptz,
  updated_at timestamptz not null default now()
);
create table public.patient_history_versions (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients(id) on delete cascade,
  revision integer not null,
  data jsonb not null,
  actor_profile_id uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  unique(patient_id, revision)
);
create table public.patient_history_reviews (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients(id) on delete cascade,
  professional_id uuid not null references public.professionals(id),
  history_revision integer not null,
  note text not null check (length(trim(note)) between 1 and 4000),
  reviewed_at timestamptz not null default now(),
  foreign key (patient_id, history_revision) references public.patient_history_versions(patient_id, revision)
);
create index patient_history_reviews_patient_idx on public.patient_history_reviews(patient_id, reviewed_at desc);
create table public.patient_invitations (
  id uuid primary key default gen_random_uuid(),
  professional_id uuid not null references public.professionals(id) on delete cascade,
  code text not null unique default upper(replace(gen_random_uuid()::text, '-', '')),
  expires_at timestamptz not null default now() + interval '7 days',
  accepted_by uuid references public.patients(id),
  accepted_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);
create index patient_invitations_professional_idx on public.patient_invitations(professional_id, created_at desc);

-- Internal lookups avoid recursive RLS policies. They always derive the actor from auth.uid().
create function private.my_profile_id() returns uuid language sql stable security definer set search_path = '' as $$
  select id from public.profiles where user_id = (select auth.uid())
$$;
create function private.my_patient_id() returns uuid language sql stable security definer set search_path = '' as $$
  select p.id from public.patients p join public.profiles pr on pr.id=p.profile_id where pr.user_id=(select auth.uid())
$$;
create function private.my_professional_id() returns uuid language sql stable security definer set search_path = '' as $$
  select p.id from public.professionals p join public.profiles pr on pr.id=p.profile_id where pr.user_id=(select auth.uid())
$$;
create function private.can_view_patient(target uuid) returns boolean language sql stable security definer set search_path = '' as $$
  select (select auth.uid()) is not null and (coalesce(target = private.my_patient_id(),false) or exists (
    select 1 from public.professional_patients pp where pp.patient_id=target and pp.active and pp.professional_id=private.my_professional_id()))
$$;
create function private.can_view_profile(target uuid) returns boolean language sql stable security definer set search_path = '' as $$
  select (select auth.uid()) is not null and (target=private.my_profile_id()
    or exists(select 1 from public.patients p where p.profile_id=target and private.can_view_patient(p.id))
    or exists(select 1 from public.professionals p join public.professional_patients pp on pp.professional_id=p.id
      where p.profile_id=target and pp.patient_id=private.my_patient_id() and pp.active))
$$;
revoke all on all functions in schema private from public;
grant execute on all functions in schema private to authenticated;

alter table public.profiles enable row level security;
alter table public.patients enable row level security;
alter table public.professionals enable row level security;
alter table public.professional_patients enable row level security;
alter table public.patient_histories enable row level security;
alter table public.patient_history_versions enable row level security;
alter table public.patient_history_reviews enable row level security;
alter table public.patient_invitations enable row level security;

create policy profiles_read on public.profiles for select to authenticated using (private.can_view_profile(id));
create policy profiles_edit_name on public.profiles for update to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()));
create policy patients_read on public.patients for select to authenticated using (private.can_view_patient(id));
create policy professionals_read on public.professionals for select to authenticated using (private.can_view_profile(profile_id));
create policy professionals_edit on public.professionals for update to authenticated using (id=(select private.my_professional_id())) with check (id=(select private.my_professional_id()));
create policy assignments_read on public.professional_patients for select to authenticated using (patient_id=(select private.my_patient_id()) or professional_id=(select private.my_professional_id()));
create policy histories_read on public.patient_histories for select to authenticated using (private.can_view_patient(patient_id));
create policy versions_read on public.patient_history_versions for select to authenticated using (private.can_view_patient(patient_id));
create policy reviews_read on public.patient_history_reviews for select to authenticated using (private.can_view_patient(patient_id));
create policy invitations_read on public.patient_invitations for select to authenticated using (professional_id=(select private.my_professional_id()));
create policy invitations_insert on public.patient_invitations for insert to authenticated with check (
  professional_id=(select private.my_professional_id()) and exists(select 1 from public.professionals where id=professional_id and completed_at is not null));

-- Revoke default Supabase table grants, then grant only the operations/columns owned by the client.
revoke all on public.profiles, public.patients, public.professionals, public.professional_patients,
  public.patient_histories, public.patient_history_versions, public.patient_history_reviews, public.patient_invitations from anon, authenticated;
grant select on public.profiles, public.patients, public.professionals, public.professional_patients,
  public.patient_histories, public.patient_history_versions, public.patient_history_reviews, public.patient_invitations to authenticated;
grant update(display_name) on public.profiles to authenticated;
grant update(specialty, license_number, institution, phone, completed_at) on public.professionals to authenticated;
grant insert(professional_id) on public.patient_invitations to authenticated;
grant all on public.profiles, public.patients, public.professionals, public.professional_patients,
  public.patient_histories, public.patient_history_versions, public.patient_history_reviews, public.patient_invitations to service_role;

-- Public wrappers use invoker rights; privileged bodies live in the unexposed private schema.
create function private.create_account(account_role text, account_name text) returns uuid
language plpgsql security definer set search_path = '' as $$
declare profile_id uuid; patient_id uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if account_role not in ('patient','professional') then raise exception 'Invalid role'; end if;
  perform pg_advisory_xact_lock(hashtextextended(auth.uid()::text, 0));
  select id into profile_id from public.profiles where user_id=auth.uid();
  if profile_id is not null then return profile_id; end if;
  insert into public.profiles(user_id, role, display_name) values(auth.uid(), account_role, trim(account_name)) returning id into profile_id;
  if account_role='patient' then
    insert into public.patients(profile_id) values(profile_id) returning id into patient_id;
    insert into public.patient_histories(patient_id) values(patient_id);
  else
    insert into public.professionals(profile_id) values(profile_id);
  end if;
  return profile_id;
end $$;
create function public.create_account(account_role text, account_name text) returns uuid
language sql security invoker set search_path = '' as $$ select private.create_account(account_role, account_name) $$;

create function private.save_patient_history(history_data jsonb, next_step integer, expected_revision integer, complete boolean) returns public.patient_histories
language plpgsql security definer set search_path = '' as $$
declare patient uuid := private.my_patient_id(); saved public.patient_histories; field text; item jsonb;
begin
  if auth.uid() is null or patient is null then raise exception 'Patient account required'; end if;
  if jsonb_typeof(history_data) <> 'object' or octet_length(history_data::text)>50000 then raise exception 'Invalid history'; end if;
  foreach field in array array['birthDate','sex','phone','address','occupation','emergencyContact','diabetesType','diagnosisYear','conditionsStatus','otherConditions','familyHistory','severeLowHistory','treatmentStatus','allergyStatus','allergies','smoking','alcohol','activity','support','notes'] loop
    if history_data ? field and (jsonb_typeof(history_data->field)<>'string' or length(history_data->>field)>2000) then raise exception 'Invalid history field'; end if;
  end loop;
  if history_data ? 'conditions' and jsonb_typeof(history_data->'conditions')<>'array' then raise exception 'Invalid conditions'; end if;
  for item in select value from jsonb_array_elements(coalesce(history_data->'conditions','[]')) loop
    if jsonb_typeof(item)<>'string' then raise exception 'Invalid condition'; end if;
  end loop;
  if history_data ? 'medications' and jsonb_typeof(history_data->'medications')<>'array' then raise exception 'Invalid medications'; end if;
  if jsonb_array_length(coalesce(history_data->'medications','[]'))>20 then raise exception 'Too many medications'; end if;
  for item in select value from jsonb_array_elements(coalesce(history_data->'medications','[]')) loop
    if jsonb_typeof(item)<>'object' or jsonb_typeof(item->'name') is distinct from 'string'
      or jsonb_typeof(item->'dose') is distinct from 'string' or jsonb_typeof(item->'schedule') is distinct from 'string'
      then raise exception 'Invalid medication'; end if;
  end loop;
  if complete and (coalesce(history_data->>'birthDate','')='' or coalesce(history_data->>'sex','')=''
    or coalesce(history_data->>'diabetesType','')='' or coalesce(history_data->>'treatmentStatus','')=''
    or coalesce(history_data->>'allergyStatus','')='' or coalesce(history_data->>'conditionsStatus','')=''
    or coalesce(history_data->>'informationConfirmed','false') <> 'true') then raise exception 'Complete the required sections'; end if;
  if complete and (history_data->>'birthDate')::date > current_date then raise exception 'Invalid birth date'; end if;
  if complete and ((history_data->>'birthDate')::date < date '1900-01-01'
    or history_data->>'sex' not in ('female','male','other')
    or history_data->>'diabetesType' not in ('type_1','type_2','gestational','other','unknown')
    or history_data->>'treatmentStatus' not in ('none','medication','insulin','both','unknown')
    or history_data->>'allergyStatus' not in ('yes','no','unknown')
    or history_data->>'conditionsStatus' not in ('yes','no','unknown')) then raise exception 'Invalid history selection'; end if;
  if complete and history_data->>'allergyStatus'='yes' and length(trim(coalesce(history_data->>'allergies','')))=0 then raise exception 'Describe the allergy'; end if;
  if complete and history_data->>'conditionsStatus'='yes' and jsonb_array_length(coalesce(history_data->'conditions','[]'))=0 then raise exception 'Describe the conditions'; end if;
  if complete and coalesce(history_data->>'diagnosisYear','')<>'' and
    ((history_data->>'diagnosisYear')::int<extract(year from (history_data->>'birthDate')::date) or (history_data->>'diagnosisYear')::int>extract(year from current_date)) then raise exception 'Invalid diagnosis year'; end if;
  update public.patient_histories set data=history_data, current_step=next_step, revision=revision+1,
    completed_at=case when complete then now() else null end, updated_at=now()
    where patient_id=patient and revision=expected_revision returning * into saved;
  if saved.patient_id is null then raise exception 'HISTORY_CONFLICT'; end if;
  insert into public.patient_history_versions(patient_id, revision, data, actor_profile_id)
    values(patient, saved.revision, history_data, private.my_profile_id());
  return saved;
end $$;
create function public.save_patient_history(history_data jsonb, next_step integer, expected_revision integer, complete boolean) returns public.patient_histories
language sql security invoker set search_path = '' as $$ select private.save_patient_history(history_data, next_step, expected_revision, complete) $$;

create function private.accept_patient_invitation(invitation_code text) returns uuid
language plpgsql security definer set search_path = '' as $$
declare patient uuid := private.my_patient_id(); invitation public.patient_invitations;
begin
  if auth.uid() is null or patient is null then raise exception 'Patient account required'; end if;
  select * into invitation from public.patient_invitations where code=upper(regexp_replace(invitation_code,'[^a-zA-Z0-9]','','g')) for update;
  if invitation.id is null or invitation.expires_at<now() or invitation.revoked_at is not null
    or (invitation.accepted_by is not null and invitation.accepted_by<>patient) then raise exception 'INVITATION_UNAVAILABLE'; end if;
  -- A previously consumed code must not restore a deliberately revoked relationship.
  if invitation.accepted_by=patient then return invitation.professional_id; end if;
  insert into public.professional_patients(professional_id,patient_id) values(invitation.professional_id,patient)
    on conflict (professional_id,patient_id) do update set active=true, linked_at=now(), ended_at=null;
  update public.patient_invitations set accepted_by=patient,accepted_at=now() where id=invitation.id;
  return invitation.professional_id;
end $$;
create function public.accept_patient_invitation(invitation_code text) returns uuid
language sql security invoker set search_path = '' as $$ select private.accept_patient_invitation(invitation_code) $$;

create function private.end_patient_assignment(target_patient uuid, target_professional uuid) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null or not(coalesce(target_patient=private.my_patient_id(),false) or coalesce(target_professional=private.my_professional_id(),false)) then raise exception 'Not allowed'; end if;
  update public.professional_patients set active=false, ended_at=now() where patient_id=target_patient and professional_id=target_professional;
end $$;
create function public.end_patient_assignment(target_patient uuid, target_professional uuid) returns void
language sql security invoker set search_path = '' as $$ select private.end_patient_assignment(target_patient, target_professional) $$;

create function private.review_patient_history(target_patient uuid, expected_revision integer, review_note text) returns void
language plpgsql security definer set search_path = '' as $$
declare professional uuid := private.my_professional_id(); history public.patient_histories;
begin
  if auth.uid() is null or professional is null or not coalesce(private.can_view_patient(target_patient),false) then raise exception 'Not allowed'; end if;
  select * into history from public.patient_histories where patient_id=target_patient for update;
  if history.completed_at is null or history.revision<>expected_revision then raise exception 'HISTORY_CONFLICT'; end if;
  insert into public.patient_history_reviews(patient_id,professional_id,history_revision,note)
    values(target_patient,professional,expected_revision,trim(review_note));
end $$;
create function public.review_patient_history(target_patient uuid, expected_revision integer, review_note text) returns void
language sql security invoker set search_path = '' as $$ select private.review_patient_history(target_patient, expected_revision, review_note) $$;

-- Complete the pre-existing glucose contract without changing measurement semantics.
alter table public.glucose_readings alter column patient_id type uuid using patient_id::uuid;
alter table public.glucose_readings add constraint glucose_patient_fk foreign key(patient_id) references public.patients(id);
alter table public.glucose_readings add column recorded_by_profile_id uuid references public.profiles(id) default private.my_profile_id();
alter table public.glucose_readings add column recorded_by_actor_type text default 'patient';
revoke all on public.glucose_readings from anon, authenticated;
grant select on public.glucose_readings to authenticated;
grant insert(patient_id,glucose_value,unit,measurement_context,measured_at,source_channel) on public.glucose_readings to authenticated;
create policy glucose_read on public.glucose_readings for select to authenticated using (private.can_view_patient(patient_id));
create policy glucose_create on public.glucose_readings for insert to authenticated with check (patient_id=(select private.my_patient_id()) and exists(select 1 from public.patient_histories h where h.patient_id=glucose_readings.patient_id and h.completed_at is not null));

-- Existing screens can continue to operate on a new local installation. Orchestration is objective 3.
create table public.alerts (
  id uuid primary key default gen_random_uuid(), event_id uuid not null unique default gen_random_uuid(),
  patient_id uuid not null references public.patients(id), source_reading_id uuid references public.glucose_readings(id),
  alert_type text not null, severity text not null check(severity in ('info','warning','critical')),
  status text not null default 'open' check(status in ('open','acknowledged','closed')), reason text not null,
  metadata jsonb not null default '{}', acknowledged_at timestamptz, closed_at timestamptz,
  acknowledged_by_professional_id uuid references public.professionals(id), created_at timestamptz not null default now()
);
create table public.clinical_tasks (
  id uuid primary key default gen_random_uuid(), event_id uuid not null unique default gen_random_uuid(),
  patient_id uuid not null references public.patients(id), source_event_id uuid, source_alert_id uuid references public.alerts(id),
  trigger_rule text not null, priority text not null check(priority in ('info','warning','critical')),
  status text not null default 'pending_review' check(status in ('pending_review','draft_ready','in_review','closed')),
  assigned_professional_id uuid references public.professionals(id), first_review_at timestamptz, closed_at timestamptz,
  final_decision text check(final_decision in ('approved','modified','cancelled')), review_note text,
  ai_draft_status text not null default 'not_requested', created_at timestamptz not null default now()
);
create index alerts_patient_idx on public.alerts(patient_id,created_at desc);
create index clinical_tasks_patient_idx on public.clinical_tasks(patient_id,created_at desc);
alter table public.alerts enable row level security;
alter table public.clinical_tasks enable row level security;
create policy alerts_read on public.alerts for select to authenticated using (private.my_professional_id() is not null and private.can_view_patient(patient_id));
create policy alerts_update on public.alerts for update to authenticated using (private.my_professional_id() is not null and private.can_view_patient(patient_id)) with check (private.my_professional_id() is not null and private.can_view_patient(patient_id));
create policy tasks_read on public.clinical_tasks for select to authenticated using (private.my_professional_id() is not null and private.can_view_patient(patient_id));
create policy tasks_update on public.clinical_tasks for update to authenticated using (private.can_view_patient(patient_id) and assigned_professional_id=private.my_professional_id()) with check (private.can_view_patient(patient_id) and assigned_professional_id=private.my_professional_id());
revoke all on public.alerts, public.clinical_tasks from anon, authenticated;
grant select on public.alerts, public.clinical_tasks to authenticated;
grant update(status) on public.alerts to authenticated;
grant update(status,final_decision,review_note) on public.clinical_tasks to authenticated;
grant all on public.alerts, public.clinical_tasks to service_role;
create function private.record_clinical_transition() returns trigger language plpgsql security definer set search_path='' as $$
begin
  if auth.uid() is null then return new; end if;
  if tg_table_name='alerts' then
    if old.status <> 'open' or new.status <> 'acknowledged' then raise exception 'Invalid alert transition'; end if;
    new.acknowledged_at:=now(); new.acknowledged_by_professional_id:=private.my_professional_id();
  elsif old.status='pending_review' and new.status='in_review' then
    if new.final_decision is distinct from old.final_decision or new.review_note is distinct from old.review_note then raise exception 'Decision requires review'; end if;
    new.first_review_at:=coalesce(old.first_review_at,now());
  elsif old.status='in_review' and new.status='closed' then
    if new.final_decision is null or length(trim(coalesce(new.review_note,'')))=0 then raise exception 'Decision and note required'; end if;
    new.closed_at:=now();
  else raise exception 'Invalid task transition';
  end if;
  return new;
end $$;
create trigger alert_transition before update on public.alerts for each row execute function private.record_clinical_transition();
create trigger task_transition before update on public.clinical_tasks for each row execute function private.record_clinical_transition();

revoke all on all functions in schema private from public, anon;
grant execute on all functions in schema private to authenticated;
revoke all on function public.create_account(text,text), public.save_patient_history(jsonb,integer,integer,boolean),
  public.accept_patient_invitation(text), public.end_patient_assignment(uuid,uuid), public.review_patient_history(uuid,integer,text) from public, anon;
grant execute on function public.create_account(text,text), public.save_patient_history(jsonb,integer,integer,boolean),
  public.accept_patient_invitation(text), public.end_patient_assignment(uuid,uuid), public.review_patient_history(uuid,integer,text) to authenticated;
create function private.preview_patient_invitation(invitation_code text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare result jsonb;
begin
  if auth.uid() is null or private.my_patient_id() is null then raise exception 'Patient account required'; end if;
  select jsonb_build_object('id',p.id,'name',pr.display_name,'specialty',p.specialty,'institution',p.institution)
    into result from public.patient_invitations i join public.professionals p on p.id=i.professional_id
    join public.profiles pr on pr.id=p.profile_id
    where i.code=upper(regexp_replace(invitation_code,'[^a-zA-Z0-9]','','g')) and i.expires_at>now()
      and i.revoked_at is null and i.accepted_at is null;
  if result is null then raise exception 'INVITATION_UNAVAILABLE'; end if;
  return result;
end $$;
create function public.preview_patient_invitation(invitation_code text) returns jsonb
language sql security invoker set search_path='' as $$ select private.preview_patient_invitation(invitation_code) $$;
revoke all on function private.preview_patient_invitation(text), public.preview_patient_invitation(text) from public,anon;
grant execute on function private.preview_patient_invitation(text), public.preview_patient_invitation(text) to authenticated;
notify pgrst, 'reload schema';
commit;
