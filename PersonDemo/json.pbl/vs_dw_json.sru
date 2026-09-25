forward
global type vs_dw_json from u_dw
end type
end forward

global type vs_dw_json from u_dw
integer width = 686
integer height = 400
string title = "none"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type
global vs_dw_json vs_dw_json

type variables
/*
	Encoding con el que se GRABAN los ficheros JSON.

	Por defecto UTF-8, que es como esta el fichero de la aplicacion y lo que
	espera todo el mundo. Se deja como variable publica porque SaveToFile,
	si no se le dice nada, escribe en UTF-16LE: mas vale tenerlo a la vista
	y poder cambiarlo desde fuera que enterrado en una llamada.
*/
public Encoding ie_encoding = EncodingUTF8!

/* Motivo del ultimo fallo al cargar o grabar. */
public String is_ultimo_error
end variables


forward prototypes
public function long of_cargar_fichero (string as_fichero)
public function boolean of_guardar_fichero (string as_fichero)
public function long of_cargar_json (string as_json)
public function long of_insertar ()
public function boolean of_borrar (long al_fila)
private subroutine of_format ()
end prototypes

public function long of_cargar_fichero (string as_fichero);
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
//10-09-2026: vs_dw_json.sru · of_cargar_fichero
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Carga el DataWindow desde un fichero JSON.

	Mismo juego de funciones que nvo_ds_json, para que dé igual estar
	trabajando con un DataWindow o con un DataStore.
*/
String ls_json

IF Trim(as_fichero) = "" THEN Return -1
IF NOT FileExists(as_fichero) THEN Return -1

ls_json = gf_get_jsondata_from_file(as_fichero)
IF Trim(ls_json) = "" THEN Return -1

Return This.of_cargar_json(ls_json)
end function

public function boolean of_guardar_fichero (string as_fichero);
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
//10-09-2026: vs_dw_json.sru · of_guardar_fichero
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Graba el contenido del DataWindow en un fichero JSON, con las clases JSON
	de PowerBuilder (JsonPackage): LoadString con lo que exporta el
	DataWindow y SaveToFile para escribirlo.

	NADA de FileOpen/FileWrite: FileWrite corta a 32.765 caracteres y un
	JSON de 130 KB se quedaba a medias, dejando de ser valido.

	Si algo falla, el motivo queda en is_ultimo_error para que quien llame
	pueda decir QUE ha pasado, en vez de un "no se ha podido grabar".
*/
String ls_json, ls_comprobar
JsonGenerator lnv_json
Integer li_rc
Long ll_rc

is_ultimo_error = ""

IF Trim(as_fichero) = "" THEN
	is_ultimo_error = "No se ha indicado el fichero."
	Return False
END IF
This.AcceptText()

IF This.RowCount() < 1 THEN
	is_ultimo_error = "No hay filas que grabar."
	Return False
END IF

ls_json = This.ExportJson(False)
IF Trim(ls_json) = "" THEN
	is_ultimo_error = "ExportJson no ha devuelto nada."
	Return False
END IF

// JsonGENERATOR, no JsonPackage: JsonPackage exige que la raiz del JSON
// sea un objeto {...} y el fichero de facturas es un array [...]
// ("Failed to load the JSON data because its root node is not an object").
// JsonGenerator es ademas el que usa gf_get_jsondata_from_file para LEERLO.
lnv_json = CREATE JsonGenerator

// ImportString devuelve un Long (el item raiz): <= 0 es que ha fallado
ll_rc = lnv_json.ImportString(ls_json)
IF ll_rc <= 0 THEN is_ultimo_error = "ImportString ha devuelto " + String(ll_rc)

IF Trim(is_ultimo_error) = "" THEN
	// El encoding es una propiedad del objeto (ie_encoding): SaveToFile
	// escribiria en UTF-16LE si no se le dijera nada.
	li_rc = lnv_json.SaveToFile(as_fichero, ie_encoding)
	IF li_rc <> 1 THEN is_ultimo_error = "SaveToFile ha devuelto " + String(li_rc)
