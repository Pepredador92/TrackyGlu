import { ArrowLeft, Check, LogOut } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from '../../components/auth/useAuth'
import { acknowledgeAlert, getProfessionalAlerts } from '../../services/alertService'
import type { AlertSeverity, AlertStatus, ProfessionalAlert } from '../../services/alertService'
import './ProfessionalAlertsPage.css'

const statusLabels: Record<AlertStatus, string> = {
  open: 'Pendiente',
  acknowledged: 'Reconocida',
  closed: 'Cerrada',
}

const severityLabels: Record<AlertSeverity, string> = {
  info: 'Información',
  warning: 'Advertencia',
  critical: 'Crítica',
}

const dateTimeFormatter = new Intl.DateTimeFormat('es-MX', {
  dateStyle: 'medium',
  timeStyle: 'short',
})

function ProfessionalAlertsPage() {
  const { signOut } = useAuth()
  const [alerts, setAlerts] = useState<ProfessionalAlert[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [hasError, setHasError] = useState(false)
  const [acknowledgingId, setAcknowledgingId] = useState<string | null>(null)
  const [successMessage, setSuccessMessage] = useState(false)
  const [acknowledgeError, setAcknowledgeError] = useState(false)

  async function loadAlerts() {
    setIsLoading(true)
    setHasError(false)

    try {
      setAlerts(await getProfessionalAlerts())
    } catch (error) {
      console.error('Could not load professional alerts', error)
      setHasError(true)
    } finally {
      // The remote request controls this loading state after the effect starts.
      // oxlint-disable-next-line react(set-state-in-effect)
      setIsLoading(false)
    }
  }

  useEffect(() => {
    let isCurrent = true

    getProfessionalAlerts()
      .then((nextAlerts) => {
        if (isCurrent) {
          setAlerts(nextAlerts)
          setIsLoading(false)
        }
      })
      .catch((error) => {
        console.error('Could not load professional alerts', error)
        if (isCurrent) {
          setHasError(true)
          setIsLoading(false)
        }
      })

    return () => {
      isCurrent = false
    }
  }, [])

  async function handleAcknowledge(alertId: string) {
    setAcknowledgingId(alertId)
    setAcknowledgeError(false)
    setSuccessMessage(false)

    try {
      await acknowledgeAlert(alertId)
      await loadAlerts()
      setSuccessMessage(true)
    } catch (error) {
      console.error('Could not acknowledge professional alert', error)
      setAcknowledgeError(true)
    } finally {
      setAcknowledgingId(null)
    }
  }

  return (
    <main className="professional-alerts">
      <div className="professional-alerts__container">
        <header className="professional-alerts__header">
          <Link className="back-link" to="/professional">
            <ArrowLeft size={19} strokeWidth={2} aria-hidden="true" />
            <span>Volver</span>
          </Link>
          <button className="professional-alerts__logout" type="button" onClick={() => void signOut()}>
            <LogOut size={16} strokeWidth={2} aria-hidden="true" />
            <span>Cerrar sesión</span>
          </button>
        </header>

        <section className="professional-alerts__intro" aria-labelledby="professional-alerts-title">
          <p className="professional-alerts__eyebrow">Panel profesional</p>
          <h1 id="professional-alerts-title">Alertas de pacientes</h1>
          <p>Revisa las alertas generadas para los pacientes que tienes asignados.</p>
        </section>

        {isLoading && <p className="alerts-feedback" role="status">Cargando alertas...</p>}
        {!isLoading && hasError && <p className="alerts-feedback alerts-feedback--error" role="alert">No fue posible cargar las alertas.</p>}
        {!isLoading && !hasError && alerts.length === 0 && <p className="alerts-feedback">No hay alertas para revisar.</p>}
        {successMessage && <p className="alerts-feedback alerts-feedback--success" role="status">Alerta reconocida correctamente.</p>}
        {acknowledgeError && <p className="alerts-feedback alerts-feedback--error" role="alert">No fue posible reconocer la alerta.</p>}

        {!isLoading && !hasError && alerts.length > 0 && (
          <div className="professional-alerts__list">
            {alerts.map((alert) => (
              <AlertCard
                key={alert.id}
                alert={alert}
                isAcknowledging={acknowledgingId === alert.id}
                onAcknowledge={handleAcknowledge}
              />
            ))}
          </div>
        )}
      </div>
    </main>
  )
}

function AlertCard({
  alert,
  isAcknowledging,
  onAcknowledge,
}: {
  alert: ProfessionalAlert
  isAcknowledging: boolean
  onAcknowledge: (alertId: string) => void
}) {
  return (
    <article className="alert-card">
      <div className="alert-card__topline">
        <span className="alert-card__patient">{alert.patientName}</span>
        <span className={`alert-card__status alert-card__status--${alert.status}`}>{statusLabels[alert.status]}</span>
      </div>
      <div className="alert-card__reading">
        {alert.glucoseValue === null ? (
          <span className="alert-card__reading-missing">Lectura no disponible</span>
        ) : (
          <><strong>{alert.glucoseValue}</strong><span>{alert.unit}</span></>
        )}
      </div>
      <div className="alert-card__details">
        <span className={`alert-card__severity alert-card__severity--${alert.severity}`}>
          {severityLabels[alert.severity]}
        </span>
        <span>{alert.reason}</span>
      </div>
      <time className="alert-card__date" dateTime={alert.createdAt}>
        {dateTimeFormatter.format(new Date(alert.createdAt))}
      </time>
      {alert.status === 'open' && (
        <button
          className="alert-card__acknowledge"
          type="button"
          disabled={isAcknowledging}
          onClick={() => onAcknowledge(alert.id)}
        >
          <Check size={17} strokeWidth={2} aria-hidden="true" />
          <span>{isAcknowledging ? 'Reconociendo...' : 'Reconocer alerta'}</span>
        </button>
      )}
    </article>
  )
}

export default ProfessionalAlertsPage
