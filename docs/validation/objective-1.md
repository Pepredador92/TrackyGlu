# Validación local — Objetivo 1

Fecha: 24 de septiembre de 2026. Entorno: macOS Apple Silicon, Node 24.1.0, Supabase CLI 2.117.0, Docker local, API de TrackyGlu en 55321 y Chromium de Playwright. Datos exclusivamente ficticios.

## Comprobaciones realizadas

| Comprobación | Resultado |
| --- | --- |
| Migraciones desde una base local vacía (`supabase db reset --local`) | Ambas migraciones aplicadas correctamente |
| Compilación TypeScript y Vite (`npm run build`) | Correcta |
| Análisis de código (`npm run lint`) | Sin incidencias |
| API y permisos (`npm run test:integration`) | 6 grupos aprobados |
| Recorridos reales de navegador (`npm run test:browser`) | 4 pruebas aprobadas |
| Advisor de seguridad de Supabase local (`npm run db:check`) | Sin incidencias reportadas |
| Igualdad SHA-256 de workflows contra los seis originales | Coincidencia de los seis archivos |
| Revisión visual de acceso e historia inicial | Escritorio y móvil; sin desbordamiento horizontal en las vistas comprobadas |

## Cobertura de integración

- Alta de paciente/profesional, idempotencia y bloqueo de modificación de rol.
- Restricción de lecturas de glucosa antes de completar la historia; validación y persistencia del formulario.
- Conflicto entre revisiones concurrentes, guardado de versiones y relación de cada revisión profesional con su versión.
- Aislamiento entre dos pacientes y dos profesionales; denegación de revisión de historia ajena.
- Invitación de uso individual, vista previa y consulta limitada a pacientes vinculados.
- Caducidad, finalización del vínculo y comprobación de que un código consumido no restaura acceso.

## Cobertura de navegador

1. Registro de paciente, errores del formulario, avance guardado al recargar, salida y reanudación, finalización y entrada al inicio.
2. Registro de profesional, perfil, invitación, aceptación desde otra sesión de paciente, consulta de historia y nota de revisión, finalización del vínculo.
3. Capturas de login e historia a 390 px y escritorio, ausencia de desbordamiento horizontal, acceso a recuperación y referencias visibles.
4. Envío de recuperación a Mailpit, apertura del enlace recibido, cambio de contraseña, acceso con la nueva y rechazo de la anterior.

Las pruebas crean cuentas temporales y eliminan únicamente sus registros al terminar. La prueba de vínculo utiliza a la paciente ficticia de demostración, finaliza el vínculo de prueba y elimina al profesional temporal. El script de demostración deja las dos cuentas descritas en README para la revisión manual.

## Evidencias reproducibles

Los comandos y requisitos están en README. Playwright genera `test-results/previews/login-desktop.png`, `login-mobile.png`, `history-desktop.png` y `history-mobile.png`. Los resultados/capturas se regeneran localmente y están excluidos de Git. Las trazas se conservan cuando una prueba falla.

Estas comprobaciones cubren la implementación local del objetivo 1. No constituyen evaluación de usabilidad con pacientes, acreditación normativa, prueba de eficacia clínica, prueba de carga ni validación del despliegue final. No se ejecutaron los workflows de n8n ni se aplicaron cambios a bases remotas.

## Para la revisión del usuario

- Crear una cuenta de paciente para recorrer la entrevista desde cero.
- Entrar con las cuentas de demostración para revisar ambos perfiles.
- Evaluar claridad, tamaño de texto, extensión de cada sección y campos opcionales.
- Confirmar si se permite más de un profesional por paciente.
- Aprobar el objetivo antes del commit/push a `main` y de preparar la migración específica de la instancia final.
