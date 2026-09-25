//╔═════════════════════════════════════════════════════════════════════════════════╗
//║                                                                                 ║
//║  ██████╗ ███████╗██████╗ ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗  ║
//║  ██╔══██╗██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║  ║
//║  ██████╔╝███████╗██████╔╝███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║  ║
//║  ██╔══██╗╚════██║██╔══██╗╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║  ║
//║  ██║  ██║███████║██║  ██║███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║  ║
//║  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝  ║
//║                                                                                 ║
//╚═════════════════════════════════════════════════════════════════════════════════╝
//
//10-09-2026: vite.config.ts
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'
import { readFileSync } from 'fs'

// Puerto de la API demo. Debe coincidir con DEMO_API_PORT del .env.
const API = 'http://localhost:5080'

// Version y fecha se pintan en el pie del login, como en WebFichar.
// La fecha NO es la del build: es la del dia de la charla, fija a proposito,
// para que lo que se ve en pantalla diga siempre 27/10/2026 se compile cuando
// se compile (incluido un rebuild de ultima hora en el portatil).
const VERSION = JSON.parse(readFileSync('./package.json', 'utf-8')).version
const FECHA = '27/10/2026'

export default defineConfig({
  define: {
    __VERSION__: JSON.stringify(VERSION),
    __BUILD_DATE__: JSON.stringify(FECHA),
  },
  plugins: [
    react(),
    // La PWA es lo que permite enseñarla en el movil sin APK ni tienda.
    VitePWA({
      registerType: 'autoUpdate',
      // Lo que NO este aqui (o entre los iconos del manifest) no se precachea:
      // la PWA instalada sale a la red a buscarlo y, sin servidor a la vista,
      // no aparece. Le paso el logo del login, que es justo lo que le pasaba.
      includeAssets: [
        'images/favicon.ico',
        'images/favicon.png',
        'images/apple-touch-icon.png',
        'images/logo.png',
      ],
      manifest: {
        name: 'Fichar Demo',
        short_name: 'Fichar',
        description: 'Demo de fichaje - Appeon Regional Conference Spain 2026',
        lang: 'es',
        theme_color: '#0080FF',
        background_color: '#ffffff',
        display: 'standalone',
        orientation: 'portrait',
        start_url: '/',
        scope: '/',
        // Sin iconos, el movil no ofrece "añadir a pantalla de inicio",
        // que es justo lo que hay que enseñar en la charla.
        icons: [
          { src: 'images/pwa-192x192.png', sizes: '192x192', type: 'image/png' },
          { src: 'images/pwa-512x512.png', sizes: '512x512', type: 'image/png' },
          { src: 'images/pwa-maskable-192x192.png', sizes: '192x192', type: 'image/png', purpose: 'maskable' },
          { src: 'images/pwa-maskable-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' }
        ]
      }
    })
  ],
  server: {
    port: 5173,
    host: true,          // para poder abrirla desde el movil por la IP de la maquina
    proxy: { '/api': API }
  },
  // El build cae DENTRO de la API: un solo proceso sirve web + endpoints.
  build: {
    outDir: '../FicharDemoApi/wwwroot',
    emptyOutDir: true
  }
})
