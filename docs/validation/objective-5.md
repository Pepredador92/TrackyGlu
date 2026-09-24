# Validación del objetivo 5

## Comprobaciones locales

| Comprobación | Resultado esperado |
| --- | --- |
| Migración desde una base local vacía | Crea fuentes, borradores, revisiones, RLS y RPC sin errores. |
| Profesional vinculado lee un borrador | Puede leer el borrador de su paciente. |
| Profesional no vinculado y paciente leen el borrador | No reciben filas por RLS. |
| RPC de edición | Cambia el estado permitido y registra una revisión con el actor profesional. |
| RPC con texto vacío o estado inválido | Rechaza la operación. |
| Workflow sin respuesta válida de IA | Guarda el fallo y deja la tarea disponible para revisión. |
| Workflow con borrador existente | Reutiliza el borrador y evita otra llamada. |

La prueba local no demuestra eficacia clínica, exactitud diagnóstica, seguridad de una indicación terapéutica ni rendimiento del proveedor de IA. La instancia n8n debe probarse con una credencial de staging y datos sintéticos antes de usarla con pacientes.
