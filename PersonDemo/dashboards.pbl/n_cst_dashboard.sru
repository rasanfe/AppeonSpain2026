forward
global type n_cst_dashboard from nonvisualobject
end type
end forward

global type n_cst_dashboard from nonvisualobject autoinstantiate
end type

type variables
// Tipos de elementos
Constant string IS_CARD = "card"
Constant string IS_CHART = "chart"

// Tamaños horizontales
Constant string IS_NORMAL = "normal"
Constant string IS_GRANDE = "grande"
Constant string IS_COMPLETO = "completo"

// Tipos de gráficos básicos
Constant string IS_BAR = "bar"
Constant string IS_LINE = "line"
Constant string IS_PIE = "pie"
Constant string IS_DOUGHNUT = "doughnut"

Protected string is_color_primario = "#FF8800"  // Valor por defecto
Protected string is_color_secundario = "#00D97A" // Valor por defecto
Protected integer il_num_columnas = 0  // Siempre responsivo
Protected integer il_zoom = 100

// Estructuras simplificadas
Protected str_dashboard_card istr_card, istr_card_vaciar
Protected str_dashboard_chart istr_chart, istr_chart_vaciar
Protected str_dashboard_config istr_config, istr_config_vaciar


end variables

forward prototypes
protected function string of_generar_dashboard_html (str_dashboard_config astr_config)
protected function string of_generar_tarjeta_html (str_dashboard_card astr_card, integer ai_index)
protected function string of_generar_grafico_html (str_dashboard_chart astr_chart, integer ai_index)
public subroutine of_open_sheet (string as_menu_name)
public subroutine of_add_card (ref str_dashboard_config astr_config)
public subroutine of_add_chart (ref str_dashboard_config astr_config)
public subroutine of_set_zoom (webbrowser a_wb)
public function string of_get_html ()
public function string of_long_to_htmlcolor (long al_color)
public subroutine of_set_theme_colors ()
public function string of_long_to_hex (long al_number, integer ai_digit)
protected function string of_leer_fichero_texto (string as_fichero)
end prototypes

protected function string of_generar_dashboard_html (str_dashboard_config astr_config);
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
//10-09-2026: n_cst_dashboard.sru · of_generar_dashboard_html
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
string ls_html, ls_grid_css, ls_containers, ls_chartjs
integer li_i

// Establecer colores según el tema
of_set_theme_colors()

// CSS con altura fija para evitar desbordamientos
ls_grid_css = "display: flex; flex-wrap: wrap; gap: 20px; width: 100%;"
ls_containers = "    .chart-container { height: calc(100vh - 220px); max-height: calc(100vh - 220px); overflow: hidden; }" + "~r~n" + &
				"    .chart-container canvas { width: 100% !important; height: calc(100% - 60px) !important; }" + "~r~n" + &
				"    .card-normal, .chart-normal { flex: 1 1 300px; max-height: 140px; }" + "~r~n" + &
				"    .card-grande, .chart-grande { flex: 2 1 620px; }" + "~r~n" + &
				"    .card-completo, .chart-completo { flex: 1 1 100%; }" + "~r~n"

ls_html = "<!DOCTYPE html>" + "~r~n"
ls_html += "<html lang=" + char(34) + "es" + char(34) + ">" + "~r~n"
ls_html += "<head>" + "~r~n"
ls_html += "  <meta charset=" + char(34) + "UTF-8" + char(34) + ">" + "~r~n"
ls_html += "  <meta name=" + char(34) + "viewport" + char(34) + " content=" + char(34) + "width=device-width, initial-scale=1.0" + char(34) + ">" + "~r~n"
ls_html += "  <title>Dashboard Simple</title>" + "~r~n"
// Chart.js viaja con la aplicación (js\chart.umd.min.js): la charla se da sin internet.
// Va INCRUSTADO en el HTML: con NavigateToString el documento no tiene carpeta y un
// <script src> relativo no cargaría. Si faltara el fichero, se tira del CDN.
ls_chartjs = of_leer_fichero_texto(gs_dir + "\js\chart.umd.min.js")
IF Len(ls_chartjs) > 0 THEN
	ls_html += "  <script>" + "~r~n" + ls_chartjs + "~r~n" + "  </script>" + "~r~n"
