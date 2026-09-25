forward
global type nvo_ds_json from u_ds
end type
end forward

global type nvo_ds_json from u_ds
end type
global nvo_ds_json nvo_ds_json

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
private function string of_create_syntax (string as_column[], string as_types[], string as_longitud[])
private function long of_get_json_schema (string as_json, ref string as_columns[], ref string as_types[], ref string as_lens[])
private function long of_importjson (string as_json)
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
//10-09-2026: nvo_ds_json.sru · of_cargar_fichero
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Carga el datastore desde un fichero JSON.

	Es el companero de of_guardar_fichero(): quien usa este objeto no tiene
	que saber como se lee ni como se escribe un JSON, solo cargar y guardar.

	Devuelve el numero de filas, o -1 si algo fue mal.
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
//10-09-2026: nvo_ds_json.sru · of_guardar_fichero
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Graba el contenido del datastore en un fichero JSON, con las clases JSON
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
//10-09-2026: nvo_ds_json.sru · of_insertar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Alta: una fila nueva al final. Devuelve el numero de fila, o -1.
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
//10-09-2026: nvo_ds_json.sru · of_borrar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Baja: quita una fila del datastore. No graba: eso es of_guardar_fichero().
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
//10-09-2026: nvo_ds_json.sru · of_cargar_json
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String ls_columns[], ls_types[], ls_lens[]
Long ll_columnas, ll_RowCount
String ls_DwSyntax
Integer li_rtn

//Obtenemos el Esquema del Json
ll_columnas = of_get_json_schema(as_json, ref ls_columns[], ref ls_types[], ref ls_lens[])

If ll_Columnas = 0 Then
	gf_mensaje("Error", "¡ No se ha Detectado Ninguna columna del Json !")
	Return -1
End IF

ls_DwSyntax = of_create_syntax(ls_columns[], ls_types[], ls_lens[])

If ls_DwSyntax = "" Then
	gf_mensaje("Error", "¡ Error Generando Syntaxy del Datastore !")
	Return -1
End IF

// Asigna la sintaxis al DataWindow
li_rtn =This.Create(ls_dwSyntax)

If li_rtn <> 1 Then
	gf_mensaje("Error", "¡ Error Asignando Syntaxy del Datastore !")
	Return -1
End IF

//Importamos Json
ll_RowCount = This.of_ImportJson(as_json)

If ll_RowCount < 0 Then
	gf_mensaje("ImportJson", "¡ Error Importando Datos !")
End If	

Return ll_RowCount
end function

private function string of_create_syntax (string as_column[], string as_types[], string as_longitud[]);
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
//10-09-2026: nvo_ds_json.sru · of_create_syntax
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
// Crea un objeto de tipo DataWindow externo
DataWindowChild ldwc
string ls_dwSyntax
Long ll_TotalColumnas
Integer li_col, li_rc
String ls_columnName, ls_columnType, ls_columnLength

ll_TotalColumnas = UpperBound(as_column)

