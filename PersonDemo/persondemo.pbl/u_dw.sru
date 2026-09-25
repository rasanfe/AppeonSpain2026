forward
global type u_dw from datawindow
end type
end forward

global type u_dw from datawindow
integer width = 686
integer height = 400
string title = "none"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
event ue_retrieve ( )
event key pbm_dwnkey
event ue_aceptar_texto ( )
event mousemove pbm_dwnmousemove
event ue_keydown ( )
event ue_keyup ( )
end type
global u_dw u_dw

type variables
private long il_last_clicked_row = 0
private String is_click_style
protected Boolean dw_has_focus = false
public boolean ib_logo=true


end variables

forward prototypes
public function any of_getitem (long al_row, string as_column)
public function string of_getitemstring (long al_row, string as_column)
public function boolean of_print ()
end prototypes

event ue_Retrieve();
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
//10-09-2026: u_dw.sru · ue_Retrieve
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
//
end event

event key;
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
//10-09-2026: u_dw.sru · key
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
If  Describe("DataWindow.Processing")  = '1' Then
	If key=(KeyUpArrow!)  Then
		This.TriggerEvent("ue_keyup")
		Return
	End IF
	
	If key=(KeyDownArrow!) Then
		This.TriggerEvent("ue_keydown")
		Return
	End If
	
	If key=(KeyEnter!) Then
		DWObject dwo_column
		Event doubleclicked(1, 1, GetselectedRow(0), dwo_column)
		Return
	End If
End If
end event

event ue_aceptar_texto();
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
//10-09-2026: u_dw.sru · ue_aceptar_texto
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
IF dw_has_focus = false THEN
	this.accepttext( )
END IF
end event

event mousemove;
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
//10-09-2026: u_dw.sru · mousemove
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
If  Describe("DataWindow.Processing")  = '1' Then
	SelectRow(0,FALSE)
	If row = 0 Then Return
	SelectRow(row,TRUE)
	ScrollToRow ( row )
End If
end event

event ue_keydown();
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
//10-09-2026: u_dw.sru · ue_keydown
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
Long ll_fila_actual, ll_new_fila

ll_fila_actual=GetselectedRow(0)

SelectRow(0, False)
ll_new_fila= ll_fila_actual + 1

If ll_new_fila > RowCount() Then ll_new_fila=1

SelectRow(ll_new_fila, True)
ScrollToRow ( ll_new_fila )
end event

event ue_keyup();
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
//10-09-2026: u_dw.sru · ue_keyup
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
Long ll_fila_actual, ll_new_fila

ll_fila_actual=GetselectedRow(0)

SelectRow(0, False)
ll_new_fila= ll_fila_actual -1

if ll_new_fila < 1 Then ll_new_fila=RowCount()

SelectRow(ll_new_fila, True)
ScrollToRow ( ll_new_fila )
end event

public function any of_getitem (long al_row, string as_column);
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
//10-09-2026: u_dw.sru · of_getitem
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String ls_montaje, ls_tipo
Any la_value

IF al_row <= 0 Then
	gf_mensaje("of_GetItem", "¡ "+as_column + " row = "+string(al_row)+" !" )
	Return ""
END IF

IF RowCount() = 0 Then
	Return ""
END IF

ls_montaje = as_column +".Coltype"

ls_tipo = this.Describe(ls_montaje)

IF ls_tipo="!" Then
	gf_mensaje("of_GetItem", "¡ La Columna ["+as_column + "] No Extiste (row = "+string(al_row)+") !") 
	Return ""
END IF

ls_tipo = Mid(ls_tipo,1,5)

CHOOSE CASE ls_tipo
	CASE "char(","char","varch"
		la_value = trim(this.GetItemString(al_row, as_column))
	CASE 	"decim"
		la_value = this.GetItemDecimal(al_row, as_column)
	CASE "numbe","long","small","float"
		la_value = this.GetItemNumber(al_row, as_column)
	CASE "date"
		la_value = this.GetItemDate(al_row, as_column)
	CASE "datet"
		la_value = this.GetItemDateTime(al_row, as_column)
	Case Else
		IF IsNull(ls_tipo) then ls_tipo = "[NULL]"
		gf_mensaje("of_GetItem", "¡ En la columna "+ as_column + " El tipo "+ls_tipo + " No esta contemplado (row = "+string(al_row)+") !" )
END CHOOSE

Return la_value
end function