ELSE
	ls_html += "  <script src=" + char(34) + "https://cdn.jsdelivr.net/npm/chart.js" + char(34) + "></script>" + "~r~n"
END IF
ls_html += "  <script>" + "~r~n"
ls_html += "    function openPB(tipo) { " + "~r~n"
ls_html += "      if(window.webBrowser && typeof window.webBrowser.ue_open===" + char(39) + "function" + char(39) + "){ " + "~r~n"
ls_html += "        window.webBrowser.ue_open(tipo); " + "~r~n"
ls_html += "      } " + "~r~n"
ls_html += "    }" + "~r~n"
ls_html += "  </script>" + "~r~n"
ls_html += "  <style>" + "~r~n"
ls_html += "    * { margin: 0; padding: 0; box-sizing: border-box; }" + "~r~n"
ls_html += "    html, body { height: 100vh; font-family: Arial, sans-serif; background-color: #f4f6f8; color: #333; overflow: hidden; }" + "~r~n"
ls_html += "    .dashboard-container { display: flex; flex-direction: column; padding: 20px; height: 100vh; }" + "~r~n"
ls_html += "    .dashboard-row { " + ls_grid_css + " }" + "~r~n"
ls_html += "    .card, .chart-container { background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); width: 100%; }" + "~r~n"
ls_html += "    .card { height: fit-content; }" + "~r~n"
ls_html += "    .card:hover { transform: scale(1.02); transition: transform 0.2s ease; }" + "~r~n"
//ls_html += "    .card h2 { font-size: 18px; font-weight: 600; color: #555; margin-bottom: 15px; text-align: center; }" + "~r~n"
ls_html += "    .card h2 { font-size: 18px; font-weight: 600; color: #555; margin-bottom: 15px; text-align: left; }" + "~r~n"
ls_html += "    .value { font-size: 36px; font-weight: 700; margin-bottom: 8px; text-align: left; }" + "~r~n"
ls_html += "    .amount { font-size: 16px; color: #666; font-weight: 500; text-align: left; }" + "~r~n"
ls_html += ls_containers
ls_html += "  </style>" + "~r~n"
ls_html += "</head>" + "~r~n"
ls_html += "<body>" + "~r~n"
ls_html += "<div class=" + char(34) + "dashboard-container" + char(34) + ">" + "~r~n"
ls_html += "<div class=" + char(34) + "dashboard-row" + char(34) + ">" + "~r~n"

// Generar tarjetas primero
for li_i = 1 to upperbound(astr_config.ast_cards)
	ls_html += of_generar_tarjeta_html(astr_config.ast_cards[li_i], li_i)
next

// Generar gráficos después
for li_i = 1 to upperbound(astr_config.ast_charts)
	ls_html += of_generar_grafico_html(astr_config.ast_charts[li_i], li_i)
next

ls_html += "</div>" + "~r~n"
ls_html += "</div>" + "~r~n"
ls_html += "</body>" + "~r~n"
ls_html += "</html>" + "~r~n"

return ls_html

end function

protected function string of_generar_tarjeta_html (str_dashboard_card astr_card, integer ai_index);
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
//10-09-2026: n_cst_dashboard.sru · of_generar_tarjeta_html
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
string ls_html
string ls_clase_tamano, ls_cursor_style
string ls_mascara_principal, ls_mascara_secundario

// Clase CSS de tamaño
choose case lower(astr_card.ls_tamano)
	case IS_NORMAL
		ls_clase_tamano = "card-normal"
	case IS_GRANDE 
		ls_clase_tamano = "card-grande"
	case IS_COMPLETO
		ls_clase_tamano = "card-completo"
	case else
		ls_clase_tamano = "card-normal"
end choose

// Cursor pointer si hay click
if trim(astr_card.ls_id_click) <> "" then
	ls_cursor_style = "cursor: pointer;"
else
	ls_cursor_style = ""
end if

