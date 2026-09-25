//objectcomments Generated Application Object
forward
global type persondemo from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables
String gs_fichero_ini, gs_dir
Boolean gb_isPBIDE
w_visor gw_visor[]

end variables

global type persondemo from application
string appname = "persondemo"
boolean freedblibraries = true

string themepath = "theme"
string themename = "Do Not Use Themes"
boolean nativepdfvalid = true
boolean nativepdfincludecustomfont = true
string nativepdfappname = ""
long richtextedittype = 5
long richtexteditx64type = 5
long richtexteditversion = 3
string richtexteditkey = ""
string appicon = "imagenes\icono.ico"
string appruntimeversion = "25.1.0.6430"
boolean manualsession = false
boolean unsupportedapierror = false
boolean ultrafast = false
boolean bignoreservercertificate = false
uint ignoreservercertificate = 0
long webview2distribution = 0
boolean webview2checkx86 = false
boolean webview2checkx64 = false
string webview2url = "https://developer.microsoft.com/en-us/microsoft-edge/webview2/"
end type
global persondemo persondemo

type prototypes
// Funciones para Fecha de Ficheros
FUNCTION boolean FileTimeToLocalFileTime ( ref os_filedatetime lpFileTime, ref os_filedatetime lpLocalFileTime)  LIBRARY "KERNEL32.DLL" alias for "FileTimeToLocalFileTime"
FUNCTION boolean FileTimeToSystemTime  (ref os_filedatetime lpFileTime, ref os_systemdatetime lpSystemTime) LIBRARY "KERNEL32.DLL" alias for "FileTimeToSystemTime"
FUNCTION long FindFirstFile ( string filename, ref os_finddata findfiledata) LIBRARY "KERNEL32.DLL"  alias for "FindFirstFileW"
//Funcion para tomar el directorio de la aplicacion  -64Bits 
FUNCTION	uLong	GetModuleFileName ( uLong lhModule, ref string sFileName, ulong nSize )  LIBRARY "Kernel32.dll" ALIAS FOR "GetModuleFileNameW"
end prototypes

type variables

end variables

on persondemo.create
appname="persondemo"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on persondemo.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;String ls_Theme
Boolean lb_theme
String ls_Path
ulong lul_handle

ls_Path = space(1024)
SetNull(lul_handle)
GetModuleFilename(lul_handle, ls_Path, len(ls_Path))

if right(UPPER(ls_path), 7)="250.EXE" or right(UPPER(ls_path), 7)="X64.EXE" then
	gb_isPBIDE = TRUE
end if
	//Messagebox("Solution Mode", ls_path)

gs_dir = GetCurrentDirectory()
gs_fichero_ini = gs_dir+"\Setting.ini"

//Temas PowerBulder 2025
ls_theme=ProfileString(gs_fichero_ini, "Setup", "Theme", "")

IF ls_theme <> "Do Not Use Themes"  and ls_theme <> "" THEN
	lb_theme = gf_iin(ls_theme, {'Flat Design Blue','Flat Design Grey', 'Flat Design Silver', 'Flat Design Dark', 'Flat Design Lime', 'Flat Design Orange'}) 
	IF lb_theme THEN ApplyTheme(ls_theme)
END IF


Open(w_frame)
end event

