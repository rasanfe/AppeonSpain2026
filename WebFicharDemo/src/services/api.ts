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
//10-09-2026: api.ts
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

import axios from 'axios'
import { APP_CONFIG } from '../config/appConfig'

const CLAVE_SESION = 'fichardemo_sesion'
/** El usuario de "Recordar": sobrevive al cierre del navegador, la sesión no. */
const CLAVE_USUARIO = 'fichardemo_usuario'

export const api = axios.create({ baseURL: APP_CONFIG.apiUrl })

api.interceptors.request.use((config) => {
  const sesion = leerSesion()
  if (sesion) config.headers.Authorization = `Bearer ${sesion.token}`
  return config
})

/** Si la API dice 401, la sesion ya no vale: fuera. */
api.interceptors.response.use(
  (r) => r,
  (error) => {
    if (error?.response?.status === 401) cerrarSesion()
    return Promise.reject(error)
  },
)

// --- Sesion ----------------------------------------------------------------

export interface Sesion {
  token: string
  usuario: string | null
  empresa: string | null
  empleado: string | null
  grupo: string | null
  /** PB, WEB o MOVIL. En la charla se pinta en pantalla: es la gracia. */
  origen: string | null
}

export function guardarSesion(sesion: Sesion) {
  sessionStorage.setItem(CLAVE_SESION, JSON.stringify(sesion))
}

export function leerSesion(): Sesion | null {
  const bruto = sessionStorage.getItem(CLAVE_SESION)
  return bruto ? (JSON.parse(bruto) as Sesion) : null
}

export function cerrarSesion() {
  sessionStorage.removeItem(CLAVE_SESION)
}

/** Lo que dejó escrito "Recordar usuario" la última vez que se entró. */
export function usuarioRecordado(): string {
  return localStorage.getItem(CLAVE_USUARIO) ?? ''
}

export function recordarUsuario(usuario: string, recordar: boolean) {
  if (recordar) localStorage.setItem(CLAVE_USUARIO, usuario)
  else localStorage.removeItem(CLAVE_USUARIO)
}

/** De donde se esta usando la app, para enseñarlo en pantalla. */
export function origenActual(): string {
  const instalada = window.matchMedia?.('(display-mode: standalone)').matches
  if (instalada) return 'MOVIL'
  return /Android|iPhone|iPad/i.test(navigator.userAgent) ? 'MOVIL' : 'WEB'
}

// --- Autenticacion ---------------------------------------------------------

export async function login(usuario: string, pin: string): Promise<Sesion> {
  const { data } = await api.post<Sesion>('/Auth/Login', {
    username: usuario,
    password: pin,
    origen: origenActual(),
  })
  guardarSesion(data)
  return data
}

/** Canje del ticket de un solo uso que trae PowerBuilder en la URL. */
export async function canjearTicket(ticket: string): Promise<Sesion> {
  const { data } = await api.post<Sesion>('/Auth/Redeem', { ticket })
  guardarSesion(data)
  return data
}

// --- Fichajes --------------------------------------------------------------

/** Tal cual lo devuelve el DataWindow de la API (PascalCase). */
export interface Fichaje {
  No: number
  Mchn: number | null
  Enno: number | null
  Name: string | null
  Mode: number | null
  Iomd: number | null
  Datetime: string | null
}

/** aaaa-mm-dd en hora local (no vale toISOString: se va al dia anterior). */
export function fechaISO(fecha: Date): string {
  const mes = String(fecha.getMonth() + 1).padStart(2, '0')
  const dia = String(fecha.getDate()).padStart(2, '0')
  return `${fecha.getFullYear()}-${mes}-${dia}`
}

export function esHoy(fecha: Date): boolean {
  return fechaISO(fecha) === fechaISO(new Date())
}

export async function listarFichajes(
  empresa: string,
  empleado: string,
  fecha: Date,
): Promise<Fichaje[]> {
  const { data } = await api.get<Fichaje[]>(
    `/Nomregistro/Retrieve/${empresa}/${empleado}/${fechaISO(fecha)}`,
  )
  return data
}

/** Para el historial: varios dias de una vez, en paralelo. */
export async function listarUltimosDias(
  empresa: string,
  empleado: string,
  dias: number,
): Promise<{ fecha: Date; fichajes: Fichaje[] }[]> {
  const fechas: Date[] = []
  for (let i = 0; i < dias; i++) {
    const f = new Date()
    f.setDate(f.getDate() - i)
    fechas.push(f)
  }
  const resultado = await Promise.all(
    fechas.map(async (fecha) => ({
      fecha,
      fichajes: await listarFichajes(empresa, empleado, fecha).catch(() => []),
    })),
  )
  return resultado.filter((d) => d.fichajes.length > 0)
}

export async function fichar(empresa: string, empleado: string): Promise<void> {
  const { latitud, longitud } = await coordenadas()
  await api.post('/Nomregistro/Fichar', { empresa, empleado, latitud, longitud })
}

/** El GPS es un extra: si el navegador lo niega o tarda, se ficha igual. */
function coordenadas(): Promise<{ latitud: number; longitud: number }> {
  return new Promise((resolver) => {
    if (!navigator.geolocation) return resolver({ latitud: 0, longitud: 0 })
    navigator.geolocation.getCurrentPosition(
      (p) => resolver({ latitud: p.coords.latitude, longitud: p.coords.longitude }),
      () => resolver({ latitud: 0, longitud: 0 }),
      { timeout: APP_CONFIG.gpsTimeoutMs, maximumAge: 60000 },
    )
  })
}
