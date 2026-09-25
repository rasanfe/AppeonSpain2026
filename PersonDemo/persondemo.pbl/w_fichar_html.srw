forward
global type w_fichar_html from window
end type
type wb_1 from webbrowser within w_fichar_html
end type
end forward

global type w_fichar_html from window
integer width = 4311
integer height = 2752
boolean titlebar = true
string title = "Control Horario"
boolean minbox = false
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
windowtype windowtype = response!
wb_1 wb_1
end type
global w_fichar_html w_fichar_html

type variables
Boolean ib_RegisterEvent = FALSE

// Configuracion: vive en Setting.ini, seccion [FicharDemo]. Ni la URL ni el
// usuario ni el PIN se escriben en el codigo.
String is_url_base
String is_usuario
String is_pin
end variables

forward prototypes
public subroutine wf_leer_configuracion ()
public function boolean wf_entrar ()
end prototypes

public subroutine wf_leer_configuracion ();
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
//10-09-2026: w_fichar_html.srw · wf_leer_configuracion
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

is_url_base = ProfileString(gs_fichero_ini, "FicharDemo", "Url", "http://localhost:5080")
is_usuario  = ProfileString(gs_fichero_ini, "FicharDemo", "Usuario", "")
is_pin      = ProfileString(gs_fichero_ini, "FicharDemo", "Pin", "")
end subroutine

public function boolean wf_entrar ();
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
//10-09-2026: w_fichar_html.srw · wf_entrar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	El puente PowerBuilder -> web, en tres pasos:

	  1. PowerBuilder se identifica el mismo contra la API (usuario + PIN).
	  2. Con su token pide un TICKET de un solo uso, que vive 30 segundos.
	  3. Abre la web pasandole ese ticket. La web lo canjea por su propia
	     sesion y el usuario entra sin volver a teclear nada.

	El ticket caduca al primer uso, asi que da igual que viaje en la URL.
*/
String ls_body, ls_respuesta, ls_token, ls_ticket, ls_url, ls_tema
RestClient lrc_cliente
JsonParser ljp_parser
Long ll_raiz, ll_estado
Integer li_ret

wf_leer_configuracion()

IF is_usuario = "" OR is_pin = "" THEN
	gf_mensaje("Fichar", "Falta el usuario o el PIN en la seccion [FicharDemo] de Setting.ini.")
	Return False
END IF

SetPointer(HourGlass!)

// --- 1. Login -----------------------------------------------------------
lrc_cliente = CREATE RestClient
lrc_cliente.SetRequestHeader("Content-Type", "application/json;charset=UTF-8")
lrc_cliente.SetRequestHeader("Accept", "application/json")

ls_body = '{"username":"' + is_usuario + '","password":"' + is_pin + '","origen":"PB"}'
li_ret = lrc_cliente.SendPostRequest(is_url_base + "/api/Auth/Login", ls_body, ls_respuesta)
ll_estado = lrc_cliente.GetResponseStatusCode()
DESTROY lrc_cliente

IF li_ret <> 1 THEN
	SetPointer(Arrow!)
	gf_mensaje("Fichar", "No hay conexion con la API.~r~n~r~nURL: " + is_url_base)
	Return False
END IF

IF ll_estado <> 200 THEN
	SetPointer(Arrow!)
	gf_mensaje("Fichar", "Usuario o PIN incorrectos (respuesta " + String(ll_estado) + ").")
	Return False
END IF

ljp_parser = CREATE JsonParser
ljp_parser.LoadString(ls_respuesta)
ll_raiz = ljp_parser.GetRootItem()
ls_token = ljp_parser.GetItemString(ll_raiz, "token")
DESTROY ljp_parser

IF ls_token = "" THEN
	SetPointer(Arrow!)
	gf_mensaje("Fichar", "La API no ha devuelto ningun token.")
	Return False
END IF

// --- 2. Ticket de un solo uso -------------------------------------------
lrc_cliente = CREATE RestClient
lrc_cliente.SetRequestHeader("Content-Type", "application/json;charset=UTF-8")
lrc_cliente.SetRequestHeader("Accept", "application/json")
lrc_cliente.SetRequestHeader("Authorization", "Bearer " + ls_token)

li_ret = lrc_cliente.SendPostRequest(is_url_base + "/api/Auth/Ticket", "{}", ls_respuesta)
ll_estado = lrc_cliente.GetResponseStatusCode()
DESTROY lrc_cliente

IF li_ret <> 1 OR ll_estado <> 200 THEN
	SetPointer(Arrow!)
	gf_mensaje("Fichar", "No se ha podido obtener el ticket de acceso.")
	Return False
