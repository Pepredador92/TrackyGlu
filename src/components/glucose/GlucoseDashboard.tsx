import { Activity, CalendarDays, CircleAlert, Gauge, TrendingDown, TrendingUp } from 'lucide-react'
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
    { label: 'Días con registro', value: formatMetric(metrics.adherencePct, '%'), detail: 'continuidad del seguimiento', icon: CalendarDays },
  ]
  return <div className={`metrics-cards${compact ? ' metrics-cards--compact' : ''}`}>{cards.map(({ label, value, detail, icon: Icon }) => <article className="metric-card" key={label}><span className="metric-card__icon"><Icon size={18} /></span><div><span className="metric-card__label">{label}</span><strong>{value}</strong><small>{detail}</small></div></article>)}</div>
}

export function MetricDetails({ metrics }: { metrics: GlucoseMetrics }) {
  const contextEntries = Object.entries(metrics.contextCounts)
  return <div className="metric-details"><div><span>Más baja</span><strong>{formatMetric(metrics.minimum)} {metrics.minimum !== null && 'mg/dL'}</strong></div><div><span>Más alta</span><strong>{formatMetric(metrics.maximum)} {metrics.maximum !== null && 'mg/dL'}</strong></div><div><span>Variabilidad</span><strong>{formatMetric(metrics.coefficientOfVariation, '%')}</strong><small>CV descriptivo</small></div><div><span>Racha actual</span><strong>{metrics.currentStreakDays} {metrics.currentStreakDays === 1 ? 'día' : 'días'}</strong></div><div><span>Por debajo de 70</span><strong>{formatMetric(metrics.lowPct, '%')}</strong><small>{metrics.lowPct !== null ? 'de las lecturas' : 'sin lecturas'}</small></div><div><span>Por encima de 180</span><strong>{formatMetric(metrics.highPct, '%')}</strong><small>{metrics.highPct !== null ? 'de las lecturas' : 'sin lecturas'}</small></div>{contextEntries.length > 0 && <div className="metric-context-list"><span>Contextos registrados</span><p>{contextEntries.map(([key, count]) => `${METRIC_CONTEXT_LABELS[key as keyof typeof METRIC_CONTEXT_LABELS] ?? key}: ${count}`).join(' · ')}</p></div>}</div>
}

export function GlucoseTrendChart({ metrics, title = 'Tendencia de glucosa' }: { metrics: GlucoseMetrics; title?: string }) {
  const points = metrics.series.filter((point) => point.value !== null)
  const width = 720
  const height = 210
  const padding = { left: 42, right: 18, top: 20, bottom: 32 }
  const values = points.map((point) => point.value as number)
  const min = Math.min(40, ...(values.length ? values : [40]))
  const max = Math.max(220, ...(values.length ? values : [220]))
  const x = (index: number) => padding.left + (index / Math.max(metrics.series.length - 1, 1)) * (width - padding.left - padding.right)
  const y = (value: number) => padding.top + ((max - value) / Math.max(max - min, 1)) * (height - padding.top - padding.bottom)
  const polyline = points.map((point) => `${x(metrics.series.findIndex((item) => item.day === point.day))},${y(point.value as number)}`).join(' ')
  const label = points.length ? `${points.length} días con lecturas en ${metrics.windowDays} días` : 'Aún no hay lecturas suficientes para dibujar la tendencia'
  return <section className="glucose-chart surface" aria-labelledby={`chart-title-${metrics.windowDays}`}><div className="chart-heading"><div><h3 id={`chart-title-${metrics.windowDays}`}>{title}</h3><p>{label}</p></div><span className="range-key"><i /> 70–180 mg/dL</span></div><div className="chart-wrap">{points.length > 0 ? <svg viewBox={`0 0 ${width} ${height}`} role="img" aria-label={`Tendencia de glucosa de los últimos ${metrics.windowDays} días`}><rect x={padding.left} y={y(180)} width={width - padding.left - padding.right} height={Math.max(y(70) - y(180), 0)} className="chart-range" /> <line x1={padding.left} x2={width - padding.right} y1={y(70)} y2={y(70)} className="chart-guide" /><line x1={padding.left} x2={width - padding.right} y1={y(180)} y2={y(180)} className="chart-guide" /><polyline points={polyline} className="chart-line" fill="none" />{points.map((point) => <circle key={point.day} cx={x(metrics.series.findIndex((item) => item.day === point.day))} cy={y(point.value as number)} r="4" className="chart-point"><title>{point.day}: {point.value} mg/dL</title></circle>)}<text x="5" y={y(180) + 4}>180</text><text x="12" y={y(70) + 4}>70</text></svg> : <div className="chart-empty"><CircleAlert size={22} /><p>Registra lecturas para ver cambios por día.</p></div>}</div></section>
}

export function MetricDisclaimer() {
  return <p className="metric-disclaimer"><TrendingDown size={15} /> Estas cifras describen tus registros. No sustituyen una meta individual ni indican cambios de tratamiento.</p>
}
