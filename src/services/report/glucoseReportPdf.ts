import { jsPDF } from 'jspdf'
import type { GlucoseMetrics } from '../glucose/glucoseMetrics'
import { METRIC_CONTEXT_LABELS } from '../glucose/glucoseMetrics'
import type { HistoryReview, PatientHistory } from '../../types/clinicalHistory'
import type { GlucoseReading } from '../../types/glucose'

interface GlucoseReportOptions {
  patientName: string
  patientId?: string
  history: PatientHistory | null
  readings: GlucoseReading[]
  metrics: GlucoseMetrics
  professionalName?: string
  professionalSpecialty?: string
  reviews?: HistoryReview[]
  reportRole: 'patient' | 'professional'
  periodLabel?: string
}

const PAGE_WIDTH = 595.28
const PAGE_HEIGHT = 841.89
const MARGIN = 34
const CONTENT_WIDTH = PAGE_WIDTH - MARGIN * 2
const COLORS = {
  ink: [28, 60, 52] as [number, number, number],
  muted: [99, 117, 109] as [number, number, number],
  green: [39, 117, 95] as [number, number, number],
  pale: [239, 246, 240] as [number, number, number],
  line: [216, 228, 220] as [number, number, number],
  low: [183, 82, 76] as [number, number, number],
  range: [73, 143, 103] as [number, number, number],
  high: [207, 145, 54] as [number, number, number],
  white: [255, 255, 255] as [number, number, number],
}

function safeText(value: string): string {
  return value.replace(/[–—]/g, '-').replace(/•/g, '*')
}

function textValue(value: unknown, fallback = 'No registrado'): string {
  if (typeof value !== 'string' || !value.trim()) return fallback
  return safeText(value.trim())
}

function formatDate(dateInput: string | null | undefined, withTime = false): string {
  if (!dateInput) return 'No registrado'
  const date = new Date(dateInput)
  if (!Number.isFinite(date.getTime())) return 'No registrado'
  return new Intl.DateTimeFormat('es-MX', withTime ? { dateStyle: 'short', timeStyle: 'short' } : { dateStyle: 'medium' }).format(date)
}

function formatMetric(value: number | null, suffix = ''): string {
  return value === null ? 'Sin datos' : `${value}${suffix}`
}

function ageFromBirthDate(birthDate: string | undefined): string {
  if (!birthDate) return 'No registrado'
  const birth = new Date(`${birthDate}T00:00:00`)
  if (!Number.isFinite(birth.getTime())) return 'No registrado'
  const now = new Date()
  let age = now.getFullYear() - birth.getFullYear()
  const beforeBirthday = now.getMonth() < birth.getMonth() || (now.getMonth() === birth.getMonth() && now.getDate() < birth.getDate())
  if (beforeBirthday) age -= 1
  return age >= 0 ? `${age} años` : 'No registrado'
}

function historyLabel(value: unknown, labels: Record<string, string>): string {
  if (typeof value !== 'string' || !value) return 'No registrado'
  return safeText(labels[value] ?? value)
}

function zoneColor(value: number): [number, number, number] {
  if (value < 70) return COLORS.low
  if (value > 180) return COLORS.high
  return COLORS.range
}

function setFont(doc: jsPDF, size: number, color = COLORS.ink, style: 'normal' | 'bold' = 'normal') {
  doc.setFont('helvetica', style)
  doc.setFontSize(size)
  doc.setTextColor(...color)
}

function writeWrapped(doc: jsPDF, value: string, x: number, y: number, width: number, size = 8, color = COLORS.ink, style: 'normal' | 'bold' = 'normal'): number {
  setFont(doc, size, color, style)
  const lines = doc.splitTextToSize(safeText(value), width) as string[]
  doc.text(lines, x, y)
  return y + lines.length * (size * 0.42)
}

function roundedBox(doc: jsPDF, x: number, y: number, width: number, height: number, fill: [number, number, number], stroke = COLORS.line, radius = 5) {
  doc.setFillColor(...fill)
  doc.setDrawColor(...stroke)
  doc.roundedRect(x, y, width, height, radius, radius, 'FD')
}

