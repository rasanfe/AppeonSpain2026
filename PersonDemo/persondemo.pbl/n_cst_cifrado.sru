//objectcomments Cifrado AES de las claves de la tabla de usuarios (demo)
forward
global type n_cst_cifrado from nonvisualobject
end type
end forward

global type n_cst_cifrado from nonvisualobject autoinstantiate
end type

type variables
/*
	Clave y vector de la DEMO, publicos a proposito: el fichero de usuarios
	viaja cifrado en el repositorio y quien lo clone tiene que poder leerlo.
	Viven SOLO aqui. En una aplicacion de verdad no estarian en el codigo.

	16 caracteres = AES-128. CrypterObject saca el tamaño de la clave del
	largo del blob.
*/
Private Constant String is_clave  = "AppeonSpain2026!"
Private Constant String is_vector = "Barcelona-27-10!"
Private Constant Encoding ie_encoding = EncodingUTF8!
end variables

forward prototypes
public function string of_cifrar (string as_texto)
public function string of_descifrar (string as_cifrado)
end prototypes

public function string of_cifrar (string as_texto);
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
//17-10-2026: n_cst_cifrado.sru · of_cifrar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	AES-CBC con relleno PKCS, con el CrypterObject de PowerBuilder, igual que
	el login del ejemplo PersonDemo. El resultado va en HEXADECIMAL y no en
	Base64: solo lleva 0-9 y A-F, asi que nvo_ds_json no lo confunde con una
	fecha (Base64 trae '/' y '-') al montar las columnas del JSON.
*/
Blob lblb_cifrado
CrypterObject lnv_crypter
CoderObject lnv_coder
String ls_resultado

IF IsNull(as_texto) OR as_texto = "" THEN Return ""

lnv_crypter = CREATE CrypterObject
lblb_cifrado = lnv_crypter.SymmetricEncrypt(AES!, Blob(as_texto, ie_encoding), &
	Blob(is_clave, ie_encoding), OperationModeCBC!, Blob(is_vector, ie_encoding), PKCSPadding!)
DESTROY lnv_crypter

lnv_coder = CREATE CoderObject
ls_resultado = lnv_coder.HexEncode(lblb_cifrado)
DESTROY lnv_coder

Return Upper(ls_resultado)
end function

public function string of_descifrar (string as_cifrado);
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
//17-10-2026: n_cst_cifrado.sru · of_descifrar
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»
/*
	La vuelta de of_cifrar(). Si el texto no es un cifrado valido, devuelve
	cadena vacia (y la clave no casara con nada).
*/
Blob lblb_datos, lblb_claro
CrypterObject lnv_crypter
CoderObject lnv_coder

IF IsNull(as_cifrado) OR Trim(as_cifrado) = "" THEN Return ""

lnv_coder = CREATE CoderObject
lblb_datos = lnv_coder.HexDecode(Trim(as_cifrado))
DESTROY lnv_coder

IF Len(lblb_datos) = 0 THEN Return ""

lnv_crypter = CREATE CrypterObject
lblb_claro = lnv_crypter.SymmetricDecrypt(AES!, lblb_datos, &
	Blob(is_clave, ie_encoding), OperationModeCBC!, Blob(is_vector, ie_encoding), PKCSPadding!)
DESTROY lnv_crypter

Return String(lblb_claro, ie_encoding)
end function

on n_cst_cifrado.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_cifrado.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on
