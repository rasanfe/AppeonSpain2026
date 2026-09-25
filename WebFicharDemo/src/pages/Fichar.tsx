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
//10-09-2026: Fichar.tsx
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

import { useCallback, useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Calendario } from '../components/Calendario'
import { MessageBox, type TipoMensaje } from '../components/MessageBox'
import { APP_CONFIG } from '../config/appConfig'
import { colorEmpresa, colorSecundario } from '../config/empresa'
import {
  cerrarSesion,
  esHoy,
  fichar,
  leerSesion,
  listarFichajes,
  listarUltimosDias,
  type Fichaje,
} from '../services/api'
import { avisoNativo, cerrarVentanaPb, estaEmbebida, temaPb } from '../services/powerbuilder'
import { temaDePowerBuilder } from '../config/tema'

/** El procedimiento 'fichar' graba todos los marcajes iguales: entrada y
 *  salida se deducen del orden, igual que en el ERP. */
const esEntrada = (indice: number) => indice % 2 === 0

const hora = (iso: string | null) =>
  iso ? new Date(iso).toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' }) : ''

const fechaLarga = (f: Date) =>
  f.toLocaleDateString('es-ES', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })

/** De dónde vino el fichaje, según el Mode que guarda el procedimiento. */
function dispositivo(modo: number | null) {
  if (modo === 32) return 'Manual'
  if (modo === 35) return 'Modificado'
  return 'App'
}

