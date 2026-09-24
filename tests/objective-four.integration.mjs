import assert from 'node:assert/strict'
import { randomUUID } from 'node:crypto'
import { localSupabase, requireData, sampleHistory } from '../scripts/local-supabase.mjs'

const { admin, client } = localSupabase()
const users = []
let patient
let professional
let otherProfessional
let alertId
let taskId
let contextId

async function account(role, name) {
  const email = `${randomUUID()}@trackyglu.test`
  const password = `Test-${randomUUID()}!`
  const created = requireData(await admin.auth.admin.createUser({ email, password, email_confirm: true })).user
  users.push(created.id)
  const api = client()
  requireData(await api.auth.signInWithPassword({ email, password }))
  const profileId = requireData(await api.rpc('create_account', { account_role: role, account_name: name }))
  const entity = requireData(await api.from(role === 'patient' ? 'patients' : 'professionals').select('id').eq('profile_id', profileId).single())
  return { api, profileId, id: entity.id }
}

try {
  patient = await account('patient', 'Paciente Objetivo Cuatro')
  professional = await account('professional', 'Profesional Objetivo Cuatro')
  otherProfessional = await account('professional', 'Profesional Sin Acceso')
  requireData(await patient.api.rpc('save_patient_history', {
    history_data: sampleHistory,
    next_step: 3,
    expected_revision: 0,
    complete: true,
  }))
  requireData(await admin.from('professional_patients').insert({ professional_id: professional.id, patient_id: patient.id, active: true }))

  const alert = requireData(await admin.from('alerts').insert({
    patient_id: patient.id,
    alert_type: 'glucose_very_high',
    severity: 'warning',
    status: 'open',
    reason: 'Prueba de preparación de caso',
    metadata: { glucose_value: 320, unit: 'mg/dL' },
  }).select('id').single())
  alertId = alert.id

  const task = requireData(await admin.from('clinical_tasks').insert({
    patient_id: patient.id,
    source_alert_id: alert.id,
    trigger_rule: 'alert_created',
    priority: 'warning',
    status: 'pending_review',
    assigned_professional_id: professional.id,
    ai_draft_status: 'not_requested',
  }).select('id').single())
  taskId = task.id

  const context = requireData(await admin.from('clinical_case_contexts').insert({
    clinical_task_id: task.id,
    source_alert_id: alert.id,
    patient_id: patient.id,
    assigned_professional_id: professional.id,
    context_version: '1.0.0',
    status: 'prepared',
    snapshot: { recent_readings: [], recent_daily_context: [], adherence_summaries: [], history: { revision: 1 } },
    missing_data: [],
  }).select('id,status,clinical_task_id').single())
  contextId = context.id

  const visible = requireData(await professional.api.from('clinical_case_contexts').select('id,status,clinical_task_id').eq('id', context.id).single())
  assert.equal(visible.status, 'prepared')
  assert.equal(visible.clinical_task_id, task.id)

  const blocked = requireData(await otherProfessional.api.from('clinical_case_contexts').select('id').eq('id', context.id))
  assert.equal(blocked.length, 0)
  const patientBlocked = requireData(await patient.api.from('clinical_case_contexts').select('id').eq('id', context.id))
  assert.equal(patientBlocked.length, 0)

  const duplicateContext = await admin.from('clinical_case_contexts').insert({
    source_alert_id: alert.id,
    patient_id: patient.id,
    context_version: '1.0.0',
    status: 'prepared',
    snapshot: {},
    missing_data: [],
  })
  assert.ok(duplicateContext.error)

  const duplicateTask = await admin.from('clinical_tasks').insert({
    patient_id: patient.id,
    source_alert_id: alert.id,
    trigger_rule: 'alert_acknowledged',
    priority: 'warning',
    status: 'pending_review',
    assigned_professional_id: professional.id,
  })
  assert.ok(duplicateTask.error)

  requireData(await admin.from('professional_patients').update({ active: false }).eq('professional_id', professional.id).eq('patient_id', patient.id))
  const afterUnlink = requireData(await professional.api.from('clinical_case_contexts').select('id').eq('id', context.id))
  assert.equal(afterUnlink.length, 0)
  console.log('✓ Objetivo 4: snapshot visible solo al profesional vinculado e idempotencia por alerta')
} finally {
  if (contextId) requireData(await admin.from('clinical_case_contexts').delete().eq('id', contextId))
  if (taskId) requireData(await admin.from('clinical_tasks').delete().eq('id', taskId))
  if (alertId) requireData(await admin.from('alerts').delete().eq('id', alertId))
  if (patient?.id && professional?.id) requireData(await admin.from('professional_patients').delete().eq('patient_id', patient.id).eq('professional_id', professional.id))
  if (patient?.id) {
    requireData(await admin.from('patient_history_reviews').delete().eq('patient_id', patient.id))
    requireData(await admin.from('patient_history_versions').delete().eq('patient_id', patient.id))
    requireData(await admin.from('patient_histories').delete().eq('patient_id', patient.id))
  }
  for (const userId of users) requireData(await admin.auth.admin.deleteUser(userId))
}
