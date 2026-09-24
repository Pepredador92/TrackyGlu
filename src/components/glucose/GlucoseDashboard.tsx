import { Activity, BarChart3, CalendarDays, CheckCircle2, CircleAlert, Gauge, TrendingDown, TrendingUp } from 'lucide-react'
import type { GlucoseMetrics } from '../../services/glucose/glucoseMetrics'
import { METRIC_CONTEXT_LABELS } from '../../services/glucose/glucoseMetrics'
import './GlucoseDashboard.css'

function formatMetric(value: number | null, suffix = ''): string {
  return value === null ? 'Sin datos' : `${value}${suffix}`
}

export function MetricsCards({ metrics, compact = false }: { metrics: GlucoseMetrics; compact?: boolean }) {
  const cards = [
    { label: 'Lecturas', value: String(metrics.totalReadings), detail: `${metrics.daysWithReading}/${metrics.windowDays} días con registro`, icon: Activity },
    { label: 'Promedio', value: formatMetric(metrics.mean), detail: 'mg/dL · descriptivo', icon: Gauge },
    { label: 'En rango general', value: formatMetric(metrics.inGeneralRangePct, '%'), detail: '70–180 mg/dL', icon: TrendingUp },
    { label: 'Continuidad', value: formatMetric(metrics.continuityPct, '%'), detail: 'días con ≥1 lectura', icon: CalendarDays },
    { label: 'Completitud', value: formatMetric(metrics.completenessPct, '%'), detail: 'días con 3 franjas', icon: CheckCircle2 },
  ]
  return <div className={`metrics-cards${compact ? ' metrics-cards--compact' : ''}`}>{cards.map(({ label, value, detail, icon: Icon }) => <article className="metric-card" key={label}><span className="metric-card__icon"><Icon size={18} /></span><div><span className="metric-card__label">{label}</span><strong>{value}</strong><small>{detail}</small></div></article>)}</div>
}

export function MetricDetails({ metrics }: { metrics: GlucoseMetrics }) {
  const contextEntries = Object.entries(metrics.contextCounts)
  return <div className="metric-details"><div><span>Más baja</span><strong>{formatMetric(metrics.minimum)} {metrics.minimum !== null && 'mg/dL'}</strong></div><div><span>Más alta</span><strong>{formatMetric(metrics.maximum)} {metrics.maximum !== null && 'mg/dL'}</strong></div><div><span>Variabilidad</span><strong>{formatMetric(metrics.coefficientOfVariation, '%')}</strong><small>CV descriptivo</small></div><div><span>Racha actual</span><strong>{metrics.currentStreakDays} {metrics.currentStreakDays === 1 ? 'día' : 'días'}</strong></div><div><span>Brecha máxima</span><strong>{metrics.longestGapDays} {metrics.longestGapDays === 1 ? 'día' : 'días'}</strong><small>sin registro</small></div><div><span>Cobertura de franjas</span><strong>{formatMetric(metrics.slotCoveragePct, '%')}</strong><small>{metrics.totalReadings}/{metrics.expectedReadings} lecturas esperadas</small></div><div><span>Por debajo de 70</span><strong>{formatMetric(metrics.lowPct, '%')}</strong><small>{metrics.lowPct !== null ? 'de las lecturas' : 'sin lecturas'}</small></div><div><span>Por encima de 180</span><strong>{formatMetric(metrics.highPct, '%')}</strong><small>{metrics.highPct !== null ? 'de las lecturas' : 'sin lecturas'}</small></div>{contextEntries.length > 0 && <div className="metric-context-list"><span>Contextos registrados</span><p>{contextEntries.map(([key, count]) => `${METRIC_CONTEXT_LABELS[key as keyof typeof METRIC_CONTEXT_LABELS] ?? key}: ${count}`).join(' · ')}</p></div>}</div>
}

function zoneForValue(value: number): 'low' | 'in-range' | 'high' {
  if (value < 70) return 'low'
  if (value > 180) return 'high'
  return 'in-range'
}

