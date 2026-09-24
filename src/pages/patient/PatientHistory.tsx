import { useEffect, useRef, useState } from 'react'
import type { FormEvent } from 'react'
import { ArrowLeft, ArrowRight, Check, CheckCircle2, ClipboardList, Plus, Save, Trash2 } from 'lucide-react'
import { Link, useNavigate, useBeforeUnload, useBlocker } from 'react-router-dom'
import { useAuth } from '../../components/auth/useAuth'
import PageShell from '../../components/layout/PageShell'
import { Choices, Field, SelectField } from '../../components/profile/Fields'
import HistorySummary from '../../components/profile/HistorySummary'
import { getHistory, profileError, saveHistory } from '../../services/profileService'
import { diabetesLabels, emptyHistory, historySteps, knownConditions, localDate, treatmentLabels, validateHistoryStep } from '../../types/clinicalHistory'
import type { ClinicalHistoryData, PatientHistory as HistoryRecord } from '../../types/clinicalHistory'

const yesNoUnknown: Array<[string, string]> = [['yes', 'Sí'], ['no', 'No'], ['unknown', 'No lo sé']]

export default function PatientHistory() {
  const { profile, refreshProfile } = useAuth()
  const navigate = useNavigate()
  const [record, setRecord] = useState<HistoryRecord | null>(null)
  const [data, setData] = useState<ClinicalHistoryData>(emptyHistory)
  const [step, setStep] = useState(0)
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(true)
  const [busy, setBusy] = useState(false)
  const [reload, setReload] = useState(0)
  const titleRef = useRef<HTMLHeadingElement>(null)
  const dirty = record !== null && JSON.stringify(data) !== JSON.stringify(record.data)
  const blocker = useBlocker(dirty && !busy)
  useBeforeUnload((event) => { if (dirty) { event.preventDefault(); event.returnValue = '' } })

  useEffect(() => {
    let active = true
    if (!profile?.entityId) return
    getHistory(profile.entityId).then((history) => {
      if (active) { setRecord(history); setData(history.data); setStep(history.completed_at ? 0 : history.current_step); setLoading(false); setError('') }
    }).catch(() => { if (active) { setError('No pudimos cargar tu historia. Intenta de nuevo.'); setLoading(false) } })
    return () => { active = false }
  }, [profile?.entityId, reload])

  function change<K extends keyof ClinicalHistoryData>(key: K, value: ClinicalHistoryData[K]) {
    setData((current) => ({ ...current, [key]: value, ...(key !== 'informationConfirmed' ? { informationConfirmed: false } : {}) }))
    setErrors((current) => ({ ...current, [key]: '' }))
  }
  function moveTo(next: number) {
    setStep(next); setErrors({})
    requestAnimationFrame(() => { titleRef.current?.focus(); titleRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' }) })
  }
  async function persist(exit = false) {
    if (!record) return
    const complete = step === 3 && !exit
    if (!exit) {
      const validation = complete ? Object.assign({}, ...[0, 1, 2, 3].map((index) => validateHistoryStep(data, index))) : validateHistoryStep(data, step)
      if (Object.keys(validation).length) {
        setErrors(validation)
        if (complete) {
          const invalidStep = [0, 1, 2, 3].find((index) => Object.keys(validateHistoryStep(data, index)).length)
          if (invalidStep !== undefined) setStep(invalidStep)
        }
        requestAnimationFrame(() => document.querySelector<HTMLElement>('[aria-invalid="true"], .field-error')?.focus())
        return
      }
    }
    setBusy(true); setError('')
    try {
      const saved = await saveHistory(data, exit ? step : Math.min(step + 1, 3), record.revision, complete)
      setRecord(saved)
      await refreshProfile()
      if (exit || complete) { navigate(complete ? '/mi-perfil?completado=1' : '/mi-perfil', { replace: true }) }
      else moveTo(step + 1)
    } catch (cause) { setError(profileError(cause, 'No pudimos guardar. Tus respuestas siguen aquí; intenta de nuevo.')) }
    finally { setBusy(false) }
  }
  function submit(event: FormEvent) { event.preventDefault(); void persist() }

  return <PageShell><div className="page-intro"><p className="eyebrow">CONOCERTE NOS AYUDA A ACOMPAÑARTE</p><h1>Tu historia, a tu ritmo.</h1><p className="lead">Cuatro pasos cortos para preparar tu seguimiento. Puedes guardar y continuar después.</p></div>
    {loading ? <p role="status" className="surface">Cargando tu historia…</p> : !record ? <div className="surface"><p role="alert">{error}</p><button className="secondary-button" onClick={() => { setLoading(true); setReload((value) => value + 1) }}>Reintentar</button></div> : <div className="onboarding-layout">
    <aside className="step-sidebar"><ol className="step-list">{historySteps.map((label, index) => <li key={label} className={index === step ? 'current' : index < step ? 'completed' : ''} aria-current={index === step ? 'step' : undefined}><span className="step-number">{index < step ? <Check size={17} /> : index + 1}</span><div><span>PASO {index + 1}</span><strong>{label}</strong></div></li>)}</ol><div className="sidebar-note"><ClipboardList size={22} /><strong>Solo lo que necesitas</strong><p>Las preguntas con * son necesarias. Si no conoces una respuesta, puedes indicarlo.</p><Link to="/fundamento-clinico">¿Por qué preguntamos esto?</Link></div></aside>
    <form className="surface history-form" onSubmit={submit} noValidate><div className="step-caption"><span>Paso {step + 1} de 4</span><span>{record.revision > 0 ? 'Avance guardado' : 'Comencemos'}</span></div><div className="progress-track" role="progressbar" aria-label="Progreso de tu historia" aria-valuemin={0} aria-valuemax={4} aria-valuenow={step}><span style={{ width: `${step / 4 * 100}%` }} /></div>
      <h2 tabIndex={-1} ref={titleRef}>{['Empecemos por conocerte', 'Cuéntanos sobre tu diabetes', 'Tu tratamiento actual', 'Un poco de tu día a día'][step]}</h2>
      <p className="section-description">{['Estos datos ayudarán a tu profesional a identificarte y adaptar el seguimiento.', 'Responde con lo que sabes hoy. Tu profesional podrá revisar la información contigo.', 'Registra lo que ya tienes indicado. Si no recuerdas una dosis, puedes dejarla pendiente.', 'Estas respuestas son opcionales. Nos ayudan a conocer tu contexto y el apoyo que necesitas.'][step]}</p>
      <fieldset disabled={busy} className="form-controls">
      {step === 0 && <>
        <div className="form-grid"><Field id="birthDate" label="Fecha de nacimiento" type="date" value={data.birthDate} onChange={(e) => change('birthDate', e.target.value)} min="1900-01-01" max={localDate()} error={errors.birthDate} required /><SelectField id="sex" label="Sexo registrado" value={data.sex} onChange={(e) => change('sex', e.target.value)} error={errors.sex} required><option value="">Selecciona</option><option value="female">Femenino</option><option value="male">Masculino</option><option value="other">Otra / prefiero no responder</option></SelectField></div>
        <Field id="phone" label="Teléfono de contacto" type="tel" autoComplete="tel" maxLength={30} value={data.phone} onChange={(e) => change('phone', e.target.value)} />
        <Field id="address" label="Domicilio" autoComplete="street-address" maxLength={300} value={data.address} onChange={(e) => change('address', e.target.value)} hint="Opcional por ahora; podrás completarlo con tu profesional." />
        <Field id="occupation" label="¿A qué te dedicas?" maxLength={150} value={data.occupation} onChange={(e) => change('occupation', e.target.value)} />
        <Field id="emergencyContact" label="Persona de apoyo y su teléfono" maxLength={200} value={data.emergencyContact} onChange={(e) => change('emergencyContact', e.target.value)} hint="Si alguien te ayuda con tu seguimiento, puedes agregar su contacto." />
      </>}
      {step === 1 && <>
        <SelectField id="diabetesType" label="¿Qué tipo de diabetes te diagnosticaron?" value={data.diabetesType} onChange={(e) => change('diabetesType', e.target.value)} error={errors.diabetesType} required><option value="">Selecciona</option>{Object.entries(diabetesLabels).map(([value, label]) => <option value={value} key={value}>{label}</option>)}</SelectField>
        <Field id="diagnosisYear" label="¿En qué año te diagnosticaron?" type="number" inputMode="numeric" placeholder="Por ejemplo, 2020" value={data.diagnosisYear} onChange={(e) => change('diagnosisYear', e.target.value)} error={errors.diagnosisYear} hint="Puedes dejarlo vacío si no lo recuerdas." />
        <Choices name="conditionsStatus" label="¿Te han diagnosticado otras condiciones? *" value={data.conditionsStatus} options={yesNoUnknown} onChange={(value) => { change('conditionsStatus', value); if (value !== 'yes') { change('conditions', []); change('otherConditions', '') } }} error={errors.conditionsStatus} />
        {data.conditionsStatus === 'yes' && <fieldset className="choice-field"><legend>Selecciona las que correspondan</legend><div className="checkbox-grid">{knownConditions.map((condition) => <label className="check-row" key={condition}><input type="checkbox" checked={data.conditions.includes(condition)} onChange={(e) => change('conditions', e.target.checked ? [...data.conditions, condition] : data.conditions.filter((item) => item !== condition))} /><span>{condition}</span></label>)}</div>{errors.conditions && <p className="field-error">{errors.conditions}</p>}{data.conditions.includes('Otra') && <Field id="otherConditions" label="¿Cuál otra?" maxLength={500} value={data.otherConditions} onChange={(e) => change('otherConditions', e.target.value)} />}</fieldset>}
        <Field id="familyHistory" label="Antecedentes de salud en tu familia" hint="Por ejemplo: diabetes, hipertensión o enfermedad del corazón. Es opcional." maxLength={500} value={data.familyHistory} onChange={(e) => change('familyHistory', e.target.value)} />
        <Choices name="severeLowHistory" label="¿Has tenido una baja de glucosa por la que necesitaste ayuda de otra persona?" value={data.severeLowHistory} options={yesNoUnknown} onChange={(value) => change('severeLowHistory', value)} />
      </>}
      {step === 2 && <>
        <SelectField id="treatmentStatus" label="¿Qué tratamiento utilizas actualmente?" value={data.treatmentStatus} onChange={(e) => { change('treatmentStatus', e.target.value); if (e.target.value === 'none') change('medications', []) }} error={errors.treatmentStatus} required><option value="">Selecciona</option>{Object.entries(treatmentLabels).map(([value, label]) => <option key={value} value={value}>{label}</option>)}</SelectField>
        {data.treatmentStatus && data.treatmentStatus !== 'none' && <div className="medication-editor"><div><h3>Medicamentos e insulina</h3><p className="field-hint">Copia el nombre, dosis y horario de tu receta. Si no los recuerdas, puedes completarlos después.</p></div>{data.medications.map((medicine, index) => <div className="medication-row" key={index}><Field id={`medicine-${index}`} label="Nombre" maxLength={150} value={medicine.name} onChange={(e) => change('medications', data.medications.map((item, i) => i === index ? { ...item, name: e.target.value } : item))} /><div className="form-grid"><Field id={`dose-${index}`} label="Dosis y unidad" placeholder="Como aparece en tu receta" maxLength={100} value={medicine.dose} onChange={(e) => change('medications', data.medications.map((item, i) => i === index ? { ...item, dose: e.target.value } : item))} /><Field id={`schedule-${index}`} label="Horario o frecuencia" maxLength={150} value={medicine.schedule} onChange={(e) => change('medications', data.medications.map((item, i) => i === index ? { ...item, schedule: e.target.value } : item))} /></div><button className="text-button danger-text" type="button" onClick={() => change('medications', data.medications.filter((_, i) => i !== index))}><Trash2 size={16} /> Eliminar medicamento {index + 1}</button></div>)}{errors.medications && <p className="field-error">{errors.medications}</p>}<button type="button" className="secondary-button" disabled={data.medications.length >= 20} onClick={() => change('medications', [...data.medications, { name: '', dose: '', schedule: '' }])}><Plus size={17} /> Agregar medicamento</button></div>}
        <Choices name="allergyStatus" label="¿Tienes alguna alergia conocida? *" value={data.allergyStatus} options={yesNoUnknown} onChange={(value) => { change('allergyStatus', value); if (value !== 'yes') change('allergies', '') }} error={errors.allergyStatus} />
        {data.allergyStatus === 'yes' && <Field id="allergies" label="¿A qué tienes alergia y qué reacción te provoca?" maxLength={1000} value={data.allergies} onChange={(e) => change('allergies', e.target.value)} error={errors.allergies} required />}
      </>}
      {step === 3 && <>
        <Choices name="smoking" label="¿Consumes tabaco?" value={data.smoking} options={[[ 'never', 'Nunca'], ['former', 'Antes, ahora no'], ['current', 'Actualmente']]} onChange={(value) => change('smoking', value)} />
        <Choices name="alcohol" label="¿Consumes bebidas alcohólicas?" value={data.alcohol} options={[[ 'none', 'No actualmente'], ['occasional', 'Ocasionalmente'], ['regular', 'Con regularidad']]} onChange={(value) => change('alcohol', value)} />
        <Choices name="activity" label="¿Realizas actividad física?" value={data.activity} options={[[ 'none', 'No actualmente'], ['sometimes', 'Algunos días'], ['regular', 'Con regularidad']]} onChange={(value) => change('activity', value)} />
        <Field id="support" label="¿Necesitas algún apoyo para usar TrackyGlu?" hint="Por ejemplo: ayuda para leer, registrar mediciones o usar tu teléfono." maxLength={500} value={data.support} onChange={(e) => change('support', e.target.value)} />
        <div className="profile-field"><label htmlFor="notes">¿Hay algo más que tu profesional deba saber?</label><textarea id="notes" rows={3} maxLength={2000} value={data.notes} onChange={(e) => change('notes', e.target.value)} placeholder="Síntomas actuales, cirugías, otros tratamientos o algo que quieras conversar." /></div>
        <details className="review-details"><summary><ClipboardList size={18} /> Revisa tus respuestas</summary><HistorySummary data={data} /></details>
        <label className="check-row confirmation-check"><input type="checkbox" checked={data.informationConfirmed} onChange={(e) => change('informationConfirmed', e.target.checked)} /><span>Revisé mis respuestas y reflejan lo que conozco de mi salud. Mi profesional podrá completarlas conmigo.</span></label>{errors.informationConfirmed && <p className="field-error">{errors.informationConfirmed}</p>}
      </>}
      {error && <p className="feedback error" role="alert">{error}</p>}
      <div className="wizard-actions">{step > 0 && <button type="button" className="secondary-button" onClick={() => moveTo(step - 1)}><ArrowLeft size={18} /> Atrás</button>}<button className="primary-button" type="submit">{busy ? 'Guardando…' : step === 3 ? 'Completar mi historia' : 'Guardar y continuar'}{step === 3 ? <CheckCircle2 size={18} /> : <ArrowRight size={18} />}</button></div>
      <button className="text-button save-later" type="button" onClick={() => void persist(true)}><Save size={16} /> Guardar y continuar después</button>
      </fieldset><p className="form-footnote">Tu profesional completará la valoración clínica en consulta. <Link to="/fundamento-clinico">Ver referencias</Link></p>
    </form></div>}
    {blocker.state === 'blocked' && <div className="dialog-backdrop"><section role="alertdialog" aria-modal="true" aria-labelledby="unsaved-title" className="surface confirm-dialog"><h2 id="unsaved-title">Tienes respuestas sin guardar</h2><p>Vuelve al formulario y usa «Guardar y continuar después» para conservarlas.</p><div className="button-row"><button autoFocus className="primary-button" onClick={() => blocker.reset()}>Seguir aquí</button><button className="secondary-button" onClick={() => blocker.proceed()}>Salir sin guardar</button></div></section></div>}
  </PageShell>
}
