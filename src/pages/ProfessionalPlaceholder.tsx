import { LogOut } from 'lucide-react'
import { useAuth } from '../components/auth/useAuth'
import './ProfessionalPlaceholder.css'

function ProfessionalPlaceholder() {
  const { profile, signOut } = useAuth()

  return (
    <main className="professional-placeholder">
      <section className="professional-placeholder__content" aria-labelledby="professional-title">
        <span className="professional-placeholder__brand">TrackyGlu</span>
        <p className="professional-placeholder__eyebrow">Acceso profesional</p>
        <h1 id="professional-title">Panel profesional</h1>
        <p className="professional-placeholder__session">Sesión iniciada como:</p>
        <p className="professional-placeholder__name">{profile?.displayName ?? 'Profesional de prueba'}</p>
        <button className="professional-placeholder__logout" type="button" onClick={() => void signOut()}>
          <LogOut size={18} strokeWidth={2} aria-hidden="true" />
          <span>Cerrar sesión</span>
        </button>
      </section>
    </main>
  )
}

export default ProfessionalPlaceholder
