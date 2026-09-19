CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.glucose_readings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  patient_id text NOT NULL,
  glucose_value numeric NOT NULL CHECK (glucose_value > 0),
  unit text NOT NULL DEFAULT 'mg/dL' CHECK (unit = 'mg/dL'),
  measurement_context text NOT NULL CHECK (
    measurement_context IN ('fasting_morning', 'pre_meal', 'post_meal_2h', 'other')
  ),
  measured_at timestamptz NOT NULL,
  source_channel text NOT NULL DEFAULT 'web' CHECK (
    source_channel IN ('web', 'app', 'whatsapp')
  ),
  created_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON COLUMN public.glucose_readings.event_id IS
  'Stable event reference for traceability and duplicate detection.';
COMMENT ON COLUMN public.glucose_readings.measured_at IS
  'The actual date and time when the patient took the measurement.';
COMMENT ON COLUMN public.glucose_readings.source_channel IS
  'The channel through which the reading entered the system.';

CREATE INDEX IF NOT EXISTS glucose_readings_patient_id_idx
  ON public.glucose_readings (patient_id);

CREATE INDEX IF NOT EXISTS glucose_readings_patient_measured_at_idx
  ON public.glucose_readings (patient_id, measured_at DESC);

ALTER TABLE public.glucose_readings ENABLE ROW LEVEL SECURITY;
