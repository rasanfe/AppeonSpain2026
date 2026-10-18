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
//17-10-2026: HistorialModal.tsx
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

import { useCallback, useEffect, useState } from 'react'
import { listarHistorico } from '../services/api'
import {
  agruparPorDia,
  etiquetaModo,
  horaMinutos,
  horasATexto,
  MESES,
  rangoMes,
  type DiaHistorial,
} from '../utils/historial'
import { ChevronDownIcon, ChevronRightIcon, XIcon } from './Iconos'
import './HistorialModal.css'

interface Props {
  visible: boolean
  onClose: () => void
  empresa: string
  empleado: string
  /** Fondo de la cabecera (el de la empresa o el del tema del ERP). */
  color: string
  /** Texto y entradas: en tema oscuro, un color que se lea. */
  acento: string
  /** Las salidas. */
  secundario: string
  /** El día elegido en el calendario: se enseña su mes. */
  fecha: Date
}

/**
 * Historial de fichajes del mes: calco de FichajesHistoryModal de WebFichar.
 * Un día por tarjeta, con las horas y el número de fichajes; al pinchar se
 * despliegan los marcajes. Sin los datos de nómina de la app real (dietas,
 * horas extra, vacaciones), que la demo no tiene.
 */
export function HistorialModal({ visible, onClose, empresa, empleado, color, acento, secundario, fecha }: Props) {
  const [dias, setDias] = useState<DiaHistorial[]>([])
  const [cargando, setCargando] = useState(false)
  const [diaAbierto, setDiaAbierto] = useState<string | null>(null)

  useEffect(() => {
    if (!visible) return
    let activo = true
    const { desde, hasta } = rangoMes(fecha)

    setCargando(true)
    setDiaAbierto(null)
    listarHistorico(empresa, empleado, desde, hasta)
      .then((fichajes) => activo && setDias(agruparPorDia(fichajes)))
      .catch(() => activo && setDias([]))
      .finally(() => activo && setCargando(false))

    return () => {
      activo = false
    }
  }, [visible, empresa, empleado, fecha])

  // Escape cierra, y el fondo no se desplaza mientras está abierto
  const alPulsarTecla = useCallback((e: KeyboardEvent) => {
    if (e.key === 'Escape') onClose()
  }, [onClose])

  useEffect(() => {
    if (!visible) return
    document.addEventListener('keydown', alPulsarTecla)
    document.body.style.overflow = 'hidden'
    return () => {
      document.removeEventListener('keydown', alPulsarTecla)
      document.body.style.overflow = ''
    }
  }, [visible, alPulsarTecla])

  if (!visible) return null

  const mes = MESES[fecha.getMonth()]
  const horasMes = dias.reduce((total, d) => total + d.totalHoras, 0)
  // Un día con fichajes impares se avisa en rojo, como en WebFichar
  const colorDia = (d: DiaHistorial) => (d.fichajes.length % 2 === 0 ? acento : '#FF0000')

  return (
    <>
      <div className="history-overlay" onClick={onClose} />
      <div className="history-modal">
        {/* Cabecera */}
        <div className="history-header" style={{ backgroundColor: color }}>
          <div className="history-header-text">
            <h2 className="history-title">Historial de Fichajes</h2>
            <div className="history-subtitle-row">
              <span className="history-subtitle">{mes} {fecha.getFullYear()}</span>
            </div>
          </div>
          <button className="history-close-btn" onClick={onClose} aria-label="Cerrar">
            <XIcon size={28} color="#fff" />
          </button>
        </div>

        {/* Contenido */}
        <div className="history-content">
          {cargando ? (
            <div className="history-loading">
              <div className="history-spinner" style={{ borderTopColor: acento }} />
              <p>Cargando historial...</p>
            </div>
          ) : dias.length === 0 ? (
            <div className="history-empty">
              <p>No hay fichajes en {mes}</p>
            </div>
          ) : (
            <div className="history-list">
              {dias.map((dia) => {
                const abierto = diaAbierto === dia.fecha
                return (
                  <div key={dia.fecha} className="day-card">
                    <div
                      className="day-header"
                      style={{ borderLeftColor: acento }}
                      onClick={() => setDiaAbierto(abierto ? null : dia.fecha)}
                    >
                      <div className="day-header-left">
                        {abierto
                          ? <ChevronDownIcon size={16} color={acento} />
                          : <ChevronRightIcon size={16} color={acento} />}
                        <div className="day-header-info">
                          <span className="day-date">{dia.fecha}</span>
                          <span className="day-hours" style={{ color: colorDia(dia) }}>
                            {horasATexto(dia.totalHoras)}
                          </span>
                        </div>
                      </div>
                      <div className="day-header-right">
                        <span className="fichajes-count" style={{ color: colorDia(dia) }}>
                          {dia.fichajes.length} fichajes
                        </span>
                      </div>
                    </div>

                    {abierto && (
                      <div className="day-content">
                        {dia.fichajes.map((f) => (
                          <div key={f.No} className="fichaje-row">
                            <div className="fichaje-time-container">
                              <span
                                className="tipo-badge"
                                style={{ backgroundColor: f.Tipo === 'E' ? acento : secundario }}
                              >
                                {f.Tipo}
                              </span>
                              <span className="fichaje-time">{horaMinutos(f.Datetime)}</span>
                            </div>
                            <div className="fichaje-details">
                              <span className="tipo-label">
                                {f.Tipo === 'E' ? 'Entrada' : 'Salida'} - {etiquetaModo(f.Mode)}
                              </span>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )
              })}
            </div>
          )}
        </div>

        {/* Pie con totales */}
        {!cargando && dias.length > 0 && (
          <div className="history-footer" style={{ borderTopColor: color }}>
            <div className="footer-item">
              <span className="footer-label">H. Totales</span>
              <span className="footer-value" style={{ color: acento }}>{horasATexto(horasMes)}</span>
            </div>
            <div className="footer-divider" />
            <div className="footer-item">
              <span className="footer-label">Dias Trab.</span>
              <span className="footer-value" style={{ color: acento }}>{dias.length}</span>
            </div>
          </div>
        )}
      </div>
    </>
  )
}
