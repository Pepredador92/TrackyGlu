import { getCurrentUser } from '../auth/authService'
import { getCurrentProfile } from '../auth/profileService'
import { supabase } from '../supabase/supabaseClient'

interface PatientRow {
  id: string
}

export async function getCurrentPatientId(): Promise<string> {
  const user = await getCurrentUser()

  if (!user) {
    throw new Error('No authenticated user')
  }

  const profile = await getCurrentProfile(user.id)

  if (!profile) {
    throw new Error('Authenticated user has no profile')
  }

  const { data, error } = await supabase
    .from('patients')
    .select('id')
    .eq('profile_id', profile.id)
    .maybeSingle<PatientRow>()

  if (error) {
    throw error
  }

  if (!data) {
    throw new Error('Authenticated profile has no patient record')
  }

  return data.id
}
