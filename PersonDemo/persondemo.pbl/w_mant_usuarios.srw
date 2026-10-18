//objectcomments Mantenimiento de los usuarios del ERP y su equivalencia con la app movil
forward
global type w_mant_usuarios from window
end type
type cbx_ver_claves from checkbox within w_mant_usuarios
end type
type cb_guardar from commandbutton within w_mant_usuarios
end type
type cb_borrar from commandbutton within w_mant_usuarios
end type
type cb_nuevo from commandbutton within w_mant_usuarios
end type
type dw_usuarios from u_dw within w_mant_usuarios
end type
type st_fichero from statictext within w_mant_usuarios
end type
type mle_fichero from multilineedit within w_mant_usuarios
end type
type gb_acciones from groupbox within w_mant_usuarios
end type
end forward

global type w_mant_usuarios from window
integer width = 4800
integer height = 2652
boolean titlebar = true
string title = "Usuarios del ERP"
boolean minbox = true
boolean maxbox = true
windowstate windowstate = maximized!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
cbx_ver_claves cbx_ver_claves
cb_guardar cb_guardar
cb_borrar cb_borrar
cb_nuevo cb_nuevo
dw_usuarios dw_usuarios
st_fichero st_fichero
mle_fichero mle_fichero
gb_acciones gb_acciones
end type
global w_mant_usuarios w_mant_usuarios

type variables
/*
	La tabla de usuarios del ERP: cada uno con su clave y, al lado, el
	usuario y el PIN con los que entra en la app movil. Es la equivalencia
	que usa la ventana de fichar para abrir la web sin pedir nada.

	En la rejilla las claves se ven (o no, segun "Ver claves") en claro;
	en el fichero van cifradas, y abajo se ve el fichero tal cual.
*/
nvo_ds_json ids_usuarios   // la tabla tal y como esta en el fichero
n_cst_cifrado inv_cifrado
end variables

forward prototypes
public subroutine wf_colocar (integer ai_ancho, integer ai_alto)
public function boolean wf_cargar ()
public function boolean wf_guardar ()
public subroutine wf_mostrar_fichero ()
public subroutine wf_ver_claves (boolean ab_ver)
private function boolean wf_validar ()
end prototypes

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
//17-10-2026: w_mant_usuarios.srw · wf_colocar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Arriba los botones, en medio la rejilla y abajo el fichero tal cual.
	Como en w_mant_facturas: con medidas aun no validas (el sheet recien
	abierto) no se toca nada.
*/
IF ai_ancho < 1000 OR ai_alto < 1000 THEN Return

gb_acciones.x = 46
gb_acciones.y = 20
gb_acciones.width = ai_ancho - 92

cb_nuevo.x = gb_acciones.x + 60
cb_borrar.x = cb_nuevo.x + cb_nuevo.width + 20
cb_guardar.x = cb_borrar.x + cb_borrar.width + 20
cbx_ver_claves.x = cb_guardar.x + cb_guardar.width + 80

cb_nuevo.y = gb_acciones.y + Integer((gb_acciones.height - cb_nuevo.height) / 2) + 16
cb_borrar.y = cb_nuevo.y
cb_guardar.y = cb_nuevo.y
cbx_ver_claves.y = cb_nuevo.y + 10

dw_usuarios.x = 46
dw_usuarios.y = gb_acciones.y + gb_acciones.height + 30
dw_usuarios.width = ai_ancho - 92
dw_usuarios.height = Integer((ai_alto - dw_usuarios.y) / 2)

st_fichero.x = 46
st_fichero.y = dw_usuarios.y + dw_usuarios.height + 30
st_fichero.width = ai_ancho - 92

mle_fichero.x = 46
mle_fichero.y = st_fichero.y + st_fichero.height + 10
mle_fichero.width = ai_ancho - 92
mle_fichero.height = ai_alto - mle_fichero.y - 30
end subroutine

public function boolean wf_cargar ();
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
//17-10-2026: w_mant_usuarios.srw · wf_cargar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Lee el fichero y pasa cada usuario a la rejilla, con las claves ya
	descifradas. Campo a campo por NOMBRE (ImportJson casa por posicion).
*/
Long ll_i, ll_fila

SetPointer(HourGlass!)

IF IsValid(ids_usuarios) THEN DESTROY ids_usuarios
ids_usuarios = CREATE nvo_ds_json

