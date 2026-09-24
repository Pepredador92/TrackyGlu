# Objetivo 3 — Automatización, eventos y evaluación operativa

Estado: contrato local implementado y validado en Supabase Docker. Fecha: 24 de septiembre de 2026.

## Qué resuelve

Este objetivo conecta el modelo de datos de TrackyGlu con los seis workflows de n8n sin mover sus credenciales. La base ahora conserva:

- cada ejecución de workflow en `public.workflow_runs`;
- cada evento de negocio en `public.events`;
- los resúmenes de continuidad y completitud en `public.adherence_summary`;
- el workflow de origen en las alertas y tareas clínicas.

`Flow-ADH-01_MedirAdherencia` quedó en versión `2.1.0`. Además de las métricas ADH de 7, 14 y 30 días, calcula `complete_days`, `completeness_pct`, `expected_readings`, `slot_coverage_pct` y `daily_slots`. Una jornada completa exige al menos una lectura válida en cada franja: mañana, tarde y noche.

## Contrato de eventos

Los eventos siguen una envoltura común:

| Campo | Uso |
| --- | --- |
| `event_id` | Identificador idempotente del evento emitido |
| `patient_id` | Sujeto al que pertenece el caso |
| `event_type` | `glucose_reading.created`, `adherence.calculated`, `alert.created`, `alert.acknowledged`, `clinical_task.created`, `clinical_task.review_started` o `clinical_task.closed` |
| `entity_type` / `entity_id` | Entidad que cambió (`glucose_reading`, `adherence_summary`, `alert`, `clinical_task`) |
| `causation_event_id` | Evento o lectura que originó el procesamiento |
| `actor_type` / `actor_profile_id` | Paciente, profesional, sistema o workflow responsable |
| `source_channel` | Canal de entrada: web, app, WhatsApp, n8n o sistema |
| `workflow_run_id` | Ejecución que produjo el evento |
| `previous_state` / `new_state` / `metadata` | Evidencia suficiente para reconstruir la transición |

El índice de idempotencia por `(entity_id, event_type)` evita duplicar transiciones aunque n8n reciba el webhook más de una vez. Los cálculos `adherence.calculated` pueden emitir una nueva evidencia cuando se recalcula el mismo periodo. Los datos de ejecución y eventos son internos del servicio (`service_role`); el resumen de adherencia solo se puede leer por el paciente o por su profesional vinculado.

## Flujo de lectura

1. Supabase/n8n recibe el webhook de `glucose_readings` en `trackyglu-glucose-reading-created`.
2. `Flow-ING-01_GlucoseReadingCreated` registra `workflow_runs` y `events` con el evento `glucose_reading.created`.
3. El flujo ejecuta `Flow-ADH-01_MedirAdherencia` y `Flow-ALR-01_TriageAlertas`.
4. ADH actualiza una fila por paciente, ventana y fecha de cierre. ALR crea una alerta solo cuando existe una regla aprobada y deja el evento de creación.
5. Cuando un profesional reconoce la alerta, ALR-02 y CLN-01 registran la transición y crean la tarea clínica idempotente.
6. CLN-02 registra el inicio y el cierre de la revisión, incluidos `final_decision` y `review_note`.

La conexión entre Supabase y los webhooks de n8n depende de la instancia donde se despliegue el proyecto. La migración deja el contrato listo, pero no inventa una URL ni activa un webhook remoto.

## Migración y despliegue

La migración versionada es `supabase/migrations/20260924150310_objective_three_workflow_contract.sql`. Para copiarla al SQL Editor existe [docs/sql/objetivo-3-supabase.sql](sql/objetivo-3-supabase.sql). En una instalación nueva se ejecutan, en orden, los SQL de objetivos 1, 2 y 3.

Después de aplicar el esquema:

1. Importa los seis JSON desde `workflows/n8n/`.
2. Revisa los identificadores de los workflows llamados por `Flow-ING-01`; n8n los renueva al importar en otra instancia.
3. Selecciona la credencial Supabase existente en cada nodo, sin pegar claves en el frontend ni reemplazar las referencias del JSON.
4. Configura los webhooks de Supabase hacia las tres rutas indicadas en el inventario y utiliza el secreto de firma de la instancia n8n.
5. Ejecuta primero un caso ficticio en staging: lectura normal, lectura `>=300 mg/dL`, duplicado, reconocimiento de alerta y cierre de tarea.

La clave `service_role` solo pertenece a los nodos de automatización del entorno servidor. El navegador sigue usando la clave pública y las políticas RLS.

## Límites documentados

- El umbral de `>=300 mg/dL` sigue siendo una regla operativa provisional del workflow ALR; no es una indicación clínica ni una meta individual.
- ADH calcula continuidad y completitud de captura. No demuestra adherencia farmacológica.
- La integración real de webhooks, credenciales y ejecución n8n requiere una instancia de n8n accesible; el repositorio valida el contrato y las migraciones en Docker.
- La evaluación operativa de latencia, duplicados, eventos fallidos y reconstrucción de casos debe ejecutarse con datos ficticios antes del despliegue definitivo.
