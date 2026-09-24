import type { GlucoseMeasurementContext } from '../types/glucose'

export const GLUCOSE_CONTEXT_LABELS: Record<GlucoseMeasurementContext, string> = {
  fasting_morning: 'Ayuno',
  pre_meal: 'Antes de comer',
  post_meal_1h: '1 hora después de comer',
  post_meal_2h: '2 horas después de comer',
  post_meal_3h_plus: '3 horas o más después',
  bedtime: 'Antes de dormir',
  random: 'Sin momento específico',
  other: 'Otro',
}

const timeFormatter = new Intl.DateTimeFormat('es-MX', {
  hour: '2-digit',
  minute: '2-digit',
  hour12: false,
})

const dateFormatter = new Intl.DateTimeFormat('es-MX', {
  day: 'numeric',
  month: 'short',
})

const longDateFormatter = new Intl.DateTimeFormat('es-MX', {
  day: 'numeric',
  month: 'long',
  year: 'numeric',
})

export function getLocalDayKey(dateInput: string | Date): string {
  const date = dateInput instanceof Date ? dateInput : new Date(dateInput)
  return `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`
}

export function isToday(timestamp: string): boolean {
  return getLocalDayKey(timestamp) === getLocalDayKey(new Date())
}

export function isYesterday(timestamp: string): boolean {
  const yesterday = new Date()
  yesterday.setDate(yesterday.getDate() - 1)
  return getLocalDayKey(timestamp) === getLocalDayKey(yesterday)
}

export function formatReadingTime(timestamp: string): string {
  return timeFormatter.format(new Date(timestamp))
}

export function formatReadingDateTime(timestamp: string): string {
  if (isToday(timestamp)) {
    return formatReadingTime(timestamp)
  }

  if (isYesterday(timestamp)) {
    return `Ayer, ${formatReadingTime(timestamp)}`
  }

  return `${dateFormatter.format(new Date(timestamp))}, ${formatReadingTime(timestamp)}`
}

export function formatReadingDay(timestamp: string): string {
  if (isToday(timestamp)) {
    return 'Hoy'
  }

  if (isYesterday(timestamp)) {
    return 'Ayer'
  }

  return longDateFormatter.format(new Date(timestamp))
}
