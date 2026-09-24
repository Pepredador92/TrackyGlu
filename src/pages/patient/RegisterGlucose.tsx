import { ArrowLeft, Check, Save } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import type { FormEvent } from 'react'
import { Link } from 'react-router-dom'
import { getDailyCaptureContext, saveDailyContext, createReading } from '../../services/glucose/glucoseService'
import type { DailyCaptureContext } from '../../services/glucose/glucoseService'
import type { GlucoseMeasurementContext, GlucoseMealType } from '../../types/glucose'
import './RegisterGlucose.css'

const CONTEXTS: Array<{ value: GlucoseMeasurementContext; label: string; help: string }> = [
  { value: 'fasting_morning', label: 'En ayuno', help: 'Antes de comer por la mañana' },
  { value: 'pre_meal', label: 'Antes de comer', help: 'Antes de una comida' },
  { value: 'post_meal_1h', label: '1 hora después', help: 'Después de comenzar a comer' },
  { value: 'post_meal_2h', label: '2 horas después', help: 'Después de comenzar a comer' },
  { value: 'post_meal_3h_plus', label: '3 horas o más después', help: 'Después de una comida' },
  { value: 'bedtime', label: 'Antes de dormir', help: 'Al terminar el día' },
  { value: 'random', label: 'Otro momento', help: 'Cuando no aplica una opción anterior' },
]
const MEALS: Array<[GlucoseMealType, string]> = [['breakfast', 'Desayuno'], ['lunch', 'Comida'], ['dinner', 'Cena'], ['snack', 'Colación'], ['other', 'Otra comida']]
const SYMPTOMS: Array<[string, string]> = [['shaking', 'Temblor'], ['sweating', 'Sudoración'], ['dizziness', 'Mareo'], ['thirst', 'Mucha sed'], ['blurred_vision', 'Vista borrosa'], ['none', 'Ninguno']]

