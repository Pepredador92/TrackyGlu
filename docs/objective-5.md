# Objetivo 5: apoyo con IA para la revisión profesional

## Resultado

Cuando `Flow-ALR-01_TriageAlertas` crea una alerta, `Flow-CLN-03_PrepararCasoClinico` reúne el snapshot auditable y llama a `Flow-CLN-04_GenerarBorradorIA`. El nuevo workflow:

1. Lee el snapshot, la tarea y el registro de fuentes permitidas.
2. Envía a OpenAI únicamente el contexto necesario para un borrador interno.
3. Solicita una respuesta estructurada con JSON Schema y valida la respuesta antes de guardarla.
4. Guarda el texto editable, las citas, el modelo, la versión del prompt y una revisión de auditoría.
5. Marca la tarea como `draft_ready` si el borrador está disponible. Un error de la IA deja la alerta y la tarea utilizables y registra `ai_draft_status = failed`.

El borrador no se muestra al paciente, no se envía automáticamente, no modifica medicamentos y no cierra la tarea. El profesional puede guardarlo como editado, marcarlo como aprobado o descartarlo; después registra por separado su decisión clínica y nota de la tarea.

## Modelo de datos

- `clinical_guideline_sources`: registro versionado de fuentes y su alcance.
- `clinical_task_drafts`: versión activa del borrador por tarea.
- `clinical_task_draft_revisions`: historial inmutable de generación, edición, aprobación, descarte y fallos.
- `clinical_case_contexts`: snapshot de evidencia preparado por el objetivo 4.

RLS permite leer el borrador solo al profesional autenticado que puede ver al paciente. La función `review_clinical_ai_draft` valida el vínculo y registra cada acción. El rol de automatización conserva las credenciales de Supabase existentes; las claves no se copian al frontend ni al repositorio.

## Ingeniería del prompt

La versión `clinical-support-v1` separa hechos, preguntas y pasos de revisión, exige declarar datos faltantes y limita las citas al registro activo. El workflow usa Structured Outputs de la Responses API para que la respuesta cumpla un esquema validable. La guía oficial de OpenAI recomienda JSON Schema estricto para salidas estructuradas; se conserva en [docs/references/clinical-guidelines/README.md](references/clinical-guidelines/README.md) junto con las fuentes clínicas del proyecto.

## Configuración en n8n

1. Importa `Flow-CLN-04_GenerarBorradorIA.json` junto con los workflows anteriores.
2. En el nodo `OpenAI Responses - Structured Output`, selecciona una credencial n8n de tipo **Header Auth** con `Authorization: Bearer <OPENAI_API_KEY>` y deja `Content-Type: application/json`.
3. Conserva la credencial Supabase existente con id `15MOY6FyWlWDp9v7`; no la reemplaces. El identificador de OpenAI del archivo es un marcador para que n8n lo resuelva en la instancia destino.
4. Revisa que `Flow-CLN-03_PrepararCasoClinico` apunte al id que n8n asigne al importar `Flow-CLN-04` y activa ambos cuando el SQL esté aplicado.
5. Activa los workflows en orden: ingestión, alertas, preparación de caso y borrador IA.

El modelo predeterminado es `gpt-4o-mini` por disponibilidad y costo. Puede cambiarse en `Build Grounded Clinical Prompt` después de evaluar calidad, latencia y costo con datos ficticios o anonimizados.

## SQL y validación

Ejecuta `docs/sql/objetivo-5-supabase.sql` después de los objetivos 1 a 4. La prueba local del objetivo valida el aislamiento RLS, la edición por RPC y el historial de revisiones; la ejecución real de OpenAI requiere una credencial configurada en n8n.
