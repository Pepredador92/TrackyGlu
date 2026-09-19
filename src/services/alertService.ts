import { supabase } from './supabase/supabaseClient'

export type AlertSeverity = 'info' | 'warning' | 'critical'
export type AlertStatus = 'open' | 'acknowledged' | 'closed'

export interface ProfessionalAlert {
  id: string
  eventId: string
  patientId: string
  patientName: string
  alertType: string
  severity: AlertSeverity
  status: AlertStatus
  reason: string
  glucoseValue: number | null
  unit: string
  measurementContext: string | null
  measuredAt: string | null
  createdAt: string
  acknowledgedAt: string | null
}

interface AlertRow {
  id: string
  event_id: string
  patient_id: string
  source_reading_id: string | null
  alert_type: string
  severity: AlertSeverity
  status: AlertStatus
  reason: string
  acknowledged_at: string | null
  closed_at: string | null
  metadata: unknown
  created_at: string
}

interface PatientRow {
  id: string
  profile_id: string
}

interface ProfileRow {
  id: string
  display_name: string | null
}

const ALERT_COLUMNS = [
  'id',
  'event_id',
  'patient_id',
  'source_reading_id',
  'alert_type',
  'severity',
  'status',
  'reason',
  'acknowledged_at',
  'closed_at',
  'metadata',
  'created_at',
].join(', ')

const STATUS_ORDER: Record<AlertStatus, number> = {
  open: 0,
  acknowledged: 1,
  closed: 2,
}

function getMetadataValue(metadata: unknown, key: string): unknown {
  if (!metadata || typeof metadata !== 'object' || Array.isArray(metadata)) {
    return null
  }

  return (metadata as Record<string, unknown>)[key] ?? null
}

function getMetadataNumber(metadata: unknown, key: string): number | null {
  const value = getMetadataValue(metadata, key)
  return typeof value === 'number' && Number.isFinite(value) ? value : null
}

function getMetadataString(metadata: unknown, key: string): string | null {
  const value = getMetadataValue(metadata, key)
  return typeof value === 'string' && value.length > 0 ? value : null
}

async function getPatientNames(patientIds: string[]): Promise<Map<string, string>> {
  if (patientIds.length === 0) {
    return new Map()
  }

  const { data: patients, error: patientsError } = await supabase
    .from('patients')
    .select('id, profile_id')
    .in('id', patientIds)

  if (patientsError) {
    throw patientsError
  }

  const patientRows = (patients ?? []) as PatientRow[]
  const profileIds = [...new Set(patientRows.map((patient) => patient.profile_id))]
  if (profileIds.length === 0) {
    return new Map()
  }

  const { data: profiles, error: profilesError } = await supabase
    .from('profiles')
    .select('id, display_name')
    .in('id', profileIds)

  if (profilesError) {
    throw profilesError
  }

  const profileNames = new Map(
    ((profiles ?? []) as ProfileRow[]).map((profile) => [profile.id, profile.display_name ?? 'Paciente']),
  )

  return new Map(
    patientRows.map((patient) => [patient.id, profileNames.get(patient.profile_id) ?? 'Paciente']),
  )
}

function mapAlertRow(row: AlertRow, patientNames: Map<string, string>): ProfessionalAlert {
  return {
    id: row.id,
    eventId: row.event_id,
    patientId: row.patient_id,
    patientName: patientNames.get(row.patient_id) ?? 'Paciente',
    alertType: row.alert_type,
    severity: row.severity,
    status: row.status,
    reason: row.reason,
    glucoseValue: getMetadataNumber(row.metadata, 'glucoseValue') ?? getMetadataNumber(row.metadata, 'glucose_value'),
    unit: getMetadataString(row.metadata, 'unit') ?? '',
    measurementContext: getMetadataString(row.metadata, 'measurementContext') ?? getMetadataString(row.metadata, 'measurement_context'),
    measuredAt: getMetadataString(row.metadata, 'measuredAt') ?? getMetadataString(row.metadata, 'measured_at'),
    createdAt: row.created_at,
    acknowledgedAt: row.acknowledged_at,
  }
}

export async function getProfessionalAlerts(): Promise<ProfessionalAlert[]> {
  const { data, error } = await supabase
    .from('alerts')
    .select(ALERT_COLUMNS)
    .order('created_at', { ascending: false })

  if (error) {
    throw error
  }

  const rows = (data ?? []) as unknown as AlertRow[]
  const patientIds = [...new Set(rows.map((row) => row.patient_id))]
  const patientNames = await getPatientNames(patientIds)

  return rows
    .map((row) => mapAlertRow(row, patientNames))
    .sort((first, second) => STATUS_ORDER[first.status] - STATUS_ORDER[second.status])
}

export async function acknowledgeAlert(alertId: string): Promise<void> {
  const { error } = await supabase
    .from('alerts')
    .update({ status: 'acknowledged' })
    .eq('id', alertId)
    .eq('status', 'open')
    .select(ALERT_COLUMNS)
    .single()

  if (error) {
    throw error
  }
}