IF ids_usuarios.of_cargar_fichero(gs_fichero_usuarios) < 1 THEN
	SetPointer(Arrow!)
	gf_mensaje("Usuarios", "No se han podido leer los usuarios de:~r~n" + gs_fichero_usuarios)
	Return False
END IF

dw_usuarios.SetRedraw(False)
dw_usuarios.Reset()

FOR ll_i = 1 TO ids_usuarios.RowCount()
	ll_fila = dw_usuarios.InsertRow(0)
	dw_usuarios.SetItem(ll_fila, "usuario",       Trim(ids_usuarios.GetItemString(ll_i, "usuario")))
	dw_usuarios.SetItem(ll_fila, "nombre",        Trim(ids_usuarios.GetItemString(ll_i, "nombre")))
	dw_usuarios.SetItem(ll_fila, "password",      inv_cifrado.of_descifrar(ids_usuarios.GetItemString(ll_i, "password")))
	dw_usuarios.SetItem(ll_fila, "usuario_movil", Trim(ids_usuarios.GetItemString(ll_i, "usuario_movil")))
	dw_usuarios.SetItem(ll_fila, "pin_movil",     inv_cifrado.of_descifrar(ids_usuarios.GetItemString(ll_i, "pin_movil")))
NEXT

dw_usuarios.ResetUpdate()
dw_usuarios.SetRedraw(True)

wf_mostrar_fichero()
SetPointer(Arrow!)
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
//17-10-2026: w_mant_usuarios.srw · wf_guardar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	La rejilla entera vuelve al fichero, con las dos claves CIFRADAS. Se
	rehace la tabla de arriba abajo: son cuatro filas y asi altas, bajas y
	cambios van por el mismo camino.
*/
Long ll_i, ll_fila

IF dw_usuarios.AcceptText() <> 1 THEN Return False
IF NOT wf_validar() THEN Return False

ids_usuarios.Reset()

FOR ll_i = 1 TO dw_usuarios.RowCount()
	ll_fila = ids_usuarios.of_insertar()
	IF ll_fila < 1 THEN
		gf_mensaje("Usuarios", "No se ha podido preparar la tabla para grabarla.")
		Return False
	END IF
	ids_usuarios.SetItem(ll_fila, "usuario",       Upper(Trim(dw_usuarios.GetItemString(ll_i, "usuario"))))
	ids_usuarios.SetItem(ll_fila, "nombre",        Trim(dw_usuarios.GetItemString(ll_i, "nombre")))
	ids_usuarios.SetItem(ll_fila, "password",      inv_cifrado.of_cifrar(dw_usuarios.GetItemString(ll_i, "password")))
	ids_usuarios.SetItem(ll_fila, "usuario_movil", Upper(Trim(dw_usuarios.GetItemString(ll_i, "usuario_movil"))))
	ids_usuarios.SetItem(ll_fila, "pin_movil",     inv_cifrado.of_cifrar(Trim(dw_usuarios.GetItemString(ll_i, "pin_movil"))))
NEXT

IF NOT ids_usuarios.of_guardar_fichero(gs_fichero_usuarios) THEN
	gf_mensaje("Usuarios", "No se ha podido grabar la tabla de usuarios." + &
		"~r~n~r~nMotivo: " + ids_usuarios.is_ultimo_error + &
		"~r~n~r~nSi ha quedado mal, restaurala con restaurar_datos_demo.bat")
	Return False
END IF

dw_usuarios.ResetUpdate()
wf_mostrar_fichero()

MessageBox("Usuarios", "Usuarios guardados.")
Return True
end function

public subroutine wf_mostrar_fichero ();
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
//17-10-2026: w_mant_usuarios.srw · wf_mostrar_fichero
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	El fichero tal y como esta en disco, un usuario por linea: es lo que se
	enseña en la charla, las claves cifradas al lado del usuario.
*/
String ls_json

ls_json = gf_get_jsondata_from_file(gs_fichero_usuarios)
ls_json = gf_replaceall(ls_json, "},{", "},~r~n  {")
ls_json = gf_replaceall(ls_json, "[{", "[~r~n  {")
ls_json = gf_replaceall(ls_json, "}]", "}~r~n]")

mle_fichero.Text = ls_json
end subroutine

public subroutine wf_ver_claves (boolean ab_ver);
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
//17-10-2026: w_mant_usuarios.srw · wf_ver_claves
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Las dos columnas de clave, tapadas o en claro. Hacen falta DOS cosas:
	Edit.Password solo tapa mientras se escribe en la celda; lo que se ve
	fuera de ella lo pinta el Format, y con "[general]" la clave salia en
	claro aunque Edit.Password estuviera puesto.
