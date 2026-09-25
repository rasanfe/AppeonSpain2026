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
//10-09-2026: appConfig.ts
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

/**
 * Configuracion de la demo. Un solo sitio: aqui.
 * En desarrollo Vite hace de proxy a la API; en produccion la propia API
 * sirve estos ficheros, asi que la ruta relativa vale en los dos casos.
 */
export const APP_CONFIG = {
  apiUrl: '/api',
  nombre: 'Fichar',
  subtitulo: 'Control Horario',
  version: __VERSION__,
  fechaBuild: __BUILD_DATE__,
  autor: 'Ramón San Félix Ramón',
  evento: 'Appeon PowerBuilder Regional Conference · Spain 2026',
  rutas: {
    login: '/login',
    fichar: '/',
    sso: '/sso',
  },
  /** Cada cuanto refresca la lista de fichajes (ms). Es lo que hace que
   *  fichar desde el movil se vea aparecer dentro de PowerBuilder. */
  refrescoMs: 3000,
  /** Lo que se espera al GPS antes de fichar sin coordenadas. */
  gpsTimeoutMs: 4000,
} as const
