import assert from 'node:assert/strict'
import { randomUUID } from 'node:crypto'
import { localSupabase, requireData, sampleHistory } from '../scripts/local-supabase.mjs'

const { admin, client } = localSupabase()
const users = []
const patientIds = []
let checks = 0
function ok(label) { checks++; console.log(`✓ ${label}`) }
async function account(role, name) {
  const email = `${randomUUID()}@trackyglu.test`
  const password = `Test-${randomUUID()}!`
  const created = requireData(await admin.auth.admin.createUser({ email, password, email_confirm: true })).user
  users.push(created.id)
  const api = client()
  requireData(await api.auth.signInWithPassword({ email, password }))
  const profileId = requireData(await api.rpc('create_account', { account_role: role, account_name: name }))
  const entity = requireData(await api.from(role === 'patient' ? 'patients' : 'professionals').select('*').eq('profile_id', profileId).single())
  if (role === 'patient') patientIds.push(entity.id)
  return { api, profileId, id: entity.id, userId: created.id }
}
async function completeHistory(patient) {
  return requireData(await patient.api.rpc('save_patient_history', { history_data: sampleHistory, next_step: 3, expected_revision: 0, complete: true }))
}
async function invite(professional) {
  return requireData(await professional.api.from('patient_invitations').insert({ professional_id: professional.id }).select().single())
}

