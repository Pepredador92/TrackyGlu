# Objetivo 2 — Captura contextual y dashboards

Estado: implementación local en curso, con migración y recorridos principales probados en Docker. Fecha: 24 de septiembre de 2026.

## Qué resuelve

El paciente registra una lectura de glucosa y puede aportar el contexto mínimo que ayuda a interpretarla. La pantalla propone un momento según la hora local, pero la persona lo confirma o lo cambia. El sistema pregunta comida y tratamiento de manera condicional y guarda el dato para no repetir el check-in diario.

El paciente ve un resumen de sus últimos 14 días. El profesional ve el resumen de 30 días y una gráfica de cada paciente vinculado. La lectura completa y el contexto siguen protegidos por las mismas políticas RLS del objetivo 1.

## Flujo de una lectura

1. El servidor identifica al paciente y consulta si ya existe una lectura ese día.
2. La interfaz propone `Ayuno`, `Antes de comer` o `Antes de dormir` según la hora local. Es una sugerencia de interfaz, no una clasificación clínica automática.
3. El paciente registra el valor en mg/dL y confirma el momento.
4. Si es una medición relacionada con comida, se pregunta el tipo de comida. Para mediciones posteriores se solicita la hora aproximada en que comenzó.
5. Si es la primera lectura del día y la historia indica tratamiento, se pregunta si tomó la dosis programada. También puede registrar una respuesta general sobre las últimas 24 horas. El sistema no calcula dosis ni cambia tratamientos.
6. Actividad física, síntomas y una nota son opcionales. Las respuestas pueden quedar vacías.
7. Se guarda la lectura con `event_id`, fecha/hora real, canal, fuente y contexto. Los campos técnicos `quality_state=valid` y `processing_state=persisted` dejan listo el contrato para los workflows del objetivo 3.

Si la hora de la comida es posterior a la lectura, la base rechaza el registro. Los valores fuera de 20–600 mg/dL se rechazan para evitar lecturas técnicas evidentemente inválidas. La validación no decide si el resultado es clínicamente seguro.

## Campos del objetivo 2

Los nombres siguen la hoja `Variables de Protocolo de experimentación.xlsx` cuando existe un equivalente. Los campos adicionales de interfaz quedan documentados en la migración.

| Grupo | Campos | Captura |
| --- | --- | --- |
| Medición | `glucose_value`, `unit`, `measured_at`, `measurement_source`, `measurement_context` | Valor, unidad fija mg/dL, momento y fuente declarados |
| Alimentación | `has_eaten`, `last_meal_at`, `meal_type`, `carbohydrate_estimate` | Solo cuando el contexto lo necesita; carbohidratos quedan reservados para una iteración posterior |
| Tratamiento | `treatment_due_before_measurement`, `treatment_taken_as_scheduled` | Solo primera lectura del día cuando existe tratamiento en la historia |
| Actividad | `recent_physical_activity`, `activity_duration_min`, `activity_intensity` | Pregunta opcional en cada captura; solo se almacena duración cuando se responde Sí |
| Seguridad y contexto | `symptoms_present`, `symptoms`, `illness_flag`, `stress_flag`, `sleep_quality`, `observation` | Opcional, sin convertir síntomas en diagnóstico |
| Trazabilidad | `event_id`, `source_channel`, `access_channel`, `quality_state`, `processing_state` | Generado por la base o por el canal, no preguntado al paciente |
| Check-in diario | `glucose_daily_context.local_date`, `treatment_adherence_24h`, `missed_doses_7d`, `missed_dose_reason`, `illness_flag`, `stress_flag`, `sleep_quality` | Una fila por paciente y día; el objetivo 2 prepara la tabla y la primera lectura puede guardar la respuesta diaria |

Los campos de dosis detalladas, insulina, carbohidratos y actividad completa aparecen como variables del protocolo, pero no se fuerzan en cada lectura. Requieren definir primero el tratamiento vigente y el consentimiento operativo del protocolo. Se incorporarán con su propio contrato cuando se apruebe el objetivo 3.

## Métricas visibles

