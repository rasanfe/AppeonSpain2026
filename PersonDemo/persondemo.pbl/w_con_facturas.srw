forward
global type w_con_facturas from window
end type
type wb_1 from webbrowser within w_con_facturas
end type
type dw_1 from vs_dw_json within w_con_facturas
end type
end forward

global type w_con_facturas from window
integer width = 5221
integer height = 2972
boolean titlebar = true
string title = "Listado Facturas"
boolean minbox = true
boolean maxbox = true
windowstate windowstate = maximized!
long backcolor = 67108864
string icon = "AppIcon!"
wb_1 wb_1
dw_1 dw_1
end type
global w_con_facturas w_con_facturas

type prototypes
//Funcion para tomar el directorio de la aplicacion  -64Bits 
FUNCTION	uLong	GetModuleFileName ( uLong lhModule, ref string sFileName, ulong nSize )  LIBRARY "Kernel32.dll" ALIAS FOR "GetModuleFileNameW"
end prototypes

type variables
string is_table
boolean ib_grid_ready = false

// Donde se recuerda como dejo el usuario el grid (orden de columnas,
// ocultas, anchos, alineacion). Lo guarda PowerBuilder: la web solo pinta.
string is_fichero_config
end variables

forward prototypes
public function long wf_retrieve (vs_dw_json adw)
public function string wf_grid_columnas_dinamicas ()
public subroutine wf_grid_cargar_datos ()
public subroutine wf_cambiar_tema (string as_tema_pb)
public subroutine wf_guardar_config ()
public subroutine wf_cargar_config ()
end prototypes

public function long wf_retrieve (vs_dw_json adw);
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
//10-09-2026: w_con_facturas.srw · wf_retrieve
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
Long ll_RowCount
String ls_jsonData

adw.setredraw(false)		
ls_jsonData = gf_get_jsondata_from_file(gs_dir+"\data2026.json")
ll_RowCount = adw.of_cargar_json(ls_jsonData)

adw.setredraw(true)

ib_grid_ready = false
wf_grid_cargar_datos()

Return ll_RowCount
end function

public function string wf_grid_columnas_dinamicas ();
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
//10-09-2026: w_con_facturas.srw · wf_grid_columnas_dinamicas
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Genera la definición JSON de columnas para el grid ReactGHHh
String ls_cols, ls_name, ls_tipo, ls_tipo_corto, ls_extra, ls_header
Integer li_col_count, li_i
Boolean lb_first

li_col_count = Integer(dw_1.Describe("datawindow.column.count"))
If li_col_count < 1 Then Return ""

ls_cols = "["
lb_first = True

For li_i = 1 To li_col_count
	ls_name = dw_1.Describe("#" + String(li_i) + ".name")
	If ls_name = "!" Or ls_name = "?" Or Len(Trim(ls_name)) = 0 Then Continue

	ls_header = dw_1.Describe("#" + String(li_i) + ".name")

	ls_tipo = Lower(Trim(dw_1.Describe("#" + String(li_i) + ".coltype")))
	ls_tipo_corto = Left(ls_tipo, 4)

	ls_extra = ""
	Choose Case ls_tipo_corto
		Case "date", "time"
			ls_extra = ',"formatter":"date"'
		Case "deci", "numb", "long", "inte", "real"
			ls_extra = ',"filter":"agNumberColumnFilter"'
	End Choose

	If Not lb_first Then ls_cols = ls_cols + ","
	lb_first = False

	ls_cols = ls_cols + '{"field":"' + Trim(ls_name) + '","headerName":"' + Trim(ls_header) + '"' &
		+ ',"defaultWidth":150' + ls_extra + '}'
Next

ls_cols = ls_cols + "]"
Return ls_cols
end function

public subroutine wf_grid_cargar_datos ();
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
//10-09-2026: w_con_facturas.srw · wf_grid_cargar_datos
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Carga los datos del dw_1 dinámico en el grid React
String ls_cols, ls_json

If dw_1.RowCount() < 1 Then
	wb_1.EvaluateJavascriptAsync("if(window.clearData) window.clearData()")
	Return
End If

// Generar columnas dinámicamente desde el DW
ls_cols = wf_grid_columnas_dinamicas()
If Len(ls_cols) < 5 Then Return

