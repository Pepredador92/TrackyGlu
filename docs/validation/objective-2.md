# Validación local — Objetivo 2

Fecha: 24 de septiembre de 2026. Entorno: Supabase local en Docker, API 55321, aplicación Vite en 5173 y Chromium de Playwright. Los datos de demostración son ficticios.

## Comprobaciones

| Prueba | Resultado |
| --- | --- |
| Reset local desde cero con la nueva migración | Aplicado correctamente |
| Advisor de seguridad (`npm run db:check`) | Sin incidencias |
| Compilación y tipos (`npm run build`) | Correcta |
| Lint (`npm run lint`) | Sin incidencias |
| Integración de permisos | 6 grupos aprobados |
| Registro contextual en navegador | Primera lectura, comida, hora de comida, actividad opcional y persistencia aprobados |
| Dashboard del paciente | Lecturas, promedio, continuidad, completitud, racha y gráficas de tendencia/completitud/zonas aprobados |
| Dashboard profesional | Historia vinculada, resumen de 30 días y las tres gráficas del paciente aprobados |
| Separación de datos | Profesional ve contexto solo después de aceptar el vínculo; otro paciente no ve el check-in diario |

## Datos comprobados

- Una lectura no se puede insertar antes de completar la historia inicial.
- La lectura contextual conserva fuente, contexto posprandial, comida, hora de comida y síntomas.
- Una hora de comida posterior a la lectura se rechaza por la restricción de la base.
- El check-in diario usa una fila por paciente y fecha y puede leerse por el profesional vinculado.
- El profesional no puede editar lecturas ni consultar las de un paciente no vinculado.
- La primera captura del día presenta preguntas adicionales y las lecturas siguientes no repiten el aviso de primera lectura.
- La continuidad se calcula como días con al menos una lectura; la completitud exige una lectura en cada franja de mañana, tarde y noche.
- La tendencia cartesiana distingue las zonas `<70`, `70–180` y `>180 mg/dL`; la distribución por zona conserva esos mismos colores y porcentajes.

## Alcance de la evidencia

La validación confirma el comportamiento local, la protección de filas y las fórmulas descriptivas. No valida eficacia clínica, metas individualizadas, usabilidad en población real, exactitud de glucómetros, integración con CGM ni ejecución de n8n. La conectividad con dispositivos, las alertas clínicas y las métricas persistidas del protocolo pertenecen al objetivo 3.
