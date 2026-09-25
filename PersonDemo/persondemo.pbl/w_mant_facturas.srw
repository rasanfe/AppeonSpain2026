forward
global type w_mant_facturas from window
end type
type st_criterio from statictext within w_mant_facturas
end type
type sle_busqueda from singlelineedit within w_mant_facturas
end type
type st_registros from statictext within w_mant_facturas
end type
type dw_lista from u_dw within w_mant_facturas
end type
type cb_guardar from commandbutton within w_mant_facturas
end type
type cb_borrar from commandbutton within w_mant_facturas
end type
type cb_nueva from commandbutton within w_mant_facturas
end type
type dw_1 from u_dw within w_mant_facturas
end type
type gb_busqueda from groupbox within w_mant_facturas
end type
type gb_registros from groupbox within w_mant_facturas
end type
type gb_acciones from groupbox within w_mant_facturas
end type
end forward

global type w_mant_facturas from window
integer width = 7045
integer height = 2652
boolean titlebar = true
string title = "Mantenimiento de Facturas"
boolean minbox = true
boolean maxbox = true
windowstate windowstate = maximized!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
st_criterio st_criterio
sle_busqueda sle_busqueda
st_registros st_registros
dw_lista dw_lista
cb_guardar cb_guardar
cb_borrar cb_borrar
cb_nueva cb_nueva
dw_1 dw_1
gb_busqueda gb_busqueda
gb_registros gb_registros
gb_acciones gb_acciones
end type
global w_mant_facturas w_mant_facturas

type variables
// Factura que se esta editando
String is_serie
String is_factura
String is_empresa
String is_anyo

// Columna por la que busca el campo de arriba. Se cambia pinchando en la
// cabecera de la lista, como en la ventana del ejemplo.
String is_columna_buscar = "razon"

// Parametro con el que se abrio ("serie|factura" o "NUEVA")
String is_parametro

// Los datos viven en un JSON, no en una base de datos
String is_fichero_json
Long il_fila            // fila del datastore de esta factura (0 = es un alta)
nvo_ds_json ids_datos   // el JSON entero, en memoria
Boolean ib_alta = False
Boolean ib_cambios = False
end variables

forward prototypes
public subroutine wf_inicializar ()
public subroutine wf_colocar (integer ai_ancho, integer ai_alto)
public function boolean wf_abrir_json ()
public subroutine wf_pintar_lista ()
public subroutine wf_cargar_maestros ()
public function boolean wf_mostrar (string as_serie, string as_factura)
public function boolean wf_nueva ()
public function boolean wf_guardar ()
public function boolean wf_borrar ()
public subroutine wf_navegar (boolean ab_anterior)
public subroutine wf_buscar (string as_texto)
public subroutine wf_refrescar ()
private function boolean wf_escribir_json ()
private function string wf_siguiente_factura (string as_serie)
private function long wf_buscar_fila (string as_serie, string as_factura)
end prototypes

public subroutine wf_inicializar ();
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
//10-09-2026: w_mant_facturas.srw · wf_inicializar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Lo que antes hacia el open. Se llama con Post: la ventana ya esta pintada.
	Parametro: "serie|factura", o "NUEVA"
*/
String ls_serie, ls_factura
Long ll_barra, ll_fila

SetPointer(HourGlass!)

// Colocar con el tamaño que tiene la ventana AHORA (ya esta en pantalla)
wf_colocar(This.WorkSpaceWidth(), This.WorkSpaceHeight())

IF NOT wf_abrir_json() THEN
	Close(This)
	Return
END IF

wf_cargar_maestros()
wf_pintar_lista()

IF Upper(is_parametro) = "NUEVA" THEN
	wf_nueva()
	SetPointer(Arrow!)
	Return
END IF

ll_barra = Pos(is_parametro, "|")
IF ll_barra > 0 THEN
	ls_serie = Left(is_parametro, ll_barra - 1)
	ls_factura = Mid(is_parametro, ll_barra + 1)
END IF

IF ls_factura = "" THEN
	// Sin factura concreta: se muestra la primera de la lista
	IF dw_lista.RowCount() > 0 THEN
		dw_lista.SetRow(1)
		wf_mostrar(dw_lista.GetItemString(1, "serie"), dw_lista.GetItemString(1, "factura"))
	END IF
	SetPointer(Arrow!)
	Return
END IF

IF NOT wf_mostrar(ls_serie, ls_factura) THEN
	gf_mensaje("Facturas", "No se encuentra la factura " + ls_serie + "/" + ls_factura)
	SetPointer(Arrow!)
	Return
END IF

// Dejar la lista posicionada en esa factura
FOR ll_fila = 1 TO dw_lista.RowCount()
	IF Trim(dw_lista.GetItemString(ll_fila, "serie")) = Trim(ls_serie) &
		AND Trim(dw_lista.GetItemString(ll_fila, "factura")) = Trim(ls_factura) THEN
		dw_lista.ScrollToRow(ll_fila)
		dw_lista.SelectRow(0, False)
		dw_lista.SelectRow(ll_fila, True)
		EXIT
	END IF
NEXT

