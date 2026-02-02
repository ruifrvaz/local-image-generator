import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: true, // Allow access from WSL
    strictPort: true,
    watch: {
      usePolling: false, // Disable polling for better performance
    },
  },
  css: {
    devSourcemap: false, // Disable CSS sourcemaps in dev for speed
  },
  build: {
    cssMinify: 'lightningcss', // Faster CSS minification
  },
})
