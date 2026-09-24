import { supabase } from './supabase/supabaseClient'
import { emptyHistory } from '../types/clinicalHistory'
import type { ClinicalHistoryData, HistoryReview, PatientHistory } from '../types/clinicalHistory'

export interface ProfessionalProfile {
  id: string
  profile_id: string
  specialty: string
  license_number: string
  institution: string
  phone: string
  completed_at: string | null
}
export interface LinkedPerson {
  id: string
  name: string
  specialty?: string
  institution?: string
  completedAt?: string | null
}
export interface PatientInvitation {
  id: string
  code: string
  expires_at: string
  accepted_at: string | null
  revoked_at: string | null
}

export async function getHistory(patientId: string): Promise<PatientHistory> {
  const { data, error } = await supabase.from('patient_histories').select('*').eq('patient_id', patientId).single()
  if (error) throw error
  return { ...data, data: { ...emptyHistory, ...data.data } } as PatientHistory
}

export async function saveHistory(data: ClinicalHistoryData, step: number, revision: number, complete = false): Promise<PatientHistory> {
  const { data: saved, error } = await supabase.rpc('save_patient_history', {
    history_data: data, next_step: step, expected_revision: revision, complete,
  })
  if (error) throw error
  return saved as PatientHistory
}

export async function getProfessional(id: string): Promise<ProfessionalProfile> {
  const { data, error } = await supabase.from('professionals').select('*').eq('id', id).single()
  if (error) throw error
  return data
}

export async function saveProfessional(id: string, profileId: string, name: string, values: Omit<ProfessionalProfile, 'id' | 'profile_id' | 'completed_at'>) {
  const { error: nameError } = await supabase.from('profiles').update({ display_name: name.trim() }).eq('id', profileId).select('id').single()
  if (nameError) throw nameError
  const { error } = await supabase.from('professionals').update({ ...values, completed_at: new Date().toISOString() }).eq('id', id).select('id').single()
  if (error) throw error
}

export async function getLinkedPatients(professionalId: string): Promise<LinkedPerson[]> {
  const { data: links, error } = await supabase.from('professional_patients').select('patient_id').eq('professional_id', professionalId).eq('active', true)
  if (error) throw error
  if (!links.length) return []
  const { data: patients, error: patientError } = await supabase.from('patients').select('id, profile_id, profiles(display_name), patient_histories(completed_at)').in('id', links.map((link) => link.patient_id))
  if (patientError) throw patientError
  return (patients as unknown as Array<{ id: string; profiles: { display_name: string }; patient_histories: { completed_at: string | null } | null }>).map((patient) => ({ id: patient.id, name: patient.profiles.display_name, completedAt: patient.patient_histories?.completed_at }))
}

export async function getLinkedProfessionals(patientId: string): Promise<LinkedPerson[]> {
  const { data: links, error } = await supabase.from('professional_patients').select('professional_id').eq('patient_id', patientId).eq('active', true)
  if (error) throw error
  if (!links.length) return []
  const { data, error: peopleError } = await supabase.from('professionals').select('id, specialty, institution, profiles(display_name)').in('id', links.map((link) => link.professional_id))
  if (peopleError) throw peopleError
  return (data as unknown as Array<{ id: string; specialty: string; institution: string; profiles: { display_name: string } }>).map((person) => ({ id: person.id, name: person.profiles.display_name, specialty: person.specialty, institution: person.institution }))
}

export async function createInvitation(professionalId: string): Promise<PatientInvitation> {
  const { data, error } = await supabase.from('patient_invitations').insert({ professional_id: professionalId }).select('id,code,expires_at,accepted_at,revoked_at').single()
  if (error) throw error
  return data
}

export async function getInvitations(professionalId: string): Promise<PatientInvitation[]> {
  const { data, error } = await supabase.from('patient_invitations').select('id,code,expires_at,accepted_at,revoked_at').eq('professional_id', professionalId).order('created_at', { ascending: false }).limit(10)
  if (error) throw error
  return data
}

export async function previewInvitation(code: string): Promise<LinkedPerson> {
  const { data, error } = await supabase.rpc('preview_patient_invitation', { invitation_code: code.trim() })
  if (error) throw error
  return data as LinkedPerson
}

export async function acceptInvitation(code: string) {
  const { error } = await supabase.rpc('accept_patient_invitation', { invitation_code: code.trim() })
  if (error) throw error
}

export async function endAssignment(patientId: string, professionalId: string) {
  const { error } = await supabase.rpc('end_patient_assignment', { target_patient: patientId, target_professional: professionalId })
  if (error) throw error
}

export async function getPatientName(patientId: string): Promise<string> {
  const { data, error } = await supabase.from('patients').select('profiles(display_name)').eq('id', patientId).single()
  if (error) throw error
  return (data as unknown as { profiles: { display_name: string } }).profiles.display_name
}

export async function getHistoryReviews(patientId: string): Promise<HistoryReview[]> {
  const { data, error } = await supabase.from('patient_history_reviews').select('*').eq('patient_id', patientId).order('reviewed_at', { ascending: false })
  if (error) throw error
  return data
}

export async function reviewHistory(patientId: string, revision: number, note: string) {
  const { error } = await supabase.rpc('review_patient_history', { target_patient: patientId, expected_revision: revision, review_note: note.trim() })
  if (error) throw error
}

export function profileError(error: unknown, fallback: string): string {
  if (error && typeof error === 'object' && 'message' in error && String(error.message).includes('HISTORY_CONFLICT')) return 'La historia cambió en otra sesión. Recarga la página antes de guardar para conservar ambas versiones.'
  return fallback
}
