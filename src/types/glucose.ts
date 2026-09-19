export type GlucoseMeasurementContext =
  | 'fasting_morning'
  | 'pre_meal'
  | 'post_meal_2h'
  | 'other'

export interface GlucoseReading {
  id: string
  patientId: string
  glucoseValue: number
  unit: 'mg/dL'
  measurementContext: GlucoseMeasurementContext
  timestamp: string
}

export interface CreateGlucoseReadingInput {
  glucoseValue: number
  unit: 'mg/dL'
  measurementContext: GlucoseMeasurementContext
  timestamp: string
}

export interface GlucoseReadingRow {
  id: string
  event_id: string
  patient_id: string
  glucose_value: number
  unit: 'mg/dL'
  measurement_context: GlucoseMeasurementContext
  measured_at: string
  source_channel: 'web' | 'app' | 'whatsapp'
  recorded_by_profile_id: string | null
  recorded_by_actor_type: string | null
  created_at: string
}
