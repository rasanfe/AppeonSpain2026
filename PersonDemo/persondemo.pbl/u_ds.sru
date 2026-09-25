forward
global type u_ds from datastore
end type
end forward

global type u_ds from datastore
end type
global u_ds u_ds

forward prototypes
public function any of_getitem (long al_row, string as_column)
public function string of_getitemstring (long al_row, string as_column)
public function boolean of_print ()
end prototypes

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
//10-09-2026: u_ds.sru · of_getitem
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
//10-09-2026: u_ds.sru · of_getitemstring
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
//10-09-2026: u_ds.sru · of_print
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

on u_ds.create
call super::create
TriggerEvent( this, "constructor" )
end on

on u_ds.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

