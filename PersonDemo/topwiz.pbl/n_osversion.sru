forward
global type n_osversion from nonvisualobject
end type
type osversioninfoex from structure within n_osversion
end type
type system_info from structure within n_osversion
end type
type langandcodepage from structure within n_osversion
end type
type vs_fixedfileinfo from structure within n_osversion
end type
end forward

type osversioninfoex from structure
	unsignedlong		dwosversioninfosize
	unsignedlong		dwmajorversion
	unsignedlong		dwminorversion
	unsignedlong		dwbuildnumber
	unsignedlong		dwplatformid
	character		szcsdversion[128]
	unsignedinteger		wservicepackmajor
	unsignedinteger		wservicepackminor
	unsignedinteger		wsuitemask
	byte		wproducttype
	byte		wreserved
end type

type system_info from structure
	unsignedinteger		wprocessorarchitecture
	unsignedinteger		wreserved
	unsignedlong		dwpagesize
	unsignedlong		lpminimumapplicationaddress
	unsignedlong		lpmaximumapplicationaddress
	unsignedlong		dwactiveprocessormask
	unsignedlong		dwnumberofprocessors
	unsignedlong		dwprocessortype
	unsignedlong		dwallocationgranularity
	unsignedinteger		wprocessorlevel
	unsignedinteger		wprocessorrevsion
end type

type langandcodepage from structure
	integer		wlanguageid
	integer		wcharacterset
end type

type vs_fixedfileinfo from structure
	unsignedlong		dwsignature
	unsignedlong		dwstrucversion
	unsignedlong		dwfileversionms
	unsignedlong		dwfileversionls
	unsignedlong		dwproductversionms
	unsignedlong		dwproductversionls
	unsignedlong		dwfileflagsmask
	unsignedlong		dwfileflags
	unsignedlong		dwfileos
	unsignedlong		dwfiletype
	unsignedlong		dwfilesubtype
	unsignedlong		dwfiledatems
	unsignedlong		dwfiledatels
end type

global type n_osversion from nonvisualobject autoinstantiate
end type

type prototypes
Function long GetSystemMetrics ( &
	long nIndex &
	) Library "user32.dll"

Function ulong RtlGetVersion ( &
	Ref OSVERSIONINFOEX lpVersionInformation &
	) Library "ntdll.dll"

Function boolean GetProductInfo ( &
	ulong dwOSMajorVersion, &
	ulong dwOSMinorVersion, &
	ulong dwSpMajorVersion, &
	ulong dwSpMinorVersion, &
	Ref ulong pdwReturnedProductType &
	) Library "kernel32.dll"

Subroutine GetNativeSystemInfo ( &
	Ref SYSTEM_INFO lpSystemInfo &
	) Library "kernel32.dll"

Subroutine GetSystemInfo ( &
	Ref SYSTEM_INFO lpSystemInfo &
	) Library "kernel32.dll"

Function boolean IsWow64Process ( &
	longptr hProcess, &
	Ref boolean Wow64Process &
	) Library "kernel32.dll"

Function longptr GetCurrentProcess ( &
	) Library "kernel32.dll"

Subroutine CopyMemory ( &
	Ref string Destination, &
	longptr Source, &
	long Length &
	) Library "kernel32.dll" Alias For "RtlMoveMemory"

Subroutine CopyMemory ( &
	Ref structure Destination, &
	longptr Source, &
	long Length &
	) Library 'kernel32.dll' Alias For "RtlMoveMemory"

Function long GetFileVersionInfoSize ( &
	string lptstrFilename, &
	Ref ulong lpdwHandle &
	) Library "version.dll" Alias For "GetFileVersionInfoSizeW"

Function boolean GetFileVersionInfo ( &
	string lptstrFilename, &
	ulong dwHandle, &
	ulong dwLen, &
	Ref blob lpData &
	) Library "version.dll" Alias For "GetFileVersionInfoW"

