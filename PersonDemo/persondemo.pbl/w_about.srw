forward
global type w_about from window
end type
type st_2 from statictext within w_about
end type
type st_11 from statictext within w_about
end type
type p_logo from picture within w_about
end type
type st_copyright from statictext within w_about
end type
type st_evento from statictext within w_about
end type
type cb_1 from commandbutton within w_about
end type
type ln_2 from line within w_about
end type
type r_1 from rectangle within w_about
end type
type r_2 from rectangle within w_about
end type
type lb_info from listbox within w_about
end type
end forward

global type w_about from window
integer x = 672
integer y = 268
integer width = 2423
integer height = 1332
windowtype windowtype = response!
long backcolor = 16777215
boolean center = true
windowanimationstyle openanimation = centeranimation!
windowanimationstyle closeanimation = centeranimation!
st_2 st_2
st_11 st_11
p_logo p_logo
st_copyright st_copyright
st_evento st_evento
cb_1 cb_1
ln_2 ln_2
r_1 r_1
r_2 r_2
lb_info lb_info
end type
global w_about w_about

type variables
Private string is_pbversion, is_pbbuild = "1"
end variables

forward prototypes
private function string wf_nombre_mes (integer ai_mes)
private function string wf_nombre_fecha (datetime adt_fecha)
private subroutine wf_pb_version ()
public subroutine wf_set_colors ()
end prototypes

private function string wf_nombre_mes (integer ai_mes);
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
//10-09-2026: w_about.srw · wf_nombre_mes
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String ls_mes

Choose Case ai_mes
CASE 1
	ls_mes = "Enero"
CASE 2
	ls_mes = "Febrero"
CASE 3
	ls_mes = "Marzo"
CASE 4
	ls_mes = "Abril"
CASE 5
	ls_mes = "Mayo"
CASE 6
	ls_mes = "Junio"
CASE 7
	ls_mes = "Julio"
CASE 8
	ls_mes = "Agosto"
CASE 9
	ls_mes = "Septiembre"
CASE 10
	ls_mes = "Octubre"
CASE 11
	ls_mes = "Noviembre"
CASE 12
	ls_mes = "Diciembre"
END CHOOSE


Return ls_mes

end function

private function string wf_nombre_fecha (datetime adt_fecha);
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
//10-09-2026: w_about.srw · wf_nombre_fecha
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
Integer li_dia, li_anyo
string ls_retorno 


li_dia = Day(date(adt_fecha))
li_anyo = Year(date(adt_fecha))


ls_retorno= String(li_dia)+ " de " +wf_nombre_mes(Month(date(adt_fecha)))+" de "+string(li_anyo)+" a "+string(time(adt_fecha))

Return ls_retorno
end function

private subroutine wf_pb_version ();
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
//10-09-2026: w_about.srw · wf_pb_version
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
integer li_return
environment env

li_return = GetEnvironment(env)

IF li_return <> 1 THEN 
	is_pbversion = "????"
	is_pbbuild+= "????"
ELSE
	is_pbversion =string(env.pbmajorrevision)
	if len(is_pbversion ) = 2 then is_pbversion ="20"+is_pbversion 
	is_pbbuild+= string(env.pbbuildnumber)
END IF


end subroutine

public subroutine wf_set_colors ();
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
//10-09-2026: w_about.srw · wf_set_colors
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String ls_themename
Long ll_color

ls_themename = GetTheme()

//Parametrización de Colores
Choose Case ls_themename
	Case "Flat Design Blue"	
		ll_Color= 16744448
	Case "Flat Design Grey"
		ll_Color= 8421504
	Case "Flat Design Silver"
		ll_Color= 9204580
	Case "Flat Design Dark"
		ll_Color= 5131854
	Case "Flat Design Lime"
		ll_Color= 6077026
	Case "Flat Design Orange"	
		ll_Color= 3706358
	Case Else
		ll_Color= 16744448
End Choose

r_1.FillColor = ll_Color
r_1.LineColor= ll_Color
end subroutine

on w_about.create
this.st_2=create st_2
this.st_11=create st_11
this.p_logo=create p_logo
this.st_copyright=create st_copyright
this.st_evento=create st_evento
this.cb_1=create cb_1
this.ln_2=create ln_2
this.r_1=create r_1
this.r_2=create r_2
this.lb_info=create lb_info
this.Control[]={this.st_2,&
this.st_11,&
this.p_logo,&
this.st_copyright,&
this.st_evento,&
this.cb_1,&
this.ln_2,&
this.r_1,&
this.r_2,&
this.lb_info}
end on

on w_about.destroy
destroy(this.st_2)
destroy(this.st_11)
destroy(this.p_logo)
destroy(this.st_copyright)
destroy(this.st_evento)
destroy(this.cb_1)
destroy(this.ln_2)
destroy(this.r_1)
destroy(this.r_2)
destroy(this.lb_info)
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
//10-09-2026: w_about.srw · open
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
string ls_fecha
Datetime ldt_fecha
n_osversion in_osver
String ls_fichero_aplicacion
String ls_build
String ls_ProductName, ls_CompanyName, ls_anyo, ls_LegalCopyright

