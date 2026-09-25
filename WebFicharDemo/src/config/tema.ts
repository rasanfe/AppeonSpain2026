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
//10-09-2026: tema.ts
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

/**
 * Coordinación de temas PowerBuilder -> web.
 *
 * El ERP se pinta con un tema de PowerBuilder (Setting.ini, [Setup] Theme).
 * Cuando la ventana abre la web le pasa ese nombre, y la web se viste igual:
 * la aplicación de escritorio y la web embebida dejan de parecer dos cosas.
 *
 * Es lo mismo que ya hace el grid de facturas con `window.setTheme(...)`.
 */
export interface Tema {
  /** Color de los fondos grandes: cabecera, cabecera de tabla, calendario. */
  color: string
  oscuro: boolean
  /** Color de los detalles (la "E", el día elegido, las etiquetas del pie).
   *  En los temas oscuros el color de fondo no se lee sobre fondo oscuro,
   *  así que hace falta uno más claro. */
  acento?: string
}

const TEMAS_PB: Record<string, Tema> = {
  'flat design blue': { color: '#0080FF', oscuro: false },
  'flat design orange': { color: '#FF6200', oscuro: false },
  'flat design lime': { color: '#7CB342', oscuro: false },
  'flat design grey': { color: '#607D8B', oscuro: false },
  'flat design silver': { color: '#78909C', oscuro: false },
  'flat design dark': { color: '#2C3E50', oscuro: true, acento: '#5DADE2' },
}

/** Traduce el nombre del tema de PowerBuilder. Si no lo conoce, devuelve null
 *  y manda el color de la empresa, como fuera del ERP. */
export function temaDePowerBuilder(nombre: string | null | undefined): Tema | null {
  if (!nombre) return null
  return TEMAS_PB[nombre.trim().toLowerCase()] ?? null
}