Function boolean VerQueryValue ( &
	Ref blob lpBlock, &
	string lpSubBlock, &
	Ref longptr lplpBuffer, &
	Ref ulong puLen &
	) Library "version.dll" Alias For "VerQueryValueW"

end prototypes

type variables
String Comments
String CompanyName
String FileDescription
String FileVersion
String FixedFileVersion
String FixedProductVersion
String InternalName
String LegalCopyright
String LegalTrademarks
String OriginalFilename
String PrivateBuild
String ProductName
String ProductVersion
String SpecialBuild

Uint BuildNumber
Uint ProductType
Uint MajorVersion
Uint MinorVersion
Uint ServicePackMajor
Uint ServicePackMinor
Uint SuiteMask

end variables

forward prototypes
public function string of_pbvmname ()
public function string of_getproductinfo ()
public function boolean of_getfileversioninfo (string as_filename)
public function integer of_getosbits ()
public function string of_hex (unsignedlong aul_decimal, integer ai_length)
public function unsignedinteger of_bitwiseand (unsignedinteger aui_value1, unsignedinteger aui_value2)
public function unsignedlong of_bitwiseand (unsignedlong aul_value1, unsignedlong aul_value2)
public function boolean of_remotesession ()
public function long of_split (string as_text, string as_sep, ref string as_array[])
public function integer of_getuaclevel ()
public function boolean of_getosversion (ref string as_osversion, ref string as_osedition, ref string as_csdversion)
public function string of_getfileversioninfo (string as_filename, string as_key)
end prototypes

public function string of_pbvmname ();// This function the name of the PowerBuilder VM file.

Environment le_env
String ls_vmname
Integer li_major, li_minor

GetEnvironment(le_env)

li_major = le_env.PBMajorRevision
li_minor = le_env.PBMinorRevision

choose case li_major
	case 10, 11, 12, 17
		choose case li_minor
			case 5
				ls_vmname = "pbvm" + String(li_major) + "5.dll"
			case 6
				ls_vmname = "pbvm" + String(li_major) + "6.dll"
			case else
				ls_vmname = "pbvm" + String(li_major) + "0.dll"
		end choose
	case 19
		If li_minor < 2 Then
			ls_vmname = "pbvm190.dll"
		Else
			ls_vmname = "pbvm.dll"
		End If
	case else
		If li_major < 10 Then
			ls_vmname = "pbvm" + String(li_major) + "0.dll"
		Else
			ls_vmname = "pbvm.dll"
		End If
end choose

Return ls_vmname

end function

public function string of_getproductinfo ();// This function gets product info from Vista & Newer

String ls_info
ULong lul_ProductType
Boolean lb_rtn

lb_rtn = GetProductInfo(MajorVersion, MinorVersion, &
					ServicePackMajor, ServicePackMinor, lul_ProductType)

