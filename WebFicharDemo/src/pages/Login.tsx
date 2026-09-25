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
//10-09-2026: Login.tsx
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { MessageBox } from '../components/MessageBox'
import { APP_CONFIG } from '../config/appConfig'
import { colorEmpresa } from '../config/empresa'
import { login, recordarUsuario, usuarioRecordado } from '../services/api'

/**
 * Calco del login de WebFichar: tarjeta centrada, logo, usuario y PIN con el
 * ojo, "Recordar", y el pie con version, fecha y autoria.
 * Sin boton de configuracion y sin sello de acceso: esto es una demo.
 */
export function Login() {
  // "Recordar usuario" no servía de nada si nadie lo leía al volver: el campo
  // arranca con el último usuario guardado, como en WebFichar.
  const recordado = usuarioRecordado()
  const [usuario, setUsuario] = useState(recordado)
  const [pin, setPin] = useState('')
  const [verPin, setVerPin] = useState(false)
  const [recordar, setRecordar] = useState(true)
  const [error, setError] = useState('')
  const [entrando, setEntrando] = useState(false)
  const navegar = useNavigate()

  const color = colorEmpresa('1')

  async function enviar(evento: FormEvent) {
    evento.preventDefault()
    setEntrando(true)
    try {
      await login(usuario.trim().toUpperCase(), pin.trim())
      // Al desmarcar "Recordar" hay que BORRARLO, no solo dejar de guardarlo.
      recordarUsuario(usuario.trim().toUpperCase(), recordar)
      navegar(APP_CONFIG.rutas.fichar, { replace: true })
    } catch {
      setError('Usuario o PIN incorrectos.')
    } finally {
      setEntrando(false)
    }
  }

  return (
    <div className="login-screen">
      <form className="login-card" onSubmit={enviar}>
        <div className="login-header">
          <img src="/images/logo.png" alt="RSR System" className="login-logo" />
          <h1 className="login-title" style={{ color }}>
            {APP_CONFIG.nombre}
            <span className="login-trademark">®</span>
          </h1>
          <p className="login-subtitulo">{APP_CONFIG.subtitulo}</p>
        </div>

        <div className="login-field">
          <label htmlFor="usuario">
            <svg className="login-field-icon" style={{ color }} viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
              <circle cx="12" cy="7" r="4" />
            </svg>
            Usuario
          </label>
          <input
            id="usuario"
            autoFocus={!recordado}
            autoComplete="username"
            value={usuario}
            disabled={entrando}
            onChange={(e) => setUsuario(e.target.value)}
          />
        </div>

        <div className="login-field">
          <label htmlFor="pin">
            <svg className="login-field-icon" style={{ color }} viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
              <path d="M7 11V7a5 5 0 0 1 10 0v4" />
            </svg>
            PIN
          </label>
          <div className="login-password-wrapper">
            <input
              id="pin"
              autoFocus={!!recordado}
              type={verPin ? 'text' : 'password'}
              inputMode="numeric"
              maxLength={4}
              autoComplete="current-password"
              value={pin}
              disabled={entrando}
              onChange={(e) => setPin(e.target.value)}
            />
            <button
              type="button"
              className="login-toggle-password"
              style={{ color }}
              onClick={() => setVerPin((v) => !v)}
              aria-label={verPin ? 'Ocultar PIN' : 'Ver PIN'}
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"
                   strokeLinecap="round" strokeLinejoin="round">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                <circle cx="12" cy="12" r="3" />
                {!verPin && <line x1="3" y1="21" x2="21" y2="3" />}
              </svg>
            </button>
          </div>
        </div>

        <div className="login-remember">
          <div className="login-remember-left">
            <input
              id="recordar"
              type="checkbox"
              checked={recordar}
              style={{ accentColor: color }}
              onChange={(e) => setRecordar(e.target.checked)}
            />
            <label htmlFor="recordar" style={{ color }}>Recordar usuario</label>
          </div>
        </div>

        <button
          className="login-submit"
          type="submit"
          disabled={entrando || !usuario || !pin}
          style={{ background: `linear-gradient(135deg, ${color} 0%, #0059b3 100%)` }}
        >
          {entrando ? 'Entrando…' : 'Iniciar sesión'}
        </button>
      </form>

      <div className="login-footer">
        <div className="login-version">v{APP_CONFIG.version}  ·  {APP_CONFIG.fechaBuild}</div>
        <div className="login-copyright">© {APP_CONFIG.autor}</div>
        <div className="login-evento">{APP_CONFIG.evento}</div>
      </div>

      <MessageBox
        abierto={!!error}
        tipo="error"
        mensaje={error}
        onCerrar={() => setError('')}
      />
    </div>
  )
}
