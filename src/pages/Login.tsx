import { LogIn } from 'lucide-react'
import { useState } from 'react'
import type { FormEvent } from 'react'
import { Navigate, useLocation, useNavigate } from 'react-router-dom'
import { AccountNotConfigured } from '../components/auth/ProtectedRoute'
import { useAuth } from '../components/auth/useAuth'
import { signIn } from '../services/auth/authService'
import './Login.css'

function Login() {
  const navigate = useNavigate()
  const location = useLocation()
  const { session, profile, isLoading, authError, signOut } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [hasError, setHasError] = useState(false)

  if (isLoading) {
    return <main className="login-page"><p role="status">Cargando...</p></main>
  }

  if (session && profile?.role === 'patient') {
    return <Navigate to="/" replace />
  }

  if (session && profile?.role === 'professional') {
    return <Navigate to="/professional" replace />
  }

  if (session && (authError || !profile)) {
    return <AccountNotConfigured onSignOut={signOut} />
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setHasError(false)
    setIsSubmitting(true)

    try {
      await signIn(email.trim(), password)
      const destination = (location.state as { from?: string } | null)?.from ?? '/'
      navigate(destination, { replace: true })
    } catch {
      setHasError(true)
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <main className="login-page">
      <section className="login-panel" aria-labelledby="login-title">
        <span className="login-panel__brand">TrackyGlu</span>
        <div className="login-panel__intro">
          <p className="login-panel__eyebrow">Acceso seguro</p>
          <h1 id="login-title">Iniciar sesión</h1>
        </div>

        <form className="login-form" onSubmit={handleSubmit} noValidate>
          <div className="login-field">
            <label htmlFor="login-email">Correo electrónico</label>
            <input
              id="login-email"
              name="email"
              type="email"
              autoComplete="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              required
            />
          </div>
          <div className="login-field">
            <label htmlFor="login-password">Contraseña</label>
            <input
              id="login-password"
              name="password"
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              required
            />
          </div>
          {hasError && <p className="login-error" role="alert">No fue posible iniciar sesión. Verifica tus datos e intenta nuevamente.</p>}
          <button className="login-button" type="submit" disabled={isSubmitting || !email || !password}>
            <LogIn size={18} strokeWidth={2} aria-hidden="true" />
            <span>{isSubmitting ? 'Iniciando sesión...' : 'Iniciar sesión'}</span>
          </button>
        </form>
      </section>
    </main>
  )
}

export default Login
