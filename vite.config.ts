import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

const proxy = {
  // Supabase
  '/auth': {
    target: 'http://127.0.0.1:8000',
    changeOrigin: true,
  },
  '/rest': {
    target: 'http://127.0.0.1:8000',
    changeOrigin: true,
  },
  '/storage': {
    target: 'http://127.0.0.1:8000',
    changeOrigin: true,
  },
  '/functions': {
    target: 'http://127.0.0.1:8000',
    changeOrigin: true,
  },
  '/realtime': {
    target: 'http://127.0.0.1:8000',
    changeOrigin: true,
    ws: true,
  },

  // n8n
  '/webhook-test': {
    target: 'http://127.0.0.1:5678',
    changeOrigin: true,
  },
  '/webhook': {
    target: 'http://127.0.0.1:5678',
    changeOrigin: true,
  },
}

export default defineConfig({
  plugins: [react()],

  server: {
    host: '0.0.0.0',
    allowedHosts: true,
    proxy,
  },

  preview: {
    host: '0.0.0.0',
    port: 4173,
    strictPort: true,
    allowedHosts: true,
    proxy,
  },
})
