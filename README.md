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
| `PersonDemo/` | La aplicación **PowerBuilder 2025**: fondo web del MDI, dashboard con Chart.js, AG Grid comiendo de un DataWindow, mantenimiento sobre JSON y la ventana de fichar con la web embebida. |
| `FicharDemoApi/` | API **.NET 10** con el ORM DataWindow de Appeon (`DWNet.Data` / `SnapObjects.Data` 5.1) y **JWT**. Sirve también la web: la demo entera es **un solo proceso**. |
| `WebFicharDemo/` | App **React 19 + Vite + TypeScript**, instalable como **PWA** (el móvil sin APK). |
| `datos/` | Scripts de la base de datos de la demo. |

## 🌉 El puente PowerBuilder → web

1. PowerBuilder hace `POST /api/Auth/Login` y guarda su JWT.
2. Pide `POST /api/Auth/Ticket`: un **ticket de un solo uso** que vive 30 segundos.
3. Navega el WebBrowser a `/sso?t=<ticket>&embedded=true`.
4. La web hace `POST /api/Auth/Redeem`, recibe **su propio JWT** y entra sin login.

Y de vuelta, la web llama a PowerBuilder con `window.webBrowser.ue_close_window(...)` y
`window.webBrowser.ue_gf_msgbox(...)`, registrados con `RegisterEvent`.

Con `embedded=true` la **misma web, un solo build,** se comporta distinto solo porque la
abre PowerBuilder: cambia la insignia, "Historial" pasa a ser "Cerrar ventana" y los
avisos los pinta el escritorio.

> ⚠️ **Es una demo.** El JWT es de manual y el usuario y el PIN viajan en claro sobre
> `localhost`. No es el mecanismo de seguridad de ninguna aplicación real.

## ✅ Requisitos

- **PowerBuilder 2025** (o su runtime, para el ejecutable) con **WebView2**.
- **.NET 10 SDK**.
- **Node.js 20+**.
- **SQL Server** con la base `FicharDemo` (el ejemplo de PowerBuilder va por JSON: solo
  la app de fichar necesita base de datos).
- Python 3, solo para `datos/comprobar_bd_demo.py`.

Todo funciona **sin internet**: no hay ni una dependencia de CDN en tiempo de ejecución.

## 🚀 Puesta en marcha

1. Copia `.env.example` a `.env` y rellena la conexión a SQL Server y una clave JWT.
2. En tu SQL Server, con un usuario administrador y en este orden:
   - `datos/crear_bd_fichardemo.sql`: crea la base `FicharDemo`, sus tablas, el
     procedimiento `fichar` y el usuario del ponente (`RASANFE` / `0000`).
   - `datos/crear_usuario_fichardemo.sql`: el login que usa la API.
   - `datos/empleados_demo.sql`: los usuarios `APPEON` (`1111`) y `PUBLICO` (`2222`).
   - `python datos/comprobar_bd_demo.py`: comprueba que está todo.
3. `WebFicharDemo`: `npm install`.
4. **`arrancar_demo.bat`**: compila la web dentro de la API, la arranca, espera a que
   responda y abre el navegador. Muestra también la URL para el móvil y la de Swagger.
5. Abre `PersonDemo/persondemo.pbsln` en PowerBuilder y ejecuta. La ventana de fichar
   lee su configuración de `PersonDemo/Setting.ini` (sección `[FicharDemo]`).

Otros lanzadores:

| Fichero | Para qué |
|---|---|
| `abrir_movil.bat` | La web como se ve en un teléfono (Chrome en modo app, 430×880, *user-agent* Android). |
| `arrancar_desarrollo.bat` | API + Vite con recarga en caliente (puerto 5173). |
| `restaurar_datos_demo.bat` | Deja `data2026.json` como estaba antes de trastear. |
| `python scripts/probar_api.py` | Prueba de punta a punta con la API levantada: login → ticket → canje → el mismo ticket otra vez (401) → fichajes. |
| `python scripts/fuente_editor_pb.py` | Pone **Consolas** en el editor de PowerBuilder, que viene con Tahoma (proporcional). Con el IDE cerrado; `--aplicar` para escribir. |

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
