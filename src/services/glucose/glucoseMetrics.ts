import type { GlucoseMeasurementContext, GlucoseReading } from '../../types/glucose'

export type MetricsWindow = 7 | 14 | 30

export type GlucoseMeasurementSlot = 'morning' | 'afternoon' | 'night'

export interface DailyCompletenessPoint {
  day: string
  morning: boolean
  afternoon: boolean
  night: boolean
  readingCount: number
  complete: boolean
}

export interface GlucoseMetrics {
  windowDays: MetricsWindow
  totalReadings: number
  daysWithReading: number
  adherencePct: number
  continuityPct: number
  completeDays: number
  completenessPct: number
  expectedReadings: number
  slotCoveragePct: number | null
  mean: number | null
  minimum: number | null
  maximum: number | null
  coefficientOfVariation: number | null
  inGeneralRangePct: number | null
  lowPct: number | null
  highPct: number | null
  currentStreakDays: number
  longestStreakDays: number
  longestGapDays: number
  latestReadingAt: string | null
  contextCounts: Partial<Record<GlucoseMeasurementContext, number>>
  series: Array<{ day: string; value: number | null; count: number }>
  dailyCompleteness: DailyCompletenessPoint[]
}

function dayKey(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

function addDays(date: Date, amount: number): Date {
  const next = new Date(date)
  next.setDate(next.getDate() + amount)
  return next
}

function round(value: number, decimals = 1): number {
  const factor = 10 ** decimals
  return Math.round(value * factor) / factor
}

function maxRun(flags: boolean[]): number {
  let longest = 0
  let current = 0
  for (const flag of flags) {
    current = flag ? current + 1 : 0
    longest = Math.max(longest, current)
  }
  return longest
}

function currentRun(flags: boolean[]): number {
  let current = 0
  for (let index = flags.length - 1; index >= 0 && flags[index]; index -= 1) current += 1
  return current
}

function measurementSlot(reading: GlucoseReading): GlucoseMeasurementSlot {
  if (reading.measurementContext === 'fasting_morning') return 'morning'
  if (reading.measurementContext === 'bedtime') return 'night'

  const hour = new Date(reading.timestamp).getHours()
  if (hour < 12) return 'morning'
  if (hour < 18) return 'afternoon'
  return 'night'
}

export function calculateGlucoseMetrics(readings: GlucoseReading[], windowDays: MetricsWindow, asOf = new Date()): GlucoseMetrics {
  const today = new Date(asOf.getFullYear(), asOf.getMonth(), asOf.getDate())
  const firstDay = addDays(today, -(windowDays - 1))
  const startKey = dayKey(firstDay)
  const endKey = dayKey(today)
  const windowReadings = readings.filter((reading) => {
    const timestamp = new Date(reading.timestamp)
    return Number.isFinite(timestamp.getTime()) && dayKey(timestamp) >= startKey && dayKey(timestamp) <= endKey && reading.glucoseValue >= 20 && reading.glucoseValue <= 600
  })
  const values = windowReadings.map((reading) => reading.glucoseValue)
  const dayMap = new Map<string, GlucoseReading[]>()
  const slotMap = new Map<string, Set<GlucoseMeasurementSlot>>()
  for (const reading of windowReadings) {
    const key = dayKey(new Date(reading.timestamp))
    dayMap.set(key, [...(dayMap.get(key) ?? []), reading])
    const slots = slotMap.get(key) ?? new Set<GlucoseMeasurementSlot>()
    slots.add(measurementSlot(reading))
    slotMap.set(key, slots)
  }
  const series = Array.from({ length: windowDays }, (_, index) => {
    const day = dayKey(addDays(firstDay, index))
    const dayReadings = dayMap.get(day) ?? []
    return { day, value: dayReadings.length ? round(dayReadings.reduce((sum, item) => sum + item.glucoseValue, 0) / dayReadings.length) : null, count: dayReadings.length }
  })
  const flags = series.map((point) => point.count > 0)
  const dailyCompleteness = series.map((point) => {
    const slots = slotMap.get(point.day) ?? new Set<GlucoseMeasurementSlot>()
    return {
      day: point.day,
      morning: slots.has('morning'),
      afternoon: slots.has('afternoon'),
      night: slots.has('night'),
      readingCount: point.count,
      complete: slots.size === 3,
    }
  })
  const completeDays = dailyCompleteness.filter((day) => day.complete).length
  const continuityPct = round((dayMap.size / windowDays) * 100)
  const expectedReadings = windowDays * 3
  const mean = values.length ? values.reduce((sum, value) => sum + value, 0) / values.length : null
  const variance = mean === null || values.length < 2 ? null : values.reduce((sum, value) => sum + (value - mean) ** 2, 0) / values.length
  const sd = variance === null ? null : Math.sqrt(variance)
  const contextCounts: Partial<Record<GlucoseMeasurementContext, number>> = {}
  for (const reading of windowReadings) contextCounts[reading.measurementContext] = (contextCounts[reading.measurementContext] ?? 0) + 1
  const percentage = (count: number) => values.length ? round((count / values.length) * 100) : null
  return {
    windowDays,
    totalReadings: values.length,
    daysWithReading: dayMap.size,
    adherencePct: continuityPct,
    continuityPct,
    completeDays,
    completenessPct: round((completeDays / windowDays) * 100),
    expectedReadings,
    slotCoveragePct: expectedReadings ? round(Math.min((values.length / expectedReadings) * 100, 100)) : null,
    mean: mean === null ? null : round(mean),
    minimum: values.length ? Math.min(...values) : null,
    maximum: values.length ? Math.max(...values) : null,
    coefficientOfVariation: mean && sd !== null ? round((sd / mean) * 100) : null,
    inGeneralRangePct: percentage(values.filter((value) => value >= 70 && value <= 180).length),
    lowPct: percentage(values.filter((value) => value < 70).length),
    highPct: percentage(values.filter((value) => value > 180).length),
    currentStreakDays: currentRun(flags),
    longestStreakDays: maxRun(flags),
    longestGapDays: maxRun(flags.map((flag) => !flag)),
    latestReadingAt: windowReadings.length ? windowReadings.reduce((latest, reading) => reading.timestamp > latest.timestamp ? reading : latest).timestamp : null,
    contextCounts,
    series,
    dailyCompleteness,
  }
}

export const METRIC_CONTEXT_LABELS: Partial<Record<GlucoseMeasurementContext, string>> = {
  fasting_morning: 'Ayuno',
  pre_meal: 'Antes de comer',
  post_meal_1h: '1 h después',
  post_meal_2h: '2 h después',
  post_meal_3h_plus: '3 h o más después',
  bedtime: 'Antes de dormir',
  random: 'Sin momento específico',
  other: 'Otro',
}