wf_set_colors()

//Obtengo la Versión de PowerBuilder y el Build
wf_pb_version()

If isPowerclientapp() Then
	ls_fichero_aplicacion = "./persondemo2025.exe"
Else
	ls_fichero_aplicacion = "./persondemo.exe"
End If
	
in_osver.of_GetFileVersionInfo(ls_fichero_aplicacion)
	
ls_ProductName =in_osver.ProductName
ls_CompanyName =in_osver.CompanyName
	
ls_build= mid(in_osver.FixedProductVersion, lastPos(in_osver.FixedProductVersion, ".") + 1, len(in_osver.FixedProductVersion) - lastPos(in_osver.FixedProductVersion, ".")) 


If isnull(ls_ProductName) or trim(ls_ProductName)="" then
	ls_fichero_aplicacion = "./persondemo.pbl"
	
	ls_ProductName = "PersonDemo"
	ls_CompanyName = "RSRSYSTEM"
	
end if

ls_LegalCopyright = in_osver.LegalCopyright

// Ejecutando sin .exe (desde el IDE o con RunPB) no hay datos de version:
// el copyright se quedaba en "Copyright © 2026 ." sin el nombre.
IF IsNull(ls_LegalCopyright) OR Trim(ls_LegalCopyright) = "" THEN
	ls_LegalCopyright = "Ramón San Félix Ramón"
END IF

ldt_fecha=gf_fecha_fichero(ls_fichero_aplicacion)
ls_anyo=string(year(date(ldt_fecha)))
ls_fecha=wf_nombre_fecha(ldt_fecha)

//Información a Mostrar
lb_info.AddItem(ls_ProductName+" "+ls_CompanyName+ " ©")
lb_info.AddItem("Versión "+is_pbversion+" Build "+ls_build )
lb_info.AddItem("Compilado el "+ls_fecha)
lb_info.AddItem("Appeon Power Builder Version "+is_pbversion+" Build "+right(is_pbbuild, 4))
lb_info.AddItem("")
lb_info.AddItem("--")
lb_info.AddItem("www.linkedin.com/in/rasanfe")
lb_info.AddItem("rsrsystem.blogspot.com")
lb_info.AddItem("github.com/rasanfe")   
st_copyright.text="Copyright ©  "+ls_anyo+" "+ls_LegalCopyright+"." 
end event

type st_2 from statictext within w_about
integer x = 87
integer y = 244
integer width = 1819
integer height = 76
integer textsize = -11
integer weight = 700
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8421504
long backcolor = 553648127
boolean enabled = false
string text = "Tu aplicación de siempre, con la web dentro"
boolean focusrectangle = false
end type

type st_11 from statictext within w_about
integer x = 87
integer y = 148
integer width = 1829
integer height = 140
integer textsize = -13
integer weight = 700
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8421504
long backcolor = 553648127
boolean enabled = false
string text = "Modernizando PowerBuilder con Tecnologías Web"
boolean focusrectangle = false
end type

type p_logo from picture within w_about
integer x = 59
integer y = 1092
integer width = 823
integer height = 196
string picturename = "imagenes\logo_gris.png"
boolean focusrectangle = false
end type

type st_copyright from statictext within w_about
integer x = 1202
integer y = 1208
integer width = 1179
integer height = 56
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8421504
long backcolor = 553648127
string text = "Copyright ©  2025 Ramón San Félix Ramón"
alignment alignment = right!
boolean focusrectangle = false
end type

type cb_1 from commandbutton within w_about
integer x = 1883
integer y = 956
integer width = 361
integer height = 88
integer taborder = 1
integer textsize = -8
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string pointer = "Hyperlink!"
string text = "OK"
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
//10-09-2026: w_about.srw · clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
Close(parent)
end event

type ln_2 from line within w_about
long linecolor = 15793151
integer linethickness = 4
integer beginx = 521
integer beginy = 280
integer endx = 1701
integer endy = 280
end type

type r_1 from rectangle within w_about
long linecolor = 33521664
integer linethickness = 4
long fillcolor = 33521664
integer x = 91
integer y = 12
integer width = 2217
integer height = 32
end type

type r_2 from rectangle within w_about
long linecolor = 8421504
integer linethickness = 4
long fillcolor = 8421504
integer x = 265
integer y = 372
integer width = 1979
integer height = 560
end type

type lb_info from listbox within w_about
integer x = 270
integer y = 376
integer width = 1970
integer height = 552
integer taborder = 11
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type

type st_evento from statictext within w_about
integer x = 599
integer y = 952
integer width = 1147
integer height = 116
integer textsize = -7
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 11119017
long backcolor = 553648127
boolean enabled = false
string text = "Appeon PowerBuilder Regional Conference · Spain 2026 · Barcelona, 27 de octubre"
alignment alignment = Center!
boolean focusrectangle = false
end type

