import { LogOut } from 'lucide-react'
import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from './useAuth'
import './AuthState.css'

export function ProtectedRoute() {
  const { session, profile, isLoading, authError, signOut } = useAuth()
  const location = useLocation()

  if (isLoading) {
    return <AuthStateMessage message="Cargando..." />
  }

  if (!session) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />
  }

  if (!profile || authError) {
    return <AccountNotConfigured onSignOut={signOut} />
  }

  return <Outlet />
}

export function PatientRoute() {
  const { profile, signOut } = useAuth()

  if (profile?.role === 'professional') {
    return <Navigate to="/professional" replace />
  }

  if (profile?.role !== 'patient') {
    return <AccountNotConfigured onSignOut={signOut} />
  }

  return <Outlet />
}

export function ProfessionalRoute() {
  const { profile, signOut } = useAuth()

  if (profile?.role === 'patient') {
    return <Navigate to="/" replace />
  }

  if (profile?.role !== 'professional') {
    return <AccountNotConfigured onSignOut={signOut} />
  }

  return <Outlet />
}

export function AuthStateMessage({ message }: { message: string }) {
  return (
    <main className="auth-state">
      <div className="auth-state__content">
        <span className="auth-state__brand">TrackyGlu</span>
        <p role="status">{message}</p>
      </div>
    </main>
  )
}

export function AccountNotConfigured({ onSignOut }: { onSignOut: () => Promise<void> }) {
  return (
    <main className="auth-state">
      <div className="auth-state__content">
        <span className="auth-state__brand">TrackyGlu</span>
        <h1>Tu cuenta todavía no está configurada en TrackyGlu.</h1>
        <button className="auth-state__button" type="button" onClick={() => void onSignOut()}>
          <LogOut size={18} strokeWidth={2} aria-hidden="true" />
          <span>Cerrar sesión</span>
        </button>
      </div>
    </main>
  )
}