try {
  const patient = await account('patient', 'Paciente Uno de Prueba')
  const otherPatient = await account('patient', 'Paciente Dos de Prueba')
  const professional = await account('professional', 'Profesional Uno de Prueba')
  const otherProfessional = await account('professional', 'Profesional Dos de Prueba')
  assert.equal(requireData(await patient.api.rpc('create_account', { account_role: 'professional', account_name: 'Intento' })), patient.profileId)
  assert.equal(requireData(await patient.api.from('profiles').select('role').single()).role, 'patient')
  assert.ok((await patient.api.from('profiles').update({ role: 'admin' }).eq('id', patient.profileId)).error)
  assert.ok((await patient.api.rpc('create_account', { account_role: 'admin', account_name: 'Admin' })).error)
  ok('Alta de ambos roles, inicialización idempotente y rol inmutable')

  const reading = { patient_id: patient.id, glucose_value: 110, unit: 'mg/dL', measurement_context: 'fasting_morning', measured_at: new Date().toISOString(), source_channel: 'web' }
  assert.ok((await patient.api.from('glucose_readings').insert(reading)).error)
  assert.ok((await patient.api.rpc('save_patient_history', { history_data: {}, next_step: 3, expected_revision: 0, complete: true })).error)
  assert.ok((await patient.api.rpc('save_patient_history', { history_data: { ...sampleHistory, sex: 'invalid' }, next_step: 3, expected_revision: 0, complete: true })).error)
  assert.ok((await patient.api.rpc('save_patient_history', { history_data: { ...sampleHistory, medications: 'wrong type' }, next_step: 3, expected_revision: 0, complete: true })).error)
  const history = await completeHistory(patient)
  assert.equal(history.revision, 1)
  assert.ok(history.completed_at)
  assert.equal(requireData(await patient.api.from('patient_histories').select('revision').single()).revision, 1)
  assert.ok((await patient.api.rpc('save_patient_history', { history_data: sampleHistory, next_step: 3, expected_revision: 0, complete: true })).error)
  requireData(await patient.api.from('glucose_readings').insert(reading))
  assert.ok((await patient.api.from('glucose_readings').insert({ ...reading, patient_id: otherPatient.id })).error)
  ok('Historia obligatoria, datos válidos, persistencia y conflicto entre ediciones')

  for (const api of [otherPatient.api, professional.api, otherProfessional.api, client()]) {
    const result = await api.from('patient_histories').select('*').eq('patient_id', patient.id)
    assert.ok(result.error || result.data.length === 0)
  }
  assert.ok((await professional.api.rpc('review_patient_history', { target_patient: patient.id, expected_revision: 1, review_note: 'No debería poder leer' })).error)
  assert.ok((await professional.api.from('patient_invitations').insert({ professional_id: professional.id })).error)
  ok('Paciente y profesional sin vínculo no acceden; revisión ajena bloqueada')

  for (const person of [professional, otherProfessional]) requireData(await person.api.from('professionals').update({ specialty: 'Medicina general', license_number: 'PRUEBA', institution: 'Entorno de pruebas', completed_at: new Date().toISOString() }).eq('id', person.id))
  const invitation = await invite(professional)
  assert.ok((await otherProfessional.api.from('patient_invitations').insert({ professional_id: professional.id })).error)
  assert.equal(requireData(await otherProfessional.api.from('patient_invitations').select()).length, 0)
  const preview = requireData(await patient.api.rpc('preview_patient_invitation', { invitation_code: invitation.code }))
  assert.equal(preview.name, 'Profesional Uno de Prueba')
  requireData(await patient.api.rpc('accept_patient_invitation', { invitation_code: invitation.code }))
  assert.ok((await otherPatient.api.rpc('accept_patient_invitation', { invitation_code: invitation.code })).error)
  assert.ok((await professional.api.rpc('accept_patient_invitation', { invitation_code: invitation.code })).error)
  assert.equal(requireData(await professional.api.from('patient_histories').select('*')).length, 1)
  assert.equal(requireData(await otherProfessional.api.from('patient_histories').select('*')).length, 0)
  assert.equal(requireData(await patient.api.from('professionals').select('id')).length, 1)
  const directory = requireData(await professional.api.from('patients').select('id,profile_id,profiles(display_name),patient_histories(completed_at)'))
  assert.equal(directory.length, 1)
  assert.equal(directory[0].profiles.display_name, 'Paciente Uno de Prueba')
  assert.ok(directory[0].patient_histories.completed_at)
  ok('Invitación de un uso, previsualización y directorio limitado a pacientes vinculados')

  assert.ok((await professional.api.from('patient_histories').update({ data: {} }).eq('patient_id', patient.id)).error)
  requireData(await professional.api.rpc('review_patient_history', { target_patient: patient.id, expected_revision: 1, review_note: 'Revisión de prueba con datos declarados.' }))
  let notes = requireData(await patient.api.from('patient_history_reviews').select())
  assert.equal(notes.length, 1)
  const draft = requireData(await patient.api.rpc('save_patient_history', { history_data: { ...sampleHistory, notes: 'Cambio del paciente' }, next_step: 1, expected_revision: 1, complete: false }))
  assert.equal(draft.completed_at, null)
  assert.ok((await professional.api.rpc('review_patient_history', { target_patient: patient.id, expected_revision: 1, review_note: 'Obsoleta' })).error)
  assert.equal(requireData(await patient.api.from('patient_history_versions').select()).length, 2)
  notes = requireData(await patient.api.from('patient_history_reviews').select())
  assert.equal(notes[0].history_revision, 1)
  ok('Revisión de versión exacta, autoría y conservación de cambios anteriores')

  const expired = await invite(otherProfessional)
  requireData(await admin.from('patient_invitations').update({ expires_at: '2000-01-01' }).eq('id', expired.id))
  assert.ok((await patient.api.rpc('accept_patient_invitation', { invitation_code: expired.code })).error)
  assert.ok((await otherPatient.api.rpc('end_patient_assignment', { target_patient: patient.id, target_professional: professional.id })).error)
  requireData(await patient.api.rpc('end_patient_assignment', { target_patient: patient.id, target_professional: professional.id }))
  assert.equal(requireData(await professional.api.from('patient_histories').select()).length, 0)
  assert.equal(requireData(await professional.api.from('glucose_readings').select()).length, 0)
  requireData(await patient.api.rpc('accept_patient_invitation', { invitation_code: invitation.code }))
  assert.equal(requireData(await professional.api.from('patient_histories').select()).length, 0)
  ok('Caducidad, revocación efectiva y código usado sin reactivar un vínculo')

  console.log(`${checks} grupos de integración aprobados.`)
} finally {
  // Cleanup only records created by this test in the dedicated local project.
  if (patientIds.length) {
    requireData(await admin.from('glucose_readings').delete().in('patient_id', patientIds))
    requireData(await admin.from('patient_invitations').delete().in('accepted_by', patientIds))
    requireData(await admin.from('patient_history_reviews').delete().in('patient_id', patientIds))
    requireData(await admin.from('patient_history_versions').delete().in('patient_id', patientIds))
  }
  for (const id of users) requireData(await admin.auth.admin.deleteUser(id))
}