// this is just a few of the types
choose case lul_ProductType
	case 1	// 0x00000001 - PRODUCT_ULTIMATE
		ls_info = "Ultimate"
	case 48	// 0x00000030 - PRODUCT_PROFESSIONAL
		ls_info = "Professional"
	case 3	// 0x00000003 - PRODUCT_HOME_PREMIUM
		ls_info = "Home Premium"
	case 2	// 0x00000002 - PRODUCT_HOME_BASIC
		ls_info = "Home Basic"
	case 4	// 0x00000004 - PRODUCT_ENTERPRISE
		ls_info = "Enterprise"
	case 6	// 0x00000006 - PRODUCT_BUSINESS
		ls_info = "Business"
	case 11	// 0x0000000B - PRODUCT_STARTER
		ls_info = "Starter"
	case 18	// 0x00000012 - PRODUCT_CLUSTER_SERVER
		ls_info = "Cluster Server"
	case 8	// 0x00000008 - PRODUCT_DATACENTER_SERVER
		ls_info = "Datacenter (full installation)"
	case 12	// 0x0000000C - PRODUCT_DATACENTER_SERVER_CORE
		ls_info = "Datacenter (core installation)"
	case 72	// 0x00000048 - PRODUCT_ENTERPRISE_EVALUATION
		ls_info = "Enterprise (evaluation installation)"
	case 10	// 0x0000000A - PRODUCT_ENTERPRISE_SERVER
		ls_info = "Enterprise (full installation)"
	case 14	// 0x0000000E - PRODUCT_ENTERPRISE_SERVER_CORE
		ls_info = "Enterprise (core installation)"
	case 15	// 0x0000000F - PRODUCT_ENTERPRISE_SERVER_IA64
		ls_info = "Enterprise for Itanium-based Systems"
	case 9	// 0x00000009 - PRODUCT_SMALLBUSINESS_SERVER
		ls_info = "Small Business"
	case 25	// 0x00000019 - PRODUCT_SMALLBUSINESS_SERVER_PREMIUM
		ls_info = "Small Business Premium"
	case 7	// 0x00000007 - PRODUCT_STANDARD_SERVER
		ls_info = "Standard"
	case 13	// 0x0000000D - PRODUCT_STANDARD_SERVER_CORE
		ls_info = "Standard (core installation)"
	case 17	// 0x00000011 - PRODUCT_WEB_SERVER
		ls_info = "Web Server (full installation)"
	case 29	// 0x0000001D - PRODUCT_WEB_SERVER
		ls_info = "Web Server (core installation)"
	case 101	// 0x00000065 - PRODUCT_CORE
		ls_info = "Home"
	case 121	// 0x00000079 - PRODUCT_EDUCATION
		ls_info = "Windows 10 Education"
	case 125	// 0x0000007D - PRODUCT_ENTERPRISE_S
		ls_info = "Windows 10 Enterprise 2015 LTSB"
	case 72	// 0x00000048 - PRODUCT_ENTERPRISE_EVALUATION
		ls_info = "Windows 10 Enterprise Evaluation"
	case 101	// 0x00000065 - PRODUCT_CORE
		ls_info = "Windows 10 Home"
	case 161	// 0x000000A1 - PRODUCT_PRO_WORKSTATION"
		ls_info = "Windows 10 Pro for Workstations"
	case else
		ls_info = "ProductType: " + String(lul_ProductType)
end choose

Return ls_info

end function

public function boolean of_getfileversioninfo (string as_filename);// This function gets information strings from a file.

VS_FIXEDFILEINFO lstr_FixedInfo
LANGANDCODEPAGE lstr_Translate
String	ls_versionkeys[12] = { "Comments", &
					"CompanyName", "FileDescription", "FileVersion", &
					"InternalName", "LegalCopyright", "LegalTrademarks", &
					"OriginalFilename", "ProductName", "ProductVersion", &
					"PrivateBuild", "SpecialBuild" }
String	ls_versioninfo[12], ls_key, ls_language, ls_charset
Integer	li_part1, li_part2, li_part3, li_part4
ULong		dwHandle, dwLength, bufLen
Longptr	dwPointer
Blob		lblob_Buffer
Integer	i

dwLength = GetFileVersionInfoSize(as_filename, dwHandle)
If dwLength = 0 Then
	// No version information available
	Return False
End If

// Allocate version information buffer
lblob_Buffer = Blob(Space(dwLength/2))

// Get version information
If Not GetFileVersionInfo(as_filename, dwHandle, dwLength, lblob_Buffer) Then
	Return False
End If