function getCurrentDate(): string { const now = new Date(); return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}` }
function getCurrentTime(): string { const now = new Date(); return `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}` }
function localTimestamp(date: string, time: string): string { return new Date(`${date}T${time}`).toISOString() }

function RegisterGlucose() {
  const [context, setContext] = useState<DailyCaptureContext | null>(null)
  const [glucoseValue, setGlucoseValue] = useState('')
  const [measurementContext, setMeasurementContext] = useState<GlucoseMeasurementContext | ''>('')
  const [date, setDate] = useState(getCurrentDate)
  const [time, setTime] = useState(getCurrentTime)
  const [mealType, setMealType] = useState<GlucoseMealType | ''>('')
  const [lastMealTime, setLastMealTime] = useState('')
  const [treatmentTaken, setTreatmentTaken] = useState('')
  const [activity, setActivity] = useState('')
  const [activityDuration, setActivityDuration] = useState('')
  const [symptoms, setSymptoms] = useState<string[]>([])
  const [observation, setObservation] = useState('')
  const [dailyTreatment, setDailyTreatment] = useState('')
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [isSaved, setIsSaved] = useState(false)
  const [saveError, setSaveError] = useState('')

  useEffect(() => { getDailyCaptureContext().then((next) => { setContext(next); setMeasurementContext(next.suggestedContext); setIsLoading(false) }).catch(() => setIsLoading(false)) }, [])

  const selectedContext = useMemo(() => CONTEXTS.find((item) => item.value === measurementContext), [measurementContext])
  const asksMeal = measurementContext === 'pre_meal' || measurementContext?.startsWith('post_meal_')
  const asksLastMeal = measurementContext?.startsWith('post_meal_')
  const firstReading = context?.isFirstReading ?? false
  const toggleSymptom = (key: string) => setSymptoms((current) => key === 'none' ? ['none'] : current.includes(key) ? current.filter((item) => item !== key) : [...current.filter((item) => item !== 'none'), key])

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); setIsSaved(false); setSaveError('')
    const nextErrors: Record<string, string> = {}
    const numeric = Number(glucoseValue)
    if (!glucoseValue.trim() || !Number.isFinite(numeric) || numeric < 20 || numeric > 600) nextErrors.glucoseValue = 'Ingresa un valor entre 20 y 600 mg/dL.'
    if (!measurementContext) nextErrors.measurementContext = 'Selecciona el momento de la medición.'
    if (!date || !time || Number.isNaN(new Date(`${date}T${time}`).getTime())) nextErrors.dateTime = 'Revisa la fecha y la hora de la lectura.'
    if (asksMeal && !mealType) nextErrors.mealType = 'Selecciona qué comida relacionas con esta lectura.'
    if (asksLastMeal && !lastMealTime) nextErrors.lastMealTime = 'Indica aproximadamente a qué hora comenzó la comida.'
    if (firstReading && context?.hasTreatmentPlan && !treatmentTaken) nextErrors.treatmentTaken = 'Indica si tomaste tu tratamiento programado.'
    if (activity === 'yes' && (!activityDuration || Number(activityDuration) < 1 || Number(activityDuration) > 720)) nextErrors.activityDuration = 'Indica los minutos de actividad, entre 1 y 720.'
    setErrors(nextErrors)
    if (Object.keys(nextErrors).length) return
    setIsSaving(true)
    try {
      let dailyContext = context?.dailyContext
      if (firstReading && !dailyContext && (dailyTreatment || treatmentTaken)) dailyContext = await saveDailyContext({ local_date: context?.localDate ?? getCurrentDate(), treatment_adherence_24h: dailyTreatment === 'yes' || treatmentTaken === 'yes' ? true : dailyTreatment === 'no' || treatmentTaken === 'no' ? false : null, missed_doses_7d: null, missed_dose_reason: null, illness_flag: null, stress_flag: null, sleep_quality: null })
      await createReading({ glucoseValue: numeric, unit: 'mg/dL', measurementContext: measurementContext as GlucoseMeasurementContext, timestamp: localTimestamp(date, time), hasEaten: measurementContext === 'fasting_morning' ? false : asksMeal ? true : null, lastMealAt: lastMealTime ? localTimestamp(date, lastMealTime) : null, mealType: mealType || null, treatmentDueBeforeMeasurement: firstReading && context?.hasTreatmentPlan ? true : null, treatmentTakenAsScheduled: firstReading && context?.hasTreatmentPlan ? treatmentTaken === 'yes' : null, recentPhysicalActivity: activity ? activity === 'yes' : null, activityDurationMin: activityDuration ? Number(activityDuration) : null, symptomsPresent: symptoms.length > 0 && !symptoms.includes('none'), symptoms: symptoms.filter((item) => item !== 'none'), observation })
      setIsSaved(true); setGlucoseValue(''); setObservation(''); setErrors({})
    } catch { setSaveError('No fue posible guardar la lectura. Intenta nuevamente.') } finally { setIsSaving(false) }
  }

  return <main className="register-glucose"><div className="register-glucose__container"><header className="register-glucose__header"><Link className="back-link" to="/"><ArrowLeft size={19} aria-hidden="true" /><span>Volver</span></Link><span className="register-glucose__brand">TrackyGlu</span></header><section className="register-glucose__intro" aria-labelledby="register-glucose-title"><p className="register-glucose__eyebrow">Nueva lectura</p><h1 id="register-glucose-title">Registrar lectura</h1><p>Te preguntaremos solo lo que ayude a entender este registro.</p></section>
    {isLoading ? <p className="capture-loading" role="status">Preparando las preguntas de hoy…</p> : <form className="glucose-form" onSubmit={handleSubmit} noValidate>
      {firstReading && <div className="context-note"><strong>Primera lectura de hoy</strong><span>Te haremos unas preguntas breves sobre comida y tratamiento. No volveremos a repetirlas en cada lectura.</span></div>}
      <div className="form-field"><label htmlFor="glucose-value">Glucosa</label><div className="glucose-input-wrap"><input id="glucose-value" name="glucoseValue" type="number" inputMode="decimal" min="20" max="600" step="any" value={glucoseValue} onChange={(event) => setGlucoseValue(event.target.value)} aria-describedby={errors.glucoseValue ? 'glucose-value-error' : undefined} aria-invalid={Boolean(errors.glucoseValue)} placeholder="124" /><span aria-hidden="true">mg/dL</span></div>{errors.glucoseValue && <p className="form-error" id="glucose-value-error">{errors.glucoseValue}</p>}</div>
      <fieldset className="form-field measurement-field" aria-describedby={errors.measurementContext ? 'measurement-context-error' : undefined}><legend>¿Cuándo tomaste esta lectura?</legend><p className="field-help">Sugerencia según la hora: {selectedContext?.label ?? 'elige una opción'}. Puedes cambiarla.</p><div className="measurement-options">{CONTEXTS.map((item) => <label className={`measurement-option${measurementContext === item.value ? ' is-selected' : ''}`} key={item.value}><input type="radio" name="measurementContext" value={item.value} checked={measurementContext === item.value} onChange={() => setMeasurementContext(item.value)} /><span className="measurement-option__indicator" aria-hidden="true" /><span><strong>{item.label}</strong><small>{item.help}</small></span></label>)}</div>{errors.measurementContext && <p className="form-error" id="measurement-context-error">{errors.measurementContext}</p>}</fieldset>
      {firstReading && context?.hasTreatmentPlan && <fieldset className="form-field contextual-question"><legend>¿Tomaste tu tratamiento programado?</legend><p className="field-help">Solo lo preguntamos una vez al día cuando tu historia indica que tienes tratamiento.</p><div className="binary-options">{[['yes', 'Sí'], ['no', 'Todavía no'], ['unknown', 'No lo recuerdo']].map(([value, label]) => <label key={value}><input type="radio" name="treatmentTaken" value={value} checked={treatmentTaken === value} onChange={() => setTreatmentTaken(value)} /><span>{label}</span></label>)}</div>{errors.treatmentTaken && <p className="form-error">{errors.treatmentTaken}</p>}</fieldset>}
      {firstReading && <fieldset className="form-field contextual-question"><legend>¿Seguiste tu tratamiento durante las últimas 24 horas?</legend><p className="field-help">Respuesta general y opcional. Puedes dejarla sin responder.</p><div className="binary-options">{[['yes', 'Sí'], ['no', 'No'], ['unknown', 'No lo sé']].map(([value, label]) => <label key={value}><input type="radio" name="dailyTreatment" value={value} checked={dailyTreatment === value} onChange={() => setDailyTreatment(value)} /><span>{label}</span></label>)}</div></fieldset>}
      {asksMeal && <fieldset className="form-field contextual-question"><legend>¿Con qué comida se relaciona?</legend><div className="meal-options">{MEALS.map(([value, label]) => <label key={value}><input type="radio" name="mealType" value={value} checked={mealType === value} onChange={() => setMealType(value)} /><span>{label}</span></label>)}</div>{errors.mealType && <p className="form-error">{errors.mealType}</p>}</fieldset>}
      {asksLastMeal && <div className="form-field"><label htmlFor="last-meal-time">¿A qué hora comenzó esa comida?</label><input id="last-meal-time" type="time" value={lastMealTime} onChange={(event) => setLastMealTime(event.target.value)} aria-invalid={Boolean(errors.lastMealTime)} />{errors.lastMealTime && <p className="form-error">{errors.lastMealTime}</p>}</div>}
      <div className="date-time-fields"><div className="form-field"><label htmlFor="reading-date">Fecha</label><input id="reading-date" type="date" value={date} onChange={(event) => setDate(event.target.value)} aria-invalid={Boolean(errors.dateTime)} /></div><div className="form-field"><label htmlFor="reading-time">Hora</label><input id="reading-time" type="time" value={time} onChange={(event) => setTime(event.target.value)} aria-invalid={Boolean(errors.dateTime)} /></div></div>{errors.dateTime && <p className="form-error date-time-error">{errors.dateTime}</p>}
      <fieldset className="form-field contextual-question"><legend>¿Hiciste actividad física antes de esta lectura?</legend><div className="binary-options">{[['no', 'No'], ['yes', 'Sí']].map(([value, label]) => <label key={value}><input type="radio" name="activity" value={value} checked={activity === value} onChange={() => setActivity(value)} /><span>{label}</span></label>)}</div>{activity === 'yes' && <div className="activity-detail"><label htmlFor="activity-duration">Minutos aproximados</label><input id="activity-duration" type="number" min="1" max="720" value={activityDuration} onChange={(event) => setActivityDuration(event.target.value)} />{errors.activityDuration && <p className="form-error">{errors.activityDuration}</p>}</div>}</fieldset>
      <fieldset className="form-field contextual-question"><legend>¿Tuviste síntomas que quieras compartir?</legend><div className="symptom-options">{SYMPTOMS.map(([value, label]) => <label key={value}><input type="checkbox" checked={symptoms.includes(value)} onChange={() => toggleSymptom(value)} /><span>{label}</span></label>)}</div></fieldset>
      <div className="form-field"><label htmlFor="reading-observation">Nota opcional</label><textarea id="reading-observation" rows={2} maxLength={2000} value={observation} onChange={(event) => setObservation(event.target.value)} placeholder="Algo que tu profesional deba conocer sobre esta lectura" /></div>
      <button className="save-reading-button" type="submit" disabled={isSaving}>{isSaving ? <span>Guardando...</span> : <><Save size={19} aria-hidden="true" /><span>Guardar lectura</span></>}</button>{saveError && <p className="form-error" role="alert">{saveError}</p>}{isSaved && <div className="success-message" role="status"><Check size={19} aria-hidden="true" /><span>Lectura registrada</span></div>}
    </form>}
  </div></main>
}
export default RegisterGlucose