SetPointer(Arrow!)
end subroutine

public subroutine wf_colocar (integer ai_ancho, integer ai_alto);
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
//10-09-2026: w_mant_facturas.srw · wf_colocar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	El mismo reparto que la ventana del ejemplo: la lista ocupa la mitad
	izquierda, el detalle la derecha, y todo crece con la ventana.

	Va en una funcion (y no solo en el resize) porque al abrir el sheet
	maximizado el resize llega con medidas aun sin fijar: los anchos salian
	negativos y la ventana aparecia VACIA, viendose el fondo del MDI.
*/
IF ai_ancho < 1000 OR ai_alto < 1000 THEN Return   // medidas aun no validas

/*
	El bloque de busqueda (gb_busqueda, st_criterio, sle_busqueda) NO se
	recoloca: se queda como esta puesto en el painter. Antes se le fijaba
	aqui la x/y y al arrancar "saltaba" un poco hacia arriba, pisando el
	ajuste hecho a mano.

	Solo se estiran los ANCHOS, para que la zona de busqueda acompañe a la
	lista cuando la ventana crece.
*/
gb_registros.x = 46
st_registros.x = 56

gb_busqueda.width = ai_ancho / 2 - 20
sle_busqueda.width = ai_ancho / 2 - sle_busqueda.x - 20

dw_lista.x=46
dw_lista.y=gb_busqueda.y + gb_busqueda.height + 36
dw_lista.width= ai_ancho / 2
dw_lista.height= ai_alto - dw_lista.y - gb_registros.height  - 60

gb_registros.y=dw_lista.y + dw_lista.height + 10
st_registros.y=gb_registros.y + 70

gb_registros.width=ai_ancho / 2 -20
st_registros.width=ai_ancho / 2 - 40

dw_1.x=dw_lista.x+dw_lista.width + 20
dw_1.y=256
dw_1.width= ai_ancho / 2 - 100
dw_1.height= ai_alto -300

// Una sola fila de botones: aqui no hay SqlExecutor que valga
/*
	La zona de botones de la derecha, dentro de un groupbox, para que haga
	juego con el "Criterio de Busqueda" de la izquierda: misma altura, mismo
	alto y los botones centrados dentro.
*/
gb_acciones.x = dw_1.x
gb_acciones.y = gb_busqueda.y
gb_acciones.height = gb_busqueda.height
gb_acciones.width = dw_1.width

cb_nueva.x = gb_acciones.x + 290   // 40 + 150 + 100 de margen
cb_borrar.x = cb_nueva.x + cb_nueva.width + 20
cb_guardar.x = cb_borrar.x + cb_borrar.width + 20

// Centrados en el groupbox, igual que el campo de busqueda en el suyo
cb_nueva.y = gb_acciones.y + Integer((gb_acciones.height - cb_nueva.height) / 2) + 16
cb_borrar.y = cb_nueva.y
cb_guardar.y = cb_nueva.y
end subroutine

public function boolean wf_abrir_json ();
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
//10-09-2026: w_mant_facturas.srw · wf_abrir_json
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Carga el fichero de facturas en el datastore. Aqui el JSON hace de base
	de datos: se lee al abrir y se reescribe al grabar, y de las dos cosas
	sabe nvo_ds_json, no esta ventana.
*/
Long ll_filas

is_fichero_json = gs_dir + "/data2026.json"

IF IsValid(ids_datos) THEN DESTROY ids_datos
ids_datos = CREATE nvo_ds_json

ll_filas = ids_datos.of_cargar_fichero(is_fichero_json)
IF ll_filas < 1 THEN
	gf_mensaje("Facturas", "No se han podido leer las facturas de:~r~n" + is_fichero_json)
	Return False
END IF

Return True
end function

public subroutine wf_pintar_lista ();
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
//10-09-2026: w_mant_facturas.srw · wf_pintar_lista
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Vuelca el datastore en la lista de la izquierda.

	OJO: NO se usa ImportJson. ImportJson casa las columnas por POSICION, y el
	JSON trae un campo mas (forma_pago) que la lista no tiene: todo se corria
	un puesto y el subtotal salia vacio (le llegaba un texto). Se copia campo
	a campo por NOMBRE, que ademas deja claro que hay detras.
*/
Long ll_i, ll_fila

IF NOT IsValid(ids_datos) THEN Return

dw_lista.SetRedraw(False)
dw_lista.Reset()

