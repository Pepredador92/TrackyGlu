import assert from 'node:assert/strict'
import { randomUUID } from 'node:crypto'
import { localSupabase, requireData, sampleHistory } from '../scripts/local-supabase.mjs'

const { admin, client } = localSupabase()
const users = []
let patient
let professional
let otherProfessional
let taskId
let alertId
let contextId
let draftId

async function account(role, name) {
  const email = `${randomUUID()}@trackyglu.test`
  const password = `Test-${randomUUID()}!`
  const user = requireData(await admin.auth.admin.createUser({ email, password, email_confirm: true })).user
  users.push(user.id)
  const api = client()
  requireData(await api.auth.signInWithPassword({ email, password }))
  const profileId = requireData(await api.rpc('create_account', { account_role: role, account_name: name }))
  const entity = requireData(await api.from(role === 'patient' ? 'patients' : 'professionals').select('id').eq('profile_id', profileId).single())
  return { api, id: entity.id }
}

try {
  patient = await account('patient', 'Paciente Objetivo Cinco')
  professional = await account('professional', 'Profesional Objetivo Cinco')
  otherProfessional = await account('professional', 'Profesional Aislado Cinco')
  requireData(await patient.api.rpc('save_patient_history', { history_data: sampleHistory, next_step: 3, expected_revision: 0, complete: true }))
  requireData(await admin.from('professional_patients').insert({ professional_id: professional.id, patient_id: patient.id, active: true }))

  const alert = requireData(await admin.from('alerts').insert({ patient_id: patient.id, alert_type: 'glucose_very_high', severity: 'warning', reason: 'Prueba objetivo cinco' }).select('id').single())
  alertId = alert.id
  const task = requireData(await admin.from('clinical_tasks').insert({ patient_id: patient.id, source_alert_id: alert.id, trigger_rule: 'alert_created', priority: 'warning', assigned_professional_id: professional.id }).select('id').single())
  taskId = task.id
  const context = requireData(await admin.from('clinical_case_contexts').insert({ clinical_task_id: task.id, source_alert_id: alert.id, patient_id: patient.id, assigned_professional_id: professional.id, context_version: '1.0.0', status: 'prepared', snapshot: {}, missing_data: [] }).select('id').single())
  contextId = context.id
  const draft = requireData(await admin.from('clinical_task_drafts').insert({ clinical_task_id: task.id, clinical_case_context_id: context.id, patient_id: patient.id, status: 'generated', draft_text: 'Borrador inicial para revisión.', structured_output: { summary: 'Inicial' }, source_keys: ['ada-2026-section-6'], model: 'gpt-4o-mini' }).select('id').single())
  draftId = draft.id

  const visible = requireData(await professional.api.from('clinical_task_drafts').select('id,status,draft_text').eq('id', draftId).single())
  assert.equal(visible.status, 'generated')
  const otherVisible = requireData(await otherProfessional.api.from('clinical_task_drafts').select('id').eq('id', draftId))
  assert.equal(otherVisible.length, 0)
  const patientVisible = requireData(await patient.api.from('clinical_task_drafts').select('id').eq('id', draftId))
  assert.equal(patientVisible.length, 0)

  const edited = requireData(await professional.api.rpc('review_clinical_ai_draft', { target_draft: draftId, next_status: 'edited', next_text: 'Borrador corregido por el profesional.', review_note: 'Se confirmó el contexto de la lectura.' }))
  assert.equal(edited.status, 'edited')
  assert.equal(edited.draft_text, 'Borrador corregido por el profesional.')
  assert.ok((await professional.api.rpc('review_clinical_ai_draft', { target_draft: draftId, next_status: 'edited', next_text: '' })).error)
  const revisions = requireData(await admin.from('clinical_task_draft_revisions').select('action').eq('draft_id', draftId).order('revision'))
  assert.deepEqual(revisions.map((row) => row.action), ['generated', 'edited'])
  console.log('✓ Objetivo 5: borrador aislado por vínculo, edición profesional y auditoría de revisiones')
} finally {
  if (draftId) requireData(await admin.from('clinical_task_draft_revisions').delete().eq('draft_id', draftId))
  if (draftId) requireData(await admin.from('clinical_task_drafts').delete().eq('id', draftId))
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