export function GlucoseTrendChart({ metrics, title = 'Tendencia de glucosa' }: { metrics: GlucoseMetrics; title?: string }) {
  const points = metrics.series.filter((point) => point.value !== null)
  const width = 720
  const height = 250
  const padding = { left: 42, right: 18, top: 20, bottom: 32 }
  const values = points.map((point) => point.value as number)
  const min = Math.min(40, ...(values.length ? values : [40]))
  const max = Math.max(220, ...(values.length ? values : [220]))
  const plotBottom = height - padding.bottom
  const x = (index: number) => padding.left + (index / Math.max(metrics.series.length - 1, 1)) * (width - padding.left - padding.right)
  const y = (value: number) => padding.top + ((max - value) / Math.max(max - min, 1)) * (plotBottom - padding.top)
  const polyline = points.map((point) => `${x(metrics.series.findIndex((item) => item.day === point.day))},${y(point.value as number)}`).join(' ')
  const label = points.length ? `${points.length} días con lecturas en ${metrics.windowDays} días` : 'Aún no hay lecturas suficientes para dibujar la tendencia'
  return <section className="glucose-chart surface" aria-labelledby={`chart-title-${metrics.windowDays}`}><div className="chart-heading"><div><h3 id={`chart-title-${metrics.windowDays}`}>{title}</h3><p>{label}. El punto representa el promedio de ese día.</p></div><div className="chart-legend" aria-label="Zonas de glucosa"><span><i className="legend-low" /> Baja &lt;70</span><span><i className="legend-range" /> En rango 70–180</span><span><i className="legend-high" /> Alta &gt;180</span></div></div><div className="chart-wrap">{points.length > 0 ? <svg viewBox={`0 0 ${width} ${height}`} role="img" aria-label={`Tendencia diaria de glucosa de los últimos ${metrics.windowDays} días`}><rect x={padding.left} y={padding.top} width={width - padding.left - padding.right} height={Math.max(y(180) - padding.top, 0)} className="chart-zone chart-zone--high" /><rect x={padding.left} y={y(180)} width={width - padding.left - padding.right} height={Math.max(y(70) - y(180), 0)} className="chart-zone chart-zone--range" /><rect x={padding.left} y={y(70)} width={width - padding.left - padding.right} height={Math.max(plotBottom - y(70), 0)} className="chart-zone chart-zone--low" /><line x1={padding.left} x2={width - padding.right} y1={y(70)} y2={y(70)} className="chart-guide" /><line x1={padding.left} x2={width - padding.right} y1={y(180)} y2={y(180)} className="chart-guide" /><polyline points={polyline} className="chart-line" fill="none" />{points.map((point) => <circle key={point.day} cx={x(metrics.series.findIndex((item) => item.day === point.day))} cy={y(point.value as number)} r="4.5" className={`chart-point chart-point--${zoneForValue(point.value as number)}`}><title>{point.day}: {point.value} mg/dL</title></circle>)}<text x="5" y={y(180) + 4}>180</text><text x="12" y={y(70) + 4}>70</text></svg> : <div className="chart-empty"><CircleAlert size={22} /><p>Registra lecturas para ver cambios por día.</p></div>}</div></section>
}

