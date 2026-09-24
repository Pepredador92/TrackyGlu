import { useState } from 'react'
import type { FormEvent } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { supabase } from '../services/supabase/supabaseClient'
import { useAuth } from '../components/auth/useAuth'
import { Brand } from '../components/layout/PageShell'
import { Field } from '../components/profile/Fields'

export default function PasswordRecovery() {
  const { session, isLoading } = useAuth()
  const [params] = useSearchParams()
  const resetting = params.get('modo') === 'nueva'
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [repeat, setRepeat] = useState('')
  const [busy, setBusy] = useState(false)
  const [done, setDone] = useState(false)
  const [error, setError] = useState('')
  async function submit(event: FormEvent) {
    event.preventDefault(); setError('')
    if (resetting && password !== repeat) { setError('Las contraseñas deben coincidir.'); return }
    setBusy(true)
    try {
      const result = resetting ? await supabase.auth.updateUser({ password }) : await supabase.auth.resetPasswordForEmail(email.trim(), { redirectTo: `${window.location.origin}/recuperar-acceso?modo=nueva` })
      if (result.error) throw result.error
      setDone(true)
    } catch { setError('No pudimos completar la solicitud. Intenta de nuevo o solicita otro enlace.') }
    finally { setBusy(false) }
  }
  return <main className="centered-page"><div className="recovery-panel"><Brand /><h1>{resetting ? 'Elige una nueva contraseña' : 'Recupera tu acceso'}</h1>
    {done ? <div className="feedback success" role="status">{resetting ? 'Tu contraseña se actualizó.' : 'Si existe una cuenta con ese correo, recibirás un enlace para recuperar tu acceso.'}</div> : resetting && !session ? <p role="status">{isLoading ? 'Verificando el enlace…' : 'El enlace no es válido o venció. Solicita uno nuevo.'}</p> : <form className="form-stack" onSubmit={submit}>
      <p className="muted">{resetting ? 'Usa al menos 8 caracteres.' : 'Te enviaremos un enlace a tu correo electrónico.'}</p>
      {resetting ? <><Field id="new-password" label="Nueva contraseña" type="password" autoComplete="new-password" minLength={8} required value={password} onChange={(e) => setPassword(e.target.value)} /><Field id="repeat-password" label="Confirmar contraseña" type="password" autoComplete="new-password" required value={repeat} onChange={(e) => setRepeat(e.target.value)} /></> : <Field id="recovery-email" label="Correo electrónico" type="email" autoComplete="email" required value={email} onChange={(e) => setEmail(e.target.value)} />}
      {error && <p role="alert" className="feedback error">{error}</p>}<button className="primary-button" disabled={busy}>{busy ? 'Un momento…' : resetting ? 'Guardar contraseña' : 'Enviar enlace'}</button>
    </form>}<Link className="quiet-link recovery-back" to={resetting && !session ? '/recuperar-acceso' : '/login'}>{resetting && !session ? 'Solicitar otro enlace' : 'Volver al inicio'}</Link>
  </div></main>
}
