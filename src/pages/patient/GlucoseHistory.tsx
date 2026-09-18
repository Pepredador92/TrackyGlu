import { ArrowLeft, Clock3, Plus } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { getReadings } from '../../services/glucose/glucoseService'
import type { GlucoseMeasurementContext, GlucoseReading } from '../../types/glucose'
import './GlucoseHistory.css'

const CONTEXT_LABELS: Record<GlucoseMeasurementContext, string> = {
  fasting_morning: 'Ayuno',
  pre_meal: 'Antes de comer',
  post_meal_2h: '2 horas después de comer',
  other: 'Otro',
}

const dateFormatter = new Intl.DateTimeFormat('es-MX', {
  day: 'numeric',
  month: 'long',
  year: 'numeric',
})

const timeFormatter = new Intl.DateTimeFormat('es-MX', {
  hour: '2-digit',
  minute: '2-digit',
  hour12: false,
})

function getLocalDayKey(timestamp: string): string {
  const date = new Date(timestamp)
  return `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`
}

function getDayLabel(timestamp: string): string {
  const date = new Date(timestamp)
  const today = new Date()
  const yesterday = new Date(today)
  yesterday.setDate(today.getDate() - 1)

  if (getLocalDayKey(timestamp) === getLocalDayKey(today.toISOString())) {
    return 'Hoy'
  }

  if (getLocalDayKey(timestamp) === getLocalDayKey(yesterday.toISOString())) {
    return 'Ayer'
  }

  return dateFormatter.format(date)
}

function groupReadingsByDay(readings: GlucoseReading[]): Array<[string, GlucoseReading[]]> {
  const groups = new Map<string, GlucoseReading[]>()

  readings
    .filter((reading) => !Number.isNaN(new Date(reading.timestamp).getTime()))
    .sort((first, second) => new Date(second.timestamp).getTime() - new Date(first.timestamp).getTime())
    .forEach((reading) => {
      const dayKey = getLocalDayKey(reading.timestamp)
      const dayReadings = groups.get(dayKey) ?? []
      dayReadings.push(reading)
      groups.set(dayKey, dayReadings)
    })

  return Array.from(groups.entries())
}

function GlucoseHistory() {
  const navigate = useNavigate()
  const [readings, setReadings] = useState<GlucoseReading[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [hasError, setHasError] = useState(false)

  useEffect(() => {
    let isCurrent = true

    async function loadReadings() {
      try {
        const storedReadings = await getReadings()
        if (isCurrent) {
          setReadings(storedReadings)
        }
      } catch {
        if (isCurrent) {
          setHasError(true)
        }
      } finally {
        if (isCurrent) {
          setIsLoading(false)
        }
      }
    }

    void loadReadings()

    return () => {
      isCurrent = false
    }
  }, [])

  const groupedReadings = groupReadingsByDay(readings)

  return (
    <main className="glucose-history">
      <div className="glucose-history__container">
        <header className="glucose-history__header">
          <Link className="back-link" to="/">
            <ArrowLeft size={19} strokeWidth={2} aria-hidden="true" />
            <span>Volver</span>
          </Link>
          <span className="glucose-history__brand">TrackyGlu</span>
        </header>

        <section className="glucose-history__intro" aria-labelledby="glucose-history-title">
          <p className="glucose-history__eyebrow">Seguimiento</p>
          <h1 id="glucose-history-title">Mis registros</h1>
          <p>Consulta tus lecturas de glucosa registradas.</p>
        </section>

        {isLoading && <p className="history-feedback" role="status">Cargando registros...</p>}

        {!isLoading && hasError && (
          <p className="history-feedback history-feedback--error" role="alert">
            No fue posible cargar tus registros.
          </p>
        )}

        {!isLoading && !hasError && groupedReadings.length === 0 && (
          <EmptyHistory onRegister={() => navigate('/registrar-glucosa')} />
        )}

        {!isLoading && !hasError && groupedReadings.length > 0 && (
          <div className="history-groups">
            {groupedReadings.map(([dayKey, dayReadings]) => (
              <section className="history-group" key={dayKey} aria-labelledby={`history-day-${dayKey}`}>
                <h2 id={`history-day-${dayKey}`}>{getDayLabel(dayReadings[0].timestamp)}</h2>
                <div className="history-group__readings">
                  {dayReadings.map((reading) => <GlucoseReadingItem key={reading.id} reading={reading} />)}
                </div>
              </section>
            ))}
            <Link className="secondary-register-link" to="/registrar-glucosa">
              <Plus size={18} strokeWidth={2} aria-hidden="true" />
              <span>Registrar nueva lectura</span>
            </Link>
          </div>
        )}
      </div>
    </main>
  )
}

function GlucoseReadingItem({ reading }: { reading: GlucoseReading }) {
  const readingDate = new Date(reading.timestamp)

  return (
    <article className="reading-item">
      <div className="reading-item__value">
        <strong>{reading.glucoseValue}</strong>
        <span>{reading.unit}</span>
      </div>
      <div className="reading-item__details">
        <span>{CONTEXT_LABELS[reading.measurementContext]}</span>
        <span className="reading-item__time">
          <Clock3 size={15} strokeWidth={1.9} aria-hidden="true" />
          <time dateTime={reading.timestamp}>{timeFormatter.format(readingDate)}</time>
        </span>
      </div>
    </article>
  )
}

function EmptyHistory({ onRegister }: { onRegister: () => void }) {
  return (
    <section className="empty-history" aria-labelledby="empty-history-title">
      <h2 id="empty-history-title">Aún no tienes lecturas registradas.</h2>
      <p>Registra tu primera lectura para comenzar tu seguimiento.</p>
      <button className="empty-history__button" type="button" onClick={onRegister}>
        <Plus size={18} strokeWidth={2} aria-hidden="true" />
        <span>Registrar lectura de glucosa</span>
      </button>
    </section>
  )
}

export default GlucoseHistory