FOR ll_i = 1 TO ids_datos.RowCount()
	ll_fila = dw_lista.InsertRow(0)

	dw_lista.SetItem(ll_fila, "fecha",         ids_datos.GetItemDateTime(ll_i, "fecha"))
	dw_lista.SetItem(ll_fila, "serie",         ids_datos.GetItemString(ll_i, "serie"))
	dw_lista.SetItem(ll_fila, "factura",       ids_datos.GetItemString(ll_i, "factura"))
	dw_lista.SetItem(ll_fila, "cliente",       ids_datos.GetItemString(ll_i, "cliente"))
	dw_lista.SetItem(ll_fila, "razon",         ids_datos.GetItemString(ll_i, "razon"))
	dw_lista.SetItem(ll_fila, "cod_fp",        ids_datos.GetItemString(ll_i, "cod_fp"))
	dw_lista.SetItem(ll_fila, "subtotal",      ids_datos.GetItemDecimal(ll_i, "subtotal"))
	dw_lista.SetItem(ll_fila, "total_iva",     ids_datos.GetItemDecimal(ll_i, "total_iva"))
	dw_lista.SetItem(ll_fila, "importe",       ids_datos.GetItemDecimal(ll_i, "importe"))
	dw_lista.SetItem(ll_fila, "situacion",     ids_datos.GetItemString(ll_i, "situacion"))
	dw_lista.SetItem(ll_fila, "fecha_factura", ids_datos.GetItemDateTime(ll_i, "fecha_factura"))
	dw_lista.SetItem(ll_fila, "obra",          ids_datos.GetItemString(ll_i, "obra"))
	dw_lista.SetItem(ll_fila, "descripcion",   ids_datos.GetItemString(ll_i, "descripcion"))
	dw_lista.SetItem(ll_fila, "empresa",       ids_datos.GetItemString(ll_i, "empresa"))
	dw_lista.SetItem(ll_fila, "anyo",          ids_datos.GetItemString(ll_i, "anyo"))
NEXT

dw_lista.ResetUpdate()
dw_lista.SetRedraw(True)

st_registros.Text = "Total registros: " + String(dw_lista.RowCount(), "#,###,###,##0")
end subroutine

public subroutine wf_cargar_maestros ();
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
//10-09-2026: w_mant_facturas.srw · wf_cargar_maestros
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Los desplegables del detalle (cliente, forma de pago y obra) son
	DropDownDataWindow EXTERNAL: no consultan ninguna tabla. Los "maestros"
	se sacan del propio JSON de facturas, quedandose con los distintos.

	OJO al quitar repetidos: NO vale Find("codigo = '29'"). Las columnas son
	char, PowerBuilder las rellena de espacios y la comparacion no casa nunca
	-> las obras salian repetidas 300 veces. Se lleva la cuenta aparte, en un
	string con los codigos ya vistos.
*/
DataWindowChild ldwc
Long ll_i, ll_fila
String ls_cod, ls_vistos

IF NOT IsValid(ids_datos) THEN Return

// --- Clientes: codigo + razon social ---------------------------------
IF dw_1.GetChild("cliente", ldwc) = 1 THEN
	ldwc.Reset()
	ls_vistos = "|"
	FOR ll_i = 1 TO ids_datos.RowCount()
		ls_cod = Trim(ids_datos.GetItemString(ll_i, "cliente"))
		IF ls_cod = "" THEN CONTINUE
		IF Pos(ls_vistos, "|" + ls_cod + "|") > 0 THEN CONTINUE
		ls_vistos = ls_vistos + ls_cod + "|"
		ll_fila = ldwc.InsertRow(0)
		ldwc.SetItem(ll_fila, "codigo", ls_cod)
		ldwc.SetItem(ll_fila, "razon", ids_datos.GetItemString(ll_i, "razon"))
		ldwc.SetItem(ll_fila, "empresa", "1")
	NEXT
	ldwc.SetSort("razon A")
	ldwc.Sort()
END IF

// --- Formas de pago: codigo + texto ----------------------------------
IF dw_1.GetChild("cod_fp", ldwc) = 1 THEN
	ldwc.Reset()
	ls_vistos = "|"
	FOR ll_i = 1 TO ids_datos.RowCount()
		ls_cod = Trim(ids_datos.GetItemString(ll_i, "cod_fp"))
		IF ls_cod = "" THEN CONTINUE
		IF Pos(ls_vistos, "|" + ls_cod + "|") > 0 THEN CONTINUE
		ls_vistos = ls_vistos + ls_cod + "|"
		ll_fila = ldwc.InsertRow(0)
		ldwc.SetItem(ll_fila, "forma", ls_cod)
		ldwc.SetItem(ll_fila, "texto1", ids_datos.GetItemString(ll_i, "forma_pago"))
		ldwc.SetItem(ll_fila, "empresa", "1")
	NEXT
	ldwc.SetSort("texto1 A")
	ldwc.Sort()
END IF

// --- Obras: codigo + descripcion -------------------------------------
IF dw_1.GetChild("obra", ldwc) = 1 THEN
	ldwc.Reset()
	ls_vistos = "|"
	FOR ll_i = 1 TO ids_datos.RowCount()
		ls_cod = Trim(ids_datos.GetItemString(ll_i, "obra"))
		IF ls_cod = "" THEN CONTINUE
		IF Pos(ls_vistos, "|" + ls_cod + "|") > 0 THEN CONTINUE
		ls_vistos = ls_vistos + ls_cod + "|"
		ll_fila = ldwc.InsertRow(0)
		ldwc.SetItem(ll_fila, "codigo", ls_cod)
		ldwc.SetItem(ll_fila, "descripcion", ids_datos.GetItemString(ll_i, "descripcion"))
		ldwc.SetItem(ll_fila, "cliente", ids_datos.GetItemString(ll_i, "cliente"))
		ldwc.SetItem(ll_fila, "empresa", "1")
	NEXT
	ldwc.SetSort("descripcion A")
	ldwc.Sort()