public function string of_getitemstring (long al_row, string as_column);
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
//10-09-2026: u_dw.sru · of_getitemstring
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
//Esta función siempre devuelve un string sea el tipo de dato que sea la columna.

String ls_valor
Any la_value

la_value=of_GetItem(al_row, as_column)

ls_valor=string(la_value)

if isnull(ls_valor) then ls_valor = ""

return trim(ls_valor)
end function

public function boolean of_print ();
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
//10-09-2026: u_dw.sru · of_print
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String ls_pdf
Integer li_visor, li_visores

If RowCount() = 0 Then Return False

li_visores = UpperBound(gw_visor[])

For li_visor = 1 to li_visores
	If Not isvalid(gw_visor[li_visor]) Then
		exit
	End If
Next

If li_visor =0 Then	li_visor = 1

ls_pdf = gs_dir + "\preview_"+string(li_visor)+".pdf"

If  SaveAs(ls_pdf, PDF!, false) <> 1 Then
	gf_mensaje("Error","¡ Error generando impreso !")
	Return False
End IF

OpenSheetWithParm(gw_visor[li_visor], ls_pdf, w_frame, 0, Original!)
Return True
end function

on u_dw.create
end on

on u_dw.destroy
end on

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
//10-09-2026: u_dw.sru · getfocus
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
dw_has_focus = true
end event

event losefocus;
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
//10-09-2026: u_dw.sru · losefocus
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
dw_has_focus = false
this.event  post ue_aceptar_texto( )
end event

event itemerror;
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
//10-09-2026: u_dw.sru · itemerror
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
//Return Values
//------------------------------------------------------------------------------
//Set the return code to affect the outcome of the event:
//0 (Default) Reject the data value and show an error message box
//1 Reject the data value with no message box
//2 Accept the data value
//3 Reject the data value but allow focus to change
//-------------------------------------------------------------------------------

string ls_colname, ls_datatype

ls_colname = dwo.Name
ls_datatype = dwo.ColType

messagebox("Atención", "En la columna "+ls_colname+char(13)+" el tipo de dato esperado es "+ls_datatype+"."+char(13)+char(13)+"¡ Introduzca un Valor correcto !", exclamation!)

// Set value to null if blank
CHOOSE CASE LEFT(ls_datatype, 5)
		CASE  "Char"
		string null_string
		SetNull(null_string)
		This.SetItem(row, ls_colname, null_string)
			
		CASE "date "
		date null_date
		SetNull(null_date)
		This.SetItem(row, ls_colname, null_date)
			
		CASE "datet"
		datetime null_datetime
		SetNull(null_datetime)
		This.SetItem(row, ls_colname, null_datetime)
			
		CASE  "decim"
		dec null_decimal
		SetNull(null_decimal)
		This.SetItem(row, ls_colname, null_decimal)
				
		CASE  "numbe", "long"
		integer null_integer
		SetNull(null_integer)
		This.SetItem(row, ls_colname, null_integer)
	
		case "time "
		time null_time
		SetNull(null_time)
		This.SetItem(row, ls_colname, null_time)
					// Additional cases for other datatypes
		//Real
		//Timestamp
		//ULong
		//	INT
END CHOOSE
	RETURN 1
end event

event dbError;
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
//10-09-2026: u_dw.sru · dbError
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
messagebox("Error SQL "+string(sqldbcode), sqlerrtext , exclamation!)
return 1
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
//10-09-2026: u_dw.sru · constructor
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
int li_start_pos = 1
int li_tab_pos
string ls_obj_list
string ls_obj_name
String ls_tag
boolean lb_is_field
String ls_themename, ls_color_cabecera, ls_color_texto_cabecera
Long ll_width,ll_header_height	
string ls_text 
Integer li_x_pos
String ls_modify
String ls_cebra
String  ls_processing

If DataObject = "" Then Return
ls_processing = Describe("DataWindow.Processing")

ls_themename = GetTheme()

