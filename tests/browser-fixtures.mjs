// Run outside Playwright's TypeScript loader, using the same local-only guard as API tests.
import { localSupabase, requireData } from '../scripts/local-supabase.mjs'
const { admin, client } = localSupabase()
const [operation, input] = process.argv.slice(2)
const payload = JSON.parse(input)
if (operation === 'create') {
  requireData(await admin.auth.admin.createUser({ email: payload.email, password: 'Anterior2026!', email_confirm: true }))
} else if (operation === 'verify-recovery') {
  requireData(await client().auth.signInWithPassword({ email: payload.email, password: 'Renovada2026!' }))
  if (!(await client().auth.signInWithPassword({ email: payload.email, password: 'Anterior2026!' })).error) throw new Error('La contraseña anterior sigue funcionando')
} else if (operation === 'cleanup') {
  const users = requireData(await admin.auth.admin.listUsers({ perPage: 1000 })).users.filter((user) => payload.emails.includes(user.email))
  for (const user of users) {
    const profile = requireData(await admin.from('profiles').select('id').eq('user_id', user.id).maybeSingle())
    if (profile) {
      const patient = requireData(await admin.from('patients').select('id').eq('profile_id', profile.id).maybeSingle())
      const professional = requireData(await admin.from('professionals').select('id').eq('profile_id', profile.id).maybeSingle())
      if (patient) {
        requireData(await admin.from('patient_invitations').delete().eq('accepted_by', patient.id))
        requireData(await admin.from('patient_history_reviews').delete().eq('patient_id', patient.id))
        requireData(await admin.from('patient_history_versions').delete().eq('patient_id', patient.id))
      }
      if (professional) requireData(await admin.from('patient_history_reviews').delete().eq('professional_id', professional.id))
    }
    requireData(await admin.auth.admin.deleteUser(user.id))
  }
} else throw new Error('Operación de prueba desconocida')