END IF
end subroutine

public function boolean wf_mostrar (string as_serie, string as_factura);
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
//10-09-2026: w_mant_facturas.srw · wf_mostrar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Lleva una factura al detalle de la derecha.
*/

il_fila = wf_buscar_fila(as_serie, as_factura)
IF il_fila = 0 THEN Return False

is_serie = as_serie
is_factura = as_factura
ib_alta = False

// Esa fila al detalle, campo a campo por NOMBRE (ImportJson casa por
// posicion y el JSON trae un campo mas que el detalle: se descolocaba todo)
Long ll_det

dw_1.Reset()
ll_det = dw_1.InsertRow(0)

dw_1.SetItem(ll_det, "fecha",         ids_datos.GetItemDateTime(il_fila, "fecha"))
dw_1.SetItem(ll_det, "serie",         ids_datos.GetItemString(il_fila, "serie"))
dw_1.SetItem(ll_det, "factura",       ids_datos.GetItemString(il_fila, "factura"))
dw_1.SetItem(ll_det, "cliente",       ids_datos.GetItemString(il_fila, "cliente"))
dw_1.SetItem(ll_det, "cod_fp",        ids_datos.GetItemString(il_fila, "cod_fp"))
dw_1.SetItem(ll_det, "subtotal",      ids_datos.GetItemDecimal(il_fila, "subtotal"))
dw_1.SetItem(ll_det, "total_iva",     ids_datos.GetItemDecimal(il_fila, "total_iva"))
dw_1.SetItem(ll_det, "importe",       ids_datos.GetItemDecimal(il_fila, "importe"))
dw_1.SetItem(ll_det, "situacion",     ids_datos.GetItemString(il_fila, "situacion"))
dw_1.SetItem(ll_det, "fecha_factura", ids_datos.GetItemDateTime(il_fila, "fecha_factura"))
dw_1.SetItem(ll_det, "obra",          ids_datos.GetItemString(il_fila, "obra"))
dw_1.SetItem(ll_det, "empresa",       ids_datos.GetItemString(il_fila, "empresa"))
dw_1.SetItem(ll_det, "anyo",          ids_datos.GetItemString(il_fila, "anyo"))

dw_1.ResetUpdate()

cb_borrar.Enabled = True
Return True
end function

public function boolean wf_nueva ();
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
//10-09-2026: w_mant_facturas.srw · wf_nueva
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Alta: una factura en blanco, con el siguiente numero libre de la serie.
*/
String ls_serie
Long ll_nueva

IF NOT IsValid(ids_datos) THEN
	IF NOT wf_abrir_json() THEN Return False
END IF

ls_serie = "1"
il_fila = 0
ib_alta = True
is_serie = ls_serie
is_factura = wf_siguiente_factura(ls_serie)

dw_1.Reset()
ll_nueva = dw_1.InsertRow(0)

dw_1.SetItem(ll_nueva, "serie", ls_serie)
dw_1.SetItem(ll_nueva, "factura", is_factura)
dw_1.SetItem(ll_nueva, "fecha", DateTime(Today(), Now()))
dw_1.SetItem(ll_nueva, "empresa", "1")
dw_1.SetItem(ll_nueva, "anyo", String(Year(Today())))
dw_1.SetItem(ll_nueva, "situacion", "S")
dw_1.SetItem(ll_nueva, "subtotal", 0)
dw_1.SetItem(ll_nueva, "total_iva", 0)
dw_1.SetItem(ll_nueva, "importe", 0)

cb_borrar.Enabled = False
dw_1.SetFocus()
dw_1.SetColumn("cliente")

Return True
end function

public function boolean wf_guardar ();
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
//10-09-2026: w_mant_facturas.srw · wf_guardar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Devuelve al JSON lo que se haya escrito en el detalle. Si es un alta,
	añade la fila; si no, actualiza la que se abrio.

	Razon social y forma de pago no estan en el detalle pero SI en la lista:
	se copian de otra factura del mismo cliente. Sin base de datos no hay
	maestro donde mirarlas.
*/
Long ll_i
String ls_cliente, ls_cod_fp, ls_obra
DataWindowChild ldwc_obra

IF NOT IsValid(ids_datos) THEN Return False

dw_1.AcceptText()
IF dw_1.RowCount() < 1 THEN Return False

IF Trim(dw_1.GetItemString(1, "cliente")) = "" THEN
	gf_mensaje("Facturas", "Falta el cliente.")
	dw_1.SetColumn("cliente")
	Return False
END IF

IF ib_alta THEN
	il_fila = ids_datos.of_insertar()
	IF il_fila < 1 THEN
		gf_mensaje("Facturas", "No se ha podido crear la factura nueva.")
		Return False
	END IF
	ids_datos.SetItem(il_fila, "serie", dw_1.GetItemString(1, "serie"))
	ids_datos.SetItem(il_fila, "factura", dw_1.GetItemString(1, "factura"))
	ids_datos.SetItem(il_fila, "empresa", "1")
	ids_datos.SetItem(il_fila, "anyo", String(Year(Today())))
	ids_datos.SetItem(il_fila, "situacion", "S")
