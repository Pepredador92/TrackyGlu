# Workflows del proyecto

Los seis archivos originales y los flujos clínicos de preparación y apoyo viven en `n8n/`. Las referencias de Supabase y conexiones existentes se conservan; el objetivo 3 adapta el contrato de datos y la lógica de `Flow-ADH-01_MedirAdherencia` a la completitud por franjas, el objetivo 4 prepara el caso auditable y el objetivo 5 genera un borrador IA editable para el profesional.

| Archivo | Función indicada por su contrato actual |
| --- | --- |
| Flow-ING-01_GlucoseReadingCreated.json | Ingestión del evento de lectura de glucosa |
| Flow-ADH-01_MedirAdherencia.json | Cálculo de adherencia |
| Flow-ALR-01_TriageAlertas.json | Evaluación y clasificación de alertas |
| Flow-ALR-02_AlertStatusChanged.json | Cambio de estado de una alerta |
| Flow-CLN-01_WorkQueueClinica.json | Cola de trabajo clínico |
| Flow-CLN-02_ClinicalTaskStatusChanged.json | Cambio de estado de una tarea clínica |
| Flow-CLN-03_PrepararCasoClinico.json | Preparación del snapshot clínico después de una alerta |
| Flow-CLN-04_GenerarBorradorIA.json | Borrador estructurado, con fuentes, para editarlo en la revisión profesional |

## Forma de trabajo

Esta carpeta es la copia de trabajo versionada para las adaptaciones solicitadas. Cada cambio documenta qué variables, tablas, eventos o reglas cambia y su fundamento. El objetivo 1 validó la igualdad de los seis archivos entregados; el objetivo 3 conserva esa referencia en el historial Git y actualiza el flujo de adherencia a la versión 2.1.0.

Los objetivos 2 y 3 definen el contrato compartido con los perfiles y las métricas del protocolo. Antes de importar en otra instancia se revisarán los identificadores de credenciales y recursos que dependen de esa instancia. Las conexiones existentes se mantienen; la migración de objetivo 3 agrega las tablas y columnas que los nodos Supabase ya esperan.

El objetivo 4 conecta `alert.created` con `Flow-CLN-03_PrepararCasoClinico`. El flujo reúne historia, lectura disparadora, lecturas recientes, contexto diario y resúmenes de adherencia; crea una tarea para el profesional vinculado y persiste `clinical_case_contexts`. Un caso sin profesional queda en `waiting_professional`.

El objetivo 5 llama a `Flow-CLN-04_GenerarBorradorIA` después de guardar el contexto. La salida usa JSON Schema, se valida contra las fuentes activas y queda como borrador editable. Si OpenAI falla, el caso conserva su alerta, tarea y snapshot; solo se registra el fallo del borrador. El workflow se importa inactivo para que la instancia configure la credencial Header Auth de OpenAI antes de activarlo.

`Flow-ADH-01_MedirAdherencia` versión 2.1.0 calcula continuidad, completitud (mañana/tarde/noche), cobertura de franjas y el detalle diario `daily_slots` para las ventanas de 7, 14 y 30 días. Los otros cinco workflows conservan sus reglas y consumen el mismo contrato de `workflow_runs`, `events`, `alerts` y `clinical_tasks`.

Fuentes del proyecto: `docs/references/Variables de Protocolo de experimentación.xlsx` y `docs/references/TESIS_PROTOCOLO_EVALUACION_OPERATIVA_v1.0_DRAFT.pdf`.