// Get Fixed File Info
If VerQueryValue(lblob_Buffer, "\", dwPointer, bufLen) Then
	// copy Fixed File Info to structure
	CopyMemory(lstr_FixedInfo, dwPointer, 52)
	// build FixedProductVersion
	If lstr_FixedInfo.dwProductVersionMS = 0 And &
		lstr_FixedInfo.dwProductVersionLS = 0 Then
		FixedProductVersion = ""
	Else
		li_part1 = IntHigh(lstr_FixedInfo.dwProductVersionMS)
		li_part2 = IntLow(lstr_FixedInfo.dwProductVersionMS)
		li_part3 = IntHigh(lstr_FixedInfo.dwProductVersionLS)
		li_part4 = IntLow(lstr_FixedInfo.dwProductVersionLS)
		FixedProductVersion = String(li_part1) + "." + &
					String(li_part2) + "." + String(li_part3) + &
					"." + String(li_part4)
	End If
	// build FixedFileVersion
	If lstr_FixedInfo.dwFileVersionMS = 0 And &
		lstr_FixedInfo.dwFileVersionLS = 0 Then
		FixedFileVersion = ""
	Else
		li_part1 = IntHigh(lstr_FixedInfo.dwFileVersionMS)
		li_part2 = IntLow(lstr_FixedInfo.dwFileVersionMS)
		li_part3 = IntHigh(lstr_FixedInfo.dwFileVersionLS)
		li_part4 = IntLow(lstr_FixedInfo.dwFileVersionLS)
		FixedFileVersion = String(li_part1) + "." + &
					String(li_part2) + "." + String(li_part3) + &
					"." + String(li_part4)
	End If
End If

// Get the structure language ID and character set
ls_key = "\VarFileInfo\Translation"
If Not VerQueryValue(lblob_Buffer, ls_key, dwPointer, bufLen) Then
	Return False
End If

// copy memory at dwPointer to structure
CopyMemory(lstr_Translate, dwPointer, bufLen)

// Convert the langid and char set into 4-digit hex value
ls_language = of_Hex(lstr_Translate.wLanguageId, 4)
ls_charset  = of_Hex(lstr_Translate.wCharacterSet, 4)

// for PB executables
If ls_charset = "1252" Then
	ls_charset = "04E4"
End If

// Query each of the version strings
For i = 1 To 12
	ls_key = "\StringFileInfo\" + ls_language + &
					ls_charset + "\" + ls_versionkeys[i]
	If Not VerQueryValue(lblob_Buffer, &
				ls_key, dwPointer, bufLen) Or bufLen <= 0 Then
		ls_versioninfo[i] = ""
	Else
		// copy memory at dwPointer to string array
		bufLen = bufLen * 2
		ls_versioninfo[i] = Space(bufLen)
		CopyMemory(ls_versioninfo[i], dwPointer, bufLen)
	End If
Next

// save values to instance variables
Comments				= ls_versioninfo[1]
CompanyName			= ls_versioninfo[2]
FileDescription	= ls_versioninfo[3]
FileVersion			= ls_versioninfo[4]
InternalName		= ls_versioninfo[5]
LegalCopyright		= ls_versioninfo[6]
LegalTrademarks	= ls_versioninfo[7]
OriginalFilename	= ls_versioninfo[8]
ProductName			= ls_versioninfo[9]
ProductVersion		= ls_versioninfo[10]
PrivateBuild		= ls_versioninfo[11]
SpecialBuild		= ls_versioninfo[12]

Return True

end function

public function integer of_getosbits ();// This function determines if OS is 32 bits or 64 bits.

Constant Long PROCESSOR_ARCHITECTURE_INTEL = 0	// x86
Constant Long PROCESSOR_ARCHITECTURE_IA64  = 6	// Intel Itanium-based
Constant Long PROCESSOR_ARCHITECTURE_AMD64 = 9	// x64 (AMD or Intel)
SYSTEM_INFO lstr_si
Integer li_bits
Boolean lb_IsWow64

IsWOW64Process(GetCurrentProcess(), lb_IsWow64)

If lb_IsWow64 Then
	GetNativeSystemInfo(lstr_si)
Else
	GetSystemInfo(lstr_si)
End If

choose case lstr_si.wProcessorArchitecture
	case PROCESSOR_ARCHITECTURE_IA64
		li_bits = 64
	case PROCESSOR_ARCHITECTURE_AMD64
		li_bits = 64
	case else
		li_bits = 32
end choose

Return li_bits

end function

public function string of_hex (unsignedlong aul_decimal, integer ai_length);// This function converts a number to a hex string.

String ls_hex
Char lch_hex[0 to 15] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', &
							'A', 'B', 'C', 'D', 'E', 'F'}

