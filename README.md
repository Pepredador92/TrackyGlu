# TrackyGlu

Plataforma de seguimiento de glucosa para pacientes y profesionales. React, TypeScript, Vite y Supabase. El trabajo actual se desarrolla en archivos locales; el push a `main` se realiza después de aprobar cada objetivo.

## Tres objetivos

1. **Acceso y perfiles:** registro, inicio y recuperación de sesión, historia inicial por secciones y vínculo paciente–profesional. Implementado para revisión local.
2. **Seguimiento y métricas:** captura contextual de glucosa, dashboards de paciente y profesional, interpretación y justificación de cada indicador.
3. **Automatización y evaluación:** adaptación de workflows, contratos de eventos, evaluación operativa y preparación del despliegue definitivo.

## Arranque reproducible en desarrollo

Requisitos: Node compatible con Vite 8 (22.12+ o versión posterior compatible), npm y Docker funcionando. El entorno fue probado en macOS Apple Silicon. La CLI de Supabase está fijada en las dependencias del proyecto.

```bash
npm ci
npm run db:start
npm run setup:local
npm run demo:local
npm run dev -- --host localhost
```

La primera ejecución descarga las imágenes Docker y aplica las migraciones. `setup:local` crea `.env.local` con la URL y la clave pública del Supabase local; conserva un archivo existente. Si ya hay configuración de otra instalación, revisar su destino antes de iniciar. El frontend admite `VITE_SUPABASE_PUBLISHABLE_KEY` o `VITE_SUPABASE_ANON_KEY` legacy.

| Servicio local de TrackyGlu | Dirección |
| --- | --- |
| Aplicación | http://localhost:5173 |
| API Supabase | http://127.0.0.1:55321 |
| PostgreSQL | localhost:55322 |
| Studio | http://127.0.0.1:55323 |
| Correo de desarrollo (Mailpit) | http://127.0.0.1:55324 |

Estos puertos separan TrackyGlu de otras instalaciones locales. El comando de arranque habilita los servicios necesarios para el objetivo 1. Realtime, Storage y funciones Edge se incorporarán cuando haya funcionalidades que los requieran. La confirmación de correo está desactivada en esta configuración **local**; los enlaces de recuperación se reciben en Mailpit.

### Cuentas ficticias para revisar

| Perfil | Correo | Contraseña local |
| --- | --- | --- |
| Paciente: Elena Martínez | paciente@trackyglu.test | TrackyGlu2026! |
| Profesional: Andrea García | profesional@trackyglu.test | TrackyGlu2026! |

Estas cuentas están vinculadas y contienen datos ficticios. `demo:local` conserva los cambios existentes y no reactiva vínculos finalizados. También puedes crear cuentas desde la interfaz para revisar el alta completa.

## Comprobaciones

Con Docker iniciado y los datos de demostración creados:

```bash
npm run build
npm run lint
npm run test:integration
npx playwright install chromium
npm run test:browser
npm run db:check
```

Las pruebas de integración y sus utilidades administrativas solo admiten el Supabase local en el puerto 55321. Las pruebas de navegador esperan la aplicación configurada contra ese mismo entorno. Playwright inicia Vite automáticamente si el puerto 5173 está libre. Las capturas quedan en `test-results/previews/`.

Para reconstruir **exclusivamente los datos locales de desarrollo** desde las migraciones:

```bash
npm run db:reset
npm run demo:local
```

`db:reset` borra los datos del proyecto Supabase local. Para detener sus contenedores conservando el entorno: `npm run db:stop`.

## Estructura y documentación

- `src/`: interfaz, rutas, contratos y servicios.
- `supabase/migrations/`: SQL versionado para una instalación nueva de desarrollo.
- `workflows/n8n/`: los seis workflows originales; conexiones y credenciales conservadas.
- `docs/references/`: Excel de variables y protocolo PDF originales.
- [Objetivo 1 y fundamento de las decisiones](docs/objective-1.md).
- [Datos, permisos y preparación de otra instalación](docs/architecture/access-profiles.md).
- [Resultados de validación](docs/validation/objective-1.md).
- [Inventario de workflows](workflows/README.md).

## Continuar en otro equipo

Después de aprobar el objetivo y subirlo a `main`, clonar el repositorio y seguir el arranque local anterior. Git transporta código, documentos, workflows y migraciones; los datos y volúmenes Docker requieren su propia transferencia si se desean conservar. La configuración `.env.local` se prepara en cada equipo.

Para alojar el proyecto definitivamente, se confirmarán dominio, correo, configuración de Auth, copia de datos y esquema de la instancia Supabase self-hosted. La migración de este objetivo crea una base nueva: **una instancia que ya contiene tablas requiere conciliación previa del esquema**. El SQL definitivo para esa instancia se prepara después de aprobar el modelo; véase la documentación de arquitectura.

El script consolidado para copiar y pegar en el SQL Editor de un Supabase **nuevo y vacío** está en [docs/sql/objetivo-1-supabase.sql](docs/sql/objetivo-1-supabase.sql). Lee primero [sus instrucciones](docs/sql/README.md); no lo ejecutes sobre una instancia existente con datos.
