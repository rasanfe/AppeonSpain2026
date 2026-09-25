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
//10-09-2026: Calendario.tsx
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

import { useMemo } from 'react'
import { fechaISO } from '../services/api'

/** Calendario mensual, lo justo para elegir el día que se mira. */
interface Props {
  seleccionada: Date
  onSeleccionar: (fecha: Date) => void
  /** Fondo de la cabecera del calendario. */
  color: string
  /** Color del día elegido (en los temas oscuros, más claro que el fondo). */
  acento?: string
}

const DIAS = ['L', 'M', 'X', 'J', 'V', 'S', 'D']
const MESES = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
]

export function Calendario({ seleccionada, onSeleccionar, color, acento }: Props) {
  const colorDia = acento ?? color
  const hoy = new Date()

  const celdas = useMemo(() => {
    const primero = new Date(seleccionada.getFullYear(), seleccionada.getMonth(), 1)
    const ultimo = new Date(seleccionada.getFullYear(), seleccionada.getMonth() + 1, 0)
    // getDay(): 0=domingo. Aquí la semana empieza en lunes.
    const hueco = (primero.getDay() + 6) % 7
    const lista: (Date | null)[] = Array(hueco).fill(null)
    for (let d = 1; d <= ultimo.getDate(); d++) {
      lista.push(new Date(seleccionada.getFullYear(), seleccionada.getMonth(), d))
    }
    return lista
  }, [seleccionada])

  function cambiarMes(delta: number) {
    const f = new Date(seleccionada)
    f.setDate(1)
    f.setMonth(f.getMonth() + delta)
    onSeleccionar(f)
  }

  return (
    <div className="jb-cal">
      <div className="jb-cal-header" style={{ backgroundColor: color }}>
        <button type="button" className="jb-cal-nav" onClick={() => cambiarMes(-1)} aria-label="Mes anterior">‹</button>
        <span className="jb-cal-mes">
          {MESES[seleccionada.getMonth()]} {seleccionada.getFullYear()}
        </span>
        <button type="button" className="jb-cal-nav" onClick={() => cambiarMes(1)} aria-label="Mes siguiente">›</button>
      </div>

      <div className="jb-cal-semana">
        {DIAS.map((d) => (
          <span key={d} className="jb-cal-dia-semana">{d}</span>
        ))}
      </div>

      <div className="jb-cal-dias">
        {celdas.map((fecha, i) => {
          if (!fecha) return <span key={`hueco-${i}`} className="jb-cal-hueco" />
          const esHoy = fechaISO(fecha) === fechaISO(hoy)
          const esSel = fechaISO(fecha) === fechaISO(seleccionada)
          const finde = fecha.getDay() === 0 || fecha.getDay() === 6
          return (
            <button
              type="button"
              key={fechaISO(fecha)}
              className={`jb-cal-dia${esSel ? ' jb-cal-sel' : ''}${esHoy ? ' jb-cal-hoy' : ''}${finde ? ' jb-cal-finde' : ''}`}
              style={esSel ? { backgroundColor: colorDia, borderColor: colorDia } : undefined}
              onClick={() => onSeleccionar(fecha)}
            >
              {fecha.getDate()}
            </button>
          )
        })}
      </div>
    </div>
  )
}