function sectionTitle(doc: jsPDF, title: string, y: number): number {
  setFont(doc, 10.5, COLORS.ink, 'bold')
  doc.text(safeText(title), MARGIN, y)
  doc.setDrawColor(...COLORS.line)
  doc.line(MARGIN, y + 5, PAGE_WIDTH - MARGIN, y + 5)
  return y + 18
}

function drawHeader(doc: jsPDF, options: GlucoseReportOptions): number {
  doc.setFillColor(...COLORS.green)
  doc.rect(0, 0, PAGE_WIDTH, 64, 'F')
  setFont(doc, 19, COLORS.white, 'bold')
  doc.text('TrackyGlu', MARGIN, 26)
  setFont(doc, 11, COLORS.white, 'bold')
  doc.text('Reporte de seguimiento de glucosa', MARGIN, 43)
  setFont(doc, 7.5, [226, 241, 231], 'normal')
  doc.text(options.reportRole === 'professional' ? 'Vista preparada para revisión profesional' : 'Resumen personal de seguimiento', MARGIN, 55)
  setFont(doc, 7.5, COLORS.white, 'normal')
  doc.text(`Generado: ${formatDate(new Date().toISOString(), true)}`, PAGE_WIDTH - MARGIN, 26, { align: 'right' })
  doc.text(`Periodo: ${safeText(options.periodLabel ?? `Últimos ${options.metrics.windowDays} días`)}`, PAGE_WIDTH - MARGIN, 39, { align: 'right' })
  return 86
}

function drawPatientData(doc: jsPDF, options: GlucoseReportOptions, y: number): number {
  const history = options.history?.data
  y = sectionTitle(doc, 'Datos del paciente', y)
  const boxHeight = 66
  roundedBox(doc, MARGIN, y, CONTENT_WIDTH, boxHeight, COLORS.pale)
  const column = CONTENT_WIDTH / 3
  const rows: Array<[string, string]> = [
    ['Paciente', options.patientName],
    ['Edad', ageFromBirthDate(history?.birthDate)],
    ['Sexo', historyLabel(history?.sex, { female: 'Mujer', male: 'Hombre', other: 'Otro', prefer_not_to_say: 'No especificado' })],
    ['Diabetes', historyLabel(history?.diabetesType, { type_1: 'Tipo 1', type_2: 'Tipo 2', gestational: 'Gestacional', other: 'Otro tipo', unknown: 'No lo sé' })],
    ['Diagnóstico', history?.diagnosisYear || 'No registrado'],
    ['Tratamiento', historyLabel(history?.treatmentStatus, { none: 'Sin medicamentos', medication: 'Medicamentos', insulin: 'Insulina', both: 'Insulina y medicamentos', unknown: 'Por confirmar' })],
  ]
  rows.forEach(([label, value], index) => {
    const col = index % 3
    const row = Math.floor(index / 3)
    const x = MARGIN + 14 + col * column
    const rowY = y + 19 + row * 25
    setFont(doc, 7, COLORS.muted, 'normal')
    doc.text(safeText(label.toUpperCase()), x, rowY)
    writeWrapped(doc, textValue(value), x, rowY + 10, column - 22, 8.2, COLORS.ink, 'bold')
  })
  return y + boxHeight + 17
}

