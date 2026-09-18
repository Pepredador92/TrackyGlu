import { BrowserRouter, Route, Routes } from 'react-router-dom'
import GlucoseHistory from './pages/patient/GlucoseHistory'
import PatientHome from './pages/patient/PatientHome'
import RegisterGlucose from './pages/patient/RegisterGlucose'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<PatientHome />} />
        <Route path="/registrar-glucosa" element={<RegisterGlucose />} />
        <Route path="/mis-registros" element={<GlucoseHistory />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
