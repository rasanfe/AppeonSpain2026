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
//17-10-2026: usePlazoBorrado.ts
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

import { useEffect, useState } from 'react'
import { APP_CONFIG } from '../config/appConfig'
import type { Fichaje } from '../services/api'

const PLAZO_MS = APP_CONFIG.minutosParaBorrar * 60 * 1000

/** Hasta cuándo se puede borrar un fichaje (ms), o 0 si no tiene hora. */
function limite(fichaje: Fichaje): number {
  return fichaje.Datetime ? new Date(fichaje.Datetime).getTime() + PLAZO_MS : 0
}

/**
 * Los minutos para arrepentirse de un fichaje, como en WebFichar.
 *
 * Devuelve `puedeBorrar(fichaje)` y vuelve a pintar justo cuando caduca el
 * plazo más próximo: así el reloj de la fila desaparece a su hora, sin
 * esperar al siguiente refresco.
 */
export function usePlazoBorrado(fichajes: Fichaje[]) {
  const [ahora, setAhora] = useState(() => Date.now())

  useEffect(() => {
    const momento = Date.now()
    const pendientes = fichajes.map(limite).filter((l) => l > momento)
    if (pendientes.length === 0) return

    const espera = Math.min(...pendientes) - momento + 100
    const temporizador = setTimeout(() => setAhora(Date.now()), espera)
    return () => clearTimeout(temporizador)
  }, [fichajes, ahora])

  return {
    puedeBorrar: (fichaje: Fichaje) => limite(fichaje) > Math.max(ahora, Date.now()),
  }
}
