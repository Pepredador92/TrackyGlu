import { execFileSync } from 'node:child_process'
import { createClient } from '@supabase/supabase-js'

export function localSupabase() {
  const status = JSON.parse(execFileSync('npx', ['supabase', 'status', '-o', 'json'], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }))
  if (!/^http:\/\/(127\.0\.0\.1|localhost):55321$/.test(status.API_URL)) throw new Error('Este script solo admite el entorno local de TrackyGlu en el puerto 55321.')
  const options = { auth: { persistSession: false, autoRefreshToken: false } }
  return {
    url: status.API_URL,
    admin: createClient(status.API_URL, status.SECRET_KEY || status.SERVICE_ROLE_KEY, options),
    client: () => createClient(status.API_URL, status.PUBLISHABLE_KEY || status.ANON_KEY, options),
  }
}

export function requireData(result) {
  if (result.error) throw result.error
  return result.data
}

export const sampleHistory = {
  birthDate: '1980-05-18', sex: 'female', phone: '', address: '', occupation: '', emergencyContact: '',
  diabetesType: 'type_2', diagnosisYear: '2018', conditionsStatus: 'no', conditions: [], otherConditions: '',
  familyHistory: '', severeLowHistory: 'no', treatmentStatus: 'unknown', medications: [],
  allergyStatus: 'no', allergies: '', smoking: '', alcohol: '', activity: '', support: '', notes: '', informationConfirmed: true,
}