// Máscaras de decimales
if astr_card.li_decimales_principal > 0 then
	ls_mascara_principal = "#,##0." + fill("0", astr_card.li_decimales_principal)
else
	ls_mascara_principal = "#,##0"
end if

if astr_card.li_decimales_secundario > 0 then
	ls_mascara_secundario = "#,##0." + fill("0", astr_card.li_decimales_secundario)
else
	ls_mascara_secundario = "#,##0"
end if

// Generar HTML
ls_html = "<div class=" + char(34) + "card " + ls_clase_tamano + char(34)

if trim(astr_card.ls_id_click) <> "" then
	ls_html += " onclick=" + char(34) + "openPB(" + char(39) + astr_card.ls_id_click + char(39) + ")" + char(34)
end if

ls_html += " style=" + char(34) + ls_cursor_style + char(34) + ">" + "~r~n"

// Título centrado
ls_html += "<h2>" + astr_card.ls_titulo + "</h2>" + "~r~n"

// Valor principal (cantidad) - con color del tema
ls_html += "<div class=" + char(39) + "value" + char(39) + " style=" + char(39) + "color:" + is_color_primario + ";" + char(39) + ">"
ls_html += string(astr_card.ld_valor_principal, ls_mascara_principal)
if trim(astr_card.ls_unidad_principal) <> "" then
	ls_html += " " + astr_card.ls_unidad_principal
end if
ls_html += "</div>" + "~r~n"

// Valor secundario (importe) - color normal
ls_html += "<div class=" + char(39) + "amount" + char(39) + ">"
ls_html += string(astr_card.ld_valor_secundario, ls_mascara_secundario)
if trim(astr_card.ls_unidad_secundario) <> "" then
	ls_html += " " + astr_card.ls_unidad_secundario
end if
ls_html += "</div>" + "~r~n"

ls_html += "</div>" + "~r~n"

return ls_html


end function

protected function string of_generar_grafico_html (str_dashboard_chart astr_chart, integer ai_index);
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
//10-09-2026: n_cst_dashboard.sru · of_generar_grafico_html
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
string ls_html, ls_data_js, ls_labels_js, ls_clase_tamano
string ls_unidad_y, ls_formato_y, ls_options
string ls_dataset1, ls_dataset2
integer li_i

// Clase CSS de tamaño
choose case lower(astr_chart.ls_tamano)
	case IS_NORMAL
		ls_clase_tamano = "chart-normal"
	case IS_GRANDE 
		ls_clase_tamano = "chart-grande"
	case IS_COMPLETO
		ls_clase_tamano = "chart-completo"
	case else
		ls_clase_tamano = "chart-completo"
end choose

// Unidad y formato Y
ls_unidad_y = trim(astr_chart.ls_unidad_y)
if ls_unidad_y = "" then ls_unidad_y = "€"
ls_formato_y = trim(astr_chart.ls_formato_y)
if ls_formato_y = "" then ls_formato_y = "0"

// Generar etiquetas JS
for li_i = 1 to upperbound(astr_chart.ls_etiquetas_x)
	if li_i > 1 then ls_labels_js += ","
	ls_labels_js += char(39) + astr_chart.ls_etiquetas_x[li_i] + char(39)
next

// Dataset serie 1 (año actual)
ls_dataset1 = "{ label: " + char(39) + astr_chart.ls_label_serie1 + char(39) + ", data: ["
for li_i = 1 to upperbound(astr_chart.ls_valores)
	if li_i > 1 then ls_dataset1 += ","
	// Punto decimal SIEMPRE: con la coma de la configuración regional, "43500,25"
	// dentro del array de JavaScript son DOS valores y todo el gráfico se corre.
	ls_dataset1 += gf_replaceall(astr_chart.ls_valores[li_i], ",", ".")
next
ls_dataset1 += "], backgroundColor: " + char(39) + is_color_primario + char(39) + ", borderColor: " + char(39) + is_color_primario + char(39) + ", borderWidth: 1 }"