// convert to hexidecimal
Do 
	ls_hex = lch_hex[mod (aul_decimal, 16)] + ls_hex
	aul_decimal /= 16
Loop Until aul_decimal= 0

// add zeroes to front so that result is ai_length characters
ls_hex = Fill('0', ai_length) + ls_hex
ls_hex = Right(ls_hex, ai_length)

Return ls_hex

end function

public function unsignedinteger of_bitwiseand (unsignedinteger aui_value1, unsignedinteger aui_value2);// This function performs a bit-wise AND operation
// on two unsigned int's. Code courtesy John Fauss.

Integer li_i
UInt    lui_result, lui_factor

If IsNull( aui_value1) Or IsNull( aui_value2) Then
	SetNull( lui_result)
	Return lui_result
End If

lui_result = 0
For li_i = 1 To 16
	If aui_value1 = 0 Or aui_value2 = 0 Then Exit
	If li_i = 1 Then
		lui_factor = 1
	Else
		lui_factor = lui_factor * 2
	End If
	If Mod( aui_value1, 2) = 1 And Mod( aui_value2, 2) = 1 Then
		lui_result += lui_factor
	End If
	aui_value1 = aui_value1 / 2
	aui_value2 = aui_value2 / 2
Next

Return lui_result
end function

public function unsignedlong of_bitwiseand (unsignedlong aul_value1, unsignedlong aul_value2);// This function performs a bit-wise AND operation
// on two unsigned long's. Code courtesy John Fauss.

Integer li_i
ULong   lul_result, lul_factor

If IsNull( aul_value1) Or IsNull( aul_value2) Then
	SetNull( lul_result)
	Return lul_result
End If

lul_result = 0
For li_i = 1 To 32
	If aul_value1 = 0 Or aul_value2 = 0 Then Exit
	If li_i = 1 Then
		lul_factor = 1
	Else
		lul_factor = lul_factor * 2
	End If
	If Mod( aul_value1, 2) = 1 And Mod( aul_value2, 2) = 1 Then
		lul_result += lul_factor
	End If
	aul_value1 = aul_value1 / 2
	aul_value2 = aul_value2 / 2
Next

Return lul_result
end function

public function boolean of_remotesession ();// Determine Remote Desktop/Terminal Services

Constant Long SM_REMOTESESSION = 4096	// 0x1000

If GetSystemMetrics(SM_REMOTESESSION) = 0 Then
	Return False
Else
	Return True
End If

end function

public function long of_split (string as_text, string as_sep, ref string as_array[]);// This function splits a string into an array

String ls_empty[], ls_work
Long ll_pos

as_array = ls_empty

If IsNull(as_text) Or as_text = "" Then Return 0

ll_pos = Pos(as_text, as_sep)
DO WHILE ll_pos > 0
	ls_work = Trim(Left(as_text, ll_pos - 1))
	as_text = Trim(Mid(as_text, ll_pos + Len(as_sep)))
	as_array[UpperBound(as_array) + 1] = ls_work
	ll_pos = Pos(as_text, as_sep)
LOOP
If Len(as_text) > 0 Then
	as_array[UpperBound(as_array) + 1] = as_text
End If

Return UpperBound(as_array)

end function

public function integer of_getuaclevel ();// Get the current uac level
//
// 1 - Low			- Never Notify
// 2 - Medium		- When apps make changes (no dim)
// 3 - Default		- When apps make changes (dim)
// 4 - High			- Always for any changes (dim)
//

Integer li_level
ULong lul_Consent, lul_Secure
String ls_regkey

ls_regkey = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

RegistryGet(ls_regkey, "ConsentPromptBehaviorAdmin", ReguLong!, lul_Consent)
RegistryGet(ls_regkey, "PromptOnSecureDesktop", ReguLong!, lul_Secure)

