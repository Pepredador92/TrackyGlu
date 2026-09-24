# Workflows del proyecto

Los seis archivos de `n8n/` se copiaron desde los JSON entregados por el usuario. Las referencias de credenciales y conexiones se conservan; el objetivo 3 adapta únicamente el contrato de datos y la lógica de `Flow-ADH-01_MedirAdherencia` a la completitud por franjas, sin sustituir claves.

| Archivo | Función indicada por su contrato actual |
| --- | --- |
| Flow-ING-01_GlucoseReadingCreated.json | Ingestión del evento de lectura de glucosa |
| Flow-ADH-01_MedirAdherencia.json | Cálculo de adherencia |
| Flow-ALR-01_TriageAlertas.json | Evaluación y clasificación de alertas |
| Flow-ALR-02_AlertStatusChanged.json | Cambio de estado de una alerta |
| Flow-CLN-01_WorkQueueClinica.json | Cola de trabajo clínico |
| Flow-CLN-02_ClinicalTaskStatusChanged.json | Cambio de estado de una tarea clínica |

## Forma de trabajo

Esta carpeta es la copia de trabajo versionada para las adaptaciones solicitadas. Cada cambio documenta qué variables, tablas, eventos o reglas cambia y su fundamento. El objetivo 1 validó la igualdad de los seis archivos entregados; el objetivo 3 conserva esa referencia en el historial Git y actualiza el flujo de adherencia a la versión 2.1.0.

Los objetivos 2 y 3 definen el contrato compartido con los perfiles y las métricas del protocolo. Antes de importar en otra instancia se revisarán los identificadores de credenciales y recursos que dependen de esa instancia. Las conexiones existentes se mantienen; la migración de objetivo 3 agrega las tablas y columnas que los nodos Supabase ya esperan.

`Flow-ADH-01_MedirAdherencia` versión 2.1.0 calcula continuidad, completitud (mañana/tarde/noche), cobertura de franjas y el detalle diario `daily_slots` para las ventanas de 7, 14 y 30 días. Los otros cinco workflows conservan sus reglas y consumen el mismo contrato de `workflow_runs`, `events`, `alerts` y `clinical_tasks`.

Fuentes del proyecto: `docs/references/Variables de Protocolo de experimentación.xlsx` y `docs/references/TESIS_PROTOCOLO_EVALUACION_OPERATIVA_v1.0_DRAFT.pdf`.