// Enviar columnas al grid
wb_1.EvaluateJavascriptSync("window.setColumns(" + ls_cols + ")")

// Exportar datos del DW a JSON y cargarlos en el grid
ls_json = dw_1.ExportJson(False)
wb_1.EvaluateJavascriptSync("window.loadData(" + ls_json + ")")

// Título para exportaciones
wb_1.EvaluateJavascriptAsync("if(window.setTitle) window.setTitle('Listado Facturas')")

ib_grid_ready = True

/*
	Si el usuario ya dejo guardada SU configuracion, mandan sus anchos.
	Solo se autoajusta cuando no hay nada guardado (la primera vez): si no,
	autoFitColumns pisaba los anchos que acababa de restaurar loadConfig.
*/
IF FileExists(is_fichero_config) THEN
	wf_cargar_config()
ELSE
	wb_1.EvaluateJavascriptAsync("if(window.autoFitColumns) window.autoFitColumns()")
END IF
end subroutine

public subroutine wf_guardar_config ();
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
//10-09-2026: w_con_facturas.srw · wf_guardar_config
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Le pregunta al grid como esta configurado y lo guarda en un fichero.

	window.getConfig() devuelve YA un JSON ({"columns":[...]}) con el orden
	de las columnas, cuales estan ocultas, anchos, fijadas y alineacion.
	Devuelve "" si algo va mal y "RESET" si el usuario pidio volver al
	estado de fabrica (entonces se borra el fichero).
*/
String ls_bruto, ls_config
JsonGenerator lnv_json
JsonParser lnv_parser
Long ll_raiz
Integer li_rc

IF NOT ib_grid_ready THEN Return

// EvaluateJavascriptSync devuelve un codigo; el resultado del JavaScript
// viene por REFERENCIA en el segundo argumento.
li_rc = wb_1.EvaluateJavascriptSync("window.getConfig ? window.getConfig() : ~'~'", ls_bruto)
IF li_rc <> 1 OR Trim(ls_bruto) = "" THEN Return

/*
	OJO: lo que devuelve NO es el valor pelado, sino un JSON envuelto:
		{"type":"string","value":"{\"columns\":[...]}"}
	El JSON bueno esta dentro de "value", escapado. Si se guarda la envoltura,
	window.loadConfig() no encuentra .columns y no hace nada (que era justo
	lo que pasaba: se grababa el fichero pero el grid seguia igual).
*/
lnv_parser = CREATE JsonParser
IF lnv_parser.LoadString(ls_bruto) = "" THEN
	ll_raiz = lnv_parser.GetRootItem()
	ls_config = lnv_parser.GetItemString(ll_raiz, "value")
END IF
DESTROY lnv_parser

// Si no venia envuelto, se usa tal cual
IF Trim(ls_config) = "" THEN ls_config = ls_bruto
IF Trim(ls_config) = "" THEN Return

IF Upper(Trim(ls_config)) = "RESET" THEN
	IF FileExists(is_fichero_config) THEN FileDelete(is_fichero_config)
	Return
END IF

lnv_json = CREATE JsonGenerator
IF lnv_json.ImportString(ls_config) > 0 THEN
	lnv_json.SaveToFile(is_fichero_config, EncodingUTF8!)
END IF
DESTROY lnv_json
end subroutine

public subroutine wf_cargar_config ();
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
//10-09-2026: w_con_facturas.srw · wf_cargar_config
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Le devuelve al grid la configuracion que se guardo la ultima vez.
	Se llama DESPUES de cargar los datos: si no, no hay columnas que ordenar.
*/
String ls_config

IF NOT FileExists(is_fichero_config) THEN Return

ls_config = gf_get_jsondata_from_file(is_fichero_config)
IF Trim(ls_config) = "" THEN Return

wb_1.EvaluateJavascriptAsync("if(window.loadConfig) window.loadConfig(" + ls_config + ")")
end subroutine

public subroutine wf_cambiar_tema (string as_tema_pb);
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
//10-09-2026: w_con_facturas.srw · wf_cambiar_tema
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Cambia el tema del grid React según el tema de PowerBuilder
// Recibe el nombre del tema PB (ej: "Flat Design Blue")
String ls_grid_theme

