import { useEffect, useMemo, useState } from 'react'
import type { ReactNode } from 'react'
import { getSession, signOut as authSignOut } from '../../services/auth/authService'
import { getCurrentProfile } from '../../services/auth/profileService'
import { supabase } from '../../services/supabase/supabaseClient'
import { AuthContext } from './context'
import type { Session } from '@supabase/supabase-js'
import type { Profile } from '../../types/profile'

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null)
  const [profile, setProfile] = useState<Profile | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [authError, setAuthError] = useState(false)

  useEffect(() => {
    let isCurrent = true

    async function loadProfileForSession(nextSession: Session | null) {
      if (!nextSession) {
        if (isCurrent) {
          setProfile(null)
          setIsLoading(false)
        }
        return
      }

      try {
        const nextProfile = await getCurrentProfile(nextSession.user.id)
        if (isCurrent) {
          setProfile(nextProfile)
          setAuthError(false)
        }
      } catch {
        if (isCurrent) {
          setProfile(null)
          setAuthError(true)
        }
      } finally {
        if (isCurrent) {
          setIsLoading(false)
        }
      }
    }

    async function initializeAuth() {
      try {
        const currentSession = await getSession()
        if (isCurrent) {
          setSession(currentSession)
        }
        await loadProfileForSession(currentSession)
      } catch {
        if (isCurrent) {
          setSession(null)
          setProfile(null)
          setAuthError(true)
          setIsLoading(false)
        }
      }
    }

    void initializeAuth()

    const { data: authListener } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      if (isCurrent) {
        setSession(nextSession)
        setIsLoading(true)
      }
      void loadProfileForSession(nextSession)
    })

    return () => {
      isCurrent = false
      authListener.subscription.unsubscribe()
    }
  }, [])

  async function signOut() {
    await authSignOut()
    setSession(null)
    setProfile(null)
  }

  const value = useMemo(
    () => ({ session, profile, isLoading, authError, signOut }),
    [session, profile, isLoading, authError],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
