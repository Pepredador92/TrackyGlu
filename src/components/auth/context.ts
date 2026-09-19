import type { Session } from '@supabase/supabase-js'
import { createContext } from 'react'
import type { Profile } from '../../types/profile'

export interface AuthContextValue {
  session: Session | null
  profile: Profile | null
  isLoading: boolean
  authError: boolean
  signOut: () => Promise<void>
}

export const AuthContext = createContext<AuthContextValue | undefined>(undefined)
