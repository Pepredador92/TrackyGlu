# TrackyGlu

## Desarrollo local

TrackyGlu se conecta a Supabase desde el navegador usando una clave pública (publishable o anon legacy). Nunca debe usarse `SUPABASE_SERVICE_ROLE_KEY` ni una secret key en el frontend.

Crea un archivo local no versionado llamado `.env.local` con:

```env
VITE_SUPABASE_URL=http://localhost:8000
VITE_SUPABASE_PUBLISHABLE_KEY=
```

Si tu Supabase self-hosted todavía usa la clave legacy `ANON_KEY`, también se admite:

```env
VITE_SUPABASE_URL=http://localhost:8000
VITE_SUPABASE_ANON_KEY=
```

Después reinicia Vite:

```bash
npm run dev
```

`.env.local` está excluido por `.gitignore`, por lo que los valores reales permanecen solo en la máquina de desarrollo.
