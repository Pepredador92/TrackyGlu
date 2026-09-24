import { ArrowLeft, Bot, Check, FileSearch, LogOut, Play, Save, Trash2, X } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from '../../components/auth/useAuth'
import {
  closeClinicalTask,
  getProfessionalClinicalTasks,
  reviewClinicalAiDraft,
  startClinicalTaskReview,
} from '../../services/clinicalTaskService'
import type {
  ClinicalCaseContext,
  ClinicalAiDraftReviewStatus,
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
  cancelled: 'Eliminada',
}

const contextStatusLabels: Record<ClinicalCaseContext['status'], string> = {
  prepared: 'Contexto completo',
  partial: 'Contexto parcial',
  waiting_professional: 'Pendiente de profesional',
  failed: 'No disponible',
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
  const [notes, setNotes] = useState<Record<string, string>>({})
  const [draftTexts, setDraftTexts] = useState<Record<string, string>>({})

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

  async function handleCloseTask(
    task: ProfessionalClinicalTask,
    decision: 'approved' | 'cancelled',
  ) {
    const reviewNote = notes[task.id] ?? ''

    if (!reviewNote.trim()) {
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
      setSuccessMessage(decision === 'approved' ? 'Tarea aprobada y cerrada correctamente.' : 'Tarea eliminada de la cola activa.')
    } catch (error) {
      console.error('Could not close clinical task', error)
      setOperationError(true)
    } finally {
      setProcessingTaskId(null)
    }
  }

  async function handleReviewAiDraft(task: ProfessionalClinicalTask, status: ClinicalAiDraftReviewStatus) {
    if (!task.aiDraft) return
    const draftText = draftTexts[task.id] ?? task.aiDraft.draftText ?? ''
    setProcessingTaskId(task.id)
    setOperationError(false)
    setSuccessMessage('')

    try {
      await reviewClinicalAiDraft(task.aiDraft.id, status, draftText, notes[task.id])
      await loadTasks()
      setSuccessMessage(status === 'discarded' ? 'Borrador descartado. La tarea sigue disponible para revisión.' : 'Borrador guardado para revisión profesional.')
    } catch (error) {
      console.error('Could not review clinical AI draft', error)
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
                note={notes[task.id] ?? ''}
                draftText={draftTexts[task.id] ?? task.aiDraft?.draftText ?? ''}
                isProcessing={processingTaskId === task.id}
                onNoteChange={(value) => setNotes((current) => ({ ...current, [task.id]: value }))}
                onDraftTextChange={(value) => setDraftTexts((current) => ({ ...current, [task.id]: value }))}
                onStartReview={handleStartReview}
                onReviewAiDraft={handleReviewAiDraft}
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
  note,
  draftText,
  isProcessing,
  onNoteChange,
  onDraftTextChange,
  onStartReview,
  onReviewAiDraft,
  onCloseTask,
}: {
  task: ProfessionalClinicalTask
  note: string
  draftText: string
  isProcessing: boolean
  onNoteChange: (value: string) => void
  onDraftTextChange: (value: string) => void
  onStartReview: (taskId: string) => void
  onReviewAiDraft: (task: ProfessionalClinicalTask, status: ClinicalAiDraftReviewStatus) => void
  onCloseTask: (task: ProfessionalClinicalTask, decision: 'approved' | 'cancelled') => void
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
      {task.caseContext && <ClinicalCaseContextSummary context={task.caseContext} />}
      {task.aiDraft && <ClinicalAiDraftEditor task={task} draftText={draftText} isProcessing={isProcessing} onDraftTextChange={onDraftTextChange} onReviewAiDraft={onReviewAiDraft} />}
      <p className="clinical-task-card__date">
        Creada: <time dateTime={task.createdAt}>{dateTimeFormatter.format(new Date(task.createdAt))}</time>
      </p>
      {task.firstReviewAt && <p className="clinical-task-card__date">Primera revisión: {dateTimeFormatter.format(new Date(task.firstReviewAt))}</p>}
      {task.closedAt && <p className="clinical-task-card__date">Cerrada: {dateTimeFormatter.format(new Date(task.closedAt))}</p>}

      {(task.status === 'pending_review' || task.status === 'draft_ready') && (
        <button className="clinical-task-card__action" type="button" disabled={isProcessing} onClick={() => onStartReview(task.id)}>
          <Play size={17} strokeWidth={2} aria-hidden="true" />
          <span>{isProcessing ? 'Iniciando...' : 'Iniciar revisión'}</span>
        </button>
      )}

      {task.status === 'in_review' && (
        <div className="clinical-task-card__form">
          <div className="clinical-task-card__field">
            <label htmlFor={`note-${task.id}`}>Nota de revisión</label>
            <textarea
              id={`note-${task.id}`}
              value={note}
              onChange={(event) => onNoteChange(event.target.value)}
              placeholder="Escribe o edita libremente la nota de revisión antes de tomar una decisión."
              rows={5}
              disabled={isProcessing}
            />
            <p className="clinical-task-card__field-help">
              El texto es libre y puede modificarse antes de aprobar o eliminar la tarea de la cola activa.
            </p>
          </div>

          <div className="clinical-task-card__decision-actions" aria-label="Decisión sobre la tarea">
            <button
              className="clinical-task-card__decision-button clinical-task-card__decision-button--approve"
              type="button"
              disabled={isProcessing || !note.trim()}
              onClick={() => onCloseTask(task, 'approved')}
            >
              <Check size={17} strokeWidth={2} aria-hidden="true" />
              <span>{isProcessing ? 'Procesando...' : 'Aprobar'}</span>
            </button>
            <button
              className="clinical-task-card__decision-button clinical-task-card__decision-button--delete"
              type="button"
              disabled={isProcessing || !note.trim()}
              onClick={() => onCloseTask(task, 'cancelled')}
            >
              <Trash2 size={17} strokeWidth={2} aria-hidden="true" />
              <span>{isProcessing ? 'Procesando...' : 'Eliminar'}</span>
            </button>
          </div>
          <p className="clinical-task-card__decision-note">
            Eliminar no borra el registro: lo cierra como cancelado para conservar la trazabilidad.
          </p>
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

function ClinicalAiDraftEditor({
  task,
  draftText,
  isProcessing,
  onDraftTextChange,
  onReviewAiDraft,
}: {
  task: ProfessionalClinicalTask
  draftText: string
  isProcessing: boolean
  onDraftTextChange: (value: string) => void
  onReviewAiDraft: (task: ProfessionalClinicalTask, status: ClinicalAiDraftReviewStatus) => void
}) {
  const draft = task.aiDraft
  if (!draft) return null

  if (draft.status === 'failed') {
    return (
      <section className="clinical-task-card__ai-draft clinical-task-card__ai-draft--failed" aria-label="Borrador de apoyo con IA">
        <div className="clinical-task-card__ai-heading"><Bot size={17} strokeWidth={2} aria-hidden="true" /><strong>Apoyo con IA no disponible</strong></div>
        <p>{draft.errorMessage || 'No fue posible generar el borrador. La revisión profesional continúa disponible.'}</p>
      </section>
    )
  }

  if (!draft.draftText || draft.status === 'discarded') return null

  return (
    <section className="clinical-task-card__ai-draft" aria-label="Borrador de apoyo con IA">
      <div className="clinical-task-card__ai-heading">
        <Bot size={17} strokeWidth={2} aria-hidden="true" />
        <strong>Borrador de apoyo para editar</strong>
        <span>{draft.status === 'approved' ? 'Marcado como aprobado' : `Fuente ${draft.promptVersion}`}</span>
      </div>
      <p className="clinical-task-card__ai-help">La IA organiza la evidencia disponible. El profesional decide, corrige o descarta el texto antes de cerrar la tarea.</p>
      <textarea
        value={draftText}
        onChange={(event) => onDraftTextChange(event.target.value)}
        rows={8}
        disabled={isProcessing}
        aria-label="Borrador editable de apoyo clínico"
      />
      <div className="clinical-task-card__ai-actions">
        <button type="button" disabled={isProcessing || !draftText.trim()} onClick={() => onReviewAiDraft(task, 'edited')}>
          <Save size={16} strokeWidth={2} aria-hidden="true" />
          <span>Guardar cambios</span>
        </button>
        <button type="button" disabled={isProcessing || !draftText.trim()} onClick={() => onReviewAiDraft(task, 'approved')}>
          <Check size={16} strokeWidth={2} aria-hidden="true" />
          <span>Aprobar borrador</span>
        </button>
        <button type="button" className="clinical-task-card__ai-discard" disabled={isProcessing} onClick={() => onReviewAiDraft(task, 'discarded')}>
          <X size={16} strokeWidth={2} aria-hidden="true" />
          <span>Descartar</span>
        </button>
      </div>
    </section>
  )
}

function ClinicalCaseContextSummary({ context }: { context: ClinicalCaseContext }) {
  const summaries = context.snapshot.adherence_summaries
  const latestSummary = summaries.find((summary) => Number(summary.window_days) === 30) ?? summaries[0]
  const historyRevision = context.snapshot.history?.revision
  const continuity = latestSummary?.adherence_pct
  const completeness = latestSummary?.completeness_pct

  return (
    <section className="clinical-task-card__context" aria-label="Contexto clínico preparado">
      <div className="clinical-task-card__context-heading">
        <FileSearch size={17} strokeWidth={2} aria-hidden="true" />
        <strong>Contexto reunido para revisión</strong>
        <span>{contextStatusLabels[context.status]}</span>
      </div>
      <div className="clinical-task-card__context-facts">
        <span>{context.snapshot.recent_readings.length} lecturas en 30 días</span>
        {historyRevision !== undefined && <span>Historia v{historyRevision}</span>}
        {typeof continuity === 'number' && <span>Continuidad {continuity}%</span>}
        {typeof completeness === 'number' && <span>Completitud {completeness}%</span>}
      </div>
      {context.missingData.length > 0 && (
        <p className="clinical-task-card__context-missing">
          Datos por confirmar: {context.missingData.join(', ')}.
        </p>
      )}
    </section>
  )
}

export default ProfessionalTasksPage
