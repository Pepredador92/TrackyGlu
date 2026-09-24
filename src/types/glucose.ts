export type GlucoseMeasurementContext =
  | 'fasting_morning'
  | 'pre_meal'
  | 'post_meal_1h'
  | 'post_meal_2h'
  | 'post_meal_3h_plus'
  | 'bedtime'
  | 'random'
  | 'other'

export type GlucoseMeasurementSource = 'capillary' | 'cgm' | 'lab' | 'other'
export type GlucoseMealType = 'breakfast' | 'lunch' | 'dinner' | 'snack' | 'other'
export type ActivityIntensity = 'light' | 'moderate' | 'vigorous'

export interface GlucoseReading {
  id: string
  patientId: string
  glucoseValue: number
  unit: 'mg/dL'
  measurementContext: GlucoseMeasurementContext
  timestamp: string
  measurementSource: GlucoseMeasurementSource
  hasEaten: boolean | null
  lastMealAt: string | null
  mealType: GlucoseMealType | null
  carbohydrateEstimate: number | null
  treatmentDueBeforeMeasurement: boolean | null
  treatmentTakenAsScheduled: boolean | null
  recentPhysicalActivity: boolean | null
  activityDurationMin: number | null
  activityIntensity: ActivityIntensity | null
  symptomsPresent: boolean | null
  symptoms: string[]
  illnessFlag: boolean | null
  stressFlag: boolean | null
  sleepQuality: 'good' | 'regular' | 'poor' | 'unknown' | null
  observation: string | null
}

export interface CreateGlucoseReadingInput {
  glucoseValue: number
  unit: 'mg/dL'
  measurementContext: GlucoseMeasurementContext
  timestamp: string
  measurementSource?: GlucoseMeasurementSource
  hasEaten?: boolean | null
  lastMealAt?: string | null
  mealType?: GlucoseMealType | null
  carbohydrateEstimate?: number | null
  treatmentDueBeforeMeasurement?: boolean | null
  treatmentTakenAsScheduled?: boolean | null
  recentPhysicalActivity?: boolean | null
  activityDurationMin?: number | null
  activityIntensity?: ActivityIntensity | null
  symptomsPresent?: boolean | null
  symptoms?: string[]
  illnessFlag?: boolean | null
  stressFlag?: boolean | null
  sleepQuality?: 'good' | 'regular' | 'poor' | 'unknown' | null
  observation?: string | null
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
  measurement_source: GlucoseMeasurementSource
  has_eaten: boolean | null
  last_meal_at: string | null
  meal_type: GlucoseMealType | null
  carbohydrate_estimate: number | null
  treatment_due_before_measurement: boolean | null
  treatment_taken_as_scheduled: boolean | null
  recent_physical_activity: boolean | null
  activity_duration_min: number | null
  activity_intensity: ActivityIntensity | null
  symptoms_present: boolean | null
  symptoms: string[]
  illness_flag: boolean | null
  stress_flag: boolean | null
  sleep_quality: 'good' | 'regular' | 'poor' | 'unknown' | null
  observation: string | null
  quality_state: 'valid' | 'invalid' | 'na'
  processing_state: 'persisted' | 'skipped_duplicate' | 'failed' | 'filtered'
  recorded_by_profile_id: string | null
  recorded_by_actor_type: string | null
  created_at: string
}
