import { supabase } from '../supabase/supabaseClient'
import type { Profile, UserRole } from '../../types/profile'

interface ProfileRow {
  id: string
  user_id: string
  role: UserRole
  display_name: string | null
}

export async function getCurrentProfile(userId: string): Promise<Profile | null> {
  const { data, error } = await supabase
    .from('profiles')
    .select('id, user_id, role, display_name')
    .eq('user_id', userId)
    .maybeSingle<ProfileRow>()

  if (error) {
    throw error
  }

  if (!data) {
    return null
  }

  let entityId: string | null = null
  let onboardingCompletedAt: string | null = null
  if (data.role === 'patient' || data.role === 'professional') {
    const { data: entity, error: entityError } = await supabase
      .from(data.role === 'patient' ? 'patients' : 'professionals')
      .select(data.role === 'patient' ? 'id' : 'id, completed_at')
      .eq('profile_id', data.id).maybeSingle()
    if (entityError) throw entityError
    const row = entity as unknown as { id: string; completed_at?: string } | null
    entityId = row?.id ?? null
    if (data.role === 'patient' && entityId) {
      const { data: history, error: historyError } = await supabase.from('patient_histories').select('completed_at').eq('patient_id', entityId).maybeSingle()
      if (historyError) throw historyError
      onboardingCompletedAt = history?.completed_at ?? null
    } else {
      onboardingCompletedAt = row?.completed_at ?? null
    }
  }

  return {
    id: data.id,
    userId: data.user_id,
    role: data.role,
    displayName: data.display_name,
    entityId,
    onboardingCompletedAt,
  }
}

export async function createAccount(role: 'patient' | 'professional', displayName: string) {
  const { error } = await supabase.rpc('create_account', { account_role: role, account_name: displayName.trim() })
  if (error) throw error
}
