# Objetivo 1 — Acceso, perfiles e historia inicial

Estado: implementado y probado localmente; pendiente de revisión del usuario. Fecha: 24 de septiembre de 2026.

## Resultado esperado

Una persona puede crear su cuenta, retomar una entrevista breve y compartirla de forma explícita con su profesional. El profesional completa su perfil y consulta exclusivamente a pacientes con un vínculo activo. La aplicación utiliza español y presenta las referencias clínicas a la vista en `/fundamento-clinico`.

## Recorridos

### Paciente

1. Crear cuenta con nombre, correo y contraseña o iniciar sesión.
2. Completar cuatro secciones de historia inicial. Cada avance se guarda en servidor; «Guardar y continuar después» admite un borrador incompleto.
3. Revisar las respuestas y confirmar que representan la información conocida.
4. Consultar el perfil y continuar al inicio existente de registro de glucosa.
5. Introducir el código que entrega el profesional, revisar su identidad declarada y aceptar compartir información. Puede finalizar el vínculo desde su perfil.

La historia inicial debe completarse antes de registrar glucosa. Si se guarda una actualización incompleta, vuelve a quedar en borrador hasta confirmarla. Las versiones previas permanecen disponibles en la base. Esta decisión es revisable durante la aprobación del objetivo.

### Profesional

1. Crear cuenta como profesional y completar nombre, profesión/especialidad, cédula e institución; teléfono opcional.
2. Generar una invitación individual con vencimiento de siete días.
3. Ver y buscar sus pacientes vinculados.
4. Consultar historia, estado de completitud y revisiones; registrar una nota vinculada a la versión exacta leída.
5. Finalizar un vínculo cuando corresponda.

La cédula se registra como **dato declarado**. No se implementó validación automática de habilitación profesional. El alta no presenta a la persona como profesional verificado.

## Entrevista inicial y justificación

| Sección | Datos | Obligatoriedad y motivo |
| --- | --- | --- |
| Sobre ti | Nombre del registro; nacimiento; sexo registrado; teléfono; domicilio; ocupación; contacto de apoyo | Nacimiento y selección de sexo son necesarios para terminar; existe opción de no responder al sexo. Otros datos pueden completarse después. Identificación y contexto, tomando como referencia NOM-004, apartados 5 y 6.1.1. |
| Tu diabetes | Tipo; año del diagnóstico; otras enfermedades; antecedentes familiares; antecedente de baja de glucosa con ayuda de otra persona | Tipo y estado de otras condiciones requieren respuesta, incluido «No lo sé». Año, antecedentes e hipoglucemia previa son opcionales. Aportan antecedentes patológicos/heredofamiliares y contexto de diabetes; no confirman diagnósticos. |
| Tu tratamiento | Tipo de tratamiento; medicamentos/insulina, dosis y horario declarados; alergias y reacción | Estado de tratamiento y alergias requeridos, con «No lo sé». Si hay alergia se describe. Los detalles farmacológicos pueden completarse después con la receta. Se documenta tratamiento previo; no se calculan dosis ni se hacen indicaciones. |
| Tu día a día | Tabaco; alcohol; actividad; apoyo para usar la plataforma; comentarios y revisión final | Hábitos y apoyo opcionales. La confirmación final es necesaria para marcar la historia como terminada. Antecedentes no patológicos y necesidades de apoyo/contexto social. |

**La selección de campos tiene fundamento clínico; la división en cuatro pasos es una decisión de diseño del proyecto.** Las normas no prescriben este número de pantallas ni prueban que la interfaz reduzca fatiga. Esa hipótesis se evaluará con usuarios. Tampoco se presentan las opciones cualitativas de actividad/alcohol como escalas clínicas validadas.

### Condicionalidad ya implementada

- Mostrar enfermedades concretas cuando se declara que existen otras condiciones.
- Pedir descripción de alergia si la respuesta es afirmativa.
- Permitir agregar medicamentos cuando el tratamiento lo amerita.
- Admitir desconocimiento y campos opcionales, evitando forzar respuestas inventadas.

Las preguntas asociadas a la **hora real de una lectura, ayuno, comida y toma de medicamentos** corresponden al objetivo 2. Su lógica, excepciones, información mínima y fuentes se definirán antes de implementarlas. La hora por sí sola no se utilizará como confirmación de ayuno o de ingesta.

## Referencias y alcance

Fuentes consultadas el 24 de septiembre de 2026:

1. [NOM-004-SSA3-2012, Del expediente clínico — DOF](https://dof.gob.mx/normasOficiales/4909/SALUD/SALUD.html): apartados 5 y 6.1. Identificación, confidencialidad e integración de historia, incluyendo antecedentes, exploración, resultados, diagnóstico, pronóstico y tratamiento.
2. [NOM-015-SSA2-2010, prevención, tratamiento y control de la diabetes mellitus — DOF](https://dof.gob.mx/normasOficiales/4215/salud/salud.htm): referencia nacional para el contexto de seguimiento y tratamiento de diabetes. Su utilización no equivale a comprobar todos sus requisitos en este módulo.
3. [ADA 2026, sección 4: Comprehensive Medical Evaluation and Assessment of Comorbidities](https://doi.org/10.2337/dc26-S004): evaluación integral centrada en la persona, antecedentes, tratamientos, comorbilidades y necesidades de apoyo. Es una guía clínica internacional, no una norma mexicana.

La historia implementada es **información inicial declarada por el paciente**. El expediente clínico completo requiere valoración profesional, exploración, resultados, diagnósticos, pronóstico, indicaciones y los demás requisitos aplicables. Este objetivo no implementa un expediente electrónico completo ni acredita cumplimiento normativo integral. El domicilio se permite pendiente durante el alta para reducir carga y debe completarse cuando corresponda al expediente del servicio.

La casilla de revisión confirma las respuestas. La aceptación de invitación autoriza el vínculo dentro del producto. Ninguna sustituye un aviso institucional de privacidad o consentimiento de investigación. La definición de esos documentos y del uso en pacientes reales permanece pendiente del contexto institucional del protocolo.

## UX y decisiones revisables

- Pantallas centradas en una tarea, lenguaje cotidiano, jerarquía clara y controles con etiquetas.
- Distribución adaptable a escritorio y móvil, con navegación y validación por sección.
- Guardado explícito, progreso persistente y aviso al abandonar cambios sin guardar.
- Mensajes de carga, error y reintento; conservación del formulario cuando falla un guardado.
- Control de versiones para evitar sobrescribir un cambio hecho en otra pestaña.
- Un paciente puede vincularse a varios profesionales: cada vínculo es independiente y exige aceptación. Si se desea exclusividad con un solo médico, se cambiará esta regla antes de aprobar el modelo.
- Revisiones profesionales separadas de las respuestas del paciente para conservar autoría.

## Relación con el protocolo y las variables originales

Los originales se conservan en `docs/references/`. Este objetivo añade variables operativas necesarias para acceso y trazabilidad: identificadores de usuario/perfil/paciente/profesional, rol, estado de perfil, sección actual, revisión de historia, fecha de completitud, vínculo activo, fechas de aceptación/finalización y autor de revisión.

Los datos clínicos iniciales se describen en la tabla anterior y su contrato exacto está en `src/types/clinicalHistory.ts`. El mapeo exhaustivo entre la hoja de variables, indicadores calculados y eventos de cada workflow se realizará en los objetivos 2 y 3. No se afirma que las métricas del protocolo estén implementadas por haber creado perfiles. La evaluación prevista es operativa; este módulo no demuestra eficacia clínica.