END IF

ljp_parser = CREATE JsonParser
ljp_parser.LoadString(ls_respuesta)
ll_raiz = ljp_parser.GetRootItem()
ls_ticket = ljp_parser.GetItemString(ll_raiz, "ticket")
DESTROY ljp_parser

SetPointer(Arrow!)

IF ls_ticket = "" THEN
	gf_mensaje("Fichar", "El ticket ha venido vacio.")
	Return False
END IF

// --- 3. Abrir la web con el ticket --------------------------------------
// embedded=true es el aviso a la web de que quien la abre es PowerBuilder:
// con eso cambia su interfaz sin ser una version distinta de la aplicacion.
//
// Y de paso le decimos con QUE TEMA se esta pintando el ERP, para que la web
// se vista igual. Es lo mismo que ya hace el grid de facturas.
ls_tema = ProfileString(gs_fichero_ini, "Setup", "Theme ", "")
IF Trim(ls_tema) = "" THEN
	ls_tema = ProfileString(gs_fichero_ini, "Setup", "Theme", "")
END IF

ls_url = is_url_base + "/sso?t=" + ls_ticket + "&embedded=true"
IF Trim(ls_tema) <> "" THEN
	// El nombre del tema solo lleva letras y espacios ("Flat Design Blue"),
	// asi que basta con cambiar los espacios: no hace falta un url-encode.
	ls_url = ls_url + "&tema=" + gf_replaceall(Trim(ls_tema), " ", "%20")
END IF

wb_1.Navigate(ls_url)

Return True
end function

on w_fichar_html.create
this.wb_1=create wb_1
this.Control[]={this.wb_1}
end on

on w_fichar_html.destroy
destroy(this.wb_1)
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
//10-09-2026: w_fichar_html.srw · open
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

This.Post wf_entrar()
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
//10-09-2026: w_fichar_html.srw · resize
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

wb_1.Move(0, 0)
wb_1.Resize(This.WorkSpaceWidth(), This.WorkSpaceHeight())
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
//10-09-2026: w_fichar_html.srw · close
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

// Nada que deshacer: es una response! y no toca el fondo del MDI.
end event

type wb_1 from webbrowser within w_fichar_html
event ue_close_window ( string as_arg )
event ue_gf_msgbox ( string as_json )
integer x = 0
integer y = 0
integer width = 4283
integer height = 2632
boolean border = false
boolean bringtotop = true
end type

event ue_close_window(string as_arg);
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
//10-09-2026: w_fichar_html.srw · ue_close_window
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Lo llama la web:  window.webBrowser.ue_close_window('CLOSE')
// La web no puede cerrar una ventana de PowerBuilder: se lo pide.
If as_arg = "CLOSE" Then
	// OJO con el Post (21-09-2026): el evento DEBE retornar antes de que muera la ventana.
	// El canal de WebView2 es síncrono y el JavaScript se queda esperando respuesta; si aquí
	// se cierra en línea, el host se destruye sin contestar y la web recibe
	// "No parameters in result". Cerrar es lo único que no se puede hacer... en el acto.
	Post Close(Parent)
End If
end event

event ue_gf_msgbox(string as_json);
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
//10-09-2026: w_fichar_html.srw · ue_gf_msgbox
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Lo llama la web:  window.webBrowser.ue_gf_msgbox('{"title":...,"message":...}')
// El texto lo decide la web; quien lo pinta, con aspecto nativo, es el escritorio.
JsonParser ljp_parser
Long ll_raiz
String ls_titulo, ls_mensaje

ljp_parser = CREATE JsonParser
ljp_parser.LoadString(as_json)
ll_raiz = ljp_parser.GetRootItem()
ls_titulo  = ljp_parser.GetItemString(ll_raiz, "title")
ls_mensaje = ljp_parser.GetItemString(ll_raiz, "message")
DESTROY ljp_parser

gf_mensaje(ls_titulo, ls_mensaje)
end event

event navigationstart;
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
//10-09-2026: w_fichar_html.srw · navigationstart
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Sin RegisterEvent, JavaScript no puede llamar a PowerBuilder.
// Se registra una sola vez, en la primera navegacion.
Integer li_rc1, li_rc2

IF ib_RegisterEvent = FALSE THEN
	li_rc1 = wb_1.RegisterEvent("ue_close_window")
	li_rc2 = wb_1.RegisterEvent("ue_gf_msgbox")
	IF li_rc1 = 1 AND li_rc2 = 1 THEN
		ib_RegisterEvent = TRUE
	END IF
END IF
end event
