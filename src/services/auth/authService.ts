import type { AuthResponse, Session, User } from '@supabase/supabase-js'
import { supabase } from '../supabase/supabaseClient'

export async function signIn(email: string, password: string): Promise<AuthResponse> {
  const response = await supabase.auth.signInWithPassword({ email, password })

  if (response.error) {
    throw response.error
  }

  return response
}

export async function signOut(): Promise<void> {
  const { error } = await supabase.auth.signOut()

  if (error) {
    throw error
  }
}

export async function getSession(): Promise<Session | null> {
  const { data, error } = await supabase.auth.getSession()

  if (error) {
    throw error
  }

  return data.session
}

export async function getCurrentUser(): Promise<User | null> {
  const { data, error } = await supabase.auth.getUser()

  if (error) {
    if (error.message.toLowerCase().includes('session')) {
      return null
    }
    throw error
  }

  return data.user
}