// Inicializa el DataWindow dinámico como un DataWindow externo
ls_dwSyntax = "release 22;"+char(13)+&
"datawindow(units=0 data.export.format=1 timer_interval=0 color=1073741824 brushmode=0 transparency=0 gradient.angle=0 gradient.color=8421504 gradient.focus=0 gradient.repetition.count=0 gradient.repetition.length=100"+&
" gradient.repetition.mode=0 gradient.scale=100 gradient.spread=100 gradient.transparency=0 picture.blur=0 picture.clip.bottom=0 picture.clip.left=0 picture.clip.right=0 picture.clip.top=0 picture.mode=0 picture.scale.x=100"+&
" picture.scale.y=100 picture.transparency=0 processing=1 HTMLDW=no print.printername='' print.documentname='' print.orientation = 0 print.margin.left = 110 print.margin.right = 110 print.margin.top = 96 print.margin.bottom = 96"+&
" print.paper.source = 0 print.paper.size = 0 print.canusedefaultprinter=yes print.prompt=no print.buttons=no print.preview.buttons=no print.cliptext=no print.overrideprintjob=no print.collate=yes print.background=no"+&
" print.preview.background=no print.preview.outline=yes hidegrayline=no showbackcoloronxp=no picture.file='' grid.lines=0 )"+char(13)+&
"header(height=80 color='536870912' transparency='0' gradient.color='8421504' gradient.transparency='0' gradient.angle='0' brushmode='0' gradient.repetition.mode='0' gradient.repetition.count='0' gradient.repetition.length='100'"+&
" gradient.focus='0' gradient.scale='100' gradient.spread='100' )"+char(13)+&
"summary(height=0 color='536870912' transparency='0' gradient.color='8421504' gradient.transparency='0' gradient.angle='0' brushmode='0' gradient.repetition.mode='0' gradient.repetition.count='0' gradient.repetition.length='100'"+&
" gradient.focus='0' gradient.scale='100' gradient.spread='100' )"+char(13)+&
"footer(height=0 color='536870912' transparency='0' gradient.color='8421504' gradient.transparency='0' gradient.angle='0' brushmode='0' gradient.repetition.mode='0' gradient.repetition.count='0' gradient.repetition.length='100'"+&
" gradient.focus='0' gradient.scale='100' gradient.spread='100' )"+char(13)+&
"detail(height=92 color='536870912' transparency='0' gradient.color='8421504' gradient.transparency='0' gradient.angle='0' brushmode='0' gradient.repetition.mode='0' gradient.repetition.count='0' gradient.repetition.length='100'"+&
" gradient.focus='0' gradient.scale='100' gradient.spread='100' )"+char(13)+&
"table("

// Ajuste de posición inicial
integer li_x_position
integer li_column_width = 485
integer li_column_height = 72
string ls_format, ls_alignment


// Recorre el array deserializado y construye las columnas del DataWindow
FOR li_col = 1 TO ll_TotalColumnas
    ls_columnName = as_column[li_col]
    ls_columnType = Lower(as_types[li_col]) // Asegurar que el tipo esté en minúsculas
    ls_columnLength = as_longitud[li_col]

    // Validar longitud, si es vacío o nulo, asignar un valor por defecto (p.ej., 50)
    IF IsNull(ls_columnLength) OR ls_columnLength = "" THEN
        ls_columnLength = "50"
    END IF

    // Determina el tipo de dato de PowerBuilder
    CHOOSE CASE ls_columnType
        CASE "integer", "byte", "number"
         	   ls_dwSyntax += "column=(type=number updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 
		CASE "long"
			 ls_dwSyntax += "column=(type=long updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 	
        CASE "char", "string"
			 ls_dwSyntax += "column=(type=char("+ls_columnLength+") updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 
		CASE "date"
			ls_dwSyntax += "column=(type=date updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 
		CASE "datetime"
             ls_dwSyntax += "column=(type=datetime updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 
		CASE "time" 
			  ls_dwSyntax += "column=(type=time updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 
        CASE "decimal"
			 if ls_columnLength = "Null" then ls_columnLength = "2"
           	 ls_dwSyntax += "column=(type=Decimal("+ls_columnLength+") updatewhereclause=yes name="+ls_columnName+" dbname='"+ls_columnName+"' )"+char(13) 
          CASE ELSE
            gf_mensaje("Error", "Tipo de dato desconocido: " + ls_columnType)
            RETURN ""
    END CHOOSE

NEXT

ls_dwSyntax += ")"+char(13) 

