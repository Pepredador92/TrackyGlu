import { BrowserRouter, Route, Routes } from 'react-router-dom'
import { AuthProvider } from './components/auth/AuthContext'
import { PatientRoute, ProfessionalRoute, ProtectedRoute } from './components/auth/ProtectedRoute'
import GlucoseHistory from './pages/patient/GlucoseHistory'
import PatientHome from './pages/patient/PatientHome'
import Login from './pages/Login'
import ProfessionalPlaceholder from './pages/ProfessionalPlaceholder'
import ProfessionalAlertsPage from './pages/professional/ProfessionalAlertsPage'
import RegisterGlucose from './pages/patient/RegisterGlucose'

function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route element={<ProtectedRoute />}>
            <Route element={<PatientRoute />}>
              <Route path="/" element={<PatientHome />} />
              <Route path="/registrar-glucosa" element={<RegisterGlucose />} />
              <Route path="/mis-registros" element={<GlucoseHistory />} />
            </Route>
            <Route element={<ProfessionalRoute />}>
              <Route path="/professional" element={<ProfessionalPlaceholder />} />
              <Route path="/professional/alerts" element={<ProfessionalAlertsPage />} />
            </Route>
          </Route>
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  )
}

export default App