export function GlucoseCompletenessChart({ metrics }: { metrics: GlucoseMetrics }) {
  const width = 720
  const height = 205
  const padding = { left: 30, right: 18, top: 22, bottom: 30 }
  const plotHeight = height - padding.top - padding.bottom
  const slotHeight = plotHeight / 3
  const barWidth = Math.max(4, Math.min(18, (width - padding.left - padding.right) / metrics.dailyCompleteness.length - 6))
  const step = (width - padding.left - padding.right) / Math.max(metrics.dailyCompleteness.length, 1)
  const visibleLabelEvery = metrics.dailyCompleteness.length > 14 ? 5 : 2
  const completeLabel = `${metrics.completeDays} de ${metrics.windowDays} días completos`
  return <section className="glucose-chart surface" aria-labelledby={`completeness-title-${metrics.windowDays}`}><div className="chart-heading"><div><h3 id={`completeness-title-${metrics.windowDays}`}>Continuidad y completitud</h3><p>{completeLabel}. Se esperan tres lecturas por día: mañana, tarde y noche.</p></div><div className="chart-legend" aria-label="Franjas esperadas"><span><i className="legend-slot legend-slot--morning" /> Mañana</span><span><i className="legend-slot legend-slot--afternoon" /> Tarde</span><span><i className="legend-slot legend-slot--night" /> Noche</span></div></div><div className="chart-wrap chart-wrap--completeness"><svg viewBox={`0 0 ${width} ${height}`} role="img" aria-label={`Completitud diaria: ${metrics.completeDays} de ${metrics.windowDays} días tienen las tres franjas`}><line x1={padding.left} x2={width - padding.right} y1={padding.top} y2={padding.top} className="chart-guide chart-guide--expected" /><text x="8" y={padding.top + 4}>3</text><text x="8" y={height - padding.bottom + 4}>0</text>{metrics.dailyCompleteness.map((day, index) => { const x = padding.left + index * step + (step - barWidth) / 2; return <g key={day.day}><rect x={x} y={padding.top} width={barWidth} height={slotHeight - 3} className={`slot-segment ${day.morning ? 'slot-segment--active slot-segment--morning' : 'slot-segment--missing'}`} /><rect x={x} y={padding.top + slotHeight} width={barWidth} height={slotHeight - 3} className={`slot-segment ${day.afternoon ? 'slot-segment--active slot-segment--afternoon' : 'slot-segment--missing'}`} /><rect x={x} y={padding.top + slotHeight * 2} width={barWidth} height={slotHeight - 3} className={`slot-segment ${day.night ? 'slot-segment--active slot-segment--night' : 'slot-segment--missing'}`} />{(index % visibleLabelEvery === 0 || index === metrics.dailyCompleteness.length - 1) && <text x={x + barWidth / 2} y={height - 7} textAnchor="middle">{day.day.slice(8)}</text>}<title>{day.day}: {day.readingCount} lectura(s), {day.complete ? 'día completo' : 'faltan franjas'}</title></g> })}</svg></div></section>
}

export function GlucoseZonesChart({ metrics }: { metrics: GlucoseMetrics }) {
  const zones = [
    { label: 'Baja', value: metrics.lowPct, className: 'zone-bar__fill--low', description: '<70 mg/dL' },
    { label: 'En rango', value: metrics.inGeneralRangePct, className: 'zone-bar__fill--range', description: '70–180 mg/dL' },
    { label: 'Alta', value: metrics.highPct, className: 'zone-bar__fill--high', description: '>180 mg/dL' },
  ]
  return <section className="glucose-chart surface zones-chart" aria-labelledby={`zones-title-${metrics.windowDays}`}><div className="chart-heading"><div><h3 id={`zones-title-${metrics.windowDays}`}>Distribución por zona</h3><p>Porcentaje de las lecturas del periodo, separado por nivel de glucosa.</p></div><BarChart3 size={20} className="chart-heading__icon" aria-hidden="true" /></div><div className="zone-bars">{zones.map((zone) => <div className="zone-bar" key={zone.label}><div className="zone-bar__label"><span>{zone.label}</span><small>{zone.description}</small><strong>{formatMetric(zone.value, '%')}</strong></div><div className="zone-bar__track"><span className={`zone-bar__fill ${zone.className}`} style={{ width: `${zone.value ?? 0}%` }} /></div></div>)}</div></section>
}

export function MetricDisclaimer() {
  return <p className="metric-disclaimer"><TrendingDown size={15} /> Estas cifras describen tus registros. No sustituyen una meta individual ni indican cambios de tratamiento.</p>
}
