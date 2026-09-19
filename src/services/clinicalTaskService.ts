import { supabase } from './supabase/supabaseClient'

export type ClinicalTaskStatus = 'pending_review' | 'draft_ready' | 'in_review' | 'closed'
export type ClinicalTaskDecision = 'approved' | 'modified' | 'cancelled'
export type ClinicalTaskPriority = 'info' | 'warning' | 'critical'
export type AiDraftStatus = 'not_requested' | 'pending' | 'generated' | 'failed'

export interface ProfessionalClinicalTask {
  id: string
  eventId: string
  patientId: string
  patientName: string
  sourceAlertId: string | null
  triggerRule: string
  priority: ClinicalTaskPriority
  status: ClinicalTaskStatus
  assignedProfessionalId: string | null
  firstReviewAt: string | null
  closedAt: string | null
  finalDecision: ClinicalTaskDecision | null
  reviewNote: string | null
  aiDraftStatus: AiDraftStatus
  createdAt: string
  alertType: string | null
  alertReason: string | null
  glucoseValue: number | null
  unit: string | null
}

interface ClinicalTaskRow {
  id: string
  event_id: string
  patient_id: string
  source_event_id: string | null
  source_alert_id: string | null
  trigger_rule: string
  priority: ClinicalTaskPriority
  status: ClinicalTaskStatus
  assigned_professional_id: string | null
  first_review_at: string | null
  closed_at: string | null
  final_decision: ClinicalTaskDecision | null
  review_note: string | null
  ai_draft_status: AiDraftStatus
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

interface SourceAlertRow {
  id: string
  alert_type: string
  reason: string
  metadata: unknown
}

const TASK_COLUMNS = [
  'id',
  'event_id',
  'patient_id',
  'source_event_id',
  'source_alert_id',
  'trigger_rule',
  'priority',
  'status',
  'assigned_professional_id',
  'first_review_at',
  'closed_at',
  'final_decision',
  'review_note',
  'ai_draft_status',
  'created_at',
].join(', ')

const TASK_STATUS_ORDER: Record<ClinicalTaskStatus, number> = {
  pending_review: 0,
  in_review: 1,
  closed: 2,
  draft_ready: 3,
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

  const patientRows = (patients ?? []) as unknown as PatientRow[]
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
    ((profiles ?? []) as unknown as ProfileRow[]).map((profile) => [profile.id, profile.display_name ?? 'Paciente']),
  )

  return new Map(
    patientRows.map((patient) => [patient.id, profileNames.get(patient.profile_id) ?? 'Paciente']),
  )
}

async function getSourceAlerts(alertIds: string[]): Promise<Map<string, SourceAlertRow>> {
  if (alertIds.length === 0) {
    return new Map()
  }

  const { data, error } = await supabase
    .from('alerts')
    .select('id, alert_type, reason, metadata')
    .in('id', alertIds)

  if (error) {
    throw error
  }

  return new Map(((data ?? []) as unknown as SourceAlertRow[]).map((alert) => [alert.id, alert]))
}

function mapTaskRow(
  row: ClinicalTaskRow,
  patientNames: Map<string, string>,
  sourceAlerts: Map<string, SourceAlertRow>,
): ProfessionalClinicalTask {
  const sourceAlert = row.source_alert_id ? sourceAlerts.get(row.source_alert_id) : undefined

  return {
    id: row.id,
    eventId: row.event_id,
    patientId: row.patient_id,
    patientName: patientNames.get(row.patient_id) ?? 'Paciente',
    sourceAlertId: row.source_alert_id,
    triggerRule: row.trigger_rule,
    priority: row.priority,
    status: row.status,
    assignedProfessionalId: row.assigned_professional_id,
    firstReviewAt: row.first_review_at,
    closedAt: row.closed_at,
    finalDecision: row.final_decision,
    reviewNote: row.review_note,
    aiDraftStatus: row.ai_draft_status,
    createdAt: row.created_at,
    alertType: sourceAlert?.alert_type ?? null,
    alertReason: sourceAlert?.reason ?? null,
    glucoseValue: getMetadataNumber(sourceAlert?.metadata, 'glucose_value') ?? getMetadataNumber(sourceAlert?.metadata, 'glucoseValue'),
    unit: getMetadataString(sourceAlert?.metadata, 'unit'),
  }
}

export async function getProfessionalClinicalTasks(): Promise<ProfessionalClinicalTask[]> {
  const { data, error } = await supabase
    .from('clinical_tasks')
    .select(TASK_COLUMNS)
    .order('created_at', { ascending: false })

  if (error) {
    throw error
  }

  const rows = (data ?? []) as unknown as ClinicalTaskRow[]
  const patientNames = await getPatientNames([...new Set(rows.map((row) => row.patient_id))])
  const sourceAlerts = await getSourceAlerts(
    [...new Set(rows.map((row) => row.source_alert_id).filter((id): id is string => Boolean(id)))],
  )

  return rows
    .map((row) => mapTaskRow(row, patientNames, sourceAlerts))
    .sort((first, second) => TASK_STATUS_ORDER[first.status] - TASK_STATUS_ORDER[second.status])
}

export async function startClinicalTaskReview(taskId: string): Promise<void> {
  const { error } = await supabase
    .from('clinical_tasks')
    .update({ status: 'in_review' })
    .eq('id', taskId)
    .eq('status', 'pending_review')
    .select(TASK_COLUMNS)
    .single()

  if (error) {
    throw error
  }
}

export async function closeClinicalTask(
  taskId: string,
  finalDecision: ClinicalTaskDecision,
  reviewNote: string,
): Promise<void> {
  if (!['approved', 'modified', 'cancelled'].includes(finalDecision)) {
    throw new Error('Invalid clinical task decision')
  }

  const trimmedReviewNote = reviewNote.trim()
  if (!trimmedReviewNote) {
    throw new Error('Review note is required')
  }

  const { error } = await supabase
    .from('clinical_tasks')
    .update({
      status: 'closed',
      final_decision: finalDecision,
      review_note: trimmedReviewNote,
    })
    .eq('id', taskId)
    .eq('status', 'in_review')
    .select(TASK_COLUMNS)
    .single()

  if (error) {
    throw error
  }
}
