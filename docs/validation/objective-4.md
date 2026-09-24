# Validación local — Objetivo 4

Fecha: 24 de septiembre de 2026. Entorno: Supabase local en Docker. Los datos de prueba son ficticios.

## Comprobaciones

| Prueba | Resultado esperado |
| --- | --- |
| Migración sobre el esquema de objetivos 1–3 | Crea `clinical_case_contexts`, sus índices, trigger y política RLS. |
| Contexto sin vínculo profesional | Conserva la alerta y registra `waiting_professional` sin crear una tarea asignada. |
| Contexto con datos incompletos | Crea la tarea y marca `partial` con `missing_data`. |
| Contexto completo | Crea una tarea `pending_review`, un snapshot `prepared` y un evento `clinical_case.context_prepared`. |
| Repetición de la misma alerta | El índice único evita un segundo contexto; el workflow cierra la ejecución como duplicada. |
| Reconocimiento posterior de la alerta | `Flow-CLN-01` detecta la tarea existente por `source_alert_id` y no crea otra. |
| Acceso de terceros | RLS impide que un profesional no vinculado lea el contexto. |
| Validación estructural de workflows | Los siete JSON tienen referencias de credenciales, tablas documentadas y rutas webhook únicas. |

La validación de ejecución real dentro de n8n requiere importar los JSON en la instancia de destino y ejecutar un payload ficticio. El objetivo 4 deja el contrato y el recorrido listos para esa prueba.