Las métricas se calculan en el navegador a partir de las filas que RLS ya autorizó para ese paciente o profesional. La función común está en `src/services/glucose/glucoseMetrics.ts`.

| Métrica | Cálculo | Lectura correcta |
| --- | --- | --- |
| Lecturas | Conteo de registros válidos entre 20 y 600 mg/dL | Volumen de datos, no calidad del control |
| Días con registro | Fechas locales distintas con una o más lecturas | Continuidad básica del seguimiento |
| Porcentaje de días registrados | Días con registro ÷ días de ventana × 100 | Adherencia de captura; no adherencia farmacológica |
| Promedio | Suma de valores ÷ lecturas | Resumen descriptivo del periodo |
| En rango general | Lecturas entre 70 y 180 mg/dL ÷ lecturas × 100 | Señal descriptiva para orientar conversación; no es TIR de CGM |
| Por debajo / por encima | Lecturas `<70` o `>180` ÷ lecturas × 100 | Frecuencia observada en la muestra; requiere contexto y revisión |
| Variabilidad (CV) | Desviación estándar ÷ promedio × 100 | Indicador descriptivo; con pocas lecturas se muestra con cautela |
| Racha y brecha | Días consecutivos con lectura y mayor secuencia sin lectura | Continuidad del registro |
| Contextos | Conteo por ayuno, antes/después de comida y otros | Ayuda a separar patrones; no sustituye una valoración |

Las ventanas de paciente son 14 días y las de profesional 30 días. La función también admite 7 días para una vista posterior y para alinear el protocolo. Cuando no hay lecturas, se muestra `Sin datos` y no se fabrica cero clínico.

## Fundamento clínico y límites

La ADA 2026 reconoce la monitorización de glucosa como útil para observar respuestas a comidas, actividad y cambios de medicación, y distingue objetivos de glucosa preprandial y posprandial. También reserva métricas como TIR, tiempo por debajo/encima y coeficiente de variación para reportes de CGM, con metas individualizadas. Por eso TrackyGlu llama a su porcentaje 70–180 “en rango general” cuando reúne lecturas capilares y no lo presenta como TIR.

Fuentes consultadas:

- [ADA 2026, sección 6 — Glycemic Goals, Hypoglycemia, and Hyperglycemic Crises](https://diabetesjournals.org/care/article/49/Supplement_1/S132/163927).
- [ADA 2026, sección 7 — Diabetes Technology y Blood Glucose Monitoring](https://diabetesjournals.org/care/article/49/Supplement_1/S150/163922).
- [NOM-015-SSA2-2010 — DOF](https://dof.gob.mx/normasOficiales/4215/salud/salud.htm), como referencia nacional del seguimiento de diabetes.

Los umbrales se muestran para conversación y análisis operativo. No definen una meta personalizada, no diagnostican hipoglucemia/hiperglucemia y no generan recomendaciones automáticas. Una alerta clínica y su redacción se revisarán con el protocolo antes de conectar `Flow-ALR-01`.

## Decisiones de experiencia

- La primera lectura del día concentra preguntas breves para evitar repetirlas.
- La hora orienta la sugerencia, pero la persona decide el contexto.
- Comida, actividad, síntomas y nota se muestran de manera progresiva.
- El paciente siempre puede indicar información desconocida o dejarla opcional.
- El profesional observa la tendencia y los agregados del paciente vinculado, sin editar sus lecturas.
- La gráfica usa promedios diarios para que una jornada con muchas lecturas no domine visualmente toda la vista.

## Pendiente para cerrar el objetivo

- Revisar visualmente la nueva captura y dashboard con el usuario.
- Confirmar si las ventanas de paciente (14) y profesional (30) son las preferidas.
- Confirmar la nomenclatura “en rango general” y la conveniencia de mostrar CV con pocos registros.
- Definir con el protocolo cuáles preguntas semanales de tratamiento se activan y qué tratamiento vigente debe alimentar `treatment_due_before_measurement`.
- Añadir el mapeo de eventos y métricas persistidas cuando se adapte n8n en el objetivo 3.
