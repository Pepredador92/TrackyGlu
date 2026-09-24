export interface Medication {
  name: string
  dose: string
  schedule: string
}

export interface ClinicalHistoryData {
  birthDate: string
  sex: string
  phone: string
  address: string
  occupation: string
  emergencyContact: string
  diabetesType: string
  diagnosisYear: string
  conditionsStatus: string
  conditions: string[]
  otherConditions: string
  familyHistory: string
  severeLowHistory: string
  treatmentStatus: string
  medications: Medication[]
  allergyStatus: string
  allergies: string
  smoking: string
  alcohol: string
  activity: string
  support: string
  notes: string
  informationConfirmed: boolean
}

export interface PatientHistory {
  patient_id: string
  data: ClinicalHistoryData
  current_step: number
  revision: number
  completed_at: string | null
  updated_at: string
}

export interface HistoryReview {
  id: string
  history_revision: number
  note: string
  reviewed_at: string
  professional_id: string
}

export const emptyHistory: ClinicalHistoryData = {
  birthDate: '', sex: '', phone: '', address: '', occupation: '', emergencyContact: '',
  diabetesType: '', diagnosisYear: '', conditionsStatus: '', conditions: [], otherConditions: '',
  familyHistory: '', severeLowHistory: '', treatmentStatus: '', medications: [],
  allergyStatus: '', allergies: '', smoking: '', alcohol: '', activity: '', support: '',
  notes: '', informationConfirmed: false,
}

export const historySteps = ['Sobre ti', 'Tu diabetes', 'Tu tratamiento', 'Tu día a día']
export const diabetesLabels: Record<string, string> = {
  type_1: 'Diabetes tipo 1', type_2: 'Diabetes tipo 2', gestational: 'Diabetes gestacional',
  other: 'Otro tipo', unknown: 'No lo sé',
}
export const treatmentLabels: Record<string, string> = {
  none: 'Sin medicamentos actualmente', medication: 'Medicamentos sin insulina',
  insulin: 'Insulina', both: 'Insulina y otros medicamentos', unknown: 'Necesito ayuda para identificarlo',
}
export const knownConditions = ['Presión alta', 'Colesterol o triglicéridos altos', 'Enfermedad del riñón', 'Enfermedad del corazón', 'Problemas de visión', 'Problemas en los pies', 'Otra']

export function localDate() {
  const now = new Date()
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
}

export function validateHistoryStep(data: ClinicalHistoryData, step: number): Record<string, string> {
  const errors: Record<string, string> = {}
  if (step === 0) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(data.birthDate) || data.birthDate < '1900-01-01' || data.birthDate > localDate()) errors.birthDate = 'Revisa tu fecha de nacimiento.'
    if (!data.sex) errors.sex = 'Selecciona una opción.'
  }
  if (step === 1) {
    if (!data.diabetesType) errors.diabetesType = 'Selecciona una opción; puedes elegir «No lo sé».'
    if (data.diagnosisYear && (!/^\d{4}$/.test(data.diagnosisYear) || Number(data.diagnosisYear) < Number(data.birthDate.slice(0, 4)) || Number(data.diagnosisYear) > new Date().getFullYear())) errors.diagnosisYear = 'Escribe un año entre tu nacimiento y el año actual.'
    if (!data.conditionsStatus) errors.conditionsStatus = 'Selecciona una opción.'
    if (data.conditionsStatus === 'yes' && !data.conditions.length) errors.conditions = 'Selecciona al menos una condición.'
  }
  if (step === 2) {
    if (!data.treatmentStatus) errors.treatmentStatus = 'Selecciona tu tratamiento actual.'
    if (!data.allergyStatus) errors.allergyStatus = 'Selecciona una opción.'
    if (data.allergyStatus === 'yes' && !data.allergies.trim()) errors.allergies = 'Indica la alergia o escribe que necesitas ayuda para identificarla.'
    if (data.medications.some((medicine) => !medicine.name.trim())) errors.medications = 'Escribe el nombre de cada medicamento o elimina la fila vacía.'
  }
  if (step === 3 && !data.informationConfirmed) errors.informationConfirmed = 'Confirma que revisaste tu información.'
  return errors
}