function drawMetricCards(doc: jsPDF, metrics: GlucoseMetrics, y: number): number {
  y = sectionTitle(doc, 'Indicadores del periodo', y)
  const cards = [
    ['Lecturas', String(metrics.totalReadings), `${metrics.daysWithReading}/${metrics.windowDays} días`],
    ['Promedio', formatMetric(metrics.mean), 'mg/dL'],
    ['En rango', formatMetric(metrics.inGeneralRangePct, '%'), '70-180 mg/dL'],
    ['Continuidad', formatMetric(metrics.continuityPct, '%'), 'días con lectura'],
    ['Completitud', formatMetric(metrics.completenessPct, '%'), 'días con 3 franjas'],
  ]
  const gap = 7
  const width = (CONTENT_WIDTH - gap * (cards.length - 1)) / cards.length
  cards.forEach(([label, value, detail], index) => {
    const x = MARGIN + index * (width + gap)
    roundedBox(doc, x, y, width, 51, COLORS.white)
    setFont(doc, 7, COLORS.muted, 'normal')
    doc.text(safeText(label.toUpperCase()), x + 8, y + 13)
    setFont(doc, 14, COLORS.ink, 'bold')
    doc.text(safeText(value), x + 8, y + 31)
    setFont(doc, 6.5, COLORS.muted, 'normal')
    doc.text(safeText(detail), x + 8, y + 43)
  })
  return y + 67
}

function drawTrendChart(doc: jsPDF, metrics: GlucoseMetrics, x: number, y: number, width: number, height: number) {
  roundedBox(doc, x, y, width, height, COLORS.white)
  setFont(doc, 8.5, COLORS.ink, 'bold')
  doc.text('Tendencia diaria', x + 10, y + 16)
  setFont(doc, 6.5, COLORS.muted)
  doc.text('Promedio por día y zonas de glucosa', x + 10, y + 27)
  const plot = { left: x + 24, right: x + width - 10, top: y + 38, bottom: y + height - 20 }
  const values = metrics.series.filter((point) => point.value !== null).map((point) => point.value as number)
  const min = Math.min(40, ...(values.length ? values : [40]))
  const max = Math.max(220, ...(values.length ? values : [220]))
  const px = (index: number) => plot.left + index / Math.max(metrics.series.length - 1, 1) * (plot.right - plot.left)
  const py = (value: number) => plot.top + (max - value) / Math.max(max - min, 1) * (plot.bottom - plot.top)
  const y180 = py(180)
  const y70 = py(70)
  doc.setFillColor(252, 239, 236); doc.rect(plot.left, plot.top, plot.right - plot.left, Math.max(y180 - plot.top, 0), 'F')
  doc.setFillColor(239, 248, 240); doc.rect(plot.left, y180, plot.right - plot.left, Math.max(y70 - y180, 0), 'F')
  doc.setFillColor(253, 245, 228); doc.rect(plot.left, y70, plot.right - plot.left, Math.max(plot.bottom - y70, 0), 'F')
  doc.setDrawColor(...COLORS.line); doc.setLineWidth(0.3)
  ;[70, 180].forEach((value) => { const guideY = py(value); doc.line(plot.left, guideY, plot.right, guideY); setFont(doc, 5.5, COLORS.muted); doc.text(String(value), x + 5, guideY + 2) })
  let previous: { x: number; y: number } | null = null
  metrics.series.forEach((point, index) => {
    if (point.value === null) { previous = null; return }
    const current = { x: px(index), y: py(point.value) }
    if (previous) { doc.setDrawColor(...COLORS.green); doc.setLineWidth(1.2); doc.line(previous.x, previous.y, current.x, current.y) }
    doc.setFillColor(...zoneColor(point.value)); doc.setDrawColor(...COLORS.white); doc.circle(current.x, current.y, 2.4, 'FD')
    previous = current
    if (index === 0 || index % Math.max(1, Math.ceil(metrics.series.length / 5)) === 0 || index === metrics.series.length - 1) { setFont(doc, 5.5, COLORS.muted); doc.text(point.day.slice(5), current.x, plot.bottom + 10, { align: 'center' }) }
  })
  if (!values.length) { setFont(doc, 7, COLORS.muted); doc.text('Sin lecturas en este periodo', (plot.left + plot.right) / 2, (plot.top + plot.bottom) / 2, { align: 'center' }) }
}

