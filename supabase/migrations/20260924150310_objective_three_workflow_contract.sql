-- Objective 3. Workflow provenance, persisted adherence metrics and
-- contracts consumed by the six n8n workflows.
-- The workflows continue to use their existing Supabase credentials. This
-- migration adds the database contract they expect; it does not rotate or
-- expose any credential.
begin;

create table if not exists public.workflow_runs (
  id uuid primary key default gen_random_uuid(),
  workflow_key text not null check (length(trim(workflow_key)) between 1 and 160),
  workflow_name text not null check (length(trim(workflow_name)) between 1 and 200),
  workflow_version text not null check (length(trim(workflow_version)) between 1 and 40),
  n8n_execution_id text,
  status text not null default 'running' check (status in ('running', 'succeeded', 'failed')),
  trigger_event_id uuid,
  input_payload jsonb not null default '{}'::jsonb check (jsonb_typeof(input_payload) = 'object'),
  output_payload jsonb check (output_payload is null or jsonb_typeof(output_payload) = 'object'),
  error_message text,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  created_at timestamptz not null default now(),
  constraint workflow_run_finished_state_check check (
    (status = 'running' and finished_at is null) or
    (status in ('succeeded', 'failed') and finished_at is not null)
  )
);

create unique index if not exists workflow_runs_n8n_execution_idx
  on public.workflow_runs(n8n_execution_id) where n8n_execution_id is not null;
create index if not exists workflow_runs_key_started_idx
  on public.workflow_runs(workflow_key, started_at desc);

create table if not exists public.events (
  event_id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients(id) on delete cascade,
  event_type text not null check (length(trim(event_type)) between 1 and 120),
  entity_type text not null check (length(trim(entity_type)) between 1 and 80),
  entity_id uuid not null,
  causation_event_id uuid,
  actor_type text not null check (actor_type in ('patient', 'professional', 'device', 'system', 'workflow')),
  actor_profile_id uuid references public.profiles(id),
  source_channel text not null default 'n8n' check (source_channel in ('web', 'app', 'whatsapp', 'n8n', 'system')),
  workflow_run_id uuid references public.workflow_runs(id),
  previous_state jsonb check (previous_state is null or jsonb_typeof(previous_state) = 'object'),
  new_state jsonb check (new_state is null or jsonb_typeof(new_state) = 'object'),
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  created_at timestamptz not null default now()
);

create index if not exists events_patient_created_idx
  on public.events(patient_id, created_at desc);
create unique index if not exists events_transition_idempotency_idx
  on public.events(entity_id, event_type)
  where event_type in (
    'glucose_reading.created', 'alert.created', 'alert.acknowledged',
    'clinical_task.created', 'clinical_task.review_started', 'clinical_task.closed'
  );
create index if not exists events_causation_idx
  on public.events(causation_event_id) where causation_event_id is not null;
create index if not exists events_workflow_run_idx
  on public.events(workflow_run_id) where workflow_run_id is not null;

create table if not exists public.adherence_summary (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients(id) on delete cascade,
  window_days integer not null check (window_days in (7, 14, 30)),
  period_end_date date not null,
  days_with_reading integer not null check (days_with_reading between 0 and window_days),
  total_readings integer not null check (total_readings >= 0),
  adherence_pct numeric(5, 1) not null check (adherence_pct between 0 and 100),
  readings_per_week numeric(7, 2) not null check (readings_per_week >= 0),
  max_streak_days integer not null check (max_streak_days between 0 and window_days),
  current_streak_days integer not null check (current_streak_days between 0 and window_days),
  max_gap_days integer not null check (max_gap_days between 0 and window_days),
  last_reading_at timestamptz,
  days_since_last_reading integer check (days_since_last_reading is null or days_since_last_reading >= 0),
  abandoned_flag boolean not null default false,
  retention_30_flag boolean,
  complete_days integer not null default 0 check (complete_days between 0 and window_days),
  completeness_pct numeric(5, 1) not null default 0 check (completeness_pct between 0 and 100),
  expected_readings integer not null default 0 check (expected_readings >= 0),
  slot_coverage_pct numeric(5, 1) not null default 0 check (slot_coverage_pct between 0 and 100),
  daily_slots jsonb not null default '[]'::jsonb check (jsonb_typeof(daily_slots) = 'array'),
  workflow_run_id uuid references public.workflow_runs(id),
  calculated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (patient_id, window_days, period_end_date)
);

create index if not exists adherence_summary_patient_window_idx
  on public.adherence_summary(patient_id, window_days, period_end_date desc);

alter table public.alerts
  add column if not exists source_event_id uuid,
  add column if not exists workflow_run_id uuid references public.workflow_runs(id);
alter table public.clinical_tasks
  add column if not exists workflow_run_id uuid references public.workflow_runs(id);

create index if not exists alerts_source_event_idx
  on public.alerts(source_event_id) where source_event_id is not null;
create index if not exists alerts_workflow_run_idx
  on public.alerts(workflow_run_id) where workflow_run_id is not null;
create index if not exists clinical_tasks_workflow_run_idx
  on public.clinical_tasks(workflow_run_id) where workflow_run_id is not null;

create or replace function private.touch_adherence_summary() returns trigger
language plpgsql security invoker set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists adherence_summary_touch on public.adherence_summary;
create trigger adherence_summary_touch
  before update on public.adherence_summary
  for each row execute function private.touch_adherence_summary();

alter table public.workflow_runs enable row level security;
alter table public.events enable row level security;
alter table public.adherence_summary enable row level security;

create policy adherence_summary_read on public.adherence_summary
  for select to authenticated using (private.can_view_patient(patient_id));

revoke all on public.workflow_runs, public.events from anon, authenticated;
revoke all on public.adherence_summary from anon, authenticated;
grant select on public.adherence_summary to authenticated;
grant all on public.workflow_runs, public.events, public.adherence_summary to service_role;

comment on table public.workflow_runs is
  'Execution provenance for n8n workflows. Internal operational data; service_role only.';
comment on table public.events is
  'Immutable business events emitted by the ingestion, adherence, alert and clinical workflows.';
comment on table public.adherence_summary is
  'Persisted 7/14/30-day continuity and three-slot completeness summaries.';
comment on column public.adherence_summary.adherence_pct is
  'Continuity: days_with_reading / window_days * 100.';
comment on column public.adherence_summary.completeness_pct is
  'Complete days / window_days * 100. A complete day has morning, afternoon and night readings.';
comment on column public.adherence_summary.slot_coverage_pct is
  'Observed readings / expected readings, capped at 100 percent.';

notify pgrst, 'reload schema';
commit;