Choose Case as_tema_pb
	Case "Flat Design Dark"
		ls_grid_theme = "dark"
	Case "Flat Design Blue"
		ls_grid_theme = "rsr"
	Case "Flat Design Grey", "Flat Design Silver"
		ls_grid_theme = "silver"
	Case "Flat Design Lime"
		ls_grid_theme = "lime"
	Case "Flat Design Orange"
		ls_grid_theme = "orange"
	Case Else
		ls_grid_theme = "rsr"
End Choose

wb_1.EvaluateJavascriptSync("if(window.setTheme) window.setTheme('" + ls_grid_theme + "')")
end subroutine

on w_con_facturas.create
this.wb_1=create wb_1
this.dw_1=create dw_1
this.Control[]={this.wb_1,&
this.dw_1}
end on

on w_con_facturas.destroy
destroy(this.wb_1)
destroy(this.dw_1)
end on

event open;
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
//10-09-2026: w_con_facturas.srw · open
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
If IsValid(w_frame) Then
	w_frame.iuo_web.Post of_set_visible(False)
End If

is_fichero_config = gs_dir + "/grid_config.json"

// Navegar al grid React en el WebBrowser
String ls_path
ls_path =  gs_dir+"/dist/index.html"
wb_1.Navigate(ls_path)


//wf_retrieve(dw_1)






end event

event resize;
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
//10-09-2026: w_con_facturas.srw · resize
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
dw_1.Width = Width - 200
dw_1.Height = Height -300
wb_1.Width = Width - 200
wb_1.Height = Height -300




end event

event close;
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
//10-09-2026: w_con_facturas.srw · close
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
Long ll_OpenWindows

// Antes de nada: recordar como ha dejado el usuario el grid
wf_guardar_config()

If IsValid(w_frame) Then
	ll_OpenWindows = gf_ventanas_abiertas(w_frame)
	
	If ll_OpenWindows = 1 Then
		w_frame.iuo_web.Post of_set_visible(True)
	End If
End If
end event

type wb_1 from webbrowser within w_con_facturas
event ue_dblclick ( string as_row )
integer x = 50
integer y = 20
integer width = 5115
integer height = 2832
boolean border = false
end type

event ue_dblclick(string as_row);
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
//10-09-2026: w_con_facturas.srw · ue_dblclick
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Doble clic en el grid: la web NO abre la factura, se lo pide a PowerBuilder.
	El grid manda el numero de fila del DataWindow (_dw_row); de ahi salen la
	serie y el numero de factura, y se abre la ventana de mantenimiento nativa.
*/
Long ll_fila
String ls_serie, ls_factura

ll_fila = Long(as_row)
IF ll_fila < 1 OR ll_fila > dw_1.RowCount() THEN Return

ls_serie = Trim(dw_1.GetItemString(ll_fila, "serie"))
ls_factura = Trim(dw_1.GetItemString(ll_fila, "factura"))

// Se abre como SHEET del MDI, igual que en el ejemplo: aparece en el tab.
// Al cerrarse, ella misma refresca este listado si hubo cambios.
OpenSheetWithParm(w_mant_facturas, ls_serie + "|" + ls_factura, w_frame, 0, Layered!)
end event

event navigationcompleted;
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
//10-09-2026: w_con_facturas.srw · navigationcompleted
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Aplicar tema del grid según tema de PowerBuilder y encender el mantenimiento
String ls_theme
Integer li_rc

// El camino de vuelta: JavaScript -> PowerBuilder
IF ib_grid_ready = False THEN
	li_rc = wb_1.RegisterEvent("ue_dblclick")
END IF

ls_theme = ProfileString(gs_fichero_ini, "Setup", "Theme ", "Do Not Use Themes")
wf_cambiar_tema(ls_theme)
// El grid ya trae el doble clic: al encenderlo, llama a ue_dblclick
this.EvaluateJavascriptAsync("if(window.setMaintenanceEnabled) window.setMaintenanceEnabled(true)")
wf_retrieve(dw_1)
end event

type dw_1 from vs_dw_json within w_con_facturas
boolean visible = false
integer x = 50
integer y = 20
integer width = 5115
integer height = 2832
integer taborder = 60
string dataobject = "dw_new"
boolean hscrollbar = true
boolean vscrollbar = true
end type