function drawCompletenessChart(doc: jsPDF, metrics: GlucoseMetrics, x: number, y: number, width: number, height: number) {
  roundedBox(doc, x, y, width, height, COLORS.white)
  setFont(doc, 8.5, COLORS.ink, 'bold')
  doc.text('Continuidad y completitud', x + 10, y + 16)
  setFont(doc, 6.5, COLORS.muted)
  doc.text(`${metrics.completeDays} de ${metrics.windowDays} días con mañana, tarde y noche`, x + 10, y + 27)
  const plot = { left: x + 23, right: x + width - 10, top: y + 42, bottom: y + height - 22 }
  const step = (plot.right - plot.left) / Math.max(metrics.dailyCompleteness.length, 1)
  const cell = Math.max(2.2, Math.min(9, step - 1.8))
  const rowHeight = (plot.bottom - plot.top) / 3
  metrics.dailyCompleteness.forEach((day, index) => {
    const cellX = plot.left + index * step + (step - cell) / 2
    const flags = [day.morning, day.afternoon, day.night]
    flags.forEach((active, row) => {
      doc.setFillColor(...(active ? [95, 157, 114] as [number, number, number] : [235, 239, 235] as [number, number, number]))
      doc.roundedRect(cellX, plot.top + row * rowHeight, cell, Math.max(2, rowHeight - 2), 1, 1, 'F')
    })
    if (index === 0 || index % Math.max(1, Math.ceil(metrics.dailyCompleteness.length / 5)) === 0 || index === metrics.dailyCompleteness.length - 1) { setFont(doc, 5.5, COLORS.muted); doc.text(day.day.slice(5), cellX + cell / 2, plot.bottom + 10, { align: 'center' }) }
  })
  setFont(doc, 5.5, COLORS.muted)
  doc.text('M', x + 8, plot.top + 4); doc.text('T', x + 8, plot.top + rowHeight + 4); doc.text('N', x + 8, plot.top + rowHeight * 2 + 4)
}

function drawZones(doc: jsPDF, metrics: GlucoseMetrics, y: number): number {
  y = sectionTitle(doc, 'Distribución por zona', y)
  const zones = [
    ['Baja', metrics.lowPct, '<70 mg/dL', COLORS.low],
    ['En rango', metrics.inGeneralRangePct, '70-180 mg/dL', COLORS.range],
    ['Alta', metrics.highPct, '>180 mg/dL', COLORS.high],
  ] as const
  zones.forEach(([label, value, description, color], index) => {
    const rowY = y + index * 24
    setFont(doc, 7.5, COLORS.ink, 'bold'); doc.text(label, MARGIN, rowY + 7)
    setFont(doc, 6.5, COLORS.muted); doc.text(description, MARGIN + 50, rowY + 7)
    doc.setFillColor(236, 240, 236); doc.roundedRect(MARGIN + 125, rowY, CONTENT_WIDTH - 180, 12, 3, 3, 'F')
    if (value !== null) { doc.setFillColor(...color); doc.roundedRect(MARGIN + 125, rowY, (CONTENT_WIDTH - 180) * Math.min(value, 100) / 100, 12, 3, 3, 'F') }
    setFont(doc, 7.5, COLORS.ink, 'bold'); doc.text(formatMetric(value, '%'), PAGE_WIDTH - MARGIN, rowY + 8, { align: 'right' })
  })
  return y + 82
}

function drawProfessionalNotes(doc: jsPDF, options: GlucoseReportOptions, y: number): number {
  y = sectionTitle(doc, 'Indicaciones y notas profesionales', y)
  const latestReview = options.reviews?.[0]
  const note = latestReview?.note?.trim() || 'No hay indicaciones profesionales registradas para este periodo.'
  const compactNote = note.length > 650 ? `${note.slice(0, 647).trim()}...` : note
  const noteLines = doc.splitTextToSize(safeText(compactNote), CONTENT_WIDTH - 24) as string[]
  const boxHeight = Math.max(46, 23 + noteLines.length * 4.2 + (latestReview ? 14 : 0))
  roundedBox(doc, MARGIN, y, CONTENT_WIDTH, boxHeight, [250, 252, 249])
  setFont(doc, 8, COLORS.ink)
  doc.text(noteLines, MARGIN + 12, y + 17)
  if (latestReview) { setFont(doc, 6.5, COLORS.muted); doc.text(`Revisión de historia v${latestReview.history_revision} - ${formatDate(latestReview.reviewed_at, true)}`, MARGIN + 12, y + boxHeight - 10) }
  return y + boxHeight + 16
}

