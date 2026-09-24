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
  'measurement_source',
  'has_eaten',
  'last_meal_at',
  'meal_type',
  'carbohydrate_estimate',
  'treatment_due_before_measurement',
  'treatment_taken_as_scheduled',
  'recent_physical_activity',
  'activity_duration_min',
  'activity_intensity',
  'symptoms_present',
  'symptoms',
  'illness_flag',
  'stress_flag',
  'sleep_quality',
  'observation',
  'quality_state',
  'processing_state',
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
    measurement_source: input.measurementSource ?? 'capillary',
    has_eaten: input.hasEaten ?? null,
    last_meal_at: input.lastMealAt ?? null,
    meal_type: input.mealType ?? null,
    carbohydrate_estimate: input.carbohydrateEstimate ?? null,
    treatment_due_before_measurement: input.treatmentDueBeforeMeasurement ?? null,
    treatment_taken_as_scheduled: input.treatmentTakenAsScheduled ?? null,
    recent_physical_activity: input.recentPhysicalActivity ?? null,
    activity_duration_min: input.activityDurationMin ?? null,
    activity_intensity: input.activityIntensity ?? null,
    symptoms_present: input.symptomsPresent ?? null,
    symptoms: input.symptoms ?? [],
    illness_flag: input.illnessFlag ?? null,
    stress_flag: input.stressFlag ?? null,
    sleep_quality: input.sleepQuality ?? null,
    observation: input.observation?.trim() || null,
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

function localDayBounds(date = new Date()): { localDate: string; start: string; end: string } {
  const startDate = new Date(date.getFullYear(), date.getMonth(), date.getDate())
  const endDate = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1)
  const localDate = `${startDate.getFullYear()}-${String(startDate.getMonth() + 1).padStart(2, '0')}-${String(startDate.getDate()).padStart(2, '0')}`
  return { localDate, start: startDate.toISOString(), end: endDate.toISOString() }
}

export interface DailyCaptureContext {
  localDate: string
  isFirstReading: boolean
  suggestedContext: 'fasting_morning' | 'pre_meal' | 'bedtime'
  hasTreatmentPlan: boolean
  dailyContext: DailyContextRow | null
}

export interface DailyContextRow {
  id?: string
  patient_id?: string
  local_date: string
  treatment_adherence_24h: boolean | null
  missed_doses_7d: 'none' | 'one_two' | 'three_five' | 'more_than_five' | null
  missed_dose_reason: 'forgetfulness' | 'unavailable' | 'side_effects' | 'cost' | 'other' | null
  illness_flag: boolean | null
  stress_flag: boolean | null
  sleep_quality: 'good' | 'regular' | 'poor' | 'unknown' | null
}

export async function getDailyCaptureContext(): Promise<DailyCaptureContext> {
  const patientId = await getCurrentPatientId()
  const { localDate, start, end } = localDayBounds()
  const [{ count, error: countError }, { data: history, error: historyError }, { data: dailyContext, error: contextError }] = await Promise.all([
    supabase.from('glucose_readings').select('id', { count: 'exact', head: true }).eq('patient_id', patientId).gte('measured_at', start).lt('measured_at', end),
    supabase.from('patient_histories').select('data').eq('patient_id', patientId).maybeSingle(),
    supabase.from('glucose_daily_context').select('*').eq('patient_id', patientId).eq('local_date', localDate).maybeSingle(),
  ])
  if (countError) throw countError
  if (historyError) throw historyError
  if (contextError) throw contextError
  const hour = new Date().getHours()
  const suggestedContext = hour < 11 ? 'fasting_morning' : hour >= 20 ? 'bedtime' : 'pre_meal'
  const historyData = (history?.data ?? {}) as { treatmentStatus?: string; medications?: unknown[] }
  return {
    localDate,
    isFirstReading: (count ?? 0) === 0,
    suggestedContext,
    hasTreatmentPlan: historyData.treatmentStatus !== 'none' && historyData.treatmentStatus !== 'unknown',
    dailyContext: dailyContext as DailyContextRow | null,
  }
}

export async function saveDailyContext(context: Omit<DailyContextRow, 'id' | 'patient_id'>): Promise<DailyContextRow> {
  const patientId = await getCurrentPatientId()
  const { data, error } = await supabase.from('glucose_daily_context').upsert({ patient_id: patientId, ...context }, { onConflict: 'patient_id,local_date' }).select('*').single()
  if (error) throw error
  return data as DailyContextRow
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

export async function getPatientReadings(patientId: string, days = 30): Promise<GlucoseReading[]> {
  const from = new Date()
  from.setDate(from.getDate() - (days - 1))
  const { data, error } = await supabase
    .from('glucose_readings')
    .select(GLUCOSE_READING_COLUMNS)
    .eq('patient_id', patientId)
    .gte('measured_at', from.toISOString())
    .order('measured_at', { ascending: true })
  if (error) throw error
  return (data as unknown as GlucoseReadingRow[]).map(mapGlucoseRowToReading)
}