choose case lul_Consent
	case 0
		li_level = 1
	case 2
		li_level = 4
	case else
		If lul_Secure = 1 Then
			li_level = 3
		Else
			li_level = 2
		End If
end choose

Return li_level

end function

public function boolean of_getosversion (ref string as_osversion, ref string as_osedition, ref string as_csdversion);//
// This function gets operating system version information.
//

// Background Info:
// https://en.wikipedia.org/wiki/Comparison_of_Microsoft_Windows_versions
// https://docs.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-osversioninfoexw
//
// Windows 10:
// https://docs.microsoft.com/en-us/windows/release-health/release-information
//
// Windows 11:
// https://docs.microsoft.com/en-us/windows/release-health/windows11-release-information
//
// Windows Server:
// https://docs.microsoft.com/en-us/windows/release-health/windows-server-release-info

OSVERSIONINFOEX lstr_ovi
Constant UInt VER_NT_WORKSTATION = 1

lstr_ovi.dwOSVersionInfoSize = 284

If RtlGetVersion(lstr_ovi) <> 0 Then Return False

// save values to instance variables
MajorVersion		= lstr_ovi.dwMajorVersion
MinorVersion		= lstr_ovi.dwMinorVersion
BuildNumber			= lstr_ovi.dwBuildNumber
ServicePackMajor	= lstr_ovi.wServicePackMajor
ServicePackMinor	= lstr_ovi.wServicePackMinor
SuiteMask			= lstr_ovi.wSuiteMask
ProductType			= lstr_ovi.wProductType

// set default values
as_osversion  = "OS Version: " + String(MajorVersion) + "." + String(MinorVersion)
as_osedition  = "OS Edition: " + String(SuiteMask)
as_csdversion = "OS Build: " + String(BuildNumber)

// populate by ref string arguments
choose case lstr_ovi.dwMajorVersion
	case 5
		as_csdversion = Trim(String(lstr_ovi.szCSDVersion))
		choose case lstr_ovi.dwMinorVersion
			case 0
				as_osversion = "Windows 2000"
			case 1
				as_osversion = "Windows XP"
			case 2
				as_osversion = "Windows Server 2003"
				as_osedition = of_GetProductInfo()
		end choose
	case 6
		as_csdversion = Trim(String(lstr_ovi.szCSDVersion))
		choose case lstr_ovi.dwMinorVersion
			case 0
				If lstr_ovi.wProductType = VER_NT_WORKSTATION Then
					as_osversion = "Windows Vista"
					as_osedition = of_GetProductInfo()
				Else
					as_osversion = "Windows Server 2008"
					as_osedition = of_GetProductInfo()
				End If
			case 1
				If lstr_ovi.wProductType = VER_NT_WORKSTATION Then
					as_osversion = "Windows 7"
					as_osedition = of_GetProductInfo()
				Else
					as_osversion = "Windows Server 2008 R2"
					as_osedition = of_GetProductInfo()
				End If
			case 2
				If lstr_ovi.wProductType = VER_NT_WORKSTATION Then
					as_osversion = "Windows 8"
					as_osedition = of_GetProductInfo()
				Else
					as_osversion = "Windows Server 2012"
					as_osedition = of_GetProductInfo()
				End If
			case 3
				If lstr_ovi.wProductType = VER_NT_WORKSTATION Then
					as_osversion = "Windows 8.1"
					as_osedition = of_GetProductInfo()
				Else
					as_osversion = "Windows Server 2012 R2"
					as_osedition = of_GetProductInfo()
				End If
		end choose
	case 10
		If lstr_ovi.wProductType = VER_NT_WORKSTATION Then
			as_osedition = of_GetProductInfo()
			If lstr_ovi.dwBuildNumber < 22000 Then
				as_osversion = "Windows 10"
				// determine release name from build number
				choose case lstr_ovi.dwBuildNumber
					case 10240
						as_csdversion = "Original Release (1507)"
					case 10586
						as_csdversion = "November Update (1511)"
					case 14393
						as_csdversion = "Anniversary Update (1607)"
					case 15063
						as_csdversion = "Creators Update (1703)"
					case 16299
						as_csdversion = "Fall Creators Update (1709)"
					case 17134
						as_csdversion = "April 2018 Update (1803)"
					case 17763
						as_csdversion = "October 2018 Update (1809)"
					case 18362
						as_csdversion = "May 2019 Update (1903)"
					case 18363
						as_csdversion = "November 2019 Update (1909)"
					case 19041
						as_csdversion = "Version 2004"
					case 19042
						as_csdversion = "Version 20H2"
					case 19043
						as_csdversion = "Version 21H1"
					case 19044
						as_csdversion = "Version 21H2"
					case 19045
						as_csdversion = "Version 22H2"
					case else
						as_csdversion = "OS Build: " + String(BuildNumber)
				end choose
			Else
				as_osversion = "Windows 11"
				// determine release name from build number
				choose case lstr_ovi.dwBuildNumber
					case 22000
						as_csdversion = "Version 21H2 (Original)"
					case 22621
						as_csdversion = "Version 22H2"
					case else
						as_csdversion = "OS Build: " + String(BuildNumber)
				end choose
			End If
		Else
			as_osversion = "Windows Server"
			as_osedition = of_GetProductInfo()
			// determine release name from build number
			as_osversion = "Windows Server"
			as_osedition = of_GetProductInfo()
			// determine release name from build number
			choose case lstr_ovi.dwBuildNumber
				case 14393
					as_osversion += " 2016"
					as_csdversion = "Version 1607"
				case 17763
					as_osversion += " 2019"
					as_csdversion = "Version 1809"
				case 18363
					as_osversion += " 2019"
					as_csdversion = "Version 1909"
				case 19041
					as_osversion += " 2019"
					as_csdversion = "Version 2004"
				case 19042
					as_osversion += " 2019"
					as_csdversion = "Version 20H2"
				case 20348
					as_osversion += " 2022"
					as_csdversion = ""
				case else
					as_csdversion = "OS Build: " + String(BuildNumber)
					as_csdversion = ""
			end choose
		End If
