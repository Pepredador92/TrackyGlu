import { ArrowLeft, Check, LogOut, Play } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from '../../components/auth/useAuth'
import {
  closeClinicalTask,
  getProfessionalClinicalTasks,
  startClinicalTaskReview,
} from '../../services/clinicalTaskService'
import type {
  ClinicalTaskDecision,
  ClinicalTaskPriority,
  ClinicalTaskStatus,
  ProfessionalClinicalTask,
} from '../../services/clinicalTaskService'
import './ProfessionalTasksPage.css'

const priorityLabels: Record<ClinicalTaskPriority, string> = {
  info: 'Información',
  warning: 'Advertencia',
  critical: 'Crítica',
}

const statusLabels: Record<ClinicalTaskStatus, string> = {
  pending_review: 'Pendiente de revisión',
  in_review: 'En revisión',
  closed: 'Cerrada',
  draft_ready: 'Borrador disponible',
}

const decisionLabels: Record<ClinicalTaskDecision, string> = {
  approved: 'Aprobada',
  modified: 'Modificada',
  cancelled: 'Cancelada',
}

const dateTimeFormatter = new Intl.DateTimeFormat('es-MX', {
  dateStyle: 'medium',
  timeStyle: 'short',
})

function ProfessionalTasksPage() {
  const { signOut } = useAuth()
  const [tasks, setTasks] = useState<ProfessionalClinicalTask[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [hasError, setHasError] = useState(false)
  const [processingTaskId, setProcessingTaskId] = useState<string | null>(null)
  const [successMessage, setSuccessMessage] = useState('')
  const [operationError, setOperationError] = useState(false)
  const [decisions, setDecisions] = useState<Record<string, ClinicalTaskDecision | ''>>({})
  const [notes, setNotes] = useState<Record<string, string>>({})

  async function loadTasks() {
    setIsLoading(true)
    setHasError(false)

    try {
      setTasks(await getProfessionalClinicalTasks())
    } catch (error) {
      console.error('Could not load clinical tasks', error)
      setHasError(true)
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    let isCurrent = true

    getProfessionalClinicalTasks()
      .then((nextTasks) => {
        if (isCurrent) {
          setTasks(nextTasks)
          setIsLoading(false)
        }
      })
      .catch((error) => {
        console.error('Could not load clinical tasks', error)
        if (isCurrent) {
          setHasError(true)
          setIsLoading(false)
        }
      })

    return () => {
      isCurrent = false
    }
  }, [])

  async function handleStartReview(taskId: string) {
    setProcessingTaskId(taskId)
    setOperationError(false)
    setSuccessMessage('')

    try {
      await startClinicalTaskReview(taskId)
      await loadTasks()
      setSuccessMessage('Revisión iniciada.')
    } catch (error) {
      console.error('Could not start clinical task review', error)
      setOperationError(true)
    } finally {
      setProcessingTaskId(null)
    }
  }

  async function handleCloseTask(task: ProfessionalClinicalTask) {
    const decision = decisions[task.id]
    const reviewNote = notes[task.id] ?? ''

    if (!decision || !reviewNote.trim()) {
      setOperationError(true)
      setSuccessMessage('')
      return
    }

    setProcessingTaskId(task.id)
    setOperationError(false)
    setSuccessMessage('')

    try {
      await closeClinicalTask(task.id, decision, reviewNote)
      await loadTasks()
      setSuccessMessage('Tarea cerrada correctamente.')
    } catch (error) {
      console.error('Could not close clinical task', error)
      setOperationError(true)
    } finally {
      setProcessingTaskId(null)
    }
  }

  return (
    <main className="professional-tasks">
      <div className="professional-tasks__container">
        <header className="professional-tasks__header">
          <Link className="back-link" to="/professional">
            <ArrowLeft size={19} strokeWidth={2} aria-hidden="true" />
            <span>Volver</span>
          </Link>
          <button className="professional-tasks__logout" type="button" onClick={() => void signOut()}>
            <LogOut size={16} strokeWidth={2} aria-hidden="true" />
            <span>Cerrar sesión</span>
          </button>
        </header>

        <section className="professional-tasks__intro" aria-labelledby="professional-tasks-title">
          <p className="professional-tasks__eyebrow">Panel profesional</p>
          <h1 id="professional-tasks-title">Tareas clínicas</h1>
          <p>Revisa y documenta las tareas generadas para los pacientes que tienes asignados.</p>
        </section>

        {isLoading && <p className="tasks-feedback" role="status">Cargando tareas...</p>}
        {!isLoading && hasError && <p className="tasks-feedback tasks-feedback--error" role="alert">No fue posible cargar las tareas.</p>}
        {!isLoading && !hasError && tasks.length === 0 && <p className="tasks-feedback">No hay tareas clínicas asignadas.</p>}
        {successMessage && <p className="tasks-feedback tasks-feedback--success" role="status">{successMessage}</p>}
        {operationError && <p className="tasks-feedback tasks-feedback--error" role="alert">No fue posible completar la acción. Revisa los datos e intenta nuevamente.</p>}

        {!isLoading && !hasError && tasks.length > 0 && (
          <div className="professional-tasks__list">
            {tasks.map((task) => (
              <ClinicalTaskCard
                key={task.id}
                task={task}
                decision={decisions[task.id] ?? ''}
                note={notes[task.id] ?? ''}
                isProcessing={processingTaskId === task.id}
                onDecisionChange={(value) => setDecisions((current) => ({ ...current, [task.id]: value }))}
                onNoteChange={(value) => setNotes((current) => ({ ...current, [task.id]: value }))}
                onStartReview={handleStartReview}
                onCloseTask={handleCloseTask}
              />
            ))}
          </div>
        )}
      </div>
    </main>
  )
}

function ClinicalTaskCard({
  task,
  decision,
  note,
  isProcessing,
  onDecisionChange,
  onNoteChange,
  onStartReview,
  onCloseTask,
}: {
  task: ProfessionalClinicalTask
  decision: ClinicalTaskDecision | ''
  note: string
  isProcessing: boolean
  onDecisionChange: (value: ClinicalTaskDecision | '') => void
  onNoteChange: (value: string) => void
  onStartReview: (taskId: string) => void
  onCloseTask: (task: ProfessionalClinicalTask) => void
}) {
  return (
    <article className="clinical-task-card">
      <div className="clinical-task-card__topline">
        <span className="clinical-task-card__patient">{task.patientName}</span>
        <span className={`clinical-task-card__status clinical-task-card__status--${task.status}`}>{statusLabels[task.status]}</span>
      </div>
      <div className="clinical-task-card__meta">
        <span className={`clinical-task-card__priority clinical-task-card__priority--${task.priority}`}>
          {priorityLabels[task.priority]}
        </span>
        <span>{task.triggerRule}</span>
      </div>
      {task.alertReason && <p className="clinical-task-card__reason">{task.alertReason}</p>}
      {task.glucoseValue !== null && (
        <p className="clinical-task-card__reading">
          <strong>{task.glucoseValue}</strong>{task.unit && <span>{task.unit}</span>}
        </p>
      )}
      <p className="clinical-task-card__date">
        Creada: <time dateTime={task.createdAt}>{dateTimeFormatter.format(new Date(task.createdAt))}</time>
      </p>
      {task.firstReviewAt && <p className="clinical-task-card__date">Primera revisión: {dateTimeFormatter.format(new Date(task.firstReviewAt))}</p>}
      {task.closedAt && <p className="clinical-task-card__date">Cerrada: {dateTimeFormatter.format(new Date(task.closedAt))}</p>}

      {task.status === 'pending_review' && (
        <button className="clinical-task-card__action" type="button" disabled={isProcessing} onClick={() => onStartReview(task.id)}>
          <Play size={17} strokeWidth={2} aria-hidden="true" />
          <span>{isProcessing ? 'Iniciando...' : 'Iniciar revisión'}</span>
        </button>
      )}

      {task.status === 'in_review' && (
        <div className="clinical-task-card__form">
          <div className="clinical-task-card__field">
            <label htmlFor={`decision-${task.id}`}>Decisión</label>
            <select
              id={`decision-${task.id}`}
              value={decision}
              onChange={(event) => onDecisionChange(event.target.value as ClinicalTaskDecision | '')}
              disabled={isProcessing}
            >
              <option value="">Selecciona una decisión</option>
              <option value="approved">Aprobar</option>
              <option value="modified">Modificar</option>
              <option value="cancelled">Cancelar</option>
            </select>
          </div>
          <div className="clinical-task-card__field">
            <label htmlFor={`note-${task.id}`}>Nota de revisión</label>
            <textarea
              id={`note-${task.id}`}
              value={note}
              onChange={(event) => onNoteChange(event.target.value)}
              placeholder="Documenta brevemente la revisión realizada y la decisión tomada."
              rows={4}
              disabled={isProcessing}
            />
          </div>
          <button className="clinical-task-card__action" type="button" disabled={isProcessing} onClick={() => onCloseTask(task)}>
            <Check size={17} strokeWidth={2} aria-hidden="true" />
            <span>{isProcessing ? 'Cerrando...' : 'Cerrar tarea'}</span>
          </button>
        </div>
      )}

      {task.status === 'closed' && (
        <div className="clinical-task-card__closed">
          {task.finalDecision && <p>Decisión: <strong>{decisionLabels[task.finalDecision]}</strong></p>}
          {task.reviewNote && <p>Nota de revisión: {task.reviewNote}</p>}
        </div>
      )}
    </article>
  )
}

export default ProfessionalTasksPage
