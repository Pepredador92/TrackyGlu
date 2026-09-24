import type { GlucoseReading, GlucoseReadingRow } from '../../types/glucose'

export function mapGlucoseRowToReading(row: GlucoseReadingRow): GlucoseReading {
  return {
    id: row.id,
    patientId: row.patient_id,
    glucoseValue: row.glucose_value,
    unit: row.unit,
    measurementContext: row.measurement_context,
    timestamp: row.measured_at,
    measurementSource: row.measurement_source,
    hasEaten: row.has_eaten,
    lastMealAt: row.last_meal_at,
    mealType: row.meal_type,
    carbohydrateEstimate: row.carbohydrate_estimate,
    treatmentDueBeforeMeasurement: row.treatment_due_before_measurement,
    treatmentTakenAsScheduled: row.treatment_taken_as_scheduled,
    recentPhysicalActivity: row.recent_physical_activity,
    activityDurationMin: row.activity_duration_min,
    activityIntensity: row.activity_intensity,
    symptomsPresent: row.symptoms_present,
    symptoms: Array.isArray(row.symptoms) ? row.symptoms : [],
    illnessFlag: row.illness_flag,
    stressFlag: row.stress_flag,
    sleepQuality: row.sleep_quality,
    observation: row.observation,
  }
}
