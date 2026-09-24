import type { ReactNode } from 'react'
import { ArrowLeft, HeartPulse, LogOut, UserRound } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useAuth } from '../auth/useAuth'
import { useState } from 'react'
import '../../styles/profiles.css'

export function Brand() {
  return <span className="brand"><span className="brand-icon"><HeartPulse size={24} aria-hidden="true" /></span>Tracky<span>Glu</span></span>
}

export default function PageShell({ children, back, professional = false }: { children: ReactNode; back?: string; professional?: boolean }) {
  const { signOut } = useAuth()
  const [error, setError] = useState('')
  return <div className="app-shell">
    <header className="app-header"><Link to={professional ? '/professional' : '/'} aria-label="TrackyGlu, inicio"><Brand /></Link>
      <span className="workspace-label">{professional ? 'Espacio profesional' : 'Tu espacio de salud'}</span>
      <div className="header-actions"><Link className="icon-link" to={professional ? '/professional/profile' : '/mi-perfil'} aria-label="Mi perfil"><UserRound size={20} /></Link>
        <button className="text-button" onClick={() => { void signOut().catch(() => setError('No se pudo cerrar la sesión. Intenta de nuevo.')) }}><LogOut size={17} /> <span>Salir</span></button></div>
    </header>
    <main className="profile-main">{back && <Link className="quiet-link back-navigation" to={back}><ArrowLeft size={17} /> Volver</Link>}{error && <p className="feedback error" role="alert">{error}</p>}{children}</main>
    <footer className="app-footer"><span>TrackyGlu · Acompañando tu seguimiento</span><Link to="/fundamento-clinico">Fundamento clínico</Link></footer>
  </div>
}