// Dataset serie 2 (año anterior) - si existe
if upperbound(astr_chart.ls_valores_serie2) > 0 then
	ls_dataset2 = "{ label: " + char(39) + astr_chart.ls_label_serie2 + char(39) + ", data: ["
	for li_i = 1 to upperbound(astr_chart.ls_valores_serie2)
		if li_i > 1 then ls_dataset2 += ","
		ls_dataset2 += gf_replaceall(astr_chart.ls_valores_serie2[li_i], ",", ".")
	next
	ls_dataset2 += "], backgroundColor: " + char(39) + is_color_secundario + char(39) + ", borderColor: " + char(39) + is_color_secundario + char(39) + ", borderWidth: 1 }"
	
	ls_data_js = ls_dataset1 + "," + ls_dataset2
else
	ls_data_js = ls_dataset1
end if

// Opciones del gráfico
ls_options = "responsive: true, maintainAspectRatio: false,"
ls_options += "plugins: {"
ls_options += "  title: { display: true, text: " + char(39) + astr_chart.ls_titulo + char(39) + ", font: { size: 18 }, padding: { top: 10, bottom: 20 } },"
ls_options += "  legend: { display: true, position: " + char(39) + "top" + char(39) + " }"
ls_options += "},"
ls_options += "scales: {"
ls_options += "  y: { beginAtZero: true, ticks: { callback: function(value) { return new Intl.NumberFormat(" + char(39) + "es-ES" + char(39) + ", { minimumFractionDigits: " + ls_formato_y + ", maximumFractionDigits: " + ls_formato_y + " }).format(value) + " + char(39) + " " + ls_unidad_y + char(39) + "; } } },"
ls_options += "  x: { ticks: { maxRotation: 0, minRotation: 0 } }"
ls_options += "}"

// HTML final
ls_html = "<div class=" + char(34) + "chart-container " + ls_clase_tamano + char(34) + ">" + "~r~n"
ls_html += "<canvas id=" + char(34) + "chart" + string(ai_index) + char(34) + "></canvas>" + "~r~n"
ls_html += "</div>" + "~r~n"
ls_html += "<script>" + "~r~n"
ls_html += "(function() {" + "~r~n"
ls_html += "  const ctx" + string(ai_index) + " = document.getElementById(" + char(39) + "chart" + string(ai_index) + char(39) + ").getContext(" + char(39) + "2d" + char(39) + ");" + "~r~n"
ls_html += "  new Chart(ctx" + string(ai_index) + ", {" + "~r~n"
ls_html += "    type: " + char(39) + astr_chart.ls_chart_type + char(39) + "," + "~r~n"
ls_html += "    data: { labels: [" + ls_labels_js + "], datasets: [" + ls_data_js + "] }," + "~r~n"
ls_html += "    options: { " + ls_options + " }" + "~r~n"
ls_html += "  });" + "~r~n"
ls_html += "})();" + "~r~n"
ls_html += "</script>" + "~r~n"

return ls_html

end function

public subroutine of_open_sheet (string as_menu_name);
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
//10-09-2026: n_cst_dashboard.sru · of_open_sheet
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Implementar en objeto descendiente para abrir ventanas específicas
// Ejemplo: OpenSheet(w_ventas, parent)
end subroutine

public subroutine of_add_card (ref str_dashboard_config astr_config);
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
//10-09-2026: n_cst_dashboard.sru · of_add_card
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
integer li_idx

li_idx = upperbound(astr_config.ast_cards[])
li_idx++

astr_config.ast_cards[li_idx] = istr_card

// Limpiar para próximo uso
istr_card = istr_card_vaciar
end subroutine

public subroutine of_add_chart (ref str_dashboard_config astr_config);
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
//10-09-2026: n_cst_dashboard.sru · of_add_chart
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
integer li_idx

li_idx = upperbound(astr_config.ast_charts[])
li_idx++

astr_config.ast_charts[li_idx] = istr_chart

// Limpiar para próximo uso
istr_chart = istr_chart_vaciar
end subroutine

public subroutine of_set_zoom (webbrowser a_wb);
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
//10-09-2026: n_cst_dashboard.sru · of_set_zoom
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
a_wb.zoom(il_zoom)
end subroutine