END IF

DESTROY lnv_json

IF Trim(is_ultimo_error) <> "" THEN Return False

ls_comprobar = gf_get_jsondata_from_file(as_fichero)
IF Left(Trim(ls_comprobar), 1) <> "[" OR Right(Trim(ls_comprobar), 1) <> "]" THEN
	is_ultimo_error = "El fichero ha quedado incompleto (" + &
		String(Len(ls_comprobar)) + " caracteres)."
	Return False
END IF

Return True
end function

public function long of_insertar ();
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
//10-09-2026: vs_dw_json.sru · of_insertar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Alta: una fila nueva al final, y se deja a la vista.
*/
Long ll_fila

/*
	OJO: aqui NO vale comprobar DataObject. Estos objetos montan su
	DataWindow AL VUELO desde el JSON (Create con la sintaxis generada),
	asi que DataObject esta VACIO aunque el objeto sea perfectamente
	valido. Se mira si tiene columnas, que es lo que importa.
*/
IF Integer(This.Describe("DataWindow.Column.Count")) < 1 THEN Return -1

ll_fila = This.InsertRow(0)
IF ll_fila < 1 THEN Return -1

This.ScrollToRow(ll_fila)
This.SetFocus()

Return ll_fila
end function

public function boolean of_borrar (long al_fila);
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
//10-09-2026: vs_dw_json.sru · of_borrar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Baja: quita una fila. No graba: eso es of_guardar_fichero().
*/
IF al_fila < 1 OR al_fila > This.RowCount() THEN Return False

Return (This.DeleteRow(al_fila) = 1)
end function

public function long of_cargar_json (string as_json);
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
//10-09-2026: vs_dw_json.sru · of_cargar_json
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
nvo_ds_json ds_data
Blob lblb_data
Long ll_rv, ll_RowCount

This.Reset()
This.Dataobject=""

ds_data = Create nvo_ds_json

ll_RowCount = ds_data.of_cargar_json(as_json)

If ll_RowCount < 0 Then Return -1


ll_rv = ds_data.GetFullState(lblb_data)
			
IF ll_rv = -1 THEN
	gf_mensaje("Error", "¡ GetFullState failed !")
	Return -1
END IF
			
ll_rv = This.SetFullState(lblb_data)
			
IF ll_rv = -1 THEN
	gf_mensaje("Error", "¡ SetFullState failed !")
	Return -1
END IF

Destroy ds_data

//Formateamos el Datawindow
of_format()

Return ll_RowCount


end function

private subroutine of_format ();
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
//10-09-2026: vs_dw_json.sru · of_format
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
int li_start_pos = 1
int li_tab_pos
string ls_obj_list, ls_obj_name

This.Object.DataWindow.Detail.Color = "1073741824~tif(Mod(GetRow(), 2) = 0, RGB(220, 220, 220), RGB(255, 255, 255))"

ls_obj_list = This.Describe("DataWindow.Objects")
li_tab_pos = Pos(ls_obj_list, "~t", li_start_pos)

Do While li_tab_pos > 0
   ls_obj_name = Mid(ls_obj_list, li_start_pos, (li_tab_pos - li_start_pos))
	  
	 If This.Describe(ls_obj_name+".band") = "header" Then
		Modify("Datawindow.Header.Height=80")
		Modify("Datawindow.Header.Color='16367753'" ) 
		Modify (ls_obj_name + ".color= '0'" ) 
		Modify (ls_obj_name + ".Font.face='Arial'") 
		Modify (ls_obj_name + ".Font.height='-8'") 
		Modify (ls_obj_name + ".y='4'") 
		Modify (ls_obj_name + ".height='60'")				
	End If	

   li_start_pos = li_tab_pos + 1
   li_tab_pos = Pos(ls_obj_list, "~t", li_start_pos)		
Loop
end subroutine

on vs_dw_json.create
end on

on vs_dw_json.destroy
end on

