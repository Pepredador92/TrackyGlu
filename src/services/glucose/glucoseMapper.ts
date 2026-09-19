import type { GlucoseReading, GlucoseReadingRow } from '../../types/glucose'

export function mapGlucoseRowToReading(row: GlucoseReadingRow): GlucoseReading {
  return {
    id: row.id,
    patientId: row.patient_id,
    glucoseValue: row.glucose_value,
    unit: row.unit,
    measurementContext: row.measurement_context,
    timestamp: row.measured_at,
  }
}
