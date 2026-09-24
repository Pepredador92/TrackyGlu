import fs from 'node:fs'
import path from 'node:path'

const root = path.resolve(new URL('..', import.meta.url).pathname)
const workflowDir = path.join(root, 'workflows/n8n')
const expected = [
  'Flow-ADH-01_MedirAdherencia.json',
  'Flow-ALR-01_TriageAlertas.json',
  'Flow-ALR-02_AlertStatusChanged.json',
  'Flow-CLN-01_WorkQueueClinica.json',
  'Flow-CLN-02_ClinicalTaskStatusChanged.json',
  'Flow-CLN-03_PrepararCasoClinico.json',
  'Flow-CLN-04_GenerarBorradorIA.json',
  'Flow-ING-01_GlucoseReadingCreated.json',
]
const expectedTables = new Set(['workflow_runs', 'events', 'glucose_readings', 'glucose_daily_context', 'adherence_summary', 'alerts', 'clinical_tasks', 'clinical_case_contexts', 'clinical_guideline_sources', 'clinical_task_drafts', 'clinical_task_draft_revisions', 'professional_patients', 'patient_histories', 'professionals'])
const webhookPaths = new Set()

for (const file of expected) {
  const filePath = path.join(workflowDir, file)
  if (!fs.existsSync(filePath)) throw new Error(`Falta ${file}`)
  const workflow = JSON.parse(fs.readFileSync(filePath, 'utf8'))
  if (!workflow.name || !workflow.nodes?.length) throw new Error(`${file}: workflow incompleto`)

  for (const node of workflow.nodes) {
    const table = node.parameters?.tableId
    if (table && !expectedTables.has(table)) throw new Error(`${file}: tabla no documentada ${table}`)
    if (node.type === 'n8n-nodes-base.supabase' && !node.credentials?.supabaseApi) throw new Error(`${file}: nodo Supabase sin referencia de credencial`)
    if (node.type === 'n8n-nodes-base.webhook') {
      const webhookPath = node.parameters?.path
      if (!webhookPath || webhookPaths.has(webhookPath)) throw new Error(`${file}: ruta webhook ausente o duplicada`)
      webhookPaths.add(webhookPath)
    }
  }

  if (file === 'Flow-ADH-01_MedirAdherencia.json') {
    const code = workflow.nodes.find((node) => node.name === 'CODE_ComputeAdherence')?.parameters?.jsCode ?? ''
    for (const field of ['complete_days', 'completeness_pct', 'expected_readings', 'slot_coverage_pct', 'daily_slots']) {
      if (!code.includes(field)) throw new Error(`${file}: falta salida ${field}`)
    }
    for (const nodeName of ['Get Latest Reading', 'Get Recent Readings']) {
      const conditions = workflow.nodes.find((node) => node.name === nodeName)?.parameters?.filters?.conditions ?? []
      for (const keyName of ['quality_state', 'processing_state']) {
        if (!conditions.some((condition) => condition.keyName === keyName)) throw new Error(`${file}: ${nodeName} no filtra ${keyName}`)
      }
    }
  }

  if (file === 'Flow-CLN-03_PrepararCasoClinico.json') {
    const names = new Set(workflow.nodes.map((node) => node.name))
    for (const nodeName of ['Get Source Alert', 'Get Patient History', 'Get Recent Readings', 'Get Recent Daily Context', 'Get Adherence Summaries', 'Get Active Professional Link', 'Assemble Clinical Case Context', 'Create Clinical Case Context']) {
      if (!names.has(nodeName)) throw new Error(`${file}: falta el nodo ${nodeName}`)
    }
    const assembly = workflow.nodes.find((node) => node.name === 'Assemble Clinical Case Context')?.parameters?.jsCode ?? ''
    for (const field of ['context_version', 'missing_data', 'recent_readings', 'adherence_summaries', 'waiting_professional']) {
      if (!assembly.includes(field)) throw new Error(`${file}: falta evidencia ${field}`)
    }
  }

  if (file === 'Flow-CLN-04_GenerarBorradorIA.json') {
    const names = new Set(workflow.nodes.map((node) => node.name))
    for (const nodeName of ['Get Clinical Case Context', 'Get Approved Clinical Sources', 'Build Grounded Clinical Prompt', 'OpenAI Responses - Structured Output', 'Validate Structured AI Draft', 'Create AI Draft', 'Mark Task Draft Ready']) {
      if (!names.has(nodeName)) throw new Error(`${file}: falta el nodo ${nodeName}`)
    }
    const prompt = workflow.nodes.find((node) => node.name === 'Build Grounded Clinical Prompt')?.parameters?.jsCode ?? ''
    for (const field of ['source_registry', 'draft_text', 'suggested_review_actions', 'json_schema', 'clinical-support-v1']) {
      if (!prompt.includes(field)) throw new Error(`${file}: falta contrato de prompt ${field}`)
    }
  }
}

console.log(`✓ ${expected.length} workflows válidos; ${webhookPaths.size} rutas webhook únicas; referencias de credenciales presentes.`)
