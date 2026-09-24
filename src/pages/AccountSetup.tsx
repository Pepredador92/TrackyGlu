import { useState } from 'react'
import type { FormEvent } from 'react'
import { HeartPulse, Stethoscope, ArrowRight } from 'lucide-react'
import { useAuth } from '../components/auth/useAuth'
import { createAccount } from '../services/auth/profileService'
import PageShell from '../components/layout/PageShell'
import { Field } from '../components/profile/Fields'

export default function AccountSetup() {
  const { session, refreshProfile } = useAuth()
  const [name, setName] = useState(String(session?.user.user_metadata.display_name ?? ''))
  const [role, setRole] = useState<'patient' | 'professional'>(session?.user.user_metadata.account_kind === 'professional' ? 'professional' : 'patient')
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  async function submit(event: FormEvent) {
    event.preventDefault(); setBusy(true); setError('')
    try { await createAccount(role, name); await refreshProfile() }
    catch { setError('No pudimos configurar tu cuenta. Intenta nuevamente.') }
    finally { setBusy(false) }
  }
  return <PageShell><div className="narrow-content"><p className="eyebrow">BIENVENIDO A TRACKYGLU</p><h1>Hagamos este espacio tuyo.</h1><p className="lead">Cuéntanos cómo usarás TrackyGlu para preparar tu perfil.</p><form className="surface form-stack" onSubmit={submit}>
    <Field id="account-name" label="Nombre completo" autoComplete="name" value={name} onChange={(e) => setName(e.target.value)} minLength={2} maxLength={120} required />
    <fieldset className="choice-field"><legend>Usaré TrackyGlu como</legend><div className="role-options">
      <label className={`role-option ${role === 'patient' ? 'selected' : ''}`}><input type="radio" name="account-role" checked={role === 'patient'} onChange={() => setRole('patient')} /><HeartPulse /><strong>Paciente</strong><span>Registrar y compartir mi seguimiento.</span></label>
      <label className={`role-option ${role === 'professional' ? 'selected' : ''}`}><input type="radio" name="account-role" checked={role === 'professional'} onChange={() => setRole('professional')} /><Stethoscope /><strong>Profesional</strong><span>Acompañar a mis pacientes.</span></label>
    </div></fieldset>
    {error && <p className="feedback error" role="alert">{error}</p>}<button className="primary-button" disabled={busy}>{busy ? 'Preparando tu espacio…' : 'Continuar'}<ArrowRight size={18} /></button>
  </form></div></PageShell>
}
