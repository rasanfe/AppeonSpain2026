# 🪟 Modernizando PowerBuilder con tecnologías web

**No se reescribe la aplicación: se le abre una ventana a la web.**

Demo de la charla de **Ramón San Félix Ramón** en la
**Appeon PowerBuilder Regional Conference Spain 2026** — Barcelona, 27 de octubre de 2026.

El control **WebBrowser** (WebView2) de PowerBuilder como puerta, en cinco escalones de
acoplamiento creciente: desde pintar el fondo del MDI con HTML hasta que una web
React viva dentro del ERP, comparta su sesión y le hable de vuelta.

---

## 🧩 Qué hay dentro

| Carpeta | Qué es |
|---|---|
| `PersonDemo/` | La aplicación **PowerBuilder 2025**: fondo web del MDI, dashboard con Chart.js, AG Grid comiendo de un DataWindow, mantenimiento sobre JSON y la ventana de fichar con la web embebida. Sus datos (las facturas) viven en `PersonDemo/Database/`. |
| `FicharDemoApi/` | API **.NET 10** con **JWT**. Sirve también la web: la demo entera es **un solo proceso**. Sus datos, un JSON por tabla, viven en `FicharDemoApi/Database/`. |
| `WebFicharDemo/` | App **React 19 + Vite + TypeScript**, instalable como **PWA** (el móvil sin APK). |

**No hace falta base de datos.** Las dos aplicaciones guardan sus datos en ficheros JSON,
cada una en su carpeta `Database/`. Los tres clientes de la app de fichar (PowerBuilder,
navegador y móvil) escriben a la vez, pero todos pasan por la API, que es quien toca los
ficheros. En producción esto sería SQL Server; aquí, JSON para que la demo arranque en
cualquier máquina y sin red.

Los fichajes de 2026 son inventados y llegan **hasta el día de la charla**, que solo
tiene la entrada de la mañana. La API no devuelve los posteriores a la hora actual, así
que cada día de ensayo se ve como una jornada real hasta ese momento.

## 🌉 El puente PowerBuilder → web

1. PowerBuilder hace `POST /api/Auth/Login` y guarda su JWT.
2. Pide `POST /api/Auth/Ticket`: un **ticket de un solo uso** que vive 30 segundos.
3. Navega el WebBrowser a `/sso?t=<ticket>&embedded=true`.
4. La web hace `POST /api/Auth/Redeem`, recibe **su propio JWT** y entra sin login.

Y de vuelta, la web llama a PowerBuilder con `window.webBrowser.ue_close_window(...)` y
`window.webBrowser.ue_gf_msgbox(...)`, registrados con `RegisterEvent`.

Con `embedded=true` la **misma web, un solo build,** se comporta distinto solo porque la
abre PowerBuilder: cambia la insignia, "Historial" pasa a ser "Cerrar" (y el historial,
un icono en el pie) y el aviso de que se ha fichado lo pinta el escritorio. Fuera del
ERP no hay aviso: el fichaje aparece en la tabla.

> ⚠️ **Es una demo.** El JWT es de manual y el usuario y el PIN viajan en claro sobre
> `localhost`. No es el mecanismo de seguridad de ninguna aplicación real.

## ✅ Requisitos

- **PowerBuilder 2025** (o su runtime, para el ejecutable) con **WebView2**.
- **.NET 10 SDK**.
- **Node.js 20+**.
- Python 3, solo para la prueba de humo (`scripts/probar_api.py`).

Todo funciona **sin internet**: no hay ni una dependencia de CDN en tiempo de ejecución.

## 🚀 Puesta en marcha

1. Copia `.env.example` a `.env` y pon una clave JWT.
2. `WebFicharDemo`: `npm install`.
3. **`arrancar_demo.bat`**: compila la web dentro de la API, la arranca, espera a que
   responda y abre el navegador. Muestra también la URL para el móvil y la de Swagger.
4. Abre `PersonDemo/persondemo.pbsln` en PowerBuilder y ejecuta. Entra con un usuario
   del ERP (`RASANFE` / `APPEON`). La URL de la API está en `PersonDemo/Setting.ini`
   (sección `[FicharDemo]`).

Otros lanzadores:

| Fichero | Para qué |
|---|---|
| `abrir_movil.bat` | La web como se ve en un teléfono (Chrome en modo app, 430×880, *user-agent* Android). |
| `arrancar_desarrollo.bat` | API + Vite con recarga en caliente (puerto 5173). |
| `restaurar_datos_demo.bat` | Deja las facturas, los usuarios del ERP y los fichajes como estaban antes de trastear (vale con la API arrancada). |
| `python scripts/probar_api.py` | Prueba de punta a punta con la API levantada: login → ticket → canje → el mismo ticket otra vez (401) → fichajes → fichar (y borra el fichaje de prueba). |
| `python scripts/fuente_editor_pb.py` | Pone **Consolas** en el editor de PowerBuilder, que viene con Tahoma (proporcional). Con el IDE cerrado; `--aplicar` para escribir. |

## 👥 Dos sistemas de usuarios

El ERP y la app de fichar **no comparten usuarios**, como pasa en cualquier cliente real.
El ERP tiene los suyos (`PersonDemo/Database/usuarios.json`, con las claves **cifradas
con AES**) y cada uno lleva asignado el usuario y el PIN con los que entra en la app
móvil. Es esa equivalencia la que usa PowerBuilder para abrir la web sin pedir nada.
Se ve y se cambia en **Usuarios**, en el ribbon.

| Usuario del ERP | Contraseña | → Usuario móvil | PIN |
|---|---|---|---|
| `RASANFE` | `APPEON` | `RAMON` | `0000` |
| `INVITADO` | `INVITADO` | `PUBLICO` | `2222` |
| — | — | `APPEON` | `1111` (solo móvil) |

Públicos a propósito: no hay un solo dato real, y la clave AES de la demo está en el
código (`n_cst_cifrado`) para que quien clone el repositorio pueda entrar.

La API comprueba que cada uno solo **consulta, ficha o borra sus propios fichajes**:
el empleado sale del token, no de lo que mande el cliente. Y borrar, como en la app
de producción, solo en los **5 minutos** siguientes a fichar (la fila lleva un reloj
mientras se puede).

## 📚 Antes de esta charla

- 🎤 **Madrid 2025 — *Mi "PowerServer"***: [rasanfe/PersonDemo03](https://github.com/rasanfe/PersonDemo03)
- 📱 **2024 — la app de fichar en React Native**: [rasanfe/FicharDemo](https://github.com/rasanfe/FicharDemo) + [rasanfe/FicharDemoApi](https://github.com/rasanfe/FicharDemoApi)

## 👤 Autor

**Ramón San Félix Ramón** — Appeon MVP

- 🌐 [LinkedIn](https://www.linkedin.com/in/rasanfe)
- 📝 [Blog](https://rsrsystem.blogspot.com)
- 💻 [GitHub](https://github.com/rasanfe)

## 📄 Licencia

[MIT](LICENSE)
