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
//10-09-2026: empresa.ts
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

/**
 * Colores por empresa, como en el ERP y en la app de fichar.
 * La 1 (la de la demo) es azul.
 */
const COLORES: Record<string, string> = {
  '1': '#0080FF',
  '2': '#009B66',
  '3': '#000080',
  '4': '#FF6200',
}

/** Naranja: el secundario de siempre (botón Historial / Cerrar y las salidas). */
export const NARANJA = '#FF6200'

/**
 * Gris del secundario cuando el color principal YA es naranja.
 * Mismo valor y mismo criterio que WebFichar (`GRAY_ORANGE_SECONDARY`):
 * naranja sobre naranja no se distingue.
 */
export const GRIS_SECUNDARIO = '#2c3e50'

const NARANJAS = ['#FF6200', '#FF9800']
const EMPRESA_NARANJA = '4'

export function colorEmpresa(empresa: string | null | undefined): string {
  return (empresa && COLORES[empresa.trim()]) || '#0080FF'
}

/**
 * El color del botón secundario. Si el principal es naranja (tema naranja o
 * empresa 4), pasa a gris; si no, se queda en naranja.
 */
export function colorSecundario(principal: string, empresa?: string | null): string {
  const esNaranja =
    NARANJAS.includes(principal.trim().toUpperCase()) || empresa?.trim() === EMPRESA_NARANJA
  return esNaranja ? GRIS_SECUNDARIO : NARANJA
}