*/
IF ab_ver THEN
	dw_usuarios.Modify("password.Edit.Password=no pin_movil.Edit.Password=no " + &
		"password.Format='[general]' pin_movil.Format='[general]'")
ELSE
	dw_usuarios.Modify("password.Edit.Password=yes pin_movil.Edit.Password=yes " + &
		"password.Format='*********' pin_movil.Format='****'")
END IF
end subroutine

private function boolean wf_validar ();
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
//17-10-2026: w_mant_usuarios.srw · wf_validar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Antes de grabar: al menos un usuario, sin repetidos, con su clave, y si
	tiene usuario movil, tambien su PIN (si no, no podria abrir la web).
	Se para en la primera fila mala y deja el cursor alli.
*/
Long ll_i, ll_j
String ls_usuario, ls_movil, ls_pin, ls_mensaje, ls_columna

IF dw_usuarios.RowCount() < 1 THEN
	gf_mensaje("Usuarios", "Tiene que quedar al menos un usuario: sin el, nadie podria entrar.")
	Return False
END IF

FOR ll_i = 1 TO dw_usuarios.RowCount()
	ls_usuario = Upper(Trim(dw_usuarios.GetItemString(ll_i, "usuario")))
	ls_movil = Trim(dw_usuarios.GetItemString(ll_i, "usuario_movil"))
	ls_pin = Trim(dw_usuarios.GetItemString(ll_i, "pin_movil"))
	IF IsNull(ls_usuario) THEN ls_usuario = ""
	IF IsNull(ls_movil) THEN ls_movil = ""
	IF IsNull(ls_pin) THEN ls_pin = ""

	ls_mensaje = ""
	IF ls_usuario = "" THEN
		ls_mensaje = "Falta el usuario."
		ls_columna = "usuario"
	ELSEIF IsNull(dw_usuarios.GetItemString(ll_i, "password")) OR dw_usuarios.GetItemString(ll_i, "password") = "" THEN
		ls_mensaje = "Falta la contraseña de " + ls_usuario + "."
		ls_columna = "password"
	ELSEIF ls_movil <> "" AND ls_pin = "" THEN
		ls_mensaje = "Falta el PIN movil de " + ls_usuario + "."
		ls_columna = "pin_movil"
	ELSE
		FOR ll_j = 1 TO ll_i - 1
			IF Upper(Trim(dw_usuarios.GetItemString(ll_j, "usuario"))) = ls_usuario THEN
				ls_mensaje = "El usuario " + ls_usuario + " esta repetido."
				ls_columna = "usuario"
				EXIT
			END IF
		NEXT
	END IF

	IF ls_mensaje <> "" THEN
		dw_usuarios.ScrollToRow(ll_i)
		dw_usuarios.SetColumn(ls_columna)
		dw_usuarios.SetFocus()
		gf_mensaje("Usuarios", ls_mensaje)
		Return False
	END IF
NEXT

Return True
end function

on w_mant_usuarios.create
this.cbx_ver_claves=create cbx_ver_claves
this.cb_guardar=create cb_guardar
this.cb_borrar=create cb_borrar
this.cb_nuevo=create cb_nuevo
this.dw_usuarios=create dw_usuarios
this.st_fichero=create st_fichero
this.mle_fichero=create mle_fichero
this.gb_acciones=create gb_acciones
this.Control[]={this.cbx_ver_claves,&
this.cb_guardar,&
this.cb_borrar,&
this.cb_nuevo,&
this.dw_usuarios,&
this.st_fichero,&
this.mle_fichero,&
this.gb_acciones}
end on

on w_mant_usuarios.destroy
destroy(this.cbx_ver_claves)
destroy(this.cb_guardar)
destroy(this.cb_borrar)
destroy(this.cb_nuevo)
destroy(this.dw_usuarios)
destroy(this.st_fichero)
destroy(this.mle_fichero)
destroy(this.gb_acciones)
end on

event closequery;
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
//17-10-2026: w_mant_usuarios.srw · closequery
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Cambios sin guardar: se pregunta antes de perderlos
Integer li_respuesta

dw_usuarios.AcceptText()
IF dw_usuarios.ModifiedCount() + dw_usuarios.DeletedCount() = 0 THEN Return 0

