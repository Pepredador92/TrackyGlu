import { diabetesLabels, treatmentLabels } from '../../types/clinicalHistory'
import type { ClinicalHistoryData } from '../../types/clinicalHistory'

const answerLabels: Record<string, string> = { yes: 'Sí', no: 'No', unknown: 'No lo sé', female: 'Femenino', male: 'Masculino', other: 'Otra / prefiero no responder', never: 'Nunca', former: 'Antes, ahora no', current: 'Actualmente', occasional: 'Ocasionalmente', none: 'No actualmente', regular: 'Con regularidad', sometimes: 'Algunos días' }
function answer(value: string) { return answerLabels[value] ?? (value || 'Sin dato') }

export default function HistorySummary({ data }: { data: ClinicalHistoryData }) {
  const sections: Array<{ title: string; values: Array<[string, string]> }> = [
    { title: 'Sobre ti', values: [['Fecha de nacimiento', data.birthDate], ['Sexo registrado', answer(data.sex)], ['Teléfono', data.phone], ['Domicilio', data.address], ['Ocupación', data.occupation], ['Contacto de apoyo', data.emergencyContact]] },
    { title: 'Diabetes y antecedentes', values: [['Tipo de diabetes', diabetesLabels[data.diabetesType]], ['Año del diagnóstico', data.diagnosisYear], ['Otras condiciones', data.conditionsStatus === 'yes' ? [...data.conditions, data.otherConditions].filter(Boolean).join(', ') : answer(data.conditionsStatus)], ['Antecedentes familiares', data.familyHistory], ['Baja de glucosa que requirió ayuda de otra persona', answer(data.severeLowHistory)]] },
    { title: 'Tratamiento y alergias', values: [['Tratamiento actual', treatmentLabels[data.treatmentStatus]], ['Alergias', data.allergyStatus === 'yes' ? data.allergies : answer(data.allergyStatus)]] },
    { title: 'Rutina y apoyo', values: [['Tabaco', answer(data.smoking)], ['Alcohol', answer(data.alcohol)], ['Actividad física', answer(data.activity)], ['Apoyo para el seguimiento', data.support], ['Información adicional', data.notes]] },
  ]
  return <div className="history-summary">{sections.map((section) => <section key={section.title}><h3>{section.title}</h3><dl>{section.values.map(([label, value]) => <div key={label}><dt>{label}</dt><dd>{value || 'Sin dato'}</dd></div>)}</dl>
    {section.title === 'Tratamiento y alergias' && data.medications.length > 0 && <div className="medication-summary">{data.medications.map((medication, index) => <p key={index}><strong>{medication.name}</strong><span>{medication.dose || 'Dosis por confirmar'} · {medication.schedule || 'Horario por confirmar'}</span></p>)}</div>}
  </section>)}</div>
}
