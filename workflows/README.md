# Workflows del proyecto

Los seis archivos de `n8n/` se copiaron desde los JSON entregados por el usuario, sin cambios de contenido, conexiones, claves o referencias de credenciales. Se comprobó igualdad SHA-256 con los originales de Downloads.

| Archivo | Función indicada por su contrato actual |
| --- | --- |
| Flow-ING-01_GlucoseReadingCreated.json | Ingestión del evento de lectura de glucosa |
| Flow-ADH-01_MedirAdherencia.json | Cálculo de adherencia |
| Flow-ALR-01_TriageAlertas.json | Evaluación y clasificación de alertas |
| Flow-ALR-02_AlertStatusChanged.json | Cambio de estado de una alerta |
| Flow-CLN-01_WorkQueueClinica.json | Cola de trabajo clínico |
| Flow-CLN-02_ClinicalTaskStatusChanged.json | Cambio de estado de una tarea clínica |

## Forma de trabajo

Esta carpeta es la copia de trabajo versionada para las adaptaciones solicitadas. Cada cambio deberá documentar qué variables, tablas, eventos o reglas cambia y su fundamento. El objetivo 1 conserva los originales; no se importaron ni ejecutaron en n8n y no se afirma compatibilidad completa con la base local nueva.

Los objetivos 2 y 3 definirán el contrato compartido con los perfiles y las métricas del protocolo. Antes de importar en otra instancia se revisarán los identificadores de credenciales y recursos que dependen de esa instancia. Las conexiones existentes se mantienen hasta que haya una adaptación concreta acordada.

Fuentes del proyecto: `docs/references/Variables de Protocolo de experimentación.xlsx` y `docs/references/TESIS_PROTOCOLO_EVALUACION_OPERATIVA_v1.0_DRAFT.pdf`.