END IF

ids_datos.SetItem(il_fila, "fecha",         dw_1.GetItemDateTime(1, "fecha"))
ids_datos.SetItem(il_fila, "fecha_factura", dw_1.GetItemDateTime(1, "fecha"))
ids_datos.SetItem(il_fila, "cliente",       dw_1.GetItemString(1, "cliente"))
ids_datos.SetItem(il_fila, "cod_fp",        dw_1.GetItemString(1, "cod_fp"))
ids_datos.SetItem(il_fila, "obra",          dw_1.GetItemString(1, "obra"))
ids_datos.SetItem(il_fila, "subtotal",      dw_1.GetItemDecimal(1, "subtotal"))
ids_datos.SetItem(il_fila, "total_iva",     dw_1.GetItemDecimal(1, "total_iva"))
ids_datos.SetItem(il_fila, "importe",       dw_1.GetItemDecimal(1, "importe"))

/*
	Hay campos que se VEN en la lista pero no se teclean en el detalle: la
	razon social, el texto de la forma de pago y la descripcion de la obra.
	La descripcion sale del propio desplegable (que hace de maestro); la
	razon y la forma de pago, de otra factura que las tenga.
	Sin esto, la factura nueva salia en la lista sin obra.
*/
ls_obra = Trim(dw_1.GetItemString(1, "obra"))
ids_datos.SetItem(il_fila, "descripcion", "")
IF ls_obra <> "" THEN
	IF dw_1.GetChild("obra", ldwc_obra) = 1 THEN
		FOR ll_i = 1 TO ldwc_obra.RowCount()
			IF Trim(ldwc_obra.GetItemString(ll_i, "codigo")) = ls_obra THEN
				ids_datos.SetItem(il_fila, "descripcion", &
					ldwc_obra.GetItemString(ll_i, "descripcion"))
				EXIT
			END IF
		NEXT
	END IF
END IF

ls_cliente = Trim(dw_1.GetItemString(1, "cliente"))
ls_cod_fp = Trim(dw_1.GetItemString(1, "cod_fp"))
FOR ll_i = 1 TO ids_datos.RowCount()
	IF ll_i = il_fila THEN CONTINUE
	IF Trim(ids_datos.GetItemString(ll_i, "cliente")) = ls_cliente THEN
		ids_datos.SetItem(il_fila, "razon", ids_datos.GetItemString(ll_i, "razon"))
		EXIT
	END IF
NEXT
FOR ll_i = 1 TO ids_datos.RowCount()
	IF ll_i = il_fila THEN CONTINUE
	IF Trim(ids_datos.GetItemString(ll_i, "cod_fp")) = ls_cod_fp THEN
		ids_datos.SetItem(il_fila, "forma_pago", ids_datos.GetItemString(ll_i, "forma_pago"))
		EXIT
	END IF
NEXT

IF NOT wf_escribir_json() THEN Return False

is_serie = dw_1.GetItemString(1, "serie")
is_factura = dw_1.GetItemString(1, "factura")
ib_alta = False
ib_cambios = True

wf_refrescar()

Return True
end function

public function boolean wf_borrar ();
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
//10-09-2026: w_mant_facturas.srw · wf_borrar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Baja: quita la factura del JSON. Es una demo, pero borra de verdad.
*/
Integer li_respuesta

IF ib_alta OR il_fila = 0 OR NOT IsValid(ids_datos) THEN Return False

li_respuesta = MessageBox("Borrar factura", &
	"¿Seguro que quieres borrar la factura " + Trim(is_serie) + "/" + Trim(is_factura) + "?", &
	Question!, YesNo!, 2)

IF li_respuesta <> 1 THEN Return False

ids_datos.of_borrar(il_fila)

IF NOT wf_escribir_json() THEN Return False

il_fila = 0
ib_cambios = True
dw_1.Reset()
cb_borrar.Enabled = False
is_factura = ""

wf_refrescar()

Return True
end function

public subroutine wf_navegar (boolean ab_anterior);
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
//10-09-2026: w_mant_facturas.srw · wf_navegar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Los botones << y >> del detalle. En la ventana del ejemplo esto era un
	SELECT max(factura) < actual / min(factura) > actual contra venfac; aqui
	se recorre el JSON, que es la unica "base de datos" que hay.

	Si no hay anterior (o siguiente), da la vuelta: al ultimo o al primero.
*/
Long ll_i, ll_num, ll_actual, ll_elegida, ll_extremo

IF NOT IsValid(ids_datos) THEN Return
IF ib_alta THEN Return

ll_actual = Long(Trim(is_factura))
ll_elegida = 0
ll_extremo = 0

