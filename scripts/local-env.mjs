import { execFileSync } from 'node:child_process'
import { existsSync, writeFileSync } from 'node:fs'

if (existsSync('.env.local')) {
  console.log('.env.local ya existe; se conserva su configuración.')
} else {
  const status = JSON.parse(execFileSync('npx', ['supabase', 'status', '-o', 'json'], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }))
  writeFileSync('.env.local', `VITE_SUPABASE_URL=${status.API_URL}\nVITE_SUPABASE_PUBLISHABLE_KEY=${status.PUBLISHABLE_KEY || status.ANON_KEY}\n`, { mode: 0o600 })
  console.log('.env.local configurado para Supabase local. Las claves existentes se conservan.')
}
