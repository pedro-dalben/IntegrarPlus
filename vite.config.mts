import { defineConfig } from "vite";
import ViteRails from "vite-plugin-rails";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [
    tailwindcss(),
    ViteRails({
      envVars: { RAILS_ENV: "development" },
      envOptions: { defineOn: "import.meta.env" },
      fullReload: {
        additionalPaths: ["config/routes.rb", "app/views/**/*"],
        delay: 300,
      },
    }),
  ],
  build: { 
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: {
          'dhx-suite': ['dhx-suite'],
          'pdf-libs': ['jspdf', 'html2canvas'],
          'csv-libs': ['papaparse']
        }
      }
    },
    chunkSizeWarningLimit: 1000
  },
});