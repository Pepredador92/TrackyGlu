import type { GlucoseReading } from '../../types/glucose'

const GLUCOSE_READINGS_STORAGE_KEY = 'trackyglu_glucose_readings'

export async function createReading(reading: GlucoseReading): Promise<GlucoseReading> {
  const storedReadings = localStorage.getItem(GLUCOSE_READINGS_STORAGE_KEY)
  const readings: GlucoseReading[] = storedReadings ? JSON.parse(storedReadings) : []

  // Temporary local storage; this will be replaced by the backend integration.
  readings.push(reading)
  localStorage.setItem(GLUCOSE_READINGS_STORAGE_KEY, JSON.stringify(readings))

  return reading
}

export async function getReadings(): Promise<GlucoseReading[]> {
  const storedReadings = localStorage.getItem(GLUCOSE_READINGS_STORAGE_KEY)

  // Temporary local storage; this will be replaced by the backend integration.
  return storedReadings ? JSON.parse(storedReadings) as GlucoseReading[] : []
}