function drawRecentReadings(doc: jsPDF, readings: GlucoseReading[], y: number): number {
  y = sectionTitle(doc, 'Lecturas recientes', y)
  const recent = [...readings].sort((a, b) => b.timestamp.localeCompare(a.timestamp)).slice(0, 6)
  const headers = ['Fecha y hora', 'Contexto', 'Glucosa', 'Zona']
  const widths = [145, 175, 75, CONTENT_WIDTH - 395]
  let x = MARGIN
  setFont(doc, 6.5, COLORS.muted, 'bold')
  headers.forEach((header, index) => { doc.text(header, x, y); x += widths[index] })
  doc.setDrawColor(...COLORS.line); doc.line(MARGIN, y + 4, PAGE_WIDTH - MARGIN, y + 4)
  recent.forEach((reading, index) => {
    const rowY = y + 17 + index * 17
    x = MARGIN
    setFont(doc, 7, COLORS.ink); doc.text(formatDate(reading.timestamp, true), x, rowY); x += widths[0]
    doc.text(safeText(METRIC_CONTEXT_LABELS[reading.measurementContext] ?? reading.measurementContext), x, rowY); x += widths[1]
    doc.text(`${reading.glucoseValue} ${safeText(reading.unit)}`, x, rowY); x += widths[2]
    const zone = reading.glucoseValue < 70 ? 'Baja' : reading.glucoseValue > 180 ? 'Alta' : 'En rango'
    setFont(doc, 7, zone === 'Baja' ? COLORS.low : zone === 'Alta' ? COLORS.high : COLORS.range, 'bold'); doc.text(zone, x, rowY)
  })
  if (!recent.length) { setFont(doc, 7, COLORS.muted); doc.text('No hay lecturas para mostrar.', MARGIN, y + 18) }
  return y + 28 + recent.length * 17
}

export function generateGlucoseReportPdf(options: GlucoseReportOptions): void {
  const doc = new jsPDF({ unit: 'pt', format: 'a4', compress: true })
  let y = drawHeader(doc, options)
  y = drawPatientData(doc, options, y)
  if (options.professionalName) {
    setFont(doc, 7.5, COLORS.muted)
    doc.text(`Profesional: ${safeText(options.professionalName)}${options.professionalSpecialty ? ` · ${safeText(options.professionalSpecialty)}` : ''}`, MARGIN, y - 5)
    y += 9
  }
  y = drawMetricCards(doc, options.metrics, y)
  const chartGap = 10
  const chartWidth = (CONTENT_WIDTH - chartGap) / 2
  drawTrendChart(doc, options.metrics, MARGIN, y, chartWidth, 154)
  drawCompletenessChart(doc, options.metrics, MARGIN + chartWidth + chartGap, y, chartWidth, 154)
  y += 171
  y = drawZones(doc, options.metrics, y)
  y = drawProfessionalNotes(doc, options, y)
  if (y > PAGE_HEIGHT - 110) { doc.addPage(); y = 54 }
  drawRecentReadings(doc, options.readings, y)

  const totalPages = doc.getNumberOfPages()
  for (let page = 1; page <= totalPages; page += 1) {
    doc.setPage(page)
    setFont(doc, 6.5, COLORS.muted)
    doc.text('TrackyGlu · Reporte descriptivo de registros · No sustituye la valoración clínica', MARGIN, PAGE_HEIGHT - 22)
    doc.text(`Página ${page} de ${totalPages}`, PAGE_WIDTH - MARGIN, PAGE_HEIGHT - 22, { align: 'right' })
  }

  const date = new Date().toISOString().slice(0, 10)
  const filenameName = options.patientName.toLocaleLowerCase('es').replace(/[^a-z0-9]+/gi, '-').replace(/^-|-$/g, '') || 'paciente'
  doc.save(`trackyglu-reporte-${filenameName}-${date}.pdf`)
}
