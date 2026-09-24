# Objetivo 4 — Preparación del caso clínico para revisión profesional

Estado: implementado en el repositorio y preparado para validación local. Fecha: 24 de septiembre de 2026.

## Qué resuelve

Cuando `Flow-ALR-01_TriageAlertas` crea una alerta, ejecuta `Flow-CLN-03_PrepararCasoClinico`. El nuevo flujo prepara una fotografía auditable del caso antes de que exista cualquier generación de texto con IA.

El contexto queda asociado a la alerta y, cuando existe un profesional vinculado, a una tarea clínica. La tarea aparece en la cola profesional con el estado `pending_review`. La aplicación muestra qué evidencia se reunió y qué información falta; todavía no presenta una recomendación automática.

## Evidencia reunida

El snapshot de `clinical_case_contexts` contiene:

- la alerta y su regla de origen;
- la lectura que disparó la alerta;
- la historia clínica vigente, su revisión y fecha de actualización;
- las lecturas válidas y persistidas de los últimos 30 días;
- el contexto diario disponible de los últimos 7 días;
- los resúmenes de continuidad y completitud disponibles;
- una lista explícita de datos que no estaban disponibles.

El flujo conserva el contexto dentro de `service_role`. La cola profesional solo puede leer casos de pacientes a los que el profesional tiene acceso mediante RLS.

## Estados del contexto

| Estado | Significado |
| --- | --- |
| `prepared` | Existe un vínculo profesional y están disponibles los elementos esperados. |
| `partial` | Existe un vínculo, pero falta evidencia opcional o histórica. |
| `waiting_professional` | La alerta se conservó, pero no existe un vínculo profesional activo para asignar la tarea. |
| `failed` | El flujo no pudo encontrar la alerta de origen o completar la preparación. |

La alerta no se elimina ni se convierte en una indicación para el paciente cuando la preparación falla. Un futuro objetivo podrá reintentar los casos en espera después de crear el vínculo profesional.

## Idempotencia y relación con los workflows existentes

- `clinical_case_contexts.source_alert_id` es único para que una alerta genere un solo snapshot.
- `clinical_tasks.source_alert_id` tiene un índice único parcial para evitar dos tareas para la misma alerta.
- `Flow-CLN-01_WorkQueueClinica` consulta cualquier tarea de la alerta. Si recibe después el evento de reconocimiento, registra la ejecución como duplicada cuando `CLN-03` ya creó la tarea.
- Cada ejecución deja su fila en `workflow_runs` y emite `clinical_case.context_prepared` en `events`.
- `ai_draft_status` permanece en `not_requested`. La generación del borrador, las fuentes y los prompts pertenecen al objetivo 5.

## Instalación en n8n

1. Ejecuta la migración del objetivo 4 después de los objetivos 1, 2 y 3.
2. Importa `Flow-CLN-03_PrepararCasoClinico.json`.
3. Revisa que la referencia del workflow llamado por `Execute Flow-CLN-03` apunte al identificador que n8n asigne al importar.
4. Selecciona la credencial Supabase existente en los nodos del nuevo flujo.
5. Activa el nuevo flujo y `Flow-ALR-01` en el mismo entorno de prueba.
6. Ejecuta un caso ficticio con una lectura que cumpla la regla de alerta y confirma la tarea, el snapshot y el evento.

## Límites

- La regla de alerta sigue siendo la regla operativa existente del proyecto. Preparar el caso no convierte el umbral en una meta clínica individual.
- El snapshot es evidencia de apoyo y no una recomendación, diagnóstico ni cambio de tratamiento.
- Si no hay resúmenes persistidos de adherencia, el flujo conserva las lecturas y marca `adherence_summary` como dato faltante.
- La ejecución dentro de una instancia n8n accesible y el webhook remoto se validarán en el entorno de despliegue.
