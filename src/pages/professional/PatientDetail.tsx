import { useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import { CheckCircle2, FileText, ShieldCheck } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'
import { useAuth } from '../../components/auth/useAuth'
import PageShell from '../../components/layout/PageShell'
import HistorySummary from '../../components/profile/HistorySummary'
import { endAssignment, getHistory, getHistoryReviews, getPatientName, profileError, reviewHistory } from '../../services/profileService'
import type { HistoryReview, PatientHistory } from '../../types/clinicalHistory'

export default function PatientDetail() {
  const { patientId } = useParams()
  const { profile } = useAuth()
  const navigate = useNavigate()
  const [record, setRecord] = useState<PatientHistory | null>(null)
  const [name, setName] = useState('')
  const [reviews, setReviews] = useState<HistoryReview[]>([])
  const [note, setNote] = useState('')
  const [loading, setLoading] = useState(true)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')
  const [reload, setReload] = useState(0)
  useEffect(() => {
    let active = true
    if (!patientId) return
    Promise.all([getHistory(patientId), getPatientName(patientId), getHistoryReviews(patientId)]).then(([history, patientName, notes]) => { if (active) { setRecord(history); setName(patientName); setReviews(notes); setLoading(false); setError('') } }).catch(() => { if (active) { setRecord(null); setError('No pudimos abrir esta historia. Verifica tu conexión y que el paciente siga vinculado contigo.'); setLoading(false) } })
    return () => { active = false }
  }, [patientId, reload])
  async function submit(event: FormEvent) {
    event.preventDefault(); if (!record) return
    setBusy(true); setError('')
    try { await reviewHistory(patientId!, record.revision, note); setReviews(await getHistoryReviews(patientId!)); setNote(''); setNotice('Revisión registrada con fecha y versión de la historia.') }
    catch (cause) { setError(profileError(cause, 'No se pudo guardar la revisión. Verifica que el paciente siga vinculado contigo.')) }
    finally { setBusy(false) }
  }
  async function unlink() {
    if (!window.confirm(`¿Finalizar el vínculo con ${name}? Dejarás de tener acceso a su información.`)) return
    setBusy(true)
    try { await endAssignment(patientId!, profile!.entityId!); navigate('/professional') }
    catch { setError('No pudimos finalizar el vínculo.'); setBusy(false) }
  }
  const latestReview = record && reviews.find((review) => review.history_revision === record.revision)
  return <PageShell professional back="/professional">{loading ? <p role="status">Cargando historia…</p> : <>
    {error && <div className="feedback error" role="alert">{error} <button className="inline-button" onClick={() => setReload((value) => value + 1)}>Recargar historia</button></div>}
    {record && <><div className="professional-intro"><div><p className="eyebrow">HISTORIA INICIAL DEL PACIENTE</p><h1>{name}</h1><p className="lead">Información declarada por el paciente · Versión {record.revision}</p></div><span className={`status-badge ${latestReview ? 'ready' : ''}`}>{latestReview ? 'Revisión registrada' : record.completed_at ? 'Pendiente de revisión' : 'En progreso'}</span></div>
    {notice && <p className="feedback success" role="status">{notice}</p>}
    <div className="profile-columns"><section className="surface"><div className="card-heading"><FileText size={22} /><h2>Historia del paciente</h2></div><HistorySummary data={record.data} /></section><aside className="form-stack">
      <section className="surface"><div className="card-heading"><ShieldCheck size={22} /><h2>Revisión profesional</h2></div><p className="muted">Documenta lo que revisaste y los datos por confirmar. La valoración clínica en consulta completa esta información inicial.</p>
      {record.completed_at ? <form className="form-stack" onSubmit={submit}><div className="profile-field"><label htmlFor="review-note">Nota de revisión</label><textarea id="review-note" required rows={5} maxLength={4000} value={note} onChange={(e) => setNote(e.target.value)} placeholder="Datos revisados con el paciente, aclaraciones y pendientes…" /></div><button className="primary-button" disabled={busy || !note.trim()}><CheckCircle2 size={18} />{busy ? 'Guardando…' : 'Registrar revisión'}</button></form> : <p className="feedback">El paciente aún está completando sus respuestas. Podrás registrar la revisión cuando termine.</p>}
      </section>{reviews.length > 0 && <section className="surface"><h3>Revisiones anteriores</h3>{reviews.map((review) => <article className="review-note" key={review.id}><strong>Versión {review.history_revision} · {review.professional_id === profile?.entityId ? 'Tu revisión' : 'Revisión de otro profesional'}</strong><time>{new Date(review.reviewed_at).toLocaleString('es-MX')}</time><p>{review.note}</p></article>)}</section>}
      <button className="text-button danger-text" disabled={busy} onClick={() => void unlink()}>Finalizar vínculo con el paciente</button>
    </aside></div></>}
  </>}</PageShell>
}