//COLUMNAS
li_x_position = 5  // Coordenada inicial de la primera fila
// Recorre el array deserializado y construye las columnas del DataWindow
FOR li_col = 1 TO ll_TotalColumnas
    ls_columnName = as_column[li_col]
	ls_columnLength = as_longitud[li_col]
	ls_columnType = Lower(as_types[li_col]) // Asegurar que el tipo esté en minúsculas

    // Validar longitud, si es vacío o nulo, asignar un valor por defecto (p.ej., 50)
    IF IsNull(ls_columnLength) OR ls_columnLength = "" THEN
        ls_columnLength = "50"
    END IF
	 
	 CHOOSE CASE ls_columnType
		CASE  "decimal"
			 li_column_width = 485
			 ls_format="###,###,###,##0.00"
			 ls_alignment="1"
		CASE "integer", "byte", "long"
			 li_column_width = 485
			ls_format="[general]"
      		 ls_alignment="1"
		CASE "char", "string"
			 li_column_width = 485
			//li_column_width= integer(ls_columnLength) * 30
			//if 	li_column_width > 1600 then li_column_width =1600
			ls_format="[general]"
			ls_alignment="0"
		CASE  "date",  "datetime"
			 li_column_width = 485
			 ls_format="dd-mm-yy"
			 ls_alignment="2"
		CASE  "time"
			 li_column_width = 485
			 ls_format="hh:mm:ss"
			 ls_alignment="2"	 
	END CHOOSE

     ls_dwSyntax += "column(band=detail id="+ String(li_col) +" alignment='"+ls_alignment+"' tabsequence="+ String(li_col * 10) +" border='0' color='0'  x='" + String(li_x_position) + "' y='4' height='" + String(li_column_height) + "' width='" + String(li_column_width) + "' format='"+ls_format+"' html.valueishtml='0'  name="+ls_columnName+" visible='1' edit.limit=0 edit.case=any edit.focusrectangle=no edit.autoselect=yes edit.autohscroll=yes  font.face='Tahoma' font.height='-10' font.weight='400'  font.family='2' font.pitch='2' font.charset='0' background.mode='1' background.color='536870912' background.transparency='0' background.gradient.color='8421504' background.gradient.transparency='0' background.gradient.angle='0' background.brushmode='0' background.gradient.repetition.mode='0' background.gradient.repetition.count='0' background.gradient.repetition.length='100' background.gradient.focus='0' background.gradient.scale='100' background.gradient.spread='100' tooltip.backcolor='134217752' tooltip.delay.initial='0' tooltip.delay.visible='32000' tooltip.enabled='0' tooltip.hasclosebutton='0' tooltip.icon='0' tooltip.isbubble='0' tooltip.maxwidth='0' tooltip.textcolor='134217751' tooltip.transparency='0' transparency='0' )"+char(13)

    // Incrementa la posición X para la siguiente columna
    li_x_position += li_column_width  + 12
NEXT

//ETIQUETAS TEXTO:
li_x_position = 5  
FOR li_col = 1 TO ll_TotalColumnas
    ls_columnName = as_column[li_col]
	 
   	 ls_dwSyntax += "text(band=header alignment='2' text='"+ls_columnName+"' border='0' color='0' x='" + String(li_x_position) + "' y='4' height='" + String(li_column_height) + "' width='" + String(li_column_width) +"' html.valueishtml='0'  name="+ls_columnName+"_t visible='1'  font.face='Tahoma' font.height='-10' font.weight='400'  font.family='2' font.pitch='2' font.charset='0' background.mode='1' background.color='536870912' background.transparency='0' background.gradient.color='8421504' background.gradient.transparency='0' background.gradient.angle='0' background.brushmode='0' background.gradient.repetition.mode='0' background.gradient.repetition.count='0' background.gradient.repetition.length='100' background.gradient.focus='0' background.gradient.scale='100' background.gradient.spread='100' tooltip.backcolor='134217752' tooltip.delay.initial='0' tooltip.delay.visible='32000' tooltip.enabled='0' tooltip.hasclosebutton='0' tooltip.icon='0' tooltip.isbubble='0' tooltip.maxwidth='0' tooltip.textcolor='134217751' tooltip.transparency='0' transparency='0' )"+CHAR(13)

    // Incrementa la posición X para la siguiente columna
    li_x_position += li_column_width  + 12
NEXT

ls_dwSyntax +="htmltable(border='1' )"+char(13)+&
"htmlgen(clientevents='1' clientvalidation='1' clientcomputedfields='1' clientformatting='0' clientscriptable='0' generatejavascript='1' encodeselflinkargs='1' netscapelayers='0' pagingmethod=0 generatedddwframes='1' )"+char(13)+&
"xhtmlgen() cssgen(sessionspecific='0' )"+char(13)+&
"xmlgen(inline='0' )"+char(13)+&
"xsltgen()"+char(13)+&
"jsgen()"+char(13)+&
"export.xml(headgroups='1' includewhitespace='0' metadatatype=0 savemetadata=0 )"+char(13)+&
"import.xml()"+char(13)+&
"export.pdf(method=2 distill.custompostscript='0' nativepdf.customsize=0 nativepdf.customorientation=0 nativepdf.pdfstandard=0 nativepdf.useprintspec=no )"+char(13)+&
"export.xhtml()"

