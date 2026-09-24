import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import type { ReactNode } from 'react'
import type { Session } from '@supabase/supabase-js'
import { getSession, signOut as authSignOut } from '../../services/auth/authService'
import { getCurrentProfile } from '../../services/auth/profileService'
import { supabase } from '../../services/supabase/supabaseClient'
import type { Profile } from '../../types/profile'
import { AuthContext } from './context'

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null)
  const [profile, setProfile] = useState<Profile | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [authError, setAuthError] = useState(false)
  const request = useRef(0)
  const currentUser = useRef<string | null>(null)
  const loadProfile = useCallback(async (nextSession: Session | null) => {
    const sequence = ++request.current
    currentUser.current = nextSession?.user.id ?? null
    setSession(nextSession)
    try {
      const nextProfile = nextSession ? await getCurrentProfile(nextSession.user.id) : null
      if (sequence === request.current) { setProfile(nextProfile); setAuthError(false) }
      return nextProfile
    } catch {
      if (sequence === request.current) { setProfile(null); setAuthError(true) }
      return null
    } finally { if (sequence === request.current) setIsLoading(false) }
  }, [])
  useEffect(() => {
    let active = true
    const timers = new Set<ReturnType<typeof setTimeout>>()
    void getSession().then((next) => { if (active) void loadProfile(next) }).catch(() => {
      if (active) { setAuthError(true); setIsLoading(false) }
    })
    const { data } = supabase.auth.onAuthStateChange((event, next) => {
      if (!active || event === 'INITIAL_SESSION') return
      setSession(next)
      if (event === 'TOKEN_REFRESHED' || (event === 'SIGNED_IN' && next?.user.id === currentUser.current)) return
      ++request.current
      setProfile(null); setIsLoading(true)
      // Leave the SDK callback before making requests to avoid its auth lock.
      const timer = setTimeout(() => { timers.delete(timer); if (active) void loadProfile(next) }, 0)
      timers.add(timer)
    })
    // This counter intentionally invalidates any in-flight request, including one started after mount.
    // oxlint-disable-next-line react-hooks/exhaustive-deps
    return () => { active = false; ++request.current; timers.forEach(clearTimeout); data.subscription.unsubscribe() }
  }, [loadProfile])
  const refreshProfile = useCallback(async () => loadProfile(await getSession()), [loadProfile])
  const signOut = useCallback(async () => {
    await authSignOut(); ++request.current; currentUser.current = null
    setSession(null); setProfile(null); setAuthError(false); setIsLoading(false)
  }, [])
  const value = useMemo(() => ({ session, profile, isLoading, authError, signOut, refreshProfile }), [session, profile, isLoading, authError, signOut, refreshProfile])
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
