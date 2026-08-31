import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  // Releases are served below `releases/<version>/` in Object Storage.
  // Relative asset paths keep each immutable release self-contained.
  base: './',
})
