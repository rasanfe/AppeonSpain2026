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
//10-09-2026: Sso.tsx
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

import { useEffect, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { APP_CONFIG } from '../config/appConfig'
import { canjearTicket } from '../services/api'
import { marcarEmbebida, marcarTemaPb } from '../services/powerbuilder'

/**
 * La puerta de atras legitima: PowerBuilder ya sabe quien eres, pide un
 * ticket de un solo uso a la API y abre esta ruta. Aqui se canjea por un
 * JWT propio y el usuario entra sin volver a teclear la clave.
 *
 * El parametro `embedded` es el detalle que hace la gracia: la MISMA web
 * se comporta distinto solo porque la ha abierto PowerBuilder.
 */
export function Sso() {
  const [params] = useSearchParams()
  const navegar = useNavigate()
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    marcarEmbebida(params.get('embedded') === 'true')
    // El ERP dice con qué tema se está pintando; la web se viste igual.
    marcarTemaPb(params.get('tema'))

    const ticket = params.get('t')
    if (!ticket) {
      navegar(APP_CONFIG.rutas.login, { replace: true })
      return
    }
    canjearTicket(ticket)
      .then(() => navegar(APP_CONFIG.rutas.fichar, { replace: true }))
      .catch(() => setError('El ticket no vale o ha caducado.'))
  }, [params, navegar])

  return (
    <div className="pantalla">
      <div className="tarjeta">
        <h1 className="titulo">{error ? 'No se pudo entrar' : 'Entrando…'}</h1>
        <p className="subtitulo">
          {error ?? 'PowerBuilder ya sabe quién eres: no hace falta que te identifiques otra vez.'}
        </p>
      </div>
    </div>
  )
}
