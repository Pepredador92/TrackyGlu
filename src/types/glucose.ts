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
