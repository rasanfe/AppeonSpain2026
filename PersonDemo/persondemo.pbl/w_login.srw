//objectcomments Login del ERP, con sus propios usuarios (Database/usuarios.json)
forward
global type w_login from window
end type
type cbx_recordar from checkbox within w_login
end type
type cb_cancel from commandbutton within w_login
end type
type cb_ok from commandbutton within w_login
end type
type sle_password from singlelineedit within w_login
end type
type sle_usuario from singlelineedit within w_login
end type
type p_logo from picture within w_login
end type
type st_password from statictext within w_login
end type
type st_userid from statictext within w_login
end type
type gb_login from groupbox within w_login
end type
end forward

global type w_login from window
integer x = 567
integer y = 272
integer width = 2062
integer height = 1717
boolean titlebar = true
string title = "PersonDemo - Login"
boolean controlmenu = true
windowtype windowtype = response!
string icon = "imagenes\icono.ico"
toolbaralignment toolbaralignment = alignatleft!
boolean center = true
cbx_recordar cbx_recordar
cb_cancel cb_cancel
cb_ok cb_ok
sle_password sle_password
sle_usuario sle_usuario
p_logo p_logo
st_password st_password
st_userid st_userid
gb_login gb_login
end type
global w_login w_login

type variables
/*
	Calco del login del ejemplo PersonDemo (Blog), sin base de datos: los
	usuarios del ERP viven en Database/usuarios.json con la clave cifrada, y
	de leerlos se ocupa n_cst_usuarios.

	"Recordar" deja usuario y clave (cifrada) en el Setting.ini, como el
	ejemplo: en la charla no hay que teclearla delante de la sala.
*/
n_cst_usuarios inv_usuarios
n_cst_cifrado inv_cifrado
end variables

on w_login.create
this.cbx_recordar=create cbx_recordar
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
this.sle_password=create sle_password
this.sle_usuario=create sle_usuario
this.p_logo=create p_logo
this.st_password=create st_password
this.st_userid=create st_userid
this.gb_login=create gb_login
this.Control[]={this.cbx_recordar,&
this.cb_cancel,&
this.cb_ok,&
this.sle_password,&
this.sle_usuario,&
this.p_logo,&
this.st_password,&
this.st_userid,&
this.gb_login}
end on

on w_login.destroy
destroy(this.cbx_recordar)
destroy(this.cb_cancel)
destroy(this.cb_ok)
destroy(this.sle_password)
destroy(this.sle_usuario)
destroy(this.p_logo)
destroy(this.st_password)
destroy(this.st_userid)
destroy(this.gb_login)
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
//17-10-2026: w_login.srw · open
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String ls_recordar

ls_recordar = ProfileString(gs_fichero_ini, "Setup", "Recordar", "N")

IF ls_recordar = "S" THEN
	cbx_recordar.Checked = True
	sle_usuario.Text = ProfileString(gs_fichero_ini, "Setup", "Usuario", "")
	sle_password.Text = inv_cifrado.of_descifrar(ProfileString(gs_fichero_ini, "Setup", "Password", ""))
ELSE
	cbx_recordar.Checked = False
	sle_usuario.Text = ""
	sle_password.Text = ""
END IF
end event

type cbx_recordar from checkbox within w_login
integer x = 704
integer y = 1189
integer width = 402
integer height = 80
integer taborder = 30
integer textsize = -10
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "Recordar"
end type

type cb_cancel from commandbutton within w_login
integer x = 1143
integer y = 1469
integer width = 343
integer height = 96
integer taborder = 50
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Cancelar"
boolean cancel = true
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
//17-10-2026: w_login.srw · cb_cancel.clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Sin login no hay ERP: al cerrar el login se cierra la aplicacion
Close(Parent)
end event

type cb_ok from commandbutton within w_login
integer x = 640
integer y = 1469
integer width = 343
integer height = 96
integer taborder = 40
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Aceptar"
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
//17-10-2026: w_login.srw · cb_ok.clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String ls_usuario, ls_password, ls_recordar

ls_usuario = Upper(Trim(sle_usuario.Text))
ls_password = sle_password.Text

IF NOT inv_usuarios.of_validar(ls_usuario, ls_password) THEN
	gf_mensaje("Login", "¡Usuario o contraseña incorrectos!")
	sle_password.SetFocus()
	Return
END IF

gs_usuario = ls_usuario

IF cbx_recordar.Checked THEN
	ls_recordar = "S"
ELSE
	ls_recordar = "N"
	ls_usuario = ""
	ls_password = ""
END IF

SetProfileString(gs_fichero_ini, "Setup", "Usuario", ls_usuario)
SetProfileString(gs_fichero_ini, "Setup", "Password", inv_cifrado.of_cifrar(ls_password))
SetProfileString(gs_fichero_ini, "Setup", "Recordar", ls_recordar)

Open(w_frame)
Close(Parent)
end event

type sle_password from singlelineedit within w_login
integer x = 704
integer y = 1009
integer width = 937
integer height = 80
integer taborder = 20
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
boolean password = true
end type

type sle_usuario from singlelineedit within w_login
integer x = 704
integer y = 829
integer width = 937
integer height = 80
integer taborder = 10
integer textsize = -10
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
textcase textcase = upper!
end type

type p_logo from picture within w_login
integer x = 300
integer y = 56
integer width = 1399
integer height = 525
string picturename = "imagenes\logo.png"
boolean focusrectangle = false
end type

type st_password from statictext within w_login
integer x = 361
integer y = 1009
integer width = 325
integer height = 80
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "&Password:"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_userid from statictext within w_login
integer x = 357
integer y = 829
integer width = 325
integer height = 80
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "Usuario:"
alignment alignment = right!
boolean focusrectangle = false
end type

type gb_login from groupbox within w_login
integer x = 142
integer y = 641
integer width = 1714
integer height = 720
integer textsize = -10
integer weight = 700
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388608
string text = "Login"
borderstyle borderstyle = styleraised!
end type
