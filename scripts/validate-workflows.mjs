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
  'Flow-ING-01_GlucoseReadingCreated.json',
]
const expectedTables = new Set(['workflow_runs', 'events', 'glucose_readings', 'adherence_summary', 'alerts', 'clinical_tasks', 'professionals'])
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
}

console.log(`✓ ${expected.length} workflows válidos; ${webhookPaths.size} rutas webhook únicas; referencias de credenciales presentes.`)