FOR ll_i = 1 TO ids_datos.RowCount()
	IF Trim(ids_datos.GetItemString(ll_i, "serie")) <> Trim(is_serie) THEN CONTINUE

	ll_num = Long(Trim(ids_datos.GetItemString(ll_i, "factura")))

	IF ab_anterior THEN
		// la mayor de las menores
		IF ll_num < ll_actual AND ll_num > ll_elegida THEN ll_elegida = ll_num
		IF ll_num > ll_extremo THEN ll_extremo = ll_num          // para la vuelta
	ELSE
		// la menor de las mayores
		IF ll_num > ll_actual AND (ll_elegida = 0 OR ll_num < ll_elegida) THEN ll_elegida = ll_num
		IF ll_extremo = 0 OR ll_num < ll_extremo THEN ll_extremo = ll_num
	END IF
NEXT

IF ll_elegida = 0 THEN ll_elegida = ll_extremo
IF ll_elegida = 0 THEN Return

wf_mostrar(is_serie, String(ll_elegida))
end subroutine

public subroutine wf_buscar (string as_texto);
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
//10-09-2026: w_mant_facturas.srw · wf_buscar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Reaplica el filtro que haya escrito en el buscador, por la columna que
	este elegida. Es el mismo criterio que el ue_keypress del campo: si no,
	al refrescar la lista se veia un filtro distinto al que puso el usuario.
*/
String ls_texto

ls_texto = Upper(Trim(as_texto))

dw_lista.SetRedraw(False)
IF ls_texto = "" THEN
	dw_lista.SetFilter("")
ELSE
	dw_lista.SetFilter("UPPER(string(" + is_columna_buscar + ")) like '%" + ls_texto + "%'")
END IF
dw_lista.Filter()
dw_lista.SetRedraw(True)

st_registros.Text = "Total registros: " + String(dw_lista.RowCount(), "#,###,###,##0")
end subroutine

public subroutine wf_refrescar ();
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
//10-09-2026: w_mant_facturas.srw · wf_refrescar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Despues de guardar, borrar o dar de alta:
	  1. se repinta la lista de la izquierda (y se le devuelve su filtro),
	  2. se deja el cursor en la factura con la que se estaba,
	  3. y si el LISTADO DE FACTURAS esta abierto, se refresca tambien:
	     los dos miran el mismo fichero, asi que no pueden ir cada uno por
	     su lado.
*/
Long ll_fila

wf_cargar_maestros()
wf_pintar_lista()
wf_buscar(sle_busqueda.Text)

// Dejar la lista donde estaba
IF Trim(is_factura) <> "" THEN
	FOR ll_fila = 1 TO dw_lista.RowCount()
		IF Trim(dw_lista.GetItemString(ll_fila, "serie")) = Trim(is_serie) &
			AND Trim(dw_lista.GetItemString(ll_fila, "factura")) = Trim(is_factura) THEN
			dw_lista.ScrollToRow(ll_fila)
			dw_lista.SelectRow(0, False)
			dw_lista.SelectRow(ll_fila, True)
			EXIT
		END IF
	NEXT
END IF

// El grid React del listado, si esta abierto
IF IsValid(w_con_facturas) THEN
	w_con_facturas.wf_retrieve(w_con_facturas.dw_1)
END IF
end subroutine

private function boolean wf_escribir_json ();
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
//10-09-2026: w_mant_facturas.srw · wf_escribir_json
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Graba el fichero de facturas. Todo lo puñetero de escribir un JSON grande
	(el corte de FileWrite a 32K, el encoding, la comprobacion posterior) vive
	en nvo_ds_json.of_guardar_fichero(): la ventana no tiene que saberlo.
*/
IF NOT IsValid(ids_datos) THEN Return False

IF NOT ids_datos.of_guardar_fichero(is_fichero_json) THEN
	gf_mensaje("Facturas", "No se ha podido grabar el fichero de facturas." + &
		"~r~n~r~nMotivo: " + ids_datos.is_ultimo_error + &
		"~r~n~r~nSi ha quedado a medias, restauralo con restaurar_datos_demo.bat")
	Return False
END IF

Return True
end function

private function string wf_siguiente_factura (string as_serie);
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
//10-09-2026: w_mant_facturas.srw · wf_siguiente_factura
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	El numero de factura es texto en el JSON ("1000"), asi que se compara
	por valor numerico, no alfabeticamente.
*/
Long ll_i, ll_max, ll_numero

ll_max = 0
FOR ll_i = 1 TO ids_datos.RowCount()
	IF Trim(ids_datos.GetItemString(ll_i, "serie")) = Trim(as_serie) THEN
		ll_numero = Long(Trim(ids_datos.GetItemString(ll_i, "factura")))
		IF ll_numero > ll_max THEN ll_max = ll_numero
	END IF
NEXT

Return String(ll_max + 1)
end function

private function long wf_buscar_fila (string as_serie, string as_factura);
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
//10-09-2026: w_mant_facturas.srw · wf_buscar_fila
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	La fila del DATASTORE (no la de la lista, que puede estar filtrada).
*/
Long ll_i

FOR ll_i = 1 TO ids_datos.RowCount()
	IF Trim(ids_datos.GetItemString(ll_i, "serie")) = Trim(as_serie) &
		AND Trim(ids_datos.GetItemString(ll_i, "factura")) = Trim(as_factura) THEN
		Return ll_i
	END IF
NEXT

