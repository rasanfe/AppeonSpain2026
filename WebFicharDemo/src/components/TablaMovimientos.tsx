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
//17-10-2026: TablaMovimientos.tsx
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

import { useState } from 'react'
import { MessageBox } from './MessageBox'
import { usePlazoBorrado } from '../hooks/usePlazoBorrado'
import type { Fichaje } from '../services/api'

/** El procedimiento 'fichar' graba todos los marcajes iguales: entrada y
 *  salida se deducen del orden, igual que en el ERP. */
export const esEntrada = (indice: number) => indice % 2 === 0

export const hora = (iso: string | null) =>
  iso ? new Date(iso).toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' }) : ''

/** dd-mm-aaaa hh:mm, como el confirmar de WebFichar. */
function fechaHora(iso: string | null) {
  if (!iso) return ''
  const f = new Date(iso)
  const dosCifras = (n: number) => String(n).padStart(2, '0')
  return `${dosCifras(f.getDate())}-${dosCifras(f.getMonth() + 1)}-${f.getFullYear()} ${hora(iso)}`
}

/** De dónde vino el fichaje, según el Mode que guarda la API. */
function dispositivo(modo: number | null) {
  if (modo === 32) return 'Manual'
  if (modo === 35) return 'Modificado'
  return 'App'
}

/** El relojito de WebFichar (su ClockIcon): esta fila aún se puede borrar. */
function Reloj() {
  return (
    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#999" strokeWidth="2">
      <circle cx="12" cy="12" r="10" />
      <polyline points="12,6 12,12 16,14" />
    </svg>
  )
}

interface Props {
  fichajes: Fichaje[]
  hoyMismo: boolean
  color: string
  acento: string
  secundario: string
  /** Borra el fichaje y refresca; si falla, avisa quien lo pasa. */
  onBorrar: (fichaje: Fichaje) => Promise<void>
}

/**
 * La tabla de movimientos del día, con lo que hace WebFichar para borrar:
 * un fichaje recién hecho lleva un reloj durante 5 minutos; mientras, se
 * puede seleccionar y aparece el botón Borrar, que pide confirmación.
 */
export function TablaMovimientos({ fichajes, hoyMismo, color, acento, secundario, onBorrar }: Props) {
  const { puedeBorrar } = usePlazoBorrado(fichajes)
  const [numeroElegido, setNumeroElegido] = useState<number | null>(null)
  const [confirmar, setConfirmar] = useState(false)

  // Si el elegido ya no está (borrado, otro día) o caducó su plazo, se suelta solo
  const elegido = fichajes.find((f) => f.No === numeroElegido && puedeBorrar(f)) ?? null

  function elegir(fichaje: Fichaje) {
    if (!puedeBorrar(fichaje)) return
    setNumeroElegido(elegido?.No === fichaje.No ? null : fichaje.No)
  }

  async function borrar() {
    if (!elegido) return
    await onBorrar(elegido)
    setNumeroElegido(null)
  }

  return (
    <>
      <div className="movimientos-table">
        <table>
          <thead>
            <tr style={{ backgroundColor: color }}>
              <th>Tipo</th>
              <th>Hora</th>
              <th>Origen</th>
            </tr>
          </thead>
          <tbody>
            {fichajes.length === 0 ? (
              <tr>
                <td className="empty-state-cell" colSpan={3}>
                  <div className="empty-state">
                    <p className="empty-state-text">Sin fichajes este día</p>
                    <p className="empty-state-hint">
                      {hoyMismo ? 'Pulsa Entrada para empezar' : 'Elige otro día en el calendario'}
                    </p>
                  </div>
                </td>
              </tr>
            ) : (
              fichajes.map((f, i) => (
                <tr
                  key={f.No}
                  className={`${elegido?.No === f.No ? 'fila-seleccionada' : ''} ${puedeBorrar(f) ? 'fila-clickable' : ''}`}
                  onClick={() => elegir(f)}
                >
                  <td>
                    <span
                      className="badge-circular"
                      style={{ backgroundColor: esEntrada(i) ? acento : secundario }}
                    >
                      {esEntrada(i) ? 'E' : 'S'}
                    </span>
                  </td>
                  <td className="fecha-hora">{hora(f.Datetime)}</td>
                  <td className="dispositivo">
                    <span className="origen-container">
                      {dispositivo(f.Mode)}
                      {puedeBorrar(f) && (
                        <span className="delete-indicator" title="Puede borrarse (5 min)">
                          <Reloj />
                        </span>
                      )}
                    </span>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Acciones del fichaje elegido, encima de la línea del pie (como WebFichar) */}
      {elegido && (
        <div className="movimientos-acciones">
          <button
            className="btn-accion-fichaje"
            style={{ backgroundColor: secundario }}
            onClick={() => setConfirmar(true)}
          >
            Borrar
          </button>
        </div>
      )}

      <MessageBox
        abierto={confirmar}
        tipo="confirm"
        titulo="Borrar Fichaje"
        mensaje={`¿Estás seguro de que quieres borrar el fichaje del ${fechaHora(elegido?.Datetime ?? null)}?`}
        textoAceptar="Sí"
        textoCancelar="No"
        onAceptar={() => void borrar()}
        onCerrar={() => setConfirmar(false)}
      />
    </>
  )
}
