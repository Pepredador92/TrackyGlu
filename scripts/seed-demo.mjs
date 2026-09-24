import { localSupabase, requireData, sampleHistory } from './local-supabase.mjs'
const { admin, client } = localSupabase()
const password = 'TrackyGlu2026!'
const people = [
  { email: 'paciente@trackyglu.test', name: 'Elena Martínez', role: 'patient' },
  { email: 'profesional@trackyglu.test', name: 'Andrea García', role: 'professional' },
]
const accounts = []
const existing = requireData(await admin.auth.admin.listUsers({ perPage: 1000 })).users
for (const person of people) {
  if (!existing.some((user) => user.email === person.email)) requireData(await admin.auth.admin.createUser({ email: person.email, password, email_confirm: true }))
  const api = client()
  requireData(await api.auth.signInWithPassword({ email: person.email, password }))
  const profileId = requireData(await api.rpc('create_account', { account_name: person.name, account_role: person.role }))
  const entity = requireData(await api.from(person.role === 'patient' ? 'patients' : 'professionals').select('*').eq('profile_id', profileId).single())
  accounts.push({ ...person, id: entity.id, api })
  if (person.role === 'professional' && !entity.completed_at) requireData(await api.from('professionals').update({ specialty: 'Medicina general', institution: 'Consultorio de demostración', license_number: 'DEMO-SIN-VALIDEZ', completed_at: new Date().toISOString() }).eq('id', entity.id))
  if (person.role === 'patient') {
    const history = requireData(await api.from('patient_histories').select('revision').eq('patient_id', entity.id).single())
    if (history.revision === 0) requireData(await api.rpc('save_patient_history', { history_data: { ...sampleHistory, support: 'Datos ficticios para revisar la interfaz.' }, next_step: 3, expected_revision: 0, complete: true }))
    const readings = requireData(await api.from('glucose_readings').select('id').eq('patient_id', entity.id).limit(1))
    if (!readings.length) {
      const now = Date.now()
      const demoReadings = [
        { glucose_value: 118, measurement_context: 'fasting_morning', measured_at: new Date(now - 9 * 86400000 + 7 * 3600000).toISOString() },
        { glucose_value: 146, measurement_context: 'pre_meal', measured_at: new Date(now - 7 * 86400000 + 13 * 3600000).toISOString() },
        { glucose_value: 171, measurement_context: 'post_meal_2h', measured_at: new Date(now - 6 * 86400000 + 15 * 3600000).toISOString(), has_eaten: true, meal_type: 'lunch' },
        { glucose_value: 105, measurement_context: 'fasting_morning', measured_at: new Date(now - 4 * 86400000 + 7 * 3600000).toISOString() },
        { glucose_value: 132, measurement_context: 'pre_meal', measured_at: new Date(now - 2 * 86400000 + 14 * 3600000).toISOString() },
        { glucose_value: 124, measurement_context: 'fasting_morning', measured_at: new Date(now - 86400000 + 8 * 3600000).toISOString() },
      ].map((reading) => ({ ...reading, patient_id: entity.id, unit: 'mg/dL', source_channel: 'web', measurement_source: 'capillary' }))
      requireData(await api.from('glucose_readings').insert(demoReadings))
    }
  }
}
const [patient, professional] = accounts
const links = requireData(await patient.api.from('professional_patients').select('professional_id').eq('professional_id', professional.id))
if (!links.length) {
  const invitation = requireData(await professional.api.from('patient_invitations').insert({ professional_id: professional.id }).select().single())
  requireData(await patient.api.rpc('accept_patient_invitation', { invitation_code: invitation.code }))
}
console.log('Cuentas ficticias locales listas: paciente@trackyglu.test / profesional@trackyglu.test. Contraseña: TrackyGlu2026!')
