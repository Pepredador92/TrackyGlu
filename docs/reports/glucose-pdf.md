# Reporte PDF de seguimiento

TrackyGlu permite descargar un resumen compacto en PDF desde:

- **Paciente:** `Inicio > Tu seguimiento > Exportar PDF`. Incluye sus datos clínicos declarados, métricas de los últimos 14 días, gráficas de tendencia, continuidad/completitud, distribución por zonas, notas profesionales visibles para el paciente y seis lecturas recientes.
- **Profesional:** `Paciente > Exportar PDF`. Incluye la misma estructura con los últimos 30 días, la historia del paciente, la última revisión registrada y el nombre del profesional que prepara el reporte.

El reporte es descriptivo. Los rangos de 70-180 mg/dL, las zonas baja/alta y los indicadores de continuidad y completitud se presentan como resumen de los registros, no como metas individuales ni cambios de tratamiento.

El generador usa `jsPDF`, dibuja las gráficas como elementos vectoriales y se carga bajo demanda al pulsar el botón. El archivo se descarga con el patrón `trackyglu-reporte-nombre-fecha.pdf`.
