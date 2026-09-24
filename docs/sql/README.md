# SQL para Supabase

El archivo [objetivo-1-supabase.sql](objetivo-1-supabase.sql) es la versión consolidada de las migraciones versionadas del objetivo 1.

El archivo [objetivo-2-supabase.sql](objetivo-2-supabase.sql) es la ampliación de contexto y métricas. Se ejecuta después del objetivo 1.

El archivo [objetivo-3-supabase.sql](objetivo-3-supabase.sql) agrega el contrato de automatización: ejecuciones de workflows, eventos, resúmenes persistidos de continuidad/completitud y vínculos de origen en alertas y tareas. Se ejecuta después de los objetivos 1 y 2.

El archivo [objetivo-4-supabase.sql](objetivo-4-supabase.sql) agrega el snapshot auditable del caso clínico, sus estados, permisos e idempotencia. Se ejecuta después de los objetivos 1, 2 y 3.

El archivo [objetivo-5-supabase.sql](objetivo-5-supabase.sql) agrega el registro de fuentes, borradores de apoyo con IA, revisiones auditables, RLS y la función de edición profesional. Se ejecuta después de los objetivos 1 a 4.

## Pegar en Supabase Dashboard

1. Confirma que seleccionaste el proyecto **nuevo/vacío** destinado a TrackyGlu.
2. Entra a **SQL Editor → New query**.
3. Copia todo `objetivo-1-supabase.sql`, pégalo y ejecuta.
4. Verifica que termine sin error y que las tablas aparezcan en Table Editor.

Este script crea tablas de glucosa, perfiles, pacientes, profesionales, historia clínica inicial, vínculos, invitaciones, revisiones y contratos básicos de alertas y tareas. También configura funciones, índices, triggers y políticas RLS.

**No lo pegues sobre una base existente con datos.** El primer esquema de lecturas trae `patient_id` como texto y la migración lo convierte a UUID con relación al paciente. Si la instancia ya guarda lecturas, registros de Auth, perfiles, eventos o tablas equivalentes, se requiere preparar una migración de adaptación para sus datos reales; ejecutarlo a ciegas podría fallar o asociar mal identificadores.

La migración está probada en un Supabase local vacío con `npm run db:reset`. Después de cambios al esquema, actualiza las migraciones, regenera este consolidado y repite esa validación. Para la instalación final se revisarán también credenciales de workflows, Auth/correo y configuración de dominio según el entorno.

Para el objetivo 2, ejecuta primero el SQL del objetivo 1 y después el SQL del objetivo 2. La segunda parte agrega columnas a `glucose_readings`, índices, validaciones, permisos y `glucose_daily_context`. No ejecutes la ampliación si la instancia no tiene el esquema del objetivo 1.

Para el objetivo 3, ejecuta después el SQL del objetivo 3. La tercera parte requiere las tablas y políticas de los objetivos anteriores. El acceso de automatización se mantiene en `service_role`; el frontend no recibe esa clave.

Para el objetivo 4, ejecuta después el SQL del objetivo 4. Crea `clinical_case_contexts` y el índice que limita a una tarea clínica por alerta. El workflow de preparación usa `service_role`; el profesional solo lee el snapshot de sus pacientes vinculados mediante RLS.

Para el objetivo 5, ejecuta después el SQL del objetivo 5. Crea `clinical_guideline_sources`, `clinical_task_drafts` y `clinical_task_draft_revisions`. La automatización escribe con `service_role`; el profesional modifica el borrador mediante `review_clinical_ai_draft`, que valida su vínculo y registra la revisión.
