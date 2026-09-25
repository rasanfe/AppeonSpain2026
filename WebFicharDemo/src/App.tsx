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
//10-09-2026: App.tsx
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { APP_CONFIG } from './config/appConfig'
import { Fichar } from './pages/Fichar'
import { Login } from './pages/Login'
import { Sso } from './pages/Sso'
import { leerSesion } from './services/api'

/** Sin sesion no se ve nada: al login. */
function Protegida({ children }: { children: React.ReactNode }) {
  return leerSesion() ? <>{children}</> : <Navigate to={APP_CONFIG.rutas.login} replace />
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path={APP_CONFIG.rutas.login} element={<Login />} />
        <Route path={APP_CONFIG.rutas.sso} element={<Sso />} />
        <Route
          path={APP_CONFIG.rutas.fichar}
          element={
            <Protegida>
              <Fichar />
            </Protegida>
          }
        />
      </Routes>
    </BrowserRouter>
  )
}
