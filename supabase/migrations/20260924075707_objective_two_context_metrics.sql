-- Objective 2. Contextual glucose capture and dashboard-ready fields.
-- This migration extends the objective 1 glucose contract. It does not run
-- workflow automation; objective 3 will connect the event pipeline.
begin;

alter table public.glucose_readings
  drop constraint if exists glucose_readings_measurement_context_check;

alter table public.glucose_readings
  add constraint glucose_readings_measurement_context_check check (
    measurement_context in (
      'fasting_morning', 'pre_meal', 'post_meal_1h', 'post_meal_2h',
      'post_meal_3h_plus', 'bedtime', 'random', 'other'
    )
  );

alter table public.glucose_readings
  add column if not exists measurement_source text not null default 'capillary',
  add column if not exists has_eaten boolean,
  add column if not exists last_meal_at timestamptz,
  add column if not exists meal_type text,
  add column if not exists carbohydrate_estimate smallint,
  add column if not exists treatment_due_before_measurement boolean,
  add column if not exists treatment_taken_as_scheduled boolean,
  add column if not exists recent_physical_activity boolean,
  add column if not exists activity_duration_min smallint,
  add column if not exists activity_intensity text,
  add column if not exists symptoms_present boolean,
  add column if not exists symptoms jsonb not null default '[]'::jsonb,
  add column if not exists illness_flag boolean,
  add column if not exists stress_flag boolean,
  add column if not exists sleep_quality text,
  add column if not exists observation text,
  add column if not exists access_channel text not null default 'direct_url',
  add column if not exists quality_state text not null default 'valid',
  add column if not exists processing_state text not null default 'persisted';

alter table public.glucose_readings
  add constraint glucose_readings_context_source_check check (
    measurement_source in ('capillary', 'cgm', 'lab', 'other')
  ),
  add constraint glucose_readings_meal_type_check check (
    meal_type is null or meal_type in ('breakfast', 'lunch', 'dinner', 'snack', 'other')
  ),
  add constraint glucose_readings_carbohydrate_check check (
    carbohydrate_estimate is null or carbohydrate_estimate between 0 and 300
  ),
  add constraint glucose_readings_activity_duration_check check (
    activity_duration_min is null or activity_duration_min between 1 and 720
  ),
  add constraint glucose_readings_activity_intensity_check check (
    activity_intensity is null or activity_intensity in ('light', 'moderate', 'vigorous')
  ),
  add constraint glucose_readings_sleep_quality_check check (
    sleep_quality is null or sleep_quality in ('good', 'regular', 'poor', 'unknown')
  ),
  add constraint glucose_readings_symptoms_check check (jsonb_typeof(symptoms) = 'array'),
  add constraint glucose_readings_quality_check check (
    quality_state in ('valid', 'invalid', 'na')
  ),
  add constraint glucose_readings_processing_check check (
    processing_state in ('persisted', 'skipped_duplicate', 'failed', 'filtered')
  ),
  add constraint glucose_readings_observation_length_check check (
    observation is null or length(observation) <= 2000
  ),
  add constraint glucose_readings_meal_before_reading_check check (
    last_meal_at is null or last_meal_at <= measured_at
  );

create index if not exists glucose_readings_patient_context_idx
  on public.glucose_readings (patient_id, measurement_context, measured_at desc);

grant insert(measurement_source, has_eaten, last_meal_at, meal_type, carbohydrate_estimate,
  treatment_due_before_measurement, treatment_taken_as_scheduled, recent_physical_activity,
  activity_duration_min, activity_intensity, symptoms_present, symptoms, illness_flag,
  stress_flag, sleep_quality, observation, quality_state, processing_state) on public.glucose_readings to authenticated;

comment on column public.glucose_readings.measurement_context is
  'Patient-confirmed physiological context used to stratify readings; it is not a diagnosis.';
comment on column public.glucose_readings.has_eaten is
  'Optional patient-reported food status captured only when the daily context is ambiguous.';
comment on column public.glucose_readings.treatment_taken_as_scheduled is
  'Optional patient report. TrackyGlu does not infer or change a treatment plan.';
comment on column public.glucose_readings.quality_state is
  'Technical quality gate for future workflow calculations. Objective 2 writes valid for accepted web readings.';

create table if not exists public.glucose_daily_context (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients(id) on delete cascade,
  local_date date not null,
  treatment_adherence_24h boolean,
  missed_doses_7d text check (missed_doses_7d is null or missed_doses_7d in ('none', 'one_two', 'three_five', 'more_than_five')),
  missed_dose_reason text check (missed_dose_reason is null or missed_dose_reason in ('forgetfulness', 'unavailable', 'side_effects', 'cost', 'other')),
  illness_flag boolean,
  stress_flag boolean,
  sleep_quality text check (sleep_quality is null or sleep_quality in ('good', 'regular', 'poor', 'unknown')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (patient_id, local_date),
  constraint daily_context_reason_check check (
    missed_doses_7d is null or missed_doses_7d = 'none' or missed_dose_reason is not null
  )
);
create index if not exists glucose_daily_context_patient_date_idx
  on public.glucose_daily_context (patient_id, local_date desc);
alter table public.glucose_daily_context enable row level security;
create policy glucose_daily_context_read on public.glucose_daily_context
  for select to authenticated using (private.can_view_patient(patient_id));
create policy glucose_daily_context_insert on public.glucose_daily_context
  for insert to authenticated with check (patient_id = (select private.my_patient_id()));
create policy glucose_daily_context_update on public.glucose_daily_context
  for update to authenticated using (patient_id = (select private.my_patient_id()))
  with check (patient_id = (select private.my_patient_id()));
revoke all on public.glucose_daily_context from anon, authenticated;
grant select on public.glucose_daily_context to authenticated;
grant insert(patient_id, local_date, treatment_adherence_24h, missed_doses_7d, missed_dose_reason, illness_flag, stress_flag, sleep_quality) on public.glucose_daily_context to authenticated;
grant update(treatment_adherence_24h, missed_doses_7d, missed_dose_reason, illness_flag, stress_flag, sleep_quality, updated_at) on public.glucose_daily_context to authenticated;
grant all on public.glucose_daily_context to service_role;

create or replace function private.touch_daily_context() returns trigger
language plpgsql security invoker set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;
create trigger glucose_daily_context_touch
  before update on public.glucose_daily_context
  for each row execute function private.touch_daily_context();

notify pgrst, 'reload schema';
commit;
