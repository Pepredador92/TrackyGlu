import { Clock3, History, LogOut, Plus, UserRound } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../../components/auth/useAuth'
import { getReadings } from '../../services/glucose/glucoseService'
import { calculateGlucoseMetrics } from '../../services/glucose/glucoseMetrics'
import { GlucoseTrendChart, MetricDetails, MetricDisclaimer, MetricsCards } from '../../components/glucose/GlucoseDashboard'
import type { GlucoseReading } from '../../types/glucose'
import { GLUCOSE_CONTEXT_LABELS, formatReadingDateTime, isToday } from '../../utils/glucose'
import './PatientHome.css'

function PatientHome() {
  const { profile, signOut } = useAuth()
  const [readings, setReadings] = useState<GlucoseReading[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [hasError, setHasError] = useState(false)

  useEffect(() => {
    let isCurrent = true

    async function loadReadings() {
      setIsLoading(true)
      setHasError(false)

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

  const validReadings = readings
    .filter((reading) => !Number.isNaN(new Date(reading.timestamp).getTime()))
    .sort((first, second) => new Date(second.timestamp).getTime() - new Date(first.timestamp).getTime())
  const todayReadings = validReadings.filter((reading) => isToday(reading.timestamp))
  const latestReading = validReadings[0]
  const metrics = calculateGlucoseMetrics(validReadings, 14)

  return (
    <main className="patient-home">
      <div className="patient-home__container">
        <header className="patient-header">
          <span className="patient-header__brand">TrackyGlu</span>
          <div className="patient-header__actions">
            <Link className="quiet-link" to="/mi-perfil"><UserRound size={21} strokeWidth={1.8} aria-hidden="true" /><span>Mi perfil</span></Link>
            <button className="logout-button" type="button" onClick={() => void signOut()}>
              <LogOut size={16} strokeWidth={2} aria-hidden="true" />
              <span>Cerrar sesión</span>
            </button>
          </div>
        </header>

        <section className="patient-home__intro" aria-labelledby="patient-home-title">
          <p className="patient-home__greeting">Hola, {profile?.displayName ?? 'Paciente'}</p>
          <h1 id="patient-home-title">Registra tu glucosa de hoy</h1>
          <p className="patient-home__description">
            Mantén actualizado tu seguimiento.
          </p>
        </section>

        <PrimaryGlucoseAction />

        <section className="today-status" aria-labelledby="today-status-title">
          <div className="section-heading">
            <h2 id="today-status-title">Hoy</h2>
            <span className="status-indicator" aria-hidden="true" />
          </div>
          {isLoading && <p className="home-feedback" role="status">Cargando registros...</p>}
          {!isLoading && hasError && <p className="home-feedback home-feedback--error" role="alert">No fue posible cargar tus registros.</p>}
          {!isLoading && !hasError && todayReadings.length === 0 && <p>Aún no has registrado lecturas hoy.</p>}
          {!isLoading && !hasError && todayReadings.length > 0 && (
            <p><strong>{todayReadings.length}</strong> {todayReadings.length === 1 ? 'lectura registrada hoy' : 'lecturas registradas hoy'}</p>
          )}
        </section>

        <section className="latest-reading" aria-labelledby="latest-reading-title">
          <div className="section-heading">
            <h2 id="latest-reading-title">Última lectura</h2>
            <Clock3 size={19} strokeWidth={1.8} aria-hidden="true" />
          </div>
          {isLoading && <p className="home-feedback" role="status">Cargando registros...</p>}
          {!isLoading && hasError && <p className="home-feedback home-feedback--error" role="alert">No fue posible cargar tus registros.</p>}
          {!isLoading && !hasError && !latestReading && <p>Aún no hay lecturas registradas.</p>}
          {!isLoading && !hasError && latestReading && (
            <>
              <div className="latest-reading__value">
                <strong>{latestReading.glucoseValue}</strong>
                <span>{latestReading.unit}</span>
              </div>
              <p className="latest-reading__context">
                {GLUCOSE_CONTEXT_LABELS[latestReading.measurementContext]}{' · '}
                <time dateTime={latestReading.timestamp}>{formatReadingDateTime(latestReading.timestamp)}</time>
              </p>
            </>
          )}
        </section>

        {!isLoading && !hasError && <section className="patient-metrics" aria-labelledby="patient-metrics-title"><div className="section-heading"><div><h2 id="patient-metrics-title">Tu seguimiento</h2><p className="metrics-period">Últimos 14 días</p></div></div><MetricsCards metrics={metrics} /><GlucoseTrendChart metrics={metrics} /><MetricDetails metrics={metrics} /><MetricDisclaimer /></section>}

        <Link className="records-link" to="/mis-registros">
          <History size={18} strokeWidth={1.9} aria-hidden="true" />
          <span>Ver mis registros</span>
        </Link>
      </div>
    </main>
  )
}

function PrimaryGlucoseAction() {
  const navigate = useNavigate()

  return (
    <button
      className="primary-glucose-action"
      type="button"
      onClick={() => navigate('/registrar-glucosa')}
    >
      <span className="primary-glucose-action__icon" aria-hidden="true">
        <Plus size={23} strokeWidth={2.3} />
      </span>
      <span>Registrar lectura de glucosa</span>
    </button>
  )
}

export default PatientHome