// Muestra la sintaxis generada para depurar
ls_dwSyntax  =gf_replaceall(ls_dwSyntax, "'", '"')


RETURN ls_dwSyntax
end function

private function long of_get_json_schema (string as_json, ref string as_columns[], ref string as_types[], ref string as_lens[]);
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
//10-09-2026: nvo_ds_json.sru · of_get_json_schema
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String ls_Json, ls_Type, ls_value, ls_key, ls_len, ls_StringValue
Long ll_ChildCount, ll_Index, ll_ArrayItem, ll_ObjectItem
JsonParser lnv_JsonParser
Long ll_columna
DateTime ldt_parse
Date lda_parse
Time lt_parse
Dec ld_parse
Long ll_parse
Long ll_Row, ll_RowCount
String ls_Error

//El Formato Esperado sera una Array de Josn, donde caja json sera cada fila

lnv_JsonParser = Create JsonParser

ls_json = as_json

// Loads a JSON string
ls_error = lnv_JsonParser.LoadString(ls_Json)

If Len(ls_Error) > 0 Then
	MessageBox("Error", ls_Error, Exclamation!)
	Return - 1
End If

ll_ArrayItem = lnv_JsonParser.GetRootItem() // Root item is JsonArrayItem!
ll_ChildCount = lnv_JsonParser.GetChildCount(ll_ArrayItem)

// Gets the array item in a loop
For ll_Index = 1 To ll_ChildCount
		
 // Gets the array item
 ll_ObjectItem = lnv_JsonParser.GetChildItem(ll_ArrayItem, ll_Index)
 
  If lnv_JsonParser.GetItemType(ll_ObjectItem) <>  JsonObjectItem! Then
	gf_mensaje("Json Schema", "¡ Formato Esperado es una Array de Json !")
	Return -1
  End If	
  

 // Obtiene la cantidad de hijos (pares clave-valor) del objeto JSON
  ll_RowCount = lnv_JsonParser.GetChildCount(ll_ObjectItem)
  
  For ll_Row = 1 To ll_RowCount
	ls_value=""
	ls_Type=""
	ls_len=""
	
	ls_key = lnv_JsonParser.GetChildKey(ll_ObjectItem, ll_Row)
 
	  If ll_columna > 1 Then
		If gf_iin(ls_key, as_columns[]) Then Continue
	 End if	
	 
	 ll_columna ++
	 as_columns[ll_columna] = ls_key
	 

	  Choose Case lnv_JsonParser.GetItemType(ll_ObjectItem, ls_key)
		  Case JsonStringItem!
			
			ls_StringValue =  lnv_JsonParser.GetItemString(ll_ObjectItem, ls_key)
			
			//Para Datetime Tiene que tener / o - y : para la hora
			If (pos(ls_StringValue, "-") > 0 Or  pos(ls_StringValue, "/")>0) And pos(ls_StringValue, ":") > 0 Then
				//Probamos si es Datetime
				ldt_parse =  lnv_JsonParser.GetItemDatetime(ll_ObjectItem, ls_key)
				
				If Not Isnull(ldt_parse) Then
					ls_Type = "datetime"
					ls_len=""			
				End if	
			End If
			
			//Para Date Tiene que tener / o - 
			If ls_Type = ""  and (pos(ls_StringValue, "-") > 0 Or  pos(ls_StringValue, "/")>0) Then 
				lda_parse =  lnv_JsonParser.GetItemDate(ll_ObjectItem, ls_key)
				
				If Not Isnull(lda_parse) and string(lda_parse, "yyyy-mm-dd") <> "1900-01-01"Then
					ls_Type ="date"
					ls_len=""	
				End if	
			End if
			
			//Para Time Tiene que tener : para la hora
			If ls_Type = "" and pos(ls_StringValue, ":") > 0 Then
				lt_parse =  lnv_JsonParser.GetItemtime(ll_ObjectItem, ls_key)
				
				If Not Isnull(lt_parse) and string(lt_parse, "hh:mm:ss.ffffff") <> "00:00:00.000000" Then
					ls_Type = "time"
					ls_len=""	
				End if	
			End if	
			
			//Si no es fecha o tiempo ponemos String
			If ls_Type = "" Then
				ls_Type = "string"
				ls_len="1033"
			End IF	
						

		  Case JsonNumberItem!
			  
			 ls_StringValue =  String(lnv_JsonParser.GetItemNumber(ll_ObjectItem, ls_key))
			
			//Para Decimal tendra que tener punto o coma
			If (pos(ls_StringValue, ".") > 0 Or  pos(ls_StringValue, ",")>0)	 Then
				ld_parse = 	lnv_JsonParser.GetItemDecimal(ll_ObjectItem, ls_key)
			 
				If Not Isnull(ld_parse) Then
					ls_value = string(ld_parse)
					ls_Type = "decimal"
					ls_len="4"	
				 End if	
			 End IF
			
			If ls_Type = "" Then
				  ll_parse = lnv_JsonParser.GetItemNumber(ll_ObjectItem, ls_key)
				  ls_value = string(ll_parse)
				  ls_Type = "number"
				  ls_len=""	
			End if
		  Case JsonBooleanItem!
				ls_value = string(lnv_JsonParser.GetItemBoolean(ll_ObjectItem, ls_key))
			  	ls_Type ="number"
				ls_len=""
			  If lnv_JsonParser.GetItemBoolean(ll_ObjectItem, ls_key) = True Then
					ls_value = "1"
			  Else
					ls_value = "0"
			  End if	
		  Case JsonNullItem!
				ls_value = ""
				ls_len="0"
				ls_Type ="string"
		Case JsonObjectItem!
			// Type of the JSON node whose key value pair is an object, such as "date_object":{"datetime":7234930293, "date": "2017-09-21", "time": "12:00:00"}.
			ls_value = lnv_JsonParser.GetItemObjectJSONString (ll_ObjectItem, ls_key)
			ls_len="32767"
			ls_Type = "string"	
		Case JsonArrayItem! 
			//Type of the JSON node whose key value pair is an array, such as "department_array":[999999, {"name":"Website"}, {"name":"PowerBuilder"}, {"name":"IT"}].
			ls_value = lnv_JsonParser.GetItemArrayJSONString(ll_ObjectItem, ls_key)
			ls_len="32767"
			ls_Type = "string"
	End Choose
	
		 as_types[ll_columna]=ls_Type
		 as_lens[ll_columna] = ls_len
	Next	 
