import { BrowserRouter, Route, Routes } from 'react-router-dom'
import PatientHome from './pages/patient/PatientHome'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<PatientHome />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
