import { lazy, Suspense } from 'react'
import { createBrowserRouter, createRoutesFromElements, Navigate, Outlet, Route, RouterProvider } from 'react-router-dom'
import { AuthProvider } from './components/auth/AuthContext'
import { PatientRoute, ProfessionalRoute, ProtectedRoute } from './components/auth/ProtectedRoute'
const GlucoseHistory = lazy(() => import('./pages/patient/GlucoseHistory'))
import PatientHome from './pages/patient/PatientHome'
import Login from './pages/Login'
const ProfessionalHome = lazy(() => import('./pages/professional/ProfessionalHome'))
const ProfessionalProfile = lazy(() => import('./pages/professional/ProfessionalProfile'))
const PatientDetail = lazy(() => import('./pages/professional/PatientDetail'))
const PatientProfile = lazy(() => import('./pages/patient/PatientProfile'))
const PatientHistory = lazy(() => import('./pages/patient/PatientHistory'))
import PasswordRecovery from './pages/PasswordRecovery'
import ClinicalBasis from './pages/ClinicalBasis'
const ProfessionalAlertsPage = lazy(() => import('./pages/professional/ProfessionalAlertsPage'))
const ProfessionalTasksPage = lazy(() => import('./pages/professional/ProfessionalTasksPage'))
const RegisterGlucose = lazy(() => import('./pages/patient/RegisterGlucose'))

const router = createBrowserRouter(createRoutesFromElements(
        <Route element={<AuthProvider><Outlet /></AuthProvider>}>
          <Route path="/login" element={<Login />} />
          <Route path="/recuperar-acceso" element={<PasswordRecovery />} />
          <Route path="/fundamento-clinico" element={<ClinicalBasis />} />
          <Route element={<ProtectedRoute />}>
            <Route element={<PatientRoute />}>
              <Route path="/" element={<PatientHome />} />
              <Route path="/mi-historia" element={<PatientHistory />} />
              <Route path="/mi-perfil" element={<PatientProfile />} />
              <Route path="/registrar-glucosa" element={<RegisterGlucose />} />
              <Route path="/mis-registros" element={<GlucoseHistory />} />
            </Route>
            <Route element={<ProfessionalRoute />}>
              <Route path="/professional" element={<ProfessionalHome />} />
              <Route path="/professional/profile" element={<ProfessionalProfile />} />
              <Route path="/professional/patients/:patientId" element={<PatientDetail />} />
              <Route path="/professional/alerts" element={<ProfessionalAlertsPage />} />
              <Route path="/professional/tasks" element={<ProfessionalTasksPage />} />
            </Route>
          </Route>
          <Route path="*" element={<Navigate to="/" replace />} />
        </Route>
))

function App() { return <Suspense fallback={<main className="centered-page"><p role="status">Cargando tu espacio…</p></main>}><RouterProvider router={router} /></Suspense> }

export default App