Return 0
end function

on w_mant_facturas.create
this.st_criterio=create st_criterio
this.sle_busqueda=create sle_busqueda
this.st_registros=create st_registros
this.dw_lista=create dw_lista
this.cb_guardar=create cb_guardar
this.cb_borrar=create cb_borrar
this.cb_nueva=create cb_nueva
this.dw_1=create dw_1
this.gb_busqueda=create gb_busqueda
this.gb_registros=create gb_registros
this.gb_acciones=create gb_acciones
this.Control[]={this.st_criterio,&
this.sle_busqueda,&
this.st_registros,&
this.dw_lista,&
this.cb_guardar,&
this.cb_borrar,&
this.cb_nueva,&
this.dw_1,&
this.gb_busqueda,&
this.gb_registros,&
this.gb_acciones}
end on

on w_mant_facturas.destroy
destroy(this.st_criterio)
destroy(this.sle_busqueda)
destroy(this.st_registros)
destroy(this.dw_lista)
destroy(this.cb_guardar)
destroy(this.cb_borrar)
destroy(this.cb_nueva)
destroy(this.dw_1)
destroy(this.gb_busqueda)
destroy(this.gb_registros)
destroy(this.gb_acciones)
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
//10-09-2026: w_mant_facturas.srw · open
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Aqui NO se carga nada: leer el JSON y montar las 300 filas lleva su rato,
	y si se hace antes de que la ventana se pinte, se queda en blanco (se ve
	solo el tab). Se deja para wf_inicializar(), que corre cuando la ventana
	ya esta en pantalla.
*/
/*
	El fondo del MDI es un WebBrowser, y los controles web se pintan SIEMPRE
	por encima de todo: si no se esconde, tapa la ventana entera y esta
	parece vacia (se ve el logo del fondo). Lo mismo hacen w_con_facturas
	y w_dashboard.
*/
If IsValid(w_frame) Then
	w_frame.iuo_web.Post of_set_visible(False)
End If

is_parametro = Trim(Message.StringParm)

This.Post wf_inicializar()
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
//10-09-2026: w_mant_facturas.srw · resize
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

wf_colocar(newwidth, newheight)
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
//10-09-2026: w_mant_facturas.srw · close
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
Long ll_ventanas

// Si hubo altas, bajas o cambios, el listado se entera aqui
IF ib_cambios AND IsValid(w_con_facturas) THEN
	w_con_facturas.wf_retrieve(w_con_facturas.dw_1)
END IF

// Y si esta era la ultima ventana, vuelve el fondo del MDI
If IsValid(w_frame) Then
	ll_ventanas = gf_ventanas_abiertas(w_frame)
	If ll_ventanas = 1 Then
		w_frame.iuo_web.Post of_set_visible(True)
	End If
End If

IF IsValid(ids_datos) THEN DESTROY ids_datos
end event

type st_criterio from statictext within w_mant_facturas
integer x = 59
integer y = 92
integer width = 297
integer height = 72
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Razón:"
alignment alignment = Right!
boolean focusrectangle = false
end type

type sle_busqueda from singlelineedit within w_mant_facturas
event ue_keypress pbm_keyup
integer x = 389
integer y = 84
integer width = 3625
integer height = 80
integer taborder = 5
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

event ue_keypress;
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
//10-09-2026: w_mant_facturas.srw · ue_keypress
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Igual que en la ventana del ejemplo: busca segun se teclea por la columna
	elegida, posiciona la lista, filtra y avisa en ROJO cuando no hay nada.
*/
Long ll_Row, ll_RowCount
String ls_buscar, ls_tipo
Integer li_len

ll_RowCount = dw_lista.RowCount()
ls_tipo = dw_lista.Describe(Parent.is_columna_buscar + ".coltype")
ls_buscar = Upper(Text)
li_len = Len(ls_buscar)

Choose Case Mid(ls_tipo, 1, 4)
	Case "char"
		ll_Row = dw_lista.Find("Upper(mid(" + Parent.is_columna_buscar + ",1," + String(li_len) + ")) = '" + ls_buscar + "'", 1, ll_RowCount)
	Case "deci", "long", "numb"
		ll_Row = dw_lista.Find("Upper(mid(string(" + Parent.is_columna_buscar + "),1," + String(li_len) + ")) = '" + ls_buscar + "'", 1, ll_RowCount)
End Choose

If ll_Row > 0 Then
	dw_lista.SelectRow(0, False)
	dw_lista.SetRow(ll_Row)
	dw_lista.ScrollToRow(ll_Row)
	dw_lista.SelectRow(ll_Row, True)
End If

If ls_buscar <> "" Then
	dw_lista.SetFilter("UPPER(string(" + Parent.is_columna_buscar + ")) like '%" + ls_buscar + "%'")
Else
	dw_lista.SetFilter("")
End If

dw_lista.Filter()
ll_RowCount = dw_lista.RowCount()

st_registros.Text = "Total registros: " + String(ll_RowCount, "#,###,###,##0")

If ll_RowCount = 0 Then
	sle_busqueda.TextColor = RGB(255, 0, 0)
	st_criterio.TextColor = RGB(255, 0, 0)
	sle_busqueda.Limit = Len(sle_busqueda.Text)