Next

Return UpperBound(as_columns[])
end function

private function long of_importjson (string as_json);
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
//10-09-2026: nvo_ds_json.sru · of_importjson
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
String ls_Json, ls_Type, ls_value, ls_key, ls_len
Long ll_ChildCount, ll_Index, ll_ArrayItem, ll_ObjectItem
JsonParser lnv_JsonParser
DateTime ldt_parse
Date lda_parse
Time lt_parse
Dec ld_parse
Long ll_parse
Long ll_Row, ll_RowCount, ll_InsertRow

//El Formato Esperado sera una Array de Josn, donde caja json sera cada fila

lnv_JsonParser = Create JsonParser

ls_json = as_json

// Loads a JSON string
lnv_JsonParser.LoadString(ls_Json)
ll_ArrayItem = lnv_JsonParser.GetRootItem() // Root item is JsonArrayItem!
ll_ChildCount = lnv_JsonParser.GetChildCount(ll_ArrayItem)

// Gets the array item in a loop
For ll_Index = 1 To ll_ChildCount
	ll_InsertRow = this.InsertRow(0)
		
 // Gets the array item
 ll_ObjectItem = lnv_JsonParser.GetChildItem(ll_ArrayItem, ll_Index)
 
  If lnv_JsonParser.GetItemType(ll_ObjectItem) <>  JsonObjectItem! Then
	gf_mensaje("Json Schema", "¡ Formato Esperado es una Array de Json !")
	Return -1
  End If	
  

 // Obtiene la cantidad de hijos (pares clave-valor) del objeto JSON
  ll_RowCount = lnv_JsonParser.GetChildCount(ll_ObjectItem)
  
  For ll_Row = 1 To ll_RowCount
	ls_value=""
	ls_Type=""
	ls_len=""
	
	ls_key = lnv_JsonParser.GetChildKey(ll_ObjectItem, ll_Row)
 
		 
	  Choose Case lnv_JsonParser.GetItemType(ll_ObjectItem, ls_key)
		  Case JsonStringItem!
			 			
			//Probamos si es Datetime
			ldt_parse =  lnv_JsonParser.GetItemDatetime(ll_ObjectItem, ls_key)
			
			If Not Isnull(ldt_parse) Then
				ls_Type = "datetime"
				ls_len=""
				 this.SetItem(ll_InsertRow, ls_Key, ldt_parse)
			End if	
			
			//Probamos si es Date
			If ls_Type = "" Then
				lda_parse =  lnv_JsonParser.GetItemDate(ll_ObjectItem, ls_key)
				
				If Not Isnull(lda_parse) and string(lda_parse, "yyyy-mm-dd") <> "1900-01-01"Then
					ls_Type ="date"
					ls_len=""	
					 this.SetItem(ll_InsertRow, ls_Key, lda_parse)
				End if	
			End if
			
			//Probamos si es Time
			If ls_Type = "" Then
				lnv_JsonParser.GetItemtime(ll_ObjectItem, ls_key)
				
				If Not Isnull(lt_parse) and string(lt_parse, "hh:mm:ss.ffffff") <> "00:00:00.000000" Then
					ls_Type = "time"
					ls_len=""	
					 this.SetItem(ll_InsertRow, ls_Key, lt_parse)
				End if	
			End if	
			
			//Si no es fecha o tiempo ponemos String
			If ls_Type = "" Then
				ls_value = lnv_JsonParser.GetItemString(ll_ObjectItem, ls_key)
				ls_Type = "string"
				ls_len="1033"
				 this.SetItem(ll_InsertRow, ls_Key, ls_value)
			End IF	
		
		  Case JsonNumberItem!
				
			ld_parse = 	lnv_JsonParser.GetItemDecimal(ll_ObjectItem, ls_key)
			 
			If Not Isnull(ld_parse) Then
				ls_value = string(ld_parse)
				ls_Type = "decimal"
				ls_len="4"	
				 this.SetItem(ll_InsertRow, ls_Key, ld_parse)
			 End if	
			
			If ls_Type = "" Then
				  ll_parse = lnv_JsonParser.GetItemNumber(ll_ObjectItem, ls_key)
				  ls_value = string(ll_parse)
				  ls_Type = "number"
				  ls_len=""	
				  this.SetItem(ll_InsertRow, ls_Key, ll_parse)
			End if
		  Case JsonBooleanItem!
				  ls_value = string(lnv_JsonParser.GetItemBoolean(ll_ObjectItem, ls_key))
			  ls_Type ="number"
				ls_len=""
			  If lnv_JsonParser.GetItemBoolean(ll_ObjectItem, ls_key) = True Then
				ls_value = "1"
			  Else
				ls_value = "0"
			  End if	
			  this.SetItem(ll_InsertRow, ls_Key, ls_value)
		  Case JsonNullItem!
			ls_value = ""
			ls_len="0"
			ls_Type ="string"
			this.SetItem(ll_InsertRow, ls_Key, ls_value)
		Case JsonObjectItem!
			// Type of the JSON node whose key value pair is an object, such as "date_object":{"datetime":7234930293, "date": "2017-09-21", "time": "12:00:00"}.
			ls_value = lnv_JsonParser.GetItemObjectJSONString (ll_ObjectItem, ls_key)
			ls_len="32767"
			ls_Type = "string"	
			this.SetItem(ll_InsertRow, ls_Key, ls_value)
		Case JsonArrayItem! 
			//Type of the JSON node whose key value pair is an array, such as "department_array":[999999, {"name":"Website"}, {"name":"PowerBuilder"}, {"name":"IT"}].
			ls_value = lnv_JsonParser.GetItemArrayJSONString(ll_ObjectItem, ls_key)
			ls_len="32767"
			ls_Type = "string"
			this.SetItem(ll_InsertRow, ls_Key, ls_value)
	End Choose
	Next	 
Next

Return ll_InsertRow
end function

on nvo_ds_json.create
call super::create
end on

on nvo_ds_json.destroy
call super::destroy
end on

