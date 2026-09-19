export type UserRole = 'patient' | 'professional' | 'admin'

export interface Profile {
  id: string
  userId: string
  role: UserRole
  displayName: string | null
}
