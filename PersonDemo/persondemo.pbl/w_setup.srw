forward
global type w_setup from window
end type
type ddlb_theme from dropdownlistbox within w_setup
end type
type ddlb_1 from dropdownlistbox within w_setup
end type
type st_theme from statictext within w_setup
end type
type cb_close from commandbutton within w_setup
end type
type cb_save from commandbutton within w_setup
end type
end forward

global type w_setup from window
integer width = 2043
integer height = 532
boolean titlebar = true
string title = "Configuración"
boolean controlmenu = true
boolean minbox = true
windowtype windowtype = popup!
long backcolor = 16777215
string icon = "AppIcon!"
boolean center = true
ddlb_theme ddlb_theme
ddlb_1 ddlb_1
st_theme st_theme
cb_close cb_close
cb_save cb_save
end type
global w_setup w_setup

type variables
String is_theme
String is_theme_path //= "C:\Program Files (x86)\Appeon19\Shared\PowerBuilder\theme190\"
end variables

forward prototypes
public subroutine of_add_theme ()
end prototypes

public subroutine of_add_theme ();
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
//10-09-2026: w_setup.srw · of_add_theme
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
Int i
String ls_theme_name

is_theme_path = gs_dir + "\theme\"

ddlb_1.DirList(is_theme_path+'*.*', 32768+16) 

For i = 2 To ddlb_1.totalitems( )
	ls_theme_name = ddlb_1.text(i)
	IF Left(ls_theme_name,1) = "[" THEN ls_theme_name = Mid(ls_theme_name, 2)
	IF Right(ls_theme_name,1) = "]" THEN ls_theme_name = Left(ls_theme_name, Len(ls_theme_name) - 1)
	ls_theme_name = Trim(ls_theme_name)
	IF FileExists(is_theme_path + ls_theme_name + "\theme.json") THEN
		ddlb_theme.Additem(ls_theme_name)
	END IF
Next 
ddlb_theme.Additem("Do Not Use Themes")


end subroutine

on w_setup.create
this.ddlb_theme=create ddlb_theme
this.ddlb_1=create ddlb_1
this.st_theme=create st_theme
this.cb_close=create cb_close
this.cb_save=create cb_save
this.Control[]={this.ddlb_theme,&
this.ddlb_1,&
this.st_theme,&
this.cb_close,&
this.cb_save}
end on

on w_setup.destroy
destroy(this.ddlb_theme)
destroy(this.ddlb_1)
destroy(this.st_theme)
destroy(this.cb_close)
destroy(this.cb_save)
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
//10-09-2026: w_setup.srw · open
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String ls_theme

//[Setup]
ls_theme=  ProFileString(gs_fichero_ini, "Setup", "Theme ", "Do Not Use Themes")

of_add_theme()
ddlb_theme.Text = ls_theme
is_theme = ls_theme
ddlb_theme.SelectItem(ddlb_theme.FindItem(ls_theme , 1))






end event

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
//10-09-2026: w_setup.srw · closequery
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
//of_deactive()
end event

type ddlb_theme from dropdownlistbox within w_setup
integer x = 571
integer y = 68
integer width = 1029
integer height = 504
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

type ddlb_1 from dropdownlistbox within w_setup
boolean visible = false
integer x = 87
integer y = 100
integer width = 869
integer height = 476
integer taborder = 10
integer textsize = -12
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type st_theme from statictext within w_setup
integer x = 78
integer y = 80
integer width = 462
integer height = 96
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 553648127
string text = "Theme:"
alignment alignment = right!
long bordercolor = 1073741824
boolean focusrectangle = false
end type

type cb_close from commandbutton within w_setup
integer x = 1019
integer y = 320
integer width = 366
integer height = 100
integer taborder = 30
integer textsize = -10
string facename = "Segoe UI"
string text = "Cancelar"
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
//10-09-2026: w_setup.srw · clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
close(parent)
end event

type cb_save from commandbutton within w_setup
integer x = 613
integer y = 320
integer width = 366
integer height = 100
integer taborder = 20
integer textsize = -10
string facename = "Segoe UI"
string text = "Acepatr"
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
//10-09-2026: w_setup.srw · clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String  ls_theme

//[Setup]
ls_theme = Trim(ddlb_theme.Text )


//Grabar Variables
//[Setup]
SetProFileString(gs_fichero_ini, "Setup", "Theme ", ls_theme)


IF ls_theme = is_theme  AND  ls_theme <> "Do Not Use Themes" THEN
	close(parent)
ElseIF ls_theme <> is_theme  AND  ls_theme = "Do Not Use Themes" THEN
	MessageBox("Configuración Guardada", "Reinicie la aplicación para que los cambios tengan efecto.")
	close(parent)
ELSE
	ApplyTheme (is_theme_path + ls_theme)
	is_theme = ls_theme
END IF

//Trampa pàra refrescar el Tema:
If isvalid(w_con_facturas) Then w_con_facturas.dw_1.TriggerEvent(Constructor!)
If IsValid(w_frame) Then 	w_frame.iuo_web.TriggerEvent(Constructor!)
If isvalid(w_con_facturas) Then 
	w_con_facturas.dw_1.TriggerEvent(Constructor!)
	w_con_facturas.wf_cambiar_tema(ls_theme)
End if
If IsValid(w_dashboard) Then 	
	w_dashboard.wb_1.NavigateToString(w_dashboard.in_dash.of_get_html())
End IF

end event

