forward
global type u_web_background from userobject
end type
type wb_1 from webbrowser within u_web_background
end type
end forward

global type u_web_background from userobject
integer width = 503
integer height = 864
string text = "none"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
event ue_resice pbm_size
wb_1 wb_1
end type
global u_web_background u_web_background

type variables
Boolean lb_navigateCompleted=False
end variables

forward prototypes
public subroutine of_set_visible (boolean ab_visible)
public function string of_get_html (string as_color_fondo, string as_logo, string as_opacidad)
end prototypes

event ue_resice;
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
//10-09-2026: u_web_background.sru · ue_resice
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
wb_1.height = This.Height
wb_1.Width = This.Width

end event

public function string of_get_html (string as_color_fondo, string as_logo, string as_opacidad);
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
//10-09-2026: u_web_background.sru · of_get_html
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	El HTML del fondo. Fuera del constructor para que se lea: es el mismo
	patron que n_cst_dashboard.of_get_html().
*/
String ls_c
ls_c = Char(34)   // las comillas dobles del HTML

Return "<!DOCTYPE html>~r~n" + &
	"<html lang=" + ls_c + "es" + ls_c + ">~r~n" + &
	"<head>~r~n" + &
	"  <meta charset=" + ls_c + "UTF-8" + ls_c + ">~r~n" + &
	"  <title>RSRSYSTEM</title>~r~n" + &
	"  <style>~r~n" + &
	"    html, body { height: 100%; margin: 0; }~r~n" + &
	"    body {~r~n" + &
	"      background-color: " + as_color_fondo + ";~r~n" + &
	"      display: flex;~r~n" + &
	"      align-items: center;~r~n" + &
	"      justify-content: center;~r~n" + &
	"      overflow: hidden;~r~n" + &
	"      user-select: none;~r~n" + &
	"      cursor: default;~r~n" + &
	"    }~r~n" + &
	"    img {~r~n" + &
	"      width: 46vw;~r~n" + &
	"      max-width: 620px;~r~n" + &
	"      height: auto;~r~n" + &
	"      opacity: " + as_opacidad + ";~r~n" + &
	"      animation: aparece 1.2s ease-out;~r~n" + &
	"    }~r~n" + &
	"    @keyframes aparece { from { opacity: 0; } to { opacity: " + as_opacidad + "; } }~r~n" + &
	"  </style>~r~n" + &
	"</head>~r~n" + &
	"<body>~r~n" + &
	"  <img src=" + ls_c + as_logo + ls_c + " alt=" + ls_c + "RSR System" + ls_c + ">~r~n" + &
	"  <script>document.addEventListener(" + ls_c + "contextmenu" + ls_c + ", function(e) { e.preventDefault(); });</script>~r~n" + &
	"</body>~r~n" + &
	"</html>"
end function

public subroutine of_set_visible (boolean ab_visible);
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
//10-09-2026: u_web_background.sru · of_set_visible
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
If ab_visible=False Then
	wb_1.Visible=False
	This.visible=False
Else
	If lb_navigateCompleted = True Then
		This.BringToTop = True
		This.visible=True
		wb_1.Visible=True
	End IF	
End IF	


end subroutine

on u_web_background.create
this.wb_1=create wb_1
this.Control[]={this.wb_1}
end on

on u_web_background.destroy
destroy(this.wb_1)
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
//10-09-2026: u_web_background.sru · constructor
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Fondo del MDI: una pagina HTML con el logo en marca de agua.

	El logo YA NO se descarga de internet (antes venia de rsrsystem.com):
	viaja con la aplicacion, en la carpeta imagenes. Asi el fondo se ve igual
	con el wifi apagado, que es como se da la charla.
*/
String ls_html, ls_color_fondo, ls_themename, ls_logo, ls_opacidad, ls_fichero
Long ll_Color_Fondo
Integer li_fichero
Long ll_escritos

ls_themename = GetTheme()

// Parametrizacion por tema: color de fondo, version del logo y cuanto se ve.
// Sobre fondo oscuro el gris normal no se distingue: va la version aclarada.
Choose Case ls_themename
	Case "Flat Design Blue"
		ls_color_fondo = "#bfbfbf"
		ll_Color_Fondo = 12566463
		ls_logo = "logo_gris.png"
		ls_opacidad = "0.10"
	Case "Flat Design Grey"
		ls_color_fondo = "#999999"
		ll_Color_Fondo = 10066329
		ls_logo = "logo_gris.png"
		ls_opacidad = "0.10"
	Case "Flat Design Silver"
		ls_color_fondo = "#949AA5"
		ll_Color_Fondo = 10853012
		ls_logo = "logo_gris.png"
		ls_opacidad = "0.10"
	Case "Flat Design Dark"
		ls_color_fondo = "#141414"
		ll_Color_Fondo = 1315860
		ls_logo = "logo_gris_claro.png"
		ls_opacidad = "0.16"
	Case "Flat Design Lime"
		ls_color_fondo = "#bfbfbf"
		ll_Color_Fondo = 12566463
		ls_logo = "logo_gris.png"
		ls_opacidad = "0.10"
	Case "Flat Design Orange"
		ls_color_fondo = "#e5e5e5"
		ll_Color_Fondo = 15066597
		ls_logo = "logo_gris.png"
		ls_opacidad = "0.10"
	Case Else
		ls_color_fondo = "#FFFFFF"
		ll_Color_Fondo = 16777215
		ls_logo = "logo_gris.png"
		ls_opacidad = "0.10"
End Choose

This.BackColor = ll_Color_Fondo

ls_html = of_get_html(ls_color_fondo, ls_logo, ls_opacidad)

// El HTML se escribe JUNTO a la imagen, para que el <img> relativo la
// encuentre. Con NavigateToString el documento no tiene carpeta y no podria.
ls_fichero = gs_dir + "/imagenes/fondo.html"

li_fichero = FileOpen(ls_fichero, StreamMode!, Write!, LockWrite!, Replace!)
IF li_fichero > 0 THEN
	// FileWrite, NO FileWriteEx: con FileWriteEx el fichero se quedaba
	// en los 3 bytes del BOM y el fondo salia vacio.
	ll_escritos = FileWrite(li_fichero, ls_html)
	FileClose(li_fichero)
END IF

IF ll_escritos > 0 THEN
	wb_1.Navigate(ls_fichero)
ELSE
	// Si no se pudo escribir, al menos que se vea el color del tema
	wb_1.NavigateToString(ls_html)
END IF

end event

type wb_1 from webbrowser within u_web_background
boolean visible = false
integer width = 517
integer height = 872
boolean enabled = false
boolean popupwindow = false
boolean contextmenu = false
boolean border = false
end type

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
//10-09-2026: u_web_background.sru · navigationcompleted
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
If lb_navigateCompleted = False Then
	lb_navigateCompleted=True
	Parent.of_set_visible(True)
End If
end event

