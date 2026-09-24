# Validación local — Objetivo 3

Fecha: 24 de septiembre de 2026. Entorno: Supabase local en Docker. Los datos de demostración y los payloads de humo son ficticios.

## Comprobaciones

| Prueba | Resultado |
| --- | --- |
| Reset local con el contrato de workflows | Aplicado correctamente |
| Advisor de seguridad (`npm run db:check`) | Sin incidencias |
| Persistencia de `workflow_runs` en estado running → succeeded | Aprobada |
| Persistencia de `events` con `workflow_run_id` y estado nuevo | Aprobada |
| Persistencia de `adherence_summary` con continuidad y completitud | Aprobada |
| Idempotencia de transiciones y recálculo ADH | Aprobada: transiciones duplicadas se rechazan; dos cálculos ADH quedan trazados |
| Lectura de resúmenes por el contrato RLS | Paciente/profesional vinculado permitido; terceros bloqueados |
| Validación estructural de los seis JSON de n8n | Aprobada |

## Datos comprobados

- `workflow_runs` no queda expuesto a `anon` ni a `authenticated`.
- `events` es interno de automatización y conserva la relación causal sin exigir que la lectura original sea otro evento; las transiciones tienen idempotencia y los recálculos de ADH pueden dejar nueva evidencia.
- `adherence_summary` permite las ventanas 7, 14 y 30 y evita duplicar un periodo con una clave única.
- Alertas y tareas aceptan `source_event_id`/`workflow_run_id` para reconstruir el origen.
- El workflow ADH 2.1.0 conserva las referencias de credenciales y agrega las cinco salidas de completitud.

## Alcance de la evidencia

La validación confirma el contrato de base y la forma de los JSON. No simula una ejecución dentro de n8n ni confirma la entrega de un webhook remoto; esa prueba requiere importar los workflows en la instancia n8n de despliegue y usar un entorno de staging.
