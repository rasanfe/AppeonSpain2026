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
//10-09-2026: MessageBox.tsx
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

/**
 * MessageBox: el mismo que usan las aplicaciones de Ramón (clon del de
 * JobersComponentes, reescrito aquí para que la demo no dependa de nada).
 *
 * En la charla tiene su gracia: dentro de PowerBuilder los avisos los pinta
 * el propio ERP (nativo); fuera, este.
 */
export type TipoMensaje = 'info' | 'success' | 'warning' | 'error' | 'confirm'

interface Props {
  abierto: boolean
  tipo?: TipoMensaje
  titulo?: string
  mensaje: string
  textoAceptar?: string
  textoCancelar?: string
  onAceptar?: () => void
  onCerrar: () => void
}

const TITULOS: Record<TipoMensaje, string> = {
  info: 'Información',
  success: 'Correcto',
  warning: 'Atención',
  error: 'Error',
  confirm: 'Confirmar',
}

function Icono({ tipo }: { tipo: TipoMensaje }) {
  const comun = {
    width: 22,
    height: 22,
    viewBox: '0 0 24 24',
    fill: 'none',
    stroke: 'currentColor',
    strokeWidth: 2,
    strokeLinecap: 'round' as const,
    strokeLinejoin: 'round' as const,
  }
  if (tipo === 'success') {
    return (
      <svg {...comun}>
        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
        <polyline points="22 4 12 14.01 9 11.01" />
      </svg>
    )
  }
  if (tipo === 'error' || tipo === 'warning') {
    return (
      <svg {...comun}>
        <path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
        <line x1="12" y1="9" x2="12" y2="13" />
        <line x1="12" y1="17" x2="12.01" y2="17" />
      </svg>
    )
  }
  return (
    <svg {...comun}>
      <circle cx="12" cy="12" r="10" />
      <line x1="12" y1="16" x2="12" y2="12" />
      <line x1="12" y1="8" x2="12.01" y2="8" />
    </svg>
  )
}

export function MessageBox({
  abierto,
  tipo = 'info',
  titulo,
  mensaje,
  textoAceptar = 'Aceptar',
  textoCancelar,
  onAceptar,
  onCerrar,
}: Props) {
  if (!abierto) return null

  return (
    <div className="msgbox-overlay" onClick={onCerrar}>
      <div
        className={`msgbox-container msgbox-${tipo}`}
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
      >
        <div className="msgbox-header">
          <div className="msgbox-header-left">
            <span className={`msgbox-icon msgbox-icon-${tipo}`}>
              <Icono tipo={tipo} />
            </span>
            <h3 className="msgbox-title">{titulo ?? TITULOS[tipo]}</h3>
          </div>
        </div>

        <div className="msgbox-body">
          <p>{mensaje}</p>
        </div>

        <div className="msgbox-footer">
          {textoCancelar && (
            <button className="msgbox-btn msgbox-btn-secondary" onClick={onCerrar}>
              {textoCancelar}
            </button>
          )}
          <button
            className="msgbox-btn msgbox-btn-primary"
            onClick={() => {
              onAceptar?.()
              onCerrar()
            }}
            autoFocus
          >
            {textoAceptar}
          </button>
        </div>
      </div>
    </div>
  )
}
