import { Link } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
import { Brand } from '../components/layout/PageShell'

export default function ClinicalBasis() {
  return <main className="profile-main narrow-content"><Link className="quiet-link back-navigation" to="/"><ArrowLeft size={17} /> Volver a mi espacio</Link><div><Brand /></div><div className="page-intro" style={{ marginTop: 36 }}><p className="eyebrow">TRANSPARENCIA EN TU SEGUIMIENTO</p><h1>¿Por qué te preguntamos esto?</h1><p className="lead">Conocer tus antecedentes, tratamiento y necesidades ayuda a preparar el seguimiento con tu profesional.</p></div>
    <div className="surface reference-list"><article><h2>Tu información, paso a paso</h2><p>La historia inicial reúne lo que tú conoces de tu salud. Se organiza en cuatro secciones y permite guardar el avance. Tu profesional revisará esta información y completará la exploración, los resultados y la valoración clínica que correspondan en consulta.</p></article>
    <article><h2>Expediente clínico en México</h2><p>Tomamos como referencia la NOM-004-SSA3-2012, en especial sus apartados 5 y 6 sobre identificación, confidencialidad e historia clínica. El cuestionario inicial aporta antecedentes; la integración del expediente completo corresponde al servicio de atención.</p><a href="https://dof.gob.mx/normasOficiales/4909/SALUD/SALUD.html" target="_blank" rel="noreferrer">Consultar NOM-004-SSA3-2012 en el DOF ↗</a></article>
    <article><h2>Antecedentes relevantes para la diabetes</h2><p>El tipo de diabetes, el tratamiento actual, las alergias, otras enfermedades y las necesidades de apoyo permiten aportar contexto al profesional. La NOM-015-SSA2-2010 y los estándares ADA 2026 son referencias para documentar estas decisiones.</p><p><a href="https://dof.gob.mx/normasOficiales/4215/salud/salud.htm" target="_blank" rel="noreferrer">Consultar NOM-015-SSA2-2010 ↗</a></p><a href="https://doi.org/10.2337/dc26-S004" target="_blank" rel="noreferrer">Consultar evaluación integral de ADA 2026 ↗</a></article>
    <article><h2>Tú eliges con quién compartir</h2><p>Tu historia queda asociada a tu cuenta. Un profesional accede a ella cuando aceptas su invitación. Puedes finalizar ese vínculo desde tu perfil; las revisiones ya registradas se conservan como parte del seguimiento.</p></article>
    <article><h2>Preguntas que ayudan a preparar la consulta</h2><p>Puedes responder «No lo sé» cuando corresponda. Los campos opcionales pueden completarse después. Registrar un tratamiento sirve para documentar lo que ya tienes indicado; los cambios se acuerdan con tu profesional.</p></article>
    </div>
  </main>
}
