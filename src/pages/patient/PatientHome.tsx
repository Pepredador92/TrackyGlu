import { Clock3, History, Plus, UserRound } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import './PatientHome.css'

const MOCK_TODAY_READINGS = {
  completed: 2,
  total: 3,
}

const MOCK_LATEST_READING = {
  value: 124,
  unit: 'mg/dL',
  time: '14:30',
}

function PatientHome() {
  return (
    <main className="patient-home">
      <div className="patient-home__container">
        <header className="patient-header">
          <span className="patient-header__brand">TrackyGlu</span>
          <button className="icon-button" type="button" aria-label="Abrir perfil">
            <UserRound size={21} strokeWidth={1.8} aria-hidden="true" />
          </button>
        </header>

        <section className="patient-home__intro" aria-labelledby="patient-home-title">
          <p className="patient-home__greeting">Hola</p>
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
          <p>
            <strong>{MOCK_TODAY_READINGS.completed} de {MOCK_TODAY_READINGS.total}</strong>{' '}
            lecturas registradas
          </p>
        </section>

        <section className="latest-reading" aria-labelledby="latest-reading-title">
          <div className="section-heading">
            <h2 id="latest-reading-title">Última lectura</h2>
            <Clock3 size={19} strokeWidth={1.8} aria-hidden="true" />
          </div>
          <div className="latest-reading__value">
            <strong>{MOCK_LATEST_READING.value}</strong>
            <span>{MOCK_LATEST_READING.unit}</span>
          </div>
          <time dateTime="14:30">{MOCK_LATEST_READING.time}</time>
        </section>

        <a className="records-link" href="/mis-registros">
          <History size={18} strokeWidth={1.9} aria-hidden="true" />
          <span>Ver mis registros</span>
        </a>
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
