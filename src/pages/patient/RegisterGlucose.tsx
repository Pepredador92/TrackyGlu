import { ArrowLeft, Check, Save } from 'lucide-react'
import { useState } from 'react'
import type { FormEvent } from 'react'
import { Link } from 'react-router-dom'
import { createReading } from '../../services/glucose/glucoseService'
import type { GlucoseMeasurementContext, GlucoseReading } from '../../types/glucose'
import './RegisterGlucose.css'

const MEASUREMENT_CONTEXTS: Array<{
  value: GlucoseMeasurementContext
  label: string
}> = [
  { value: 'fasting_morning', label: 'Ayuno' },
  { value: 'pre_meal', label: 'Antes de comer' },
  { value: 'post_meal_2h', label: '2 horas después de comer' },
  { value: 'other', label: 'Otro' },
]

function getCurrentDate(): string {
  const now = new Date()
  const year = now.getFullYear()
  const month = String(now.getMonth() + 1).padStart(2, '0')
  const day = String(now.getDate()).padStart(2, '0')

  return `${year}-${month}-${day}`
}

function getCurrentTime(): string {
  const now = new Date()
  const hours = String(now.getHours()).padStart(2, '0')
  const minutes = String(now.getMinutes()).padStart(2, '0')

  return `${hours}:${minutes}`
}

function createReadingId(): string {
  return crypto.randomUUID()
}

function RegisterGlucose() {
  const [glucoseValue, setGlucoseValue] = useState('')
  const [measurementContext, setMeasurementContext] = useState<GlucoseMeasurementContext | ''>('')
  const [date, setDate] = useState(getCurrentDate)
  const [time, setTime] = useState(getCurrentTime)
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [isSaving, setIsSaving] = useState(false)
  const [isSaved, setIsSaved] = useState(false)

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setIsSaved(false)

    const nextErrors: Record<string, string> = {}
    const numericGlucoseValue = Number(glucoseValue)

    if (!glucoseValue.trim() || !Number.isFinite(numericGlucoseValue) || numericGlucoseValue <= 0) {
      nextErrors.glucoseValue = 'Ingresa una lectura de glucosa mayor que cero.'
    }

    if (!measurementContext) {
      nextErrors.measurementContext = 'Selecciona el momento de la medición.'
    }

    if (!date || !time || Number.isNaN(new Date(`${date}T${time}`).getTime())) {
      nextErrors.dateTime = 'Revisa la fecha y la hora de la lectura.'
    }

    setErrors(nextErrors)

    if (Object.keys(nextErrors).length > 0 || !measurementContext) {
      return
    }

    const reading: GlucoseReading = {
      id: createReadingId(),
      // MOCK/TEMPORAL: reemplazar cuando exista autenticación.
      patientId: 'P0001',
      glucoseValue: numericGlucoseValue,
      unit: 'mg/dL',
      measurementContext,
      timestamp: new Date(`${date}T${time}`).toISOString(),
    }

    setIsSaving(true)

    try {
      await createReading(reading)
      setIsSaved(true)
      setGlucoseValue('')
      setMeasurementContext('')
      setErrors({})
    } finally {
      setIsSaving(false)
    }
  }

  return (
    <main className="register-glucose">
      <div className="register-glucose__container">
        <header className="register-glucose__header">
          <Link className="back-link" to="/">
            <ArrowLeft size={19} strokeWidth={2} aria-hidden="true" />
            <span>Volver</span>
          </Link>
          <span className="register-glucose__brand">TrackyGlu</span>
        </header>

        <section className="register-glucose__intro" aria-labelledby="register-glucose-title">
          <p className="register-glucose__eyebrow">Nueva lectura</p>
          <h1 id="register-glucose-title">Registrar lectura</h1>
          <p>Ingresa tu medición de glucosa.</p>
        </section>

        <form className="glucose-form" onSubmit={handleSubmit} noValidate>
          <div className="form-field">
            <label htmlFor="glucose-value">Glucosa</label>
            <div className="glucose-input-wrap">
              <input
                id="glucose-value"
                name="glucoseValue"
                type="number"
                inputMode="decimal"
                min="0"
                step="any"
                value={glucoseValue}
                onChange={(event) => setGlucoseValue(event.target.value)}
                aria-describedby={errors.glucoseValue ? 'glucose-value-error' : undefined}
                aria-invalid={Boolean(errors.glucoseValue)}
                placeholder="124"
              />
              <span aria-hidden="true">mg/dL</span>
            </div>
            {errors.glucoseValue && <p className="form-error" id="glucose-value-error">{errors.glucoseValue}</p>}
          </div>

          <fieldset className="form-field measurement-field" aria-describedby={errors.measurementContext ? 'measurement-context-error' : undefined}>
            <legend>Momento de la medición</legend>
            <div className="measurement-options">
              {MEASUREMENT_CONTEXTS.map((context) => (
                <label className={`measurement-option${measurementContext === context.value ? ' is-selected' : ''}`} key={context.value}>
                  <input
                    type="radio"
                    name="measurementContext"
                    value={context.value}
                    checked={measurementContext === context.value}
                    onChange={() => setMeasurementContext(context.value)}
                  />
                  <span className="measurement-option__indicator" aria-hidden="true" />
                  <span>{context.label}</span>
                </label>
              ))}
            </div>
            {errors.measurementContext && <p className="form-error" id="measurement-context-error">{errors.measurementContext}</p>}
          </fieldset>

          <div className="date-time-fields">
            <div className="form-field">
              <label htmlFor="reading-date">Fecha</label>
              <input
                id="reading-date"
                name="date"
                type="date"
                value={date}
                onChange={(event) => setDate(event.target.value)}
                aria-describedby={errors.dateTime ? 'date-time-error' : undefined}
                aria-invalid={Boolean(errors.dateTime)}
              />
            </div>
            <div className="form-field">
              <label htmlFor="reading-time">Hora</label>
              <input
                id="reading-time"
                name="time"
                type="time"
                value={time}
                onChange={(event) => setTime(event.target.value)}
                aria-describedby={errors.dateTime ? 'date-time-error' : undefined}
                aria-invalid={Boolean(errors.dateTime)}
              />
            </div>
          </div>
          {errors.dateTime && <p className="form-error date-time-error" id="date-time-error">{errors.dateTime}</p>}

          <button className="save-reading-button" type="submit" disabled={isSaving}>
            {isSaving ? <span>Guardando...</span> : <><Save size={19} strokeWidth={2} aria-hidden="true" /><span>Guardar lectura</span></>}
          </button>

          {isSaved && (
            <div className="success-message" role="status">
              <Check size={19} strokeWidth={2.2} aria-hidden="true" />
              <span>Lectura registrada</span>
            </div>
          )}
        </form>
      </div>
    </main>
  )
}

export default RegisterGlucose
