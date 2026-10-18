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
//17-10-2026: historial.ts
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

import type { Fichaje } from '../services/api'

/**
 * Los cálculos del historial, los mismos que FichajesHistoricoService de
 * WebFichar: agrupar por día, E/S por posición dentro del día y horas
 * trabajadas sumando cada pareja entrada-salida.
 */

export const MESES = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto',
  'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']

const DIAS_SEMANA = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']

export interface FichajeDelDia extends Fichaje {
  /** 'E' o 'S', según el orden dentro del día. */
  Tipo: 'E' | 'S'
}

export interface DiaHistorial {
  /** "Miércoles 14/10/2026", como lo pinta WebFichar. */
  fecha: string
  fechaDate: Date
  totalHoras: number
  fichajes: FichajeDelDia[]
}

/** Primer y último día del mes de una fecha. */
export function rangoMes(fecha: Date): { desde: Date; hasta: Date } {
  return {
    desde: new Date(fecha.getFullYear(), fecha.getMonth(), 1),
    hasta: new Date(fecha.getFullYear(), fecha.getMonth() + 1, 0),
  }
}

/** Agrupa por día, el más reciente primero. */
export function agruparPorDia(fichajes: Fichaje[]): DiaHistorial[] {
  const porFecha = new Map<string, Fichaje[]>()
  for (const f of fichajes) {
    if (!f.Datetime) continue
    const clave = f.Datetime.substring(0, 10)
    porFecha.set(clave, [...(porFecha.get(clave) ?? []), f])
  }

  const dias: DiaHistorial[] = []
  porFecha.forEach((delDia, clave) => {
    const ordenados = [...delDia].sort((a, b) => (a.Datetime ?? '').localeCompare(b.Datetime ?? ''))
    const conTipo = ordenados.map((f, i): FichajeDelDia => ({ ...f, Tipo: i % 2 === 0 ? 'E' : 'S' }))
    const fechaDate = new Date(clave + 'T00:00:00')
    dias.push({ fecha: fechaLegible(fechaDate), fechaDate, totalHoras: horasTrabajadas(conTipo), fichajes: conTipo })
  })

  return dias.sort((a, b) => b.fechaDate.getTime() - a.fechaDate.getTime())
}

/**
 * Horas entre cada entrada y su salida. Una entrada sin salida cuenta hasta
 * ahora si es de hoy, o hasta el final del día si no (como WebFichar).
 */
function horasTrabajadas(fichajes: FichajeDelDia[]): number {
  let minutos = 0
  for (let i = 0; i < fichajes.length; i += 2) {
    const entrada = new Date(fichajes[i].Datetime ?? '')
    const salida = fichajes[i + 1]?.Datetime
    let fin: Date
    if (salida) {
      fin = new Date(salida)
    } else {
      const ahora = new Date()
      const esHoy = entrada.toDateString() === ahora.toDateString()
      fin = esHoy ? ahora : new Date(entrada.getFullYear(), entrada.getMonth(), entrada.getDate(), 23, 59, 59)
    }
    minutos += (fin.getTime() - entrada.getTime()) / 60000
  }
  return Math.round((minutos / 60) * 100) / 100
}

/** 9.63 → "9h 38m". Cuenta los minutos totales y los redondea (no trunca el decimal). */
export function horasATexto(horas: number): string {
  const minutos = Math.round((horas || 0) * 60)
  return `${Math.floor(minutos / 60)}h ${minutos % 60}m`
}

function fechaLegible(fecha: Date): string {
  const dosCifras = (n: number) => String(n).padStart(2, '0')
  return `${DIAS_SEMANA[fecha.getDay()]} ${dosCifras(fecha.getDate())}/${dosCifras(fecha.getMonth() + 1)}/${fecha.getFullYear()}`
}

/** El origen del fichaje, con las etiquetas del historial de WebFichar. */
export function etiquetaModo(modo: number | null): string {
  switch (modo) {
    case 37: return 'Movil'
    case 35: return 'Modificado'
    case 32: return 'Insertado'
    default: return '-'
  }
}

export function horaMinutos(iso: string | null): string {
  if (!iso) return ''
  const f = new Date(iso)
  return `${String(f.getHours()).padStart(2, '0')}:${String(f.getMinutes()).padStart(2, '0')}`
}
