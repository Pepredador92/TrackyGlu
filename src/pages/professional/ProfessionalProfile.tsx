import { useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import { CheckCircle2, Stethoscope } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../../components/auth/useAuth'
import PageShell from '../../components/layout/PageShell'
import { Field, SelectField } from '../../components/profile/Fields'
import { getProfessional, saveProfessional } from '../../services/profileService'

export default function ProfessionalProfile() {
  const { profile, refreshProfile } = useAuth()
  const navigate = useNavigate()
  const [name, setName] = useState(profile?.displayName ?? '')
  const [values, setValues] = useState({ specialty: '', license_number: '', institution: '', phone: '' })
  const [loading, setLoading] = useState(true)
  const [loaded, setLoaded] = useState(false)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  const [reload, setReload] = useState(0)
  useEffect(() => {
    let active = true
    if (!profile?.entityId) return
    getProfessional(profile.entityId).then((record) => { if (active) { setValues({ specialty: record.specialty, license_number: record.license_number, institution: record.institution, phone: record.phone }); setLoaded(true); setLoading(false); setError('') } }).catch(() => { if (active) { setError('No pudimos cargar tu perfil. Intenta nuevamente.'); setLoading(false) } })
    return () => { active = false }
  }, [profile?.entityId, reload])
  async function submit(event: FormEvent) {
    event.preventDefault(); setBusy(true); setError('')
    try { await saveProfessional(profile!.entityId!, profile!.id, name, Object.fromEntries(Object.entries(values).map(([key, value]) => [key, value.trim()])) as typeof values); await refreshProfile(); navigate('/professional', { replace: true }) }
    catch { setError('No se pudo guardar tu perfil. Revisa tus datos e intenta de nuevo.') }
    finally { setBusy(false) }
  }
  return <PageShell professional back={profile?.onboardingCompletedAt ? '/professional' : undefined}><div className="narrow-content"><p className="eyebrow">PERFIL PROFESIONAL</p><h1>Un espacio para acompañar.</h1><p className="lead">Completa tus datos para que tus pacientes puedan reconocerte al recibir una invitación.</p>
    {loading ? <p role="status">Cargando tu perfil…</p> : !loaded ? <div className="feedback error" role="alert">{error} <button type="button" className="inline-button" onClick={() => { setLoading(true); setReload((value) => value + 1) }}>Reintentar</button></div> : <form className="surface form-stack" onSubmit={submit}><div className="card-heading"><span className="tile-icon"><Stethoscope /></span><div><h2>Tus datos profesionales</h2><p className="muted">Podrás actualizarlos más adelante.</p></div></div><fieldset className="form-controls" disabled={busy}>
      <Field id="professional-name" label="Nombre completo" autoComplete="name" minLength={2} maxLength={120} required value={name} onChange={(e) => setName(e.target.value)} />
      <SelectField id="specialty" label="Profesión o especialidad" value={values.specialty} onChange={(e) => setValues({ ...values, specialty: e.target.value })} required><option value="">Selecciona</option>{['Medicina general', 'Medicina familiar', 'Endocrinología', 'Medicina interna', 'Enfermería', 'Nutrición', 'Otra especialidad'].map((value) => <option key={value}>{value}</option>)}</SelectField>
      <Field id="license" label="Cédula profesional" required maxLength={40} value={values.license_number} onChange={(e) => setValues({ ...values, license_number: e.target.value })} hint="Registra la cédula correspondiente a tu profesión. El dato queda declarado por ti." />
      <Field id="institution" label="Institución o consultorio" autoComplete="organization" required maxLength={180} value={values.institution} onChange={(e) => setValues({ ...values, institution: e.target.value })} />
      <Field id="professional-phone" label="Teléfono de contacto profesional" type="tel" autoComplete="tel" maxLength={30} value={values.phone} onChange={(e) => setValues({ ...values, phone: e.target.value })} />
      {error && <div className="feedback error" role="alert">{error} <button className="inline-button" type="button" onClick={() => setReload((value) => value + 1)}>Reintentar carga</button></div>}
      <button className="primary-button" disabled={busy}>{busy ? 'Guardando…' : 'Guardar mi perfil'}<CheckCircle2 size={18} /></button></fieldset>
      <p className="form-footnote">Tus pacientes se vincularán contigo al aceptar una invitación.</p>
    </form>}</div></PageShell>
}