end choose

Return True

end function

public function string of_getfileversioninfo (string as_filename, string as_key);// This function gets an information string from a file.

LANGANDCODEPAGE lstr_Translate
Blob lblob_Buffer
String ls_Value, ls_key, ls_language, ls_charset
ULong dwLength, dwHandle, bufLen
Longptr dwPointer

dwLength = GetFileVersionInfoSize(as_filename, dwHandle)
If dwLength = 0 Then
	// No version information available
	Return ""
End If

// Allocate version information buffer
lblob_Buffer = Blob(Space(dwLength/2))

// Get version information
If Not GetFileVersionInfo(as_filename, dwHandle, dwLength, lblob_Buffer) Then
	Return ""
End If

// Get the structure language ID and character set
ls_key = "\VarFileInfo\Translation"
If Not VerQueryValue(lblob_Buffer, ls_key, dwPointer, bufLen) Then
	Return ""
End If

// copy memory at dwPointer to structure
CopyMemory(lstr_Translate, dwPointer, bufLen)

// Convert the langid and char set into 4-digit hex value
ls_language = of_Hex(lstr_Translate.wLanguageId, 4)
ls_charset  = of_Hex(lstr_Translate.wCharacterSet, 4)

// for PB executables
If ls_charset = "1252" Then
	ls_charset = "04E4"
End If

ls_key = "\StringFileInfo\" + ls_language + &
			ls_charset + "\" + as_key
If Not VerQueryValue(lblob_Buffer, &
			ls_key, dwPointer, bufLen) Or bufLen <= 0 Then
	Return ""
Else
	// copy memory at dwPointer to string array
	bufLen = bufLen * 2
	ls_Value = Space(bufLen)
	CopyMemory(ls_Value, dwPointer, bufLen)
End If

Return ls_Value

end function

on n_osversion.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_osversion.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

