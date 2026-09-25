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
//10-09-2026: powerbuilder.ts
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

/**
 * El puente con PowerBuilder.
 *
 * Cuando la web se abre dentro del control WebBrowser, PowerBuilder registra
 * eventos con `wb_1.RegisterEvent("ue_lo_que_sea")` y desde JavaScript se
 * llaman como `window.webBrowser.ue_lo_que_sea(...)`.
 *
 * Es la MISMA web que corre en el navegador y en el movil: aqui solo se
 * decide, en tiempo de ejecucion, si hay un PowerBuilder al otro lado.
 */

const CLAVE_EMBEBIDA = 'fichardemo_embebida'
const CLAVE_TEMA = 'fichardemo_tema'

declare global {
  interface Window {
    webBrowser?: {
      ue_close_window?: (arg: string) => void
      ue_gf_msgbox?: (json: string) => void
    }
  }
}

/** Lo marca la URL con la que PowerBuilder abre la web (?embedded=true). */
export function marcarEmbebida(embebida: boolean) {
  sessionStorage.setItem(CLAVE_EMBEBIDA, embebida ? '1' : '0')
}

export function estaEmbebida(): boolean {
  return sessionStorage.getItem(CLAVE_EMBEBIDA) === '1'
}

/** El tema de PowerBuilder con el que se está pintando el ERP. */
export function marcarTemaPb(tema: string | null) {
  if (tema) sessionStorage.setItem(CLAVE_TEMA, tema)
  else sessionStorage.removeItem(CLAVE_TEMA)
}

export function temaPb(): string | null {
  return sessionStorage.getItem(CLAVE_TEMA)
}

/** ¿Hay realmente un PowerBuilder escuchando? */
function hayPuente(): boolean {
  return typeof window.webBrowser?.ue_close_window === 'function'
}

/**
 * Le pide a PowerBuilder que cierre SU ventana. La web no puede hacerlo sola.
 *
 * El try/catch NO sobra (21-09-2026): el puente de WebView2 es SINCRONO y se queda
 * esperando la respuesta del host, pero lo que le estamos pidiendo es justo que se
 * destruya. Si la ventana de PB cierra en linea (sin `Post`), la respuesta no llega
 * nunca y el puente lanza «No parameters in result». Es el sintoma normal del cierre,
 * no un fallo, y sin capturarlo sube al window.onerror y acaba en el buzon.
 */
export function cerrarVentanaPb(): boolean {
  if (!hayPuente()) return false
  try {
    window.webBrowser!.ue_close_window!('CLOSE')
  } catch {
    // El host ya se esta yendo: el cierre se pidio igualmente.
  }
  return true
}

/**
 * Le pide a PowerBuilder que enseñe un aviso NATIVO.
 * El mensaje lo decide la web; quien lo pinta es la aplicacion de escritorio.
 */
export function avisoNativo(titulo: string, mensaje: string): boolean {
  if (typeof window.webBrowser?.ue_gf_msgbox !== 'function') return false
  // Mismo cinturon que en cerrarVentanaPb: el canal es sincrono y al otro lado hay un
  // MessageBox modal, asi que cualquier tropiezo del host no debe tumbar a la web.
  try {
    window.webBrowser.ue_gf_msgbox(JSON.stringify({ title: titulo, message: mensaje }))
  } catch {
    // Sin aviso nativo; la web sigue funcionando igual.
  }
  return true
}
