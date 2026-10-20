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
//20-10-2026: useTemaPb.ts
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

import { useEffect, useState } from 'react'
import { temaDePowerBuilder, type Tema } from '../config/tema'
import { EVENTO_TEMA, temaPb } from '../services/powerbuilder'

/**
 * El tema con el que se está pintando el ERP, ya traducido (o null fuera de él).
 *
 * Se vuelve a pintar cuando PowerBuilder lo cambia con `window.setTema(...)`:
 * el usuario cambia el tema en w_setup y la ventana de fichar lo sigue al momento.
 */
export function useTemaPb(): Tema | null {
  const [nombre, setNombre] = useState(temaPb)

  useEffect(() => {
    const alCambiar = () => setNombre(temaPb())
    window.addEventListener(EVENTO_TEMA, alCambiar)
    return () => window.removeEventListener(EVENTO_TEMA, alCambiar)
  }, [])

  return temaDePowerBuilder(nombre)
}