//Parametrización de Colores
Choose Case ls_themename
	Case "Flat Design Blue"	
		ls_color_cabecera= string(16744448)
		ls_color_texto_cabecera= string(16777215)
		ls_cebra = "1073741824~tif(Mod(GetRow(), 2) = 0, RGB(220, 220, 220), RGB(255, 255, 255))"
	Case "Flat Design Grey"
		ls_color_cabecera= string(8421504)
		ls_color_texto_cabecera= string(16777215)
		ls_cebra = "1073741824~tif(Mod(GetRow(), 2) = 0, RGB(220, 220, 220), RGB(255, 255, 255))"
	Case "Flat Design Silver"
		ls_color_cabecera= string(9204580)
		ls_color_texto_cabecera= string(16777215)
		ls_cebra = "1073741824~tif(Mod(GetRow(), 2) = 0, RGB(220, 220, 220), RGB(255, 255, 255))"
	Case "Flat Design Dark"
		ls_color_cabecera= string(5131854)
		ls_color_texto_cabecera= string(12632256)
		ls_cebra = "1073741824~tif(Mod(GetRow(), 2) = 0, RGB(50, 50, 50), RGB(0, 0, 0))"
	Case "Flat Design Lime"
		ls_color_cabecera= string(6077026)
		ls_color_texto_cabecera= string(16777215)
		ls_cebra = "1073741824~tif(Mod(GetRow(), 2) = 0, RGB(220, 220, 220), RGB(255, 255, 255))"
	Case "Flat Design Orange"	
		ls_color_cabecera= string(3706358)
		ls_color_texto_cabecera= string(16777215)
		ls_cebra = "1073741824~tif(Mod(GetRow(), 2) = 0, RGB(220, 220, 220), RGB(255, 255, 255))"
	Case Else
		ls_color_cabecera= string(16744448)
		ls_color_texto_cabecera= string(16777215)
		ls_cebra = "1073741824~tif(Mod(GetRow(), 2) = 0, RGB(220, 220, 220), RGB(255, 255, 255))"
End Choose


// Efecto cebra
//Object.DataWindow.Detail.Color = ls_cebra


// Transparencia
ls_obj_list = Describe("DataWindow.Objects")
li_tab_pos = Pos(ls_obj_list, "~t", li_start_pos)

Do While li_tab_pos > 0
   ls_obj_name = Mid(ls_obj_list, li_start_pos, (li_tab_pos - li_start_pos))
	
   // Si es un compute
   lb_is_field = (Describe(ls_obj_name + ".DBName") <> "!" Or Describe(ls_obj_name + ".Type") = "compute")
	
   If lb_is_field Then
      Modify(ls_obj_name + ".Background.Mode='1'") // transparente
   End If
   
	 If Describe(ls_obj_name+".band") = "header" Then
		//Si Es Un Grid Podrá Ordenarse le Ponemos el Cursor Mano
		If  ls_processing  = "1" Then
			Modify (ls_obj_name + ".Pointer = 'HyperLink!'")			
		End If
	End If	

	//Modify(ls_obj_name + ".font.height= '-12' ") // transparente	
   li_start_pos = li_tab_pos + 1
   li_tab_pos = Pos(ls_obj_list, "~t", li_start_pos)		
Loop

If  ls_processing  = "1" Then
	Modify("DataWindow.Grid.ColumnMove=No")
	Modify("DataWindow.Row.Resize=No")
	Modify("DataWindow.Selected.Mouse = No")
End If

If ib_logo Then
	Modify("datawindow.brushmode=6") 
	Modify("datawindow.picture.transparency=90") 
	Object.datawindow.picture.File= gs_dir + "\imagenes\logo_dw.png"
	Modify("DataWindow.Color= 553648127")
End If	


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
//10-09-2026: u_dw.sru · clicked
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String ls_old_sort, ls_column
Char lc_sort

//Si es Grid
IF DataObject <> "" Then
	If  Describe("DataWindow.Processing")  = '1' Then
	
	/* Checa cuando el usuario hace click en la cabecera */
	IF Right(dwo.name,2) = '_t' THEN
		ls_column = LEFT(dwo.name, LEN(String(dwo.name)) - 2)
		/* Guarda la última ordenación, si hubiera alguna*/
		ls_old_sort = Describe("Datawindow.Table.sort")
		/* Checa cuando préviamente se ordenó una columna y en la que se hace click actualmente es la misma o no. Si es la misma, entonces se checa el orden del ordenamiento anterior (A - Ascendente, D - Descendente) y lo cambia. Si las columnas odenadas no son las mismas, las ordena en orden ascendente. */
		IF ls_column = LEFT(ls_old_sort, LEN(ls_old_sort) - 2) THEN
			lc_sort = RIGHT(ls_old_sort, 1)
			IF lc_sort = 'A' THEN
				lc_sort = 'D'
			ELSE
				lc_sort = 'A'
			END IF
			SetSort(ls_column+" "+lc_sort)
		ELSE
			SetSort(ls_column+" A")
		END IF
			Sort()
	END IF
	End If
End If

end event

