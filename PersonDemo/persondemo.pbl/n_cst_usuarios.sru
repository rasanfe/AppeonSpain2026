//objectcomments La tabla de usuarios del ERP (Database/usuarios.json) y su equivalencia con la app movil
forward
global type n_cst_usuarios from nonvisualobject
end type
end forward

global type n_cst_usuarios from nonvisualobject autoinstantiate
end type

type variables
/*
	Los usuarios del ERP NO son los de la app movil: cada uno tiene su
	usuario y su clave, y ademas el usuario y el PIN con los que entra en
	la web de fichar. Esa equivalencia es la que usa w_fichar_html para que
	PowerBuilder abra la web sin pedir nada.

	Las dos claves se guardan cifradas (n_cst_cifrado). La tabla se lee del
	disco en cada llamada: es pequeña y asi el mantenimiento manda al momento.
*/
n_cst_cifrado inv_cifrado
end variables

forward prototypes
public function boolean of_validar (string as_usuario, string as_password)
public function boolean of_equivalencia (string as_usuario, ref string as_usuario_movil, ref string as_pin_movil)
private function long of_buscar (nvo_ds_json ads_usuarios, string as_usuario)
private function boolean of_cargar (ref nvo_ds_json ads_usuarios)
end prototypes

public function boolean of_validar (string as_usuario, string as_password);
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
//17-10-2026: n_cst_usuarios.sru · of_validar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Login del ERP: el usuario existe y su clave, descifrada, es la tecleada.
	El usuario no distingue mayusculas; la clave si.
*/
nvo_ds_json lds_usuarios
Long ll_fila
Boolean lb_ok = False

IF Trim(as_usuario) = "" OR as_password = "" THEN Return False
IF NOT of_cargar(lds_usuarios) THEN Return False

ll_fila = of_buscar(lds_usuarios, as_usuario)
IF ll_fila > 0 THEN
	lb_ok = (inv_cifrado.of_descifrar(lds_usuarios.GetItemString(ll_fila, "password")) = as_password)
END IF

DESTROY lds_usuarios
Return lb_ok
end function

public function boolean of_equivalencia (string as_usuario, ref string as_usuario_movil, ref string as_pin_movil);
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
//17-10-2026: n_cst_usuarios.sru · of_equivalencia
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	Con que usuario y PIN entra en la app movil un usuario del ERP.
	False si el usuario no existe o no tiene usuario movil asignado.
*/
nvo_ds_json lds_usuarios
Long ll_fila

as_usuario_movil = ""
as_pin_movil = ""

IF NOT of_cargar(lds_usuarios) THEN Return False

ll_fila = of_buscar(lds_usuarios, as_usuario)
IF ll_fila > 0 THEN
	as_usuario_movil = Trim(lds_usuarios.GetItemString(ll_fila, "usuario_movil"))
	as_pin_movil = inv_cifrado.of_descifrar(lds_usuarios.GetItemString(ll_fila, "pin_movil"))
END IF

DESTROY lds_usuarios

IF IsNull(as_usuario_movil) THEN as_usuario_movil = ""
Return (as_usuario_movil <> "" AND as_pin_movil <> "")
end function

private function long of_buscar (nvo_ds_json ads_usuarios, string as_usuario);
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
//17-10-2026: n_cst_usuarios.sru · of_buscar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	La fila de ese usuario, sin mirar mayusculas ni espacios. 0 si no esta.
	Se recorre a mano: Find() no casa con columnas char rellenas de espacios.
*/
Long ll_i

FOR ll_i = 1 TO ads_usuarios.RowCount()
	IF Upper(Trim(ads_usuarios.GetItemString(ll_i, "usuario"))) = Upper(Trim(as_usuario)) THEN
		Return ll_i
	END IF
NEXT

Return 0
end function

private function boolean of_cargar (ref nvo_ds_json ads_usuarios);
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
//17-10-2026: n_cst_usuarios.sru · of_cargar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	La tabla entera, recien leida del fichero. Quien llama la destruye.
*/
ads_usuarios = CREATE nvo_ds_json

IF ads_usuarios.of_cargar_fichero(gs_fichero_usuarios) < 1 THEN
	DESTROY ads_usuarios
	gf_mensaje("Usuarios", "No se ha podido leer la tabla de usuarios:~r~n" + gs_fichero_usuarios)
	Return False
END IF

Return True
end function

on n_cst_usuarios.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_usuarios.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on
