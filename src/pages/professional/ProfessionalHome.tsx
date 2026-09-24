import { useEffect, useState } from 'react'
import { ArrowRight, Bell, ClipboardList, Copy, Link2, Search, UserPlus, UsersRound } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useAuth } from '../../components/auth/useAuth'
import PageShell from '../../components/layout/PageShell'
import { createInvitation, getInvitations, getLinkedPatients } from '../../services/profileService'
import type { LinkedPerson, PatientInvitation } from '../../services/profileService'

export default function ProfessionalHome() {
  const { profile } = useAuth()
  const [patients, setPatients] = useState<LinkedPerson[]>([])
  const [invitations, setInvitations] = useState<PatientInvitation[]>([])
  const [loading, setLoading] = useState(true)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')
  const [search, setSearch] = useState('')
  const [reload, setReload] = useState(0)
  const [now, setNow] = useState(Date.now)
  useEffect(() => { const timer = setInterval(() => setNow(Date.now()), 60000); return () => clearInterval(timer) }, [])
  useEffect(() => {
    let active = true
    if (!profile?.entityId) return
    Promise.all([getLinkedPatients(profile.entityId), getInvitations(profile.entityId)]).then(([people, invites]) => { if (active) { setPatients(people); setInvitations(invites); setLoading(false); setError('') } }).catch(() => { if (active) { setLoading(false); setError('No pudimos cargar tu espacio. Intenta de nuevo.') } })
    return () => { active = false }
  }, [profile?.entityId, reload])
  async function invite() {
    setBusy(true); setError(''); setNotice('')
    try { const invitation = await createInvitation(profile!.entityId!); setInvitations((current) => [invitation, ...current].slice(0, 10)); setNotice('Invitación creada. Comparte el código con tu paciente.') }
    catch { setError('No pudimos crear la invitación. Verifica que tu perfil esté completo.') }
    finally { setBusy(false) }
  }
  async function copy(code: string) {
    try { await navigator.clipboard.writeText(code); setNotice('Código copiado.') }
    catch { setNotice('Selecciona el código para copiarlo manualmente.') }
  }
  const shownPatients = patients.filter((patient) => patient.name.toLocaleLowerCase('es').includes(search.toLocaleLowerCase('es')))
  const availableInvites = invitations.filter((invitation) => !invitation.accepted_at && !invitation.revoked_at && new Date(invitation.expires_at).getTime() > now)
  return <PageShell professional><div className="professional-intro"><div><p className="eyebrow">ESPACIO PROFESIONAL</p><h1>Hola, {profile?.displayName}.</h1><p className="lead">Un lugar para conocer y acompañar a tus pacientes.</p></div><Link className="secondary-button" to="/professional/profile">Editar mi perfil</Link></div>
    <nav className="workspace-nav" aria-label="Herramientas profesionales"><span className="active"><UsersRound size={18} /> Mis pacientes</span><Link to="/professional/alerts"><Bell size={18} /> Alertas</Link><Link to="/professional/tasks"><ClipboardList size={18} /> Tareas clínicas</Link></nav>
    {error && <div className="feedback error" role="alert">{error} <button className="inline-button" onClick={() => setReload((value) => value + 1)}>Reintentar</button></div>}{notice && <p className="feedback success" role="status">{notice}</p>}
    <div className="professional-columns"><section className="surface"><div className="section-title-row"><div><h2>Mis pacientes <span className="count-pill">{patients.length}</span></h2><p className="muted">Personas que comparten su seguimiento contigo.</p></div><button className="icon-link" aria-label="Actualizar pacientes" onClick={() => setReload((value) => value + 1)}>↻</button></div>
      <div className="search-box"><Search size={19} /><input aria-label="Buscar paciente por nombre" placeholder="Buscar por nombre" value={search} onChange={(e) => setSearch(e.target.value)} /></div>
      {loading ? <p role="status">Cargando pacientes…</p> : patients.length === 0 ? <div className="empty-profile-state"><span className="empty-icon"><UsersRound size={40} strokeWidth={1.3} /></span><h3>Tu primer vínculo comienza aquí</h3><p>Crea una invitación y compártela con tu paciente. Aparecerá en esta lista cuando la acepte.</p></div> : shownPatients.length === 0 ? <p>No encontramos pacientes con ese nombre.</p> : <div className="patient-directory">{shownPatients.map((patient) => <Link className="patient-directory-row" key={patient.id} to={`/professional/patients/${patient.id}`}><span className="avatar">{patient.name.charAt(0).toUpperCase()}</span><div><strong>{patient.name}</strong><span>{patient.completedAt ? 'Historia inicial completada' : 'Historia en progreso'}</span></div><ArrowRight size={19} /></Link>)}</div>}
    </section><aside className="form-stack"><section className="surface invitation-panel"><span className="tile-icon"><UserPlus /></span><h2>Añade un paciente</h2><p>Crea un código personal. Tu paciente lo ingresará en «Mi perfil» y confirmará que desea compartir su información contigo.</p><button className="primary-button full-width" disabled={busy} onClick={() => void invite()}><Link2 size={18} />{busy ? 'Creando…' : 'Crear invitación'}</button><p className="form-footnote">Cada código se usa una sola vez y vence en 7 días.</p></section>
      {availableInvites.length > 0 && <section className="surface"><h3>Invitaciones disponibles</h3>{availableInvites.map((invitation) => <div className="invitation-code-row" key={invitation.id}><code>{invitation.code}</code><button className="text-button" onClick={() => void copy(invitation.code)}><Copy size={16} /> Copiar</button><small>Vence el {new Date(invitation.expires_at).toLocaleDateString('es-MX')}</small></div>)}</section>}
    </aside></div>
  </PageShell>
}
