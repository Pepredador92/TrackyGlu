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

  return {
    id: data.id,
    userId: data.user_id,
    role: data.role,
    displayName: data.display_name,
  }
}
