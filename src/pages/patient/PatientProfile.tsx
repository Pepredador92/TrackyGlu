import { useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import { ArrowRight, CheckCircle2, ClipboardList, Link2, ShieldCheck, Stethoscope } from 'lucide-react'
import { Link, useSearchParams } from 'react-router-dom'
import { useAuth } from '../../components/auth/useAuth'
import PageShell from '../../components/layout/PageShell'
import HistorySummary from '../../components/profile/HistorySummary'
import { Field } from '../../components/profile/Fields'
import { acceptInvitation, endAssignment, getHistory, getLinkedProfessionals, previewInvitation } from '../../services/profileService'
import type { LinkedPerson } from '../../services/profileService'
import type { PatientHistory } from '../../types/clinicalHistory'

export default function PatientProfile() {
  const { profile } = useAuth()
  const [params] = useSearchParams()
  const [history, setHistory] = useState<PatientHistory | null>(null)
  const [professionals, setProfessionals] = useState<LinkedPerson[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')
  const [code, setCode] = useState('')
  const [inviting, setInviting] = useState<LinkedPerson | null>(null)
  const [consent, setConsent] = useState(false)
  const [busy, setBusy] = useState(false)
  const [reload, setReload] = useState(0)
  useEffect(() => {
    let active = true
    if (!profile?.entityId) return
    Promise.all([getHistory(profile.entityId), getLinkedProfessionals(profile.entityId)]).then(([record, people]) => {
      if (active) { setHistory(record); setProfessionals(people); setLoading(false); setError('') }
    }).catch(() => { if (active) { setError('No pudimos cargar tu perfil. Intenta de nuevo.'); setLoading(false) } })
    return () => { active = false }
  }, [profile?.entityId, reload])
  async function preview(event: FormEvent) {
    event.preventDefault(); setError(''); setNotice(''); setBusy(true)
    try { setInviting(await previewInvitation(code)); setConsent(false) }
    catch { setError('La invitación no está disponible. Revisa el código o pide uno nuevo a tu profesional.') }
    finally { setBusy(false) }
  }
  async function accept() {
    if (!consent) return
    setBusy(true); setError('')
    try { await acceptInvitation(code); setProfessionals(await getLinkedProfessionals(profile!.entityId!)); setInviting(null); setCode(''); setNotice('Ya estás vinculado con tu profesional.') }
    catch { setError('No se pudo aceptar la invitación. Puede haber vencido o ya estar utilizada.') }
    finally { setBusy(false) }
  }
  async function unlink(person: LinkedPerson) {
    if (!window.confirm(`¿Dejar de compartir tu historia con ${person.name}? Podrás vincularte nuevamente con una nueva invitación.`)) return
    setBusy(true); setError('')
    try { await endAssignment(profile!.entityId!, person.id); setProfessionals((people) => people.filter((item) => item.id !== person.id)); setNotice('Dejaste de compartir tu historia con este profesional.') }
    catch { setError('No pudimos actualizar el vínculo. Intenta nuevamente.') }
    finally { setBusy(false) }
  }
  return <PageShell back={profile?.onboardingCompletedAt ? '/' : undefined}><div className="page-intro"><p className="eyebrow">MI PERFIL</p><h1>Hola, {profile?.displayName?.split(' ')[0]}.</h1><p className="lead">Tu historia y las personas que te acompañan, en un mismo lugar.</p></div>
    {params.get('completado') && <div className="feedback success" role="status"><CheckCircle2 size={21} /> Tu historia inicial está lista. Ya puedes comenzar a registrar tus lecturas. <Link to="/">Ir a mi inicio</Link></div>}
    {notice && <p className="feedback success" role="status">{notice}</p>}{error && <div className="feedback error" role="alert">{error} {!history && <button className="inline-button" onClick={() => setReload((value) => value + 1)}>Reintentar</button>}</div>}
    {loading ? <p role="status">Cargando tu perfil…</p> : history && <div className="profile-columns"><div><section className="surface"><div className="card-heading"><span className="tile-icon"><ClipboardList /></span><div><h2>Mi historia clínica</h2><p className="muted">{history.completed_at ? 'Información declarada por ti' : 'Continúa cuando estés listo'}</p></div><span className={`status-badge ${history.completed_at ? 'ready' : ''}`}>{history.completed_at ? 'Completada' : 'En progreso'}</span></div>
      <p>{history.completed_at ? 'Puedes consultar y actualizar tus respuestas. Tu profesional podrá revisarlas contigo.' : `Guardamos tu avance en el paso ${history.current_step + 1} de 4. Completa tu historia para iniciar el seguimiento.`}</p>
      <Link className="primary-button" to="/mi-historia">{history.completed_at ? 'Actualizar mi historia' : 'Continuar mi historia'}<ArrowRight size={18} /></Link>
      {history.revision > 0 && <details className="review-details"><summary>Ver mis respuestas guardadas</summary><HistorySummary data={history.data} /></details>}
    </section></div><div className="form-stack"><section className="surface"><div className="card-heading"><span className="tile-icon"><Stethoscope /></span><div><h2>Mi equipo de salud</h2><p className="muted">Personas con quienes compartes tu seguimiento</p></div></div>
      {professionals.length ? professionals.map((person) => <article className="person-card" key={person.id}><strong>{person.name}</strong><span>{person.specialty} · {person.institution}</span><button className="text-button danger-text" disabled={busy} onClick={() => void unlink(person)}>Dejar de compartir</button></article>) : <p className="muted">Aún no tienes un profesional vinculado. Puedes agregarlo con su código de invitación.</p>}
    </section><section className="surface invite-surface"><div className="card-heading"><Link2 size={23} /><h2>Vincular a mi profesional</h2></div>
      {inviting ? <div className="form-stack"><div className="person-card"><strong>{inviting.name}</strong><span>{inviting.specialty} · {inviting.institution}</span></div><label className="check-row"><input type="checkbox" checked={consent} onChange={(e) => setConsent(e.target.checked)} /><span>Reconozco a este profesional y acepto compartir mi historia, lecturas y seguimiento con él.</span></label><div className="button-row"><button className="primary-button" disabled={busy || !consent} onClick={() => void accept()}>{busy ? 'Vinculando…' : 'Aceptar invitación'}</button><button className="text-button" disabled={busy} onClick={() => setInviting(null)}>Cancelar</button></div></div> : <form className="form-stack" onSubmit={preview}><Field id="invitation-code" label="Código de invitación" value={code} onChange={(e) => setCode(e.target.value)} placeholder="Pega aquí el código de tu profesional" maxLength={64} required /><button className="secondary-button" disabled={busy}>{busy ? 'Buscando…' : 'Revisar invitación'}<ArrowRight size={17} /></button></form>}
      <p className="form-footnote"><ShieldCheck size={15} /> Siempre podrás dejar de compartir desde tu perfil.</p>
    </section></div></div>}
  </PageShell>
}