public function string of_get_html ();
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
//10-09-2026: n_cst_dashboard.sru · of_get_html
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
return of_generar_dashboard_html(istr_config)
end function

public function string of_long_to_htmlcolor (long al_color);
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
//10-09-2026: n_cst_dashboard.sru · of_long_to_htmlcolor
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Convierte un color LONG (PowerBuilder) al formato HTML "#RRGGBB"
Long  ll_rgb
Integer R,G,B
String ls_r, ls_g, ls_b

ll_rgb=rgb(0,1,0)

R = Mod(al_color, ll_rgb)
al_color = al_color / ll_rgb

G = Mod(al_color, ll_rgb)
al_color = al_color / ll_rgb

B = Mod(al_color, ll_rgb)

ls_r=of_long_to_hex(R, 2)
ls_g=of_long_to_hex(G, 2)
ls_b=of_long_to_hex(B, 2)
	
if isnull(ls_r) THEN ls_r="" 	
if isnull(ls_g) THEN ls_g="" 	
if isnull(ls_b) THEN ls_b="" 	

RETURN "#"+ ls_r + ls_g + ls_b
end function

public subroutine of_set_theme_colors ();
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
//10-09-2026: n_cst_dashboard.sru · of_set_theme_colors
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String ls_themename
Long ll_color1, ll_color2

ls_themename = GetTheme()

Choose Case ls_themename
	Case "Flat Design Blue"	
		ll_color1 = 16744448
		ll_color2 = 16311512
	Case "Flat Design Grey"
		ll_color1 = 8421504
		ll_color2 = 12632256
	Case "Flat Design Silver"
		ll_color1 = 10789024
		ll_color2 = 12632256
	Case "Flat Design Dark"
		ll_color1 = 0
		ll_color2 = 5131854
	Case "Flat Design Lime"
		ll_color1 = 6077026
		ll_color2 = 12632256
	Case "Flat Design Orange"	
		ll_color1 = 3706358
		ll_color2 = 112632256
	Case Else
		ll_color1 = 16744448
		ll_color2 = 16311512
End Choose

// Convertir a formato hex y asignar
is_color_primario = of_long_to_htmlcolor(ll_color1)
is_color_secundario = of_long_to_htmlcolor(ll_color2)
end subroutine

public function string of_long_to_hex (long al_number, integer ai_digit);
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
//10-09-2026: n_cst_dashboard.sru · of_long_to_hex
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
long ll_temp0, ll_temp1
char lc_ret

IF ai_digit > 0 THEN
   ll_temp0 = abs(al_number / (16 ^ (ai_digit - 1 ) ) )
   ll_temp1 = ll_temp0 * (16 ^ (ai_digit - 1 ) )
   IF ll_temp0 > 9 THEN
      lc_ret = char ( ll_temp0 + 55 )
   ELSE
      lc_ret = char ( ll_temp0 + 48 )
   END IF
   RETURN lc_ret + of_long_to_hex( al_number - ll_temp1 , ai_digit - 1)
else
	RETURN ""
END IF
end function

protected function string of_leer_fichero_texto (string as_fichero);
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
//26-09-2026: n_cst_dashboard.sru · of_leer_fichero_texto
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Devuelve el contenido entero de un fichero de texto, o "" si no se puede leer.
// FileReadEx en StreamMode! lee el fichero de una vez (FileRead corta a 32.765).
Integer li_fichero
Long ll_leidos
String ls_texto

IF NOT FileExists(as_fichero) THEN Return ""

li_fichero = FileOpen(as_fichero, StreamMode!, Read!, Shared!)
IF li_fichero < 1 THEN Return ""

ll_leidos = FileReadEx(li_fichero, ls_texto)
FileClose(li_fichero)

IF ll_leidos < 1 OR IsNull(ls_texto) THEN Return ""

Return ls_texto
end function

on n_cst_dashboard.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_dashboard.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;
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
//10-09-2026: n_cst_dashboard.sru · constructor
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Zoom por defecto
environment lenv_object
getenvironment(lenv_object)
if lenv_object.screenwidth > 1600 then
	il_zoom = 110
else
	il_zoom = 80
end if
end event