export function Fichar() {
  const sesion = leerSesion()
  const navegar = useNavigate()
  const embebida = estaEmbebida()
  // Dentro del ERP manda el tema de PowerBuilder; fuera, el color de la empresa.
  const tema = temaDePowerBuilder(temaPb())
  const color = tema?.color ?? colorEmpresa(sesion?.empresa)
  // Los detalles (la "E", el día elegido, las etiquetas) necesitan un color que
  // se lea; en los temas oscuros no vale el mismo que el de los fondos.
  const acento = tema?.acento ?? color
  // En tema naranja el secundario NO puede ser naranja: pasa a gris,
  // igual que hace WebFichar.
  const secundario = colorSecundario(color, sesion?.empresa)

  const [dia, setDia] = useState(new Date())
  const [fichajes, setFichajes] = useState<Fichaje[]>([])
  const [fichando, setFichando] = useState(false)
  const [historial, setHistorial] = useState<{ fecha: Date; fichajes: Fichaje[] }[] | null>(null)
  const [aviso, setAviso] = useState<{ tipo: TipoMensaje; texto: string } | null>(null)
  const [confirmarSalir, setConfirmarSalir] = useState(false)

  const refrescar = useCallback(async () => {
    if (!sesion?.empresa || !sesion?.empleado) return
    try {
      setFichajes(await listarFichajes(sesion.empresa, sesion.empleado, dia))
    } catch {
      /* un fallo de refresco no puede romper la pantalla en mitad de la demo */
    }
  }, [sesion?.empresa, sesion?.empleado, dia])

  useEffect(() => {
    if (!sesion) {
      navegar(APP_CONFIG.rutas.login, { replace: true })
      return
    }
    void refrescar()
    // El refresco es el truco de la demo: lo que se ficha en el móvil
    // aparece solo dentro de la ventana de PowerBuilder.
    const reloj = setInterval(() => void refrescar(), APP_CONFIG.refrescoMs)
    return () => clearInterval(reloj)
  }, [sesion, navegar, refrescar])

  const totales = useMemo(() => {
    const entradas = fichajes.filter((_, i) => esEntrada(i)).length
    return { entradas, salidas: fichajes.length - entradas }
  }, [fichajes])

  if (!sesion) return null

  const hoyMismo = esHoy(dia)
  const siguienteEsEntrada = esEntrada(fichajes.length)

  async function marcar() {
    setFichando(true)
    try {
      const tipo = siguienteEsEntrada ? 'Entrada' : 'Salida'
      await fichar(sesion!.empresa!, sesion!.empleado!)
      // Dentro del ERP el aviso lo pinta PowerBuilder (nativo). Fuera, esta web.
      // Mismo código, dos experiencias.
      if (!avisoNativo('Fichaje registrado', tipo + ' de ' + sesion!.usuario)) {
        setAviso({ tipo: 'success', texto: tipo + ' registrada correctamente.' })
      }
      await refrescar()
    } catch {
      setAviso({ tipo: 'error', texto: 'No se ha podido fichar.' })
    } finally {
      setFichando(false)
    }
  }

  async function abrirHistorial() {
    setHistorial([])
    setHistorial(await listarUltimosDias(sesion!.empresa!, sesion!.empleado!, 15))
  }

  function salir() {
    // Dentro de PowerBuilder no se cierra sesión: se cierra LA VENTANA,
    // y eso solo puede hacerlo PowerBuilder. La web se lo pide.
    if (embebida && cerrarVentanaPb()) return
    cerrarSesionYVolverAlLogin()
  }

  /** El logout de verdad, como en WebFichar: se confirma y se vuelve al login. */
  function cerrarSesionYVolverAlLogin() {
    cerrarSesion()
    navegar(APP_CONFIG.rutas.login, { replace: true })
  }

  return (
    <div className={'fichar-page' + (tema?.oscuro ? ' tema-oscuro' : '')}>
      {/* Cabecera de empresa */}
      <div className="fichar-header" style={{ backgroundColor: color }}>
        <div className="fichar-header-usuario">
          <strong>{sesion.usuario}</strong>
          <span>Empresa {sesion.empresa} · Empleado {sesion.empleado}</span>
        </div>
        <div className="fichar-header-derecha">
          <span className="fichar-header-origen">
            {embebida ? 'DENTRO DEL ERP' : sesion.origen}
          </span>

          {/* Cerrar sesión: el mismo icono y el mismo sitio que en WebFichar.
              Dentro del ERP no se cierra sesión (la ventana la cierra PB), así
              que el botón ni aparece. */}
          {!embebida && (
            <button
              type="button"
              className="fichar-header-logout"
              title="Cerrar sesión"
              aria-label="Cerrar sesión"
              onClick={() => setConfirmarSalir(true)}
            >
              <svg viewBox="0 0 512 512" width="22" height="22">
                <path
                  fill="none"
                  stroke="currentColor"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="40"
                  d="M304 336v40a40 40 0 01-40 40H104a40 40 0 01-40-40V136a40 40 0 0140-40h152c22.09 0 48 17.91 48 40v40M368 336l80-80-80-80M176 256h256"
                />
              </svg>
            </button>
          )}
        </div>
      </div>

      <div className="main-container">
        <Calendario seleccionada={dia} onSeleccionar={setDia} color={color} acento={acento} />

        <div className="movimientos-panel">
          <div className="movimientos-header" style={{ backgroundColor: color }}>
            <h3>Movimientos</h3>
            <span className="fecha-seleccionada">{fechaLarga(dia)}</span>
          </div>

          <div className="movimientos-table">
            <table>
              <thead>
                <tr style={{ backgroundColor: color }}>
                  <th>Tipo</th>
                  <th>Fecha y hora</th>
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
                    <tr key={f.No}>
                      <td>
                        <span
                          className="badge-circular"
                          style={{ backgroundColor: esEntrada(i) ? acento : secundario }}
                        >
                          {esEntrada(i) ? 'E' : 'S'}
                        </span>
                      </td>
                      <td className="fecha-hora">{hora(f.Datetime)}</td>
                      <td className="dispositivo">{dispositivo(f.Mode)}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          <div className="movimientos-footer" style={{ borderTopColor: color }}>
            <div className="movimientos-footer-row">
              <div className="footer-item">
                <span className="footer-label" style={{ color: acento }}>Entradas</span>
                <span className="footer-value" style={{ color: acento }}>{totales.entradas}</span>
              </div>
              <div className="footer-item">
                <span className="footer-label" style={{ color: acento }}>Salidas</span>
                <span className="footer-value" style={{ color: secundario }}>{totales.salidas}</span>
              </div>

              {/* Historial: solo aquí cuando estamos dentro de PowerBuilder.
                  Fuera, el botón principal de la derecha YA es Historial. */}
              {embebida && (
                <div className="footer-item footer-historial" onClick={() => void abrirHistorial()}>
                  <span className="footer-label" style={{ color: acento }}>Historial</span>
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={acento}
                       strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
                    <line x1="16" y1="2" x2="16" y2="6" />
                    <line x1="8" y1="2" x2="8" y2="6" />
                    <line x1="3" y1="10" x2="21" y2="10" />
                  </svg>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Botones principales */}
      <div className="main-buttons">
        <button
          className="btn-fichar-main"
          style={{ backgroundColor: color }}
          onClick={() => void marcar()}
          disabled={fichando || !hoyMismo}
          title={hoyMismo ? '' : 'Solo se puede fichar en el día de hoy'}
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <polyline points="9 11 12 14 22 4" />
            <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11" />
          </svg>
          {fichando ? 'Fichando…' : siguienteEsEntrada ? 'Entrada' : 'Salida'}
        </button>

        {/* El mismo sitio, dos significados: dentro del ERP cierra la ventana
            de PowerBuilder; fuera, abre el historial. */}
        {embebida ? (
          <button className="btn-salir-main" style={{ backgroundColor: secundario }} onClick={salir}>
            <svg width="20" height="20" viewBox="0 0 512 512" fill="none" stroke="currentColor"
                 strokeWidth="40" strokeLinecap="round" strokeLinejoin="round">
              <path d="M378 108a191.24 191.24 0 0170 148c0 106-86 192-192 192S64 362 64 256a192 192 0 0169-148" />
              <line x1="256" y1="64" x2="256" y2="256" />
            </svg>
            Cerrar
          </button>
        ) : (
          <button
            className="btn-salir-main"
            style={{ backgroundColor: secundario }}
            onClick={() => void abrirHistorial()}
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="12" r="10" />
              <polyline points="12 6 12 12 16 14" />
            </svg>
            Historial
          </button>
        )}
      </div>

      <div className="main-footer">
        <span className="main-footer-copyright">© {APP_CONFIG.autor}</span>
        <span className="main-footer-version">v{APP_CONFIG.version}  {APP_CONFIG.fechaBuild}</span>
      </div>

      {/* Historial: los últimos días con fichajes */}
      {historial !== null && (
        <div className="msgbox-overlay" onClick={() => setHistorial(null)}>
          <div className="msgbox-container historial" onClick={(e) => e.stopPropagation()}>
            <div className="msgbox-header">
              <div className="msgbox-header-left">
                <h3 className="msgbox-title">Historial de fichajes</h3>
              </div>
            </div>
            <div className="msgbox-body">
              {historial.length === 0 ? (
                <p>Sin fichajes en los últimos días.</p>
              ) : (
                historial.map((d) => (
                  <div key={d.fecha.toISOString()} className="historial-dia">
                    <div className="historial-fecha" style={{ color: acento }}>{fechaLarga(d.fecha)}</div>
                    <div className="historial-horas">
                      {d.fichajes.map((f, i) => (
                        <span
                          key={f.No}
                          className="historial-hora"
                          style={{ borderColor: esEntrada(i) ? acento : secundario }}
                        >
                          {esEntrada(i) ? 'E' : 'S'} {hora(f.Datetime)}
                        </span>
                      ))}
                    </div>
                  </div>
                ))
              )}
            </div>
            <div className="msgbox-footer">
              <button
                className="msgbox-btn msgbox-btn-primary"
                style={{ background: 'linear-gradient(135deg, ' + color + ' 0%, #0059b3 100%)' }}
                onClick={() => setHistorial(null)}
              >
                Cerrar
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Confirmación de cierre de sesión, como la de WebFichar. */}
      <MessageBox
        abierto={confirmarSalir}
        tipo="confirm"
        titulo="Cerrar sesión"
        mensaje="¿Deseas cerrar la sesión?"
        textoAceptar="Sí"
        textoCancelar="No"
        onAceptar={cerrarSesionYVolverAlLogin}
        onCerrar={() => setConfirmarSalir(false)}
      />

      <MessageBox
        abierto={!!aviso}
        tipo={aviso?.tipo ?? 'info'}
        mensaje={aviso?.texto ?? ''}
        onCerrar={() => setAviso(null)}
      />
    </div>
  )
}