li_respuesta = MessageBox("Usuarios", "Hay cambios sin guardar. ¿Guardarlos antes de cerrar?", &
	Question!, YesNoCancel!, 1)

CHOOSE CASE li_respuesta
	CASE 1
		IF NOT wf_guardar() THEN Return 1   // no se ha podido: la ventana se queda
	CASE 3
		Return 1
END CHOOSE

Return 0
end event

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
//17-10-2026: w_mant_usuarios.srw · open
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// El fondo del MDI es un WebBrowser y se pinta por encima de todo: se
// esconde mientras haya ventanas, como en las de facturas.
If IsValid(w_frame) Then
	w_frame.iuo_web.Post of_set_visible(False)
End If

This.Post wf_cargar()
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
//17-10-2026: w_mant_usuarios.srw · resize
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
//17-10-2026: w_mant_usuarios.srw · close
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Si era la ultima ventana, vuelve el fondo del MDI
If IsValid(w_frame) Then
	If gf_ventanas_abiertas(w_frame) = 1 Then
		w_frame.iuo_web.Post of_set_visible(True)
	End If
End If

IF IsValid(ids_usuarios) THEN DESTROY ids_usuarios
end event

type cbx_ver_claves from checkbox within w_mant_usuarios
integer x = 1500
integer y = 86
integer width = 500
integer height = 80
integer taborder = 40
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Ver claves"
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
//17-10-2026: w_mant_usuarios.srw · cbx_ver_claves.clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

Parent.wf_ver_claves(This.Checked)
end event

type cb_guardar from commandbutton within w_mant_usuarios
integer x = 960
integer y = 76
integer width = 404
integer height = 100
integer taborder = 30
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
string text = "Guardar"
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
//17-10-2026: w_mant_usuarios.srw · cb_guardar.clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

Parent.wf_guardar()
end event

type cb_borrar from commandbutton within w_mant_usuarios
integer x = 520
integer y = 76
integer width = 404
integer height = 100
integer taborder = 20
integer textsize = -9
integer weight = 700
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
//17-10-2026: w_mant_usuarios.srw · cb_borrar.clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Quita la fila de la rejilla; el fichero no cambia hasta Guardar
Long ll_fila
String ls_usuario

ll_fila = dw_usuarios.GetRow()
IF ll_fila < 1 THEN Return

ls_usuario = Trim(dw_usuarios.GetItemString(ll_fila, "usuario"))
IF IsNull(ls_usuario) THEN ls_usuario = ""

IF MessageBox("Borrar usuario", "¿Seguro que quieres borrar el usuario " + ls_usuario + "?", &
	Question!, YesNo!, 2) <> 1 THEN Return

dw_usuarios.DeleteRow(ll_fila)
end event

type cb_nuevo from commandbutton within w_mant_usuarios
integer x = 80
integer y = 76
integer width = 404
integer height = 100
integer taborder = 10
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
string text = "Nuevo"
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
//17-10-2026: w_mant_usuarios.srw · cb_nuevo.clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Una fila en blanco al final, con el cursor en el usuario
Long ll_fila

ll_fila = dw_usuarios.InsertRow(0)
dw_usuarios.ScrollToRow(ll_fila)
dw_usuarios.SetColumn("usuario")
dw_usuarios.SetFocus()
end event

type dw_usuarios from u_dw within w_mant_usuarios
integer x = 46
integer y = 260
integer width = 4600
integer height = 1000
integer taborder = 50
string dataobject = "dw_usuarios"
boolean vscrollbar = true
boolean ib_logo = false
end type

type st_fichero from statictext within w_mant_usuarios
integer x = 46
integer y = 1300
integer width = 4600
integer height = 72
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Así se guarda en Database\usuarios.json (las dos claves, cifradas con AES):"
boolean focusrectangle = false
end type

type mle_fichero from multilineedit within w_mant_usuarios
integer x = 46
integer y = 1380
integer width = 4600
integer height = 1000
integer taborder = 60
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "Consolas"
long textcolor = 33554432
boolean vscrollbar = true
boolean autohscroll = true
boolean autovscroll = true
boolean displayonly = true
borderstyle borderstyle = stylelowered!
end type

type gb_acciones from groupbox within w_mant_usuarios
integer x = 46
integer y = 20
integer width = 4600
integer height = 200
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Usuarios del ERP y su usuario de la app móvil"
end type
