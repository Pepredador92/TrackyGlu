import { createClient } from '@supabase/supabase-js'

function getRequiredEnv(name: 'VITE_SUPABASE_URL'): string {
  const value = import.meta.env[name]

  if (!value) {
    throw new Error(`Missing ${name}`)
  }

  return value
}

function getSupabasePublicKey(): string {
  const value =
    import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY ||
    import.meta.env.VITE_SUPABASE_ANON_KEY

  if (!value) {
    throw new Error(
      'Missing Supabase public key. Set VITE_SUPABASE_PUBLISHABLE_KEY or VITE_SUPABASE_ANON_KEY in .env.local',
    )
  }

  return value
}

const supabaseUrl = getRequiredEnv('VITE_SUPABASE_URL')
const supabasePublicKey = getSupabasePublicKey()

export const supabase = createClient(supabaseUrl, supabasePublicKey, {
  global: {
    headers: {
      'ngrok-skip-browser-warning': 'true',
    },
  },
})
