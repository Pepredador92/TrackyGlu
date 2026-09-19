import { getCurrentPatientId } from '../patient/patientService'
import { supabase } from '../supabase/supabaseClient'
import type { CreateGlucoseReadingInput, GlucoseReading, GlucoseReadingRow } from '../../types/glucose'
import { mapGlucoseRowToReading } from './glucoseMapper'

const GLUCOSE_READING_COLUMNS = [
  'id',
  'event_id',
  'patient_id',
  'glucose_value',
  'unit',
  'measurement_context',
  'measured_at',
  'source_channel',
  'recorded_by_profile_id',
  'recorded_by_actor_type',
  'created_at',
].join(', ')

export async function createReading(input: CreateGlucoseReadingInput): Promise<GlucoseReading> {
  const patientId = await getCurrentPatientId()
  const payload = {
    patient_id: patientId,
    glucose_value: input.glucoseValue,
    unit: input.unit,
    measurement_context: input.measurementContext,
    measured_at: input.timestamp,
    source_channel: 'web' as const,
  }

  const { data, error } = await supabase
    .from('glucose_readings')
    .insert(payload)
    .select(GLUCOSE_READING_COLUMNS)
    .single()

  if (error) {
    throw error
  }

  return mapGlucoseRowToReading(data as unknown as GlucoseReadingRow)
}

export async function getReadings(): Promise<GlucoseReading[]> {
  const patientId = await getCurrentPatientId()
  const { data, error } = await supabase
    .from('glucose_readings')
    .select(GLUCOSE_READING_COLUMNS)
    .eq('patient_id', patientId)
    .order('measured_at', { ascending: false })

  if (error) {
    throw error
  }

  return (data as unknown as GlucoseReadingRow[]).map(mapGlucoseRowToReading)
}