Else
	sle_busqueda.TextColor = RGB(0, 0, 0)
	st_criterio.TextColor = RGB(0, 0, 255)
	sle_busqueda.Limit = 255
End If
end event

event getfocus;
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
//10-09-2026: w_mant_facturas.srw · getfocus
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
This.SelectText(1, Len(This.Text))
end event

type st_registros from statictext within w_mant_facturas
integer x = 78
integer y = 2444
integer width = 4037
integer height = 68
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Total registros: 0"
boolean focusrectangle = false
end type

type dw_lista from u_dw within w_mant_facturas
integer x = 46
integer y = 248
integer width = 4073
integer height = 2148
integer taborder = 10
string dataobject = "dw_mant_lista"
boolean vscrollbar = true
boolean ib_logo = false
end type

event doubleclicked;
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
//10-09-2026: w_mant_facturas.srw · doubleclicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
call super::doubleclicked;
// Doble clic en la lista: esa factura pasa al detalle
IF row < 1 THEN Return

Parent.wf_mostrar(This.GetItemString(row, "serie"), This.GetItemString(row, "factura"))
end event

event clicked;
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
//10-09-2026: w_mant_facturas.srw · clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
call super::clicked;/*
	Pinchando en la CABECERA de una columna, esa columna pasa a ser la que
	busca el campo de arriba (los titulos acaban en "_t").
*/
IF Right(dwo.Name, 2) = "_t" THEN
	st_criterio.Text = dw_lista.Describe(String(dwo.Name) + ".text")
	Parent.is_columna_buscar = Left(Trim(dw_lista.Describe(String(dwo.Name) + ".name")), &
		Len(Trim(dw_lista.Describe(String(dwo.Name) + ".name"))) - 2)
END IF
end event

type cb_nueva from commandbutton within w_mant_facturas
integer x = 4457
integer y = 76
integer width = 404
integer height = 100
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
string text = "Nueva"
end type

event clicked;
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
//10-09-2026: w_mant_facturas.srw · clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
Parent.wf_nueva()
end event

type cb_borrar from commandbutton within w_mant_facturas
integer x = 4869
integer y = 76
integer width = 404
integer height = 100
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
string text = "Borrar"
end type

event clicked;
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
//10-09-2026: w_mant_facturas.srw · clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
Parent.wf_borrar()
end event

type cb_guardar from commandbutton within w_mant_facturas
integer x = 5280
integer y = 76
integer width = 404
integer height = 100
integer taborder = 40
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
string text = "Guardar"
boolean default = true
end type

event clicked;
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
//10-09-2026: w_mant_facturas.srw · clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
IF Parent.wf_guardar() THEN
	// Exito: MessageBox sin icono (Information! por defecto).
	// gf_mensaje es para INCIDENCIAS, que pinta la X de exclamacion.
	MessageBox("Facturas", "Los cambios se han guardado.")
END IF
end event

type dw_1 from u_dw within w_mant_facturas
integer x = 4151
integer y = 256
integer width = 2848
integer height = 2300
integer taborder = 15
string dataobject = "dw_mant_detalle"
boolean livescroll = false
end type

event clicked;
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
//10-09-2026: w_mant_facturas.srw · clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
call super::clicked;
// Los botones << y >> que trae la DataWindow del detalle
Choose Case dwo.Name
	Case "b_ant"
		Parent.wf_navegar(True)
	Case "b_sig"
		Parent.wf_navegar(False)
End Choose
end event

event itemchanged;
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
//10-09-2026: w_mant_facturas.srw · itemchanged
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
call super::itemchanged;/*
	Igual que en la ventana del ejemplo: al teclear el subtotal, el IVA y el
	importe se calculan solos. (Alli la parte de "cliente" recargaba la DDDW
	de obras contra la base de datos; aqui no hay DDDW ni base de datos.)
*/
Dec{2} ld_importe, ld_totaliva
Constant Dec{2} ld_iva = 0.21

Choose Case dwo.name
	Case "subtotal"
		ld_totaliva = Round(Dec(data) * ld_iva, 2)
		ld_importe = Round(Dec(data) + ld_totaliva, 2)
		This.Object.total_iva[row] = ld_totaliva
		This.Object.importe[row] = ld_importe
End Choose
end event

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
//10-09-2026: w_mant_facturas.srw · constructor
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
call super::constructor;
// Es una DataWindow EXTERNAL: no hay transaccion que asignar. Los datos
// entran por ImportJson y salen por GetItem.
This.Modify("datawindow.readonly=no")
end event

type gb_busqueda from groupbox within w_mant_facturas
integer x = 46
integer y = 12
integer width = 4073
integer height = 196
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Criterio de Búsqueda"
end type

type gb_registros from groupbox within w_mant_facturas
integer x = 50
integer y = 2388
integer width = 4078
integer height = 164
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
end type

type gb_acciones from groupbox within w_mant_facturas
integer x = 4151
integer y = 12
integer width = 2848
integer height = 196
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Facturas"
end type

