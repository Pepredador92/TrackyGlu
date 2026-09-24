import { ArrowRight, CheckCircle2, Eye, EyeOff, HeartPulse, ShieldCheck, Stethoscope } from 'lucide-react'
import { useState } from 'react'
import type { FormEvent } from 'react'
import { Link, Navigate, useSearchParams } from 'react-router-dom'
import { useAuth } from '../components/auth/useAuth'
import { supabase } from '../services/supabase/supabaseClient'
import { createAccount } from '../services/auth/profileService'
import { Brand } from '../components/layout/PageShell'
import { Field } from '../components/profile/Fields'
import '../styles/profiles.css'

export default function Login() {
  const { session, profile, isLoading, refreshProfile } = useAuth()
  const [params, setParams] = useSearchParams()
  const registering = params.get('modo') === 'registro'
  const [role, setRole] = useState<'patient' | 'professional'>('patient')
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  const [confirmation, setConfirmation] = useState(false)
  if (session && !busy && !isLoading) return <Navigate to={profile?.role === 'professional' ? '/professional' : '/'} replace />
  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); setBusy(true); setError('')
    try {
      if (registering) {
        const { data, error: signupError } = await supabase.auth.signUp({ email: email.trim(), password, options: {
          emailRedirectTo: `${window.location.origin}/`, data: { display_name: name.trim(), account_kind: role },
        } })
        if (signupError) throw signupError
        if (data.session) { await createAccount(role, name); await refreshProfile() }
        else setConfirmation(true)
      } else {
        const { error: loginError } = await supabase.auth.signInWithPassword({ email: email.trim(), password })
        if (loginError) throw loginError
        await refreshProfile()
      }
    } catch { setError(registering ? 'No pudimos crear la cuenta. Verifica tus datos; si ya tienes una cuenta, inicia sesión.' : 'Revisa tu correo y contraseña. Si acabas de registrarte, confirma primero tu correo.') }
    finally { setBusy(false) }
  }
  return <div className="access-page"><aside className="access-story"><Brand /><div className="access-story-content"><span className="story-label">UN PASO A LA VEZ</span><h1>Tu seguimiento,<br />más cerca de ti.</h1><p>Un espacio sencillo para registrar tu glucosa y mantener cerca a tu equipo de salud.</p><div className="story-illustration" aria-hidden="true"><div className="illustration-orbit orbit-one" /><div className="illustration-orbit orbit-two" /><div className="illustration-heart"><HeartPulse size={76} strokeWidth={1.25} /></div><span className="illustration-note"><CheckCircle2 size={20} /> Cada registro cuenta</span></div></div><p className="story-footnote"><ShieldCheck size={18} /> Tú eliges con quién compartes tu historia.</p></aside>
    <main className="access-form-area"><div className="access-mobile-brand"><Brand /></div><div className="access-form-wrap">
      {confirmation ? <div className="confirmation-panel"><CheckCircle2 size={44} /><h1>Revisa tu correo</h1><p>Si el registro es válido, recibirás un enlace para confirmar tu cuenta y continuar con tu perfil.</p><button className="primary-button" onClick={() => { setConfirmation(false); setParams({}); setPassword('') }}>Volver a iniciar sesión</button></div> : <>
      <div className="access-tabs"><button type="button" className={!registering ? 'active' : ''} onClick={() => { setParams({}); setError('') }}>Iniciar sesión</button><button type="button" className={registering ? 'active' : ''} onClick={() => { setParams({ modo: 'registro' }); setError('') }}>Crear cuenta</button></div>
      <p className="eyebrow">{registering ? 'COMIENZA AQUÍ' : 'QUÉ BUENO TENERTE DE VUELTA'}</p><h1>{registering ? 'Tu salud, acompañada.' : 'Bienvenido a tu espacio.'}</h1><p className="lead">{registering ? 'Primero creamos tu cuenta. Después completaremos tu perfil, paso a paso.' : 'Entra para continuar con tu seguimiento.'}</p>
      <form onSubmit={submit} className="form-stack"><fieldset className="form-controls" disabled={busy || isLoading}>
      {registering && <><fieldset className="choice-field"><legend>Quiero registrarme como</legend><div className="role-options compact">
        <label className={`role-option ${role === 'patient' ? 'selected' : ''}`}><input type="radio" name="role" checked={role === 'patient'} onChange={() => setRole('patient')} /><HeartPulse size={21} /><strong>Paciente</strong></label>
        <label className={`role-option ${role === 'professional' ? 'selected' : ''}`}><input type="radio" name="role" checked={role === 'professional'} onChange={() => setRole('professional')} /><Stethoscope size={21} /><strong>Profesional</strong></label>
      </div></fieldset><Field id="full-name" label="Nombre completo" value={name} onChange={(e) => setName(e.target.value)} autoComplete="name" minLength={2} maxLength={120} required /></>}
      <Field id="email" label="Correo electrónico" type="email" value={email} onChange={(e) => setEmail(e.target.value)} autoComplete="email" placeholder="nombre@correo.com" required />
      <div className="password-wrap"><Field id="password" label="Contraseña" type={showPassword ? 'text' : 'password'} value={password} onChange={(e) => setPassword(e.target.value)} autoComplete={registering ? 'new-password' : 'current-password'} minLength={registering ? 8 : undefined} hint={registering ? 'Usa al menos 8 caracteres.' : undefined} required /><button type="button" className="password-toggle" aria-label={showPassword ? 'Ocultar contraseña' : 'Mostrar contraseña'} onClick={() => setShowPassword(!showPassword)}>{showPassword ? <EyeOff size={18} /> : <Eye size={18} />}</button></div>
      {!registering && <Link className="quiet-link forgot-link" to="/recuperar-acceso">Olvidé mi contraseña</Link>}{error && <p className="feedback error" role="alert">{error}</p>}
      <button className="primary-button full-width" type="submit">{busy || isLoading ? 'Un momento…' : registering ? 'Crear mi cuenta' : 'Entrar'}<ArrowRight size={18} /></button>
      </fieldset></form><p className="access-note">{registering ? 'Tu información se guardará en tu cuenta. Compartirla con un profesional requiere que aceptes su invitación.' : '¿Primera vez aquí?'} {!registering && <button className="inline-button" onClick={() => setParams({ modo: 'registro' })}>Crea tu cuenta</button>}</p></>}
      <Link className="legal-link" to="/fundamento-clinico">Conoce cómo construimos tu historia clínica</Link>
    </div></main></div>
}
