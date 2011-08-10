;;-------------------------------------------------------------------------
;;
;;	Adic Helper [cJass]
;;	v 1.4.2.31
;;
;;	© 2009 ADOLF aka ADX 
;;	http://cjass.xgm.ru
;;
;;-------------------------------------------------------------------------

;;-------------------------------------------------------------------------
	.686
	.model flat
	.xmm
;;-------------------------------------------------------------------------
	includelib	\masm32\lib\kernel32.lib
	includelib	\masm32\lib\user32.lib
	includelib	\masm32\lib\gdi32.lib
	includelib	\masm32\lib\comctl32.lib
	includelib	\masm32\lib\shell32.lib

	includelib	SFmpq.lib

;;	include		\masm32\include\kernel32.inc
	include		\masm32\include\gdi32.inc
	include		\masm32\include\windows.inc
	include		\masm32\include\comctl32.inc
;;-------------------------------------------------------------------------
	extern	_imp__ExitProcess@4:dword
	extern	_imp__GetCommandLineA@0:dword
	extern	_imp__CreateThread@24:dword
	extern	_imp__CloseHandle@4:dword
	extern	_imp__GlobalAlloc@8:dword
	extern	_imp__GlobalLock@4:dword
	extern	_imp__GlobalUnlock@4:dword
	extern	_imp__GlobalFree@4:dword
	extern	_imp__CreateFileA@28:dword
	extern	_imp__WriteFile@20:dword
	extern	_imp__DeleteFileA@4:dword
	extern	_imp__GetCurrentDirectoryA@8:dword
	extern	_imp__SetCurrentDirectoryA@4:dword
	extern	_imp__ReadFile@20:dword
	extern	_imp__GetFileSize@8:dword
	extern	_imp__SetThreadPriority@8:dword
	extern	_imp__LoadLibraryA@4:dword
	extern	_imp__GetProcAddress@8:dword
extern	_imp__CreateProcessA@40:dword
extern	_imp__WaitForSingleObject@8:dword

	extern	_imp__MessageBoxA@16:dword
	extern	_imp__RegisterClassA@4:dword
	extern	_imp__CreateWindowExA@48:dword
	extern	_imp__GetSystemMetrics@4:dword
	extern	_imp__GetMessageA@16:dword
	extern	_imp__DispatchMessageA@4:dword
	extern	_imp__DefWindowProcA@16:dword
	extern	_imp__LoadIconA@8:dword
	extern	_imp__PostMessageA@16:dword
	extern	_imp__SendMessageA@16:dword
	extern	_imp__ShowWindow@8:dword
	extern	_imp__RedrawWindow@16:dword
	extern	_imp__LoadCursorA@8:dword
	extern	_imp__SetCursor@4:dword
;;	extern	_imp__DrawIcon@16:dword
	extern	_imp__DestroyWindow@4:dword
	extern	_imp__SetWindowTextA@8:dword
	extern	_imp__MoveWindow@24:dword
	extern	_imp__MessageBeep@4:dword
	extern	_imp__SetFocus@4:dword

	extern	_imp__MpqOpenArchiveForUpdate@12:dword
	extern	_imp__MpqDeleteFile@8:dword
	extern	_imp__SFileOpenFileEx@16:dword
extern	_imp__SFileCloseFile@4:dword
	extern	_imp__MpqCompactArchive@4:dword
	extern	_imp__MpqCloseUpdatedArchive@8:dword
	extern	_imp__SFileGetFileSize@8:dword
	extern	_imp__SFileReadFile@20:dword
	extern	_imp__MpqAddFileToArchiveEx@24:dword

	extern	_imp__BeginPaint@8:dword
	extern	_imp__EndPaint@8:dword
	extern	_imp__SetBkMode@8:dword
	extern	_imp__GetStockObject@4:dword
	extern	_imp__SelectObject@8:dword
	extern	_imp__SetBkMode@8:dword
	extern	_imp__DrawTextA@20:dword
	extern	_imp__SetTextColor@8:dword
	extern	_imp__CreateFontIndirectA@4:dword
	
	extern	_imp__ShellExecuteA@24:dword

	extern	_imp__GetLocalTime@4:dword
	
;;dbg
;;extern	_imp__wsprintfA:dword
;;-------------------------------------------------------------------------
.data

	WM_PROCEND		equ	WM_USER + 02h
	WM_CJ_ERROR		equ	WM_USER + 03h

	_dWndStlEx		dd	WS_VISIBLE

;	align			04h
	_sWinName		db	"AdicHelper 1.4.2.31", 00h
	_sTollInfo		db	"cJass parser and optimizer AdicHelper v 1.4.2.31", 0dh, 0ah, "ADOLF aka ADX, 2011", 00h
	_sSiteAdr		db	"http://cjass.xgm.ru", 00h
	
	_sOpen			db	"open", 00h

	_sAttr			db	"(attributes)", 00h
	_sWJ			db	"war3map.j", 00h
	_sBJ			db	"scripts\Blizzard.j", 00h
	_sCJ			db	"scripts\common.j", 00h
	_sWJP			db	"parsed_war3map.j", 00h
	_sWJO			db	"optimized_war3map.j", 00h
	_sSynErr		db	"AdicHelper: syntax error", 00h

	_sCstProcName		db	"ParseCode", 00h

	_dfilename		dd	offset _sWJP

	_dDefTableSD		equ	$

	_dMapProcCode		dd	00h	;; used in string preprocessor

	;; used in setdef
				dd	00h, 00h, 00h

	_hWndCls		dd	CS_NOCLOSE or CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW,
					offset _hWndProc, 00h, 00h, 400000h, ?, 10011h, COLOR_WINDOW, 00h, offset _sWJ
	_hErrCls		dd	CS_HREDRAW or CS_VREDRAW,
					offset _hErrProc, 00h, 00h, 400000h, ?, 10011h,	COLOR_WINDOW, 00h, offset _sSynErr

	;; fonts
	_xOutFont		dd	0bh, 00h, 00h, 00h, 0190h
				db	00h, 00h ,00h, ANSI_CHARSET, 00h, 00h, 00h, 01h
				db	"Lucida console", 00h
	_xGuiFont		dd	0dh, 00h, 00h, 00h, 0190h
				db	00h, 00h ,00h, ANSI_CHARSET, 00h, 00h, 00h, 01h
				db	"MS Sans Serif", 00h
	_xWWWFont		dd	0dh, 00h, 00h, 00h, 0190h
				db	00h, 01h ,00h, ANSI_CHARSET, 00h, 00h, 00h, 01h
				db	"MS Sans Serif", 00h

	_dFreeScope		dd	00h

	_dDbgOff		dd	offset _lCRDebugRem	;; is debug mode

	_dSynDesc		dd	offset _xSynDesc	;; ex syntax (zinc and boa) pointer

	_dInclArgCurr		dd	offset _xInclArg

	_dAddrDefArgPnt		dd	offset _dAddrDefArg

	_dSortSteps		dd	0010h, 0050h, 0130h, 0290h, 06d0h, 0d10h, 1f90h, 3a10h, 8710h, 0f410h, 0ffffffffh
	;;
	;; 10 bits offset oriented
	;;

	_dAnonBlock		dd	offset 	_dAnonBlockTable - 04h	;; anonym block counter

	_dCurrStr		dd	offset _sProg_00

	_dStaticVarsId		dd	0ffffffffh	;; static variables id

	_dForGroupIdMax		dd	0ffffffffh	;; for groups id

	_xRect_00		dd	0010h, 10h, 0172h, 40h
	_xRect_01		dd	0010h, 24h, 0172h, 40h
	_xRect_toRedraw		dd	0118h, 10h, 0172h, 1ch

	_xRect_02		dd	0010h, 08h, 0172h, 20h

	_dEnumStrPoint		dd	offset _xEnumStr+0dh
	_dEnumTablePointer	dd	offset _xEnumTable+0ch
;;	_dEnumLabelPointer	dd	offset _xEnumLabel

	_dEnumDefTable		dd	offset _xEnumDefTable, offset _xEnumDefTable+0ch
	_xEnumDefTable		dd	80000000h, 0ffffffffh, offset _xEnumDefTable+0ch, 00000000h, 7fffffffh, 00000000h

	_sDateL			db	"DATE", 02h
	_sTimeL			db	"TIME", 02h
	_sDebugL		db	"DEBUG", 02h
	_sCountL		db	"COUNTER", 02h
	_sCountSTL		db	"COUNTER_ST", 02h
	_sCountIncL		db	"CounterInc()", 02h
	_sCountResL		db	"CounterReset()", 02h
	_sWeatherL		db	"WEATHER_ON_MARS", 02h
	_sWarVer		db	"WAR3VER", 02h
	_sFuncNameL		db	"FUNCNAME", 02h
	_sAnonymL		db	"lambda", 02h
	_sAFLDefL		db	"AUTOFLUSH_LOCALS", 02h
	_sWhileMcrL		db	"while", 02h
	_sEndWhileMcrL		db	"endwhile", 02h
	_sFirstWordL		db	"FIRST_WORD", 02h
	_sImportBJL		db	"IS_CUSTOM_BJ", 02h
	_sImportCJL		db	"IS_CUSTOM_CJ", 02h
	_sForpMacroL		db	"forp", 02h
	_sForMacroL		db	"for", 02h
	_sArgMacrolL		db	"WITHOUT_FIRST_WORD", 02h

	_sArgMacrol		db	01h, "q", 80h, 01h, "n", 03h
	_sInt			db	"integer", 03h
	_sTrue			db	"1", 03h
	_sVer24			db	"WAR3VER_24", 03h
	_sVer23			db	"WAR3VER_23", 03h
	_sVerUndef		db	"WAR3VER_00", 03h
	_sCntSpec		db	01h, 36h, 03h
	_sCntSTSpec		db	01h, 34h, 03h
	_sWether		db	01h, 37h, 03h
	_sFuncName		db	66h, 66h, 01h, 38h, 03h
	_sCountInc		db	01h, 41h, 03h
	_sCountRes		db	01h, 42h, 03h
	_sAnonym		db	01h, 44h, 03h
	_sAFLDef		db	"0", 03h
	_sWhileMcr		db	01h, 77h, "whilenot!(", 03h
	_sEndWhileMcr		db	"endwhilenot", 03h
	_sFirstWord		db	01h, "q", 80h, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, " ", 84h, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, " ", 84h, " ", 85h, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, " ", 84h, " ", 85h, " ", 86h, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, " ", 84h, " ", 85h, " ", 86h, " ", 87h, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, " ", 84h, " ", 85h, " ", 86h, " ", 87h, " ", 88h, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, " ", 84h, " ", 85h, " ", 86h, " ", 87h, " ", 88h, " ", 89h, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, " ", 84h, " ", 85h, " ", 86h, " ", 87h, " ", 88h, " ", 89h, " ", 8ah, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, " ", 84h, " ", 85h, " ", 86h, " ", 87h, " ", 88h, " ", 89h, " ", 8ah, " ", 8bh, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, " ", 84h, " ", 85h, " ", 86h, " ", 87h, " ", 88h, " ", 89h, " ", 8ah, " ", 8bh, " ", 8ch, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, " ", 84h, " ", 85h, " ", 86h, " ", 87h, " ", 88h, " ", 89h, " ", 8ah, " ", 8bh, " ", 8ch, " ", 8dh, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, " ", 84h, " ", 85h, " ", 86h, " ", 87h, " ", 88h, " ", 89h, " ", 8ah, " ", 8bh, " ", 8ch, " ", 8dh, " ", 8eh, 01h, "t", 03h
				db	01h, "q", 80h, " ", 81h, " ", 82h, " ", 83h, " ", 84h, " ", 85h, " ", 86h, " ", 87h, " ", 88h, " ", 89h, " ", 8ah, " ", 8bh, " ", 8ch, " ", 8dh, " ", 8eh, " ", 8fh, 01h, "t", 03h
	_sImportBJ		db	"0", 03h
	_sImportCJ		db	"0", 03h
	_sForp4Macro		db	"vblock", 0dh, 0ah, 80h, 0dh, 0ah, "do", 0dh, 0ah, 83h, 0dh, 0ah, 82h, 0dh, 0ah, "enddo whilenot !(", 81h, ")", 0dh, 0ah, "endvblock", 0dh, 0ah, 03h
	_sForp3Macro		db	"vblock", 0dh, 0ah, 80h, 0dh, 0ah, "do", 0dh, 0ah, 82h, 0dh, 0ah, "enddo whilenot !(", 81h, ")", 0dh, 0ah, "endvblock", 0dh, 0ah, 03h
	_sFor2Macro		db	"vblock", 0dh, 0ah, 80h, 0dh, 0ah, "loop", 0dh, 0ah, 81h, 0dh, 0ah, "endloop", 0dh, 0ah, "endvblock", 0dh, 0ah, 03h

	_sForGroupEnumTypes	db	"UnitsOfType UnitsOfPlayer UnitsOfTypeCounted UnitsInRect UnitsInRectCounted "
				db	"UnitsInRange UnitsInRangeOfLoc UnitsInRangeCounted UnitsInRangeOfLocCounted UnitsSelected", 00h

	_sForGroupEnumTypesEx	db	"UnitsInGroup", 00h

	_sForGroupEnumTypesFx	db	"GroupRemovePickedUnit()", 00h

	;;----------------
	_sFor3Macro		dw	0a0dh
				db	01h, "q", 01h, "q", 81h, 01h, "t", 01h, "O"
				dd	offset _sForGroupEnumTypes, offset _sFor3Macro_GroupEnum, offset _sFor3Macro_Next_00

	_sFor3Macro_Next_00	db	01h, "q", 01h, "q", 81h, 01h, "t", 01h, "O"
				dd	offset _sForGroupEnumTypesEx, offset _sFor3Macro_Group, offset _sFor3Macro_For

	_sFor3Macro_GroupEnum	db	"vblock", 0dh, 0ah
				db	80h, 0dh, 0ah
				db	"cjgrfgn_", 01h, "h", 0dh, 0ah
				db	"GroupEnum", 01h, "q", 81h, 01h, "t(cjgrfgn_", 01h, "k,", 01h, "q", 81h, 01h, "n, null)", 0dh, 0ah
				db	"loop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=FirstOfGroup(cjgrfgn_", 01h, "k)", 0dh, 0ah
				db	"exitwhen ", 01h, "q", 80h, 01h, "v==null", 0dh, 0ah
				db	"GroupRemoveUnit(cjgrfgn_", 01h, "k,", 01h, "q", 80h, 01h, "v)", 0dh, 0ah
				db	82h, 0dh, 0ah
				db	"endloop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=null_cjnullex", 0dh, 0ah
				db	"endvblock", 0dh, 0ah
				db	03h

	_sFor3Macro_Group	db	"vblock", 0dh, 0ah
				db	80h, 0dh, 0ah
				db	"cjgrfgn_", 01h, "h", 0dh, 0ah
				db	"cj_tmpgr_copy_nw509ert7=cjgrfgn_", 01h, "k", 0dh, 0ah
				db	"GroupClear(cj_tmpgr_copy_nw509ert7)", 0dh, 0ah
				db	"ForGroup(", 01h, "q", 81h, 01h, "n,function cj_group_copy_75hJKJ3745gf)", 0dh, 0ah
				db	"loop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=FirstOfGroup(cjgrfgn_", 01h, "k)", 0dh, 0ah
				db	"exitwhen ", 01h, "q", 80h, 01h, "v==null", 0dh, 0ah
				db	"GroupRemoveUnit(cjgrfgn_", 01h, "k,", 01h, "q", 80h, 01h, "v)", 0dh, 0ah
				db	82h, 0dh, 0ah
				db	"endloop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=null_cjnullex", 0dh, 0ah
				db	"endvblock", 0dh, 0ah
				db	03h

	_sFor3Macro_For		db	"vblock", 0dh, 0ah
				db	80h, 0dh, 0ah
				db	"whilenot !(", 81h, ")", 0dh, 0ah
				db	82h, 0dh, 0ah
				db	"endwhilenot", 0dh, 0ah
				db	"endvblock", 0dh, 0ah
				db	03h
	;;----------------

	;;----------------
	_sFor4Macro		dw	0a0dh
				db	01h, "q", 01h, "q", 81h, 01h, "t", 01h, "O"
				dd	offset _sForGroupEnumTypes, offset _sFor4Macro_GroupEnumX, offset _sFor4Macro_Next_00

	_sFor4Macro_Next_00	db	01h, "q", 01h, "q", 81h, 01h, "t", 01h, "O"
				dd	offset _sForGroupEnumTypesEx, offset _sFor4Macro_Group, offset _sFor4Macro_For

	_sFor4Macro_Group	db	01h, "q", 82h, 01h, "O"
				dd	offset _sForGroupEnumTypesFx, offset _sFor4Macro_GroupPick_A, offset _sFor4Macro_GroupPick_B


	_sFor4Macro_GroupPick_A	db	01h, "q", 01h, "q", 81h, 01h, "n", 01h, "P"
				dd	offset _sFor4Macro_GroupPick_C, offset _sFor4Macro_GroupPick_D

;; lite pick
	_sFor4Macro_GroupPick_C	db	"vblock", 0dh, 0ah
				db	80h, 0dh, 0ah
				db	"loop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=FirstOfGroup(", 01h, "q", 81h, 01h, "n)", 0dh, 0ah
				db	"exitwhen ", 01h, "q", 80h, 01h, "v==null", 0dh, 0ah
				db	"GroupRemoveUnit(", 01h, "q", 81h, 01h, "n,", 01h, "q", 80h, 01h, "v)", 0dh, 0ah
				db	83h, 0dh, 0ah
				db	"endloop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=null_cjnullex", 0dh, 0ah
				db	"endvblock", 0dh, 0ah
				db	03h

;; lite pick use additional group
	_sFor4Macro_GroupPick_D	db	"vblock", 0dh, 0ah
				db	80h, 0dh, 0ah
				db	"globals", 0dh, 0ah
				db	"group cjgrfgt_", 01h, "h", 0dh, 0ah
				db	"endglobals", 0dh, 0ah
				db	"cjgrfgt_", 01h, "k=", 01h, "q", 81h, 01h, "n", 0dh, 0ah
				db	"loop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=FirstOfGroup(cjgrfgt_", 01h, "k)", 0dh, 0ah
				db	"exitwhen ", 01h, "q", 80h, 01h, "v==null", 0dh, 0ah
				db	"GroupRemoveUnit(cjgrfgt_", 01h, "k,", 01h, "q", 80h, 01h, "v)", 0dh, 0ah
				db	83h, 0dh, 0ah
				db	"endloop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=null_cjnullex", 0dh, 0ah
				db	"endvblock", 0dh, 0ah
				db	03h

	_sFor4Macro_GroupPick_B	db	01h, "q", 82h, 01h, "P"
				dd	offset _sFor4Macro_GroupPick_E, offset _sFor4Macro_GroupPick_F

;; hard pick
	_sFor4Macro_GroupPick_E	db	"vblock", 0dh, 0ah
				db	80h, 0dh, 0ah
				db	"cj_tmpgr_copy_nw509ert7=", 82h, 0dh, 0ah
				db	"GroupClear(cj_tmpgr_copy_nw509ert7)", 0dh, 0ah
				db	"ForGroup(", 01h, "q", 81h, 01h, "n,function cj_group_copy_75hJKJ3745gf)", 0dh, 0ah
				db	"loop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=FirstOfGroup(", 82h, ")", 0dh, 0ah
				db	"exitwhen ", 01h, "q", 80h, 01h, "v==null", 0dh, 0ah
				db	"GroupRemoveUnit(", 82h, ",", 01h, "q", 80h, 01h, "v)", 0dh, 0ah
				db	83h, 0dh, 0ah
				db	"endloop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=null_cjnullex", 0dh, 0ah
				db	"endvblock", 0dh, 0ah
				db	03h

;; hard pick use additional pick
	_sFor4Macro_GroupPick_F	db	"vblock", 0dh, 0ah
				db	80h, 0dh, 0ah
				db	"globals", 0dh, 0ah
				db	"group cjgrfgt_", 01h, "h", 0dh, 0ah
				db	"endglobals", 0dh, 0ah
				db	"cjgrfgt_", 01h, "k=", 82h, 0dh, 0ah
				db	"cj_tmpgr_copy_nw509ert7=cjgrfgt_", 01h, "k", 0dh, 0ah
				db	"GroupClear(cj_tmpgr_copy_nw509ert7)", 0dh, 0ah
				db	"ForGroup(cjgrfgt_", 01h, "k,function cj_group_copy_75hJKJ3745gf)", 0dh, 0ah
				db	"loop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=FirstOfGroup(cjgrfgt_", 01h, "k)", 0dh, 0ah
				db	"exitwhen ", 01h, "q", 80h, 01h, "v==null", 0dh, 0ah
				db	"GroupRemoveUnit(cjgrfgt_", 01h, "k,", 01h, "q", 80h, 01h, "v)", 0dh, 0ah
				db	83h, 0dh, 0ah
				db	"endloop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=null_cjnullex", 0dh, 0ah
				db	"endvblock", 0dh, 0ah
				db	03h

	_sFor4Macro_GroupEnumX	db	01h, "q", 82h, 01h, "P"
				dd	offset _sFor4Macro_GroupEnum_A, offset _sFor4Macro_GroupEnum_B

;; lite enum
	_sFor4Macro_GroupEnum_A	db	"vblock", 0dh, 0ah
				db	80h, 0dh, 0ah
				db	"GroupEnum", 01h, "q", 81h, 01h, "t(", 82h, ",", 01h, "q", 81h, 01h, "n, null)", 0dh, 0ah
				db	"loop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=FirstOfGroup(", 82h, ")", 0dh, 0ah
				db	"exitwhen ", 01h, "q", 80h, 01h, "v==null", 0dh, 0ah
				db	"GroupRemoveUnit(", 82h, ",", 01h, "q", 80h, 01h, "v)", 0dh, 0ah
				db	83h, 0dh, 0ah
				db	"endloop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=null_cjnullex", 0dh, 0ah
				db	"endvblock", 0dh, 0ah
				db	03h

;; hard enum
	_sFor4Macro_GroupEnum_B	db	"vblock", 0dh, 0ah
				db	80h, 0dh, 0ah
				db	"globals", 0dh, 0ah
				db	"group cjgrfgt_", 01h, "h", 0dh, 0ah
				db	"endglobals", 0dh, 0ah
				db	"cjgrfgt_", 01h, "k=", 82h, 0dh, 0ah
				db	"GroupEnum", 01h, "q", 81h, 01h, "t(cjgrfgt_", 01h, "k,", 01h, "q", 81h, 01h, "n, null)", 0dh, 0ah
				db	"loop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=FirstOfGroup(cjgrfgt_", 01h, "k)", 0dh, 0ah
				db	"exitwhen ", 01h, "q", 80h, 01h, "v==null", 0dh, 0ah
				db	"GroupRemoveUnit(cjgrfgt_", 01h, "k,", 01h, "q", 80h, 01h, "v)", 0dh, 0ah
				db	83h, 0dh, 0ah
				db	"endloop", 0dh, 0ah
				db	01h, "q", 80h, 01h, "v=null_cjnullex", 0dh, 0ah
				db	"endvblock", 0dh, 0ah
				db	03h

;; for
	_sFor4Macro_For		db	"vblock", 0dh, 0ah
				db	80h, 0dh, 0ah
				db	"whilenot !(", 81h, ")", 0dh, 0ah
				db	83h, 0dh, 0ah
				db	82h, 0dh, 0ah
				db	"endwhilenot", 0dh, 0ah
				db	"endvblock", 0dh, 0ah
				db	03h
	;;----------------

	_dWarVerSL		dd	offset _sVerUndef	;; if zero - do not remove unused code

	_sProg_00		db	"Parsing: preparing...", 00h
	_sProg_01_pre		db	"Parsing: textmacro preprocessing...", 00h
	_sProg_01		db	"Parsing: processing...", 00h
	_sProg_02		db	"Parsing: build Find'n'Replace table...", 00h
	_sProg_03		db	"Parsing: find'n'Replace - process...", 00h
	_sProg_04		db	"Parsing: functions and variables...", 00h
	_sProg_05		db	"Parsing: success!", 00h

	_sProg_06		db	"Optimization: preparing...", 00h
	_sProg_07		db	"Optimization: removing unused code...", 00h
	_sProg_08		db	"Optimization: success!", 00h

	_sExit			db	"Exit", 00h

	_sProgBar		db	"msctls_progress32", 00h
	_sEditWnd		db	"edit",	00h
	_sListWnd		db	"listbox", 00h
	_sButton		db	"button", 00h

	_sErr_Arch		db	"Error: cannot open archive", 00h
	_sErr_Code		db	"Error: cannot find war3map.j", 00h
	_sErr_Scrf		db	"Error: cannot open file", 00h

	_sErr_Title		db	"Compiling is stopped", 00h

	_sErr_Base		db	"[00] Critical syntax error", 00h
	_sErr_UnclosedString	db	"[01] Critical error: string unclosed or too big", 00h
	_sErr_CantOpenFile	db	"[02] Critical error: cannot open included file", 00h
	_sErr_BadBlockInFile	db	"[03] Critical error: unclosed block in included file", 00h
	_sErr_BadBlock		db	"[04] Critical error: excessive block closing bracket", 00h
	_sErr_UnclosedBlock	db	"[05] Critical error: unclosed block", 00h
	_sErr_EndLibScope	db	"[06] Critical error: excessive endlibrary/endscope", 00h
	_sErr_BadDef		db	"[07] Critical error: word cannot be defined: maybe missing enddefine?", 00h
	_sErr_BadChar		db	"[08] Critical error: bad char", 00h
	_sErr_UnclosedLib	db	"[09] Critical error: missing endlibrary or endscope", 00h
	_sErr_UnclosedComment	db	"[10] Critical error: unclosed comment block", 00h
	_sErr_BadComment	db	"[11] Critical error: comment closed without opening", 00h
	_sErr_ValueRedefined	db	"[12] Critical error: macro defined twice with different arguments", 00h
	_sErr_ValueRedefinedEX	db	"[**] Redeclared here", 00h
	_sErr_MissDefArg	db	"[13] Critical error: missing define arguments", 00h
	_sErr_DefArg		db	"[14] Critical error: too many arguments passed to define", 00h
	_sErr_UnknowBlock	db	"[15] Critical error: unknown block", 00h
	_sErr_IncorrectLiteral	db	"[16] Critical error: incorrect literal", 00h
	_sErr_PreProc		db	"[17] Critical error: incorrect preprocessor instruction", 00h
	_sErr_Ude		db	"[18] Critical error: used defined error", 00h
	_sErr_FailedDef		db	"[19] Critical error: defines cannot be declared in #if/#endif block. Please declare them outside of this block and use setdef instruction", 00h
	_sErr_PlugFail		db	"[20] Critical error: cannot load plugin or cannot found function <_stdcall cjplugresult ParseCode (*cjpluginfo arg)>", 00h
	_sErr_PlugEpicFail	db	"[21] Critical error: unknown error in plugin", 00h
	_sErr_RedeclaredVar	db	"[22] Critical error: variables redeclared", 00h
	_sErr_ForDeclaration	db	"[23] Critical error: missing ", 22h, "(", 22h, " in for declaration", 00h
	_sErr_UnkCallback	db	"[24] Critical error: unknown callback type", 00h

	_bFCLL			db	40h		;; locals
	_bFCLLMAX		db	40h		;; locals max

	_dFCPL			dd	offset 	_bFuncPostEX		;; postix index - pointer

	_lDefXEX		dd	offset _lDefX
	_xForDefValEX		dd	offset _xForDefVal

	_sCodeConst		db	"true", 00h
				db	"false", 00h
				db	"function", 00h
				db	"Player", 00h
				db	"GetRandomInt", 00h
				db	"GetRandomReal", 00h
				db	"Deg2Rad", 00h
				db	"Rad2Deg", 00h
				db	"Sin", 00h
				db	"Cos", 00h
				db	"Tan", 00h
				db	"Asin", 00h
				db	"Acos", 00h
				db	"Atan", 00h
				db	"Atan2", 00h
				db	"SquareRoot", 00h
				db	"Pow", 00h
				db	"I2R", 00h
				db	"R2I", 00h
				db	"I2S", 00h
				db	"R2S", 00h
				db	"R2SW", 00h
				db	"S2I", 00h
				db	"S2R", 00h
				db	"SubString", 00h
				db	"StringLength", 00h
				db	"StringCase", 00h
				db	"Condition", 00h
				db	"Filter", 00h

				db	00h

	_sCodeNXFunc		db	"laeRmodnaRteG", 00h
				db	"tnImodnaRteG", 00h
				db	"reyalP", 00h
				db	"reggirTetaerC", 00h
				db	"noigeRetaerC", 00h
				db	"noitacoL", 00h
				db	"tceR", 00h
				db	"ecroFetaerC", 00h
				db	"puorGetaerC", 00h
				db	"remiTetaerC", 00h

				db	00h

	_sBool			db	"boolean", 00h


;;				null terminated string, arg count, type id
_cbt_onInit			equ	00h
_cbt_onUnitAttacked		equ	01h
_cbt_onUnitDeath		equ	02h
_cbt_onUnitDecay		equ	03h
_cbt_onUnitIssuedOrder		equ	04h
_cbt_onUnitIssuedPointOrder	equ	05h
_cbt_onUnitIssuedTargetOrder	equ	06h
_cbt_onHeroLevel		equ	07h
_cbt_onHeroSkill		equ	08h
_cbt_onUnitSpellChannel		equ	09h
_cbt_onUnitSpellCast		equ	0ah
_cbt_onUnitSpellEffect		equ	0bh
_cbt_onUnitSpellFinish		equ	0ch
_cbt_onUnitSpellEndcast		equ	0dh
_cbt_onGameLoad			equ	0eh
_cbt_onGameSave			equ	0fh

_xCallbacksTypes	db	"onInit", 			00h, 00h, _cbt_onInit
			db	"onUnitAttacked", 		00h, 00h, _cbt_onUnitAttacked
			db	"onUnitDeath", 			00h, 00h, _cbt_onUnitDeath
			db	"onUnitDecay", 			00h, 00h, _cbt_onUnitDecay
			db	"onUnitIssuedOrder", 		00h, 01h, _cbt_onUnitIssuedOrder
			db	"onUnitIssuedPointOrder", 	00h, 01h, _cbt_onUnitIssuedPointOrder
			db	"onUnitIssuedTargetOrder", 	00h, 01h, _cbt_onUnitIssuedTargetOrder
			db	"onHeroLevel", 			00h, 00h, _cbt_onHeroLevel
			db	"onHeroSkill", 			00h, 01h, _cbt_onHeroSkill
			db	"onUnitSpellChannel", 		00h, 01h, _cbt_onUnitSpellChannel
			db	"onUnitSpellCast", 		00h, 01h, _cbt_onUnitSpellCast
			db	"onUnitSpellEffect", 		00h, 01h, _cbt_onUnitSpellEffect
			db	"onUnitSpellFinish", 		00h, 01h, _cbt_onUnitSpellFinish
			db	"onUnitSpellEndcast", 		00h, 01h, _cbt_onUnitSpellEndcast
			db	"onGameLoad", 			00h, 00h, _cbt_onGameLoad
			db	"onGameSave", 			00h, 00h, _cbt_onGameSave
			db	00h, 00h, 00h, 00h

_dCallbackListPnt	dd	offset _dCallbackList - _dCBSize
_dCallbackListNext	dd	0ffffffffh

_sCallbackReg_00_Str	equ	$
			db	"library cjCallbacksRegestrationHack initializer cjCallbacksRegestration__init0", 0dh, 0ah
			db	"function cjCallbacksRegestration__init0 takes nothing returns nothing", 0dh, 0ah
			db	"//# optional", 0dh, 0ah
			db	"call ExecuteFunc(", 22h, "cjCallbacksRegestration__initX", 22h, ")", 0dh, 0ah
			db	"endfunction", 0dh, 0ah
			db	"endlibrary", 0dh, 0ah
			db	"scope cjCallbacksRegestration", 0dh, 0ah
_sCallbackReg_00_End	equ	$

_sCallbackReg_01_Str	equ	$
			db	"private function reg_** takes nothing returns nothing", 0dh, 0ah
_sCallbackReg_01_End	equ	$

_sCallbackReg_Order_Str	equ	$
			db	"local integer i=GetIssuedOrderId()", 0dh, 0ah
_sCallbackReg_Order_End	equ	$

_sCallbackReg_Skill_Str	equ	$
			db	"local integer i=GetLearnedSkill()", 0dh, 0ah
_sCallbackReg_Skill_End	equ	$

_sCallbackReg_Spell_Str	equ	$
			db	"local integer i=GetSpellAbilityId()", 0dh, 0ah
_sCallbackReg_Spell_End	equ	$

_sCallbackReg_02_Str	equ	$
			db	"function cjCallbacksRegestration__initX takes nothing returns nothing", 0dh, 0ah
_sCallbackReg_02_End	equ	$

_sCallbackReg_03_Str	equ	$
			db	"local integer i=0", 0dh, 0ah, "local player p", 0dh, 0ah, "loop", 0dh, 0ah, "set p=Player(i)", 0dh, 0ah
_sCallbackReg_03_End	equ	$

_sCallbackReg_04_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_01, p, EVENT_PLAYER_UNIT_ATTACKED, null)", 0dh, 0ah
_sCallbackReg_04_End	equ	$

_sCallbackReg_05_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_02, p, EVENT_PLAYER_UNIT_DEATH, null)", 0dh, 0ah
_sCallbackReg_05_End	equ	$

_sCallbackReg_06_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_03, p, EVENT_PLAYER_UNIT_DECAY, null)", 0dh, 0ah
_sCallbackReg_06_End	equ	$

_sCallbackReg_07_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_04, p, EVENT_PLAYER_UNIT_ISSUED_ORDER, null)", 0dh, 0ah
_sCallbackReg_07_End	equ	$

_sCallbackReg_08_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_05, p, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, null)", 0dh, 0ah
_sCallbackReg_08_End	equ	$

_sCallbackReg_09_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_06, p, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, null)", 0dh, 0ah
_sCallbackReg_09_End	equ	$

_sCallbackReg_0a_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_07, p, EVENT_PLAYER_HERO_LEVEL, null)", 0dh, 0ah
_sCallbackReg_0a_End	equ	$

_sCallbackReg_0b_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_08, p, EVENT_PLAYER_HERO_SKILL, null)", 0dh, 0ah
_sCallbackReg_0b_End	equ	$

_sCallbackReg_0c_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_09, p, EVENT_PLAYER_UNIT_SPELL_CHANNEL, null)", 0dh, 0ah
_sCallbackReg_0c_End	equ	$

_sCallbackReg_0d_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_0a, p, EVENT_PLAYER_UNIT_SPELL_CAST, null)", 0dh, 0ah
_sCallbackReg_0d_End	equ	$

_sCallbackReg_0e_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_0b, p, EVENT_PLAYER_UNIT_SPELL_EFFECT, null)", 0dh, 0ah
_sCallbackReg_0e_End	equ	$

_sCallbackReg_0f_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_0c, p, EVENT_PLAYER_UNIT_SPELL_FINISH, null)", 0dh, 0ah
_sCallbackReg_0f_End	equ	$

_sCallbackReg_10_Str	equ	$
			db	"call TriggerRegisterPlayerUnitEvent(cj_callback_trg_0d, p, EVENT_PLAYER_UNIT_SPELL_ENDCAST, null)", 0dh, 0ah
_sCallbackReg_10_End	equ	$

_sCallbackReg_11_Str	equ	$
			db	"call TriggerAddAction(cj_callback_trg_**, function reg_**)", 0dh, 0ah
_sCallbackReg_11_End	equ	$

_sCallbackReg_12_Str	equ	$
			db	"call TriggerRegisterGameEvent(cj_callback_trg_0e, EVENT_GAME_LOADED)", 0dh ,0ah
_sCallbackReg_12_End	equ	$

_sCallbackReg_13_Str	equ	$
			db	"call TriggerRegisterGameEvent(cj_callback_trg_0e, EVENT_GAME_SAVE)", 0dh ,0ah
_sCallbackReg_13_End	equ	$

_sCallbackReg_14_Str	equ	$
			db	"trigger cj_callback_trg_**=CreateTrigger()", 0dh, 0ah
_sCallbackReg_14_End	equ	$

_sCallbackReg_15_Str	equ	$
			db	"set i=i+1", 0dh, 0ah
			db	"exitwhen i==16", 0dh, 0ah
			db	"endloop", 0dh, 0ah
_sCallbackReg_15_End	equ	$

_sTempMacroIn		db	"macro_preprocessing_in.j", 00h
_sTempMacroOut		db	"macro_preprocessing_out.j", 00h
_sTempMacroCJ		db	"cj_null.j", 00h
_sTempMacroBJ		db	"bj_null.j", 00h

_sEndMacroExStr		db	"cjpreprocendmacrodetectionen_8H4f855w9Ioen68EgE337gy", 0dh, 0ah
_sEndMacroExStrSize	equ	$ - offset _sEndMacroExStr

_sVXPreProcCmdLine	db	"--nooptimize --macromode cj_null.j bj_null.j macro_preprocessing_in.j macro_preprocessing_out.j"

_sGroupCopyCode		db	"globals", 0dh, 0ah
			db	"group cj_tmpgr_copy_nw509ert7", 0dh, 0ah
			db	"endglobals", 0dh, 0ah
			db	"function cj_group_copy_75hJKJ3745gf takes nothing returns nothing", 0dh, 0ah
			db	"//# optional", 0dh, 0ah
			db	"call GroupAddUnit(cj_tmpgr_copy_nw509ert7,GetEnumUnit())", 0dh, 0ah
			db	"endfunction", 0dh ,0ah
_sGroupCopyCodeSize	equ	$ - offset _sGroupCopyCode

;;_dAonBlockBaseFuncS	dd	0ffffffffh	;; base anon block's function
;;_dAonBlockBaseFuncE	dd	0ffffffffh

	;;
	;; 0...9 ; A...Z ; _ ; a...z
	;;

	_bAscii_00 \
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h
	db	01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 00h, 00h, 00h, 00h, 01h
	db	00h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h
	db	01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

	;;
	;; 0...9 ; A...Z ; _ ; a...z ; , and .
	;;

	_bAscii_03 \
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 01h, 00h
	db	01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 00h, 00h, 00h, 00h, 00h
	db	00h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h
	db	01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 00h, 00h, 00h, 00h, 01h
	db	00h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h
	db	01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

	;;
	;; 0...9 ; A...F ; a...f --- hex table
	;;

	_bAscii_05 \
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	30h, 30h, 30h, 30h, 30h, 30h, 30h, 30h, 30h, 30h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 37h, 37h, 37h, 37h, 37h, 37h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 57h, 57h, 57h, 57h, 57h, 57h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h

	;;
	;; convert int to string (hex)
	;;

	_bIntToHexStr \
	db	"000102030405060708090a0b0c0d0e0f"
	db	"101112131415161718191a1b1c1d1e1f"
	db	"202122232425262728292a2b2c2d2e2f"
	db	"303132333435363738393a3b3c3d3e3f"
	db	"404142434445464748494a4b4c4d4e4f"
	db	"505152535455565758595a5b5c5d5e5f"
	db	"606162636465666768696a6b6c6d6e6f"
	db	"707172737475767778797a7b7c7d7e7f"
	db	"808182838485868788898a8b8c8d8e8f"
	db	"909192939495969798999a9b9c9d9e9f"
	db	"a0a1a2a3a4a5a6a7a8a9aaabacadaeaf"
	db	"b0b1b2b3b4b5b6b7b8b9babbbcbdbebf"
	db	"c0c1c2c3c4c5c6c7c8c9cacbcccdcecf"
	db	"d0d1d2d3d4d5d6d7d8d9dadbdcdddedf"
	db	"e0e1e2e3e4e5e6e7e8e9eaebecedeeef"
	db	"f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
	;;

	;;
	;; remove bs 00
	;;
	;;	00h,       01h,       02h,       03h,       04h,       05h,       06h,       07h,       08h,       09h,       0ah,       0bh,       0ch,       0dh,       0eh,       0fh
	_bAscii_01 \
	db	_lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00	;; 00h - 0fh
	db	_lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00	;; 10h - 1fh
	db	_lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_02, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_01, _lCRDD_01, _lCRDD_00, _lCRDD_01, _lCRDD_02, _lCRDD_01 	;; 20h - 2fh
	db	_lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00	;; 30h - 3fh
	db	_lCRDD_00, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02	;; 40h - 4fh
	db	_lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00	;; 50h - 5fh
	db	_lCRDD_00, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02	;; 60h - 6fh
	db	_lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_02, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00	;; 70h - 7fh

	_lCRDD_00	equ		offset _lCRScanBS - _lBSRemBase
	_lCRDD_01	equ		offset _lCRIncDec - _lBSRemBase
	_lCRDD_02	equ		offset _lCRBSNext - _lBSRemBase
	_lCRDD_03	equ		offset _lCRBSAdd  - _lBSRemBase

	;;
	;; remove bs 01
	;;
	_bAscii_02 \
	db	_lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00
	db	_lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00
	db	_lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_03, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_03, _lCRDD_00
	db	_lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00
	db	_lCRDD_00, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03
	db	_lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_03
	db	_lCRDD_00, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03
	db	_lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_03, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00, _lCRDD_00

	;;----------------
	;; for debug
	;;_sDbgSrc	db		"%d", 00h
	;;_sDbgDest	db		20h	dup(00h)
	;;----------------

;;-------------------------------------------------------------------------
.data?

	_xForDefVal		db	2000h	dup(?)	;; used in #for

	_dAddrDefArg		dd	0100h	dup(?)	;; def args addr

	_xInclArg		dd	80h	dup(?)

	_sTime			db	09h	dup(?)
	_sDate			db	0bh	dup(?)
	_dCounterV		dd	?

	_bCodeSys		db	?	;; 0 = not return and not if construction
	_bCodePosOp		db	?	;; 0 = no post operation (++ or --)

	_bTempBool		db	?
	_bTempType		db	?

	_dBuffer		dd	?	;; buffer
	_hOLMacro		dd	?	;; used in macro overloading

	_dGuiFont		dd	?
	_dWWWFont		dd	?	;; used in string preprocessor

	_fScr			dd	?

	_fScr_BJ		dd	?
	_fScr_CJ		dd	?

	_dUndefPnt		dd	?	;; script position in undefined

	_hWnd			dd	?
	_hPrg			dd	?
	_hList			dd	?
	_hBtn			dd	?	;; used in #if ...

	_hTrd			dd	?

	_dStackPos		dd	?
	_dPreStackPos		dd	?

	_dErrorCodeStart	dd	?	;; edi position of bad code
	_xErrorTable		dd	08h	dup(?)

	_dStdCursor		dd	?
	_dExCursor		dd	?

	_sMapPath		db	0200h	dup(?)
	_dMapPathToSX		equ	0200h
	_sMapPathSX		db	0200h	dup(?)	;; for plugins
	_dMapPathToEX		equ	0400h
	_sMapPathEX		db	0200h	dup(?)	;; for include
	_dMapPathEnd		dd	?

	_sCurrDir		db	0200h	dup(?)
	_dCurrDirEnd		dd	?

	align			10h	
	_lDefX			dd	00010000h	dup(?)	;; 80h bits defBlocks

	_dScopeIn		dd	0100h	dup(?)
	_dScopeOut		dd	0100h	dup(?)

	_dDefTable		dd	0080h	dup(?)		;; used in f'n'p	;; used in code romoning (variables)
	_dDefTableEX		dd	0080h	dup(?)					;; used in code romoning (function)

	_dDefArgs		dd	0080h	dup(?)

	_xPntStr		PAINTSTRUCT	 <?>

	_dFCL			dd	?		;; locals	
	_dFCB			dd	?		;; base code of function

	_dBCP			dd	?		;; base code pointer

	align			10h
	_bFuncCodeLocals	db	00010000h	dup(?)	;; locals			;; used also in string preprocessor	;; used in guard	;; used in removing unused code - variables
	align			10h
	_bFuncCodeBase		db	000a0000h	dup(?)	;; base code of function	;; used also in string preprocessor				;; used in removing unused code - functions
	_bFuncCodeOneLine	db	00004000h	dup(?)	;; one line of func code
	_bFuncPostEX		db	00000200h	dup(?)	;; postix index

	_xEnumStr		db	00008000h	dup(?)	;; enum string
	_xEnumTable		dd	00008000h	dup(?)	;; enum structs			;; used also in #if
	_xEnumLabel		dd	00000100h	dup(?)	;; enum labels

	_xSysTime		dw	08h		dup(?)	;; system time

	_dVarParams		dd	?		;; variable group params

	_dLastFuncName		dd	?		;; used in FUNCNAME macro
	_dLastStructName	dd	?		;; used in FUNCNAME macro

	_bIsPPCEn		db	?		;; in #if/#endif block

	_xSynDesc		dd	0400h		dup(?)	;; ex syntax (zinc and boa) descriptor

	_bStrXX			db	?		;; uses to add bs at strings
	_bOprInFunc		db	?		;; is function/method optional

	_bArrayFX		db	?		;; is array

	_dAnonFuncCnt		dd	?		;; anonym function counter
	_dAnonBlockTable	dd	0800h	dup(?)

				dd	04h	dup(?)
	_dAnonFuncTable		dd	2000h	dup(?)

	_dFNPAnonESITemp	dd	?		;; save esi in anon function parsing

	_dFinalParseOffset	dd	?		;; code without anon function

	_dCStructName		dd	?		;; curr struct name (used in anon function)

	_dForSrt		dd	?		;; temp, used in #for

	_bAdicIntMode		db	?		;; use int 03h - adic debug mode

	_bLocalsAutoFlush	db	?		;; automatic flush locals variables

	_dInFuncBlockMax	dd	?		;; in func block ID, used in locals processing

	_dInFuncBlockPnt	dd	?		;; in func block pointer, used as stack pointer
	_dInFuncBlockStack	dd	0400h	dup(?)	;; in func block stack

	_dGeneratedLocalsID	dd	?		;; generated locals variables id

				db	?		;; need for _sCJGenGlobalsTypes
	_sCJGenGlobalsTypes	db	0800h	dup(?)	;; generated globals types

	_sFuncType		dd	?		;; returns ***

	_dLocalsOffset		dd	?		;; addr of locals
	_dCodeOffset		dd	?		;; addr of code

	_bALFReturnExpr		db	?		;; is locals flushed before return expression
	_bALFReturnExprUse	db	?		;; is we use it in this return
	_bALFReturnLast		db	?		;; return expr; endfunction

	_bWhileCondCorrect	db	?		;; add in f'n'p ")" for while expression

	_bIgnoreCustomBJ	db	?		;; flag in cmd line
	_bIgnoreCustomCJ	db	?		;;

	_bPreForScope		db	?		;; used in preparing for loop
	_bPreForArgs		db	?		;;

	_dFreeForGroupPnt	dd	?		;; pointer to free group
	_dFreeForGroup		dd	0200h	dup(?)	;; free group stack

	_bInVblock		db	?		;; is in vblock
	_bLocGenPreInit		db	?
	_bFuncCodeNop		db	?

	_dFlushLocalsStackPos	dd	?
	_dFlushLocalsExBlock	dd	?		;; 01 - normal block (root or if), 02 - loop

	_dCallbackList		db	0800h * 10h	dup(?) ;; _dCBSize = 10h

_bCallbackArgFam	dw	?
_bCallbackArgPickType	db	?

	_bIsExist_BaseOffset			equ	$
	_bIsExist_onInit			db	?
						db	?	;; is have arg?
	_bIsExist_onUnitAttacked		db	?
						db	?
	_bIsExist_onUnitDeath			db	?
						db	?
	_bIsExist_onUnitDecay			db	?
						db	?
	_bIsExist_onUnitIssuedOrder		db	?
						db	?
	_bIsExist_onUnitIssuedPointOrder	db	?
						db	?
	_bIsExist_onUnitIssuedTargetOrder	db	?
						db	?
	_bIsExist_onHeroLevel			db	?
						db	?
	_bIsExist_onHeroSkill			db	?
						db	?
	_bIsExist_onUnitSpellChannel		db	?
						db	?
	_bIsExist_onUnitSpellCast		db	?
						db	?
	_bIsExist_onUnitSpellEffect		db	?
						db	?
	_bIsExist_onUnitSpellFinish		db	?
						db	?
	_bIsExist_onUnitSpellEndcast		db	?
						db	?
	_bIsExist_onGameLoad			db	?
						db	?
	_bIsExist_onGameSave			db	?
						db	?
	_bIsExist_BaseOffsetEnd			equ	$

	_bFlushFlagBlock			db	?

	_dVJassParserAdd			dd	?
	_bUseMacroPrePorc			db	?

	_hTempMacroIn				dd	?

	_bMacroPreIsExist			db	?

	_xPrcInfo				PROCESS_INFORMATION	<?>
	_xStrInfo				STARTUPINFO		<?>

	_dMacroPreMem				dd	?
	_dMacroPrePnt				dd	?	;; next run

	_dMacroPreESI				dd	?	;; save esi in #R

;_bCallbackTempType			db	?

	;;----------------
	;; custom
	_dCstCodeStart		dd	?
	_dCstCodeSize		dd	?
	_dCstCodeDest		dd	?
	_dCstCodeFinalSize	dd	?
	_sCstArguments		dd	?
	_sCstMapPath		dd	?

	_sCstPlugPath		db	80h	dup(?)

	_sCstArgNull		dd	?

	_dCstMemHndl		dd	?
	_dCstMemAddr		dd	?

	_dCstEsi		dd	?
	;;----------------

;;-------------------------------------------------------------------------
.code

	_next	equ	@f
	_prew	equ	@b
	_lbl	equ	@@

	;;----------------
	;; debug print reg
	_printReg macro reg
	pushad
	
	push	reg
	push	offset _sDbgSrc
	push	offset _sDbgDest
	
	call	_imp__wsprintfA
	add	esp,			0ch
	
	push	00h
	push	00h
	push	offset _sDbgDest
	push	00h
	call	_imp__MessageBoxA@16	
	
	popad
	endm
	;;----------------

	;;-------------------------------------------------------------------------

	;;	struct defBlock		10h
	;;
	;;	_sDFLabel	dd	;; adress of string [define label]
	;;	_sDFValue	dd	;; adress of string [define value]
	;;	_sDFScope	dd	;; scope id
	;;	_dValueLenght	dd	;; arg count
		_dDFSize	equ	10h

	;;	struct errorTable	10h
	;;
	;;	_hString	dd	;; offset of info string
	;;	_hStarsS	dd	;; selection end
	;;	_hEndS		dd	;; selection start
	;;			dd	;; not used

	;;	struck Callback		0dh
	;;
	;;	_hsName		dd	;; func name
	;;	_hsStructName	dd	;; struct name
	;;	_dArgAddr	dd	;; pointer to args
	;;	_bType		db	;; type id
	;;	_wFamily	dw	;; args block - 0, 1...fffe (ffff - removed)
	;;	_bArgEx		db	;; functions int the arg
		_dCBSize	equ	10h

	;;	struct enumLabels	0ch
	;;
	;;	_hName		dd	;; pointer to string
	;;	_hNegBase	dd	;; negative enumTable
	;;	_hPosBase	dd	;; positive enumTable

	;;	struct enumTable	0ch
	;;
	;;	_hMin		dd
	;;	_hMax		dd
	;;	_hNext		dd	;; next enumTable

	;;	struct globVar/func	10h
	;;
	;;	_hAddrS		dd	;; address - start
	;;	_hAddrE		dd	;; end
	;;	_hName		dd	;; var Name
	;;	_wCnt		dw	;; counter
	;;	_		db
	;;	_		db

	;;	struct funcCode		10h
	;;
	;;	_hAddrS		dd	;; address - start
	;;	_hAddrE		dd	;; end
	;;	_hName		dd	;; var Name
	;;	_wCnt		dw	;; counter
	;;	_bIsChecked	db	;; is checked
	;;	_		db

	;;	struct anonFunc		10h
	;;
	;;	_dAddrS		dd	;; non parsed address - start
	;;	_dAddrE		dd	;; non parsed address - end
	;;	_dName		dd	;; function name ;; addr of "endfunction" str, final
	;;	_dFinalName	dd	;; addr of "function" str, final

	;;	struct anonBlock	04h
	;;
	;;	_dAddrS		dd	;; addr - start

	;;-------------------------------------------------------------------------

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; proc optimize
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_lMapOptimizeCode:

	;;----------------
	mov	_dCurrStr,			offset _sProg_06
	mov	eax,				10h
	call	_lSetProg
	;;----------------

	;;----------------
	;; code preparation
	xor	ebx,			ebx	;; use bl only
	jmp	_lOptPreStartEX
	_lOptPreStart:
	movsb
	_lOptPreStartEX:
	mov	eax,			dword ptr [esi]

		;;----------------
		;; nl
		cmp	ax,			0a0dh	;; nl
		jne	_next

		_lOptAddNLEX:
		cmp	byte ptr [edi-01h],	0ah	;; nl
		jne	_lOptAddNL
		add	esi,			02h
		jmp	_lOptPreStartEX

		_lOptAddNL:
		mov	byte ptr [edi],		0ah	;; nl
		add	esi,			02h
		inc	edi
		jmp	_lOptPreStartEX
		;;----------------

		;;----------------
		;; comments
		_lbl:
		cmp	ax,			2f2fh		;; //
		jne	_next

		cmp	byte ptr [_dWarVerSL],	00h
		je	_lOptComm

		cmp	eax,			20232f2fh	;; //#_
		jne	_lOptComm
		cmp	dword ptr [esi+04h],	6974706fh	;; opti
		jne	_lOptComm
		cmp	dword ptr [esi+08h],	6c616e6fh	;; onal
		jne	_lOptComm
		cmp	word ptr [esi+0ch],	0a0dh		;; nl
		jne	_lOptComm

;;		mov	word ptr [edi],		0a02h
mov	byte ptr [edi],			02h
		add	esi,			0eh
;;		add	edi,			02h
inc	edi
		jmp	_lOptPreStartEX

		_lOptComm:
		inc	esi
		cmp	byte ptr [esi],		00h
		je	_lOptPreEnd
		cmp	word ptr [esi],		0a0dh
		jne	_lOptComm
		jmp	_lOptAddNLEX
		;;----------------

		;;----------------
		;; strings
		_lbl:
		cmp	eax,			2b202222h	;; "" +
		jne	_next
		add	esi,			04h
		jmp	_lOptPreStartEX

		_lbl:
		cmp	eax,			2222202bh	;; + ""
		jne	_next
		add	esi,			04h
		jmp	_lOptPreStartEX

		_lbl:
		cmp	eax,			202b2022h	;; " + 
		jne	_next
		cmp	byte ptr [esi+04h],	22h		;; "
		jne	_next
		add	esi,			05h
		jmp	_lOptPreStartEX

		_lbl:
		cmp	al,			22h		;; "
		jne	_next

		_lOptStr:
		movsb
		_lOptStrSX:
		cmp	byte ptr [esi],		5ch		;; \ 
		je	_lOptStrEX
		cmp	byte ptr [esi],		22h		;; "
		jne	_lOptStr
		jmp	_lOptPreStart

		_lOptStrEX:
		movsw
		jmp	_lOptStrSX
		;;----------------

		;;----------------
		;; bs
		_lbl:
		cmp	al,				20h	;; bs
		jne	_next
		jmp	_lOptRemoveBS

		_lbl:
		cmp	al,				09h	;; tab
		jne	_next

		_lOptRemoveBS:
		;; prew char
		mov	bl,				byte ptr [edi-01h]
		cmp	byte ptr [_bAscii_00+ebx],	bh	;; bh = 00h
		jne	_lOptBS

		inc	esi
		jmp	_lOptPreStartEX

		;; next char
		_lOptBS:
		mov	bl,				ah
		cmp	byte ptr [_bAscii_00+ebx],	bh	;; bh = 00h
		jne	_lOptPreStart

		inc	esi
		jmp	_lOptPreStartEX
		;;----------------

		;;----------------
		;; null
		_lbl:
		cmp	al,			00h	;; null
		jne	_lOptPreStart

		cmp	byte ptr [edi-01h],	0ah	;; nl
		jne	_lOptPreEnd
		dec	edi
		mov	byte ptr [edi],		00h	;; null

		;;----------------

	_lOptPreEnd:
	;;----------------

	;;----------------
	mov	_dCurrStr,			offset _sProg_07
	mov	eax,				20h
	call	_lSetProg
	;;----------------

	;;----------------
	;; callback initialization fix
	push	esi
	add	esi,				04h

	_lOptCBFix:
	cmp	dword ptr [esi],		"llac"
	jne	_lOptCBFix_GetNextLine
	cmp	dword ptr [esi + 04h],		"exE "
	jne	_lOptCBFix_GetNextLine
	cmp	dword ptr [esi + 08h],		"etuc"
	jne	_lOptCBFix_GetNextLine
	cmp	dword ptr [esi + 0ch],		"cnuF"
	jne	_lOptCBFix_GetNextLine
	cmp	dword ptr [esi + 10h],		6a632228h	;; ("cj
	jne	_lOptCBFix_GetNextLine
	cmp	dword ptr [esi + 14h],		"llaC"
	jne	_lOptCBFix_GetNextLine
	cmp	dword ptr [esi + 18h],		"kcab"
	jne	_lOptCBFix_GetNextLine
	cmp	dword ptr [esi + 1ch],		"geRs"
	jne	_lOptCBFix_GetNextLine
	cmp	dword ptr [esi + 20h],		"rtse"
	jne	_lOptCBFix_GetNextLine
	cmp	dword ptr [esi + 24h],		"oita"
	jne	_lOptCBFix_GetNextLine
	cmp	dword ptr [esi + 28h],		"i__n"
	jne	_lOptCBFix_GetNextLine
	cmp	dword ptr [esi + 2ch],		"0tin"
	jne	_lOptCBFix_GetNextLine
	cmp	word ptr [esi + 30h],		2922h		;; ")
	jne	_lOptCBFix_GetNextLine
	cmp	byte ptr [esi + 32h],		0ah
	jne	_lOptCBFix_GetNextLine
	mov	byte ptr [esi + 2fh],		"X"
	jmp	_lOptCBFix_End

	_lOptCBFix_GetNextLineEx:
	inc	esi
	_lOptCBFix_GetNextLine:
	cmp	byte ptr [esi],			00h
	je	_lOptCBFix_End
	cmp	byte ptr [esi],			0ah
	jne	_lOptCBFix_GetNextLineEx
	inc	esi
	jmp	_lOptCBFix

	_lOptCBFix_End:
	pop	esi
	;;----------------

	;;----------------
	;; removing unused code
	cmp	dword ptr [_dWarVerSL],			00h
	jne	_next

	add	esi,					04h
	jmp	_lOptCC_NoRemove

	_lbl:
	push	edi
	push	esi


		;;----------------
		;; variables
		mov	ebx,				offset _bFuncCodeLocals
		add	esi,				0ch	;; globals_

		_lOptCC_VarStr:
		cmp	dword ptr [esi],		67646e65h	;; endg
		jne	_lOptCC_VarAdd
		cmp	dword ptr [esi+04h],		61626f6ch	;; loba
		jne	_lOptCC_VarAdd
		cmp	word ptr [esi+08h],		736ch		;; ls
		jne	_lOptCC_VarAdd
		cmp	byte ptr [esi+0ah],		0ah		;; nl
		jne	_lOptCC_VarAdd

		add	esi,				0bh

			;;----------------
			;; go to sort
			push	esi			;; store esi before sort
			cmp	ebx,			offset _bFuncCodeLocals+10h
			jbe	_lOptCC_VarNoSort

			mov	ebp,			offset _bFuncCodeLocals
			sub	ebx,			ebp
			call	_lOptCC_SortIn

			_lOptCC_VarNoSort:
			mov	eax,			offset _bFuncCodeLocals-10h
			mov	edx,			offset _dDefTable
			push	offset _lOptCC_Func
			jmp	_lOptCC_BuildIn
			;;----------------

		_lOptCC_VarAdd:
		mov	dword ptr [ebx],		esi		;; start

		cmp	dword ptr [esi],		736e6f63h	;; cons
		jne	_next
		cmp	dword ptr [esi+04h],		746e6174h	;; tant
		jne	_next
		cmp	byte ptr [esi+08h],		20h		;; bs
		add	esi,				09h		;; remove constant
		_lbl:
		inc	esi
		cmp	byte ptr [esi],			20h		;; bs
		jne	_prew
		inc	esi

		cmp	dword ptr [esi],		61727261h	;; arra
		jne	_next
		cmp	word ptr [esi+04h],		2079h		;; y_
		jne	_next
		add	esi,				06h
		_lbl:

		mov	dword ptr [ebx+08h],		esi		;; var name

		_lbl:
		inc	esi
		cmp	byte ptr [esi],			0ah		;; nl
		jne	_prew
		inc	esi
		mov	dword ptr [ebx+04h],		esi		;; end
		add	ebx,				10h

		jmp	_lOptCC_VarStr
		;;----------------

		;;----------------
		;; functions
		_lOptCC_Func:
		pop	esi
		mov	ebx,				offset _bFuncCodeBase

		_lOptCC_FuncStr:
		cmp	byte ptr [esi],			00h
		jne	_lOptCC_FuncAdd

			;;----------------
			;; go to sort
			cmp	ebx,			offset _bFuncCodeBase+10h
			jbe	_lOptCC_FuncNoSort

			mov	ebp,			offset _bFuncCodeBase
			sub	ebx,			ebp
			call	_lOptCC_SortIn

			_lOptCC_FuncNoSort:
			mov	eax,			offset _bFuncCodeBase-10h
			mov	edx,			offset _dDefTableEX
			push	offset _lOptCC_ChStr
			jmp	_lOptCC_BuildIn
			;;----------------

		_lOptCC_FuncAdd:
		mov	dword ptr [ebx],		esi
		cmp	dword ptr [esi],		736e6f63h	;; cons
		jne	_next
		add	esi,				09h

		_lbl:

			;;----------------
			;; native ?
			cmp	dword ptr [esi],		6974616eh	;; nati
			jne	_next

			add	esi,				07h
			mov	dword ptr [ebx+08h],		esi
			mov	byte ptr [ebx+0eh],		01h

			_lOptCC_NatArg:
			inc	esi
			cmp	dword ptr [esi],		6b617420h	;; _tak
			jne	_lOptCC_NatArg

			cmp	dword ptr [esi+07h],		68746f6eh	;; noth
			jne	_lOptCC_NatGetEnd
			cmp	dword ptr [esi+0bh],		20676e69h	;; ing_
			jne	_lOptCC_NatGetEnd

			mov	word ptr [ebx+0ch],		01h

			_lOptCC_NatGetEnd:
			inc	esi
			cmp	byte ptr [esi-01h],		0ah		;; nl
			jne	_lOptCC_NatGetEnd
			mov	dword ptr [ebx+04h],		esi

			add	ebx,				10h
			cmp	byte ptr [esi],			02h
			jne	_lOptCC_FuncStr

			inc	esi
			mov	word ptr [ebx-04h],		00h
			jmp	_lOptCC_FuncStr
			;;----------------

		_lbl:
		add	esi,				09h
		mov	dword ptr [ebx+08h],		esi

		_lOptCC_FuncArg:
		inc	esi
		cmp	dword ptr [esi],		6b617420h	;; _tak
		jne	_lOptCC_FuncArg

		cmp	dword ptr [esi+07h],		68746f6eh	;; noth
		jne	_lOptCC_FuncGetEnd
		cmp	dword ptr [esi+0bh],		20676e69h	;; ing_
		jne	_lOptCC_FuncGetEnd

			;;----------------
			;; is optional
			_lOptCC_FuncIsOpt:
			inc	esi
			cmp	byte ptr [esi],			0ah		;; nl
			jne	_lOptCC_FuncIsOpt

			cmp	byte ptr [esi+01h],		02h
			je	_lOptCC_FuncGetEndEX

			mov	word ptr [ebx+0ch],		01h
			jmp	_lOptCC_FuncGetEndEX
			;;----------------

		_lOptCC_FuncGetEnd:
		inc	esi
		_lOptCC_FuncGetEndEX:
cmp	dword ptr [esi],		646e6502h	;; _end
je	_lOptCC_FuncGetEndOX
		cmp	dword ptr [esi],		646e650ah	;; _end
		jne	_lOptCC_FuncGetEnd
_lOptCC_FuncGetEndOX:
		cmp	dword ptr [esi+04h],		636e7566h	;; func
		jne	_lOptCC_FuncGetEnd

		add	esi,				0dh
		mov	dword ptr [ebx+04h],		esi
		add	ebx,				10h
		jmp	_lOptCC_FuncStr
		;;----------------

		;;----------------
		;; sort
			;;----------------
			;; set step
			_lOptCC_SortIn:
			mov	eax,			offset _dSortSteps-04h
			_lbl:
			add	eax,			04h
			mov	ecx,			dword ptr [eax+04h]
			lea	ecx,			dword ptr [ecx+ecx*02h]
			cmp	ebx,			ecx
			jg	_prew
			;;----------------

		_lOptCC_SortStr:
		mov	ecx,			dword ptr [eax]
		lea	ebx,			dword ptr [ebp+ecx]

		_lOptCC_SortGo:
		mov	esi,			dword ptr [ebx+08h]
		mov	edi,			ebx
		mov	dl,			byte ptr [esi]
		movaps	xmm1,			[ebx]

		_lbl:
		sub	edi,			ecx
		cmp	edi,			ebp
		jb	_lOptCC_SortNext
		mov	esi,			dword ptr [edi+08h]
		cmp	byte ptr [esi],		dl
		jb	_lOptCC_SortNext

		movaps	xmm0,			[edi]
		movaps	[edi+ecx],		xmm0

		jmp	_prew

		_lOptCC_SortNext:
		movaps	[edi+ecx],		xmm1
		add	ebx,			10h
		cmp	dword ptr [ebx],	00h
		jnz	_lOptCC_SortGo

		sub	eax,			04h
		cmp	eax,			offset _dSortSteps-04h
		jne	_lOptCC_SortStr

		_lOptCC_SortEnd:
		retn
		;;----------------

		;;----------------
		;; build table
		_lOptCC_BuildIn:
		xor	ebx,			ebx
		xor	ecx,			ecx

		_lOptCC_VarDT:
		add	eax,			10h
		cmp	dword ptr [eax],	00h
		je	_lOptCC_VarDTEnd

		mov	ebp,			dword ptr [eax+08h]
		mov	bl,			byte ptr [ebp]
		cmp	cl,			bl
		je	_lOptCC_VarDT
		mov	dword ptr[edx+ebx*04h],	eax
		mov	cl,			bl
		jmp	_lOptCC_VarDT

		_lOptCC_VarDTEnd:
		retn
		;;----------------

		;;----------------
		;; checking
		_lOptCC_ChStr:

			;;----------------
			;; check next function
			_lOptCC_ChNext:
			xor	ebx,			ebx
			_lOptCC_ChNextEX:
			mov	eax,			offset _bFuncCodeBase

			_lOptCC_ChIn:
			cmp	dword ptr [eax],	00h
			je	_lOptCC_RemIn

			cmp	word ptr [eax+0ch],	00h
			jne	_lOptCC_ChCall
			add	eax,			10h
			jmp	_lOptCC_ChIn

			_lOptCC_ChCall:
			cmp	byte ptr [eax+0eh],	00h
			je	_lOptCC_ChInFunc
			add	eax,			10h
			jmp	_lOptCC_ChIn

				;;----------------
				;; in function
				_lOptCC_ChInFunc:
				mov	esi,			dword ptr [eax+08h]
				mov	byte ptr [eax+0eh],	01h

				_lbl:
				inc	esi
				cmp	byte ptr [esi-01h],	0ah		;; nl
				jne	_prew

				_lOptCC_ChInFunc_GetWord:
				mov	bl,			byte ptr [esi]
				cmp	byte ptr [_bAscii_00+ebx],	bh
				je	_lOptCC_ChInFunc_Inc

				cmp	dword ptr [esi],	66646e65h	;; endf
				jne	_lOptCC_ChInFunc_CheckWord
				cmp	byte ptr [esi-01h],	0ah		;; nl
				je	_lOptCC_ChNextEX

					;;----------------
					_lOptCC_ChInFunc_CheckWord:
					mov	bl,			byte ptr [esi]
					lea	edx,			[_dDefTable+ebx*04h]
					mov	edx,			dword ptr [edx]
					test	edx,			edx
					jz	_lOptCC_ChInFunc_ReCheck

					_lOptCC_ChInFunc_CheckWordEX:
					mov	ecx,			esi
					mov	ebp,			dword ptr [edx+08h]
					mov	bl,			byte ptr [ecx]
					cmp	byte ptr [ebp],		bl
					jne	_lOptCC_ChInFunc_ReCheck
					inc	ecx
					inc	ebp

					_lOptCC_ChInFunc_CheckWordFX:
					mov	bl,			byte ptr [ecx]
					cmp	byte ptr [_bAscii_00+ebx],	bh
					je	_lOptCC_ChInFunc_CheckWordOX

					cmp	byte ptr [ebp],		bl
					jne	_lOptCC_ChInFunc_NextFX
					inc	ebp
					inc	ecx
					jmp	_lOptCC_ChInFunc_CheckWordFX

					_lOptCC_ChInFunc_CheckWordOX:
					mov	bl,			byte ptr [ebp]
					cmp	byte ptr [_bAscii_00+ebx],	bh
					jne	_lOptCC_ChInFunc_NextFX

					inc	word ptr [edx+0ch]
					;;----------------

				_lOptCC_ChInFunc_NextWord:
				inc	esi
				mov	bl,			byte ptr [esi]
				cmp	byte ptr [_bAscii_00+ebx],	bh
				jne	_lOptCC_ChInFunc_NextWord
				jmp	_lOptCC_ChInFunc_GetWord

				_lOptCC_ChInFunc_NextFX:
				add	edx,			10h
				cmp	dword ptr [edx],	00h
				je	_lOptCC_ChInFunc_ReCheck
				jmp	_lOptCC_ChInFunc_CheckWordEX

				_lOptCC_ChInFunc_Inc:
				cmp	bl,			22h	;; "
				je	_lOptCC_ChInFunc_IncStr
				inc	esi
				jmp	_lOptCC_ChInFunc_GetWord

				_lOptCC_ChInFunc_IncStrEX:
				inc	esi
				_lOptCC_ChInFunc_IncStr:
				inc	esi
				cmp	byte ptr [esi],		5ch	;; \ 
				je	_lOptCC_ChInFunc_IncStrEX
				cmp	byte ptr [esi],		22h	;; "
				jne	_lOptCC_ChInFunc_IncStr
				inc	esi
				jmp	_lOptCC_ChInFunc_GetWord

				_lOptCC_ChInFunc_ReCheck:
				cmp	edx,			offset _bFuncCodeBase
				jge	_lOptCC_ChInFunc_NextWord

				mov	bl,			byte ptr [esi]
				lea	edx,			[_dDefTableEX+ebx*04h]
				mov	edx,			dword ptr [edx]
				test	edx,			edx
				jz	_lOptCC_ChInFunc_NextWord
				jmp	_lOptCC_ChInFunc_CheckWordEX
				;;----------------
			;;----------------

			;;----------------
			;; remove unused
			_lOptCC_RemIn:
			mov	al,		02h

				;;----------------
				;; functions
				mov	edx,			offset _bFuncCodeBase-10h

				_lOptCC_RemFunc:
				add	edx,			10h
				cmp	dword ptr [edx],	00h
				je	_lOptCC_RemVarIn

				cmp	word ptr [edx+0ch],	00h
				jne	_lOptCC_RemFunc

					;;----------------
					;; remove
					mov	edi,			dword ptr [edx]
					mov	ecx,			dword ptr [edx+04h]
					sub	ecx,			edi
					rep	stosb

					jmp	_lOptCC_RemFunc
					;;----------------
				;;----------------

				;;----------------
				;; variables
				_lOptCC_RemVarIn:
				mov	edx,			offset _bFuncCodeLocals-10h

				_lOptCC_RemVar:
				add	edx,			10h
				cmp	dword ptr [edx],	00h
				je	_lOptCC_RemParse

				cmp	word ptr [edx+0ch],	00h
				jne	_lOptCC_RemVar

					;;----------------
					;; remove
					mov	ebp,			dword ptr [edx+08h]

					_lbl:
					inc	ebp
					cmp	byte ptr [ebp],		0ah		;; nl
					je	_lOptCC_RemVarEX
					cmp	byte ptr [ebp],		3dh		;; =
					jne	_prew

						;;----------------
						;; check
						_lOptCC_RemVarCheckStart:
						inc	ebp
						cmp	byte ptr [ebp],		0ah		;; nl
						je	_lOptCC_RemVarEX
						cmp	byte ptr [ebp],		28h		;; (
						jne	_lOptCC_RemVarCheckStart

						mov	bl,			byte ptr [ebp-01h]
						cmp	byte ptr [_bAscii_00+ebx],	bh
						je	_lOptCC_RemVarCheckStart

							;;----------------
							mov	esi,			offset _sCodeNXFunc

							_lOptCC_RemVarCheck:
							lea	ecx,			[ebp-01h]

							_lbl:
							mov	bl,			byte ptr [ecx]
							cmp	bl,			byte ptr [esi]
							jne	_lOptCC_RemVarCheckFX
							dec	ecx
							inc	esi
							jmp	_prew

							_lOptCC_RemVarCheckFX:
							cmp	byte ptr [_bAscii_00+ebx],	bh
							jne	_lOptCC_RemVarCheckNext
							cmp	byte ptr [esi],		00h
							je	_lOptCC_RemVarCheckStart

							_lOptCC_RemVarCheckNext:
							cmp	byte ptr [esi],		00h
							jne	_lOptCC_RemVarCheckNextEX
							inc	esi
							cmp	byte ptr [esi],		00h
							jne	_lOptCC_RemVarCheck
							jmp	_lOptCC_RemVarCheckStart

							_lOptCC_RemVarCheckNextEX:
							inc	esi
							jmp	_lOptCC_RemVarCheckNext
							;;----------------

						;;----------------

						;;----------------
						_lOptCC_RemVarEX:
						mov	edi,			dword ptr [edx]
						mov	ecx,			dword ptr [edx+04h]
						sub	ecx,			edi
						rep	stosb

						jmp	_lOptCC_RemVar
						;;----------------
					;;----------------
				;;----------------

				;;----------------
				;; parse code
				_lOptCC_RemParse:
				pop	esi
				pop	edi
				add	esi,			04h
				add	edi,			04h

				_lOptCC_RemParseEX:
				lodsb
				cmp	al,			02h
				je	_lOptCC_RemParseEX
				test	al,			al
				jz	_lOptCC_RemParseEnd
				stosb
				jmp	_lOptCC_RemParseEX

				_lOptCC_RemParseEnd:
				add	esi,			03h
				;;----------------
			;;----------------
		;;----------------
	_lOptCC_NoRemove:
	;;----------------

	;;----------------
	mov	_dCurrStr,			offset _sProg_08
	mov	eax,				64h
	call	_lSetProg
	;;----------------

	sub	edi,			esi		;; edi = new script size

	retn

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; optimize endp
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; proc parse
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;; esi=Src
	;; edi=Dest

	;; stack:
	;;
	;; edi
	;; mem
	;; mem
	;; archive
	;; attributes

	_lMapParseCode:

	;;----------------
	;; utf 8 bom
	cmp	word ptr [esi],		0bbefh
	jne	_next
	cmp	byte ptr [esi+02h],	0bfh
	jne	_next

	add	esi,			03h

	_lbl:
	;;----------------

	;;----------------
	;; textmacro preprocessing
	cmp	byte ptr [_bUseMacroPrePorc],	00h
	je	_lMcrPre_End

	push	esi
	push	edi

		;;----------------
		mov	_dCurrStr,			offset _sProg_01_pre
		mov	eax,				04
		call	_lSetProg
		;;----------------

		;;----------------
		;; create file
		push	00h
		push	FILE_ATTRIBUTE_NORMAL
		push	CREATE_ALWAYS
		push	00h
		push	FILE_SHARE_READ + FILE_SHARE_WRITE
		push	00h
		push	offset _sTempMacroCJ
		call	_imp__CreateFileA@28

		cmp	eax,				0ffffffffh
;; je err
		push	eax
		call	_imp__CloseHandle@4

		push	00h
		push	FILE_ATTRIBUTE_NORMAL
		push	CREATE_ALWAYS
		push	00h
		push	FILE_SHARE_READ + FILE_SHARE_WRITE
		push	00h
		push	offset _sTempMacroBJ
		call	_imp__CreateFileA@28

		cmp	eax,				0ffffffffh
;; je err

		push	eax
		call	_imp__CloseHandle@4

		;; in file
		push	00h
		push	FILE_ATTRIBUTE_NORMAL
		push	CREATE_ALWAYS
		push	00h
		push	FILE_SHARE_READ + FILE_SHARE_WRITE
		push	GENERIC_READ + GENERIC_WRITE
		push	offset _sTempMacroIn
		call	_imp__CreateFileA@28

		cmp	eax,				0ffffffffh
;; je err
		mov	dword ptr [_hTempMacroIn],	eax
		;;----------------

	jmp	_lMcrPre_Get_LineEx

	_lMcrPre_Get_Line:
	inc	esi
	_lMcrPre_Get_LineEx:
	cmp	byte ptr [esi],			20h
	je	_lMcrPre_Get_Line
	cmp	byte ptr [esi],			09h
	je	_lMcrPre_Get_Line

	cmp	word ptr [esi],			2f2fh	;; //
	jne	_lMcrPre_Get_NextLine
	cmp	byte ptr [esi + 02h],		"!"
	jne	_lMcrPre_Get_Comment

		;;----------------
		lea	ecx,			[esi + 02h]

		_lMcrPre_Get_Instruct:
		inc	ecx
		_lMcrPre_Get_InstructEx:
		cmp	byte ptr [ecx],		" "
		je	_lMcrPre_Get_Instruct
		cmp	byte ptr [ecx],		09h
		je	_lMcrPre_Get_Instruct

		cmp	dword ptr [ecx],	"txet"
		jne	_next
		cmp	dword ptr [ecx + 04h],	"rcam"
		jne	_next
		cmp	word ptr [ecx + 08h],	" o"
		je	_lMcrPre_Get_MacroIn
		cmp	word ptr [ecx + 08h],	"_o"
		je	_lMcrPre_Get_MacroIn
		cmp	word ptr [ecx + 08h],	096fh	;; o tab
		je	_lMcrPre_Get_MacroIn

		_lbl:
		cmp	dword ptr [ecx],	"tnur"
		jne	_lMcrPre_Get_Comment
		cmp	dword ptr [ecx + 04h],	"mtxe"
		jne	_lMcrPre_Get_Comment
		cmp	dword ptr [ecx + 08h],	"orca"
		jne	_lMcrPre_Get_Comment
		cmp	byte ptr [ecx + 0ch],	" "
		jne	_lMcrPre_Get_Comment

			;;----------------
			;; run macro
			_lMcrPre_Get_MacroRun:
			inc	ecx
cmp	byte ptr [ecx],			00h
;;
			cmp	byte ptr [ecx],		0ah
			jne	_lMcrPre_Get_MacroRun
			inc	ecx

				;;----------------
				;; write it
				mov	byte ptr [_bMacroPreIsExist],	01h

				mov	ebx,			ecx
				sub	ebx,			esi
				mov	edi,			esi
				mov	ebp,			ecx

				push	00h
				push	offset _dBuffer
				push	ebx
				push	esi
				push	dword ptr [_hTempMacroIn]
				call	_imp__WriteFile@20

				push	00h
				push	offset _dBuffer
				push	_sEndMacroExStrSize
				push	offset _sEndMacroExStr
				push	dword ptr [_hTempMacroIn]
				call	_imp__WriteFile@20

				mov	word ptr [edi],		5201h	;; #R
				inc	edi
				_lMcrPre_Get_MacroRunClean:
				inc	edi
				cmp	byte ptr [edi],		0ah
				je	_lMcrPre_Get_MacroRunCleanEnd
				mov	byte ptr [edi],		" "
				jmp	_lMcrPre_Get_MacroRunClean
				_lMcrPre_Get_MacroRunCleanEnd:
				mov	byte ptr [edi],		" "

				mov	esi,			ebp

				jmp	_lMcrPre_Get_LineEx
				;;----------------
			;;----------------

			;;----------------
			;; declare macro
			_lMcrPre_Get_MacroIn:
			mov	ebx,			esi

			_lMcrPre_Get_MacroIn_NextChar:
			inc	ebx
			_lMcrPre_Get_MacroIn_NextCharEx:
cmp	byte ptr [ebx],				00h
;; err
			cmp	word ptr [ebx],		2f2fh
			je	_lMcrPre_Get_MacroIn_SkipLine

			cmp	byte ptr [ebx],		22h
			jne	_lMcrPre_Get_MacroIn_NextCharFx
			push	ebx
			call	_lSkipStr
			mov	ebx,			eax
			jmp	_lMcrPre_Get_MacroIn_NextCharEx

			_lMcrPre_Get_MacroIn_NextCharFx:
			cmp	word ptr [ebx],		"*/"
			jne	_lMcrPre_Get_MacroIn_NextCharLN
			push	ebx
			call	_lSkipComment
			mov	ebx,			eax
			jmp	_lMcrPre_Get_MacroIn_NextCharEx

			_lMcrPre_Get_MacroIn_NextCharLN:
			cmp	byte ptr [ebx],			0ah
			jne	_lMcrPre_Get_MacroIn_NextChar
			jmp	_lMcrPre_Get_MacroIn_LineEx

			_lMcrPre_Get_MacroIn_SkipLine:
			inc	ebx
cmp	byte ptr [ebx],			00h
;;
			cmp	byte ptr [ebx],			0ah
			jne	_lMcrPre_Get_MacroIn_SkipLine
			jmp	_lMcrPre_Get_MacroIn_Line

			_lMcrPre_Get_MacroIn_LineEx:
			inc	ebx
			_lMcrPre_Get_MacroIn_Line:
			cmp	byte ptr [ebx],			" "
			je	_lMcrPre_Get_MacroIn_LineEx
			cmp	byte ptr [ebx],			09h
			je	_lMcrPre_Get_MacroIn_LineEx
			cmp	word ptr [ebx],			2f2fh
			jne	_lMcrPre_Get_MacroIn_NextCharEx
			cmp	byte ptr [ebx + 02h],		"!"
			jne	_lMcrPre_Get_MacroIn_NextCharEx

			lea	ebp,				[ebx + 02h]
			_lMcrPre_Get_MacroIn_EndMacro:
			inc	ebp
			cmp	byte ptr [ebp],			" "
			je	_lMcrPre_Get_MacroIn_EndMacro
			cmp	byte ptr [ebp],			09h
			je	_lMcrPre_Get_MacroIn_EndMacro
			cmp	dword ptr [ebp],		"tdne"
			jne	_lMcrPre_Get_MacroIn_NextChar
			cmp	dword ptr [ebp + 04h],		"mtxe"
			jne	_lMcrPre_Get_MacroIn_NextChar
			cmp	dword ptr [ebp + 08h],		"orca"
			jne	_lMcrPre_Get_MacroIn_NextChar
			cmp	byte ptr [ebp + 0ch],		20h
			ja	_lMcrPre_Get_MacroIn_NextChar

			_lMcrPre_Get_MacroIn_EndMacroEx:
			inc	ebp
cmp	byte ptr [ebp],			00h
;;
			cmp	byte ptr [ebp],			0ah
			jne	_lMcrPre_Get_MacroIn_EndMacroEx
			inc	ebp

				;;----------------
				;; write it
				mov	edi,				esi
				mov	ebx,				ebp
				sub	ebp,				esi

				push	00h
				push	offset _dBuffer
				push	ebp
				push	esi
				push	dword ptr [_hTempMacroIn]
				call	_imp__WriteFile@20

				mov	al,				" "
				mov	ecx,				ebp
				mov	esi,				ebx
				rep	stosb				

				jmp	_lMcrPre_Get_LineEx
				;;----------------
			;;----------------
		;;----------------

		;;----------------
		_lMcrPre_Get_Comment:
		inc	esi
cmp	byte ptr [esi],			00h
;;
		cmp	byte ptr [esi],			0ah
		jne	_lMcrPre_Get_Comment
		jmp	_lMcrPre_Get_LineEx

		_lMcrPre_Get_NextLineEx:
		inc	esi
		_lMcrPre_Get_NextLine:
		cmp	byte ptr [esi],			00h
		je	_lMcrPre_EndEx

		cmp	word ptr [esi],			2f2fh	;; //
		je	_lMcrPre_Get_Comment

		cmp	byte ptr [esi],			22h
		jne	_lMcrPre_Get_NextLineFx
		push	esi
		call	_lSkipStr
		mov	esi,				eax
		jmp	_lMcrPre_Get_NextLine

		_lMcrPre_Get_NextLineFx:
		cmp	word ptr [esi],			"*/"
		jne	_lMcrPre_Get_NextLineOx
		push	esi
		call	_lSkipComment
		mov	esi,				eax
		jmp	_lMcrPre_Get_NextLine

		_lMcrPre_Get_NextLineOx:
		cmp	byte ptr [esi],			0ah	;; nl
		je	_lMcrPre_Get_Line

		jmp	_lMcrPre_Get_NextLineEx
		;;----------------

		;;----------------
		;; skip ex comment /* */
		_lSkipComment:
		mov	ecx,			dword ptr [esp + 04h]
		xor	edx,			edx

		_lSkipComment_Next:
		inc	ecx
		_lSkipComment_NextEx:
cmp	byte ptr [ecx],			00h
;;

		cmp	byte ptr [ecx],		22h
		jne	_lSkipComment_NextFx
		push	ecx
		call	_lSkipStr
		mov	ecx,			eax
		jmp	_lSkipComment_NextEx

		_lSkipComment_NextFx:
		cmp	word ptr [ecx],		"*/"
		je	_lSkipComment_NextDx
		cmp	word ptr [ecx],		"/*"
		jne	_lSkipComment_Next

		dec	edx
		jns	_lSkipComment_Next

		lea	eax,			[ecx + 02h]
		retn	04h


		_lSkipComment_NextDx:
		inc	edx
		jmp	_lSkipComment_Next
		;;----------------

		;;----------------
		;; skip line proc (addr)
		_lSkipStr:
		mov	eax,			dword ptr [esp + 04h]

		_lMcrPre_Get_String:
		inc	eax
		_lMcrPre_Get_StringEx:
		cmp	byte ptr [eax],			5ch	;; \ 
		jne	_lMcrPre_Get_String_Next
		add	eax,				02h
		jmp	_lMcrPre_Get_StringEx
		_lMcrPre_Get_String_Next:
cmp	byte ptr [eax],			00h
;;
		cmp	byte ptr [eax],			22h
		jne	_lMcrPre_Get_String

		inc	eax

		retn	04h
		;;----------------

	_lMcrPre_EndEx:
	cmp	byte ptr [_bMacroPreIsExist],	00h
	je	_lMcrPre_EndNoRun

	push	dword ptr [_hTempMacroIn]
	call	_imp__CloseHandle@4

	mov	dword ptr [_xStrInfo.cb],	sizeof STARTUPINFO
	push	offset _xPrcInfo
	push	offset _xStrInfo
	push	00h
	push	00h
	push	00h
	push	00h
	push	00h
	push	00h
	push	offset _sVXPreProcCmdLine
	push	dword ptr [_dVJassParserAdd]
	call	_imp__CreateProcessA@40

	test	eax,				eax
;; jz err

	push	0ffffffffh
	push	dword ptr [_xPrcInfo.hProcess]
	call	_imp__WaitForSingleObject@8

		;;----------------
		;; get parsed file
		push	00h
		push	FILE_ATTRIBUTE_NORMAL
		push	OPEN_EXISTING
		push	00h
		push	FILE_SHARE_READ
		push	GENERIC_READ
		push	offset _sTempMacroOut
		call	_imp__CreateFileA@28

		cmp	eax,			0ffffffffh
;; je err cant read parsed file

		mov	ebx,			eax	;; ebx - file

		push	00h
		push	ebx
		call	_imp__GetFileSize@8

		mov	esi,			eax	;; esi - size

		push	eax
		push	GPTR
		call	_imp__GlobalAlloc@8

		mov	dword ptr [_dMacroPreMem],	eax	;; mem addr
		mov	dword ptr [_dMacroPrePnt],	eax	;; mem addr

		push	00h
		push	offset _dBuffer
		push	esi
		push	eax
		push	ebx
		call	_imp__ReadFile@20

		push	ebx
		call	_imp__CloseHandle@4
		;;----------------

	_lMcrPre_EndNoRun:
	pop	edi
	pop	esi

	_lMcrPre_End:
	;;----------------

	;;----------------
	mov	_dCurrStr,			offset _sProg_01
	mov	eax,				10h
	call	_lSetProg
	;;----------------

	;;----------------
	;; comments removing

;;----------------
;; #custom pre
mov	dword ptr [_sCstPlugPath],		"gulp"
mov	dword ptr [_sCstPlugPath + 04h],	5c736e69h	;; \sni

mov	dword ptr [_sCstMapPath],		offset _sMapPathSX
;;----------------

;	_lCrStr:
	push	00h					;; for safe
	mov	_dStackPos,			esp	;; save stack
	mov	dword ptr [_dErrorCodeStart],	edi	;; for syntax error
	jmp	_lCRScanLineSx

		;;----------------
		;; line start
		_lCRScanLine:

			;;----------------
			cmp	dword ptr [_hBtn],	00h
			je	_lCRScanLineFx

			mov	dword ptr [_hBtn],	00h
			lea	eax,			[edi+02h]
			push	eax
			mov	dword ptr [edi],	78016101h		;; #a#x
			add	edi,			08h
			jmp	_lCRScanLineDx
			;;----------------

		_lCRScanLineFx:
		cmp	word ptr [edi-02h],	0a0dh	;; nl
		je	_lCRScanLineDx
		cmp	byte ptr [edi-01h],	00h
		je	_lCRScanLineDx
		mov	word ptr [edi],		0a0dh	;; nl
		add	edi,			02h
		_lCRScanLineDx:
		cmp	byte ptr [esi],		0ah
		jne	_next
		inc	esi
		jmp	_lCRScanLineDx
		_lbl:
		cmp	byte ptr [esi],		0dh
		jne	_lCRScanLineSx
		inc	esi
		jmp	_lCRScanLineDx

		_lCRScanLineSx:			;; <---
		mov	eax,			dword ptr [esi]
		;;----------------

		;;----------------
		;; remove bs and tabs in line start
		_lbl:
		cmp	al,			09h
		jne	_next
		inc	esi
		jmp	_lCRScanLineSx

		_lbl:
		cmp	al,			20h
		jne	_next
		inc	esi
		jmp	_lCRScanLineSx
		;;----------------

;;----------------
;; macro pre out
_lbl:
cmp	eax,				"rpjc"
jne	_next
cmp	dword ptr [esi + 04h],		"orpe"
jne	_next
cmp	dword ptr [esi + 08h],		"dnec"
jne	_next

push	edi
push	esi

mov	ecx,				_sEndMacroExStrSize
mov	edi,				offset _sEndMacroExStr

repe	cmpsb

test	ecx,				ecx
jnz	_lMacroPreOut_Fail

mov	dword ptr [_dMacroPrePnt],	esi
mov	esi,				dword ptr [_dMacroPreESI]

add	esp,				04h
pop	edi

jmp	_lCRScanLine

_lMacroPreOut_Fail:
pop	esi
pop	edi
;;----------------

		;;----------------
		;; define test
		_lbl:
		cmp	byte ptr [_bIsPPCEn],	00h
		je	_next

		cmp	eax,			69666564h	;; defi
		jne	_next
		cmp	word ptr [esi+04h],	656eh		;; ne
		jne	_next
		cmp	byte ptr [esi+06h],	20h
		jg	_next

		_lDefErrFGS:
		mov	dword ptr [_xErrorTable],	offset _sErr_FailedDef
		mov	dword ptr [_xErrorTable+04h],	edi
		_lDefErrFGSEX:
		movsb
		cmp	word ptr [esi],			0a0dh	;; nl
		jne	_lDefErrFGSEX
		mov	dword ptr [_xErrorTable+08h],	edi
		jmp	_lErrIn	
		;;----------------

		;;----------------
		;; pre proc
		_lbl:
		cmp	al,			23h		;; #
		jne	_next

			;;----------------
			;; #if
cmp	ax,			"i#"
jne	_lCRElifOS
cmp	byte ptr [esi+02h],	"f"
jne	_lCRElifOS
cmp	byte ptr [esi+03h],	41h
jge	_lCRErrPrePorc	

			mov	byte ptr [_bIsPPCEn],	al

			mov	dword ptr [_hBtn],	eax
			mov	word ptr [edi],		6901h		;; #i
			add	esi,			02h
			add	edi,			02h
			jmp	_lCRScan

				;;----------------
				;; error
				_lCRErrPrePorc:
				mov	dword ptr [_xErrorTable],	offset _sErr_PreProc
				mov	dword ptr [_xErrorTable+04h],	edi
				_lCRErrPrePorcEX:
				movsb
				cmp	word ptr [esi],			0a0dh	;; nl
				jne	_lCRErrPrePorcEX
				mov	dword ptr [_xErrorTable+08h],	edi
				jmp	_lErrIn
				;;----------------
			;;----------------

			;;----------------
			;; #else #elseif

				;;----------------
				;; close
				_lCRElifOX:
				mov	dword ptr [_hBtn],	eax
				_lCRElifFF:
				mov	word ptr [esi],		6901h		;; #i

				pop	eax
				test	eax,			eax
				jz	_lBlockErr

				mov	dword ptr [eax+02h],	edi
				mov	word ptr [edi],		7901h		;; #y
				mov	dword ptr [edi+02h],	eax
				mov	dword ptr [edi+06h],	06060606h	;; ex backspace
				mov	dword ptr [edi+0ah],	06060606h
				mov	word ptr [edi+0eh],	0a0dh		;; new line

				add	edi,			10h
				movsd
				jmp	_lCRScan
				;;----------------

			_lCRElifOS:
			cmp	eax,			736c6523h	;; #els
			jne	_lCRElifER
			cmp	dword ptr [esi+03h],	66696573h	;; eif_
			je	_lCRElifOX

			cmp	byte ptr [esi+04h],	65h		;; e
			jne	_lCRElifER
			cmp	byte ptr [esi+05h],	20h
			jbe	_lCRElifOX
			;;----------------

			;;----------------
			;; error
			_lCRElifER:
			cmp	eax,			72726523h	;; #err
			jne	_lCRElif_AAX
			cmp	word ptr [esi+04h],	726fh		;; or
			jne	_lCRElif_AAX
			cmp	byte ptr [esi+06h],	22h
			jg	_lCRElif_AAX

			mov	word ptr [esi],		6701h		;; #g
			movsd
			movsw
			jmp	_lCRScan
			;;----------------

			;;----------------
			;; include arguments
			_lCRElif_AAX:
			cmp	eax,			73797323h	;; #sys
			jne	_lCRElif_AAY
			cmp	dword ptr [esi+04h],	74696e69h	;; init
			jne	_lCRElif_AAY
			cmp	byte ptr [esi+08h],	22h
			jg	_lCRElif_AAY

;;			sub	dword ptr [_dInclArgCurr],	04h

			add	esi,			08h
			push	esi

			mov	eax,			dword ptr [_dInclArgCurr]
			lea	eax,			[eax-04h]
			mov	esi,			dword ptr [eax]

			jmp	_lCRScan
			;;----------------

			;;----------------
			_lCRElif_AAY:
			cmp	eax,			66656423h	;; #def
			je	_lCRElif_SOX
			cmp	eax,			74657323h	;; #set
			je	_lCRElif_OOX
			cmp	eax,			646e7523h	;; #und
			je	_lCRElif_OOX
			cmp	eax,			636e6923h	;; #inc
			jne	_lCRElif_GU

			_lCRElif_OOX:
			inc	esi
			jmp	_lCRScanLineSx

			_lCRElif_SOX:
			inc	esi
			cmp	byte ptr [_bIsPPCEn],	00h
			je	_lCRScanLineSx
			jmp	_lDefErrFGS
			;;----------------

			;;----------------
			;; #guard
			_lCRElif_GU:
			cmp	eax,			61756723h	;; #gua
			jne	_lCRElifFX
			cmp	word ptr [esi+04h],	6472h		;; rd
			jne	_lCRElifFX

			add	esi,			06h
			xor	eax,			eax

			_lCRElif_GU_01:
			inc	esi
			cmp	byte ptr [esi],		20h		;; bs
			je	_lCRElif_GU_01
			cmp	byte ptr [esi],		09h		;; tab
			je	_lCRElif_GU_01

			mov	ebp,			offset _bFuncCodeLocals

			_lCRElif_GU_02:
			mov	edx,			esi

			_lCRElif_GU_03:
			mov	al,			byte ptr [edx]
			cmp	al,			byte ptr [ebp]
			jne	_lCRElif_GU_04
			inc	ebp
			inc	edx
			jmp	_lCRElif_GU_03

			_lCRElif_GU_04:
			cmp	byte ptr [ebp],		00h
			jne	_lCRElif_GU_Next
			cmp	byte ptr [_bAscii_00+eax],	ah
			je	_lRetnGuard

			_lCRElif_GU_Next:
			inc	ebp
			cmp	byte ptr [ebp],		00h
			jne	_lCRElif_GU_Next
			inc	ebp
			cmp	byte ptr [ebp],		00h
			jne	_lCRElif_GU_02

			_lCRElif_GU_Add:
			mov	al,			byte ptr [esi]
			cmp	byte ptr [_bAscii_00+eax],	ah
			je	_lCRScan
			mov	byte ptr [ebp],		al
			inc	esi
			inc	ebp
			jmp	_lCRElif_GU_Add
			;;----------------

			;;----------------
			;; #endif
			_lCRElifFX:
			cmp	eax,			646e6523h	;; #end
			jne	_lCRElifFor
			cmp	word ptr [esi+04h],	6669h		;; if
			jne	_lCRElifFor
			mov	byte ptr [_bIsPPCEn],	00h

			jmp	_lCRElifFF
			;;----------------

			;;----------------
			;; #for
			_lCRElifFor:
			cmp	eax,			726f6623h	;; #for
			jne	_lCRElifEndfor

			cmp	byte ptr [esi+04h],	20h		;; bs
			je	_lCRElifFor_00
			cmp	byte ptr [esi+04h],	09h		;; tab
			je	_lCRElifFor_00
			jmp	_lCRElifEndfor

			_lCRElifFor_00:
			add	esi,			03h
			_lCRElifFor_01:
			inc	esi
			cmp	byte ptr [esi],		20h		;; bs
			je	_lCRElifFor_01
			cmp	byte ptr [esi],		09h		;; tab
			je	_lCRElifFor_01

			lea	eax,				[esi-02h]
			mov	ebx,				dword ptr [_lDefXEX]
			mov	dword ptr [ebx],		eax
			mov	dword ptr [ebx+08h],		7fffffffh
			mov	ebp,				dword ptr [_xForDefValEX]
			mov	dword ptr [ebx+04h],		ebp
			mov	dword ptr [ebp],		"@@@@"
			add	ebx,				10h
			mov	byte ptr [ebp+04h],		03h
			mov	dword ptr [_lDefXEX],		ebx
			mov	dword ptr [ebp+05h],		edi
			lea	ebx,				[ebp+09h]
			add	ebp,				0dh
			xor	eax,				eax
			mov	dword ptr [_xForDefValEX],	ebp

			_lCRElifFor_02:
			mov	al,				byte ptr [esi]
			cmp	byte ptr [_bAscii_00+eax],	ah
			je	_lCRElifFor_03
			mov	byte ptr [esi-02h],		al
			inc	esi
			jmp	_lCRElifFor_02

			_lCRElifFor_03:
			mov	word ptr [esi-02h],	0240h	;; @ endlabel

			mov	dword ptr [edi],	78014701h	;; #G#x
			mov	word ptr [edi+08h],	7901h		;; #y
			mov	word ptr [edi+0eh],	7801h		;; #x
			mov	word ptr [edi+14h],	7901h		;; #y
			mov	dword ptr [edi+16h],	ebx
			mov	word ptr [edi+1ah],	4901h		;; #I
			add	edi,			1ch

			mov	dword ptr [_hBtn],	eax		;; add #a#x
			jmp	_lCRScan
			;;----------------

			;;----------------
			;; #endfor
			_lCRElifEndfor:
			cmp	eax,			646e6523h	;; #end
			jne	_lCRElifRep
			cmp	dword ptr [esi+03h],	726f6664h	;; dfor
			jne	_lCRElifRep

			pop	eax
			test	eax,			eax
			jz	_lBlockErr

			mov	dword ptr [eax+02h],	edi
			mov	dword ptr [edi],	79014801h	;; #H#y
			mov	dword ptr [edi+04h],	eax
			mov	dword ptr [edi+08h],	06060606h	;; ex backspace
			mov	dword ptr [edi+0ch],	06060606h
			mov	word ptr [edi+10h],	0a0dh		;; nl

			add	esi,			07h
			add	edi,			12h

			_lCRElifEndfor_00:
			dec	eax
			cmp	word ptr [eax],		4901h		;; #I
			jne	_lCRElifEndfor_00

			mov	eax,			dword ptr [eax-04h]
			mov	dword ptr [eax],	edi

			jmp	_lCRScan
			;;----------------

			;;----------------
			;; #repeat
			_lCRElifRep:
			cmp	eax,			"per#"
			jne	_lCRElifEndrep
			cmp	dword ptr [esi+03h],	"taep"
			jne	_lCRElifEndrep

			cmp	byte ptr [esi+07h],	20h		;; bs
			je	_lCRElifRep_00
			cmp	byte ptr [esi+07h],	09h		;; tab
			je	_lCRElifRep_00
			jmp	_lCRElifEndrep

			_lCRElifRep_00:
			add	esi,			08h
			mov	dword ptr [edi],	78014b01h	;; #K#x
			mov	word ptr [edi+08h],	7901h		;; #y
			mov	word ptr [edi+0eh],	7801h		;; #x
			mov	word ptr [edi+14h],	7901h		;; #y
			mov	word ptr [edi+1ah],	4901h		;; #I
			add	edi,			1ch

			mov	dword ptr [_hBtn],	eax		;; add #a#x
			jmp	_lCRScan
			;;----------------

			;;----------------
			;; #endrepeat
			_lCRElifEndrep:
			cmp	eax,			646e6523h	;; #end
			jne	_lCRElifCS
			cmp	dword ptr [esi+04h],	"eper"
			jne	_lCRElifCS
			cmp	word ptr [esi+08h],	"ta"
			jne	_lCRElifCS

			pop	eax
			test	eax,			eax
			jz	_lBlockErr

			mov	dword ptr [eax+02h],	edi
			mov	dword ptr [edi],	79014801h	;; #H#y
			mov	dword ptr [edi+04h],	eax
			mov	dword ptr [edi+08h],	06060606h	;; ex backspace
			mov	dword ptr [edi+0ch],	06060606h
			mov	word ptr [edi+10h],	0a0dh		;; nl

			add	esi,			0ah
			add	edi,			12h

			jmp	_lCRScan
			;;----------------

			;;----------------
			;; #custon
			_lCRElifCS:
			cmp	eax,				"suc#"
			jne	_lCRErrPrePorc
			cmp	dword ptr [esi+04h],		" mot"
			jne	_lCRErrPrePorc

				;;----------------
				;; module name
				add	esi,				06h
				_lCRElifCS_00:
				inc	esi
				cmp	byte ptr [esi],			20h	;; bs
				je	_lCRElifCS_00

				xor	eax,				eax
				mov	edx,				offset _sCstPlugPath + 08h

				_lCRElifCS_01:
				lodsb
				cmp	byte ptr [_bAscii_00+eax],	00h
				je	_lCRElifCS_01e
				mov	byte ptr [edx],			al
				inc	edx
				jmp	_lCRElifCS_01

				_lCRElifCS_01e:
				mov	dword ptr [edx],		"lld."
				mov	byte ptr [edx+04h],		00h
				;;----------------

				;;----------------
				;; get arguments
				dec	esi

				_lCRElifCS_02:
				inc	esi
				mov	eax,				dword ptr [esi]
				cmp	al,				"("
				je	_lCRElifCS_02e
				cmp	ax,				0a0dh	;; nl
				je	_lCRElifCS_02f
				cmp	al,				20h	;; bs
				je	_lCRElifCS_02
				cmp	al,				09h	;; tab
				je	_lCRElifCS_02
				jmp	_lCRElifCS_03err

				_lCRElifCS_02f:
				mov	dword ptr [_sCstArguments],	offset	_sCstArgNull
				jmp	_lCRElifCS_03

				_lCRElifCS_02e:
				inc	esi
				mov	dword ptr [_sCstArguments],	esi

				dec	esi
				_lCRElifCS_02x:
				inc	esi
				cmp	byte ptr [esi],			")"
				jne	_lCRElifCS_02x
				mov	byte ptr [esi],			00h

				_lCRElifCS_02y:
				inc	esi
				cmp	word ptr [esi],			0a0dh	;; nl
				jne	_lCRElifCS_02y
				;;----------------

				;;----------------
				;; get code
				_lCRElifCS_03:
				lea	eax,				[esi+02h]	;; remov nl
				mov	dword ptr [_dCstCodeStart],	eax

				_lCRElifCS_03sx:
				dec	esi
				_lCRElifCS_03s:
				inc	esi
				_lCRElifCS_03sy:
				cmp	word ptr [esi],			00h
				je	_lCRElifCS_03err
				cmp	word ptr [esi],			0a0dh	;; nl
				jne	_lCRElifCS_03s

				inc	esi
				_lCRElifCS_03c:
				inc	esi
				_lCRElifCS_03a:
				cmp	dword ptr [esi],		"dne#"
				je	_lCRElifCS_03b
				cmp	byte ptr  [esi],		20h	;; bs
				je	_lCRElifCS_03c
				cmp	byte ptr [esi],			09h	;; tab
				je	_lCRElifCS_03c
				jmp	_lCRElifCS_03sy

					;;----------------
					_lCRElifCS_03err:
					mov	dword ptr [_xErrorTable],	offset _sErr_Base
					mov	dword ptr [_xErrorTable+04h],	edi
					movsb
					mov	dword ptr [_xErrorTable+08h],	edi
					jmp	_lErrIn
					;;----------------

				_lCRElifCS_03b:
				cmp	dword ptr [esi+04h],		"tsuc"
				jne	_lCRElifCS_03s
				cmp	word ptr [esi+08h],		"mo"
				jne	_lCRElifCS_03s
				cmp	byte ptr [esi+0ah],		20h
				ja	_lCRElifCS_03s

				mov	dword ptr [esi],		00h

				mov	ebx,				dword ptr [_dCstCodeStart]
				sub	ebx,				esi
				add	esi,				0ah
				mov	dword ptr [_dCstCodeSize],	ebx
				;;----------------

				;;----------------
				;; get mem
				shl	ebx,				04h
				add	ebx,				00080000h

				push	ebx
				push	GMEM_ZEROINIT
				call	_imp__GlobalAlloc@8
				mov	dword ptr [_dCstMemHndl],	eax

				push	eax
				call	_imp__GlobalLock@4
				mov	dword ptr [_dCstMemAddr],	eax

				mov	dword ptr [_dCstCodeDest],	eax
				mov	dword ptr [_dCstEsi],		esi
				;;----------------

				;;----------------
				;; load plugin
				push	offset _sCstPlugPath
				call	_imp__LoadLibraryA@4
				test	eax,				eax
				jz	_lCRElifCS_04_err00

				push	offset _sCstProcName
				push	eax
				call	_imp__GetProcAddress@8
				test	eax,				eax
				jz	_lCRElifCS_04_err00

					;;----------------
					;; oh shi~
					pushad

					push	offset _dCstCodeStart
					call	eax

					test	eax,				eax
					jnz	_lCRElifCS_04_err01

					popad

					mov	eax,				dword ptr [_dCstCodeFinalSize]
					add	eax,				02h

					push	eax
					push	GMEM_ZEROINIT
					call	_imp__GlobalAlloc@8

					push	eax
					call	_imp__GlobalLock@4

					mov	ecx,				dword ptr [_dCstCodeFinalSize]
					mov	word ptr [eax+ecx],		4601h	;; #F
					mov	esi,				dword ptr [_dCstCodeDest]
					push	edi
					mov	edi,				eax
					rep	movsb

					mov	esi,				eax
					pop	edi

					push	dword ptr [_dCstMemAddr]
					call	_imp__GlobalUnlock@4
					push	dword ptr [_dCstMemHndl]
					call	_imp__GlobalFree@4

					jmp	_lCRScanLineSx
					;;----------------

					;;----------------
					;; cannot load plug
					_lCRElifCS_04_err00:
					mov	dword ptr [_xErrorTable],	offset _sErr_PlugFail
					_lCRElifCS_04_err00in:
					mov	dword ptr [_xErrorTable+04h],	edi

					mov	dword ptr [edi],		"suc#"
					mov	dword ptr [edi+04h],		" mot"
					mov	esi,				offset _sCstPlugPath + 08h
					add	edi,				08h

					_lCRElifCS_04_err00x:
					movsb
					cmp	byte ptr [esi],			00h
					jne	_lCRElifCS_04_err00x
					mov	byte ptr [edi-04h],		00h

					mov	dword ptr [_xErrorTable+08h],	edi
					jmp	_lErrIn
					;;----------------

					;;----------------
					;; epic fail - plug error
					_lCRElifCS_04_err01:
					cmp	eax,				0ffffffffh
					jne	_lCRElifCS_04_err01x

					popad

					mov	dword ptr [_xErrorTable],	offset _sErr_PlugEpicFail
					jmp	_lCRElifCS_04_err00in

					_lCRElifCS_04_err01x:
					push	00h
					call	_imp__ExitProcess@4
					;;----------------
				;;----------------
			;;----------------

		;;----------------

;;----------------
;; for
_lbl:
cmp	ax,			"of"
jne	_next
cmp	byte ptr [esi + 02h],	"r"
jne	_next
cmp	byte ptr [esi + 03h],	30h
jae	_next

	;;----------------
	;; for in
	_lCRPreForIn:
	lea	eax,			[esi + 02h]

	_lCRPreForIn_Scan:
	inc	eax
	cmp	byte ptr [eax],		20h
	je	_lCRPreForIn_Scan
	cmp	byte ptr [eax],		09h
	je	_lCRPreForIn_Scan

	cmp	byte ptr [eax],		"("
	je	_lCRPreForIn_Ex

		;;----------------
		;; error
		dec	eax
		mov	dword ptr [_xErrorTable],	offset _sErr_ForDeclaration
		mov	dword ptr [_xErrorTable + 04h],	eax
		inc	eax
		mov	dword ptr [_xErrorTable + 08h],	eax
		jmp	_lErrIn
		;;----------------

	_lCRPreForIn_Ex:
	mov	byte ptr [eax],			19h
	mov	byte ptr [_bPreForArgs],	02h
	mov	byte ptr [_bPreForScope],	01h

	jmp	_lCRScan
	;;----------------

_lbl:
cmp	eax,			"prof"
jne	_next
cmp	byte ptr [esi + 04h],	30h
jae	_next
lea	eax,			[esi + 03h]
jmp	_lCRPreForIn_Scan
;;----------------

;;----------------
;; endfor (old style)
_lbl:
cmp	eax,				"fdne"
jne	_next
cmp	word ptr [esi + 04h],		"ro"
jne	_next
xor	ecx,				ecx
mov	cl,				byte ptr [esi + 06h]
cmp	byte ptr [_bAscii_00 + ecx],	ch
je	_lCREndFor

_lbl:
cmp	eax,				"fdne"
jne	_next
cmp	dword ptr [esi + 03h],		"prof"
jne	_next
xor	ecx,				ecx
mov	cl,				byte ptr [esi + 07h]
cmp	byte ptr [_bAscii_00 + ecx],	ch
jne	_next

inc	esi

_lCREndFor:
mov	dword ptr [edi],		0a0d291bh	;; 1b ) nl
add	esi,				06h
add	edi,				04h	
jmp	_lCRScanLine
;;----------------

		;;----------------
		;; textmacros

			;;----------------
			;; start
			_lCRTTInOnce:
			cmp	dword ptr [esi+08h],	636e5f6fh	;; o_nc
			jne	_next
			cmp	word ptr [esi+0ch],	2065h		;; e_
			jne	_next
			add	esi,			0eh
			jmp	_lCRTTInOX

			_lbl:
			cmp	eax,			74786574h	;; text	
			jne	_next
			cmp	dword ptr [esi+04h],	7263616dh	;; macr
			jne	_next
			cmp	word ptr [esi+08h],	206fh		;; o_
			jne	_lCRTTInOnce

			add	esi,			0ah
			_lCRTTInOX:
			mov	dword ptr [edi-04h],	69666564h	;; defi
			mov	dword ptr [edi],	7420656eh	;; ne_t
			mov	byte ptr [edi+04h],	6dh		;; m
			add	edi,			05h

			mov	eax,			esi
			_lCRTTIn:
			inc	eax
			cmp	byte ptr [eax],		0ah		;; nl
			je	_lCRTTInEnd
			cmp	dword ptr [eax],	656b6174h	;; take
			jne	_lCRTTIn
			cmp	word ptr [eax+04h],	2073h		;; s_
			jne	_lCRTTIn

			mov	dword ptr [eax],	20202020h	;; bs
			mov	word ptr [eax+04h],	1320h		;; _( 

			_lCRTTInEX:
			inc	eax
			cmp	byte ptr [eax],		2ch		;; ,
			jne	_lCRTTInFF
			mov	byte ptr [eax],		14h
			jmp	_lCRTTInEX

			_lCRTTInFF:
			cmp	byte ptr [eax],		0ah		;; nl
			jne	_lCRTTInEX

			cmp	byte ptr [eax-01h],	0dh
			jne	_lCRTTInFX
			mov	byte ptr [eax-01h],	20h		;; bs

			_lCRTTInFX:
			mov	byte ptr [eax],		11h
			jmp	_lCRScan

			_lCRTTInEnd:
			cmp	byte ptr [eax-01h],	0dh
			jne	_lCRTTInDX
			mov	byte ptr [eax-01h],	20h
			_lCRTTInDX:
			mov	byte ptr [eax],		12h
			jmp	_lCRScan
			;;----------------

			;;----------------
			;; end
			_lbl:
			cmp	eax,			74646e65h	;; endt
			jne	_next
			cmp	dword ptr [esi+04h],	6d747865h	;; extm
			jne	_next
			cmp	dword ptr [esi+08h],	6f726361h	;; acro
			jne	_next
			cmp	byte ptr [esi+0ch],	20h		;; _
			jg	_next

			sub	edi,			04h
			add	esi,			0ch

			pop	eax
			test	eax,			eax
			jz	_lBlockErr

			cmp	word ptr [edi-02h],	0a0dh		;; new line
			je	_lCLTMNE
			mov	word ptr [edi],		0a0dh		;; new line
			add	edi,			02h
			_lCLTMNE:
			mov	dword ptr [eax+02h],	edi
			mov	word ptr [edi],		7901h		;; #y
			mov	dword ptr [edi+02h],	eax
			mov	dword ptr [edi+06h],	06060606h	;; ex backspace
			mov	dword ptr [edi+0ah],	06060606h
			mov	word ptr [edi+0eh],	0a0dh		;; new line

			add	edi,			10h
			jmp	_lCRScanLine
			;;----------------

			;;----------------
			;; run
			_lbl:
			cmp	eax,			746e7572h	;; runt
			jne	_next
			cmp	dword ptr [esi+04h],	6d747865h	;; extm
			jne	_next
			cmp	dword ptr [esi+08h],	6f726361h	;; acro
			jne	_next
			cmp	byte ptr [esi+0ch],	20h		;; _
			jne	_next

			xor	ecx,			ecx		;; is optional
			cmp	dword ptr [esi+0dh],	6974706fh	;; opti
			jne	_lCRMacroRunXX
			cmp	dword ptr [esi+11h],	6c616e6fh	;; onal
			jne	_lCRMacroRunXX
			cmp	byte ptr [esi+15h],	20h		;; bs
			jne	_lCRMacroRunXX

			add	esi,			09h
			inc	ecx					;; yes, optional

			_lCRMacroRunXX:
			mov	word ptr [edi-04h],	6d74h		;; tm ;; textmacro prefix
			lea	eax,			[esi+0ah]
			sub	edi,			02h
			add	esi,			0dh
			mov	ebx,			eax

			_lCRMacroRun:
			inc	eax
			cmp	byte ptr [eax],		22h		;; "
			jne	_lCRMacroRunEX

			test	ebx,			ebx
			jz	_lCRMacroRunB

			_lCRMacroRunA:
			mov	byte ptr [eax],		0bh
			xor	ebx,			ebx

				;;----------------
				;; special for Strilanc
				cmp	word ptr [eax+01h],	2f2fh		;; //
				jne	_lCRMacroRun

				mov	word ptr [eax+01h],	3501h		;; #5
				jmp	_lCRMacroRun
				;;----------------

			_lCRMacroRunB:
			mov	byte ptr [eax],		0bh
			inc	ebx
			jmp	_lCRMacroRun

			_lCRMacroRunEX:
			cmp	byte ptr [eax],		0ah		;; nl
			jne	_lCRMacroRun

			test	ecx,			ecx
			jz	_lCRMacroRunMF
			mov	byte ptr [eax],		15h

			_lCRMacroRunMF:
			cmp	ebx,			01h
			jbe	_lCRScan

			_lCRMacroRunSF:
			dec	eax
			cmp	byte ptr [eax],		0ah
			je	_lCRScan
			cmp	byte ptr [eax],		28h		;; ( 
			je	_lCRMacroRunDF
			cmp	byte ptr [eax],		29h		;; )  
			jne	_lCRMacroRunSF
			_lCRMacroRunDF:
			mov	byte ptr [eax],		20h		;; bs
			jmp	_lCRMacroRunSF
			;;----------------
		;;----------------

		;;----------------
		;; zinc and boa
		_lbl:
		cmp	eax,			636e697ah	;; zinc
		jne	_next
		cmp	byte ptr [esi+04h],	20h
		jbe	_lCRFXSyn

		_lbl:
		cmp	ax,			"ul"
		jne	_next
		cmp	byte ptr [esi+02h],	"a"
		jne	_next
		cmp	byte ptr [esi+03h],	20h
		jbe	_lCRFXSyn

_lbl:
cmp	eax,			"jcon"
jne	_next
cmp	word ptr [esi + 03h],	"ssaj"
jne	_next
cmp	byte ptr [esi + 07h],	20h
jbe	_lCRFXSyn

		_lbl:
		cmp	ax,			6f62h		;; bo
		jne	_next
		cmp	byte ptr [esi+02h],	61h		;; a
		jne	_next
		cmp	byte ptr [esi+03h],	20h
		jg	_next


		_lCRFXSyn:
		mov	eax,			dword ptr [_dSynDesc]
		mov	dword ptr [eax],	esi
		mov	dword ptr [edi-04h],	0a0d3901h		;; #9 nl

		_lCREndFXSyn:
		inc	esi

;;		cmp	byte ptr [esi],		00h
;;		je

		cmp	dword ptr [esi],	7a646e65h	;; endz
		jne	_lCREndFXSynEX
		cmp	word ptr [esi+04h],	6e69h		;; in
		jne	_lCREndFXSynEX
		cmp	byte ptr [esi+06h],	63h		;; c
		jne	_lCREndFXSynEX
		cmp	byte ptr [esi+07h],	20h		;; bs
		jb	_lCREndFXSynDX

		_lCREndFXSynEX:
		cmp	dword ptr [esi],	"ldne"
		jne	_lCREndFXSynRX
		cmp	word ptr [esi+04h],	"au"
		jne	_lCREndFXSynRX
		cmp	byte ptr [esi+06h],	20h		;; bs
		jb	_lCREndFXSynDX

_lCREndFXSynRX:
cmp	dword ptr [esi],		"ndne"
jne	_lCREndFXSynFX
cmp	dword ptr [esi + 04h],		"ajco"
jne	_lCREndFXSynFX
cmp	word ptr [esi + 08h],		"ss"
jne	_lCREndFXSynFX
cmp	byte ptr [esi + 0ah],		" "		;; bs
jb	_lCREndFXSynDX


		_lCREndFXSynFX:
		cmp	dword ptr [esi],	62646e65h	;; endb
		jne	_lCREndFXSyn
		cmp	word ptr [esi+04h],	616fh		;; oa
		jne	_lCREndFXSyn
		cmp	byte ptr [esi+06h],	20h		;; bs
		jg	_lCREndFXSyn

		_lCREndFXSynDX:
		inc	esi
		cmp	word ptr [esi-02h],	0a0dh
		jne	_lCREndFXSynDX

		mov	dword ptr [eax+04h],	esi
		add	eax,			08h
		mov	dword ptr [_dSynDesc],	eax
		jmp	_lCRScanLineSx
		;;----------------

		;;----------------
		;; debug?
		_lbl:
		cmp	eax,			75626564h	;; debu
		jne	_next
		cmp	byte ptr [esi+04h],	67h		;; g
		jne	_next
		cmp	byte ptr [esi+05h],	20h		;; bs or tab
		jg	_next
		jmp	dword ptr [_dDbgOff]

		_lCRDebugRem:
		inc	esi
		cmp	byte ptr [esi],		0ah		;; nl
		jne	_lCRDebugRem
		jmp	_lCRScanLine

		_lCRDebugAdd:
		add	esi,			06h
		jmp	_lCRScanLineSx
		;;----------------

		;;----------------
		;; include?
		_lbl:
		cmp	eax,			6c636e69h	;; incl
		jne	_lCRScanEx
		cmp	dword ptr [esi+04h],	20656475h	;; ude_
		jne	_lCRScanEx
		lea	ebx,			[esi+07h]

		_lIncSearch:
		inc	ebx
		cmp	byte ptr [ebx],		22h		;; "
		je	_lIncParseName
		cmp	byte ptr [ebx],		20h		;; bs
		je	_lIncSearch
		cmp	byte ptr [ebx],		09h		;; tab
		je	_lIncSearch

			;;----------------
			;; error
			mov	dword ptr [_xErrorTable],	offset _sErr_Base
			movsd
			movsd
			mov	dword ptr [_xErrorTable+04h],	edi
			_lIncludeErrEX:
			movsb
			cmp	word ptr [esi],			0a0dh
			jne	_lIncludeErrEX
			mov	dword ptr [_xErrorTable+08h],	edi
			jmp	_lErrIn
			;;----------------

		_lIncParseName:
		mov	edx,			dword ptr [_dCurrDirEnd]
		mov	ebp,			dword ptr [_dMapPathEnd]
		mov	ecx,			ebx
		inc	ebx
		_lIncLib:
		inc	ecx
		mov	al,			byte ptr [ecx]
		inc	edx
		inc	ebp
		cmp	al,			22h		;; "
		mov	byte ptr [edx],		al
		mov	byte ptr [ebp],		al
		jne	_lIncLib
		mov	byte ptr [ecx],		00h
		mov	byte ptr [edx],		00h
		mov	byte ptr [ebp],		00h

		mov	eax,			dword ptr [_dInclArgCurr]
		mov	esi,			ecx		;; new sorc script position
		mov	dword ptr [eax],	00h

			;;----------------
			;; arguments
			_IncParseNameEX:
			inc	esi
			cmp	byte ptr [esi],		20h		;; bs
			je	_IncParseNameEX
			cmp	byte ptr [esi],		09h		;; tab
			je	_IncParseNameEX
			cmp	byte ptr [esi],		0ah		;; nl
			je	_IncParseNameEX
			cmp	byte ptr [esi],		0dh		;; cr
			je	_IncParseNameEX

			cmp	byte ptr [esi],		7bh		;; {
			jne	_lOpenFile

			mov	byte ptr [esi],		16h

			mov	edx,			esi
			xor	ecx,			ecx		;; block counter
			mov	dword ptr [eax],	edx
			jmp	_lParseInclArg_StrEX

			_lParseInclArg_Str:
			inc	edx
			_lParseInclArg_StrEX:
			cmp	byte ptr [edx],		0ah		;; nl
			jne	_next

			test	ecx,			ecx
			jnz	_lParseInclArg_Str
			mov	byte ptr [edx],		16h
			cmp	byte ptr [edx-01h],	0dh
			jne	_lParseInclArg_Str
			mov	byte ptr [edx-01h],	16h
			jmp	_lParseInclArg_Str

			_lbl:
			cmp	byte ptr [edx],		7bh		;; {
			jne	_next
			inc	ecx
			jmp	_lParseInclArg_Str

			_lbl:
			cmp	byte ptr [edx],		7dh		;; }
			jne	_lParseInclArg_Str
			dec	ecx
			jns	_lParseInclArg_Str

			lea	esi,				[edx+01h]

			mov	byte ptr [edx],		17h

			;;----------------

			;;----------------
			;; open file
			_lOpenFile:
			add	eax,				04h
			mov	dword ptr [_dInclArgCurr],	eax

			push	00h
			push	FILE_ATTRIBUTE_NORMAL
			push	OPEN_EXISTING
			push	00h
			push	FILE_SHARE_READ
			push	GENERIC_READ
			push	offset _sCurrDir
			call	_imp__CreateFileA@28

			inc	eax
			jnz	_lIncNoReopen

			push	00h
			push	FILE_ATTRIBUTE_NORMAL
			push	OPEN_EXISTING
			push	00h
			push	FILE_SHARE_READ
			push	GENERIC_READ
			push	offset _sMapPathEX
			call	_imp__CreateFileA@28

			inc	eax
			jnz	_lIncNoReopen

			push	00h
			push	FILE_ATTRIBUTE_NORMAL
			push	OPEN_EXISTING
			push	00h
			push	FILE_SHARE_READ
			push	GENERIC_READ
			push	ebx
			call	_imp__CreateFileA@28

			inc	eax
			jnz	_lIncNoReopen

				;;----------------
				;; cannot open file
				mov	ecx,				esi
				mov	dword ptr [_xErrorTable],	offset _sErr_CantOpenFile
				mov	dword ptr [_xErrorTable+04h],	edi
				_lIncludeErr:
				dec	esi
				cmp	byte ptr [esi-01h],		0ah
				jne	_lIncludeErr
				sub	ecx,				esi
				rep	movsb
				mov	byte ptr [edi-01h],		22h	;; "
				mov	dword ptr [_xErrorTable+08h],	edi	
				jmp	_lErrIn
				;;----------------
			;;----------------

			;;----------------
			;; read file
			_lIncNoReopen:
			dec	eax					;; restore eax
			sub	esp,			08h		;; old esi, mem handle, mem address
			mov	ebx,			eax		;; ebx = file handle
			
			push	esi					;; old script position

			push	00h
			push	eax
			call	_imp__GetFileSize@8

			mov	ebp,			eax		;; ebp = file size

			push	00h					;; ---> _imp__ReadFile@20
			push	offset _dBuffer				;; ---> _imp__ReadFile@20
			push	eax					;; ---> _imp__ReadFile@20
			add	eax,			04h

			push	eax
			push	GMEM_ZEROINIT
			call	_imp__GlobalAlloc@8
			push	eax
			mov	dword ptr [esp+14h],	eax
			call	_imp__GlobalLock@4
			mov	esi,			eax
			mov	dword ptr [esp+14h],	eax
			add	ebp,			eax

			push	eax
			push	ebx
			call	_imp__ReadFile@20

			push	ebx
			call	_imp__CloseHandle@4

			mov	dword ptr [ebp],	00007201h	;; #r__
			push	00h					;; for safe

			jmp	_lCRScanLine
			;;----------------
		;;----------------

		;;----------------
		;; remove bs
		_lBSRemBase	equ		$
		_lCRScanBS:
		inc	esi

		_lCRScan:
		mov	eax,			dword ptr [esi]

		_lCRScanEx:	;; <---
		cmp	al,			20h
		jne	_next

			;;----------------
			;; check prew blocks
			cmp	word ptr [edi-06h],	7801h	;; #x
			je	_lCRScanBS
			cmp	word ptr [edi-06h],	7901h	;; #y
			je	_lCRScanBS
			;;----------------

		_lCRBSStart:	;; test previous char
		xor	ebx,			ebx
		mov	bl,			byte ptr [edi-01h]
		mov	bl,			byte ptr [_bAscii_01+ebx]
		add	ebx,			_lBSRemBase
		jmp	ebx

		_lCRBSNext:	;; test next char
cmp	word ptr [esi + 01h],		"*/"
je	_lCRBSAdd	
		xor	ebx,			ebx
		mov	bl,			ah
		mov	bl,			byte ptr [_bAscii_02+ebx]
		add	ebx,			_lBSRemBase
		jmp	ebx

		_lCRBSAdd:
		mov	byte ptr [edi],		20h	;; _
		inc	esi
		inc	edi
		jmp	_lCRScan

		_lCRIncDec:
		cmp	ah,			2bh	;; ++
		je	_lCRBSAdd
		cmp	ah,			2dh	;; --
		je	_lCRBSAdd
		jmp	_lCRScanBS

		_lbl:
		cmp	al,			09h	;; tab
		je	_lCRBSStart
		;;----------------

		;;----------------
		;; optional macro
		cmp	ah,			15h
		jne	_next

		mov	byte ptr [esi+01h],	0ah	;; nl
		mov	word ptr [edi],		4301h	;; #C
		add	edi,			02h
		jmp	_lCRScan

		cmp	al,			15h
		jne	_next

		mov	byte ptr [esi],		0ah	;; nl
		mov	word ptr [edi],		4301h	;; #c
		add	edi,			02h
		jmp	_lCRScan
		;;----------------

;;----------------
;; #R - macro pre in
_lbl:
cmp	ax,			5201h	;; #R
jne	_next

add	esi,				02h
mov	dword ptr [_dMacroPreESI],	esi
mov	esi,				dword ptr [_dMacroPrePnt]

jmp	_lCRScanLine
;;----------------

		;;----------------
		;; new line
		_lbl:
		cmp	al,				0ah
		jne	_next

		_lCRNewLinePreFor:
		cmp	byte ptr [_bPreForScope],	00h
		je	_lCRScanLine

		dec	edi
		cmp	byte ptr [edi],			")"
		je	_lCRPreForBlockCorrectEx

			;;----------------
			;; error
			_lCRPreForBlockCorrect_Err:
			mov	dword ptr [_xErrorTable],	offset _sErr_Base
			mov	dword ptr [_xErrorTable + 04h],	esi
			inc	esi
			mov	dword ptr [_xErrorTable + 08h],	esi
			jmp	_lErrIn
			;;----------------

		_lCRPreForBlockCorrectEx:
mov	eax,			esi
_lCRPreForBlockCorrectDx:
inc	eax
cmp	byte ptr [eax],		20h
je	_lCRPreForBlockCorrectDx
cmp	byte ptr [eax],		09h
je	_lCRPreForBlockCorrectDx
cmp	byte ptr [eax],		0ah
je	_lCRPreForBlockCorrectDx
cmp	byte ptr [eax],		0dh
je	_lCRPreForBlockCorrectDx
cmp	byte ptr [eax],		00h
je	_lCRPreForBlockCorrect_Err
cmp	byte ptr [eax],		"{"
jne	_lCRPreForBlockCorrectSx
mov	esi,			eax
jmp	_lCRPreForBlockCorrect

		_lCRPreForBlockCorrectSx:
		mov	dword ptr [edi],		001a2c1bh
		add	edi,				03h

		mov	eax,				esi
		_lCRNewLinePreForEx:
		inc	esi
		cmp	byte ptr [esi],			0ah
		je	_lCRNewLinePreForEx
		cmp	byte ptr [esi],			0dh
		je	_lCRNewLinePreForEx
		cmp	byte ptr [esi],			00h
		je	_lCRNewLinePreForErr
mov	byte ptr [_bPreForArgs],	00h
		mov	byte ptr [_bPreForScope],	00h
		jmp	_lCRScanLine

		_lCRNewLinePreForErr:
		mov	dword ptr [_xErrorTable],	offset _sErr_Base
		mov	dword ptr [_xErrorTable+04h],	eax
		dec	esi
		mov	dword ptr [_xErrorTable+08h],	esi
		jmp	_lErrIn

		_lbl:
		cmp	al,				0dh
		je	_lCRNewLinePreFor
		;;----------------

		;;----------------
		;; error with 80+ char
		cmp	al,			80h
		jb	_next

		mov	dword ptr [_xErrorTable],	offset _sErr_BadChar
		mov	dword ptr [_xErrorTable+04h],	edi
		movsb
		mov	dword ptr [_xErrorTable+08h],	edi
		jmp	_lErrIn
		;;----------------

		;;----------------
		;; ascii int
		_lbl:
		cmp	al,			27h		;; '
		jne	_next

		xor	eax,			eax
		mov	al,			byte ptr [edi-01h]
		inc	esi
		cmp	byte ptr [_bAscii_00+eax],	ah
		je	_lCRASCII_FX
		mov	byte ptr [edi],		20h		;; bs
		inc	edi

		_lCRASCII_FX:
		mov	word ptr [edi],		7830h		;; 0x
		add	edi,			02h
		mov	ecx,			05h

		_lCRASCII:
		mov	al,			byte ptr [esi]
		cmp	al,			27h		;; '
		je	_lCRASCII_EX

		shr	eax,			04h
		and	al,			0fh
		cmp	al,			0ah
		sbb	al,			69h
		das
		stosb
		mov	al,			byte ptr [esi]
		and	al,			0fh
		cmp	al,			0ah
		sbb	al,			69h
		das
		stosb

		inc	esi
		dec	ecx
		jnz	_lCRASCII

			;;----------------
			;; error
			mov	dword ptr [_xErrorTable],	offset _sErr_IncorrectLiteral
			dec	edi
			mov	dword ptr [_xErrorTable+04h],	edi
			inc	edi
			mov	dword ptr [_xErrorTable+08h],	edi
			jmp	_lErrIn
			;;----------------

		_lCRASCII_EX:
		inc	esi
		jmp	_lCRScan
		;;----------------

		;;----------------
		;; include arg end
		_lbl:
		cmp	al,				17h
		jne	_next

;;		sub	dword ptr [_dInclArgCurr],	04h
		pop	esi
		jmp	_lCRScan
		;;----------------

		;;----------------
		;; add set def to include arg
		_lbl:
		cmp	al,			16h
		jne	_next

		mov	ebx,			esi
		xor	eax,			eax
		inc	esi

		_lInclArgSDAdd:
		inc	ebx
		mov	al,			byte ptr [ebx]

		cmp	al,			16h
		je	_lCRScan
		cmp	al,			0ah		;; nl
		je	_lCRScan
		cmp	al,			2fh		;; / (comments)
		je	_lCRScan
		cmp	byte ptr [_bAscii_00+eax],	ah
		je	_lInclArgSDAdd

		cmp	word ptr [edi-02h],	0a0dh
		jne	_lInclArgSDAddEX
		sub	edi,			02h

		_lInclArgSDAddEX:
		mov	dword ptr [edi],	65730a0dh	;; __se
		mov	dword ptr [edi+04h],	66656474h	;; def
		mov	byte ptr [edi+08h],	20h		;; bs
		add	edi,			09h
		jmp	_lCRScan
		;;----------------

;;----------------
;; for arg
_lbl:
cmp	al,			19h
jne	_next

inc	esi
mov	word ptr [edi],		1a28h	;; ( 1ah
add	edi,			02h

jmp	_lCRScan
;;----------------

		;;----------------
		;; textmacro fx
		_lbl:
		cmp	al,			11h
		jne	_next
		inc	esi

		lea	eax,			[edi+06h]
		mov	dword ptr [edi],	74747474h	;; tttt
		mov	dword ptr [edi+04h],	78013d29h	;; )={ 
		add	edi,			0ch
		push	eax
		jmp	_lCRScan

		_lbl:
		cmp	al,			12h
		jne	_next
		inc	esi

		lea	eax,			[edi+01h]
		mov	dword ptr [edi],	0078013dh	;; ={ 
		add	edi,			07h
		push	eax
		jmp	_lCRScan

		_lbl:
		cmp	al,			13h
		jne	_next

		inc	esi
		mov	byte ptr [edi],		28h		;; ( 
		mov	dword ptr [edi+01h],	74747474h
		add	edi,			05h
		jmp	_lCRScan

		_lbl:
		cmp	al,			14h
		jne	_next

		_lCRGFDD:
		inc	esi
		cmp	byte ptr [esi],		09h		;; tab
		je	_lCRGFDD
		cmp	byte ptr [esi],		20h		;; bs
		je	_lCRGFDD

;		inc	edi
;		_lCRGFGG:
;		dec	edi
;		cmp	byte ptr [edi],		20h

		mov	dword ptr [edi],	74747474h	;; tttt
		mov	byte ptr [edi+04h],	2ch		;; ,
		mov	dword ptr [edi+05h],	74747474h	;; tttt
		add	edi,			09h
		jmp	_lCRScan
		;;----------------

		;;----------------
		;; comments? vJass parser instruction?
		_lbl:
		cmp	ax,			2f2fh		;; //
		jne	_lCRCommTest_01
		cmp	byte ptr [esi+02h],	21h		;; !	
		jne	_lComm_00
		mov	dword ptr [edi],	20212f2fh	;; //!_
		add	edi,	04h
		add	esi, 	03h
		jmp	_lCRScanLineSx
		_lComm_00:
		inc	esi
cmp	byte ptr [esi],			16h		;; nl in incl args
je	_lCRScanLine
		cmp	byte ptr [esi],		00h
		je	_lCREnd
		cmp	word ptr [esi],		0a0dh
		jne	_lComm_00
		jmp	_lCRScanLine

		_lCRCommTest_01:
		cmp	ax,			2a2fh		;; /*
		jne	_next

		mov	edx,			01h
		_lCRCommNextEx:
		inc	esi
		_lCRCommNext:
		inc	esi
		cmp	byte ptr [esi],		00h
		je	_lCRErrorComm
		cmp	word ptr [esi],		2f2fh		;; //
		jne	_lCRCommNextX
		inc	esi
		_lCRCommRemX:
		inc	esi
		cmp	byte ptr [esi],		00h
		je	_lCREnd
		cmp	word ptr [esi],		0a0dh
		jne	_lCRCommRemX
		jmp	_lCRCommNextEx
		_lCRCommNextX:
		cmp	word ptr [esi],		2f2ah		;; */
		je	_lCRCommSX
		cmp	word ptr [esi],		2a2fh		;; /*
		jne	_lCRCommNext
		inc	edx
		jmp	_lCRCommNextEx
		_lCRCommSX:
		dec	edx
		jnz	_lCRCommNextEx
		add	esi,			02h
cmp	byte ptr [edi - 01h],		" "
jne	_lCRScan
mov	dl,				byte ptr [esi]
cmp	byte ptr [_bAscii_00+edx],	dh	;; bh = 00h
jne	_lCRScan
dec	edi
mov	byte ptr [edi],			00h
		jmp	_lCRScan

			;;----------------
			;; error
			_lCRErrorComm:
			mov	dword ptr [_xErrorTable],	offset _sErr_UnclosedComment
			mov	dword ptr [_xErrorTable+04h],	edi
			mov	dword ptr [edi],		2a2fh	;; /*
			add	edi,				02h
			mov	dword ptr [_xErrorTable+08h],	edi
			jmp	_lErrIn
			;;----------------
		;;----------------

		;;----------------
		;; textmacro arg
		_lbl:
		cmp	al,			24h		;; $
		jne	_next

		xor	eax,			eax
		mov	ebx,			esi
		inc	esi

		_lCRMArgFX:
		inc	ebx
		mov	al,			byte ptr [ebx]
		cmp	byte ptr [_bAscii_00+eax],	ah
		jne	_lCRMArgFX

		cmp	byte ptr [ebx],		24h		;; $
		je	_lCRMArgSF
		mov	word ptr [edi],		7830h		;; 0x
		add	edi,			02h
		jmp	_lCRScan

		_lCRMArgSF:
		mov	al,			byte ptr [esi-02h]
		cmp	byte ptr [_bAscii_00+eax],	ah
		jz	_lCRMArg_00

		mov	word ptr [edi],		2323h		;; ##
		mov	dword ptr [edi+02h],	74747474h	;; tttt
		add	edi,			06h
		jmp	_lCRMArg_01

		_lCRMArg_00:
		mov	dword ptr [edi],	74747474h	;; tttt
		add	edi,			04h

		_lCRMArg_01:
		movsb
		cmp	esi,			ebx
		jb	_lCRMArg_01

		inc	esi
		mov	al,			byte ptr [esi]
		cmp	byte ptr [_bAscii_00+eax],	ah

		je	_lCRMArg_02

		mov	dword ptr [edi],	74747474h	;; tttt
		mov	word ptr [edi+04h],	2323h		;; ##
		add	edi,			06h
		jmp	_lCRScan

		_lCRMArg_02:
		mov	dword ptr [edi],	74747474h	;; tttt
		add	edi,			04h
		cmp	byte ptr [esi],		24h		;; $
		jne	_lCRScan
		mov	word ptr [edi],		2323h		;; ##
		add	edi,			02h
		jmp	_lCRScan

		_lbl:
		cmp	ax,			3501h		;; #5
		jne	_next

		add	esi,			02h
		mov	word ptr [edi],		2f2fh		;; //
		add	edi,			02h
		jmp	_lCRScan
		;;----------------

		;;----------------
		;; error with */
		_lbl:
		cmp	ax,			2f2ah		;; */
		jne	_next

		mov	dword ptr [_xErrorTable],	offset _sErr_BadComment
		mov	dword ptr [_xErrorTable+04h],	edi
		mov	dword ptr [edi],		2f2ah	;; /*
		add	edi,				02h
		mov	dword ptr [_xErrorTable+08h],	edi
		jmp	_lErrIn
		;;----------------

		;;----------------
		;; line ex
		_lbl:
		cmp	al,			5ch		;; \ 
		jne	_next
		mov	edx,			esi

		_lCRSBS_00:
		inc	edx

		cmp	byte ptr [edx],		20h		;; bs
		je	_lCRSBS_00
		cmp	byte ptr [edx],		09h		;; tab
		je	_lCRSBS_00
		cmp	byte ptr [edx],		5ch		;; \ 
		je	_lCRSBS_00

		cmp	word ptr [edx],		2f2fh		;; //
		je	_lCRSBS_02

		cmp	word ptr [edx],		6201h		;; #b
		je	_lCRScanBS

		cmp	word ptr [edx],		0a0dh		;; nl
		je	_lCRSBS_01

		_lCRSBS_03:
		movsb
		jmp	_lCRScan

		_lCRSBS_01:
		inc	esi
		mov	word ptr [edx],		6201h		;; #b
		jmp	_lCRScan

		_lCRSBS_02:
		cmp	byte ptr [edx+02h],	21h		;; !
		je	_lCRSBS_03

		_lCRSBS_04:
		mov	byte ptr [edx],		20h		;; bs
		inc	edx

		cmp	word ptr [edx],		0a0dh		;; nl
		jne	_lCRSBS_04

		inc	esi
		mov	word ptr [edx],		6201h		;; #b
		jmp	_lCRScan
		;;----------------

		;;----------------
		;; ex new line
		_lbl:
		cmp	al,			3bh		;; ;
		jne	_next

cmp	byte ptr [_bPreForArgs],	00h
jne	_lCRPreForArsg

		inc	esi
		jmp	_lCRScanLine

_lCRPreForArsg:
dec	byte ptr [_bPreForArgs]
mov	dword ptr [edi],		001a2c1bh	;; 1bh , 1ah
inc	esi
add	edi,				03h
jmp	_lCRScan
		;;----------------

		;;----------------
		;; blocks
			;;----------------
			;; x
			_lbl:
			cmp	al,			7bh		;; {
			jne	_next

cmp	byte ptr [_bPreForScope],	00h
je	_lCRBlockCheck

dec	edi
cmp	byte ptr [edi],			")"
je	_lCRPreForBlockCorrect

	;;----------------
	;; error
	mov	dword ptr [_xErrorTable],	offset _sErr_Base
	mov	dword ptr [_xErrorTable + 04h],	esi
	inc	esi
	mov	dword ptr [_xErrorTable + 08h],	esi
	jmp	_lErrIn
	;;----------------

_lCRPreForBlockCorrect:
mov	byte ptr [_bPreForArgs],	00h
mov	byte ptr [_bPreForScope],	00h
mov	dword ptr [edi],		001a2c1bh	;; 1bh , 1ah
inc	esi
add	edi,				03h
push	0ffffffffh
jmp	_lCRScanLine


			_lCRBlockCheck:
			cmp	word ptr [edi-02h],	0a0dh
			jne	_lCRBlockCheckEnd
			sub	edi,			02h
			_lCRBlockCheckEnd:
			push	edi
			mov	word ptr [edi],		7801h		;; #x
			inc	esi
			add	edi,			06h
			jmp	_lCRScan				;; ???
			;;----------------

			;;----------------
			;; y
			_lbl:
			cmp	al,			7dh		;; }
			jne	_next
			_lCRCloseBlock:
			pop	eax
			test	eax,			eax
			jz	_lBlockErr

cmp	eax,			0ffffffffh
jne	_lCRCloseBlockEx
mov	dword ptr [edi],	0a0d291bh	;; 1bh ) nl
inc	esi
add	edi,			04h
jmp	_lCRScanLine

_lCRCloseBlockEx:
			cmp	word ptr [edi-02h],	0a0dh		;; new line
			je	_lCLAddNE
			mov	word ptr [edi],		0a0dh		;; new line

			add	edi,			02h
			_lCLAddNE:
			mov	dword ptr [eax+02h],	edi
			mov	word ptr [edi],		7901h		;; #y
			mov	dword ptr [edi+02h],	eax
			mov	dword ptr [edi+06h],	06060606h	;; ex backspace
			mov	dword ptr [edi+0ah],	06060606h
			mov	word ptr [edi+0eh],	0a0dh		;; new line

			inc	esi
			add	edi,			10h
			jmp	_lCRScanLine

				;;----------------
				;; error
				_lBlockErr:
				mov	dword ptr [_xErrorTable],	offset _sErr_BadBlock
				mov	dword ptr [_xErrorTable+04h],	edi
				mov	byte ptr [edi],			7dh	;; }
				inc	edi
				mov	dword ptr [_xErrorTable+08h],	edi

				jmp	_lErrIn
				;;----------------
			;;----------------
		;;----------------

		;;----------------
		;; return from included file
		_lbl:
		cmp	ax,			7201h		;; #r
		jne	_next

			;;----------------
			;; remove arg
			sub	dword ptr [_dInclArgCurr],	04h
			;;----------------

		_lRetnGuard:
		pop	eax					;; for safe
		test	eax,			eax
		jnz	_lIncRetErr
		pop	esi
		call	_imp__GlobalUnlock@4
		call	_imp__GlobalFree@4
		jmp	_lCRScanLine

			;;----------------
			;; error
			_lIncRetErr:
			mov	dword ptr [_xErrorTable],	offset _sErr_BadBlockInFile
			mov	dword ptr [_xErrorTable+04h],	eax
			inc	eax
			mov	dword ptr [_xErrorTable+08h],	eax
			jmp	_lErrIn
			;;----------------
		;;----------------

		;;----------------
		;; return from custom code
		_lbl:
		cmp	ax,			4601h		;; #F
		jne	_next

;;		push	dword ptr [_dCstMemAddr]
;;		call	_imp__GlobalUnlock@4
;;		push	dword ptr [_dCstMemHndl]
;;		call	_imp__GlobalFree@4

		mov	esi,			dword ptr [_dCstEsi]
		jmp	_lCRScanLine
		;;----------------

		;;----------------
		;; #b
		_lbl:
		cmp	ax,			6201h		;; #b
		jne	_next
		add	esi,			02h
		mov	byte ptr [edi],		20h		;; bs
		inc	edi
		jmp	_lCRScan
		;;----------------

		;;----------------
		;; strings
		_lbl:
		cmp	al,			22h		;; "
		jne	_next
		mov	ebp,			edi
		mov	ecx,			0800h
		jmp	_lCRStringDX

		_lCRStringEX:
		movsb
		_lCRStringDX:
		movsb
		_lCRStringSX:
		cmp	word ptr [esi],		0a0dh		;; nl
		jne	_lCRStringNext
		mov	word ptr [edi],		6e5ch		;; \n
		add	esi,			02h
		add	edi,			02h
		jmp	_lCRStringSX
		_lCRStringNext:
		cmp	byte ptr [esi],		00h		;; null
		je	_lCRStringError
		cmp	byte ptr [esi],		5ch		;; \ 
		je	_lCRStringEX
		dec	ecx
		jz	_lCRStringError
		cmp	byte ptr [esi],		22h		;; "
		jne	_lCRStringDX
		movsb
		jmp	_lCRScan

			;;----------------
			;; not closed string
			_lCRStringError:
			mov	dword ptr [_xErrorTable],	offset _sErr_UnclosedString
			mov	dword ptr [_xErrorTable+04h],	ebp
			mov	dword ptr [_xErrorTable+08h],	edi

			jmp	_lErrIn
			;;----------------
		;;----------------

		;;----------------
		;; null and other
		_lbl:
		cmp	al,			00h		;; null
		je	_lCREnd
		movsb
		jmp	_lCRScan
		;;----------------

		;;----------------
		_lCREnd:
		cmp	dword ptr [_dStackPos],	esp			
		je	_next
			;;----------------
			;; error
			mov	dword ptr [_xErrorTable],	offset _sErr_UnclosedBlock
			pop	eax
			add	eax,				02h
			mov	dword ptr [_xErrorTable+04h],	eax
			inc	eax
			mov	dword ptr [_xErrorTable+08h],	eax
			jmp	_lErrIn
			;;----------------
		_lbl:
		pop	eax					;; for safe
		;;----------------

	mov	esi,			dword ptr [esp+04h]
	add	edi,			04h
	mov	dword ptr [_dSynDesc],	offset _xSynDesc	;; reset
	push	edi
	;;----------------	

	mov	_dCurrStr,	offset _sProg_02
	mov	eax,		28h
	call	_lSetProg

	;;----------------
	;; build define block
	dec	esi
	mov	ebx,		dword ptr [_lDefXEX]
;;	mov	ebx,		offset _lDefX

		;;----------------
		;; sysdefines

			;;----------------
			;; date time
			push	offset _xSysTime
			call	_imp__GetLocalTime@4

			mov	ecx,				0ah
			xor	eax,				eax
			xor	edx,				edx
			mov	ax,				word ptr [_xSysTime]

			div	ecx
			add	dl,				30h
			mov	byte ptr [_sDate+03h],		dl
			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sDate+02h],		dl
			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sDate+01h],		dl
			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sDate],		dl

			mov	byte ptr [_sDate+04h],		2eh	;; .

			mov	al,				byte ptr [_xSysTime+02h]

			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sDate+06h],		dl
			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sDate+05h],		dl

			mov	byte ptr [_sDate+07h],		2eh	;; .

			mov	al,				byte ptr [_xSysTime+06h]

			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sDate+09h],		dl
			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sDate+08h],		dl

			mov	byte ptr [_sDate+0ah],		03h

			mov	al,				byte ptr [_xSysTime+08h]

			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sTime+01h],		dl
			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sTime],		dl

			mov	byte ptr [_sTime+02h],		3ah	;; :

			mov	al,				byte ptr [_xSysTime+0ah]

			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sTime+04h],		dl
			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sTime+03h],		dl

			mov	byte ptr [_sTime+05h],		3ah	;; :

			mov	al,				byte ptr [_xSysTime+0ch]

			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sTime+07h],		dl
			xor	edx,				edx
			div	ecx
			add	dl,				30h
			mov	byte ptr [_sTime+06h],		dl

			mov	byte ptr [_sTime+08h],		03h

			mov	dword ptr [ebx],		offset _sDateL
			mov	dword ptr [ebx+04h],		offset _sDate
			mov	dword ptr [ebx+10h],		offset _sTimeL
			mov	dword ptr [ebx+14h],		offset _sTime
			;;----------------

			;;----------------
			;; weather
			mov	dword ptr [ebx+20h],		offset _sWeatherL
			mov	dword ptr [ebx+24h],		offset _sWether
			;;----------------

			;;----------------
			;; version
			_lbl:
			mov	eax,				dword ptr [_dWarVerSL]
			mov	dword ptr [ebx+30h],		offset _sWarVer
			mov	dword ptr [ebx+34h],		eax
			;;----------------

			;;----------------
			;; count
			mov	dword ptr [ebx+40h],		offset _sCountL
			mov	dword ptr [ebx+44h],		offset _sCntSpec

			mov	dword ptr [ebx+50h],		offset _sCountSTL
			mov	dword ptr [ebx+54h],		offset _sCntSTSpec

			mov	dword ptr [ebx+60h],		offset _sCountIncL
			mov	dword ptr [ebx+64h],		offset _sCountInc

			mov	dword ptr [ebx+70h],		offset _sCountResL
			mov	dword ptr [ebx+74h],		offset _sCountRes
			;;----------------

			;;----------------
			;; funcname
			mov	dword ptr [ebx+80h],		offset _sFuncNameL
			mov	dword ptr [ebx+84h],		offset _sFuncName
			;;----------------

			;;----------------
			;; anonym
			mov	dword ptr [ebx+90h],		offset _sAnonymL
			mov	dword ptr [ebx+94h],		offset _sAnonym
			;;----------------

;;----------------
;; afl flag
mov	dword ptr [ebx+00a0h],		offset _sAFLDefL
mov	dword ptr [ebx+00a4h],		offset _sAFLDef
;;----------------

;;----------------
;; while
mov	dword ptr [ebx+00b0h],		offset _sWhileMcrL
mov	dword ptr [ebx+00b4h],		offset _sWhileMcr

mov	dword ptr [ebx+00c0h],		offset _sEndWhileMcrL
mov	dword ptr [ebx+00c4h],		offset _sEndWhileMcr
;;----------------

;;----------------
;; custom j
mov	dword ptr [ebx+00d0h],		offset _sImportBJL
mov	dword ptr [ebx+00d4h],		offset _sImportBJ

mov	dword ptr [ebx+00e0h],		offset _sImportCJL
mov	dword ptr [ebx+00e4h],		offset _sImportCJ
;;----------------

;;----------------
;; for
mov	dword ptr [ebx+00f0h],		offset _sForpMacroL
mov	dword ptr [ebx+00f4h],		offset _sForp3Macro
mov	dword ptr [ebx+00fch],		03h

mov	dword ptr [ebx+0100h],		offset _sForpMacroL
mov	dword ptr [ebx+0104h],		offset _sForp4Macro
mov	dword ptr [ebx+010ch],		04h

mov	dword ptr [ebx+0110h],		offset _sForMacroL
mov	dword ptr [ebx+0114h],		offset _sFor3Macro
mov	dword ptr [ebx+011ch],		03h

mov	dword ptr [ebx+0120h],		offset _sForMacroL
mov	dword ptr [ebx+0124h],		offset _sFor4Macro
mov	dword ptr [ebx+012ch],		04h

mov	dword ptr [ebx+0130h],		offset _sForMacroL
mov	dword ptr [ebx+0134h],		offset _sFor2Macro
mov	dword ptr [ebx+013ch],		02h

mov	dword ptr [ebx+0140h],		offset _sForpMacroL
mov	dword ptr [ebx+0144h],		offset _sFor2Macro
mov	dword ptr [ebx+014ch],		02h
;;----------------

;;----------------
;; def arsg
mov	dword ptr [ebx+0150h],		offset _sArgMacrolL
mov	dword ptr [ebx+0154h],		offset _sArgMacrol
mov	dword ptr [ebx+015ch],		01h
;;----------------

			;;----------------
			;; debug
			cmp	dword ptr [_dDbgOff],		offset _lCRDebugAdd
			jne	_next

			mov	dword ptr [ebx+0160h],		offset _sDebugL
			mov	dword ptr [ebx+0164h],		offset _sTrue
			add	ebx,				10h
			_lbl:
			;;----------------

		add	ebx,				0160h

;;----------------
;; firstword
mov	ecx,				offset _sFirstWord
mov	eax,				01h

_lFirstWordAdd:
mov	dword ptr [ebx],		offset _sFirstWordL
mov	dword ptr [ebx + 04h],		ecx
mov	dword ptr [ebx + 0ch],		eax

inc	eax
add	ebx,				10h
cmp	eax,				11h
je	_lFirstWordAddEnd

lea	ecx,				[ecx + 05h + eax - 01h]
jmp	_lFirstWordAdd

_lFirstWordAddEnd:
;;----------------
		;;----------------

	xor	ecx,		ecx		;; current scope = 00h
	mov	_dStackPos,	esp		;; save stack

		;;----------------
		;; line start
		_lLineStart:
		inc	esi
		_lLineStartEx:
		mov	eax,			dword ptr [esi]
		;;----------------

		;;----------------
		;; define in
		_lbl:
		cmp	eax, 			69666564h	;; defi
		jne	_next
		cmp	word  ptr [esi+04h],	656eh		;; ne
		jne	_next
		cmp	byte ptr [esi+06h],	20h		;; _
		jg	_lDefInEX

		mov	eax,			esi
		jne	_lBlockCheckPre
		inc	esi
		_lBlockCheckPre:
		add	esi,			06h
		cmp	word ptr [esi],		0a0dh		;; nl
		jne	_lBlockCheck_01				;; single constant or block
		add	esi,			02h
		mov	edx,			offset _lDefEx
		mov	word ptr [eax],		6401h		;; #d
		jmp	_lDefEx

		_lBlockCheck_01:
		cmp	word ptr [esi],		7801h		;; #x
		jne	_lBlockCheck_02				;; single constant
		mov	word ptr [eax],		6401h		;; #d
		mov	eax,			dword ptr [esi+02h]
		add	esi,			06h
		mov	dword ptr [eax],	6e650a0dh	;; __en
		mov	dword ptr [eax+04h],	66656464h	;; ddef
		mov	dword ptr [eax+08h],	20656e69h	;; ine_
		mov	edx,			offset _lDefEx
		jmp	_lDefEx
		_lBlockCheck_02:
		mov	edx,			offset _lLineStartEx
		mov	word ptr [eax],		6301h		;; #c
		jmp	_lDefEx

		_lDefInEX:
		cmp	byte ptr [esi+06h],	3ch		;; <
		jne	_next
		mov	word ptr [esi],		6301h		;; #c
		mov	edx,			offset _lLineStartEx
		add	esi,			06h
		jmp	_lDefEx
		;;----------------

		;;----------------
		;; enum in
		_lbl:
		cmp	eax,			6d756e65h	;; enum
		jne	_next
		cmp	byte ptr [esi+04h],	28h		;; ( 
		je	_lEnumInEX
		cmp	byte ptr [esi+04h],	20h		;; bs
		jg	_next
		je	_lEnumInBase
		mov	ebp,				offset _dEnumDefTable-04h
		jmp	_lEnumInBlock
		;;----------------

		;;----------------
		;; undef
		_lbl:
		cmp	eax,			65646e75h	;; unde
		jne	_next
		cmp	word ptr [esi+04h],	2066h		;; f_
		je	_lUndefNorm

		cmp	word ptr [esi+04h],	3c66h		;; f<
		jne	_next

			;;----------------
			;; hard
			mov	word ptr [esi],		7501h		;; #u
			add	esi,			06h
			_lUndefHard:
			inc	esi
			cmp	byte ptr [esi],		3eh	;; >
			jne	_lUndefHard
			mov	byte ptr [esi],		02h
			jmp	_lLineStartEx
			;;----------------

			;;----------------
			;; norm
			_lUndefNorm:
			mov	word ptr [esi],		7501h		;; #u
			add	esi,			06h
			_lUndefNormEX:
			inc	esi
			cmp	word ptr [esi],		0a0dh	;; nl
			jne	_lUndefNormEX
			mov	byte ptr [esi],		02h
			jmp	_lLineStartEx
			;;----------------
		;;----------------

		;;----------------
		;; setdef
		_lbl:
		cmp	eax,			64746573h	;; setd
		jne	_next
		cmp	word ptr [esi+04h],	6665h		;; ef
		jne	_next
		cmp	byte ptr [esi+06h],	3ch		;; <
		je	_lSetdefHard
		cmp	byte ptr [esi+06h],	20h		;; bs
		jne	_next

		push	ebx
		mov	edx,			offset _lSetdefExit
		xor	eax,			eax
		xor	ebp,			ebp
		lea	edi,			[esi+02h]
		mov	byte ptr [esi],		08h		;; setdef
		add	esi,			06h
		mov	ebx,			_dDefTableSD+_dDFSize

		_lSetdef:
		inc	esi
		mov	al,			byte ptr [esi]
		cmp	byte ptr [_bAscii_00+eax],	ah	;; ah = 00h
		jne	_lSetdef

		_lSetdefEX:
		cmp	byte ptr [esi],		3dh		;; =
		je	_lSetdefClose
		cmp	word ptr [esi],		2928h		;; () 
		je	_lSetdefFVEX

			;;----------------
			;; macro
			mov	byte ptr [esi],		02h
			mov	ebp,			esi
			_lSetdefArg:
			inc	esi
			cmp	byte ptr [esi],		3dh		;; =
			jne	_lSetdefArg
			;;----------------

			;;----------------
			;; close setdef
			_lSetdefClose:
			mov	byte ptr [esi],		02h
			inc	esi

			cmp	word ptr [esi],		7801h		;; #x
			je	_lSetdefMultiline

			mov	dword ptr [edi],		esi
			dec	edi
			mov	dword ptr [_dDefTableSD+04h],	esi
			push	edi
			jmp	_lDFFindValueEndRE			;; !!!

			_lSetdefMultiline:
			mov	eax,			dword ptr [esi+02h]
			add	esi,			06h
			mov	dword ptr [edi],	esi
;;			mov	byte ptr [eax],		03h
mov	byte ptr [eax-02h],		03h

mov	dword ptr [_dDefTableSD+04h],		esi

dec	edi
push	edi
			jmp	_lDFFindValueEndEG
			;;----------------

		_lSetdefFVEX:
		add	esi,			02h
		jmp	_lSetdefClose

		_lSetdefHard:
push	ebx
mov	edx,			offset _lSetdefExit
xor	ebp,			ebp
lea	edi,			[esi+02h]
mov	byte ptr [esi],		08h		;; setdef
add	esi,			06h
mov	ebx,			_dDefTableSD+_dDFSize
		_lSetdefHardEX:
		inc	esi
		cmp	byte ptr [esi],		3eh	;; >
		jne	_lSetdefHardEX
mov	byte ptr [esi],		02h
inc	esi
		jmp	_lSetdefEX

			;;----------------
			;; restore ebx
			_lSetdefExit:
			pop	edi
			mov	eax,			dword ptr [_dDefTableSD+0ch]
			mov	byte ptr [edi],		al
			mov	dword ptr [_dDefTableSD+0ch],	00h
			pop	ebx
			jmp	_lLineStartEx
			;;----------------
		;;----------------

		;;----------------
		;; scope
		_lbl:
		cmp	eax, 			706f6373h	;; scop
		jne	_next
		cmp	byte  ptr [esi+04h],	65h		;; e
		jne	_next
		cmp	byte ptr [esi+05h],	20h		;; _
		jg	_next
		add	esi,			05h
		_lScopeIn:
		inc	esi
		cmp	word ptr [esi],		0a0dh
		je	_lLSIn
		cmp	word ptr [esi],		7801h		;; #x
		jne	_lScopeIn
		mov	eax,			dword ptr [esi+02h]
		mov	dword ptr [esi],	05050505h
		mov	word ptr [esi+04h],	0a0dh
		add	esi,			04h
		cmp	word ptr [eax-02h],	0a0dh
		je	_lScopeInEX
		mov	word ptr [eax],		0a0dh
		add	eax,			02h
		_lScopeInEX:
		mov	dword ptr [eax],	73646e65h	;; ends
		mov	dword ptr [eax+04h],	65706f63h	;; cope
		_lLSIn:
		push	ecx
		inc	dword ptr [_dFreeScope]
		mov	ecx,			_dFreeScope
		lea	eax,			[offset _dScopeIn+ecx*04h]
		mov	dword ptr [eax],	esi
		jmp	_lNextLineSx
		;;----------------

		;;----------------
		;; library
		_lbl:
		cmp	eax,			7262696ch	;; libr
		jne	_next
		cmp	dword ptr [esi+03h],	79726172h	;; rary
		jne	_next
		cmp	dword ptr [esi+07h],	636e6f5fh	;; _onc
		jne	_lLibExTest
		cmp	byte ptr [esi+0bh],	65h		;; e
		jne	_lLibExTest
		cmp	byte ptr [esi+0ch],	20h		;; _
		jg	_lLibExTest
		add	esi,			0eh
		jmp	_lLibInEX
		_lLibExTest:
		cmp	byte ptr [esi+07h],	20h		;; _
		jg	_next
		add	esi,			08h
		_lLibIn:
		inc	esi
		_lLibInEX:
		cmp	word ptr [esi],		0a0dh
		je short	_lLSIn
		cmp	word ptr [esi],		7801h		;; #x
		jne	_lLibIn
		mov	eax,			dword ptr [esi+02h]
		mov	dword ptr [esi],	05050505h
		mov	word ptr [esi+04h],	0a0dh
		add	esi,			04h
		cmp	word ptr [eax-02h],	0a0dh
		je	_lLibInSX
		mov	word ptr [eax],		0a0dh
		add	eax,			02h
		_lLibInSX:
		mov	word ptr [eax],		6e65h		;; en
		mov	dword ptr [eax+02h],	62696c64h	;; dlib
		mov	dword ptr [eax+06h],	79726172h	;; rary
		jmp	_lLSIn
		;;----------------

		;;----------------
		;; endscope
		_lbl:
		cmp	eax,			73646e65h	;; ends
		jne	_next
		cmp	dword ptr [esi+04h],	65706f63h	;; cope
		jne	_next
		cmp	byte ptr [esi+08h],	20h		;; _
		jg	_next
		;;----------------

		;;----------------
		;; scope/library out
		_lOut:
		test	ecx,			ecx
		jz	_lLibScpErr
		lea	eax,			[offset _dScopeOut+ecx*04h]
		mov	dword ptr [eax],	esi
		pop	ecx
		jmp	_lNextLineSx

			;;----------------
			;; error
			_lLibScpErr:
			mov	dword ptr [_xErrorTable],	offset _sErr_EndLibScope
			mov	dword ptr [_xErrorTable+04h],	esi
			_lLibScpErrEX:
			inc	esi
			cmp	word ptr [esi],			0a0dh	;; nl
			jne	_lLibScpErrEX
			mov	dword ptr [_xErrorTable+08h],	esi
			jmp	_lErrIn
			;;----------------
		;;----------------

		;;----------------
		;; endlibrary
		_lbl:
		cmp	eax,				6c646e65h	;; endl
		jne	_lNextLineSx
		cmp	dword ptr [esi+04h],		61726269h	;; ibra
		jne	_lNextLineSx
		cmp	word ptr [esi+08h],		7972h		;; ry
		jne	_lNextLineSx
		cmp	byte ptr [esi+0ah],		20h		;; _
		jbe	_lOut
		;;----------------

		;;----------------
		;; search new line
		_lNextLineEx:
		inc	esi
		_lNextLineSx:
		cmp	word  ptr [esi],		0a0dh		;; new line
		je	_next
		cmp	word ptr [esi],			7801h		;; #x
		je	_lNextLineDx
		cmp	word ptr [esi],			7901h		;; #y
		je	_lNextLineDx
		cmp	byte  ptr [esi],		00h
		jne	_lNextLineEx
		jmp	_lScanEnd
		_lbl:
		inc	esi
		jmp	_lLineStart

		_lNextLineDx:
		add	esi,				06h
		jmp	_lLineStartEx ; _lNextLineSx
		;;----------------

		;;----------------
		;; build enum
			;;----------------
			;; named enum

				;;----------------
				;; error
				_lEnumInErr:
				mov	dword ptr [_xErrorTable],	offset _sErr_Base
				mov	dword ptr [_xErrorTable+04h],	esi
				inc	esi
				mov	dword ptr [_xErrorTable+08h],	esi
				jmp	_lErrIn
				;;----------------

			_lEnumInEX:
			xor	eax,				eax
			add	esi,				05h
			mov	dword ptr [_dBuffer],		esi
			mov	ebp,				offset _xEnumLabel
			mov	edi,				dword ptr [ebp]
			test	edi,				edi
			jz	_lEnumInEXCreateNew

			_lEnumInEXCheck:
			lodsb
			cmp	byte ptr [_bAscii_00+eax],	ah	;; ah = 00h
			jne	_lEnumInEXCheckEX

			cmp	al,				29h	;; ) 
			jne	_lEnumInErr
			scasb
			jne	_lEnumInEXGetNext
			mov	eax,				dword ptr [_dBuffer]
			sub	eax,				05h
			jmp	_lEnumInBlockEX

			_lEnumInEXCheckEX:
			scasb
			je	_lEnumInEXCheck

			_lEnumInEXGetNext:
			add	ebp,				0ch
			mov	edi,				dword ptr [ebp]
			mov	esi,				dword ptr [_dBuffer]
			test	edi,				edi
			jnz	_lEnumInEXCheck

			_lEnumInEXCreateNew:
			mov	dword ptr [ebp],		esi
			mov	edi,				dword ptr [_dEnumTablePointer]
			mov	dword ptr [edi],		80000000h
			mov	dword ptr [edi+04h],		0ffffffffh
			lea	eax,				[edi+0ch]
			mov	dword ptr [edi+08h],		eax
			mov	dword ptr [ebp+04h],		edi
			mov	dword ptr [edi+0ch],		00000000h
			mov	dword ptr [edi+10h],		7fffffffh
			mov	dword ptr [edi+14h],		00000000h
			lea	eax,				[edi+0ch]
			mov	dword ptr [ebp+08h],		eax
			add	edi,				18h
			mov	dword ptr [_dEnumTablePointer],	edi
			mov	eax,				dword ptr [_dBuffer]
			sub	eax,				05h

				;;----------------
				;; label
				mov	dword ptr [ebx+04h],		offset _sInt
				mov	dword ptr [ebx],		esi
				add	ebx,				10h
				;;----------------

			_lbl:
			inc	esi
			cmp	byte ptr [esi-01h],		29h		;; ) 
			jne	_prew

			mov	byte ptr [esi-01h],		02h		;; define label end

			jmp	_lEnumInBlockEX
			;;----------------

			;;----------------
			;; base enum
			_lEnumInBase:
			mov	word ptr [esi],			6301h		;; #c
			add	esi,				05h
			mov	ebp,				offset _dEnumDefTable-04h
			mov	dword ptr [_dBuffer],		offset _lLineStartEx
			jmp	_lEnumBStart
			;;----------------

			;;----------------
			;; block enum
			_lEnumInBlock:
			mov	eax,				esi
			add	esi,				04h
			_lEnumInBlockEX:
			cmp	word ptr [esi],			0a0dh		;; nl
			je	_lEnumInBlockFX
			cmp	word ptr [esi],			7801h		;; #x
			je	_lEnumInBlockSX
			;;----------------

			;;----------------
			;; single lined
			mov	dword ptr [_dBuffer],		offset _lLineStartEx
			mov	word ptr [eax],			6301h		;; #c
			jmp	_lEnumBStart
			;;----------------		

			;;----------------
			_lEnumInBlockSX:
			add	esi,				04h
			_lEnumInBlockFX:
			add	esi,				02h
			mov	dword ptr [_dBuffer],		offset _lEnumMStart
			mov	word ptr [eax],			6401h		;; #d
			jmp	_lEnumBStart
			;;----------------

			;;----------------
			;; start

				;;----------------
				;; exit from block
				_lEnumMStart:
				cmp	word ptr [esi],			7901h		;; #y
				jne	_lEnumMStartEX

				mov	word ptr [esi+0eh],		6401h		;; #d
				add	esi,				10h
				jmp	_lLineStartEx

				_lEnumMStartEX:
				cmp	dword ptr [esi],		65646e65h	;; ende
				jne	_lEnumBStart
				cmp	word ptr [esi+04h],		756eh		;; nu
				jne	_lEnumBStart
				cmp	byte ptr [esi+06h],		6dh		;; m
				jne	_lEnumBStart
				cmp	byte ptr [esi+07h],		20h		;;
				jg	_lEnumBStart
				cmp	word ptr [esi+07h],		0a0dh		;; nl
				jne	_lEnumInErr

				mov	word ptr [esi+07h],		6401h		;; #d
				add	esi,				09h
				jmp	_lLineStartEx
				;;----------------

			_lEnumBStart:

				;;----------------
				;; private ?
				cmp	dword ptr [esi],		76697270h	;; priv
				jne	_next
				cmp	dword ptr [esi+04h],		20657461h	;; ate_
				jne	_next
				add	esi,				08h
				mov	dword ptr [ebx+08h],		ecx
				;;----------------

			_lbl:
			mov	dword ptr [ebx],		esi	;; label

			cmp	byte ptr [esi],			3ch	;; <
			jne	_lEnumNorm

				;;----------------
				;; hard enum
				inc	dword ptr [ebx]
				_lEnumHard:
				inc	esi
				cmp	byte ptr [esi],			3eh	;; >
				jne	_lEnumHard

				mov	byte ptr [esi],			02h	;; label end 
				inc	esi
				jmp	_lEnumCheckRange
				;;----------------

				;;----------------
				;; norm enum
				_lEnumNorm:
				xor	eax,				eax
				dec	esi
				_lEnumNormEX:
				inc	esi
				mov	al,				byte ptr [esi]
				cmp	byte ptr [_bAscii_00+eax],	ah	;; ah = 00h
				jnz	_lEnumNormEX
				;;----------------

				;;----------------
				;; ranged?
				_lEnumCheckRange:
				cmp	byte ptr [esi],				28h	;; ( 
				je	_lEnumRanged
				;;----------------

				;;----------------
				;; simple
				cmp	byte ptr [esi],			2ch	;; ,
				jne	_next

				mov	byte ptr [esi],			02h	;; label end
				inc	esi
				jmp	_lEnumNextLabel

				_lbl:
				cmp	word ptr [esi],			0a0dh	;; nl
;				jne
				mov	word ptr [esi],			0702h	;; label end ; enum out
				add	esi,				02h

				_lEnumNextLabel:
				mov	edi,				dword ptr [ebp+08h]
				mov	eax,				dword ptr [edi]
				cmp	eax,				dword ptr [edi+04h]
;				je
				inc	dword ptr [edi]
				;;----------------

				;;----------------
				;; calculate string
				push	ebp

				mov	edi,				dword ptr [_dEnumStrPoint]
				mov	ebp,				0ah
				mov	byte ptr [edi],			03h	;; define value end
				_lbl:
				dec	edi
				xor	edx,				edx
				div	ebp
				add	edx,				30h
				mov	byte ptr [edi],			dl
				test	eax,				eax
				jnz	_prew

				mov	dword ptr [ebx+04h],		edi
				add	ebx,				_dDFSize

				add	edi,				0dh
				mov	dword ptr [_dEnumStrPoint],	edi

				pop	ebp
				jmp	dword ptr [_dBuffer]
				;;----------------

				;;----------------
				;; ranged
				_lEnumRanged:
				;;----------------
			;;----------------

		;;----------------

		;;----------------
		;; build defines
		_lDefEx:
		mov	eax,			dword ptr [esi]

		cmp	ax,			0a0dh
		jne	_lDefCheck
		add	esi,			02h
		jmp	_lDefEx

			;;----------------
			;; exit
			_lDefCheck:
			cmp	eax,			64646e65h	;; endd
			jne	_next
			cmp	dword ptr [esi+04h],	6e696665h	;; efin
			jne	_next
			cmp	byte ptr [esi+08h],	65h		;; e
			jne	_next
			cmp	byte ptr [esi+09h],	20h		;; _
			jg	_next

			cmp	byte ptr [esi+0ah],	06h
			jne	_lDefExitEX
			add	esi,			05h

			_lDefExitEX:
			add	esi,			09h
			mov	word ptr [esi-02h],	6401h		;; #d
			jmp	_lLineStartEx
			;;----------------

			;;----------------
			;; private ?
			_lDefPrivEX:
			cmp	dword ptr [esi+04h],	3c657461h	;; ate<
			jne	_next
			add	esi,			07h
			jmp	_lDefPrivSX

			_lbl:
			cmp	eax,			76697270h	;; priv
			jne	_next
			cmp	dword ptr [esi+04h],	20657461h	;; ate_
			jne	_lDefPrivEX
			add	esi,			08h
			_lDefPrivSX:
			mov	dword ptr [ebx+08h],	ecx
			;;----------------

			;;----------------
			;; define label
			_lbl:
			mov	dword ptr [ebx],	esi	;; find label
			mov	al,			byte ptr [esi]
			xor	ebp,			ebp
			;;----------------

		cmp	al,			3ch	;; <
		jne	_lDefNorm
		inc	dword ptr [ebx]

		_lDefHard:
		inc	esi
		cmp	byte ptr [esi],		3eh	;; >
		jne	_lDefHard
		mov	byte ptr [esi],		02h
		inc	esi
		cmp	byte ptr [esi],		3dh	;; =
		je	_lDFFindValue
		cmp	byte ptr [esi],		28h	;; (
		je	_lDFFindArgValue
		cmp	word ptr [esi],		0a0dh	;; nl
		je	_lDFNull

			;;----------------
			;; error
			_lDefErrorBase:
			mov	dword ptr [_xErrorTable],	offset _sErr_BadDef
			mov	dword ptr [_xErrorTable+04h],	esi
			inc	esi
			mov	dword ptr [_xErrorTable+08h],	esi
			jmp	_lErrIn
			;;----------------

			;;----------------
			;; check first char
			_lDefNorm:
			cmp	al,			41h
			jb	_lDefErrorBase
			cmp	al,			5ah
			jbe	_next
			cmp	al,			61h
			jb	_lDefErrorBase
			cmp	al,			7ah
			jg	_lDefErrorBase
			;;----------------

			;;----------------
			;; check define label
			_lbl:
			inc	esi
			mov	al,			byte ptr [esi]
			cmp	al,			3dh	;; =
			je	_lDFFindValue
			cmp	al,			28h	;; (
			je	_lDFFindArgValue
			cmp	word ptr [esi],		0a0dh	;; nl
			je	_lDFNull

			cmp	al,			5fh
			je	_prew
			cmp	al,			30h
			jb	_lDefErrorBase
			cmp	al,			39h
			jbe	_prew
			cmp	al,			41h
			jb	_lDefErrorBase
			cmp	al,			5ah
			jbe	_prew
			cmp	al,			61h
			jb	_lDefErrorBase
			cmp	al,			7ah
			jg	_lDefErrorBase
			jmp	_prew
			;;----------------

			;;----------------
			;; null define
			_lDFNullEX:
			mov	dword ptr [esi],	02h
			add	esi,			02h
			_lDFNull:
			mov	word ptr [esi],		0302h		;; label end ; def end
			inc	esi
			mov	dword ptr [ebx+04h],	esi
			add	ebx,			_dDFSize
			inc	esi
			jmp	edx
			;;----------------

			;;----------------
			;; macros
			_lDFFindArgValue:
			cmp	dword ptr [esi],	0a0d2928h	;; () nl
			je	_lDFNullEX
			cmp	word ptr [esi],		2928h		;; ()
			jne	_lDFFindArgValueSX
			mov	byte ptr [esi],		02h
			add	esi,			03h
			jmp	_lDFFindValueTX

			_lDFFindArgValueSX:
			mov	byte ptr [esi],		02h
			mov	ebp,			esi
			_lDFFindArgValueRe:
			inc	esi
			cmp	word ptr [esi],		0a0dh		;; nl
			je	_lDFFindValueEndFS
			cmp	byte ptr [esi],		3dh		;; =
			jne	_lDFFindArgValueRe
			;;----------------

			;;----------------
			;; close define
			_lDFFindValue:
			mov	byte ptr [esi],		02h
			inc	esi
			;;----------------

			;;----------------
			;; is it multilined define?
			_lDFFindValueTX:
			cmp	word ptr [esi],		7801h		;; #x
			je	_lDFFindValueEndEx
			;;----------------

			;;----------------
			mov	dword ptr [ebx+04h],	esi
			add	ebx,			_dDFSize
			;;----------------

			;;----------------
			_lDFFindValueEndRE:
			cmp	word ptr [esi],		0a0dh		;; nl
			je	_lDFFindValueEndRR

			_lDFFindValueEnd:
			inc	esi
_lDFFindValueEndZX:
cmp	word ptr [esi],		7801h	;; #X
jne	_lDFFindValueEndFF
mov	esi,			dword ptr [esi+02h]
add	esi,			06h
jmp	_lDFFindValueEndZX
_lDFFindValueEndFF:
			cmp	word ptr [esi],		0a0dh		;; nl
			jne	_lDFFindValueEnd
			_lDFFindValueEndRR:
			mov	byte ptr [esi],		03h
			add	esi,			02h
			jmp	_lDFArcCheckStart

			_lDFFindValueEndFS:
			mov	word ptr [esi],		0302h		;; label end ; def end
			inc	esi
			mov	dword ptr [ebx+04h],	esi
			add	ebx,			_dDFSize
			inc	esi
			jmp	_lDFArcCheckStart
			;;----------------

			;;----------------
			;; multilined define
			_lDFFindValueEndEx:
			mov	eax,			dword ptr [esi+02h]
			add	esi,			06h
			mov	dword ptr [ebx+04h],	esi
			add	ebx,			_dDFSize
;;			mov	byte ptr [eax],		03h
mov	byte ptr [eax-02h],		03h
			_lDFFindValueEndEG:
			lea	esi,			[eax+05h]
			_lDFFindValueEndES:
			inc	esi
			cmp	word ptr [esi],		0a0dh
			jne	_lDFFindValueEndES
			add	esi,			02h
;;			jmp	_lDFArcCheckStart
			;;----------------

			;;----------------
			;; parse arguments
			_lDFArcCheckStart:
			test	ebp,			ebp
			jnz	_lDFEAXLoad
			jmp 	edx			;; exit

			_lDFEAXLoad:
			mov	ah,			7fh
			_lDFNextArg:
			inc	ebp
			cmp	byte ptr [ebp],		29h	;; )
			jne	_lDFArgReplace
			jmp	edx			;; exit - all arguments parsed

			_lDFArgReplace:
			push	ebp
			inc	ah
			inc	dword ptr [ebx+0ch-_dDFSize]
			mov	edi,			dword ptr [ebx+04h-_dDFSize]

			dec	edi
			_lDFArgSearchWord:
			inc	edi
			_lDFArgSearchWordEx:
			cmp	byte ptr [edi],		03h
			je	_lDFArgCheckEnd

				;;----------------
				;; strings
				cmp	byte ptr [edi],		22h	;; "
				jne	_lDFArgSearchWordSx
				_lDFArgSearchWordDx:
				inc	edi
				_lDFArgSearchWordRx:
				cmp	byte ptr [edi],		03h
				je	_lDFArgCheckEnd
				cmp	byte ptr [edi],		5ch	;; \ 
				jne	_lDFArgSearchWordFx
				add	edi,			02h
				jmp	_lDFArgSearchWordRx
				_lDFArgSearchWordFx:
				cmp	byte ptr [edi],		22h	;; "
				jne	_lDFArgSearchWordDx
				jmp	_lDFArgSearchWord
				;;----------------

			_lDFArgSearchWordSx:
			cmp	byte ptr [edi],		01h
			je	_lDFArgSearchWordSS
			cmp	byte ptr [edi],		30h
			jb	_lDFArgSearchWord
			cmp	byte ptr [edi],		3ah
			jb	_lDFArgNextWord
			cmp	byte ptr [edi],		41h
			jb	_lDFArgSearchWord
			cmp	byte ptr [edi],		5bh
			jb	_lDFArgCheckWord
			cmp	byte ptr [edi],		5fh
			je	_lDFArgCheckWord
			cmp	byte ptr [edi],		61h
			jb	_lDFArgSearchWord
			cmp	byte ptr [edi],		7bh
			jb	_lDFArgCheckWord
			cmp	byte ptr [edi],		7ch
			je	_lDFArgSearchWord

			_lDFArgNextWord:
			inc	edi
			_lDFArgNextWordSS:
			cmp	byte ptr [edi],		30h
			jb	_lDFArgSearchWordEx
			cmp	byte ptr [edi],		3ah
			jb	_lDFArgNextWord
			cmp	byte ptr [edi],		41h
			jb	_lDFArgSearchWordEx
			cmp	byte ptr [edi],		5bh
			jb	_lDFArgNextWord
			cmp	byte ptr [edi],		5fh
			je	_lDFArgNextWord
			cmp	byte ptr [edi],		61h
			jb	_lDFArgSearchWordEx
			cmp	byte ptr [edi],		7bh
			jb	_lDFArgNextWord
			jmp	_lDFArgSearchWordEx

				;;----------------
				;; special
				_lDFArgSearchWordSS:
				cmp	word ptr [edi],		7801h	;; #x
				je	_lDFArgSearchWordSSEX
				cmp	word ptr [edi],		7901h	;; #y
				je	_lDFArgSearchWordSSEX

				cmp	word ptr [edi],		6901h	;; #i
				jne	_lDFArgSearchWordSSNorm

add	edi,			02h
jmp	_lDFArgNextWord
;				jmp	_lDFArgSearchWordSx

				_lDFArgSearchWordSSEX:
				add	edi,			06h
				jmp	_lDFArgSearchWordSx

				_lDFArgSearchWordSSNorm:
				add	edi,			02h
				jmp	_lDFArgSearchWordSx
				;;----------------

			_lDFArgCheckWord:
			mov	ebp,			dword ptr [esp]
			mov	dword ptr [_dBuffer],	edi
			jmp	_lDFArgCheckWordStartEX

			_lDFArgCheckWordStart:
			inc	ebp
			inc	edi
			_lDFArgCheckWordStartEX:
			mov	al,			byte ptr [ebp]
			cmp	al,			29h
			je	_lDFArgCheckWordEnd
			cmp	al,			2ch
			je	_lDFArgCheckWordEnd
			cmp	al,			30h
			jb	_lDFArgCheckError ;_lDFArgCheckWordEnd
			cmp	al,			3ah
			jb	_lDFArgCheckTest
			cmp	al,			41h
			jb	_lDFArgCheckError ;_lDFArgCheckWordEnd
			cmp	al,			5bh
			jb	_lDFArgCheckTest
			cmp	al,			5fh
			je	_lDFArgCheckTest
			cmp	al,			61h
			jb	_lDFArgCheckError ;_lDFArgCheckWordEnd
			cmp	al,			7bh
			jb	_lDFArgCheckTest

				;;----------------
				;; error
				_lDFArgCheckError:
				mov	dword ptr [_xErrorTable],	offset _sErr_BadChar
				mov	dword ptr [_xErrorTable+04h],	ebp
				inc	ebp
				mov	dword ptr [_xErrorTable+08h],	ebp
				jmp	_lErrIn
				;;----------------

			_lDFArgCheckTest:
			cmp	al,			byte ptr [edi]
			jne	_lDFArgNextWordSS
			jmp	_lDFArgCheckWordStart

			_lDFArgCheckWordEnd:
			mov	al,			byte ptr [edi]
			cmp	al,			30h
			jb	_lDFArgCheckWordEndFx
			cmp	al,			3ah
			jb	_lDFArgNextWord
			cmp	al,			41h
			jb	_lDFArgCheckWordEndFx
			cmp	al,			5bh
			jb	_lDFArgNextWord
			cmp	al,			5fh
			je	_lDFArgNextWord
			cmp	al,			61h
			jb	_lDFArgCheckWordEndFx
			cmp	al,			7bh
			jb	_lDFArgNextWord			

			_lDFArgCheckWordEndFx:
			mov	ebp,			dword ptr [_dBuffer]
			_lDFArgCheckWordEndEx:
			mov	byte ptr [ebp],		05h	;; ex backspace
			inc	ebp
			cmp	ebp,			edi
			jne	_lDFArgCheckWordEndEx
			mov	byte ptr [edi-01h],	ah
			jmp	_lDFArgSearchWordEx

			_lDFArgCheckEnd:
			pop	ebp
			_lDFArgCheckEndEx:
			inc	ebp
			cmp	byte ptr [ebp],		29h		;; ) 
			jne	_lDFArgCheckEndSx
			jmp	edx
			_lDFArgCheckEndSx:
			cmp	byte ptr [ebp],		2ch		;; ,
			jne	_lDFArgCheckEndEx
			jmp	_lDFNextArg
			;;----------------

		;;----------------
		;; lib check
		_lScanEnd:
		cmp	esp,				_dStackPos
		je	_next

		lea	eax,				dword ptr [offset _dScopeIn+ecx*04h]
		mov	ebx,				dword ptr [eax]
		mov	dword ptr [_xErrorTable],	offset _sErr_UnclosedLib
		mov	eax,				ebx
		_lUncLibErr:
		dec	ebx
		cmp	word ptr [ebx-02h],		0a0dh
		jne	_lUncLibErr
		mov	dword ptr [_xErrorTable+04h],	ebx
		mov	dword ptr [_xErrorTable+08h],	eax
		jmp	_lErrIn
		;;----------------
	_lbl:
	;;----------------

	;;----------------
	;; sort define block
	cmp	ebx,			offset _lDefX+10h
	jbe	_lDFSortEnd

		;;----------------
		;; set step
		mov	eax,			offset _dSortSteps-04h

		sub	ebx,			offset _lDefX
;;		shr	edx,			02h		;; ??? why ?!
		_lbl:
		add	eax,			04h
		mov	ebp,			dword ptr [eax+04h]
		lea	ebp,			dword ptr [ebp+ebp*02h]
		cmp	ebx,			ebp
		jg	_prew
		;;----------------

	_lDFSordStart:
	mov	ecx,			dword ptr [eax]
	lea	ebx,			dword ptr [_lDefX+ecx]

	_lDFSordGo:
	mov	edi,			ebx
	mov	ebp,			dword ptr [ebx+08h]
	mov	esi,			dword ptr [ebx]
	mov	dl,			byte ptr [esi]
	movaps	xmm1,			[ebx]

	_lbl:
	sub	edi,			ecx
	cmp	edi,			offset _lDefX-10h
	jbe	_lDFSortNext
	mov	esi,			dword ptr [edi]
	cmp	byte ptr [esi],		dl
	jb	_lDFSortNext
	je	_lDFSortNextEx

	_lDFSortRe:
	movaps	xmm0,			[edi]
	movaps	[edi+ecx],		xmm0

	jmp	_prew
	
	_lDFSortNextEx:
	cmp	ebp,			dword ptr [edi+08h]
	jg	_lDFSortRe	

	_lDFSortNext:
	movaps	[edi+ecx],		xmm1	

	add	ebx,			10h
	cmp	dword ptr [ebx],	00h
	jnz	_lDFSordGo

	_lDFNextStep:
	sub	eax,			04h
	cmp	eax,			offset _dSortSteps-04h
	jne	_lDFSordStart

	_lDFSortEnd:
	;;----------------

	;;----------------
	;; build find'n'replace table
	mov	eax,			offset _lDefX-10h
	mov	edx,			offset _dDefTable
	xor	ebx,			ebx
	xor	ecx,			ecx

	_lDFTableBld:
	add	eax,			10h
	cmp	dword ptr [eax],	00h
	je	_lDFBuildEnd
	mov	ebp,			dword ptr [eax]
	mov	bl,			byte ptr [ebp]

	cmp	cl,			bl
	je	_lDFTableBld
	mov	[edx+ebx*04h],		eax
	mov	cl,			bl
	jmp	_lDFTableBld

	_lDFBuildEnd:
	;;----------------

	;;----------------
	;; check defines table
	mov	ebx,			offset _lDefX-10h

	_lDFTableCheckNext:
	add	ebx,			10h
	cmp	dword ptr [ebx],	00h
	jz	_lDFTableCheckEnd

	mov	edx,			dword ptr [ebx]			;; edx = string addr
	mov	ah,			byte ptr [edx]
	mov	ebp,			ebx				;; ebp = checked struct

		;;----------------
		;; check next defines
		_lDFTableCheckStart:
		add	ebp,			10h
		cmp	dword ptr [ebp],	00h
		je	_lDFTableCheckNext
		mov	edi,			dword ptr [ebp]		;; checked string
		cmp	byte ptr [edi],		ah
		jne	_lDFTableCheckNext

			;;----------------
			;; check own lib
			mov	esi,			dword ptr [ebp+08h]
			cmp	esi,			dword ptr [ebx+08h]
			jne	_lDFTableCheckStart
			;;----------------

			;;----------------
			;; check string 
			mov	esi,			edx			;; base string, edi loaded before

			_lbl:
			lodsb
			cmp	al,			02h
			je	_next
			scasb
			je	_prew
			jmp	_lDFTableCheckStart

			_lbl:
			scasb
			jne	_lDFTableCheckStart
			;;----------------

			;;----------------
			;; check arg count
			mov	esi,			dword ptr [ebp+0ch]
			cmp	esi,			dword ptr [ebx+0ch]
			je	_lDFTableCheckValue	;_lDFTableCheckStart

				;;----------------
				;; resort
				mov	esi,			ebp
				mov	edi,			ebx
				jb	_lDFTableCheckSort
				add	edi,			10h

				_lDFTableCheckSort:
				cmp	edi,			esi
				je	_lDFTableCheckSortEnd

				movaps	xmm0,			[esi]

				_lDFTableCheckSortEX:
				sub	esi,			10h
				movaps	xmm1,			[esi]
				movaps	[esi+10h],		xmm1

				cmp	edi,			esi
				jne	_lDFTableCheckSortEX

				movaps	[edi],			xmm0

				_lDFTableCheckSortEnd:
				mov	dword ptr [ebx+18h],	0ffffffffh	;; modify to overload define
				jmp	_lDFTableCheckStart
				;;----------------

			;;----------------

			;;----------------
			;; check value
			_lDFTableCheckValue:
			mov	esi,			dword ptr [ebp+04h]
			mov	edi,			dword ptr [ebx+04h]

			_lbl:
			lodsb
			cmp	al,			03h
			je	_next
			scasb
			je	_prew
			jmp	_lDFTableError

			_lbl:
			scasb
			je	_lDFTableCheckStart
			;;----------------

			;;----------------
			;; error
			_lDFTableError:
			mov	dword ptr [_xErrorTable],	offset _sErr_ValueRedefined
			mov	edi,				dword ptr [ebp]
			mov	dword ptr [_xErrorTable+04h],	edi
			_lbl:
			inc	edi
			cmp	byte ptr [edi],			02h
			jne	_prew
			mov	dword ptr [_xErrorTable+08h],	edi

			mov	dword ptr [_xErrorTable+10h],	offset _sErr_ValueRedefinedEX
			mov	edi,				dword ptr [ebx]
			mov	dword ptr [_xErrorTable+14h],	edi
			_lbl:
			inc	edi
			cmp	byte ptr [edi],			02h
			jne	_prew
			mov	dword ptr [_xErrorTable+18h],	edi

			jmp	_lErrIn
			;;----------------

		;;----------------

	_lDFTableCheckEnd:
	;;----------------

	mov	_dCurrStr,		offset _sProg_03
	mov	eax,			48h
	call	_lSetProg

	;;----------------
	;; find'n'replacing
	mov	_dStackPos,			esp		;; save stack
	mov	edi,				dword ptr [esp]
	mov	esi,				dword ptr [esp+08h]
	xor	eax,				eax
	jmp	_lXFPStart

	_lXFPNewWord:
	movsb
	_lXFPStart:

		;;----------------
		;; string preprocessor in
		cmp	dword ptr [esi],		73404021h	;; !@@s
		je	_lXFPStrPrIn
		cmp	dword ptr [esi],		65404021h	;; !@@e
		je	_lXFPStrPrOut
		;;----------------

	_lXFPStartFX:
	mov	al,				byte ptr [esi]

	cmp	al,				80h
	jb	_lXFPDFF

;;----------------
;; arguments
mov	edx,				dword ptr [_dAddrDefArgPnt]
inc	esi
sub	edx,				08h
sub	eax,				80h
mov	ecx,				dword ptr [edx]
push	esi
lea	ecx,				dword ptr [ecx+eax*08h+0ch]

mov	esi,				dword ptr [ecx]

	;;----------------
	mov	ecx,				dword ptr [edx+04h]
;;	mov	ecx,				dword ptr [ecx+04h]

	mov	ebx,				dword ptr [ecx]
	mov	dword ptr [edx+08h],		ebx
	mov	ebx,				dword ptr [ecx+04h]
	mov	dword ptr [edx+0ch],		ebx

	add	edx,				10h
	mov	dword ptr [_dAddrDefArgPnt],	edx
	;;----------------

jmp	_lXFPStart
;;----------------

		;;----------------
		;; check word
		_lXFPDFF:
		cmp	al,				41h
		jb	_lXFPGetNextEx

		lea	edx,				[_dDefTable+eax*04h]
		mov	edx,				dword ptr [edx]		;; edx = def block address
		test	edx,				edx
		jz	_lXFPGetNextEx

		mov	ecx,				esi			;; ecx = temt src script position
		mov	dword ptr [_dUndefPnt],		esi			;; for undef
		_lXFPCheck:
		mov	ebx,				dword ptr [edx]
		mov	al,				byte ptr [esi]
		cmp	al,				byte ptr [ebx]
		jne	_lXFPGetNext

		_lXFPCheckStart:
		inc	esi
		inc	ebx
		mov	al,				byte ptr [esi]
		cmp	al,				byte ptr [ebx]
		je	_lXFPCheckStart
cmp	byte ptr [ebx],			40h	;;@
je	_lXFPFoundCnt
		cmp	byte ptr [ebx],			02h
		jne	_lXFPNext

		cmp	byte ptr [_bAscii_00+eax],	ah		;; ah = 00h
		je	_lXFPFound

		mov	al,				byte ptr [ebx-01h]
		cmp	byte ptr [_bAscii_00+eax],	ah		;; ah = 00h
		jne	_lXFPNext
		;;----------------

		;;----------------
		;; is private
		_lXFPFound:
		mov	ebx,			dword ptr [edx+08h]
		test	ebx,			ebx
		jnz	_lXFPLibTest
		;;----------------

		;;----------------
		;; arguments?
		_lXFPAct:
		mov	dword ptr [_hOLMacro],	edx
		mov	ecx,			dword ptr [edx+04h]
		cmp	dword ptr [edx+0ch],	00h
		jne	_lXFPActArg

			;;----------------
			;; overloaded macros
			cmp	dword ptr [edx+18h],	0ffffffffh	;; is macros overload
			jne	_lXFPNoOverLoad
			cmp	byte ptr [esi],		28h		;; (
			jne	_lXFPNoOverLoad
			cmp	word ptr [esi],		2928h		;; ()
			jne	_lXPFArgErrEX
			add	esi,			02h
			;;----------------

		_lXFPNoOverLoad:

			;;----------------
			;; undefined?
			test	ecx,			ecx
			jz	_lXFPUndefined
			;;----------------

		push	esi
		push	00h
		mov	esi,			ecx
;;----------------
mov	eax,				dword ptr [_dAddrDefArgPnt]
mov	dword ptr [eax],		esp
lea	ecx,				[eax-08h]
mov	dword ptr [eax+04h],		ecx
add	eax,				08h
mov	dword ptr [_dAddrDefArgPnt],	eax
;;----------------
		xor	eax,			eax
		jmp	_lXFPStart

		_lXFPActArg:
		mov	edx,			dword ptr [edx+0ch]
		mov	eax,			offset _dDefArgs
		cmp	byte ptr [esi],		28h		;; (
		mov	ebp,			edx
		je	_lXFPNextArg

			;;----------------
			;; error
			_lXPFArgErr:
			mov	dword ptr [_xErrorTable],	offset _sErr_MissDefArg
			mov	dword ptr [_xErrorTable+08h],	esi
			dec	esi
			mov	dword ptr [_xErrorTable+04h],	esi
			jmp	_lErrIn
			;;----------------

			;;----------------
			;; next macro
			_lXPFArgErrEX:
			cmp	byte ptr [esi],		28h		;; (
			jne	_lXPFArgErr
			add	edx,			10h
			mov	dword ptr [_hOLMacro],	edx
			mov	ecx,			dword ptr [edx+04h]
			jmp	_lXFPActArg
			;;----------------

			;;----------------
			;; #for counter
			_lXFPFoundCnt:
			cmp	byte ptr [_bAscii_00+eax],	ah		;; ah = 00h
			jne	_lXFPNext

			mov	ebx,				dword ptr [edx+04h]
			mov	ebp,				dword ptr [ebx+05h]
			cmp	ebp,				esi
			ja	_lXFPNext
			mov	ebp,				dword ptr [ebx+09h]
			cmp	ebp,				esi
			jb	_lXFPNext
			jmp	_lXFPAct
			;;----------------
		;;----------------

		;;----------------
		;; parse arguments
		_lXFPNextArgAdd:
		mov	byte ptr [esi],		04h

		_lXFPNextArg:
		dec	edx
		js	_lXFPArgEnd

		_lXFPNextArgFX:
		inc	esi
		cmp	byte ptr [esi],		05h
		je	_lXFPNextArgFX

			;;----------------
			;; complex arg
			mov	dword ptr [eax],	esi
			add	eax,			04h

			xor	ebx,			ebx

			cmp	byte ptr [esi],		0bh
			je	_lXFPHardArg
cmp	byte ptr [esi],		1ah
je	_lXFPHardArgNew
			cmp	byte ptr [esi],		3ch	;; <
			jne	_lXFPArgSX			;; simple arg
			inc	dword ptr [eax-04h]
			inc	ebx
			_lXFPMArg:
			inc	esi
			cmp	byte ptr [esi],		22h	;; "
			je	_lXFPMArgStr
			cmp	byte ptr [esi],		80h
			jb	_lXFPMArgFX

			shl	ebx,			10h	;; save bx
			mov	bx,			bp	;; defines arg count
			add	bx,			80h
			cmp	byte ptr [esi],		bl

			jg	_lXFPMArgOX

			mov	bh,			byte ptr [esi]
			sub	bh,			7fh
			add	bh,			bl
			mov	byte ptr [esi],		bh

			_lXFPMArgOX:
			shr	ebx,			10h	;; load bx

			_lXFPMArgFX:
			cmp	byte ptr [esi],		3eh	;; >
			je	_lXFPMArgEX
			cmp	byte ptr [esi],		3ch	;; <
			jne	_lXFPMArg
			inc	ebx
			jmp	_lXFPMArg

			_lXFPMArgEX:
			dec	ebx
			jnz	_lXFPMArg
			mov	byte ptr [esi],		04h
			mov	dword ptr [eax],	3eh

			_lXFPMArgETT:
			add	eax,			04h

			inc	esi
			cmp	byte ptr [esi],		29h	;; )
			jne	_lXFPMArgDX
			test	edx,			edx
			jnz	_lXPFArgErr
			jmp	_lXFPArgEndOX

			_lXFPMArgDX:
			cmp	byte ptr [esi],		2ch	;; ,
;;			jne	_lXFPMArgErr
;;			jmp	_lXFPNextArg
			je	_lXFPNextArg

				;;----------------
				;; error
				_lXFPMArgErr:
				mov	dword ptr [_xErrorTable],	offset _sErr_Base
				mov	dword ptr [_xErrorTable+04h],	esi
				dec	esi
				mov	dword ptr [_xErrorTable+08h],	esi
				jmp	_lErrIn
				;;----------------

			_lXFPMArgStrEX:
			inc	esi
			_lXFPMArgStr:
			inc	esi
			cmp	byte ptr [esi],		5ch	;; \ 
			je	_lXFPMArgStrEX
			cmp	byte ptr [esi],		22h	;; "
			jne	_lXFPMArgStr
			jmp	_lXFPMArg
			;;----------------

			;;----------------
			;; hard arg
			_lXFPHardArg:
			inc	dword ptr [eax-04h]
			inc	ebx
			_lXFPHardArgEX:
			inc	esi
			cmp	byte ptr [esi],		0bh
			jne	_lXFPHardArgEX

			mov	byte ptr [esi],		04h
			mov	dword ptr [eax],	0bh
			jmp	_lXFPMArgETT
			;;----------------

;;----------------
;; hard arg new
_lXFPHardArgNewInc:
inc	ebx
jmp	_lXFPHardArgNewEx

_lXFPHardArgNew:
inc	ebx
inc	dword ptr [eax-04h]
push	ebx

xor	ebx,			ebx

_lXFPHardArgNewEx:
inc	esi
cmp	byte ptr [esi],		1ah
je	_lXFPHardArgNewInc
cmp	byte ptr [esi],		1bh
jne	_lXFPHardArgNewEx
dec	ebx
jns	_lXFPHardArgNewEx

pop	ebx
mov	byte ptr [esi],		04h
mov	dword ptr [eax],	1bh
jmp	_lXFPMArgETT
;;----------------

			;;----------------
			;; simple arg
			_lXFPArgDX:
			inc	ebx

			_lXFPArgEX:
			inc	esi

			_lXFPArgSX:
;;cmp	byte ptr [esi],			80h
;;jb	_lXFPArgKX
;;
;;mov	dword ptr [_xErrorTable],	offset _sErr_Base
;;mov	dword ptr [_xErrorTable+04h],	esi
;;dec	esi
;;mov	dword ptr [_xErrorTable+08h],	esi
;;jmp	_lErrIn

_lXFPArgKX:
			cmp	byte ptr [esi],		22h	;; "
			je	_lXFPArgGX
			cmp	byte ptr [esi],		28h	;; ( 
			je	_lXFPArgDX
			cmp	byte ptr [esi],		29h	;; )
			je	_lXFPArgXX
			cmp	byte ptr [esi],		2ch	;; ,
			jne	_lXFPArgEX
			test	ebx,			ebx
			jnz	_lXFPArgEX
			mov	dword ptr [eax],	2ch
			add	eax,			04h
			jmp	_lXFPNextArgAdd

			_lXFPArgXX:
			dec	ebx
			jns	_lXFPArgEX
			test	edx,			edx
			jnz	_lXPFArgErr
			mov	dword ptr [eax],	29h
			add	eax,			04h
			jmp	_lXFPNextArgAdd

			_lXFPArgGS:
			inc	esi
			_lXFPArgGX:
			inc	esi
			cmp	byte ptr [esi],		5ch	;; \ 
			je	_lXFPArgGS
			cmp	byte ptr [esi],		22h	;; "
			jne	_lXFPArgGX
			jmp	_lXFPArgEX
			;;----------------

			;;----------------
			_lXFPArgEnd:
			cmp	dword ptr [eax-04h],	3eh	;; >
			jne	_lXFPArgEndSX
			cmp	byte ptr [esi-01h],	29h	;; )
			jne	_lXFPOverload
			_lXFPArgEndSX:
			cmp	dword ptr [eax-04h],	29h	;; )
			jne	_lXFPOverload
			_lXFPArgEndOX:

				;;----------------
				;; undefined?
				test	ecx,			ecx
				jz	_lXFPUndefined
				;;----------------

			inc	esi
			_lXFPArgEndEX:
			push	dword ptr [eax-08h]
			push	dword ptr [eax-04h]
			sub	eax,			08h
			cmp	eax,			offset _dDefArgs
			jne	_lXFPArgEndEX

			push	esi
			push	ebp
			mov	esi,			ecx
;;----------------
mov	eax,				dword ptr [_dAddrDefArgPnt]
mov	dword ptr [eax],		esp
lea	ecx,				[eax-08h]
mov	dword ptr [eax+04h],		ecx
add	eax,				08h
mov	dword ptr [_dAddrDefArgPnt],	eax
;;----------------
			xor	eax,			eax
			jmp	_lXFPStart
			;;----------------

			;;----------------
			;; next overloaded macros
			_lXFPOverload:
			mov	ebx,			dword ptr [_hOLMacro]
			add	ebx,			10h
			cmp	dword ptr [ebx+08h],	0ffffffffh
			je	_lXFPOverloadEX

				;;----------------
				;; error
				mov	dword ptr [_xErrorTable],	offset _sErr_DefArg
				mov	dword ptr [_xErrorTable+04h],	esi
				dec	esi
				mov	dword ptr [_xErrorTable+08h],	esi
				jmp	_lErrIn
				;;----------------

			_lXFPOverloadEX:
			mov	ecx,			dword ptr [ebx+04h]
			mov	dword ptr [_hOLMacro],	ebx

			mov	edx,			dword ptr [ebx+0ch]
			mov	ebp,			edx
			sub	edx,			dword ptr [ebx-04h]

			jmp	_lXFPNextArg
			;;----------------
		;;----------------

		;;----------------
		;; check own lib
		_lXFPLibTest:
		cmp	ecx,			dword ptr [_dScopeIn+ebx*04h]
		jb	_lXFPNext
		cmp	ecx,			dword ptr [_dScopeOut+ebx*04h]
		jb	_lXFPAct
		;;----------------

		;;----------------
		;; check next define
		_lXFPNext:
		mov	esi,			ecx
		_lXFPNextEX:
		add	edx,			10h
		cmp	dword ptr [edx],	00h
		je	_lXFPGetNext
			;;----------------
			;; overloaded?
			cmp	dword ptr [edx+08h],	0ffffffffh
			je	_lXFPNextEX
			;;----------------
		jmp	_lXFPCheck
		;;----------------

		;;----------------
		;; undefined
		_lXFPUndefined:
		mov	esi,			dword ptr [_dUndefPnt]

			;;----------------
			;; remove arg
			_lXFPUndefinedRE:
			cmp	eax,			offset _dDefArgs	;; ???
			jbe	_lXFPUndefinedEnd

			mov	dl,			byte ptr [eax-04h]
			test	dl,			dl
			jz	_lXFPUndefinedREEX
			mov	ebx,			dword ptr [eax-08h]
			dec	ebx
			
			_lXFPUndefinedRemArg:
			inc	ebx
			_lXFPUndefinedRemArgEX:
			cmp	word ptr [ebx],		7801h	;; #x
			je	_lXFPUndefinedRemArgSX
			cmp	word ptr [ebx],		7901h	;; #y
			je	_lXFPUndefinedRemArgSX
			cmp	byte ptr [ebx],		04h
			jne	_lXFPUndefinedRemArg

			mov	byte ptr [ebx],		dl

			_lXFPUndefinedREEX:
			sub	eax,			08h
			jmp	_lXFPUndefinedRE

			_lXFPUndefinedRemArgSX:
			add	ebx,			06h
			jmp	_lXFPUndefinedRemArgEX
			;;----------------

		_lXFPUndefinedEnd:
		xor	eax,			eax
		jmp	_lXFPGetNext
		;;----------------

		;;----------------
		;; remove bs
		_lXFPBSRem:
		xor	eax,				eax
		mov	al,				byte ptr [edi-01h]	;; bs
		cmp	byte ptr [_bAscii_00+eax],	ah
		jne	_lXFPNewWord
		cmp	byte ptr [esi+01h],		2bh			;; +
		je	_lXFPNewWord
		cmp	byte ptr [esi+01h],		2dh			;; -
		je	_lXFPNewWord

		inc	esi
		jmp	_lXFPStartFX
		;;----------------

		;;----------------
		;; get next word and parse text
		_lXFPGetNext:
		movsb
		mov	al,			byte ptr [esi]
		_lXFPGetNextEx:
		cmp	al,			05h	;; ex backspace
		jne	_next
		inc	esi
		jmp	_lXFPStart
		_lbl:
		cmp	dword ptr [esi],	"@@@@"
		jne	_next
		cmp	byte ptr [esi+04h],	03h
		je	_lXFP_11

		_lbl:
		cmp	al,			20h
		jb	_lXFPXX
		je	_lXFPBSRem
		cmp	al,			22h	;; "
		je	_lXFPString
		cmp	word ptr [esi],		2323h	;; ##
		je	_lXFPConf
		cmp	al,			30h
		jb	_lXFPNewWord
		cmp	al,			3ah
		jb	_lXFPGetNext
		cmp	al,			41h
		jb	_lXFPNewWord
		cmp	al,			5bh
		jb	_lXFPGetNext
		cmp	al,			5fh
		jb	_lXFPNewWord
		cmp	al,			60h	;; `
		je	_lXPFRepStr
		cmp	al,			7ah
		jg	_lXFPNewWord
		jmp	_lXFPGetNext

		_lXFPConf:
		add	esi,			02h
		jmp	_lXFPStart

			;;----------------
			;; string
			_lXFPStringEX:
			movsb
			_lXFPString:
			movsb
			cmp	byte ptr [esi],		5ch	;; \ 
			je	_lXFPStringEX
			cmp	byte ptr [esi],		22h	;; "
			jne	_lXFPString
			jmp	_lXFPNewWord

			_lXPFRepStr:
			mov	byte ptr [edi],		22h	;; "
			inc	esi
			inc	edi
			jmp	_lXFPStart
			;;----------------

			;;----------------
			;; system
			_lXFPXX:
			cmp	al,			08h
			je	_lXFPSetdef
			cmp	al,			04h
			je	_lXFPArgOut
			cmp	al,			03h
			je	_lXFPDefOut
			cmp	al,			0bh
			je	_lXFPTMArg

			cmp	word ptr [esi],		3801h	;; #8
			jne	_lXFPXX_Next
			movsw
			jmp	_lXFPStart

			_lXFPXX_Next:
			cmp	word ptr [esi],		6401h	;; #d
			je	_lXFP_00
			cmp	word ptr [esi],		6701h	;; #g
			je	_lXFP_0a
			cmp	word ptr [esi],		6301h	;; #c
			je	_lXFP_01
			cmp	word ptr [esi],		7801h	;; #x
			je	_lXFP_02_EX
			cmp	word ptr [esi],		7901h	;; #y
			je	_lXFP_02
			cmp	word ptr [esi],		7301h	;; #s
			je	_lXFP_03
			cmp	word ptr [esi],		6901h	;; #i
			je	_lXFP_04
			cmp	word ptr [esi],		6101h	;; #a
			je	_lXFP_05
			cmp	word ptr [esi],		6501h	;; #e
			je	_lXFP_06
			cmp	word ptr [esi],		7501h	;; #u
			je	_lXFP_07
			cmp	word ptr [esi],		3601h	;; #6
			je	_lXFP_08
			cmp	word ptr [esi],		3401h	;; #4
			je	_lXFP_08_QA
			cmp	word ptr [esi],		4101h	;; #A
			je	_lXFP_08_INC
			cmp	word ptr [esi],		4201h	;; #B
			je	_lXFP_08_RES
			cmp	word ptr [esi],		3701h	;; #7
			je	_lXFP_09
			cmp	word ptr [esi],		4301h	;; #C
			je	_lXFP_0b
			cmp	word ptr [esi],		4401h	;; #D
			je	_lXFP_0c
			cmp	word ptr [esi],		4501h	;; #E
			je	_lXFP_0d
			cmp	word ptr [esi],		4701h	;; #G
			je	_lXFP_0e
			cmp	word ptr [esi],		4b01h	;; #K
			je	_lXFP_12
			cmp	word ptr [esi],		4801h	;; #H
			je	_lXFP_0f
			cmp	word ptr [esi],		4a01h	;; #J
			je	_lXFP_10
			cmp	word ptr [esi],		4c01h	;; #L
			je	_lXFP_13
cmp	word ptr [esi],		7701h		;; #w
je	_lXFP_14
cmp	word ptr [esi],		7101h		;; #q
je	_lXFP_15
cmp	word ptr [esi],		7401h		;; #t
je	_lXFP_16
cmp	word ptr [esi],		7601h		;; #v
je	_lXFP_17
cmp	word ptr [esi],		6801h		;; #h
je	_lXFP_18
cmp	word ptr [esi],		6b01h		;; #k
je	_lXFP_19
cmp	word ptr [esi],		6e01h		;; #n
je	_lXFP_1a
cmp	word ptr [esi],		4f01h		;; #O
je	_lXFP_1b
cmp	word ptr [esi],		5001h		;; #P
je	_lXFP_1c
			cmp	al,			00h
			je	_lXFPEnd

cmp	word ptr [esi],			0a0dh	;; nl
jne	_lXFPNewWord
cmp	byte ptr [_bWhileCondCorrect],	00h
je	_lXFPNewWordEx
mov	byte ptr [_bWhileCondCorrect],	00h
mov	byte ptr [edi],			")"
inc	edi

			jmp	_lXFPNewWordEx
			;;----------------

;;----------------
_lXFPNewWordEx:
cmp	word ptr [edi - 02h],		0a0dh
jne	_lXFPNewWord
add	esi,				02h
jmp	_lXFPStart
;;----------------

			;;----------------
			_lXFPTMArg:
			mov	byte ptr [edi],		22h	;; "
			inc	esi
			inc	edi
			jmp	_lXFPStart
			;;----------------

			;;----------------
			;; set esi
			_lXFP_03:
			mov	esi,			dword ptr [esi+02h]
			jmp	_lXFPStart
			;;----------------

;;----------------
_lXFP_1b:
mov	ecx,				edi
xor	eax,				eax

_lXFP_1b_Ex:
dec	edi
cmp	word ptr [edi],			7101h	;; #q
jne	_lXFP_1b_Ex

mov	edx,				dword ptr [esi + 02h]

_lXFP_1b_Start:
lea	ebx,				[edi + 02h]

_lXFP_1b_Check:
mov	al,				byte ptr [ebx]
cmp	byte ptr [_bAscii_00 + eax],	ah
jne	_lXFP_1b_Check_00

mov	al,				byte ptr [edx]
cmp	byte ptr [_bAscii_00 + eax],	ah
jne	_lXFP_1b_Check_GetNext

mov	esi,				dword ptr [esi + 06h]
jmp	_lXFP_1b_End

_lXFP_1b_Check_00:
cmp	al,				byte ptr [edx]
jne	_lXFP_1b_Check_GetNext
inc	edx
inc	ebx
jmp	_lXFP_1b_Check

_lXFP_1b_Check_GetNextEx:
inc	edx
_lXFP_1b_Check_GetNext:
cmp	byte ptr [edx],			" "
je	_lXFP_1b_StartEx
cmp	byte ptr [edx],			00h
jne	_lXFP_1b_Check_GetNextEx

mov	esi,				dword ptr [esi + 0ah]
_lXFP_1b_End:
xor	eax,				eax
;sub	edi,				02h
mov	edx,				edi
sub	ecx,				edi
rep	stosb
mov	edi,				edx
jmp	_lXFPStart

_lXFP_1b_StartEx:
inc	edx
jmp	_lXFP_1b_Start
;;----------------

;;----------------
_lXFP_1c:
mov	ecx,				edi
xor	eax,				eax

_lXFP_1c_Ex:
dec	edi
cmp	word ptr [edi - 02h],		7101h
je	_lXFP_1c_Equ
mov	al,				byte ptr [edi]
cmp	byte ptr [_bAscii_00 + eax],	ah
jne	_lXFP_1c_Ex

_lXFP_1c_NoEqu:
dec	edi
cmp	word ptr [edi - 02h],		7101h
jne	_lXFP_1c_NoEqu
mov	esi,				dword ptr [esi + 06h]
jmp	_lXFP_1c_End

_lXFP_1c_Equ:
mov	esi,				dword ptr [esi + 02h]

_lXFP_1c_End:
xor	eax,				eax
sub	edi,				02h
mov	edx,				edi
sub	ecx,				edi
rep	stosb
mov	edi,				edx
jmp	_lXFPStart
;;----------------

;;----------------
;; group id
_lXFP_18:
inc	dword ptr [_dForGroupIdMax]

_lXFP_19:
mov	eax,				dword ptr [_dForGroupIdMax]
and	eax,				0ff000000h
shr	eax,				17h
mov	ax,				word ptr [eax + _bIntToHexStr]
mov	word ptr [edi],			ax
mov	eax,				dword ptr [_dForGroupIdMax]
and	eax,				00ff0000h
shr	eax,				0fh
mov	ax,				word ptr [eax + _bIntToHexStr]
mov	word ptr [edi + 02h],		ax
mov	eax,				dword ptr [_dForGroupIdMax]
and	eax,				0000ff00h
shr	eax,				07h
mov	ax,				word ptr [eax + _bIntToHexStr]
mov	word ptr [edi + 04h],		ax
mov	eax,				dword ptr [_dForGroupIdMax]
and	eax,				000000ffh
shl	eax,				01h
mov	ax,				word ptr [eax + _bIntToHexStr]
mov	word ptr [edi + 06h],		ax

add	edi,				08h
add	esi,				02h
xor	eax,				eax
jmp	_lXFPStart
;;----------------

;;----------------
;; second word
_lXFP_17:
add	esi,			02h
mov	ecx,			edi

xor	eax,			eax

_lXFP_17_Ex:
mov	al,				byte ptr [edi - 01h]
cmp	byte ptr [_bAscii_00 + eax],	ah
je	_lXFP_17_Fx
dec	edi
jmp	_lXFP_17_Ex

_lXFP_17_Fx:
cmp	word ptr [edi - 01h],	7101h		;; #q
jne	_lXFP_17_Wx
inc	edi

_lXFP_17_Wx:
mov	ebx,			edi
cmp	ebx,			ecx
jae	_lXFP_17_Fail

_lXFP_17_Dx:
dec	edi
cmp	word ptr [edi],		7101h	;; #q
jne	_lXFP_17_Dx

_lXFP_17_Mx:
mov	al,			byte ptr [ebx]
test	al,			al
je	_lXFP_17_Ax
mov	byte ptr [edi],		al
inc	ebx
inc	edi
jmp	_lXFP_17_Mx

_lXFP_17_Ax:
mov	edx,			edi
sub	ecx,			edi
rep	stosb
mov	edi,			edx
jmp	_lXFPStart

_lXFP_17_Fail:
mov	dword ptr [edi],	"oknu"
mov	dword ptr [edi + 04h],	"v_nw"
mov	dword ptr [edi + 08h],	"aira"
mov	dword ptr [edi + 0ch],	" elb"
add	edi,			0fh
jmp	_lXFPStart
;;----------------

;;----------------
;; first word start
_lXFP_15:
movsw
jmp	_lXFPStart
;;----------------

;;----------------
;; first word end
_lXFP_16:
add	esi,			02h
mov	ecx,			edi

_lXFP_16_Ex:
dec	edi
cmp	word ptr [edi],		7101h	;; #q
jne	_lXFP_16_Ex

xor	eax,			eax

_lXFP_16_Dx:
mov	al,				byte ptr [edi + 02h]
cmp	byte ptr [_bAscii_00 + eax],	ah
je	_lXFP_16_Sx
stosb
jmp	_lXFP_16_Dx

_lXFP_16_Sx:
xor	eax,			eax
sub	ecx,			edi
mov	edx,			edi
rep	stosb
mov	edi,			edx

jmp	_lXFPStart
;;----------------

;;----------------
;; get def args
_lXFP_1a:
add	esi,			02h
mov	ecx,			edi

_lXFP_1a_Ex:
dec	edi
cmp	word ptr [edi],		7101h	;; #q
jne	_lXFP_1a_Ex

xor	eax,			eax
lea	edx,			[edi + 02h]

_lXFP_1a_Dx:
mov	al,				byte ptr [edx]
cmp	byte ptr [_bAscii_00 + eax],	ah
je	_lXFP_1a_Sx
inc	edx
jmp	_lXFP_1a_Dx

_lXFP_1a_Sx:
cmp	al,			"("
jne	_lXFP_1a_Mx
inc	edx

_lXFP_1a_Mx:
mov	al,			byte ptr [edx]
test	eax,			eax
je	_lXFP_1a_Rx
mov	byte ptr [edi],		al
inc	edx
inc	edi
jmp	_lXFP_1a_Mx

_lXFP_1a_Rx:
cmp	byte ptr [edi - 01h],	")"
jne	_lXFP_1a_Vx
dec	edi

_lXFP_1a_Vx:
xor	eax,			eax
sub	ecx,			edi
mov	edx,			edi
rep	stosb
mov	edi,			edx

jmp	_lXFPStart
;;----------------

;;----------------
;; while correct
_lXFP_14:
mov	byte ptr [_bWhileCondCorrect],	01h
add	esi,				02h
jmp	_lXFPStart
;;----------------

			;;----------------
			;; arg out
			_lXFPArgOut:

				;;----------------
				mov	esi,				dword ptr [_dAddrDefArgPnt]
				sub	esi,				08h
				mov	dword ptr [_dAddrDefArgPnt],	esi
				;;----------------

			pop	esi
			jmp	_lXFPStart
			;;----------------

			;;----------------
			;; error
			_lXFP_0a:
			mov	dword ptr [_xErrorTable],	offset _sErr_Ude
			mov	dword ptr [_xErrorTable+04h],	esi
			_lXFP_0a_EX:
			inc	esi
			cmp	word ptr [esi],			0a0dh		;; nl
			jne	_lXFP_0a_EX
			mov	dword ptr [_xErrorTable+08h],	esi
			jmp	_lErrIn
			;;----------------

			;;----------------
			;; setdef
			_lXFPSetdef:
			mov	al,			byte ptr [esi+07h]
			lea	edx,			[_dDefTable+eax*04h]
			mov	edx,			dword ptr [edx]		;; edx = def block address
			test	edx,			edx
			jnz	_lXFPSetdefCheck

;; error
			_lXFPSetdefCheckNext:
			add	edx,			10h
			_lXFPSetdefCheck:
			lea	ecx,			[esi+07h]
			mov	ebx,			dword ptr [edx]
			mov	al,			byte ptr [ecx]
			cmp	al,			byte ptr [ebx]
;;			jne
			_lXFPSetdefCheckEX:
			inc	ecx
			inc	ebx
			mov	al,			byte ptr [ecx]
			cmp	al,			02h			;; def label end
			je	_lXFPSetdefCheckEnd
			cmp	al,			byte ptr [ebx]
			je	_lXFPSetdefCheckEX
			jmp	_lXFPSetdefCheckNext

			_lXFPSetdefCheckEnd:
			cmp	al,			byte ptr [ebx]
			jne	_lXFPSetdefCheckNext

				;;----------------
				;; check lib
				mov	ecx,			dword ptr [edx+08h]

				test	ecx,			ecx
				jz	_lXFPSetdefGlob
				js	_lXFPSetdefGlob

				cmp	esi,			dword ptr [_dScopeIn+ecx*04h]
				jb	_lXFPSetdefCheckNext
				cmp	esi,			dword ptr [_dScopeOut+ecx*04h]
				jg	_lXFPSetdefCheckNext
				;;----------------

				;;----------------
				;; check arg count
				_lXFPSetdefGlob:
				mov	al,			byte ptr [esi+01h]
				cmp	eax,			dword ptr [edx+0ch]
				jne	_lXFPSetdefCheckNext
				;;----------------

			mov	ecx,			dword ptr [esi+02h]
			mov	dword ptr [edx+04h],	ecx			;; huh...

			add	esi,			08h
			_lXFPSetdefEnd:
			inc	esi
			_lXFPSetdefEnd_EX:
cmp	word ptr [esi],			7801h	;; #x
je	_lXFPSetdefEnd_00
cmp	word ptr [esi],			7901h	;; #y
je	_lXFPSetdefEnd_00
			cmp	byte ptr [esi],		03h
			jne	_lXFPSetdefEnd
			add	esi,			02h
cmp	byte ptr [esi-01h],	79h	;; y
jne	_lXFPStart
add	esi,			0eh
			jmp	_lXFPStart

			_lXFPSetdefEnd_00:
			add	esi,			06h
			jmp	_lXFPSetdefEnd_EX
			;;----------------

			;;----------------
			;; undef
			_lXFP_07:
			mov	al,			byte ptr [esi+06h]
			lea	edx,			[_dDefTable+eax*04h]
			mov	edx,			dword ptr [edx]		;; edx = def block address
			test	edx,			edx
			jnz	_lXFPUndefCheck

;; error
			_lXFPUndefCheckNext:
			add	edx,			10h
			_lXFPUndefCheck:
			lea	ecx,			[esi+06h]
			mov	ebx,			dword ptr [edx]
			mov	al,			byte ptr [ecx]
			cmp	al,			byte ptr [ebx]
;;			jne
			_lXFPUndefCheckEX:
			inc	ecx
			inc	ebx
			mov	al,			byte ptr [ecx]
			cmp	al,			02h			;; def label end
			je	_lXFPUndefCheckEnd
			cmp	al,			byte ptr [ebx]
			je	_lXFPUndefCheckEX
			jmp	_lXFPUndefCheckNext

			_lXFPUndefCheckEnd:
			cmp	al,			byte ptr [ebx]
			jne	_lXFPUndefCheckNext

				;;----------------
				;; check lib
				mov	ebx,			dword ptr [edx+08h]

				test	ebx,			ebx
				jz	_lXFPUndefRem

				cmp	esi,			dword ptr [_dScopeIn+ebx*04h]
				jb	_lXFPUndefCheckNext
				cmp	esi,			dword ptr [_dScopeOut+ebx*04h]
				jg	_lXFPUndefCheckNext

				jmp	_lXFPUndefRem
				;;----------------

			_lXFPUndefRemEX:
			add	edx,			10h
			_lXFPUndefRem:
			mov	dword ptr [edx+04h],	00000000h		;; huh...
			cmp	dword ptr [edx+18h],	0ffffffffh		;; is overloaded?
			je	_lXFPUndefRemEX

			lea	esi,			[ecx+01h]

			cmp	byte ptr [esi],		0ah
			jne	_lXFPStartFX
			inc	esi
			jmp	_lXFPStartFX
			;;----------------

			;;----------------
			;; #repeat
			_lXFP_12:
			lea	eax,			[esi+1bh]
			mov	dword ptr [esi+04h],	01h

			_lXFP_12_00:
			inc	eax
			cmp	word ptr [eax],		6101h	;; #a
			jne	_lXFP_12_00

			mov	word ptr [eax],		4c01h	;; #L
			lea	ecx,			[eax+08h]
			mov	eax,			dword ptr [eax+04h]
			mov	dword ptr [eax+04h],	esi
			add	eax,			0dh

			mov	dword ptr [esi+16h],	eax
			mov	dword ptr [esi+10h],	ecx

			mov	dword ptr [_xEnumTable],	edi
			mov	dword ptr [_dForSrt],		esi
			mov	edi,				offset _xEnumTable + 04h

			lea	esi,			[esi+1ch]
			xor	eax,			eax
			jmp	_lXFPStartFX
			;;----------------

			;;----------------
			;; condition in #repeat loop
			_lXFP_13:
			mov	word ptr [esi],		6101h	;; #a
			mov	byte ptr [edi],		00h
			mov	edi,			dword ptr [_xEnumTable]
			mov	esi,			offset _xEnumTable + 04h

			mov	ebx,			dword ptr [_dForSrt]
			lea	eax,			[ebx+0ah]
			push	eax
			call	_lpReadInt
			test	eax,			eax
			jz	_lXFP_10_error	;; !!!

			cmp	byte ptr [esi],		00h
			jne	_lXFP_10_error

			mov	eax,			dword ptr [ebx+04h]
			cmp	dword ptr [ebx+0ah],	eax
			mov	esi,			dword ptr [ebx+10h]
			cmovb	esi,			dword ptr [ebx+16h]
			xor	eax,			eax
			jmp	_lXFPStart
			;;----------------

			;;----------------
			;; #for
			_lXFP_0e:
			lea	eax,			[esi+1bh]

			_lXFP_0e_00:
			inc	eax
			cmp	word ptr [eax],		6101h	;; #a
			jne	_lXFP_0e_00

			mov	word ptr [eax],		4a01h	;; #J
			lea	ecx,			[eax+08h]
			mov	eax,			dword ptr [eax+04h]
			mov	dword ptr [eax+04h],	esi
			add	eax,			0dh

			mov	dword ptr [esi+16h],	eax
			mov	dword ptr [esi+10h],	ecx

			mov	dword ptr [_xEnumTable],	edi
			mov	dword ptr [_dForSrt],		esi
			mov	edi,				offset _xEnumTable + 04h

			lea	esi,			[esi+1ch]
			xor	eax,			eax
			jmp	_lXFPStartFX
			;;----------------

			;;----------------
			;; condition in #for loop
			_lXFP_10:
			mov	word ptr [esi],		6101h	;; #a
			mov	byte ptr [edi],		00h
			mov	edi,			dword ptr [_xEnumTable]
			mov	esi,			offset _xEnumTable + 04h
			cmp	byte ptr [esi],		"("
			jne	_lXFP_10_error
			inc	esi

			mov	ebx,			dword ptr [_dForSrt]

			lea	eax,			[ebx+04h]
			push	eax
			call	_lpReadInt
			test	eax,			eax
			jz	_lXFP_10_error

			cmp	byte ptr [esi],		","
			jne	_lXFP_10_error

			inc	esi

			lea	eax,			[ebx+0ah]
			push	eax
			call	_lpReadInt
			test	eax,			eax
			jz	_lXFP_10_error

			cmp	word ptr [esi],		0029h	;; ) null
			jne	_lXFP_10_error

			mov	eax,			dword ptr [ebx+04h]
			cmp	dword ptr [ebx+0ah],	eax
			mov	esi,			dword ptr [ebx+10h]
			cmovb	esi,			dword ptr [ebx+16h]
			xor	eax,			eax
			jmp	_lXFPStart

			_lXFP_10_error:


				;;----------------
				;; read int
				;; bool readInt (addr def)
				;; esi = sorc, modifed
				_lpReadInt:
				xor	ecx,			ecx
				xor	eax,			eax
				cmp	byte ptr [esi],		"0"
				je	_lpReadInt_00
				jb	_lpReadInt_Fail
				cmp	byte ptr [esi],		"9"
				ja	_lpReadInt_Fail

					;;----------------
					;; dec
					push	ebx
					mov	ecx,			0ah
					xor	ebx,			ebx

					_lpReadInt_DEC:
					mov	bl,			byte ptr [esi]
					inc	esi
					cmp	bl,			"0"
					jb	_lpReadInt_WinEX
					cmp	bl,			"9"
					ja	_lpReadInt_WinEX
					sub	ebx,			30h

					mul	ecx
					jc	_lpReadInt_Fail
					add	eax,			ebx
					jmp	_lpReadInt_DEC
					;;----------------

				_lpReadInt_WinEX:
				mov	ebx,			dword ptr [esp+08h]
				mov	dword ptr [ebx],	eax
				pop	ebx
				dec	esi
				mov	eax,			01h
				retn	04h

				_lpReadInt_00:
				cmp	word ptr [esi],		"x0"
				je	_lpReadInt_HEX

					;;----------------
					;; oct
					_lpReadInt_OCT:
					lodsb
					cmp	al,		"0"
					jb	_lpReadInt_Win
					cmp	al,		"7"
					ja	_lpReadInt_Win

					sub	al,		30h
					shl	ecx,		03h
					jc	_lpReadInt_Fail
					add	ecx,		eax
					jmp	_lpReadInt_OCT
					;;----------------

					;;----------------
					;; hex
					_lpReadInt_HEX:
					mov	al,				byte ptr [esi+02h]
					cmp	byte ptr [_bAscii_05+eax],	ah
					jz	_lpReadInt_Fail
					add	esi,				02h

					_lpReadInt_HEX_00:
					lodsb
					cmp	byte ptr [_bAscii_05+eax],	ah
					je	_lpReadInt_Win

					shl	ecx,				04h
					jc	_lpReadInt_Fail
					sub	al,				byte ptr [_bAscii_05+eax]
					add	ecx,				eax
					jmp	_lpReadInt_HEX_00
					;;----------------


				_lpReadInt_Fail:
				xor	eax,			eax
				retn	04h

				_lpReadInt_Win:
				dec	esi
				mov	eax,			dword ptr [esp+04h]
				mov	dword ptr [eax],	ecx
				mov	eax,			01h
				retn	04h
				;;----------------
			;;----------------

			;;----------------
			;; #endfor
			_lXFP_0f:
			mov	ecx,			dword ptr [esi+04h]
			mov	eax,			dword ptr [ecx+04h]
			inc	eax
			cmp	dword ptr [ecx+0ah],	eax
			mov	dword ptr [ecx+04h],	eax

			mov	esi,			dword ptr [ecx+10h]
			cmovb	esi,			dword ptr [ecx+16h]
			xor	eax,			eax
			jmp	_lXFPStart
			;;----------------

			;;----------------
			;; index of #for
			_lXFP_11:
			add	esi,			04h
			mov	ebx,			dword ptr [esi+01h]
			mov	eax,			dword ptr [ebx+04h]
			jmp	_lXFP_08_QX
			;;----------------

			;;----------------
			;; optional texmacro: removing
			_lXFP_0b:
			add	esi,			02h

			_lXFP_0b_EX:
			dec	edi
			cmp	word ptr [edi-02h],	0a0dh	;; nl
			jne	_lXFP_0b_EX
			jmp	_lXFPStart
			;;----------------

			;;----------------
			;; anonym function
			_lXFP_0c:
			add	esi,					02h

			mov	dword ptr [edi],			"cnuf"
			mov	dword ptr [edi+04h],			"noit"

			add	edi,					08h

			mov	eax,					20202020h		;; bs
			mov	ecx,					10h
			rep	stosd								;; structname.

			mov	dword ptr [edi],			5f6a6318h		;; _jc*
			mov	dword ptr [edi+04],			"nona"
			mov	dword ptr [edi+08h],			"__my"

			mov	eax,					dword ptr [_dAnonFuncCnt]

			add	edi,					0ch

			mov	ecx,					eax
			mov	ebp,					dword ptr [esp+04h]
			shl	ecx,					04h
			mov	dword ptr [_dAnonFuncTable+ecx],	ebp
mov	dword ptr [_dAnonFuncTable+ecx],	edi
			mov	dword ptr [_dAnonFuncTable+ecx+08h],	edi

			inc	eax
			mov	dword ptr [_dAnonFuncCnt],		eax

			_lbl:
			inc	ebp

			cmp	byte ptr [ebp],				06h	;; anonym function declared in define
;je	_lXFP_0c_00
je	_lXFP_08_QX

			cmp	word ptr [ebp],				7801h	;; #x
			jne	_prew
			mov	edx,					dword ptr [ebp+02h]
;mov	dword ptr [_dAnonFuncTable+ecx+04h],	edx

			mov	dword ptr [edx],			"fdne"
			mov	dword ptr [edx+04h],			"tcnu"
			mov	dword ptr [edx+08h],			" noi"
			mov	word ptr [edx+0bh],			4501h	;; #E

			mov	word ptr [ebp],				0606h
			mov	dword ptr [ebp+02h],			06060606h

			cmp	byte ptr [edx+10h],			")"
			je	_next
			cmp	byte ptr [edx+10h],			","
			je	_next
			cmp	word ptr [edx+10h],			"=="
			je	_next
			cmp	word ptr [edx+10h],			"=!"
			je	_next
			cmp	byte ptr [edx+10h],			04h	;; def arg
			je	_next

			jmp	_lXFP_08_QX

			_lbl:
			mov	word ptr [edx+0eh],			0606h
			jmp	_lXFP_08_QX
			;;----------------

			;;----------------
			;; anonym endfunction
			_lXFP_0d:
			mov	edx,				dword ptr [_dAnonFuncCnt]	
			shl	edx,				04h
			lea	edx,				[_dAnonFuncTable+edx+04h]

			_lbl:
			sub	edx,				10h
			cmp	dword ptr [edx],		00h
			jne	_prew

			mov	dword ptr [edx],		edi

			movsw
			jmp	_lXFPNewWord
			;;----------------

			;;----------------
			;; counter
			_lXFP_08:
			inc	dword ptr [_dCounterV]

			_lXFP_08_QA:
			add	esi,			02h
			mov	eax,			dword ptr [_dCounterV]
;;			push				offset _lXFPStart

			_lXFP_08_QX:
			inc	edi
			cmp	eax,			0ah
			jb	_lXFP_08_FX

			inc	edi
			cmp	eax,			64h
			jb	_lXFP_08_FX

			inc	edi
			cmp	eax,			03e8h
			jb	_lXFP_08_FX

			inc	edi
			cmp	eax,			2710h
			jb	_lXFP_08_FX

			inc	edi
			cmp	eax,			000186a0h
			jb	_lXFP_08_FX

			inc	edi
			cmp	eax,			000f4240h
			jb	_lXFP_08_FX

			inc	edi
			cmp	eax,			00989680h
			jb	_lXFP_08_FX

			inc	edi
			cmp	eax,			05f5e100h
			jb	_lXFP_08_FX

			inc	edi
			cmp	eax,			3b9aca00h
			jb	_lXFP_08_FX

			inc	edi

			_lXFP_08_FX:
			mov	ecx,			0ah
			mov	ebp,			edi
			_lXFP_08_EX:
			xor	edx,			edx
			dec	ebp
			div	ecx
			add	dl,			30h
			mov	byte ptr [ebp],		dl
			test	eax,			eax
			jnz	_lXFP_08_EX

			jmp	_lXFPStart
;;			retn

				;;----------------
				;; inc
				_lXFP_08_INC:
				inc	dword ptr [_dCounterV]
				add	esi,			02h
				jmp	_lXFPStart
				;;----------------

				;;----------------
				;; reset
				_lXFP_08_RES:
				mov	dword ptr [_dCounterV],	00h
				add	esi,			02h
				jmp	_lXFPStart
				;;----------------
			;;----------------

			;;----------------
			;; weather
			_lXFP_09:
			add	esi,			02h
			rdtsc
			and	eax,			01h
			or	eax,			30h
			stosb
			xor	eax,			eax
			jmp	_lXFPStart
			;;----------------

			;;----------------
			;; def out
			_lXFPDefOut:
;;----------------
mov	eax,				dword ptr [_dAddrDefArgPnt]
sub	eax,				08h
mov	dword ptr [_dAddrDefArgPnt],	eax
;;----------------
			pop	eax
			pop	esi
			_lXFPDefOutEX:
			test	eax,			eax
			jnz	_lXFPDefOutKX

				;;----------------
				;; optional textmacro
				cmp	word ptr [esi],		4301h	;; #c
				jne	_lXFPStart
				add	esi,			02h
				;;----------------

			jmp	_lXFPStart

			_lXFPDefOutKX:
			mov	ecx,			dword ptr [esp]
			test	ecx,			ecx
			jz	_lXFPDefOutSBX
			mov	ebp,			dword ptr [esp+04h]
			dec	ebp
			_lXFPDefOutDX:
			inc	ebp
			_lXFPDefOutAX:
			cmp	word ptr [ebp],		7801h	;; #x
			je	_lXFPDefOutBX
			cmp	word ptr [ebp],		7901h	;; #y
			je	_lXFPDefOutBX
			cmp	byte ptr [ebp],		04h
			jne	_lXFPDefOutDX

			mov	byte ptr [ebp],		cl
			_lXFPDefOutSBX:
			add	esp,			08h
			dec	eax
			jmp	_lXFPDefOutEX

			_lXFPDefOutBX:
			add	ebp,			06h
			jmp	_lXFPDefOutAX
			;;----------------

			;;----------------
			;; #i

				;;----------------
				;; #if
				_lXFP_04:
cmp	byte ptr [esi+02h],		66h		;; f ;; #if
jne	_lXFP_04_FX
cmp	byte ptr [esi+03h],		41h
jge	_lXFP_04_FX

				mov	dword ptr [_xEnumTable],	edi
				add	esi,				03h
				mov	edi,				offset _xEnumTable+04h
				jmp	_lXFPStartFX
				;;----------------

				;;----------------
				;; #elseif
				_lXFP_04_FX:
				cmp	dword ptr [esi+02h],		6965736ch	;; lsei
				jne	_lXFP_04_DX
cmp	byte ptr [esi+06h],		66h		;; f
jne	_lXFP_04_DX
cmp	byte ptr [esi+07h],		41h
jge	_lXFP_04_DX

				mov	dword ptr [_xEnumTable],	edi
				add	esi,				07h
				mov	edi,				offset _xEnumTable+04h
				jmp	_lXFPStartFX
				;;----------------

				;;----------------
				;; #else
				_lXFP_04_DX:
				cmp	dword ptr [esi+02h],		0165736ch	;; lse#
				jne	_lXFP_04_RX

				mov	ecx,				dword ptr [esi+09h]
				mov	word ptr [ecx],			0606h
				mov	dword ptr [ecx+02h],		06060606h
				add	esi,				0dh
				jmp	_lXFPStartFX
				;;----------------

				;;----------------
				;; #endif
				_lXFP_04_RX:
				cmp	dword ptr [esi+02h],		6669646eh	;; ndif
				jne	_lCRErrPrePorc					;; omg!
				add	esi,				06h
				jmp	_lXFPStartFX
				;;----------------
			;;----------------

			;;----------------
			;; #e
			_lXFP_06:
			mov	word ptr [esi],		6901h	;; #i
			_lXFP_06_EX:
			inc	esi
			cmp	word ptr [esi],		7801h	;; #x
			jne	_lXFP_06_EX

			mov	esi,			dword ptr [esi+02h]
			add	esi,			10h
			jmp	_lXFPStartFX			
			;;----------------

			;;----------------
			;; #d
			_lXFP_00:
			inc	esi

			_lXFP_00_Re:
			cmp	word ptr [esi],		7801h	;; #x
			je	_lXFP_00_FX
			cmp	word ptr [esi],		7901h	;; #y
			je	_lXFP_00_FX

			cmp	word ptr [esi],		6401h	;; #d
			jne	_lXFP_00
			add	esi,			02h
			jmp	_lXFPStart

			_lXFP_00_FX:
			add	esi,			06h
			jmp	_lXFP_00_Re
			;;----------------

			;;----------------
			;; #a
			_lXFP_05:
			xor	ebx,			ebx
			mov	dword ptr [edi],	ebx
			mov	edi,			dword ptr [_xEnumTable]
			mov	ecx,			offset _xEnumTable + 04h

;;----------------
;; check
dec	ecx

_lXFP_a00:
inc	ecx

cmp	byte ptr [ecx],		00h
je	_lXFP_b00

cmp	word ptr [ecx],		3d21h	;; !=
je	_lXFP_a01			;; bl = 00h
cmp	word ptr [ecx],		3d3dh	;; ==
jne	_lXFP_a00
inc	ebx				;; bl = 01h

	;;----------------
	_lXFP_a01:
	mov	edx,			ecx
	mov	word ptr [ecx],		2020h	;; bs
	inc	ecx
	xor	eax,			eax

	_lXFP_a02:
	inc	ecx

	cmp	byte ptr [ecx],		"("
	je	_lXFP_a03
	cmp	byte ptr [ecx],		")"
	je	_lXFP_a04
	cmp	byte ptr [ecx],		00h
	jne	_lXFP_a02
;; ?

		;;----------------
		_lXFP_a05:
		xor	eax,			eax

		_lXFP_a06:
		dec	ecx
		dec	edx

		mov	bh,			byte ptr [edx]

		cmp	bh,			")"
		jne	_lXFP_a06a
		inc	eax
jmp	_lXFP_a06b

		_lXFP_a06a:
		cmp	bh,			"("
		jne	_lXFP_a06b
		dec	eax
jmp	_lXFP_a06b

		_lXFP_a06b:
		cmp	byte ptr [ecx],		bh
		jne	_lXFP_a07

		mov	byte ptr [ecx],		20h	;; bs
		mov	byte ptr [edx],		20h	;; bs
		jmp	_lXFP_a06

		_lXFP_a07:
		cmp	word ptr [ecx-01h],	2020h	;; bs - == or !=
		jne	_lXFP_a08pre

			;;----------------
			;; equal
			add	bl,			30h
			mov	byte ptr [edx+01h],	bl
xor	ebx,			ebx
			jmp	_lXFP_a00
			;;----------------

		_lXFP_a08pre:
		inc	edx
		_lXFP_a08:
		dec	edx
		cmp	byte ptr [edx],		"("
		je	_lXFP_a09
		cmp	byte ptr [edx],		")"
		je	_lXFP_a0a
		cmp	byte ptr [edx],		00h
		je	_lXFP_a0b

		mov	byte ptr [edx],		20h	;; bs
		jmp	_lXFP_a08

		_lXFP_a0a:
		inc	eax
		jmp	_lXFP_a08
		_lXFP_a09:
		dec	eax
		jns	_lXFP_a08

			;;----------------
			;; not equal
			_lXFP_a0b:
			xor	bl,			01h
			add	bl,			30h
			mov	byte ptr [edx+01h],	bl
xor	ebx,			ebx
			jmp	_lXFP_a00
			;;----------------
		;;----------------

	_lXFP_a03:
	inc	eax
	jmp	_lXFP_a02
	_lXFP_a04:
	dec	eax
	jns	_lXFP_a02
	jmp	_lXFP_a05
	;;----------------

	;;----------------
	_lXFP_b00:
	mov	ecx,				offset _xEnumTable + 03h ;; !
	mov	edx,				offset _xEnumTable + 04h
	xor	eax,				eax

	_lXFP_b01:
	inc	ecx
	_lXFP_b01ex:
	mov	al,				byte ptr [ecx]

	cmp	al,				20h	;; bs
	je	_lXFP_b01
	cmp	al,				00h
	je	_lXFP_c01

	cmp	al,				"1"
	je	_lXFP_b03

	cmp	al,				"("
	je	_lXFP_b03
	cmp	al,				")"
	je	_lXFP_b03
	cmp	al,				"!"
	je	_lXFP_b03

	cmp	word ptr [ecx],			"||"
	je	_lXFP_b04
	cmp	word ptr [ecx],			"&&"
	je	_lXFP_b04

	cmp	dword ptr [ecx],		"eurt"
	jne	_lXFP_b02
	mov	al,				byte ptr [ecx+04h]
	cmp	byte ptr [_bAscii_00+eax],	ah
	jne	_lXFP_b02
	mov	byte ptr [edx],			"1"
	add	ecx,				04h
	inc	edx
	jmp	_lXFP_b01ex

		;;----------------
		;; add 0
		_lXFP_b02:
		xor	ebx,				ebx
		mov	byte ptr [edx],			"0"
		inc	edx
		dec	ecx

		_lXFP_b05:
		inc	ecx
		mov	al,				byte ptr [ecx]

		cmp	al,				"("
		je	_lXFP_b06
		cmp	al,				")"
		je	_lXFP_b07
		cmp	al,				00h
		jne	_lXFP_b05
		jmp	_lXFP_c01			;; syntax error? #if a(

		_lXFP_b06:
		inc	ebx
		jmp	_lXFP_b05

		_lXFP_b07:
		dec	ebx
		jns	_lXFP_b05
		jmp	_lXFP_b01ex
		;;----------------

	_lXFP_b03:
	mov	byte ptr [edx],			al
	inc	edx
	jmp	_lXFP_b01

	_lXFP_b04:
	mov	byte ptr [edx],			al
	mov	byte ptr [edx+01h],		al
	add	ecx,				02h
	add	edx,				02h
	jmp	_lXFP_b01ex
	;;----------------

	;;----------------
	_lXFP_c01:
	mov	dword ptr [edx],		00h

	_lXFP_c02:
	mov	ecx,				offset _xEnumTable + 04h

	cmp	dword ptr [ecx],		00000031h	;; 1
	je	_lXFP_05win
	cmp	dword ptr [ecx],		00000030h	;; 0
	je	_lXFP_05fail	

	lea	edx,				[ecx-01h]

		;;----------------
		_lXFP_c03:
		inc	edx
		_lXFP_c03ex:
		mov	eax,				dword ptr [edx]

		test	al,				al
		jnz	_lXFP_c03fx
		mov	dword ptr [ecx],		00h
		jmp	_lXFP_c02

		_lXFP_c03fx:
		cmp	eax,				"1&&1"
		je	_lXFP_c04
		cmp	eax,				"1||1"
		je	_lXFP_c04
		cmp	eax,				"1||0"
		je	_lXFP_c04
		cmp	eax,				"0||1"
		je	_lXFP_c04

		cmp	eax,				"0&&1"
		je	_lXFP_c05
		cmp	eax,				"1&&0"
		je	_lXFP_c05
		cmp	eax,				"0&&0"
		je	_lXFP_c05
		cmp	eax,				"0||0"
		je	_lXFP_c05

		cmp	ax,				"1!"
		je	_lXFP_c06
		cmp	ax,				"0!"
		je	_lXFP_c07

		cmp	ax,				"1("
		jne	_lXFP_c08
		cmp	byte ptr [edx+02h],		")"
		jne	_lXFP_c09
		mov	byte ptr [ecx],			"1"
		add	edx,				03h
		inc	ecx
		jmp	_lXFP_c03ex		

		_lXFP_c08:
		cmp	ax,				"0("
		jne	_lXFP_c09
		cmp	byte ptr [edx+02h],		")"
		jne	_lXFP_c09
		mov	byte ptr [ecx],			"0"
		add	edx,				03h
		inc	ecx
		jmp	_lXFP_c03ex

		_lXFP_c09:
		mov	byte ptr [ecx],			al
		inc	ecx
		jmp	_lXFP_c03

		_lXFP_c04:
		mov	byte ptr [ecx],			"1"
		add	edx,				04h
		inc	ecx
		jmp	_lXFP_c03ex

		_lXFP_c05:
		mov	byte ptr [ecx],			"0"
		add	edx,				04h
		inc	ecx
		jmp	_lXFP_c03ex

		_lXFP_c06:
		mov	byte ptr [ecx],			"0"
		add	edx,				02h
		inc	ecx
		jmp	_lXFP_c03ex

		_lXFP_c07:
		mov	byte ptr [ecx],			"1"
		add	edx,				02h
		inc	ecx
		jmp	_lXFP_c03ex
		;;----------------
	;;----------------
;;----------------

;;----------------
_lXFP_05fail:
mov	esi,			dword ptr [esi+04h]
add	esi,			10h
jmp	_lXFPStartFX
;;----------------

;;----------------
_lXFP_05win:
mov	ecx,			dword ptr [esi+04h]
mov	word ptr [ecx],		0606h
mov	dword ptr [ecx+02h],	06060606h
add	esi,			08h

_lXFP_05win_00:
add	ecx,			10h
cmp	dword ptr [ecx],	646e6901h	;; #ind ;; #end
je	_lXFPStartFX

mov	word ptr [ecx],		6501h		;; #e
_lXFP_05win_01:
inc	ecx
cmp	word ptr [ecx],		7801h		;; #x
jne	_lXFP_05win_01
mov	ecx,			dword ptr [ecx+02h]
jmp	_lXFP_05win_00
;;----------------
			;;----------------

			;;----------------
			;; #c
			_lXFP_01_Ex:
			add	esi,			05h
			_lXFP_01:
			inc	esi
			cmp	byte ptr [esi],		07h	;; enum out
			jne	_lXFP_01_Sx	
			inc	esi
			jmp	_lXFPStart
			_lXFP_01_Sx:
			cmp	word ptr [esi],		7801h	;; #x
			je	_lXFP_01_Ex
			cmp	word ptr [esi],		7901h	;; #y
			je	_lXFP_01_Ex
			cmp	word ptr [esi],		0302h	;; null define
			je	_lXFP_01_Dx
			cmp	byte ptr [esi],		03h
			jne	_lXFP_01
			add	esi,			02h
;;			cmp	byte ptr [esi-01h],	79h	;; y
cmp	byte ptr [esi+01h],	79h	;; y
			jne	_lXFPStart
;;			add	esi,			0eh
add	esi,			10h
			jmp	_lXFPStart

			_lXFP_01_Dx:				;; ???
			add	esi,			02h
			cmp	byte ptr [esi],		0ah
			jne	_lXFPStart
			inc	esi
			jmp	_lXFPStart
			;;----------------

			;;----------------
			;; blocks
_lXFP_02_EX:
cmp	byte ptr [_bWhileCondCorrect],	00h
je	_lXFP_02
mov	byte ptr [_bWhileCondCorrect],	00h
mov	byte ptr [edi],			")"
inc	edi
			_lXFP_02:
			movsw
			mov	edx,			dword ptr [esi]
			sub	edi,			02h
			mov	dword ptr [edx+02h],	edi
			add	edi,			06h
			add	esi,			04h
			jmp	_lXFPStart
			;;----------------
		;;----------------

		;;----------------
		;; string preprocessor

			;;----------------
			;; in
			_lXFPStrPrIn:
			add	esi,				04h
			mov	dword ptr [_dMapProcCode],	edi
			mov	edi,				offset _bFuncCodeBase
			jmp	_lXFPStart
			;;----------------

			;;----------------
			;; out
			_lXFPStrPrOut:
			movsd							;; copy !@@e

			mov	dword ptr [_dWWWFont],		esi
			mov	esi,				offset _bFuncCodeBase	;; esi = old buffer
			mov	edi, 				offset _bFuncCodeLocals	;; edi = new buffer

			mov	ebx,				esi
			_lXFPStrPrOutAX:
			inc	ebx
			cmp	dword ptr [ebx],		61404021h	;; !@@a
			jne	_lXFPStrPrOutAX					;; ebx = arg types

			lea	ecx,				[ebx+03h]
			_lXFPStrPrOutBX:
			inc	ecx
;;			cmp	dword ptr [ecx],		65404021h	;; !@@e
;;			error - no args
			cmp	byte ptr [ecx-01h],		40h		;; @
			jne	_lXFPStrPrOutBX					;; ecx = first arg

			jmp	_lXFPStrPrOutDX

			_lXFPStrPrOutEX:
			stosb
			_lXFPStrPrOutCX:
			cmp	esi,				ebx
			jne	_lXFPStrPrOutDX

				;;----------------
				;; huh...
				mov	word ptr [edi],		7301h		;; #s
				mov	ebx,			dword ptr [_dWWWFont]
				mov	dword ptr [edi+02h],	ebx
				mov	esi,			offset _bFuncCodeLocals
				mov	edi,			dword ptr [_dMapProcCode]
				jmp	_lXFPStart
				;;----------------

			_lXFPStrPrOutSX:
			cmp	byte ptr [esi],			5eh		;; ^
			je	_lXFPStrPrOutTX
			cmp	byte ptr [esi],			25h		;; %
			je	_lXFPStrPrOutTX
			stosb
			_lXFPStrPrOutTX:
			movsb
			_lXFPStrPrOutDX:
			lodsb
			cmp	al,				5ch		;; \ 
			je	_lXFPStrPrOutSX
			cmp	al,				25h		;; %
			je	lXFPStrPr_GX
			cmp	al,				5eh		;; ^
			jne	_lXFPStrPrOutEX

				;;----------------
				;; find type
				lXFPStrPr_GX:
				lea	ebp,				[ebx+06h]	;; ebp = first arg type

				_lXFPStrPrOutJX:
				mov	edx,				esi		;; edx = position in string

				_lXFPStrPrOutFX:
				mov	al,				byte ptr [ebp]

				cmp	al,				5eh		;; ^
				je	_lXFPStrPrOutGX

				cmp	al,				byte ptr [edx]
				jne	_lXFPStrPrOutHX
				inc	ebp
				inc	edx
				jmp	_lXFPStrPrOutFX

				_lXFPStrPrOutHX:
				inc	ebp
				cmp	byte ptr [ebp-01h],		5eh		;; ^
				jne	_lXFPStrPrOutHX
				jmp	_lXFPStrPrOutJX

				_lXFPStrPrOutGX:
				mov	esi,				edx

					;;----------------
					;; replace
					add	ebp,				02h	;; remove ^=

					_lXFPStrPrOutLX:
					mov	al,				byte ptr [ebp]
					cmp	al,				3ch	;; <
					je	_lXFPStrPrOutIX
					cmp	al,				3eh	;; >
					je	_lXFPStrPrOutKX
					cmp	al,				24h	;; $
					je	_lXFPStrPrOutMX
					cmp	al,				5eh	;; ^
					je	_lXFPStrPrOutCX
					cmp	al,				22h	;; "
					je	_lXFPStrPrOutCX
					mov	byte ptr [edi],		al
					inc	edi
					inc	ebp
					jmp	_lXFPStrPrOutLX

					_lXFPStrPrOutMX:
					inc	ebp
					_lXFPStrPrOutNX:
					cmp	dword ptr [ecx],		65404021h	;; !@@e
					je	_lXFPStrPrOutLX
					mov	al,				byte ptr [ecx]
					cmp	al,				40h		;; @
					je	_lXFPStrPrOutOX
					mov	byte ptr [edi],		al
					inc	edi
					inc	ecx
					jmp	_lXFPStrPrOutNX
					_lXFPStrPrOutOX:
					inc	ecx
					jmp	_lXFPStrPrOutLX

					_lXFPStrPrOutIX:
					inc	ebp
;;					cmp	byte ptr [edx-01h],		22h	;; "
;;					je	_lXFPStrPrOutUX				;; ???
					mov	word ptr [edi],			2b22h	;; "+
					add	edi,				02h
					jmp	_lXFPStrPrOutLX

;;					_lXFPStrPrOutUX:
;;					inc	edx
;;					jmp	_lXFPStrPrOutLX

					_lXFPStrPrOutKX:
					inc	ebp
;;					cmp	byte ptr [esi],			22h	;; " ;; [edx+01h] ???
;;					je	_lXFPStrPrOutPX
					mov	word ptr [edi],			222bh	;; +"
					add	edi,				02h
					jmp	_lXFPStrPrOutLX

					_lXFPStrPrOutPX:
					inc	esi
					jmp	_lXFPStrPrOutLX
					;;----------------
				;;----------------



			;;----------------
		;;----------------

	_lXFPEnd:
	mov	esp,			_dStackPos	;; load stack
	add	esi,			04h
	add	edi,			04h
	;;----------------

	mov	_dCurrStr,	offset _sProg_04
	mov	eax,		52h
	call	_lSetProg

	;;----------------
	;; capture world...
	mov	dword ptr [_dErrorCodeStart],	edi	;; for syntax error
	mov	_dStackPos,			esp

	xor 	ebx,				ebx	;; f l a g s
							;; 0 0 0 0 b
							;; | | | |
							;; | | | is in function (0 - out)
							;; | | | dont add set/call/local etc
							;; | | |
							;; | | is int struct (0 - out)
							;; | | dont add globals/endglobals
							;; | |
							;; | is in interface (0 - out)
							;; | not entry to functions/methods
							;; |
							;; is in globals (0 - out)
							;; not add nothing


	push	ebx			;; 00h on stack top

		;;----------------
		;; parse anon functions
		mov	dword ptr [_dFNPAnonESITemp],	esi

		mov	eax,				dword ptr [_dAnonFuncCnt]
		shl	eax,				04h
		add	eax,				offset _dAnonFuncTable
		mov	dword ptr [_dAnonFuncCnt],	eax

			;;----------------
			;; build anon blocks
			mov	eax,			offset _dAnonFuncTable - 10h
			xor	edx,			edx
			xor	ecx,			ecx

			_lFNPAnonBlockBld_Str:
			add	eax,			10h

			mov	ebp,			dword ptr [eax]
			test	ebp,			ebp
			jz	_lFNPAnonBlockBld_End

			cmp	edx,			ebp
			jb	_lFNPAnonBlockBld_New
			cmp	ecx,			ebp
			jb	_lFNPAnonBlockBld_Str

			_lFNPAnonBlockBld_New:
			mov	ecx,			ebp
			mov	edx,			dword ptr [eax+04h]
			mov	dword ptr [eax-10h],	00h
			jmp	_lFNPAnonBlockBld_Str

			_lFNPAnonBlockBld_End:
			mov	dword ptr [eax-10h],	00h
			;;----------------

		_lFNPAnonStr:
		mov	eax,				dword ptr [_dAnonFuncCnt]
		sub	eax,				10h
		cmp	eax,				offset _dAnonFuncTable - 10h
		je	_lFNPAnonEnd

		mov	dword ptr [_dAnonFuncCnt],	eax

			;;----------------
			;; use new or old anon block
			cmp	dword ptr [eax],	00h
			jne	_lFNPAnonOldBlock
				;;----------------
				;; get new anon block
				_lFNPAnonNewBlock:
				mov	edx,					dword ptr [_dAnonBlock]
				add	edx,					04h
				mov	dword ptr [edx],			edi
				mov	dword ptr [_dAnonBlock],		edx
				;;----------------

			_lFNPAnonOldBlock:
			;;----------------

			;;----------------
			;; parse func
			mov	esi,					dword ptr [eax+08h]	;; esi = 123 void (*)
			mov	dword ptr [eax+0ch],			edi

			mov	dword ptr [edi],			"cnuf"
			mov	dword ptr [edi+04h],			"noit"
			mov	dword ptr [edi+08h],			"    "
			mov	dword ptr [edi+0ch],			"jc  "
			mov	dword ptr [edi+10h],			"ona_"
			mov	dword ptr [edi+14h],			"_myn"
			mov	byte ptr [edi+18h],			"_"

			add	edi,					19h

			jmp	_lFNPAnonNameStr
			_lbl:
			stosb
			_lFNPAnonNameStr:
			lodsb
			cmp	al,					20h		;; bs
			jne	_prew

			mov	edx,					esi		;; edx = return type

			_lbl:
			inc	esi
			cmp	byte ptr [esi],				"("
			jne	_prew							;; esi = arguments

			;; adding takes
			mov	dword ptr [edi],			6b617420h	;; _tak
			mov	dword ptr [edi+04h],			00207365h	;; es_
			add	edi,					07h

			inc	esi
			cmp	byte ptr [esi],				")"
			jne	_lFNPAnonNonVoid

			mov	dword ptr [edi],			68746f6eh	;; noth
			mov	dword ptr [edi+04h],			00676e69h	;; ing
			add	edi,					07h
			inc	esi
			jmp	_lFNPAnonRetParam

			_lFNPAnonNonVoidEX:
			stosb
			_lFNPAnonNonVoid:
			lodsb
			cmp	al,					")"
			jne	_lFNPAnonNonVoidEX

			_lFNPAnonRetParam:
			add	esi,					06h
			mov	dword ptr [edi],			74657220h	;; _ret
			mov	dword ptr [edi+04h],			736e7275h	;; urns
			mov	byte ptr [edi+08h],			20h		;; _
			add	edi,					09h

			_lbl:						;; copy func type
			mov	al,					byte ptr [edx]
			cmp	al,					"("
			je	_next
			mov	byte ptr [edi],				al
			inc	edx
			inc	edi
			jmp	_prew

			_lbl:
			mov	dword ptr [edi],			2f2f0a0dh	;; nl//
			mov	dword ptr [edi+04h],			"po #"
			mov	dword ptr [edi+08h],			"noit"
			mov	dword ptr [edi+0ch],			0a0d6c61h	;; al new line

			add	edi,					10h

			mov	dword ptr [_dBCP],			edi	;; system in
			or	ebx,					01h

			mov	dword ptr [_dFCL],			offset _bFuncCodeLocals
			mov	dword ptr [_dFCB],			offset _bFuncCodeBase

			mov	dword ptr [_dInFuncBlockMax],		00h
			mov	dword ptr [_dInFuncBlockStack],		00h
			mov	dword ptr [_dInFuncBlockPnt],		offset _dInFuncBlockStack + 04h

			mov	byte ptr [_bFuncCodeNop],		00h

			mov	dword ptr [_dGeneratedLocalsID],	0ffffffffh

			jmp	_lFNPLine
			;;----------------

		_lFNPAnonEnd:
		mov	esi,				dword ptr [_dFNPAnonESITemp]
		mov	dword ptr [_dFinalParseOffset],	edi

			;;----------------
			;; close last anon block
			mov	edx,				dword ptr [_dAnonBlock]
			add	edx,				04h
			mov	dword ptr [edx],		edi
			mov	dword ptr [_dAnonBlock],	edx
			;;----------------

		;;----------------

;;----------------
;; add copy group code
push	esi
mov	ecx,			_sGroupCopyCodeSize
mov	esi,			offset _sGroupCopyCode
rep	movsb

pop	esi
;;----------------

	jmp	_lFNPLine

	_lFNPLineEx:
	movsw

	_lFNPLine:
	mov	eax,			dword ptr [esi]

	cmp	al,			00h
	je	_lFNPEnd

	cmp	ax,			0a0dh
	jne	_lFNPParseStart
	add	esi,			02h
	jmp	_lFNPLine

		;;----------------
		;; global instruction parsing
		_lFNPParseStart:

			;;----------------
			;; nocjass
			cmp	ax,			3901h		;; #9
			jne	_next

			lea	edx,			[esi+02h]
			mov	eax,			dword ptr [_dSynDesc]
			mov	esi,			dword ptr [eax]
			mov	ecx,			dword ptr [eax+04h]
			add	eax,			08h
			mov	dword ptr [_dSynDesc],	eax
			mov	dword ptr [edi],	20212f2fh	;; //!_
			add	edi,			04h
			sub	ecx,			esi
			rep	movsb
			mov	esi,			edx
			jmp	_lFNPLine
			;;----------------

		_lbl:
		test	ebx,			01b
		jp	_next
		mov	edi,			offset _bFuncCodeOneLine

			;;----------------
			;; comment
			_lbl:
			cmp	ax,			2f2fh		;; //
			jne	_next

			cmp	byte ptr [esi+02h],	21h		;; !
			je	_lFNPExCode

			_lFNPCommExs:
			inc	esi
			cmp	word ptr [esi],		0a0dh		;; nl
			jne	_lFNPCommExs
			add	esi,			02h
			mov	eax,			dword ptr [esi]
			jmp	_lFNPParseStart
			;;----------------

		_lbl:
		cmp	al,			0ch		;; ;
		je	_lFNPVarX

		_lbl:
		test	ebx,			01b
		jp	_lFNPOutside				;; globals ? ;; out the function
		;;----------------

		;;----------------
		;; in function
		cmp	eax,			6c6c6163h	;; call
		jne	_next
		cmp	byte ptr [esi+04h],	20h		;; _
		je	_lFNPCopyParse

		_lbl:
		cmp	eax,			20746573h	;; set_
		je	_lFNPCopyParse

		_lbl:
		cmp	eax,			"tats"
		jne	_next
		cmp	dword ptr [esi+04h],	"i ci"
		jne	_next
		cmp	byte ptr [esi+08h],	"f"
		jne	_next
		cmp	byte ptr [esi+09h],	"("
		jbe	_lFNPCopyParse

		_lbl:
		cmp	eax,			"lpmi"
		jne	_next
		cmp	dword ptr [esi+04h],	"neme"
		jne	_next
		cmp	word ptr [esi+08h],	" t"
		je	_lFNPCopy

		_lbl:
		cmp	eax,			"olbv"
		jne	_next
		cmp	word ptr [esi + 04h],	"kc"
		jne	_next
		cmp	byte ptr [esi + 06h],	20h
		jg	_next
		call	_lInFuncBlockIn
		call	_lFNPCheckBlock
		mov	byte ptr [_bInVblock],	01h
		test	eax,			eax
		jz	_lFNPCopyParse
		mov	dword ptr [eax],	"vdne"
		mov	dword ptr [eax + 04h],	"colb"
		mov	byte ptr [eax + 08h],	"k"
		jmp	_lFNPCopyParse

		_lbl:
		cmp	eax,			"vdne"
		jne	_next
		cmp	dword ptr [esi + 04h],	"colb"
		jne	_next
		cmp	byte ptr [esi + 08h],	"k"
		jne	_next
		cmp	byte ptr [esi + 09h],	20h
		jg	_next
		call	_lInFuncBlockOut
		call	_lInFuncBlockOutVars
		mov	byte ptr [_bInVblock],	00h
		jmp	_lFNPCopyParse

		_lbl:
		cmp	eax,			61636f6ch	;; loca
		jne	_next
		cmp	word ptr [esi+04h],	206ch		;; l_
		jne	_next
		jmp	_lFNVarParse

;		_lbl:
;		cmp	eax,			74617473h	;; stat
;		jne	_next
;		cmp	dword ptr [esi+04h],	69206369h	;; ic_i
;		jne	_next
;		cmp	word ptr [esi+08h],	2066h		;; f_
;		je	_lFNPCopyParse

			;;----------------
			;; if
			_lbl:
			cmp	ax,			6669h		;; if
			jne	_next
			cmp	byte ptr [esi+02h],	2eh		;; _ ;; !!!!
			jg	_next

			call	_lInFuncBlockIn

			movsw
			mov	dword ptr [edi],	20202020h	;; bs
			mov	dword ptr [edi+04h],	20202020h	;; bs
			mov	dword ptr [edi+08h],	20202020h	;; bs
			add	edi,			0ch
			mov	byte ptr [_bCodeSys],	01h
			mov	byte ptr [_bCodePosOp],	00h

			jmp	_FNPIf

			_lbl:
			cmp	eax,			65736c65h	;; else
			jne	_next
			cmp	word ptr [esi+04h],	0a0dh		;; new line
			jne	_lFNPIfUX
			call	_lInFuncBlockOut
			call	_lInFuncBlockOutVars
			call	_lInFuncBlockIn
			jmp	_lFNPCopyParse
			_lFNPIfUX:
			cmp	word ptr [esi+04h],	7801h		;; #x
			jne	_lFNPIfEX

			call	_lInFuncBlockOut
			call	_lInFuncBlockOutVars
			call	_lInFuncBlockIn

			mov	ecx,			dword ptr [esi+06h]
			mov	dword ptr [esi+04h],	06060606h
			cmp	word ptr [esi+0ah],	0a0dh		;; new line
			je	_lFNPIfElseFX
			mov	word ptr [esi+08h],	0a0dh		;; new line
			jmp	_lFNPIfBlockEx
			_lFNPIfElseFX:
			mov	word ptr [esi+08h],	0606h		;; new line
			jmp	_lFNPIfBlockEx

			_lFNPIfEX:
			cmp	word ptr [esi+04h],	6669h		;; if
			jne	_next
			cmp	byte ptr [esi+06h],	2eh		;; _ ;; !!!!
			jg	_next

			call	_lInFuncBlockOut
			call	_lInFuncBlockOutVars
			call	_lInFuncBlockIn

			_FNPIf:
			mov	eax,			esi
			_FNPIfx:
			inc	eax
			cmp	dword ptr [eax],	6e656874h	;; then
			je	_FNPIfs
			cmp	word ptr [eax],		7801h		;; #x
			je	_lFNPIfBlock
			cmp	word ptr [eax],		0a0dh
			jne	_FNPIfx
			mov	word ptr [eax],		3001h		;; #0
			jmp	_lFNPCopyParse
			_FNPIfs:
			cmp	byte ptr [eax+04h],	20h
			je	_lFNPCopyParse
			cmp	word ptr [eax+04h],	0a0dh
			je	_lFNPCopyParse
			jmp	_FNPIfx

			_lFNPIfBlock:
			mov	ecx,			dword ptr [eax+02h]

			mov	dword ptr [eax],	06060606h
			mov	word ptr [eax+04h],	3001h		;; #0

			cmp	dword ptr [ecx+10h],	65736c65h	;; else
			jne	_lFNPIfBlockEx
			cmp	word ptr [ecx+14h],	6669h		;; if
			jne	_lFNPIfBlockSx

lea	eax,			[ecx+16h]
_lFNPIfBlockGX:
inc	eax
cmp	word ptr [eax],		7801h	;; #x
je	_lFNPIfBlockNull
cmp	word ptr [eax],		0a0dh	;; nl
jne	_lFNPIfBlockGX
jmp	_lFNPIfBlockEx

;;			cmp	byte ptr [ecx+16h],	2dh		;; _ ;; !!!
;;			jbe	_lFNPIfBlockNull

			_lFNPIfBlockSx:
cmp	word ptr [ecx+14h],		7801h	;; #x
je	_lFNPIfBlockNull

;;			cmp	byte ptr [ecx+14h],	2dh		;; _ ;; !!!
;;			jbe	_lFNPIfBlockNull

			_lFNPIfBlockEx:
			mov	dword ptr [ecx],	69646e65h	;; endi
			mov	word ptr [ecx+04h],	0666h		;; f_
			jmp	_lFNPCopyParse

			_lFNPIfBlockNull:
			mov	dword ptr [ecx],	06060606h	;; ex bs
			mov	word ptr [ecx+04h],	0606h
			cmp	word ptr [ecx-02h],	0a0dh		;; new line
			jne	_lFNPCopyParse
			mov	word ptr [ecx-02h],	0606h
			jmp	_lFNPCopyParse

			_lbl:
			cmp	eax,			69646e65h	;; endi
			jne	_next
			cmp	byte ptr [esi+04h],	66h		;; f
			jne	_next
			cmp	byte ptr [esi+05h],	20h		;; _

			call	_lInFuncBlockOut
			call	_lInFuncBlockOutVars
			jbe	_lFNPCopyParse
			;;----------------

			;;----------------
			;; loop
			_lbl:
			cmp	eax,			706f6f6ch	;; loop
			jne	_next
			cmp	byte ptr [esi+04h],	20h		;; _
			jg	_next
			call	_lInFuncBlockIn
			call	_lFNPCheckBlock
			test	eax,			eax
			jz	_lFNPCopyParse
			mov	dword ptr [eax],	6c646e65h	;; endl
			mov	dword ptr [eax+04h],	06706f6fh	;; oop_
			jmp	_lFNPCopyParse

			_lbl:
			cmp	eax,			6c646e65h	;; endl
			jne	_next
			cmp	word ptr [esi+04h],	6f6fh		;; oo
			jne	_next
			cmp	byte ptr [esi+06h],	70h		;; p
			jne	_next
			cmp	byte ptr [esi+07h],	20h		;; _
			jg	_next
			call	_lInFuncBlockOut
			call	_lInFuncBlockOutVars
			jmp	_lFNPCopyParse

			_lbl:
			cmp	eax,			74697865h	;; exit
			jne	_next
			cmp	dword ptr [esi+04h],	6e656877h	;; when
			jne	_next
			cmp	byte ptr [esi+08h],	2dh		;; _ ;; !!!!
			jg	_next

			movsd
			movsd
			mov	dword ptr [edi],	20202020h
			mov	word ptr [edi+04h],	2020h
			add	edi,			06h

			mov	byte ptr [_bCodeSys],	01h
			mov	byte ptr [_bCodePosOp],	00h

			jmp	_lFNPCopyParse

				;;----------------
				;; whilenot
				_lbl:
				cmp	eax,			6c696877h	;; whil
				jne	_next
				cmp	dword ptr [esi+04h],	746f6e65h	;; enot
				jne	_next
				cmp	byte ptr [esi+08h],	2dh		;; _ ;; !!!!
				jg	_next
				call	_lInFuncBlockIn
				call	_lFNPCheckBlock
				add	esi,			08h
				test	eax,			eax
				jz	_lFNPWhileEX
				mov	dword ptr [eax],	6c646e65h	;; endl
				mov	dword ptr [eax+04h],	06706f6fh	;; oop_
				_lFNPWhileEX:
				mov	eax,			dword ptr [_dFCB]
				mov	dword ptr [eax],	706f6f6ch	;; loop
				mov	word ptr [eax+04h],	0a0dh		;; new line
				add	eax,			06h
				mov	dword ptr [_dFCB],	eax
				cmp	byte ptr [esi],		10h		;; 0a0dh or #
				jbe	_lFNPCopyParse
				mov	dword ptr [edi],	74697865h	;; exit
				mov	dword ptr [edi+04h],	6e656877h	;; when
				mov	byte ptr [edi+08h],	20h		;; _
				add	edi,			09h
				jmp	_lFNPCopyParse

				_lbl:
				cmp	eax,			77646e65h	;; endw
				jne	_next
				cmp	dword ptr [esi+04h],	656c6968h	;; hile
				jne	_next
;cmp	byte ptr [esi + 08h],	20h
;ja	_lEndwhilenot
;add	esi,			09h
;jmp	_lEndwhilenotEx
;_lEndwhilenot:
				cmp	dword ptr [esi+08h],	0d746f6eh	;; not_
				jne	_next
				add	esi,			0bh
;_lEndwhilenotEx:
;call	_lInFuncBlockOut
;call	_lInFuncBlockOutVars
				mov	dword ptr [edi],	6c646e65h	;; endl
				mov	dword ptr [edi+04h],	00706f6fh	;; oop_
				add	edi,			07h
				call	_lInFuncBlockOut
				call	_lInFuncBlockOutVars
				jmp	_lFNPCopyParse
				;;----------------

				;;----------------
				;; do
				_lbl:
				cmp	ax,			6f64h		;; do
				jne	_next
				cmp	byte ptr [esi+02h],	21h
				jg	_next

				call	_lInFuncBlockIn

				mov	dword ptr [edi],	706f6f6ch	;; loop
				mov	word ptr [edi+04h],	0a0dh		;; new line
				add	edi,			06h

				call	_lFNPCheckBlock
				add	esi,			02h
				test	eax,			eax
				jz	_lFNPCopyParse

				cmp	dword ptr [eax+10h],	6c696877h	;; whil
				jne	_lFNPDo
				cmp	dword ptr [eax+14h],	746f6e65h	;; enot
				jne	_lFNPDo
				cmp	byte ptr [eax+18h],	2dh		;; _ ;; !!!!
				jg	_lFNPDo

				mov	dword ptr [eax],	06060606h
				mov	word ptr [eax+04h],	0606h
				mov	dword ptr [eax+0eh],	78650a0dh	;; __ex
				mov	dword ptr [eax+12h],	68777469h	;; itwh
				mov	word ptr [eax+16h],	6e65h		;; en

				add	eax,			11h
				_lFNPDoEX:
				inc	eax
				cmp	word ptr [eax],		0a0dh		;; nl
				jne	_lFNPDoEX
				mov	word ptr [eax],		6f01h		;; #o
				jmp	_lFNPCopyParse

				_lFNPDo:
				mov	dword ptr [eax],	6c646e65h	;; endl
				mov	dword ptr [eax+04h],	06706f6fh	;; oop_
				jmp	_lFNPCopyParse

				_lbl:
				cmp	eax,			64646e65h	;; endd
				jne	_next
				cmp	word ptr [esi+04h],	206fh		;; o_
				jne	_next
				cmp	dword ptr [esi+06h],	6c696877h	;; whil
				jne	_next
				cmp	dword ptr [esi+0ah],	746f6e65h	;; enot
				jne	_next
				cmp	byte ptr [esi+0eh],	2dh		;; _ ;; !!!!
				jg	_next

				call	_lInFuncBlockOut
				call	_lInFuncBlockOutVars

				mov	dword ptr [esi],	74697865h	;; exit
				mov	dword ptr [esi+04h],	6e656877h	;; when
				mov	dword ptr [esi+08h],	06060606h
				mov	word ptr [esi+0ch],	06060606h
				mov	eax,			esi
				jmp	_lFNPDoEX
				;;----------------
			;;----------------

			;;----------------
			;; ex endloop
			_lbl:
			cmp	ax,			6601h		;; #f
			jne	_next
			call	_lInFuncBlockOut
			call	_lInFuncBlockOutVars
			add	esi,			02h
			mov	dword ptr [edi],	6e650a0dh	;; nl en
			mov	dword ptr [edi+04h],	6f6f6c64h	;; dloo
			mov	dword ptr [edi+08h],	000a0d70h	;; p nl
			add	edi,			0bh
			jmp	_lFNPIncDecSTX
			;;----------------

		_lbl:
		cmp	eax,			75746572h	;; retu
		jne	_next
		cmp	word ptr [esi+04h],	6e72h		;; rn
		jne	_next
		cmp	byte ptr [esi+06h],	2eh		;; _ ;; !!!!	
		jg	_next

		movsd
		movsw
		mov	dword ptr [edi],	20202020h	;; bs
		mov	dword ptr [edi+04h],	20202020h	;; bs
		add	edi,			08h
		mov	byte ptr [_bCodeSys],	01h
		mov	byte ptr [_bCodePosOp],	00h
	
		jmp	_lFNPCopyParse

			;;----------------
			;; in func block in
			_lInFuncBlockIn:
			push	eax
			push	ebx

			mov	eax,				dword ptr [_dInFuncBlockMax]
			inc	eax
			mov	ebx,				dword ptr [_dInFuncBlockPnt]
			mov	dword ptr [_dInFuncBlockMax],	eax
			mov	dword ptr [ebx],		eax
			add	ebx,				04h
			mov	dword ptr [_dInFuncBlockPnt],	ebx

			pop	ebx
			pop	eax

			retn
			;;----------------

			;;----------------
			;;in func block out
			_lInFuncBlockOut:
			push	eax
			push	ebx

			mov	ebx,				dword ptr [_dInFuncBlockPnt]
			mov	eax,				dword ptr [ebx]	;; eax - outed block id
			sub	ebx,				04h
			mov	dword ptr [_dInFuncBlockPnt],	ebx

			pop	ebx
			pop	eax

			retn
			;;----------------

			;;----------------
			;; in func block out - process variables
			_lInFuncBlockOutVars:
			push	ecx
			push	eax

			mov	eax,				dword ptr [_dInFuncBlockPnt]
			mov	ecx,				offset _bFuncCodeLocals
			;mov	eax,				dword ptr [eax - 04h]
			mov	eax,				dword ptr [eax]

			_lInFuncBlockOut_CheckVars:
			cmp	ecx,				dword ptr [_dFCL]
			jge	_lInFuncBlockOut_CheckVarsEnd

			cmp	word ptr [ecx],			4d23h		;; #M
			jne	_lInFuncBlockOut_CheckVarsGetNext

			cmp	dword ptr [ecx + 03h],		eax
			jne	_lInFuncBlockOut_CheckVarsGetNext

				;;----------------
				;; undef it

				mov	byte ptr [ecx + 02h],		00h
			;	mov	word ptr [edi],			"O#"
			;	add	edi,				02h
			;
			;	add	ecx,				0dh
			;	xor	ebx,				ebx
			;
			;	_lInFuncBlockOut_UndefGetName:
			;	inc	ecx
			;	cmp	byte ptr [ecx - 01h],		" "
			;	jne	_lInFuncBlockOut_UndefGetName
			;
			;	cmp	dword ptr [ecx],		"arra"
			;	jne	_lInFuncBlockOut_Undef
			;	cmp	word ptr [ecx + 04h],		" y"
			;	jne	_lInFuncBlockOut_Undef
			;	add	ecx,				06h
			;
			;	_lInFuncBlockOut_Undef:
			;	mov	bl,				byte ptr [ecx]
			;	cmp	[_bAscii_00 + ebx],		bh
			;	je	_lInFuncBlockOut_UndefEnd
			;	mov	byte ptr [edi],			bl
			;	inc	ecx
			;	inc	edi
			;	jmp	_lInFuncBlockOut_Undef
			;
			;	_lInFuncBlockOut_UndefEnd:
			;	mov	word ptr [edi],			0a0dh
			;	add	edi,				02h
				;;----------------

			_lInFuncBlockOut_CheckVarsGetNext:
			inc	ecx
			cmp	word ptr [ecx - 02h],		0a0dh
			jne	_lInFuncBlockOut_CheckVarsGetNext
			jmp	_lInFuncBlockOut_CheckVars

			_lInFuncBlockOut_CheckVarsEnd:
			pop	eax
			pop	ecx

			retn
			;;----------------

			;;----------------
			_lInFuncBlockOutVarsEx:
			mov	eax,				dword ptr [_dInFuncBlockPnt]
			pop	ecx
			mov	eax,				dword ptr [eax]

			_lInFuncBlockOutVarsEx_Start:
			cmp	dword ptr [esp],		00h
			je	_lInFuncBlockOutVarsEx_End

			cmp	dword ptr [esp + 08h],		eax
			jb	_lInFuncBlockOutVarsEx_End

				;;----------------
				;; generated groups
				mov	ebx,				dword ptr [esp + 04h]
				cmp	dword ptr [ebx],		"rgjc"
				jne	_lInFuncBlockOutVarsEx_Clean
				cmp	dword ptr [ebx + 04h],		"_ngf"
				jne	_lInFuncBlockOutVarsEx_Clean

				mov	edx,				dword ptr [_dFreeForGroupPnt]
				add	edx,				04h
				mov	dword ptr [edx],		ebx
				mov	dword ptr [_dFreeForGroupPnt],	edx
				;;----------------

			_lInFuncBlockOutVarsEx_Clean:
			add	esp,				0ch
			jmp	_lInFuncBlockOutVarsEx_Start

			_lInFuncBlockOutVarsEx_End:
			jmp	ecx
			;;----------------

			;;----------------
			;; auto flush locals
			_lbl:
			cmp	eax,			"sulf"
			jne	_next
			cmp	dword ptr [esi+04h],	"ol h"
			jne	_next
			cmp	dword ptr [esi+08h],	"slac"
			jne	_next
			cmp	word ptr [esi+0ch],	0a0dh	;; nl
			jne	_next

			;;add	esi,			0ch

			jmp	_lFNPCopyParse

			;;jmp	_lFNPCopyParseNext	;; eax mast be null!
			;;----------------

			;;----------------
			;; ++ -- pre
			_lbl:
			cmp	ax,			2b2bh		;; ++
			jne	_next

				;;----------------
				_lFNPIDPreX:
				mov	ecx,			edi
				mov	edx,			esi

				mov	edi,			esi
				lea	esi,			[esi+02h]

				_lFNPIDPreXfx:
				movsb
				cmp	word ptr [esi],		0a0dh	;; nl
				jne	_lFNPIDPreXfx

				mov	word ptr [edi],		ax
				add	edi,			02h

				mov	edi,			ecx
				mov	esi,			edx
				jmp	_lFNPFuncScanIn
				;;----------------

			_lbl:
			cmp	ax,			2d2dh		;; --
			je	_lFNPIDPreX
			;;----------------

		_lbl:
		cmp	eax,			"cdne"
		jne	_next
		cmp	dword ptr [esi + 04h],	"blla"
		jne	_next
		cmp	dword ptr [esi + 07h],	"kcab"
		jne	_next
		cmp	byte ptr [esi + 0bh],	20h
		jg	_next

		mov	eax,			ebx
		and	eax,			10b
		jz	_lCallbackEndf
		mov	dword ptr [esi],	"mdne"
		mov	dword ptr [esi + 04h],	"ohte"
		mov	dword ptr [esi + 08h],	"   d"
		jmp	_lFNPFuncOut

		_lCallbackEndf:
		mov	dword ptr [esi],	"fdne"
		mov	dword ptr [esi + 04h],	"tcnu"
		mov	dword ptr [esi + 08h],	" noi"
		jmp	_lFNPFuncOut

		_lbl:
		cmp	eax,			66646e65h	;; endf
		jne	_next
		cmp	dword ptr [esi+04h],	74636e75h	;; unct
		jne	_next
		cmp	word ptr [esi+08h],	6f69h		;; io
		jne	_next
		cmp	byte ptr [esi+0ah],	6eh		;; n
		jne	_next
		cmp	byte ptr [esi+0bh],	20h		;; _	
		jg	_next

			;;----------------
			;; function out
			_lFNPFuncOut:
			mov	edi,			dword ptr [_dBCP]

				;;----------------
				;; get function type
				mov	ecx,				edi
				_lFNPFuncOutBX:
				dec	ecx
				cmp	byte ptr [ecx - 01h],		" "
				jne	_lFNPFuncOutBX

				mov	dword ptr [_sFuncType],		ecx
				;;----------------

				;;----------------
				;; sys locals

					;;----------------
					;; index
					mov	al,			byte ptr [_bFCLLMAX]
					mov	byte ptr [_bFCLLMAX],	40h
					_lFNPFuncOutIS:
					cmp	al,			40h
					je	_lFNPFuncOutEX

					mov	dword ptr [edi],	61636f6ch	;; loca
					mov	dword ptr [edi+04h],	6e69206ch	;; l_in
					mov	dword ptr [edi+08h],	65676574h	;; tege
					mov	dword ptr [edi+0ch],	78712072h	;; r_qx
					mov	byte ptr [edi+10h],	al
					mov	word ptr [edi+11h],	0a0dh		;; nl
					add	edi,			13h
					dec	al
					jmp	_lFNPFuncOutIS
					;;----------------
				;;----------------

;;----------------
;; add locals and code

;; locals in stack:
;;
;; base var name
;; replaced var name
;; block id

			_lFNPFuncOutEX:

push	ebx
push	esi	;; store esi
push	00h
push	00h
push	00h

mov	edx,				dword ptr [_dFCL]
inc	edx

	;;----------------
	;; get static variables
	mov	esi,				offset _bFuncCodeLocals

	_lGetStaticVariables:
	cmp	esi,				dword ptr [_dFCL]
	jae	_lGetStaticVariables_End

	cmp	dword ptr [esi + 06h],		"tats"
	jne	_lGetStaticVariables_GetNext
	cmp	dword ptr [esi + 09h],		" cit"
	jne	_lGetStaticVariables_GetNext

	add	esi,				0dh

	_lGetStaticVariables_Type:
	inc	esi
	cmp	byte ptr [esi - 01h],		" "
	jne	_lGetStaticVariables_Type

	cmp	dword ptr [esi],		"arra"
	jne	_lGetStaticVariables_TypeNext
	cmp	word ptr [esi + 04h],		" y"
	jne	_lGetStaticVariables_TypeNext
	add	esi,				06h

	_lGetStaticVariables_TypeNext:
	push	00h
	push	edx
	push	esi

	mov	dword ptr [edx],		"tsjc"
	mov	dword ptr [edx + 04h],		"_ngt"

	mov	ebp,				dword ptr [_dStaticVarsId]
	inc	ebp
	mov	dword ptr [_dStaticVarsId],	ebp
	and	ebp,				0ff000000h
	shr	ebp,				17h
	mov	ax,				word ptr [ebp + _bIntToHexStr]
	mov	word ptr [edx + 08h],		ax
	mov	ebp,				dword ptr [_dStaticVarsId]
	and	ebp,				00ff0000h
	shr	ebp,				0fh
	mov	ax,				word ptr [ebp + _bIntToHexStr]
	mov	word ptr [edx + 0ah],		ax
	mov	ebp,				dword ptr [_dStaticVarsId]
	and	ebp,				0000ff00h
	shr	ebp,				07h
	mov	ax,				word ptr [ebp + _bIntToHexStr]
	mov	word ptr [edx + 0ch],		ax
	mov	ebp,				dword ptr [_dStaticVarsId]
	and	ebp,				000000ffh
	shl	ebp,				01h
	mov	ax,				word ptr [ebp + _bIntToHexStr]
	mov	word ptr [edx + 0eh],		ax
	add	edx,				11h

	call	_lCheckInFuncVars

	_lGetStaticVariables_GetNext:
cmp	dword ptr [esi],		"acol"
jne	_lGetStaticVariables_GetNextEx
cmp	word ptr [esi + 04h],		" l"
jne	_lGetStaticVariables_GetNextEx
add	esi,				06h
_lGetStaticVariables_GetNextDx:
inc	esi
cmp	byte ptr [esi - 01h],		" "
jne	_lGetStaticVariables_GetNextDx
cmp	dword ptr [esi],		"arra"
jne	_lGetStaticVariables_GetNextSx
cmp	word ptr [esi + 04h],		" y"
jne	_lGetStaticVariables_GetNextSx
add	esi,				06h
_lGetStaticVariables_GetNextSx:
push	00h
push	esi
push	esi

call	_lCheckInFuncVars

	_lGetStaticVariables_GetNextEx:
	inc	esi
	cmp	word ptr [esi - 02h],		0a0dh
	jne	_lGetStaticVariables_GetNextEx
	jmp	_lGetStaticVariables

	_lGetStaticVariables_End:
	;;----------------

	;;----------------
	;; copy (with replacing) variables
	mov	esi,				offset _bFuncCodeLocals
	mov	dword ptr [_dLocalsOffset],	edi

	_lVarsCopy:
	cmp	esi,				dword ptr [_dFCL]
	jae	_lVarsCopy_End

	xor	ebx,				ebx	;; add endglobals instruction
	cmp	word ptr [esi],			"M#"
	jne	_lVarsCopy_00
	add	esi,				09h
	jmp	_lVarsCopy

	_lVarsCopy_00:
	cmp	dword ptr [esi + 06h],		"tats"
	jne	_lVarsCopy_Line	
	cmp	dword ptr [esi + 09h],		" cit"
	jne	_lVarsCopy_Line
	mov	dword ptr [edi],		"bolg"
	mov	dword ptr [edi + 03h],		"slab"
	mov	word ptr [edi + 07h],		0a0dh
	add	edi,				09h
	add	esi,				0dh
	inc	ebx

		;;----------------
		;; copy line
		_lVarsCopy_Line:
		xor	eax,				eax

		_lVarsCopy_Word:
		lea	ecx,				[esp - 0ch]
		_lVarsCopy_WordCheckStr:
		add	ecx,				0ch
		mov	edx,				esi
		mov	ebp,				dword ptr [ecx]
		test	ebp,				ebp
		jz	_lVarsCopy_NoReplace

			;;----------------
			;; check word
			_lVarsCopy_WordCheck:
			mov	al,				byte ptr [edx]
			cmp	byte ptr [_bAscii_00 + eax],	ah
			jne	_lVarsCopy_WordCheck_00

			mov	al,				byte ptr [ebp]
			cmp	byte ptr [_bAscii_00 + eax],	ah
			jne	_lVarsCopy_WordCheckStr

				;;----------------
				;; replace word
				mov	esi,				edx
				mov	ebp,				dword ptr [ecx + 04h]

				_lVarsCopy_WordReplace:
				mov	al,				byte ptr [ebp]
				cmp	byte ptr [_bAscii_00 + eax],	ah
				je	_lVarsCopy_NoReplace_00
				mov	byte ptr [edi],			al
				inc	ebp
				inc	edi
				jmp	_lVarsCopy_WordReplace
				;;----------------

			_lVarsCopy_WordCheck_00:
			cmp	al,				byte ptr [ebp]
			jne	_lVarsCopy_WordCheckStr
			inc	edx
			inc	ebp
			jmp	_lVarsCopy_WordCheck
			;;----------------

			;;----------------
			;; copy word
			_lVarsCopy_NoReplace:
			mov	al,				byte ptr [esi]

			cmp	al,				"."
			je	_lVarsCopy_NoReplaceEx

			_lVarsCopy_NoReplaceQX:
			cmp	byte ptr [_bAscii_00 + eax],	ah
			je	_lVarsCopy_NoReplace_00
			_lVarsCopy_NoReplaceEx:
			mov	byte ptr [edi],			al
			inc	esi
			inc	edi
			jmp	_lVarsCopy_NoReplace

			_lVarsCopy_NoReplace_00:
			cmp	word ptr [esi],			0a0dh
			je	_lVarsCopy_NoReplace_01
			movsb
			jmp	_lVarsCopy_Word

			_lVarsCopy_NoReplace_01:
			movsw
			test	ebx,				ebx
			jz	_lVarsCopy
			mov	dword ptr [edi],		"gdne"
			mov	dword ptr [edi + 04h],		"abol"
			mov	dword ptr [edi + 08h],		0a0d736ch
			add	edi,				0ch
			jmp	_lVarsCopy
			;;----------------
		;;----------------

	_lVarsCopy_End:
	;;----------------

	;;----------------
	;; copy (with replacing) code
	mov	dword ptr [_dInFuncBlockMax],		00h
	mov	dword ptr [_dInFuncBlockStack],		00h
	mov	dword ptr [_dInFuncBlockPnt],		offset _dInFuncBlockStack + 04h

	mov	byte ptr [_bFuncCodeNop],		00h

	mov	dword ptr [_dFreeForGroupPnt],		offset _dFreeForGroup - 04h

	mov	esi,				offset _bFuncCodeBase
	mov	dword ptr [_dCodeOffset],	edi

	_lCodeCopy_Line:
	cmp	esi,				dword ptr [_dFCB]
	jae	_lCodeCopy_End

	mov	byte ptr [_bALFReturnLast],	00h

	mov	eax,				dword ptr [esi]

	cmp	eax,				"sulf"
	jne	_lCodeCopy_00
	cmp	dword ptr [esi + 04h],		"ol h"
	jne	_lCodeCopy_00
	cmp	dword ptr [esi + 08h],		"slac"
	jne	_lCodeCopy_00
	cmp	word ptr [esi + 0ch],		0a0dh	;; nl
	jne	_lCodeCopy_00
	add	esi,				0eh

	mov	byte ptr [_bALFReturnExpr],	00h
	call	_lFlushLocals
	jmp	_lCodeCopy_Line

	_lCodeCopy_00:
	cmp	ax,				"fi"
	jne	_lCodeCopy_01
	xor	eax,				eax
	mov	al,				byte ptr [esi + 02h]
	cmp	byte ptr [_bAscii_00 + eax],	ah
	jne	_lCodeCopy_01
	call	_lInFuncBlockIn
	jmp	_lCopyCode_Word

	_lCodeCopy_01:
	cmp	eax,			"tats"
	jne	_lCodeCopy_02
	cmp	dword ptr [esi + 04h],	"i ci"
	jne	_lCodeCopy_02
	cmp	byte ptr [esi + 08h],	"f"
	jne	_lCodeCopy_02
	call	_lInFuncBlockIn
	jmp	_lCopyCode_Word

	_lCodeCopy_02:
	cmp	eax,			"esle"
	jne	_lCodeCopy_03
	call	_lInFuncBlockOut
	call	_lInFuncBlockOutVarsEx
	call	_lInFuncBlockIn
	jmp	_lCopyCode_Word

	_lCodeCopy_03:
	cmp	eax,			"idne"
	jne	_lCodeCopy_04
	cmp	byte ptr [esi + 04h],	"f"
	jne	_lCodeCopy_04
	call	_lInFuncBlockOut
	call	_lInFuncBlockOutVarsEx
	jmp	_lCopyCode_Word

	_lCodeCopy_04:
	cmp	eax,			"pool"
	jne	_lCodeCopy_05
	call	_lInFuncBlockIn
	jmp	_lCopyCode_Word

	_lCodeCopy_05:
	cmp	eax,			"ldne"
	jne	_lCodeCopy_06
	cmp	dword ptr [esi + 03h],	"pool"
	jne	_lCodeCopy_06
	call	_lInFuncBlockOut
	call	_lInFuncBlockOutVarsEx
	jmp	_lCopyCode_Word

	_lCodeCopy_06:
	cmp	ax,			"N#"
	jne	_lCodeCopy_07

		;;----------------
		;; add local to replace
		mov	eax,			dword ptr [_dInFuncBlockPnt]
		mov	eax,			dword ptr [eax - 04h]
		push	eax

		add	esi,			02h
		push	esi

		_lCodeCopy_06_Ex:
		inc	esi
		cmp	byte ptr [esi - 01h],	" "
		jne	_lCodeCopy_06_Ex

		push	esi

		_lCodeCopy_06_Dx:
		inc	esi
		cmp	word ptr [esi - 02h],	0a0dh
		jne	_lCodeCopy_06_Dx

		call	_lCheckInFuncVars

		jmp	_lCodeCopy_Line
		;;----------------

	_lCodeCopy_07:
	cmp	eax,			"uter"
	jne	_lCodeCopy_08
	cmp	word ptr [esi + 04h],	"nr"
	jne	_lCodeCopy_08

	cmp	byte ptr [_bLocalsAutoFlush],	00h
	je	_lCopyCode_Word
	mov	byte ptr [_bALFReturnExpr],	01h
	call	_lFlushLocals
	jmp	_lCopyCode_Word

	_lCodeCopy_08:
	cmp	eax,			"olbv"
	jne	_lCodeCopy_09
	cmp	word ptr [esi + 04h],	"kc"
	jne	_lCodeCopy_09
	cmp	byte ptr [esi + 06h],	20h
	jg	_lCodeCopy_09
	call	_lInFuncBlockIn
	add	esi,			08h
	jmp	_lCodeCopy_Line

	_lCodeCopy_09:
	cmp	eax,			"vdne"
	jne	_lCodeCopy_0a
	cmp	dword ptr [esi + 04h],	"colb"
	jne	_lCodeCopy_0a
	cmp	byte ptr [esi + 08h],	"k"
	jne	_lCodeCopy_0a
	cmp	byte ptr [esi + 09h],	20h
	jg	_lCodeCopy_0a
	call	_lInFuncBlockOut
	call	_lInFuncBlockOutVarsEx
	add	esi,			0bh
	jmp	_lCodeCopy_Line

	_lCodeCopy_0a:
	cmp	eax,			"rgjc"
	jne	_lCodeCopy_0b
	cmp	dword ptr [esi + 04h],	"_ngf"
	jne	_lCodeCopy_0b

	;;----------------
	;; generate group
	cmp	dword ptr [_dFreeForGroupPnt],	offset _dFreeForGroup - 04h
	je	_lCodeCopy_GenGroup

		;;----------------
		;; use free
		mov	eax,			dword ptr [_dInFuncBlockPnt]
		mov	eax,			dword ptr [eax - 04h]
		push	eax

		mov	edx,				dword ptr [_dFreeForGroupPnt]
		push	dword ptr [edx]
		sub	edx,				04h
		mov	dword ptr [_dFreeForGroupPnt],	edx

		push	esi

		_lCodeCopy_SkipLine:
		inc	esi
		cmp	word ptr [esi - 02h],		0a0dh
		jne	_lCodeCopy_SkipLine
		jmp	_lCodeCopy_Line
		;;----------------

		;;----------------
		;; generate new
		_lCodeCopy_GenGroup:
		mov	dword ptr [edi],		"bolg"
		mov	dword ptr [edi + 04h],		0d736c61h	;; als nl
		mov	dword ptr [edi + 08h],		6f72670ah	;; nl gro
		mov	dword ptr [edi + 0ch],		"  pu"

		add	edi,				0fh

		mov	eax,				dword ptr [_dInFuncBlockPnt]
		mov	eax,				dword ptr [eax - 04h]
		push	eax
		push	edi
		push	edi		

		_CodeCopy_GenGroupVar:
		movsb
		cmp	word ptr [esi],			0a0dh
		jne	_CodeCopy_GenGroupVar
		add	esi,				02h

		mov	dword ptr [edi],		"erC="
		mov	dword ptr [edi + 04h],		"Geta"
		mov	dword ptr [edi + 08h],		"puor"
		mov	dword ptr [edi + 0ch],		0a0d2928h	;; () nl
		mov	dword ptr [edi + 10h],		"gdne"
		mov	dword ptr [edi + 14h],		"abol"
		mov	dword ptr [edi + 18h],		0a0d736ch	;; ls nl

		add	edi,				1ch
		jmp	_lCodeCopy_Line
		;;----------------
	;;----------------

	_lCodeCopy_0b:
	_lCopyCode_Word:
	cmp	esi,				dword ptr [_dFCB]
	jae	_lCodeCopy_End
	cmp	word ptr [esi],			0a0dh
	jne	_lCopyCode_WordStart
	movsw
	jmp	_lCodeCopy_Line

	_lCopyCode_WordStart:
	xor	eax,				eax
	_lCopyCode_WordStartEx:
	mov	al,				byte ptr [esi]

	cmp	al,				"."
	je	_lCopyCode_WordCopyFx

	cmp	al,				22h
	je	_lCopyCode_String

	cmp	byte ptr [_bAscii_00 + eax],	ah
	jne	_lCopyCode_WordNew
	movsb
	jmp	_lCopyCode_Word

		;;----------------
		;; copy string
		_lCopyCode_String:
		movsb
		_lCopyCode_StringEX:
		cmp	byte ptr [esi],			5ch	;; \ 
		jne	_lCopyCode_StringDX
		movsw
		jmp	_lCopyCode_StringEX
		_lCopyCode_StringDX:
		cmp	byte ptr [esi],			22h
		jne	_lCopyCode_String

		movsb
		jmp	_lCopyCode_Word
		;;----------------

		;;----------------
		;; check next word
		_lCopyCode_WordNew:
		cmp	dword ptr [esi],		"v_jc"
		jne	_lCopyCode_WordNewEx
		cmp	dword ptr [esi + 04h],		"_666"
		jne	_lCopyCode_WordNewEx

			;;----------------
			movsd
			movsd
			inc	esi

			mov	eax,				offset _sBool
			cmp	byte ptr [esi - 01h],		"b"
			jne	_lCopyCode_NotBool
			call	_lGetGlobals_Start
			jmp	_lCopyCode_Word

			_lCopyCode_NotBool:
			mov	eax,				dword ptr [_sFuncType]
			call	_lGetGlobals_Start
			jmp	_lCopyCode_Word
			;;----------------

		_lCopyCode_WordNewEx:
		mov	ebx,				esi
		lea	ecx,				[esp - 0ch]

		_lCopyCode_WordNew_00:
		add	ecx,				0ch
		mov	esi,				ebx
		cmp	dword ptr [ecx],		00h
		je	_lCopyCode_WordCopy

		mov	edx,				dword ptr [ecx]

		_lCopyCode_WordNew_01:
		mov	al,				byte ptr [edx]
		cmp	byte ptr [_bAscii_00 + eax],	ah
		je	_lCopyCode_WordNew_02
		cmp	al,				byte ptr [esi]
		jne	_lCopyCode_WordNew_00
		inc	esi
		inc	edx
		jmp	_lCopyCode_WordNew_01

		_lCopyCode_WordNew_02:
		mov	al,				byte ptr [esi]
		cmp	byte ptr [_bAscii_00 + eax],	ah
		jne	_lCopyCode_WordNew_00

;		_lCopyCode_WordReplace:
		mov	ebx,				dword ptr [ecx + 04h]
		_lCopyCode_WordReplace_00:
		mov	al,				byte ptr [ebx]
		cmp	byte ptr [_bAscii_00 + eax],	ah
		je	_lCopyCode_Word
		stosb
		inc	ebx
		jmp	_lCopyCode_WordReplace_00

		_lCopyCode_WordCopy:
		mov	al,				byte ptr [esi]
		cmp	byte ptr [_bAscii_00 + eax],	ah
		je	_lCopyCode_Word
_lCopyCode_WordCopyFx:
		stosb
		inc	esi
		jmp	_lCopyCode_WordCopy
		;;----------------

	_lCodeCopy_End:
	cmp	byte ptr [_bLocalsAutoFlush],	00h
	je	_lCodeCopy_EndEx
	cmp	byte ptr [_bALFReturnLast],	01h
	je	_lCodeCopy_EndEx
	mov	byte ptr [_bALFReturnExpr],	00h
	call	_lFlushLocals

	_lCodeCopy_EndEx:
	mov	byte ptr [_bALFReturnLast],	00h
	;;----------------

	;;----------------
	;; clean stack
	_lCodeCopy_CleanStack_Start:
	cmp	dword ptr [esp],		00h
	jne	_lCodeCopy_CleanStack_Clean
	cmp	dword ptr [esp + 04h],		00h
	jne	_lCodeCopy_CleanStack_Clean
	cmp	dword ptr [esp + 08h],		00h
	je	_lCodeCopy_CleanStack_End

	_lCodeCopy_CleanStack_Clean:
	add	esp,				0ch
	jmp	_lCodeCopy_CleanStack_Start

	_lCodeCopy_CleanStack_End:
	;;----------------

	;;----------------
	;; remove "set var = null_cjnullex"
	mov	ecx,				dword ptr [_dCodeOffset]

	_lCodeCopy_RemoveFxNulling_Line:
	cmp	byte ptr [ecx],			00h
	je	_lCodeCopy_RemoveFxNulling_End

	cmp	dword ptr [ecx],		" tes"
	jne	_lCodeCopy_RemoveFxNulling_GetNextLine
	mov	edx,				ecx

	_lCodeCopy_RemoveFxNulling_GetValue:
	inc	edx
	cmp	byte ptr [edx - 01h],		"="
	jne	_lCodeCopy_RemoveFxNulling_GetValue

	cmp	dword ptr [edx],		"llun"
	jne	_lCodeCopy_RemoveFxNulling_GetNextLine
	cmp	dword ptr [edx + 04h],		"njc_"
	jne	_lCodeCopy_RemoveFxNulling_GetNextLine
	cmp	dword ptr [edx + 08h],		"ellu"
	jne	_lCodeCopy_RemoveFxNulling_GetNextLine
	cmp	byte ptr [edx + 0ch],		"x"
	jne	_lCodeCopy_RemoveFxNulling_GetNextLine
	cmp	word ptr [edx + 0dh],		0a0dh
	jne	_lCodeCopy_RemoveFxNulling_GetNextLine

	dec	ecx
	mov	word ptr [ecx - 01h],		"  "

	_lCodeCopy_RemoveFxNulling_RemoveLine:
	inc	ecx
	cmp	word ptr [ecx],			0a0dh
	je	_lCodeCopy_RemoveFxNulling_Line
	mov	byte ptr [ecx],			" "
	jmp	_lCodeCopy_RemoveFxNulling_RemoveLine

	_lCodeCopy_RemoveFxNulling_GetNextLine:
	inc	ecx
	cmp	word ptr [ecx - 02h],		0a0dh
	jne	_lCodeCopy_RemoveFxNulling_GetNextLine
	jmp	_lCodeCopy_RemoveFxNulling_Line

	_lCodeCopy_RemoveFxNulling_End:
	;;----------------

add	esp,			0ch
pop	esi	;; restore esi
pop	ebx
;;----------------

			xor	ebx,			01b
;;			mov	esi,			eax
			cmp	word ptr [esi+0bh],			4501h	;; #E
			jne	_lFNPCopy

				;;----------------
				;; anonym endfunction
				mov	dword ptr [edi],			"fdne"
				mov	dword ptr [edi+04h],			"tcnu"
				mov	dword ptr [edi+08h],			0d6e6f69h	;; nl noi
				mov	byte ptr [edi+0ch],			0ah		;; nl

				lea	edx,					[edi+0dh]	;; correct edi and store it in edx

				mov	eax,					dword ptr [_dAnonFuncCnt]

				mov	ecx,					edi
				mov	edi,					dword ptr [eax+08h]
				mov	dword ptr [eax+08h],			ecx

				mov	al,					06h

				_lFNPAnonEndf:
				inc	edi
				cmp	byte ptr [edi],				20h	;; bs
				jne	_lFNPAnonEndf

				lea	ecx,					[esi+0dh]
				sub	ecx,					edi

				rep	stosb

				mov	edi,					edx		;; restore edi
				jmp	_lFNPAnonStr
				;;----------------

				;;----------------
				;; check redeclared static variables
				_lCheckInFuncVars:
				push	ebx
				push	ecx
				push	edx

				lea	ecx,			[esp + 10h]
				xor	eax,			eax

				_lCheckInFuncVars_Next:
				add	ecx,			0ch
				cmp	dword ptr [ecx],	00h
				je	_lCheckInFuncVars_End

				mov	ebx,				dword ptr [ecx]
				mov	edx,				dword ptr [esp + 10h]

				_lCheckInFuncVars_Check:
				mov	al,				byte ptr [ebx]
				cmp	byte ptr [_bAscii_00 + eax],	ah
				je	_lCheckInFuncVars_Check_00
				cmp	al,				byte ptr [edx]
				jne	_lCheckInFuncVars_Next
				inc	ebx
				inc	edx
				jmp	_lCheckInFuncVars_Check

				_lCheckInFuncVars_Check_00:
				mov	al,				byte ptr [edx]
				cmp	byte ptr [_bAscii_00 + eax],	ah
				jne	_lCheckInFuncVars_Next

					;;----------------
					;; error
					mov	dword ptr [_xErrorTable],	offset _sErr_RedeclaredVar
					mov	dword ptr [_xErrorTable + 04h],	edi

					_lCheckInFuncVars_Err:
					movsb
					cmp	word ptr [esi],			0a0dh
					jne	_lCheckInFuncVars_Err

					mov	dword ptr [_xErrorTable + 08h],	edi
					jmp	_lErrIn
					;;----------------

				_lCheckInFuncVars_End:
				pop	edx
				pop	ecx
				pop	ebx

				retn
				;;----------------

				;;----------------
				;; get global var
				_lGetGlobals_Start:
				push	eax
				xor	eax,				eax
				mov	ecx,				offset _sCJGenGlobalsTypes

				_lGetGlobals_Type:
				cmp	byte ptr [ecx],			00h
				je	_lGetGlobals_NewType
				mov	edx,				dword ptr [esp]

				_lGetGlobals_Check:
				mov	al,				byte ptr [edx]
				cmp	byte ptr [_bAscii_00 + eax],	ah
				je	_lGetGlobals_Check_00
				cmp	al,				byte ptr [ecx]
				jne	_lGetGlobals_GetNext
				inc	edx
				inc	ecx
				jmp	_lGetGlobals_Check

				_lGetGlobals_Check_00:
				mov	al,				byte ptr [ecx]
				cmp	byte ptr [_bAscii_00 + eax],	ah
				jne	_lGetGlobals_GetNext

					;;----------------
					pop	edx

					_lGetGlobals_CopyType_00:
					mov	al,				byte ptr [edx]
					cmp	byte ptr [_bAscii_00 + eax],	ah
					je	_lGetGlobals_End

					stosb
					inc	edx
					jmp	_lGetGlobals_CopyType_00
					;;----------------

				_lGetGlobals_GetNextEx:
				inc	ecx
				_lGetGlobals_GetNext:
				mov	al,				byte ptr [ecx]
				cmp	byte ptr [_bAscii_00 + eax],	ah
				jne	_lGetGlobals_GetNextEx
				inc	ecx
				jmp	_lGetGlobals_Type

					;;----------------
					_lGetGlobals_NewType:
					pop	edx
					cmp	byte ptr [ecx - 01h],		00h
					je	_lGetGlobals_CopyType_01

					mov	byte ptr [ecx],			" "
					inc	ecx

					_lGetGlobals_CopyType_01:
					mov	al,				byte ptr [edx]
					cmp	byte ptr [_bAscii_00 + eax],	ah
					je	_lGetGlobals_End

					stosb
					inc	edx
					mov	byte ptr [ecx],			al
					inc	ecx

					jmp	_lGetGlobals_CopyType_01
					;;----------------

				_lGetGlobals_End:
				retn
				;;----------------

				;;----------------
				;; flush locals pre
				_lFlushLocals:

					;;----------------
					;; scan locals
					push	00h
					push	00h

					mov	dword ptr [_dFlushLocalsStackPos],	esp

					mov	ecx,			dword ptr [_dLocalsOffset]

					_lFlLoc_00:
					cmp	ecx,				dword ptr [_dCodeOffset]
					jae	_lFlLoc_LSE

					cmp	dword ptr [ecx],	"acol"
					jne	_lFlLoc_Skip
					cmp	word ptr [ecx + 04h],	" l"
					jne	_lFlLoc_Skip
					add	ecx,			06h

						;;----------------
						;; check types
						;; correct types
						mov	eax,			dword ptr [ecx]
						cmp	eax,			"neve"
						jne	_lFlLoc_T_00
						cmp	word ptr [ecx+04h],	" t"
						jne	_lFlLoc_T_00
						add	ecx,			06h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_00:
						cmp	eax,			"gdiw"
						jne	_lFlLoc_T_01
						cmp	word ptr [ecx+04h],	"te"
						jne	_lFlLoc_T_01
						cmp	byte ptr [ecx+06h],	" "
						jne	_lFlLoc_T_01
						add	ecx,			07h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_01:
						cmp	eax,			"tinu"
						jne	_lFlLoc_T_02
						cmp	byte ptr [ecx+04h],	" "
						jne	_lFlLoc_T_02
						add	ecx,			05h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_02:
						cmp	eax,			"tsed"
						jne	_lFlLoc_T_03
						cmp	dword ptr [ecx+04h],	"tcur"
						jne	_lFlLoc_T_03
						cmp	dword ptr [ecx+08h],	"elba"
						jne	_lFlLoc_T_03
						cmp	byte ptr [ecx+0ch],	" "
						jne	_lFlLoc_T_03
						add	ecx,			0dh
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_03:
						cmp	eax,			"meti"
						jne	_lFlLoc_T_04
						cmp	byte ptr [ecx+04h],	" "
						jne	_lFlLoc_T_04
						add	ecx,			05h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_04:
						cmp	eax,			"crof"
						jne	_lFlLoc_T_05
						cmp	word ptr [ecx+04h],	" e"
						jne	_lFlLoc_T_05
						add	ecx,			06h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_05:
						cmp	eax,			"uorg"
						jne	_lFlLoc_T_06
						cmp	word ptr [ecx],		" p"
						jne	_lFlLoc_T_06
						add	ecx,			06h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_06:
						cmp	eax,			"girt"
						jne	_lFlLoc_T_07
						cmp	dword ptr [ecx+04h],	" reg"
						jne	_lFlLoc_T_07
						add	ecx,			08h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_07:
						cmp	eax,			"girt"
						jne	_lFlLoc_T_08
						cmp	dword ptr [ecx+04h],	"creg"
						jne	_lFlLoc_T_08
						cmp	dword ptr [ecx+08h],	"idno"
						jne	_lFlLoc_T_08
						cmp	dword ptr [ecx+0ch],	"noit"
						jne	_lFlLoc_T_08
						cmp	byte ptr [ecx+10h],	" "
						jne	_lFlLoc_T_08
						add	ecx,			11h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_08:
						cmp	eax,			"girt"
						jne	_lFlLoc_T_09
						cmp	dword ptr [ecx+04h],	"areg"
						jne	_lFlLoc_T_09
						cmp	dword ptr [ecx+08h],	"oitc"
						jne	_lFlLoc_T_09
						cmp	word ptr [ecx+0ch],	" n"
						jne	_lFlLoc_T_09
						add	ecx,			0eh
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_09:
						cmp	eax,			"emit"
						jne	_lFlLoc_T_0a
						cmp	word ptr [ecx+04h],	" r"
						jne	_lFlLoc_T_0a
						add	ecx,			06h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_0a:
						cmp	eax,			"acol"
						jne	_lFlLoc_T_0b
						cmp	dword ptr [ecx+04h],	"noit"
						jne	_lFlLoc_T_0b
						cmp	byte ptr [ecx+08h],	" "
						jne	_lFlLoc_T_0b
						add	ecx,			09h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_0b:
						cmp	eax,			"iger"
						jne	_lFlLoc_T_0c
						cmp	word ptr [ecx+04h],	"no"
						jne	_lFlLoc_T_0c
						cmp	byte ptr [ecx+06h],	" "
						jne	_lFlLoc_T_0c
						add	ecx,			07h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_0c:
						cmp	eax,			"tcer"
						jne	_lFlLoc_T_0d
						cmp	byte ptr [ecx+04h],	" "
						jne	_lFlLoc_T_0d
						add	ecx,			05h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_0d:
						cmp	eax,			"nuos"
						jne	_lFlLoc_T_0e
						cmp	word ptr [ecx+04h],	" d"
						jne	_lFlLoc_T_0e
						add	ecx,			06h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_0e:
				;		cmp	eax,			"emac"
				;		jne	_lFlLoc_T_0f
				;		cmp	dword ptr [ecx+04h],	"esar"
				;		jne	_lFlLoc_T_0f
				;		cmp	dword ptr [ecx+08h],	" put"
				;		jne	_lFlLoc_T_0f
				;		add	ecx,			0ch
				;		jmp	_lFlLoc_T_Add

						_lFlLoc_T_0f:
						cmp	eax,			"effe"
						jne	_lFlLoc_T_10
						cmp	word ptr [ecx+04h],	"tc"
						jne	_lFlLoc_T_10
						cmp	byte ptr [ecx+06h],	" "
						jne	_lFlLoc_T_10
						add	ecx,			07h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_10:
						cmp	eax,			"taew"
						jne	_lFlLoc_T_11
						cmp	dword ptr [ecx+04h],	"ereh"
						jne	_lFlLoc_T_11
						cmp	dword ptr [ecx+08h],	"ceff"
						jne	_lFlLoc_T_11
						cmp	word ptr [ecx+0ch],	" t"
						add	ecx,			0eh
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_11:
						cmp	eax,			"laid"
						jne	_lFlLoc_T_12
						cmp	word ptr [ecx+04h],	"go"
						jne	_lFlLoc_T_12
						cmp	byte ptr [ecx+06h],	" "
						jne	_lFlLoc_T_12
						add	ecx,			07h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_12:
						cmp	eax,			"ttub"
						jne	_lFlLoc_T_13
						cmp	dword ptr [ecx+03h],	" not"
						jne	_lFlLoc_T_13
						add	ecx,			07h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_13:
						cmp	eax,			"seuq"
						jne	_lFlLoc_T_14
						cmp	word ptr [ecx+04h],	" t"
						jne	_lFlLoc_T_14
						add	ecx,			06h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_14:
						cmp	eax,			"seuq"
						jne	_lFlLoc_T_15
						cmp	dword ptr [ecx+04h],	"etit"
						jne	_lFlLoc_T_15
						cmp	word ptr [ecx+08h],	" m"
						jne	_lFlLoc_T_15
						add	ecx,			0ah
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_15:
						cmp	eax,			"emit"
						jne	_lFlLoc_T_16
						cmp	dword ptr [ecx+04h],	"aidr"
						jne	_lFlLoc_T_16
						cmp	dword ptr [ecx+08h],	" gol"
						jne	_lFlLoc_T_16
						add	ecx,			0ch
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_16:
						cmp	eax,			"dael"
						jne	_lFlLoc_T_17
						cmp	dword ptr [ecx+04h],	"obre"
						jne	_lFlLoc_T_17
						cmp	dword ptr [ecx+08h],	" dra"
						jne	_lFlLoc_T_17
						add	ecx,			0ch
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_17:
						cmp	eax,			"tlum"
						jne	_lFlLoc_T_18
						cmp	dword ptr [ecx+04h],	"aobi"
						jne	_lFlLoc_T_18
						cmp	dword ptr [ecx+07h],	" dra"
						jne	_lFlLoc_T_18
						add	ecx,			0bh
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_18:
						cmp	eax,			"tlum"
						jne	_lFlLoc_T_19
						cmp	dword ptr [ecx+04h],	"aobi"
						jne	_lFlLoc_T_19
						cmp	dword ptr [ecx+08h],	"tidr"
						jne	_lFlLoc_T_19
						cmp	dword ptr [ecx+0bh],	" met"
						jne	_lFlLoc_T_19
						add	ecx,			0fh
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_19:
						cmp	eax,			"emag"
						jne	_lFlLoc_T_1a
						cmp	dword ptr [ecx+04h],	"hcac"
						jne	_lFlLoc_T_1a
						cmp	word ptr [ecx+08h],	" e"
						jne	_lFlLoc_T_1a
						add	ecx,			0ah
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_1a:
				;		cmp	eax,			"hgil"
				;		jne	_lFlLoc_T_1b
				;		cmp	dword ptr [ecx+04h],	"niht"
				;		jne	_lFlLoc_T_1b
				;		cmp	word ptr [ecx+08h],	" g"
				;		jne	_lFlLoc_T_1b
				;		add	ecx,			0ah
				;		jmp	_lFlLoc_T_Add

						_lFlLoc_T_1b:
				;		cmp	eax,			"gami"
				;		jne	_lFlLoc_T_1c
				;		cmp	dword ptr [ecx+04h],	" e"
				;		jne	_lFlLoc_T_1c
				;		add	ecx,			06h
				;		jmp	_lFlLoc_T_Add

						_lFlLoc_T_1c:
				;		cmp	eax,			"rebu"
				;		jne	_lFlLoc_T_1d
				;		cmp	dword ptr [ecx+04h],	"alps"
				;		jne	_lFlLoc_T_1d
				;		cmp	word ptr [ecx+08h],	" t"
				;		jne	_lFlLoc_T_1d
				;		add	ecx,			0ah
				;		jmp	_lFlLoc_T_Add

						_lFlLoc_T_1d:
						cmp	eax,			"dnah"
						jne	_lFlLoc_T_1e
						cmp	dword ptr [ecx+03h],	" eld"
						jne	_lFlLoc_T_1e
						add	ecx,			07h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_1e:
						cmp	eax,			"hsah"
						jne	_lFlLoc_T_1f
						cmp	dword ptr [ecx+04h],	"lbat"
						jne	_lFlLoc_T_1f
						cmp	word ptr [ecx+08h],	" e"
						jne	_lFlLoc_T_1f
						add	ecx,			0ah
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_1f:
						cmp	eax,			"nega"
						jne	_lFlLoc_T_20
						cmp	word ptr [ecx+04h],	" t"
						jne	_lFlLoc_T_20
						add	ecx,			06h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_20:
						cmp	eax,			"tinu"
						jne	_lFlLoc_T_21
						cmp	dword ptr [ecx+04h],	"loop"
						jne	_lFlLoc_T_21
						cmp	byte ptr [ecx+08h],	" "
						jne	_lFlLoc_T_21
						add	ecx,			09h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_21:
						cmp	eax,			"meti"
						jne	_lFlLoc_T_22
						cmp	dword ptr [ecx+04h],	"loop"
						jne	_lFlLoc_T_22
						cmp	byte ptr [ecx+08h],	" "
						jne	_lFlLoc_T_22
						add	ecx,			09h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_22:
						cmp	eax,			"mgof"
						jne	_lFlLoc_T_23
						cmp	dword ptr [ecx+04h],	"fido"
						jne	_lFlLoc_T_23
						cmp	dword ptr [ecx+08h],	" rei"
						jne	_lFlLoc_T_23
						add	ecx,			0ch
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_23:
						cmp	eax,			"efed"
						jne	_lFlLoc_T_24
						cmp	dword ptr [ecx+04h],	"octa"
						jne	_lFlLoc_T_24
						cmp	dword ptr [ecx+08h],	"tind"
						jne	_lFlLoc_T_24
						cmp	dword ptr [ecx+0ch],	" noi"
						jne	_lFlLoc_T_24
						add	ecx,			10h
						jmp	_lFlLoc_T_Add

						_lFlLoc_T_24:
						_lFlLoc_GetNext:
						inc	ecx
						cmp	word ptr [ecx-02h],	0a0dh	;; nl
						jne	_lFlLoc_GetNext
						jmp	_lFlLoc_00

						_lFlLoc_T_Add:
						cmp	dword ptr [ecx],	"arra"
						jne	_lFlLoc_T_AddEX
						cmp	word ptr [ecx+04h],	" y"
						je	_lFlLoc_GetNext
						_lFlLoc_T_AddEX:
						push	ecx

						_lFlLoc_T_IsInit:
						inc	ecx
						cmp	byte ptr [ecx],		"="
						je	_lFlLoc_T_Init
						cmp	word ptr [ecx],		0a0dh
						jne	_lFlLoc_T_IsInit
						add	ecx,			02h
						push	00h			;; var is null
						jmp	_lFlLoc_00

						_lFlLoc_T_Init:
						cmp	dword ptr [ecx+01h],	"llun"
						jne	_lFlLoc_T_InitEX
						cmp	word ptr [ecx+05h],	0a0dh	;; nl
						jne	_lFlLoc_T_InitEX
						push	00h			;; var is null
						jmp	_lFlLoc_GetNext

						_lFlLoc_T_InitEX:
						push	01h			;; var is't null
						jmp	_lFlLoc_GetNext
						;;----------------

						;;----------------
						_lFlLoc_Skip:
						inc	ecx
						cmp	word ptr [ecx - 02h],	0a0dh
						jne	_lFlLoc_Skip
						jmp	_lFlLoc_00
						;;----------------

					_lFlLoc_LSE:
					;;----------------

					;;----------------
					;; scan code

					;; 0 variables
					cmp	dword ptr [esp + 04h],		00h
					je	_lFlushLocals_EndEx

					mov	dword ptr [_dFlushLocalsExBlock],	01h

					mov	ecx,				dword ptr [_dCodeOffset]
				;	xor	edx,				edx	;; block counter

					_lFlLoc_SC_Start:
					mov	eax,				dword ptr [ecx]

					cmp	al,			00h
					je	_lFlLoc_SC_End

					cmp	ax,			"fi"
					je	_lFlLoc_SC_If

					cmp	eax,			"esle"
					je	_lFlLoc_SC_Else

					cmp	eax,			"idne"
					je	_lFlLoc_SC_Endif

					cmp	eax,			"pool"
					je	_lFlLoc_SC_Loop

					cmp	eax,			"ldne"
					je	_lFlLoc_SC_Endloop

					cmp	eax,			"uter"
					je	_lFlLoc_SC_Return

					cmp	eax,			" tes"
					jne	_lFlLoc_SC_GetNextLine
					
						;;----------------
						;; set
						add	ecx,			04h
						mov	ebp,			esp
						xor	eax,			eax

						_lFlLoc_SC_GetVal_00:
						mov	ebx,			dword ptr [ebp + 04h]
						test	ebx,			ebx
						jz	_lFlLoc_SC_GetNextLine

							;;----------------
							;; check
							push	ecx
							_lFlLoc_SC_CheckVal_00:
							mov	al,				byte ptr [ecx]
							cmp	byte ptr [_bAscii_00 + eax],	ah
							jz	_lFlLoc_SC_CheckVal_01

							cmp	byte ptr [ebx],			al
							jne	_lFlLoc_SC_GetVal_Next
							inc	ecx
							inc	ebx
							jmp	_lFlLoc_SC_CheckVal_00

							_lFlLoc_SC_CheckVal_01:
							mov	al,				byte ptr [ebx]
							cmp	byte ptr [_bAscii_00 + eax],	ah
							jz	_lFlLoc_SC_GetVal_Found
							;;----------------

						_lFlLoc_SC_GetVal_Next:
						pop	ecx
						add	ebp,			08h
						jmp	_lFlLoc_SC_GetVal_00

							;;----------------
							;; found
							_lFlLoc_SC_GetVal_Found:
							add	esp,			04h
							cmp	dword ptr [ecx + 01h],	"llun"
							jne	_lFlLoc_SC_NotNullEx
							cmp	word ptr [ecx + 05h],	0a0dh
							jne	_lFlLoc_SC_NotNullEx
				;			test	edx,			edx
				;			jnz	_lFlLoc_SC_GetNextLine
							mov	dword ptr [ebp],	00h
							jmp	_lFlLoc_SC_GetNextLine

							_lFlLoc_SC_NotNullEx:
							cmp	dword ptr [ecx + 01h],	"llun"
							jne	_lFlLoc_SC_NotNull
							cmp	dword ptr [ecx + 05h],	"njc_"
							jne	_lFlLoc_SC_NotNull
							cmp	dword ptr [ecx + 09h],	"ellu"
							jne	_lFlLoc_SC_NotNull
							cmp	byte ptr [ecx + 0dh],	"x"
							jne	_lFlLoc_SC_NotNull
							cmp	word ptr [ecx + 0eh],	0a0dh
							jne	_lFlLoc_SC_NotNull
				;			test	edx,			edx
				;			jnz	_lFlLoc_SC_GetNextLine
							mov	dword ptr [ebp],	00h
							jmp	_lFlLoc_SC_GetNextLine

							_lFlLoc_SC_NotNull:
							mov	dword ptr [ebp],	01h
							jmp	_lFlLoc_SC_GetNextLine
							;;----------------
						;;----------------

						;;----------------
						;; if
						_lFlLoc_SC_If:
						cmp	byte ptr [ecx+02h],	28h
						ja	_lFlLoc_SC_GetNextLine
				;		inc	edx
						push	00h
						push	dword ptr [_dFlushLocalsExBlock]
						mov	dword ptr [_dFlushLocalsExBlock],	01h
						jmp	_lFlLoc_SC_BlockIn
				;		jmp	_lFlLoc_SC_GetNextLine
						;;----------------

						;;----------------
						;; else and elseif
						_lFlLoc_SC_Else:
						cmp	word ptr [ecx + 04h],	0a0dh
						je	_lFlLoc_SC_ElseEx
						cmp	word ptr [ecx + 04h],	"fi"
						jne	_lFlLoc_SC_GetNextLine
						cmp	byte ptr [ecx + 06h],	28h
						ja	_lFlLoc_SC_GetNextLine

						_lFlLoc_SC_ElseEx:
						call	_lFlLoc_SC_BlockOut
						push	00h
						push	dword ptr [_dFlushLocalsExBlock]
						mov	dword ptr [_dFlushLocalsExBlock],	01h
						jmp	_lFlLoc_SC_BlockIn
				;		jmp	_lFlLoc_SC_GetNextLine
						;;----------------

						;;----------------
						;; endif
						_lFlLoc_SC_Endif:
						cmp	word ptr [ecx + 03h],	"fi"
						jne	_lFlLoc_SC_GetNextLine
						cmp	byte ptr [ecx + 05h],	28h
						ja	_lFlLoc_SC_GetNextLine
				;		dec	edx
						call	_lFlLoc_SC_BlockOut
						jmp	_lFlLoc_SC_GetNextLine
						;;----------------

						;;----------------
						;; loop
						_lFlLoc_SC_Loop:
						cmp	byte ptr [ecx + 04h],	28h
						ja	_lFlLoc_SC_GetNextLine
				;		inc	edx
						push	00h
						push	dword ptr [_dFlushLocalsExBlock]
						mov	dword ptr [_dFlushLocalsExBlock],	02h
						jmp	_lFlLoc_SC_BlockIn
				;		jmp	_lFlLoc_SC_GetNextLine
						;;----------------

						;;----------------
						;; endloop
						_lFlLoc_SC_Endloop:
						cmp	dword ptr [ecx + 03h],	"pool"
						jne	_lFlLoc_SC_GetNextLine
						cmp	byte ptr [ecx + 07h],	28h
						ja	_lFlLoc_SC_GetNextLine
				;		dec	edx
						call	_lFlLoc_SC_BlockOut
						jmp	_lFlLoc_SC_GetNextLine
						;;----------------

						;;----------------
						;; return
						_lFlLoc_SC_Return:
						cmp	word ptr [ecx + 04h],	"nr"
						jne	_lFlLoc_SC_GetNextLine
						cmp	byte ptr [ecx + 06h],	28h
						ja	_lFlLoc_SC_GetNextLine

							;;----------------
							cmp	dword ptr [_dFlushLocalsExBlock],	02h
							je	_lFlLoc_SC_GetNextLine

							mov	edx,				esp

							_lFlLoc_SC_ReturnFix:
							mov	dword ptr [edx],		00h
							add	edx,				08h
							cmp	dword ptr [edx + 04h],		00h
							jne	_lFlLoc_SC_ReturnFix
							;;----------------

						jmp	_lFlLoc_SC_GetNextLine
						;;----------------

						;;----------------
						;; get next line
						_lFlLoc_SC_GetNextLine:
						inc	ecx
						cmp	word ptr [ecx - 02h],	0a0dh	;; nl
						jne	_lFlLoc_SC_GetNextLine
						jmp	_lFlLoc_SC_Start
						;;----------------

				;;----------------
				;; block in
				_lFlLoc_SC_BlockIn:
				mov	edx,			dword ptr [_dFlushLocalsStackPos]

				_lFlLoc_SC_BlockIn_Start:
				mov	eax,			dword ptr [edx - 04h]
				test	eax,			eax
				je	_lFlLoc_SC_GetNextLine

				push	eax
				mov	eax,			dword ptr [edx - 08h]
				push	eax

				sub	edx,			08h
				jmp	_lFlLoc_SC_BlockIn_Start
				;;----------------

				;;----------------
				;; block out
				_lFlLoc_SC_BlockOut:
				pop	ebp			;; ret addr

				mov	edx,			esp
				_lFlLoc_SC_BlockOut_Get:
				add	edx,			08h
				cmp	dword ptr [edx + 04h],	00h
				jne	_lFlLoc_SC_BlockOut_Get
				add	edx,			08h

				_lFlLoc_SC_BlockOut_Start:
				pop	eax
				add	esp,			04h
				or	dword ptr [edx],	eax		
				add	edx,			08h
				cmp	dword ptr [esp + 04h],	00h
				jne	_lFlLoc_SC_BlockOut_Start

				pop	dword ptr [_dFlushLocalsExBlock]
				add	esp,			04h

				jmp	ebp
				;;----------------

					_lFlLoc_SC_End:
					;;----------------

					;;----------------
					;; process return expression
					cmp	byte ptr [_bALFReturnExpr],	00h
					je	_lFLRetExpr_End

					lea	ecx,			[esi + 05h]
					xor	eax,			eax

					_lFLRetExpr_Start:
					inc	ecx
					_lFLRetExpr_StartEx:
					cmp	word ptr [ecx],		0a0dh
					je	_lFLRetExpr_End

					mov	al,				byte ptr [ecx]
					cmp	byte ptr [_bAscii_00 + eax],	ah
					je	_lFLRetExpr_Start

						;;----------------
						;; check word
						lea	ebp,				[esp - 08h]

						_lFLRetExpr_Check:
						add	ebp,				08h
						mov	edx,				ecx
						mov	ebx,				dword ptr [ebp + 04h]
						test	ebx,				ebx
						jz	_lFLRetExpr_NextWord

						_lFLRetExpr_Check_00:
						mov	al,				byte ptr [edx]
						cmp	byte ptr [_bAscii_00 + eax],	ah
						je	_lFLRetExpr_Check_01
						cmp	al,				byte ptr [ebx]
						jne	_lFLRetExpr_Check
						inc	ebx
						inc	edx
						jmp	_lFLRetExpr_Check_00

						_lFLRetExpr_Check_01:
						mov	al,				byte ptr [ebx]
						cmp	byte ptr [_bAscii_00 + eax],	ah
						jne	_lFLRetExpr_Check

				cmp	dword ptr [ebp],			00h
				je	_lFLRetExpr_NextWord

							;;----------------
							;; use generated globals
							mov	eax,				dword ptr [_sFuncType]

							mov	dword ptr [edi],		" tes"
							mov	dword ptr [edi + 04h],		"v_jc"
							mov	dword ptr [edi + 08h],		"_666"
							add	edi,				0ch

							call	_lGetGlobals_Start

							mov	byte ptr [edi],			"="
							inc	edi

							add	esi,				06h
							_lFLRetExpr_CopyExpr:
							movsb
							cmp	word ptr [edi - 02h],		0a0dh
							jne	_lFLRetExpr_CopyExpr

							mov	byte ptr [_bALFReturnExprUse],	01h
							jmp	_lFLRetExpr_End
							;;----------------

						_lFLRetExpr_NextWord:
						inc	ecx
						mov	al,				byte ptr [ecx]
						cmp	byte ptr [_bAscii_00 + eax],	ah
						jne	_lFLRetExpr_NextWord
						jmp	_lFLRetExpr_StartEx
						;;----------------

					_lFLRetExpr_End:
					;;----------------

					;;----------------
					;; final
					mov	byte ptr [_bFlushFlagBlock],	01h

					_lFlLoc_FinalNext:
					pop	eax	;; is null
					pop	ebx	;; val name

					test	ebx,			ebx
					jz	_lFlLoc_FinalEnd

					cmp	byte ptr [_bFlushFlagBlock],	00h
					je	_lFlLoc_FinalNext

					test	eax,			eax
					jz	_lFlLoc_FinalNext

						;;----------------
						mov	dword ptr [edi],		" tes"
						add	edi,				04h

						_lFlLoc_Final_00:
						mov	al,				byte ptr [ebx]
						cmp	byte ptr [_bAscii_00+eax],	ah
						jz	_lFlLoc_Final_01
						mov	byte ptr [edi],			al
						inc	ebx
						inc	edi
						jmp	_lFlLoc_Final_00

						_lFlLoc_Final_01:
						mov	dword ptr [edi],		"lun="
						mov	dword ptr [edi+04h],		000a0d6ch	;; l nl _
						add	edi,				07h
						jmp	_lFlLoc_FinalNext
						;;----------------

					_lFlLoc_FinalEnd:
					mov	byte ptr [_bFlushFlagBlock],	00h
					test	eax,			eax
					jnz	_lFlLoc_FinalNext
					;;----------------

					;;----------------
					;; return expr ex
					cmp	byte ptr [_bALFReturnExprUse],	00h
					je	_lFlLoc_RetnExprEx_End

					mov	byte ptr [_bALFReturnLast],	01h

					mov	dword ptr [edi],		"uter"
					mov	dword ptr [edi + 04h],		"c nr"
					mov	dword ptr [edi + 08h],		"6v_j"
					mov	dword ptr [edi + 0ch],		"__66"

					add	edi,				0fh

					mov	ecx,				dword ptr [_sFuncType]
					xor	eax,				eax

					_lFlLoc_RetnExprEx_CopyType:
					mov	al,				byte ptr [ecx]
					cmp	byte ptr [_bAscii_00 + eax],	ah
					je	_lFlLoc_RetnExprEx_CopyTypeEnd
					stosb
					inc	ecx
					jmp	_lFlLoc_RetnExprEx_CopyType

					_lFlLoc_RetnExprEx_CopyTypeEnd:
					mov	word ptr [edi],			0a0dh
					add	edi,				02h

				;	_lFlLoc_RetnExprEx_Correct:
				;	inc	esi
				;	cmp	word ptr [esi - 02h],		0a0dh
				;	jmp	_lFlLoc_RetnExprEx_Correct

					_lFlLoc_RetnExprEx_End:
					;;----------------

				_lFlushLocals_End:
				retn

				_lFlushLocals_EndEx:
				add	esp,				08h
				retn
				;;----------------

			;;----------------

		_lbl:
		cmp	eax,			6d646e65h	;; endm
		jne	_next
		cmp	dword ptr [esi+04h],	6f687465h	;; etho
		jne	_next
		cmp	byte ptr [esi+08h],	64h		;; d
		jne	_next
		cmp	byte ptr [esi+09h],	20h		
		jg	_next
		jmp	_lFNPFuncOut

			;;----------------
			;; in function scan
			_lbl:
			_lFNPFuncScanIn:
			mov	ecx,			esi	;; temp script posiyion
			xor	ebp,			ebp	;; temp flags

			_lFNPInFuncScan:
			inc	ecx
			mov	eax,			dword ptr [ecx]

			cmp	al,			22h	;; "
			jne	_next
			_lFNPInFuncScanString:
			inc	ecx
			cmp	byte ptr [ecx],		5ch	;; \ 
			jne	_lFNPInFuncScanStringEX
			add	ecx,			02h
			_lFNPInFuncScanStringEX:
			cmp	byte ptr [ecx],		22h	;; "
			jne	_lFNPInFuncScanString
			jmp	_lFNPInFuncScan

			_lbl:
			cmp	ax,			0a0dh
			jne	_next
			cmp	ebp,			0100b		;; adding call
			jb	_lFNPCopyParse
			mov	dword ptr [edi],	6c6c6163h	;; call
			mov	byte ptr [edi+04h],	20h		;; _
			add	edi,			05h
			jmp	_lFNPCopyParse

			_lbl:
			cmp	al,			28h	;; (
			jne	_next
			or	ebp,			0100b	;; call pre
			jmp	_lFNPInFuncScan

			_lbl:
			cmp	al,	 		3dh	;; =
			jne	_next
			cmp	ax,			3d3dh	;; ==
			jne	_lFNPSetEX
			inc	ecx
			jmp	_lFNPInFuncScan

			_lFNPSetEX:
			cmp	ax,			3d3dh	;; set pre
			je	_lFNPInFuncScan
			cmp	byte ptr [ecx-01h],	3ch
			je	_lFNPInFuncScan
			cmp	byte ptr [ecx-01h],	3eh
			je	_lFNPInFuncScan
			cmp	byte ptr [ecx-01h],	21h
			je	_lFNPInFuncScan
			_lFNPSet:
			mov	dword ptr [edi],	20746573h	;; set_
			add	edi,			04h
			jmp	_lFNPCopyParse

			_lbl:
			cmp	eax,	 		0a0d2b2bh	;; ++
			jne	_next
			mov	word ptr [ecx],		7001h		;; #p
			jmp	_lFNPSet
			_lbl:
			cmp	eax,	 		06062b2bh	;; ++
			jne	_next
			mov	word ptr [ecx],		7001h		;; #p
			jmp	_lFNPSet

			_lbl:
			cmp	eax,	 		0a0d2d2dh	;; --
			jne	_next
			mov	word ptr [ecx],		6d01h		;; #m
			jmp	_lFNPSet
			_lbl:
			cmp	eax,	 		06062d2dh	;; --
			jne	_next
			mov	word ptr [ecx],		6d01h		;; #m
			jmp	_lFNPSet

			_lbl:
			cmp	al,			20h
			jne	_next
			or	ebp,			01b		;; local pre
			jmp	_lFNPInFuncScan

			_lbl:
			cmp	al,			5bh
			jne	_next
			or	ebp,			10b		;; local not
			jmp	_lFNPInFuncScan

			_lbl:
			cmp	ebp,			01h
			jne	_lFNPInFuncScan
			cmp	al,			41h
			jb	_lFNPInFuncScan
			cmp	al,			5ah
			jbe	_lFNPLocal
			cmp	al,			61h
			jb	_lFNPInFuncScan
			cmp	al,			7ah
			jg	_lFNPInFuncScan

			_lFNPLocal:
			mov	dword ptr [edi],	61636f6ch	;; loca
			mov	dword ptr [edi+04h],	206ch		;; l_
			add	edi,			06h
			jmp	_lFNVarParse
			;;----------------
		;;----------------

		;;----------------
		;; ex code parsing
		_lFNPExCode:
		mov	dword ptr [edi],	20212f2fh	;; //!_
		add	esi,			03h
		add	edi,			04h
		mov	eax,			dword ptr [esi]

		cmp	ax,			0a0dh
		je	_lFNPCopy

		cmp	eax,			656a6e69h	;; inje
		jne	_next
		cmp	word ptr [esi+04h],	7463h		;; ct
		jne	_next
		cmp	byte ptr [esi+06h],	20h		;; _
		jg	_next

			;;----------------
			;; anon
			xor	eax,			eax
			lea	ecx,			[esi+06h]

			_lFNPInjAddAnon_00:
			inc	ecx
			_lFNPInjAddAnon_00_EX:

			cmp	byte ptr [ecx],		18h		;; anon block
			je	_lFNPInjAddAnon_01

			cmp	dword ptr [ecx],	2f2f0a0dh	;; // en
			je	_lFNPInjAddAnon_02

			cmp	word ptr [ecx],		7801h		;; #x
			je	_lFNPInjAddAnon_03
			cmp	word ptr [ecx],		7901h		;; #y
			jne	_lFNPInjAddAnon_00

			_lFNPInjAddAnon_03:
			add	ecx,			06h
			jmp	_lFNPInjAddAnon_00_EX

			_lFNPInjAddAnon_01:
;			mov	byte ptr [ecx],		20h		;; bs
mov	byte ptr [ecx],		1ah		;; bs
			inc	eax
			jmp	_lFNPInjAddAnon_00

			_lFNPInjAddAnon_02:
			cmp	dword ptr [ecx+04h],	"dne!"
			jne	_lFNPInjAddAnon_00
			cmp	dword ptr [ecx+08h],	"ejni"
			jne	_lFNPInjAddAnon_00
			cmp	word ptr [ecx+0ch],	"tc"
			jne	_lFNPInjAddAnon_00
			cmp	byte ptr [ecx+0eh],	20h
			jg	_lFNPInjAddAnon_00

			test	eax,				eax
			jz	_lFNPInjectNoAnon

			sub	edi,				04h
			call	_lFNPAnonFuncAdd
			mov	dword ptr [edi],		20212f2fh	;; //!_
			add	edi,				04h
			;;----------------

		_lFNPInjectNoAnon:
		lea	edx,			[esi+06h]
		_lFNPInjectLoop:
		inc	edx
		mov	eax,			dword ptr [edx]
		cmp	ax,			0a0dh
		je	_lFNPCopy	
		cmp	eax,			6e69616dh	;; main
		jne	_lFNPInjectLoopEX
		cmp	byte ptr [edx+04h],	20h		;; _
		jg	_lFNPInjectLoopEX
		jmp	_lFNPCopyFuncIn
		_lFNPInjectLoopEX:
		cmp	eax,			666e6f63h	;; conf
		jne	_lFNPInjectLoop
		cmp	word ptr [edx+04h],	6769h		;; if
		jne	_lFNPInjectLoop
		cmp	byte ptr [edx+06h],	20h		;; _
		jg	_lFNPInjectLoop
		jmp	_lFNPCopyFuncIn

;;		_lbl:
;;		cmp	eax,			6f706d69h	;; impo
;;		jne	_next
;;		cmp	word ptr [esi+04h],	7472h		;; rt
;;		jne	_next
;;		movsd
;;		movsw
;;		mov	byte ptr [edi],		20h		;; bs
;;		inc	edi
;;		jmp	_lFNPCopy

		_lbl:
		cmp	eax,			69646e65h	;; endi
		jne	_next
		cmp	dword ptr [esi+04h],	63656a6eh	;; njec
		jne	_next
		cmp	byte ptr [esi+08h],	74h		;; t
		jne	_next
		cmp	byte ptr [esi+09h],	20h		;; _
		jg	_next

		mov	eax,			dword ptr [_dFCB]
		mov	dword ptr [eax],	20212f2fh	;; //!_
		add	eax,			04h
		mov	dword ptr [_dFCB],	eax

		jmp	_lFNPFuncOut

		;;----------------
		;; external
		_lbl:
		cmp	eax,			"etxe"
		jne	_next
		cmp	dword ptr [esi+04h],	"lanr"
		jne	_next
		cmp	dword ptr [esi+08h],	"colb"
		jne	_next
		cmp	word ptr [esi+0ch],	" k"
		jne	_next

		lea	ecx,			[esi+09h]
		xor	eax,			eax

			;;----------------
			;; fix
			_lFNPExterFix:
			inc	ecx
			_lFNPExterFixEX:
			cmp	word ptr [ecx],			0a0dh	;; nl
			je	_lFNPCopy

			cmp	dword ptr [ecx],		"ttt "
			jne	_lFNPExterFix
			cmp	byte ptr [ecx+04h],		"t"
			jne	_lFNPExterFix

			lea	edx,				[ecx+08h]
			_lFNPExterFixNext:
			inc	edx
			mov	al,				byte ptr [edx]
			cmp	byte ptr [_bAscii_00+eax],	ah
			jne	_lFNPExterFixNext

			cmp	dword ptr [edx-04h],		"tttt"
			jne	_lFNPExterFix

			mov	dword ptr [ecx+01h],		24060606h	;; $
			mov	dword ptr [edx-04h],		06060624h	;; $
			add	ecx,				09h
			jmp	_lFNPExterFixEX
			;;----------------

		_lbl:
		cmp	al,			"i"
		jne	_lFNPCopy
		cmp	ah,			20h
		ja	_lFNPCopy

		lea	ecx,			[esi+02]
		xor	eax,			eax
		jmp	_lFNPExterFixEX
		;;----------------

		;;----------------
		;; outside the function
		_lFNPOutside:
		cmp	eax,			65736c65h	;; else
		jne	_next
		cmp	word ptr [esi+04h],	6669h		;; if
		jne	_lFNPOutsideEX
		cmp	byte ptr [esi+06h],	28h		;; bs
		jb	_lFNPCopy
	
		_lFNPOutsideEX:
		cmp	byte ptr [esi+04h],	20h		;; bs
		jb	_lFNPCopy

		_lbl:
		cmp	eax,			69646e65h	;; endi
		jne	_next
		cmp	byte ptr [esi+04h],	66h		;; f
		jne	_next
		cmp	byte ptr [esi+05h],	20h		;; bs
		jb	_lFNPCopy

		_lbl:
		cmp	eax,			74617473h	;; stat
		jne	_lFNPGlob
		cmp	dword ptr [esi+04h],	69206369h	;; ic_i
		jne	_lFNPGlob
		cmp	word ptr [esi+08h],	2066h		;; f_
		je	_lFNPCopy
		;;----------------

		;;----------------
		;; in globals
		_lFNPGlob:
		cmp	ebx,			1000b
		jb	_lFNPInCode

		cmp	eax,			67646e65h	;; endg
		jne	_lFNVarParse
		cmp	dword ptr [esi+04h],	61626f6ch	;; loba
		jne	_lFNVarParse
		cmp	word ptr [esi+08h],	736ch		;; ls
		jne	_lFNVarParse
		cmp	byte ptr [esi+0ah],	20h		;; _
		jg	_lFNVarParse
		xor	ebx,			1000b
		jmp	_lFNPCopy
		;;----------------

		;;----------------
		;; in code
		_lFNPInCode:
		cmp	eax,			626f6c67h	;; glob
		jne	_next
		cmp	dword ptr [esi+03h],	736c6162h	;; bals
		jne	_next
		cmp	byte ptr [esi+07h],	20h		;; _
		jg	_next
		or	ebx,			1000b
		jmp	_lFNPCopy

;;----------------
;; callbakc
_lbl:
cmp	eax,			"llac"
jne	_next
cmp	dword ptr [esi + 04h],	"kcab"
jne	_next
cmp	byte ptr [esi + 08h],	" "
jne	_next

add	esi,			09h

	;;----------------
	;; callback in
	mov	edx,			offset _xCallbacksTypes
	xor	eax,			eax

	_lCallbackGetType:
	mov	ecx,			esi

	_lCallbackGetType_Check:
	mov	al,			byte ptr [ecx]
	cmp	al,			byte ptr [edx]
	jne	_lCallbackGetType_Check_00
	inc	ecx
	inc	edx
	jmp	_lCallbackGetType_Check

	_lCallbackGetType_Check_00:
	cmp	byte ptr [_bAscii_00 + eax],	ah
	jne	_lCallbackGetType_Next
	cmp	byte ptr [edx],			00h
	jne	_lCallbackGetType_Next

		;;----------------
		;; get it
		push	ecx
		call	_lFNPCheckBlock
		pop	ecx
		test	eax,				eax
		jz	_lCallbackGetType_NoBlock
		mov	dword ptr [eax],		"cdne"
		mov	dword ptr [eax + 04h],		"blla"
		mov	dword ptr [eax + 08h],		" kca"

		_lCallbackGetType_NoBlock:

		mov	ebp,				dword ptr [_dCallbackListPnt]
		add	ebp,				_dCBSize
		mov	dword ptr [_dCallbackListPnt],	ebp

		mov	al,				byte ptr [edx + 02h]
		mov	byte ptr [ebp + 0ch],		al

		cmp	byte ptr [ecx],			"("
		jne	_lCallbackErr
		cmp	byte ptr [ecx + 01h],		")"
		je	_lCallback_ArgEnd

		cmp	byte ptr [edx + 01h],		00h
		je	_lCallbackErr

		lea	eax,				[ecx + 01h]
		mov	dword ptr [ebp + 08h],		eax

		_lCallback_ArgEnd:

;;----------------
;; add anon blocks
xor	eax,			eax

_lCallback_AnonPre:
inc	ecx
cmp	byte ptr [ecx],		00h
;; je err
cmp	word ptr [ecx - 01h],	0a0dh
jne	_lCallback_AnonPre

_lCallback_AnonChar:
inc	ecx

_lCallback_AnonCharEx:
cmp	byte ptr [ecx],		18h		;; anon block
je	_lCallback_Anon_00

cmp	byte ptr [ecx],		00h
;; je err

cmp	dword ptr [ecx],	6e650a0dh	;; nl en
je	_lCallback_Anon_03

cmp	word ptr [ecx],		7801h		;; #x
je	_lCallback_Anon_02
cmp	word ptr [ecx],		7901h		;; #y
jne	_lCallback_AnonChar

_lCallback_Anon_02:
add	ecx,			06h
jmp	_lCallback_AnonCharEx

_lCallback_Anon_00:
inc	eax
test	ebx,			ebx
jz	_lCallback_AnonFunc

mov	dword ptr [ecx - 08h],	"siht"
mov	dword ptr [ecx - 04h],	"epyt"
mov	byte ptr [ecx],	 	"."
jmp	_lCallback_AnonChar

_lCallback_AnonFunc:
mov	byte ptr [ecx],		" "
jmp	_lCallback_AnonChar

_lCallback_Anon_03:
cmp	dword ptr [ecx + 04h],	"lacd"
jne	_lCallback_AnonChar
cmp	dword ptr [ecx + 08h],	"cabl"
jne	_lCallback_AnonChar
cmp	byte ptr [ecx + 0ch],	"k"
jne	_lCallback_AnonChar
cmp	byte ptr [ecx + 0d],	20h
ja	_lCallback_AnonChar

test	eax,			eax
jz	_lCallback_AnonEnd

push	offset _lCallback_AnonEnd
test	ebx,			ebx
jz	_lFNPAnonFuncAdd
jmp	_lFNPAnonMethodAdd

_lCallback_AnonEnd:
;;----------------

		test	ebx,				ebx
		jnz	_lCallback_Method

		_lCallback_Func:
		mov	dword ptr [edi],		"cnuf"
		mov	dword ptr [edi + 04h],		"noit"
		mov	dword ptr [edi + 08h],		"_jc "
		mov	dword ptr [edi + 0ch],		"llac"
		mov	dword ptr [edi + 10h],		"kcab"
		mov	byte ptr [edi + 14h],		"_"
		lea	eax,				[edi + 09h]
		mov	dword ptr [ebp],		eax
		add	edi,				15h
		mov	dword ptr [_dLastFuncName],			eax
		jmp	_lCallback_AddName

		_lCallback_Method:
		mov	eax,				dword ptr [_dLastStructName]
		mov	dword ptr [ebp + 04h],		eax
		mov	dword ptr [edi],		"tats"
		mov	dword ptr [edi + 04h],		"m ci"
		mov	dword ptr [edi + 08h],		"ohte"
		mov	dword ptr [edi + 0ch],		"jc d"
		mov	dword ptr [edi + 10h],		"lac_"
		mov	dword ptr [edi + 14h],		"cabl"
		mov	word ptr [edi + 18h],		"_k"
		lea	eax,				[edi + 0eh]
		mov	dword ptr [ebp],		eax
		add	edi,				1ah
		mov	dword ptr [_dLastFuncName],			eax

		_lCallback_AddName:
		mov	ebp,				dword ptr [_dCallbackListNext]
		inc	ebp
		mov	dword ptr [_dCallbackListNext],	ebp
		and	ebp,				0ff000000h
		shr	ebp,				17h
		mov	ax,				word ptr [ebp + _bIntToHexStr]
		mov	word ptr [edi],			ax
		mov	ebp,				dword ptr [_dCallbackListNext]
		and	ebp,				00ff0000h
		shr	ebp,				0fh
		mov	ax,				word ptr [ebp + _bIntToHexStr]
		mov	word ptr [edi + 02h],		ax
		mov	ebp,				dword ptr [_dCallbackListNext]
		and	ebp,				0000ff00h
		shr	ebp,				07h
		mov	ax,				word ptr [ebp + _bIntToHexStr]
		mov	word ptr [edi + 04h],		ax
		mov	ebp,				dword ptr [_dCallbackListNext]
		and	ebp,				000000ffh
		shl	ebp,				01h
		mov	ax,				word ptr [ebp + _bIntToHexStr]
		mov	word ptr [edi + 06h],		ax

		mov	dword ptr [edi + 08h],		"kat "
		mov	dword ptr [edi + 0ch],		"n se"
		mov	dword ptr [edi + 10h],		"ihto"
		mov	dword ptr [edi + 14h],		"r gn"
		mov	dword ptr [edi + 18h],		"rute"
		mov	dword ptr [edi + 1ch],		"n sn"
		mov	dword ptr [edi + 20h],		"ihto"
		mov	dword ptr [edi + 24h],		0a0d676eh	;; ng nl

		mov	dword ptr [edi + 28h],		20232f2fh	;; //#_
		mov	dword ptr [edi + 2ch],		6974706fh	;; opti
		mov	dword ptr [edi + 30h],		6c616e6fh	;; onal
		mov	word ptr [edi + 34h],		0a0dh		;; nl

		add	edi,				36h

		mov	dword ptr [_dBCP],	edi	;; system in
		or	ebx,			01h

		_lCallback_CorrectCodeOffset:
		inc	esi
		cmp	word ptr [esi],		0a0dh
		jne	_lCallback_CorrectCodeOffset

		mov	dword ptr [_dFCL],	offset _bFuncCodeLocals
		mov	dword ptr [_dFCB],	offset _bFuncCodeBase

		mov	dword ptr [_dInFuncBlockMax],		00h
		mov	dword ptr [_dInFuncBlockStack],		00h
		mov	dword ptr [_dInFuncBlockPnt],		offset _dInFuncBlockStack + 04h

		mov	byte ptr [_bFuncCodeNop],		00h

		mov	dword ptr [_dGeneratedLocalsID],	0ffffffffh

		jmp	_lFNPLine
		;;----------------

	_lCallbackGetType_Next:
	cmp	byte ptr [edx],			00h
	je	_lCallbackGetType_Next_Ex
	inc	edx
	jmp	_lCallbackGetType_Next

	_lCallbackGetType_Next_Ex:
	add	edx,				03h
	cmp	byte ptr [edx],			00h
	jne	_lCallbackGetType

		;;----------------
		;; error
		_lCallbackErr:
		mov	dword ptr [_xErrorTable],	offset _sErr_UnkCallback
		mov	dword ptr [_xErrorTable + 04h],	edi
		inc	edi
		mov	dword ptr [_xErrorTable + 08h],	edi
		jmp	_lErrIn
		;;----------------
	;;----------------
;;----------------

		_lbl:
		cmp	eax,			73646e65h	;; ends
		jne	_next
		cmp	dword ptr [esi+04h],	63757274h	;; truc
		jne	_next
		cmp	byte ptr [esi+08h],	74h		;; t
		jne	_next
		cmp	byte ptr [esi+09h],	20h		;; _
		jg	_next
		mov	dword ptr [_dLastStructName],	00h
		xor	ebx,			10b
		jmp	_lFNPCopy

		_lbl:
		cmp	eax,			6d646e65h	;; endm
		jne	_next
		cmp	dword ptr [esi+04h],	6c75646fh	;; odul
		jne	_next
		cmp	byte ptr [esi+08h],	65h		;; e
		jne	_next
		cmp	byte ptr [esi+09h],	20h		;; _
		jg	_next
		mov	dword ptr [_dLastStructName],	00h
		xor	ebx,			10b
		jmp	_lFNPCopy

		_lbl:
		cmp	eax,			69646e65h	;; endi
		jne	_next
		cmp	dword ptr [esi+04h],	7265746eh	;; nter
		jne	_next
		cmp	dword ptr [esi+08h],	65636166h	;; face
		jne	_next
		cmp	byte ptr [esi+0ch],	20h		;; _
		jg	_next
		xor	ebx,			0100b
		jmp	_lFNPCopy

		_lbl:
		test	ebx,			ebx
		jz	_lFNPOutStruct

			;;----------------
			;; in the struct
			cmp	eax,			656c6564h	;; dele
			jne	_next
			cmp	dword ptr [esi+04h],	65746167h	;; gate
			jne	_next
			cmp	byte ptr [esi+08h],	20h		;; _
			jbe	_lFNPCopy

			_lbl:
			cmp	eax,			6c706d69h	;; impl
			jne	_next
			cmp	dword ptr [esi+04h],	6e656d65h	;; emen
			jne	_next
			cmp	word ptr [esi+06h],	2074h		;; t_
			je	_lFNPCopy

			_lbl:
			lea	ecx,			[esi-01h]
			_lFNPMSStart:
			inc	ecx
			mov	eax,			dword ptr [ecx]

			cmp	al,			3dh		;; =
			je	_lFNVarParse

			cmp	al,			28h		;; (
			je	_lFNPExFuncDef

			cmp	ax,			0a0dh
			je	_lFNVarParse

			cmp	eax,			7265706fh	;; oper
			jne	_lFNPMSStartEX
			cmp	dword ptr [ecx+04h],	726f7461h	;; ator
			jne	_lFNPMSStartEX
			cmp	byte ptr [ecx+08h],	3ch		;; <
			je	_lFNPExFuncDefEX
			cmp	byte ptr [ecx+08h],	3dh		;; =
			je	_lFNPExFuncDefEX
;;			cmp	byte ptr [ecx+08h],	3eh		;; >
;;			je	_lFNPExFuncDef
			cmp	byte ptr [ecx+08h],	21h		;; !
			je	_lFNPExFuncDefEX
			cmp	byte ptr [ecx+08h],	5bh		;; [ 
			je	_lFNPExFuncDefEX
			cmp	byte ptr [ecx+08h],	20h		;; bs
			je	_lFNPExFuncDefEX

			_lFNPMSStartEX:
			cmp	eax,			6874656dh	;; meth
			jne	_lFNPMSStart
			cmp	word ptr [ecx+04h],	646fh		;; od
			jne	_lFNPMSStart
			cmp	byte ptr [ecx+06h],	20h		;; _
			jg	_lFNPMSStart

			lea	eax,				[ecx+09h]
			mov	dword ptr [_dLastFuncName],	eax

				;;----------------
				;; anonyms
				xor	eax,			eax

				_lFNPMetAddAnon_00:
				inc	ecx
				_lFNPMetAddAnon_00_EX:

				cmp	byte ptr [ecx],		18h		;; anon block
				je	_lFNPMetAddAnon_01

				cmp	dword ptr [ecx],	6e650a0dh	;; nl en
				je	_lFNPMetAddAnon_02

				cmp	word ptr [ecx],		7801h		;; #x
				je	_lFNPMetAddAnon_03
				cmp	word ptr [ecx],		7901h		;; #y
				jne	_lFNPMetAddAnon_00

				_lFNPMetAddAnon_03:
				add	ecx,			06h
				jmp	_lFNPMetAddAnon_00_EX

					;;----------------
					;; add struct name
					_lFNPMetAddAnon_01:
					inc	eax
mov	dword ptr [ecx - 08h],		"siht"
mov	dword ptr [ecx - 04h],		"epyt"
mov	byte ptr [ecx],			"."
jmp	_lFNPMetAddAnon_00
;					mov	byte ptr [ecx],		"."
;
;					mov	ebp,			ecx
;					mov	edx,			dword ptr [_dCStructName]
;
;					_lFNPMetAddAnon_01_EX:
;					mov	bh,			byte ptr [edx]
;					cmp	bh,			20h	;; bs
;					je	_lFNPMetAddAnon_00
;					dec	ebp
;					mov	byte ptr [ebp],			bh
;					dec	edx
;					jmp	_lFNPMetAddAnon_01_EX
					;;----------------

				_lFNPMetAddAnon_02:
				cmp	dword ptr [ecx+04h],	"temd"
				jne	_lFNPMetAddAnon_00
				cmp	dword ptr [ecx+07h],	"doht"
				jne	_lFNPMetAddAnon_00
				cmp	byte ptr [ecx+0bh],	20h
				jg	_lFNPMetAddAnon_00

				test	eax,				eax
				jz	_lFNPCopyFuncInEx

;				xor	bh,				bh
				push	offset _lFNPCopyFuncInEx
				jmp	_lFNPAnonMethodAdd
				;;----------------
			;;----------------

			;;----------------
			;; out the struct
			_lFNPOutStruct:
			cmp	eax,			7262696ch	;; libr
			jne	_next
			cmp	dword ptr [esi+03h],	79726172h	;; rary
			jne	_next
			cmp	dword ptr [esi+07h],	636e6f5fh	;; _onc
			jne	_lFNPLibTestEX
			cmp	byte ptr [esi+0bh],	65h		;; e
			jne	_lFNPLibTestEX
			cmp	byte ptr [esi+0ch],	20h		;; _
			jg	_next
			_lFNPLibBlockEX:
			call	_lFNPCheckBlock
			test	eax,			eax
			jz	_lFNPCopy
			mov	dword ptr [eax],	6c646e65h	;; endl
			mov	dword ptr [eax+04h],	61726269h	;; ibra
			mov	word ptr [eax+08h],	7972h		;; ry
			jmp	_lFNPCopy
			_lFNPLibTestEX:
			cmp	byte ptr [esi+07h],	20h		;; _
			jbe	_lFNPLibBlockEX

			_lbl:
			cmp	eax, 			706f6373h	;; scop
			jne	_next
			cmp	byte  ptr [esi+04h],	65h		;; e
			jne	_next
			cmp	byte ptr [esi+05h],	20h		;; _
			jg	_next
			call	_lFNPCheckBlock
			test	eax,			eax
			jz	_lFNPCopy
			mov	dword ptr [eax],	73646e65h	;; ends
			mov	dword ptr [eax+04h],	65706f63h	;; cope
			jmp	_lFNPCopy

			_lbl:
			cmp	eax,			6c646e65h	;; endl
			jne	_next
			cmp	dword ptr [esi+04h],	61726269h	;; ibra
			jne	_next
			cmp	word ptr [esi+08h],	7972h		;; ry
			jne	_next
			cmp	byte ptr [esi+0ah],	20h		;; _
			jbe	_lFNPCopy

			_lbl:
			cmp	eax,			73646e65h	;; ends
			jne	_next
			cmp	dword ptr [esi+04h],	65706f63h	;; cope
			jne	_next
			cmp	byte ptr [esi+08h],	20h		;; _
			jbe	_lFNPCopy

				;;----------------
				;; public/private loop
				_lbl:
				lea	ecx,			[esi-01h]
				_lFNPInCodeScan:
				inc	ecx
				_lFNPInCodeScanEX:
				mov	eax,			dword ptr [ecx]

				cmp	eax,			76697270h	;; priv
				jne	_next
				cmp	dword ptr [ecx+04h],	20657461h	;; ate_
				jne	_next
				add	ecx,			08h
				jmp	_lFNPInCodeScanEX

				_lbl:
				cmp	eax,			6c627570h	;; publ
				jne	_next
				_lFNPScanIc:
				cmp	word ptr [ecx+04h],	6369h		;; ic
				jne	_next
				cmp	byte ptr [ecx+06h],	20h		;; _
				jne	_next
				add	ecx,			07h
				jmp	_lFNPInCodeScanEX

				_lbl:
				cmp	eax,			6974706fh	;; opti
				jne	_next
				cmp	dword ptr [ecx+04h],	6c616e6fh	;; onal
				jne	_next
				cmp	byte ptr [ecx+08h],	20h		;; bs
				jne	_next
				add	ecx,			09h
				jmp	_lFNPInCodeScanEX

				_lbl:
				cmp	eax,			736e6f63h	;; cons
				jne	_next
				cmp	dword ptr [ecx+04h],	746e6174h	;; tant
				jne	_next
				cmp	byte ptr [ecx+08h],	20h		;; _
				jne	_next
				add	ecx,			09h
				jmp	_lFNPInCodeScanEX

				_lbl:
				cmp	eax,			74617473h	;; stat
				je	_lFNPScanIc

					;;----------------
					;; function, native and function interface
					_lbl:
					cmp	eax,			6974616eh	;; nati
					jne	_next
					cmp	word ptr [ecx+04h],	6576h		;; ve
					jne	_next
					cmp	byte ptr [ecx+06h],	20h		;; bs
					jne	_next

					_lXFPNative:
					inc	ecx
					cmp	word ptr [ecx],		0a0dh		;; nl
					je	_lFNPCopy
					cmp	byte ptr [ecx],		28h		;; (
					jne	_lXFPNative
					jmp	_lFNPExFuncDef

						;;----------------
						;; add anon blocks
						_lFNPFuncAddAnon:
						xor	eax,			eax

						_lFNPFuncAddAnon_00:
						inc	ecx
						_lFNPFuncAddAnon_00_EX:

						cmp	byte ptr [ecx],		18h		;; anon block
						je	_lFNPFuncAddAnon_01

						cmp	dword ptr [ecx],	6e650a0dh	;; nl en
						je	_lFNPFuncAddAnon_02

						cmp	word ptr [ecx],		7801h		;; #x
						je	_lFNPFuncAddAnon_03
						cmp	word ptr [ecx],		7901h		;; #y
						jne	_lFNPFuncAddAnon_00

						_lFNPFuncAddAnon_03:
						add	ecx,			06h
						jmp	_lFNPFuncAddAnon_00_EX

						_lFNPFuncAddAnon_01:
						mov	byte ptr [ecx],		20h	;; bs
						inc	eax
						jmp	_lFNPFuncAddAnon_00

						_lFNPFuncAddAnon_02:
						cmp	dword ptr [ecx+04h],	"nufd"
						jne	_lFNPFuncAddAnon_00
						cmp	dword ptr [ecx+08h],	"oitc"
						jne	_lFNPFuncAddAnon_00
						cmp	byte ptr [ecx+0ch],	"n"
						jne	_lFNPFuncAddAnon_00
						cmp	byte ptr [ecx+0dh],	20h
						jg	_lFNPFuncAddAnon_00

						test	eax,				eax
						jz	_lFNPCopyFuncInEx

						push	offset _lFNPCopyFuncInEx

							;;----------------
							;; add anons blocks func
							_lFNPAnonFuncAdd:
							push	esi
							mov	esi,				dword ptr [_dAnonBlock]
							shl	eax,				02h
							mov	ecx,				dword ptr [esi]
							sub	esi,				eax
							mov	dword ptr [_dAnonBlock],	esi
							mov	esi,				dword ptr [esi]
							sub	ecx,				esi

								;;----------------
								;; remove 18h
								push	ecx
								push	edi
								mov	edi,				esi
								mov	al,				18h

								_lFNPAnonFuncAdd_00:
								repnz	scasb
								test	ecx,				ecx
								jz	_lFNPAnonFuncAdd_01

								mov	byte ptr [edi-01h],		" "
								jmp	_lFNPAnonFuncAdd_00

								_lFNPAnonFuncAdd_01:
								pop	edi
								pop	ecx
								;;----------------

							rep	movsb

							pop	esi

							retn
							;;----------------

							;;----------------
							;; add anons blocks method
							_lFNPAnonMethodAdd:
							push	esi
							mov	esi,				dword ptr [_dAnonBlock]
							shl	eax,				02h
							mov	ecx,				dword ptr [esi]
							sub	esi,				eax
							mov	dword ptr [_dAnonBlock],	esi
							mov	esi,				dword ptr [esi]
							sub	ecx,				esi

								;;----------------
									;;----------------
									;; fin method calling
									mov	ebp,				dword ptr [_dAnonFuncCnt]
									lea	eax,				[esi+ecx]

									_lFNPAnonMethodAdd_00:
									mov	edx,				dword ptr [ebp+0ch]

									test	edx,				edx
									jz	_lFNPAnonMethodAdd_01

									cmp	edx,				esi
									jb	_lFNPAnonMethodAdd_01

									cmp	edx,				eax
									jae	_lFNPAnonMethodAdd_02

									mov	dword ptr [edx],		"tats"
									mov	dword ptr [edx+04h],		"m ci"
									mov	dword ptr [edx+08h],		"ohte"
									mov	byte ptr [edx+0ch],		"d"

									mov	edx,				dword ptr [ebp+08h]
									mov	dword ptr [edx+03h],		"htem"
									mov	dword ptr [edx+07h],		"  do"

									_lFNPAnonMethodAdd_02: 
									add	ebp,				10h
									jmp	_lFNPAnonMethodAdd_00

									_lFNPAnonMethodAdd_01:
									mov	dword ptr [_dAnonFuncCnt],	ebp
									;;----------------

									;;----------------
									;; add struct name
									push	ecx
									push	edi
									mov	edi,				esi
									mov	al,				18h

									_lFNPAnonMethodAdd_03:

									repnz	scasb
									test	ecx,				ecx
									jz	_lFNPAnonMethodAdd_04

;									lea	ebp,				[edi-01h]
;									mov	edx,				dword ptr [_dCStructName]
									mov	dword ptr [edi - 09h],		"siht"
									mov	dword ptr [edi - 05h],		"epyt"
									mov	byte ptr [edi - 01h],		"."
jmp	_lFNPAnonMethodAdd_03

;									_lFNPAnonMethodAdd_05:
;									mov	bh,				byte ptr [edx]
;									cmp	bh,				20h	;; bs
;									je	_lFNPAnonMethodAdd_03
;									dec	ebp
;									mov	byte ptr [ebp],			bh
;									dec	edx
;									jmp	_lFNPAnonMethodAdd_05

									_lFNPAnonMethodAdd_04:
									pop	edi
									pop	ecx
									xor	bh,				bh
									;;----------------
								;;----------------

							rep	movsb

							pop	esi

							retn
							;;----------------
						;;----------------

					_lbl:
					cmp	eax,			636e7566h	;; func
					jne	_next
					cmp	dword ptr [ecx+04h],	6e6f6974h	;; tion
					jne	_next
					cmp	byte ptr [ecx+08h],	20h		;; _
					jne	_next
					cmp	ebx,			0100b
					jge	_lFNPCopy

					lea	eax,				[ecx+09h]
					mov	dword ptr [_dLastFuncName],	eax

					cmp	dword ptr [ecx+09h],	65746e69h	;; inte
					jne	_lFNPFuncAddAnon
					cmp	dword ptr [ecx+0dh],	63616672h	;; rfac
					jne	_lFNPFuncAddAnon
					cmp	word ptr [ecx+11h],	2065h		;; e_
					je	_lFNPCopy
					;;----------------

					;;----------------
					;; struct
					_lbl:
					cmp	eax,			75727473h	;; stru
					jne	_next
					cmp	word ptr [ecx+04h],	7463h		;; ct
					jne	_next
					cmp	byte ptr [ecx+06h],	20h		;; _
					jg	_next

					lea	eax,			[ecx+07h]
					mov	dword ptr [_dLastStructName],	eax

					or	ebx,			10b
					mov	edx,			ecx
					call	_lFNPCheckBlock
					test	eax,			eax
					jz	_lFNPGetStructName
					mov	dword ptr [eax],	73646e65h	;; ends
					mov	dword ptr [eax+04h],	63757274h	;; truc
					mov	byte ptr [eax+08h],	74h		;; t
					jmp	_lFNPGetStructName
					;;----------------

					;;----------------
					;; module
					_lbl:
					cmp	eax,			75646f6dh	;; modu
					jne	_next
					cmp	word ptr [ecx+04h],	656ch		;; le
					jne	_next
					cmp	byte ptr [ecx+06h],	20h		;; _
					jg	_next

					lea	eax,			[ecx+07h]
					mov	dword ptr [_dLastStructName],	eax

					or	ebx,			10b
					mov	edx,			ecx
					call	_lFNPCheckBlock
					test	eax,			eax
					jz	_lFNPGetStructName
					mov	dword ptr [eax],	6d646e65h	;; endm
					mov	dword ptr [eax+04h],	6c75646fh	;; odul
					mov	byte ptr [eax+08h],	65h		;; e

						;;----------------
						;; get struck/module name
						_lFNPGetStructName:
						add	edx,				06h
						xor	eax,				eax

						_lFNPGetStructNameEX:
						inc	edx
						mov	al,				byte ptr [edx]
						cmp	byte ptr [_bAscii_00+eax],	00h
						jne	_lFNPGetStructNameEX
						dec	edx

						mov	dword ptr [_dCStructName],	edx
						;;----------------

					jmp	_lFNPCopy
					;;----------------


				_lbl:
				cmp	eax,			65746e69h	;; inte
				jne	_next
				cmp	dword ptr [ecx+04h],	63616672h	;; rfac
				jne	_next
				cmp	byte ptr [ecx+08h],	65h		;; e
				jne	_next
				cmp	byte ptr [ecx+09h],	20h		;; _
				jg	_next
				or	ebx,			0100b
				call	_lFNPCheckBlock
				test	eax,			eax
				jz	_lFNPCopy
				mov	dword ptr [eax],	69646e65h	;; endi
				mov	dword ptr [eax+04h],	7265746eh	;; nter
				mov	dword ptr [eax+08h],	65636166h	;; face
				jmp	_lFNPCopy

				_lbl:
				cmp	eax,			7779656bh	;; keyw
				jne	_next
				cmp	dword ptr [ecx+03h],	64726f77h	;; word
				jne	_next
				cmp	byte ptr [ecx+07h],	20h		;; _
				jbe	_lFNPCopy

				_lbl:
				cmp	eax,			6b6f6f68h	;; hook
				jne	_next
				cmp	byte ptr [esi+04h],	20h		;; bs
				je	_lFNPCopy

				_lbl:
				cmp	eax,			65707974h	;; type
				jne	_lFNPGlobalsScan
				cmp	byte ptr [ecx+04h],	20h		;; _
				jbe	_lFNPCopy

				_lFNPGlobalsScanEx:
				inc	ecx
				mov	eax,			dword ptr [ecx]
				_lFNPGlobalsScan:
				cmp	ax,			0a0dh
				je	_lFNPAddGlobals
				cmp	al,			3dh		;; =
				je	_lFNPAddGlobalsEx

				cmp	al,			28h		;; (
				jne	_lFNPGlobalsScanEx
				cmp	word ptr [ecx-02h],	0a0dh		;; nl
				jne	_lFNPExFuncDef

				jmp	_lFNPGlobalsScanEx

				_lFNPAddGlobalsEx:
				inc	ecx
				cmp	word ptr [ecx],		0a0dh
				jne	_lFNPAddGlobalsEx
				_lFNPAddGlobals:
				mov	word ptr [ecx],		3301h		;; #3
				mov	dword ptr [edi],	626f6c67h	;; glob
				mov	dword ptr [edi+04h],	0d736c61h	;; als_
				mov	byte ptr [edi+08h],	0ah		;; _
				add	edi,			09h
				jmp	_lFNVarParse
				;;----------------
			;;----------------
		;;----------------

		;;----------------
		;; ex function define
		_lFNPExFuncDefOpt:
		cmp	dword ptr [esi+04h],	6c616e6fh	;; onal
		jne	_lFNPExFuncDefDX
		cmp	byte ptr [esi+08h],	20h		;; bs
		jne	_lFNPExFuncDefDX

		add	esi,			09h
		mov	byte ptr [_bOprInFunc],	01h
		jmp	_lFNPExFuncDefDX

		_lFNPExFuncDefEX:		;; from overloading operators
		inc	ecx
		cmp	byte ptr [ecx],		28h		;; ( 
		jne	_lFNPExFuncDefEX

		;; --->
		_lFNPExFuncDef:

			;;----------------
			;; add anon blocks
			cmp	ebx,			10b
			jg	_lFNPExFuncDefAddAnon_EndEX

			push	ecx
			xor	eax,			eax

			_lFNPExFuncDefAddAnon_00:
			inc	ecx
			cmp	word ptr [ecx],		0a0dh	;; ln
			je	_lFNPExFuncDefAddAnon_End
			cmp	word ptr [ecx],		7801h	;; #x
			jne	_lFNPExFuncDefAddAnon_00

			mov	ebp,			dword ptr [ecx+02h]
			add	ecx,			05h

			_lFNPExFuncDefAddAnon_01:
			inc	ecx
			_lFNPExFuncDefAddAnon_01_EX:
			cmp	ecx,			ebp
			je	_lFNPExFuncDefAddAnon_03

			cmp	byte ptr [ecx],		18h	;; anon block
			je	_lFNPExFuncDefAddAnon_02

			cmp	word ptr [ecx],		7801h	;; #x
			je	_lFNPExFuncDefAddAnon_04
			cmp	word ptr [ecx],		7901h	;; #y
			jne	_lFNPExFuncDefAddAnon_01

			_lFNPExFuncDefAddAnon_04:
			add	ecx,			06h
			jmp	_lFNPExFuncDefAddAnon_01_EX

				;;----------------
				;; process 18h
				_lFNPExFuncDefAddAnon_02:
				inc	eax

mov	byte ptr [ecx],		" "
test	ebx,			ebx
jz	_lFNPExFuncDefAddAnon_01
mov	dword ptr [ecx - 08h],	"siht"
mov	dword ptr [ecx - 04h],	"epyt"
mov	byte ptr [ecx],		"."

jmp	_lFNPExFuncDefAddAnon_01
;				mov	byte ptr [ecx],		20h	;; bs
;
;				test	ebx,			ebx
;
;				jz	_lFNPExFuncDefAddAnon_01
;
;					;;----------------
;					;; add struct name
;					push	eax
;					push	ecx
;					mov	byte ptr [ecx],			"."
;					mov	edx,				dword ptr [_dCStructName]
;
;					_lFNPExFuncDefAddAnon_02_EX:
;					mov	bh,				byte ptr [edx]
;					cmp	bh,				20h	;; bs
;					je	_lFNPExFuncDefAddAnon_02_FX
;					dec	ecx
;					mov	byte ptr [ecx],			bh
;					dec	edx
;					jmp	_lFNPExFuncDefAddAnon_02_EX
;
;					_lFNPExFuncDefAddAnon_02_FX:
;					xor	bh,				bh
;					pop	ecx
;					pop	eax
;					jmp	_lFNPExFuncDefAddAnon_01
;					;;----------------
				;;----------------

			_lFNPExFuncDefAddAnon_03:
			test	eax,				eax
			jz	_lFNPExFuncDefAddAnon_End

			push	offset _lFNPExFuncDefAddAnon_End
			test	ebx,				ebx
			jz	_lFNPAnonFuncAdd
			jmp	_lFNPAnonMethodAdd

			_lFNPExFuncDefAddAnon_End:
			pop	ecx
			_lFNPExFuncDefAddAnon_EndEX:
			;;----------------

		dec	ecx			;; ecx = func name
		cmp	word ptr [ecx-02h],	0a0dh		;; nl
		je	_lFNPCopy
		cmp	byte ptr [ecx-01h],	20h		;; _
		jne	_lFNPExFuncDef

		;; is operator?
		cmp	dword ptr [ecx-05h],	726f7461h	;; ator
		jne	_next
		cmp	dword ptr [ecx-09h],	7265706fh	;; oper
		jne	_next
		sub	ecx,			09h

		_lbl:
		mov	edx,			ecx
		_lbl:				;; edx = type
		dec	edx
		cmp	word ptr [edx-02h],	0a0dh		;; new line
		je	_lFNPExFuncDefDX
		cmp	byte ptr [edx-01h],	20h		;; _
		jne	_prew

		_lFNPExFuncDefMX:		;; copy func params
		cmp	dword ptr [esi],	6974706fh	;; opti
		je	_lFNPExFuncDefOpt

		movsb
		_lFNPExFuncDefDX:
		cmp	esi,			edx
		jne	_lFNPExFuncDefMX

			;;----------------
			;; add func or method
			cmp	dword ptr [edi-07h],	6974616eh	;; nati
			jne	_lFNPExFuncDefTTTF
			cmp	word ptr [edi-03h],	6576h		;; ve
			jne	_lFNPExFuncDefTTTF
			cmp	byte ptr [edi-01h],	20h		;; bs
			je	_next

			_lFNPExFuncDefTTTF:
			cmp	ebx,			10b
			jb	_lFNPExFuncDefFF

			mov	dword ptr [edi],	6874656dh	;; meth
			mov	dword ptr [edi+04h],	0020646fh	;; od_
			add	edi,			07h
			jmp	_next
			_lFNPExFuncDefFF:
			mov	dword ptr [edi],	636e7566h	;; func
			mov	dword ptr [edi+04h],	6e6f6974h	;; tion
			mov	byte ptr [edi+08h],	20h		;; _
			add	edi,			09h
			;;----------------

		_lbl:
		mov	esi,				ecx	;; copy func name

		mov	dword ptr [_dLastFuncName],	ecx

		_lbl:
		movsb
		cmp	byte ptr [esi],		28h		;; (
		jne	_prew

		_lbl:				;; adding takes
		mov	dword ptr [edi],	6b617420h	;; _tak
		mov	dword ptr [edi+04h],	00207365h	;; es_
		add	edi,			07h

		cmp	word ptr [esi],		2928h		;; ()
		jne	_next

		mov	dword ptr [edi],	68746f6eh	;; noth
		mov	dword ptr [edi+04h],	00676e69h	;; ing
		add	edi,			07h
		inc	esi
		jmp	_lFNPExFuncDefSX

		_lbl:
		inc	esi
		_lbl:				;; copy arguments
		movsb
		cmp	byte ptr [esi],		29h		;; )
		jne	_prew

		_lFNPExFuncDefSX:		;; add returns
		inc	esi
		mov	dword ptr [edi],	74657220h	;; _ret
		mov	dword ptr [edi+04h],	736e7275h	;; urns
		mov	byte ptr [edi+08h],	20h		;; _
		add	edi,			09h

		_lbl:				;; copy func type
		mov	al,			byte ptr [edx]
		cmp	al,			20h
		je	_next
		mov	byte ptr [edi],		al
		inc	edx
		inc	edi
		jmp	_prew

		_lbl:				;; func in?
		cmp	ebx,			0100b
		jge	_lFNPExFuncDefUX

		;; add endfunction
		cmp	word ptr [esi],		7801h		;; #x
		je	_lFNPExFuncDefEnd

		_lFNPExFuncDefUX:
		mov	word ptr [edi],		0a0dh		;; nl
		add	edi,			02h
		jmp	_lFNPLine

		_lFNPExFuncDefEnd:
		mov	eax,			dword ptr [esi+02h]
		add	esi,			06h
		mov	word ptr [edi],		0a0dh		;; new line
		add	edi,			02h

			;;----------------
			;; add endfunc or endmethod
			cmp	word ptr [eax-02h],	0a0dh		;; new line
			je	_next
			mov	word ptr [eax],		0a0dh		;; new line
			add	eax,			02h
			_lbl:
			cmp	ebx,			10b
			jb	_lFNPExFuncDefEF
			mov	dword ptr [eax],	6d646e65h	;; endm
			mov	dword ptr [eax+04h],	6f687465h	;; etho
			mov	byte ptr [eax+08h],	64h		;; d
			jmp	_next
			_lFNPExFuncDefEF:
			mov	dword ptr [eax],	66646e65h	;; endf
			mov	dword ptr [eax+04h],	74636e75h	;; unct
			mov	dword ptr [eax+08h],	066e6f69h	;; ion
			;;----------------

		_lbl:
		cmp	byte ptr [_bOprInFunc],	00h
		je	_next

		mov	byte ptr [_bOprInFunc],	00h
		mov	dword ptr [edi],	20232f2fh	;; //#_
		mov	dword ptr [edi+04h],	6974706fh	;; opti
		mov	dword ptr [edi+08h],	6c616e6fh	;; onal
		mov	word ptr [edi+0ch],	0a0dh		;; nl
		add	edi,			0eh

		_lbl:
		mov	dword ptr [_dBCP],	edi	;; system in
		or	ebx,			01h

		mov	dword ptr [_dFCL],	offset _bFuncCodeLocals
		mov	dword ptr [_dFCB],	offset _bFuncCodeBase

		mov	dword ptr [_dInFuncBlockMax],		00h
		mov	dword ptr [_dInFuncBlockStack],		00h
		mov	dword ptr [_dInFuncBlockPnt],		offset _dInFuncBlockStack + 04h

		mov	byte ptr [_bFuncCodeNop],		00h

		mov	dword ptr [_dGeneratedLocalsID],	0ffffffffh

		jmp	_lFNPLine
		;;----------------

		;;----------------
		;; parse comma in variables declaration
		_lFNVarParse:
		push	ebx
		lea	ecx,			[esi-01h]
		xor	edx,			edx
		xor	ebx,			ebx

		_lFNVarParseEx:
		inc	ecx
		mov	eax,			dword ptr [ecx]

		cmp	al,			22h	;; "
		jne	_next
		_lFNVarParseString:
		inc	ecx
		cmp	byte ptr [ecx],		5ch	;; \ 
		jne	_lFNVarParseStringEX
		add	ecx,			02h
		_lFNVarParseStringEX:
		cmp	byte ptr [ecx],		22h	;; "
		jne	_lFNVarParseString
		jmp	_lFNVarParseEx

		_lbl:
		cmp	al,			28h	;; (
		jne	_next
		inc	edx
		jmp	_lFNVarParseEx

		_lbl:
		cmp	al,			3dh	;; =
		jne	_next
		inc	ebx
		jmp	_lFNVarParseEx

		_lbl:
		cmp	al,			29h	;; )
		jne	_next
		dec	edx
		jmp	_lFNVarParseEx

		_lbl:
		test	ebx,			ebx
		jnz	_next

		cmp	al,			5bh	;; [
		jne	_next
		cmp	ax,			5d5bh	;; []
		jne	_lFNVarParseFx
		mov	word ptr [ecx],		0606h	;; ex bs
		_lFNVarParseFx:
		mov	ebp,			ecx
		_lFNVarParseFxOx:
		dec	ebp
		cmp	byte ptr [ebp],		3dh	;; =
		je	_lFNVarParseEx
		cmp	byte ptr [ebp],		0eh	;; ;
		je	_lFNVarParseKx
		cmp	byte ptr [ebp],		0fh	;; array
		je	_lFNVarParseEx
		cmp	byte ptr [ebp],		20h	;; bs
		jne	_lFNVarParseFxOx

				;; array
		mov	byte ptr [ebp],		0fh	;; array
		jmp	_lFNVarParseEx

		_lFNVarParseKx:	;; ex array
		mov	al,			byte ptr [ebp+01h]
		or	al,			80h
		mov	byte ptr [ebp+01h],	al
		jmp	_lFNVarParseEx

		_lbl:
		cmp	al,			2ch	;; ,
		jne	_next
		test	edx,			edx
		jnz	_lFNVarParseEx
		mov	byte ptr [ecx],		0eh	;; ;
		xor	ebx,			ebx

		jmp	_lFNVarParseEx

		_lbl:
		cmp	ax,			3301h	;; #3
		je	_next
		cmp	ax,			0a0dh
		jne	_lFNVarParseEx

		_lbl:
		pop	ebx
		jmp	_lFNPCopyParse
		;;----------------

		;;----------------
		;; check blocks
		_lFNPCheckBlock:
		mov	ecx,			esi
		_lFNPCheckBlockEx:
		inc	ecx
		cmp	word ptr [ecx],		0a0dh
		je	_lFNPCheckBlockSx
		cmp	word ptr [ecx],		7801h		;; #x
		jne	_lFNPCheckBlockEx

		mov	eax,			dword ptr [ecx+02h]
		mov	dword ptr [ecx],	06060606h
		mov	word ptr [ecx+04h],	0a0dh

		cmp	word ptr [eax-02h],	0a0dh
		je	_lFNPCheckBlockRet
		mov	word ptr [eax],		0a0dh
		add	eax,			02h
		_lFNPCheckBlockRet:
		retn

		_lFNPCheckBlockSx:
		xor	eax,			eax
		retn
		;;----------------

		;;----------------
		;; copy line (function in)
		_lFNPCopyFuncOpt:
		cmp	dword ptr [esi+04h],	6c616e6fh	;; onal
		jne	_lFNPCopyFuncIn
		cmp	byte ptr [esi+08h],	20h		;; bs
		jne	_lFNPCopyFuncIn

		add	esi,			09h
		mov	byte ptr [_bOprInFunc],	01h

		jmp	_lFNPCopyFuncInEx


		_lFNPCopyFuncIn:
		movsb
		_lFNPCopyFuncInEx:
		mov	eax,			dword ptr [esi]

		cmp	eax,			6974706fh	;; opti
		je	_lFNPCopyFuncOpt

;;		cmp	al,			00h
;;		je	_lFNPEnd
		cmp	ax,			7801h	;; #x
		je	_lFNPUnBlockErr

		cmp	al,			3ch	;; < = >
		jb	_lFNPCopyFuncInSx
		cmp	al,			3eh	;; >
		jg	_lFNPCopyFuncInDx

		_lFNPCopyFuncInOx:
		cmp	byte ptr [esi+01h],	3dh	;; = ;; ==
		je	_lFNPCopyFuncIn
		mov	ah,			20h	;; _
		mov	word ptr [edi],		ax
		add	edi,			02h
		inc	esi
		jmp	_lFNPCopyFuncInEx
		
		_lFNPCopyFuncInDx:
		cmp	al,			5dh	;; ] 
		jne	_lFNPCopyFuncInSx
		cmp	ax,			3d5dh	;; ]=
		je	_lFNPCopyFuncIn
		jmp	_lFNPCopyFuncInOx

		_lFNPCopyFuncInSx:
		cmp	ax,			0a0dh	;; nl
		jne	_lFNPCopyFuncInXx

		movsw

			;;----------------
			;; interfaces ?
			cmp	ebx,			0100b
			je	_lFNPLine			
			;;----------------

		cmp	byte ptr [_bOprInFunc],	00h
		je	_next

		mov	byte ptr [_bOprInFunc],	00h
		mov	dword ptr [edi],	20232f2fh	;; //#_
		mov	dword ptr [edi+04h],	6974706fh	;; opti
		mov	dword ptr [edi+08h],	6c616e6fh	;; onal
		mov	word ptr [edi+0ch],	0a0dh		;; nl
		add	edi,			0eh

		_lbl:
		mov	dword ptr [_dBCP],	edi
		or	ebx,			01h

		mov	dword ptr [_dFCL],	offset _bFuncCodeLocals
		mov	dword ptr [_dFCB],	offset _bFuncCodeBase

		mov	dword ptr [_dInFuncBlockMax],		00h
		mov	dword ptr [_dInFuncBlockStack],		00h
		mov	dword ptr [_dInFuncBlockPnt],		offset _dInFuncBlockStack + 04h

		mov	byte ptr [_bFuncCodeNop],		00h

		mov	dword ptr [_dGeneratedLocalsID],	0ffffffffh

		jmp	_lFNPLine

		_lFNPCopyFuncInXx:
		cmp	al,			06h	;; ex _
		jne	_lFNPCopyFuncIn
		inc	esi
		jmp	_lFNPCopyFuncInEx
		;;----------------

		;;----------------
		;; unknow block
		_lFNPUnBlockErr:
		mov	dword ptr [_xErrorTable],	offset _sErr_UnknowBlock
		mov	dword ptr [_xErrorTable+04h],	edi
		mov	dword ptr [edi],		007b0a0dh	;; nl {
		add	edi,				03h
		mov	dword ptr [_xErrorTable+08h],	edi
		jmp	_lErrIn
		;;----------------

		;;----------------
		;; copy line (no parse)
		_lFNPCopySTR:
		cmp	byte ptr [_bStrXX],	00h
		je	_lFNPCopySTREX
		movsb
		mov	byte ptr [edi],		20h
		inc	edi
		jmp	_lFNPCopyEx

		_lFNPCopySTREX:
		mov	byte ptr [_bStrXX],	al
		mov	byte ptr [edi],		20h
		inc	edi

		_lFNPCopy:
		movsb
		_lFNPCopyEx:
		mov	eax,			dword ptr [esi]
		cmp	al,			00h
		je	_lFNPEnd
		cmp	al,			22h	;; "
		je	_lFNPCopySTR
		cmp	ax,			7801h	;; #x
		je	_lFNPUnBlockErr
		cmp	ax,			0a0dh
		jne	_lFNPCopySx
		test	ebx,			01b
		jp	_lFNPLineEx

			;;----------------
			;; add line ex
			movsw				;; copy nl

			mov	eax,			esi
			mov	esi,			offset _bFuncCodeOneLine
			mov	ecx,			edi
			sub	ecx,			esi
			mov	edi,			dword ptr [_dFCB]
			rep	movsb
			mov	esi,			eax
			mov	dword ptr [_dFCB],	edi
			jmp	_lFNPLine
			;;----------------

		_lFNPCopySx:
		cmp	al,			06h	;; ex _
		jne	_lFNPCopy
		inc	esi
		jmp	_lFNPCopyEx
		;;----------------

		;;----------------
		;; copy line (with parse)
		_lFNPCopyParse:
		xor	eax,				eax
		jmp	_lFNPCopyParseNext

		_lFNPCopyParseCX:
		stosb
		_lFNPCopyParseNext:
		lodsb

		cmp	byte ptr [_bAscii_00+eax],	00h
;;		jz	_lFNPCopyParseSym
;;		jmp	_lFNPCopyParseCX
		jnz	_lFNPCopyParseCX

			;;----------------
			;; symbols
			_lFNPCopyParseSym:
			mov	ecx,			dword ptr [esi-01h]

			cmp	cx,			7c7ch		;; ||
			jne	_next
			inc	esi
			mov	dword ptr [edi],	20726f20h	;; _or_
			add	edi,			04h
			jmp	_lFNPCopyParseNext

			_lbl:
			cmp	cl,			21h		;; !
			jne	_next
			cmp	cx,			3d21h		;; !=
			jne	_lFNPNot
			stosb
			movsb
			jmp	_lFNPCopyParseNext
			_lFNPNot:
			mov	dword ptr [edi],	746f6e20h	;; _not
			mov	dword ptr [edi+04h],	20h		;; _
			add	edi,			05h
			jmp	_lFNPCopyParseNext

			_lbl:
			cmp	cx,			2626h		;; &&
			jne	_next
			inc	esi
			mov	dword ptr [edi],	646e6120h	;; _and
			mov	dword ptr [edi+04h],	20h		;; _
			add	edi,			05h
			jmp	_lFNPCopyParseNext

;;_lbl:
;;cmp	cl,				18h	;; anon func in nesteds function
;;jne	_next
;;mov	byte ptr [_bAnonBlockEX],	01h
;;jmp	_lFNPCopyParseCX


			_lbl:
			cmp	cx,			2b2bh		;; ++
			jne	_next
			push	2bh					;; +
			jmp	_lFNPIncDecPreX

			_lbl:
			cmp	cx,			2d2dh		;; --
			jne	_next
			push	2dh					;; -

				;;----------------
				;; inc dec pre
				_lFNPIncDecPreX:
				push	edi
				inc	esi

				mov	al,			byte ptr [esi]
				cmp	byte ptr [_bAscii_00+eax],	00h
				jz	_lFNPCopyParseNext

				mov	al,			byte ptr [esi-03h]
				cmp	byte ptr [_bAscii_00+eax],	00h
				jz	_lFNPCopyParseNext

				mov	byte ptr [edi],		20h		;; _
				inc	edi
				inc	dword ptr [esp]

				jmp	_lFNPCopyParseNext
				;;----------------

				;;----------------
				;; string
				_lbl:
				cmp	cl,			22h		;; "
				jne	_next
				stosb
				_lFNPCopyString:
				cmp	word ptr [esi],		3801h		;; #8
				je	_lFNPCopyStringFN
				movsb
				_lFNPCopyStringSX:
				cmp	byte ptr [edi-01h],	22h		;; "
				je	_lFNPCopyParseNext
				cmp	byte ptr [edi-01h],	5ch		;; \ 
				je	_lFNPCopyStringEX
				jmp	_lFNPCopyString
				_lFNPCopyStringEX:
				movsw
				jmp	_lFNPCopyStringSX

				_lFNPCopyStringFN:
				sub	edi,			02h
				add	esi,			02h
				mov	ecx,			dword ptr [_dLastStructName]
				xor	eax,			eax
				test	ecx,			ecx
				jz	_lFNPCopyStringFNDX

				_lFNPCopyStringFNSX:
				mov	al,			byte ptr [ecx]
				cmp	byte ptr [_bAscii_00+eax],		ah
				je	_lFNPCopyStringFNMX
				stosb
				inc	ecx
				jmp	_lFNPCopyStringFNSX
				_lFNPCopyStringFNMX:
				mov	byte ptr [edi],		2eh	;; .
				inc	edi

				_lFNPCopyStringFNDX:
				mov	ecx,			dword ptr [_dLastFuncName]
				_lFNPCopyStringFNFX:
				mov	al,			byte ptr [ecx]
				cmp	byte ptr [_bAscii_00+eax],		ah
				je	_lFNPCopyString
				stosb
				inc	ecx
				jmp	_lFNPCopyStringFNFX
				;;----------------

			_lbl:
			cmp	cx,			3d2bh		;; +=
			jne	_next
			mov	al,			2bh		;; +
			jmp	_lFNPPx

			_lbl:
			cmp	cx,			3d2dh		;; -=
			jne	_next
			mov	al,			2dh		;; -
			jmp	_lFNPPx

			_lbl:
			cmp	cx,			3d2ah		;; *=
			jne	_next
			mov	al,			2ah		;; *
			jmp	_lFNPPx

			_lbl:
			cmp	cx,			3d2fh		;; /=
			jne	_next
			mov	al,			2fh		;; /

				;;----------------
				;; += -= *= /=

					;;----------------
					;; scan
					_lFNPPx:
					cmp	byte ptr [edi-01h],	5dh		;; ]
					jne	_lFNPPxNorm

					mov	ecx,			edi
					xor	edx,			edx

					_lFNPPxSS:
					dec	ecx
					cmp	byte ptr [ecx],		5bh		;; [
					jne	_lFNPPxDD
					dec	ah
					jmp	_lFNPPxSS

					_lFNPPxDD:
					cmp	byte ptr [ecx],		5dh		;; ]
					jne	_lFNPPxFF
					inc	ah
					jmp	_lFNPPxSS

					_lFNPPxFF:
					cmp	word ptr [ecx],		0a0dh		;; nl
					je	_lFNPPxNorm
;; cmp	byte ptr [ecx], 00h
;; je ...
					cmp	byte ptr [ecx],		28h		;; (
					jne	_lFNPPxSS

					mov	dl,			byte ptr [ecx-01h]
					cmp	byte ptr [_bAscii_00+edx],		dh
					je	_lFNPPxSS

						;;----------------
						;; ex index
						mov	ebp,			esp
						push	ebx
						mov	ebx,			dword ptr [ebp]

						_lFNPPxII:
						dec	ecx
						cmp	byte ptr [ecx],		5dh		;; ]
						jne	_lFNPPxII_00
						inc	ah
						jmp	_lFNPPxII

						_lFNPPxII_00:
						cmp	byte ptr [ecx],		5bh		;; [
						jne	_lFNPPxII
						dec	ah
						jnz	_lFNPPxII

						mov	edx,			dword ptr [_dFCPL]
						inc	ecx

						inc	byte ptr [_bFCLL]
						mov	dword ptr [edx],	20746573h	;; set_
						mov	ah,			byte ptr [_bFCLL]
						mov	dword ptr [edx+04h],	3d207871h	;; qx_=
						mov	byte ptr [edx+06h],	ah
						add	edx,			08h

						_lFNPPxII_01:
						mov	ah,			byte ptr [ecx]
						mov	byte ptr [edx],		ah
						mov	byte ptr [ecx],		20h
						cmp	ebx,			ecx
						jne	_lFNPPxII_SC
						mov	dword ptr [ebp],	edx
						sub	ebp,			04h
						mov	ebx,			dword ptr [ebp]

						_lFNPPxII_SC:
						inc	edx
						inc	ecx
						cmp	ecx,			edi
						jne	_lFNPPxII_01

						mov	ah,			byte ptr [_bFCLL]
						mov	word ptr [edx-01h],	0a0dh
						mov	dword ptr [edi-04h],	5d207871h	;; qx*]
						inc	edx
						mov	byte ptr [edi-02h],	ah

						mov	dword ptr [_dFCPL],	edx
						pop	ebx
						;;----------------
					;;----------------

					;;----------------
					;; norm
					_lFNPPxNorm:
					mov	edx,			edi
					movsb					;; =
					mov	ecx,			esi
					_lFNPPxEX:
					inc	ecx
					cmp	word ptr [ecx],		0a0dh	;; nl
					jne	_lFNPPxEX
					mov	word ptr [ecx],		3101h	;; #1
					lea	ecx,			[edi-01h]
					_lFNPPxSX:
					dec	edx
					cmp	dword ptr [edx-04h],	20746573h	;; set_
					jne	_lFNPPxSX
					_lFNPPxDX:
					mov	ah,			byte ptr [edx]
					mov	byte ptr [edi],		ah
					inc	edx
					inc	edi
					cmp	edx,			ecx
					jb	_lFNPPxDX
					mov	byte ptr [edi],		al
					mov	byte ptr [edi+01h],	28h
					add	edi,			02h
					xor	eax,			eax
					jmp	_lFNPCopyParseNext
					;;----------------
				;;----------------

				;;----------------
				_lbl:
				cmp	cl,				0eh		;; ;
				jne	_next

				mov	dword ptr [_dVarParams],	edi
				mov	word ptr [edi],			0a0dh		;; nl
				dec	esi
				add	edi,				02h
				mov	byte ptr [esi],			0ch		;; ;
				test	ebx,				01b
				jp	_lFNPLine
				jmp	_lFNPIncDecSTX
				;;----------------

			_lbl:
			cmp	cx,			0a0dh		;; new line
			jne	_next
			mov	dword ptr [edi],	0a0dh		;; new line
			inc	esi
			add	edi,			02h
			test	ebx,			01b
			jp	_lFNPLine

				;;----------------
				;; ++ -- in stack
				_lFNPIncDecSTX:
				mov	dword ptr [_dBuffer],	esi
				mov	esi,			edi
				mov	edi,			dword ptr [_dFCB]

				_lFNPIncDecSTXNext:
				cmp	dword ptr [esp],	00h
				je	_lFNPIncDecSTXEnd

				pop	ebp
				xor	eax,			eax
				xor	edx,			edx
				mov	al,			byte ptr [ebp]
				mov	ecx,			ebp			;; ecx = operation position

				cmp	byte ptr [_bAscii_03+eax],		ah
				jz	_lFNPIDS_00p

					;;----------------
					;; pref

						;;----------------
						;; scan
						_lFNPIDS_00:
						inc	ecx
						mov	al,			byte ptr [ecx]

						cmp	al,			5bh		;; [
						jne	_lFNPIDS_01
						inc	edx
						jmp	_lFNPIDS_00

						_lFNPIDS_01:
						cmp	al,			28h		;; (
						jne	_lFNPIDS_02
						mov	al,			byte ptr [ecx-01h]
						cmp	byte ptr [_bAscii_00+eax],		ah
						jne	_lFNPIDEI
						jmp	_lFNPIDS_00

						_lFNPIDS_02:
						cmp	al,			5dh		;; ]
						jne	_lFNPIDS_03
						test	edx,			edx
						jz	_lFNPIDS_04
						dec	edx
						jnz	_lFNPIDS_00
						jmp	_lFNPIDS_04

						_lFNPIDS_03:
						cmp	byte ptr [_bAscii_03+eax],		ah
						jne	_lFNPIDS_00

						_lFNPIDS_04:
						mov	ecx,			ebp
						;;----------------

						;;----------------
						;; norm
						_lFNPIncDecSTX_Norm:
						mov	dword ptr [edi],	20746573h	;; set_
						add	edi,			04h
						jmp	_lFNPIncDecSTXPre

						_lFNPIncDecSTXPreNext:
						inc	ebp
						_lFNPIncDecSTXPre:
						mov	al,			byte ptr [ebp]
						cmp	al,			5bh		;; [
						jne	_lFNPIncDecSTXPre_00
						inc	edx
						jmp	_lFNPIncDecSTXPre_02
						_lFNPIncDecSTXPre_00:
						test	edx,			edx
						jnz	_lFNPIncDecSTXPre_03
						cmp	byte ptr [_bAscii_03+eax],		ah
						jne	_lFNPIncDecSTXPre_02
						_lFNPIncDecSTXPre_01:
						mov	edx,			ecx
						sub	ecx,			ebp
						neg	ecx

						mov	ebp,			edi
						mov	byte ptr [edi],		3dh		;; =
						inc	edi

						_lFNPIncDecSTXCopyNext:
						mov	al,			byte ptr [edx]
						inc	edx
						mov	byte ptr [edi],		al
						inc	edi
						dec	ecx
						jnz	_lFNPIncDecSTXCopyNext
						pop	eax
						or	eax,			0a0d3100h	;; x 1 new line
						mov	dword ptr [edi],	eax
						add	edi,			04h
						jmp	_lFNPIncDecSTXNext

						_lFNPIncDecSTXPre_02:
						mov	byte ptr [edi],		al
						inc	edi
						jmp	_lFNPIncDecSTXPreNext

						_lFNPIncDecSTXPre_03:
						cmp	al,			5dh		;; ]
						jne	_lFNPIncDecSTXPre_02
						dec	edx
						jmp	_lFNPIncDecSTXPre_02
						;;----------------

						;;----------------
						;; ex index
						_lFNPIDEI:
						inc	byte ptr [_bFCLL]
						mov	ecx,			ebp
						xor	edx,			edx
						mov	al,			byte ptr [_bFCLL]

						mov	dword ptr [edi],	20746573h	;; set_
						mov	dword ptr [edi+04h],	3d207871h	;; qx_=
						mov	byte ptr [edi+06h],	al
						add	edi,			08h

						_lFNPIDEIndexSet:
						inc	ecx
						cmp	byte ptr [ecx],		5bh		;; [
						jne	_lFNPIDEIndexSet
						inc	ecx

						_lFNPIDEIndexSetEX:
						mov	ah,			byte ptr [ecx]
						cmp	ah,			5bh		;; [
						jne	_lFNPIDEIndexSetFX
						inc	edx
						jmp	_lFNPIDEIndexSetCopy

						_lFNPIDEIndexSetFX:
						cmp	ah,			5dh		;; ]
						jne	_lFNPIDEIndexSetCopy
						dec	edx
						jns	_lFNPIDEIndexSetCopy

						mov	word ptr [edi],		0a0dh		;; nl
						mov	word ptr [ecx-03h],	7871h		;; qx
						mov	byte ptr [ecx-01h],	al
						add	edi,			02h
						xor	edx,			edx
						mov	ecx,			ebp
						xor	eax,			eax
						jmp	_lFNPIncDecSTX_Norm

						_lFNPIDEIndexSetCopy:
						mov	byte ptr [ecx],		20h		;; bs
						mov	byte ptr [edi],		ah
						inc	ecx
						inc	edi
						jmp	_lFNPIDEIndexSetEX
						;;----------------
					;;----------------

					;;----------------
					;; post

						;;----------------
						;; scan
						_lFNPIDS_00p:
						dec	ecx
						mov	al,			byte ptr [ecx]

						cmp	al,			5dh		;; ]
						jne	_lFNPIDS_01p
						inc	edx
						jmp	_lFNPIDS_00p

						_lFNPIDS_01p:
						cmp	al,			5bh		;; [
						jne	_lFNPIDS_02p
						test	edx,			edx
						jz	_lFNPIDS_04p
						dec	edx
						js	_lFNPIDS_04p
						jmp	_lFNPIDS_00p

						_lFNPIDS_02p:
						cmp	al,			28h		;; (
						jne	_lFNPIDS_03p
						test	edx,			edx
						jz	_lFNPIDS_04p
						mov	al,			byte ptr [ecx-01h]
						cmp	byte ptr [_bAscii_00+eax],		ah
						je	_lFNPIDS_00p
						jmp	_lFNPIDEIp

						_lFNPIDS_03p:
						cmp	byte ptr [_bAscii_03+eax],		ah
						jne	_lFNPIDS_00p
						test	edx,			edx
						jnz	_lFNPIDS_00p

						_lFNPIDS_04p:
						mov	ecx,			ebp
						;;----------------

						;;----------------
						;; norm
						_lFNPIncDecSTXPost:
						mov	byte ptr [_bCodePosOp],	01h		;; post operation = 1
						_lFNPIncDecSTXPostNext:
						dec	ebp
						mov	al,			byte ptr [ebp]
						cmp	al,			5dh		;; ]
						jne	_lFNPIncDecSTXPost_00
						inc	edx
						jmp	_lFNPIncDecSTXPostNext
						_lFNPIncDecSTXPost_00:
						cmp	byte ptr [_bAscii_03+eax],		ah
						jnz	_lFNPIncDecSTXPostNext
						test	edx,			edx
						jz	_lFNPIncDecSTXPost_01
						cmp	al,			5bh		;; [
						jne	_lFNPIncDecSTXPostNext
						dec	edx
						jmp	_lFNPIncDecSTXPostNext

						_lFNPIncDecSTXPost_01:
						inc	ebp
						sub	ecx,			ebp
						lea	edx,			[ecx+01h]
						mov	dword ptr [esi],	20746573h	;; set_
						add	esi,			04h

						_lFNPIncDecSTXCopyEX:
						mov	al,			byte ptr [ebp]
						inc	ebp
						mov	byte ptr [esi],		al
						mov	byte ptr [esi+edx],	al
						inc	esi
						dec	ecx
						jnz	_lFNPIncDecSTXCopyEX
						mov	byte ptr [esi],		3dh		;; =
						add	esi,			edx
						pop	eax
						or	eax,			0a0d3100h	;; x 1 new line
						mov	dword ptr [esi],	eax
						add	esi,			04h
						jmp	_lFNPIncDecSTXNext
						;;----------------

						;;----------------
						;; ex index
						_lFNPIDEIpEX:
						inc	edx
						_lFNPIDEIp:
						dec	ecx
						cmp	byte ptr [ecx],		5dh		;; ]
						je	_lFNPIDEIpEX
						cmp	byte ptr [ecx],		5bh		;; [
						jne	_lFNPIDEIp
						dec	edx
						jnz	_lFNPIDEIp

						inc	byte ptr [_bFCLL]
;						push	edi
						mov	al,			byte ptr [_bFCLL]
;						mov	edi,			dword ptr [_dFCPL]

						mov	dword ptr [edi],	20746573h	;; set_
						mov	dword ptr [edi+04h],	3d207871h	;; qx_=
						mov	byte ptr [edi+06h],	al
						add	edi,			08h
						lea	edx,			[ebp-01h]

						_lFNPIDEIndexSetp:
						inc	ecx
						mov	ah,			byte ptr [ecx]
						mov	byte ptr [edi],		ah
						inc	edi
						mov	byte ptr [ecx],		20h		;; bs
						cmp	ecx,			edx
						jne	_lFNPIDEIndexSetp

						inc	ecx
						mov	word ptr [edi-01h],	0a0dh
						mov	dword ptr [ebp-04h],	5d207871h	;; qx*]
						inc	edi
						mov	byte ptr [ebp-02h],	al
						xor	eax,			eax
;						mov	dword ptr [_dFCPL],	edi
;						pop	edi
						xor	edx,			edx
						jmp	_lFNPIncDecSTXPost
						;;----------------
					;;----------------

					;;----------------
					;; copy code
					_lFNPIncDecSTXEnd:

						;;----------------
						cmp	byte ptr [_bCodeSys],		00h
						je	_lFNPIncDecSTXEndDD

						cmp	byte ptr [_bCodePosOp],		00h
						je	_lFNPIncDecSTXEndFL

						mov	eax,				offset _bFuncCodeOneLine

						cmp	word ptr [eax],			6669h		;; if
						jne	_lFNPEXExit

							;;----------------
							;; if
;							mov	byte ptr [_bTempBool],		01h
							mov	dword ptr [eax],		20746573h	;; set_
							mov	dword ptr [eax+04h],		765f6a63h	;; cj_v
							mov	dword ptr [eax+08h],		5f363636h	;; 666_
							mov	word ptr [eax+0ch],		3d62h		;; b=

							mov	dword ptr [esi],		63206669h	;; if_c
							mov	dword ptr [esi+04h],		36765f6ah	;; j_v6
							mov	dword ptr [esi+08h],		625f3636h	;; 66_b
							mov	dword ptr [esi+0ch],		65687420h	;; _the
							mov	dword ptr [esi+10h],		000a0d6eh	;; en__

							add	esi,				13h

							_lFNPIncDecSTXEndRemThen:
							inc	eax
							cmp	dword ptr [eax],		6e656874h	;; then
							jne	_lFNPIncDecSTXEndRemThen
							cmp	word ptr [eax+04h],		0a0dh		;; nl
							jne	_lFNPIncDecSTXEndRemThen
							mov	dword ptr [eax],		20202020h	;; bs
							jmp	_lFNPIncDecSTXEndFL
							;;----------------

							;;----------------
							;; exitwhen
							_lFNPEXExit:
							cmp	dword ptr [eax],		74697865h	;; exit
							jne	_lFNPEXRetn

							mov	dword ptr [eax],		20746573h	;; set_
							mov	dword ptr [eax+04h],		765f6a63h	;; cj_v
							mov	dword ptr [eax+08h],		5f363636h	;; 666_
							mov	word ptr [eax+0ch],		3d62h		;; b=

							mov	byte ptr [_bTempBool],		01h

							mov	dword ptr [esi],		74697865h	;; exit
							mov	dword ptr [esi+04h],		6e656877h	;; when
							mov	dword ptr [esi+08h],		5f6a6320h	;; _cj_
							mov	dword ptr [esi+0ch],		36363676h	;; v666
							mov	dword ptr [esi+10h],		0a0d625fh	;; _b__

							add	esi,				14h

							jmp	_lFNPIncDecSTXEndFL
							;;----------------

							;;----------------
							;; return
							_lFNPEXRetn:
;							mov	byte ptr [_bTempType],		01h
							mov	dword ptr [eax],		20746573h	;; set_
							mov	dword ptr [eax+04h],		765f6a63h	;; cj_v
							mov	dword ptr [eax+08h],		5f363636h	;; 666_
							mov	word ptr [eax+0ch],		3d72h	;; r=

							mov	dword ptr [esi],		75746572h	;; retu
							mov	dword ptr [esi+04h],		63206e72h	;; rn_c
							mov	dword ptr [esi+08h],		36765f6ah	;; j_v6
							mov	dword ptr [esi+0ch],		725f3636h	;; 66_r
							mov	word ptr [esi+10h],		0a0dh		;; nl

							add	esi,				12h
							;;----------------

						_lFNPIncDecSTXEndFL:
						mov	byte ptr [_bCodeSys],	00h
						;;----------------

						;;----------------
						_lFNPIncDecSTXEndDD:
						mov	edx,			esi

						mov	ecx,			dword ptr [_dFCPL]
						mov	esi,			offset _bFuncPostEX
						sub	ecx,			esi
						rep	movsb
						mov	dword ptr [_dFCPL],	offset _bFuncPostEX

							;;----------------
							;; code nop
							cmp	byte ptr [_bFuncCodeNop],		02h
							je	_lIsCodeNop_End
							cmp	byte ptr [_bFuncCodeNop],		01h
							jne	_lIsCodeNop_Check

							mov	byte ptr [_bFuncCodeNop],		02h
							jmp	_lIsCodeNop_End

							_lIsCodeNop_Check:
							cmp	dword ptr [_bFuncCodeOneLine],		"olbv"
							jne	_lIsCodeNop_Ex
							cmp	word ptr [_bFuncCodeOneLine + 04h],	"kc"
							jne	_lIsCodeNop_Ex
							cmp	byte ptr [_bFuncCodeOneLine + 06h],	20h
							jbe	_lIsCodeNop_End

							_lIsCodeNop_Ex:
							cmp	dword ptr [_bFuncCodeOneLine],		"vdne"
							jne	_lIsCodeNop_Fx
							cmp	dword ptr [_bFuncCodeOneLine + 04h],	"colb"
							jne	_lIsCodeNop_Fx
							cmp	byte ptr [_bFuncCodeOneLine + 08h],	"k"
							jne	_lIsCodeNop_Fx
							cmp	byte ptr [_bFuncCodeOneLine + 09h],	20h
							jbe	_lIsCodeNop_End

							_lIsCodeNop_Fx:
							mov	byte ptr [_bFuncCodeNop],		01h

							_lIsCodeNop_End:
							;;----------------

							;;----------------
							;; locals
							cmp	dword ptr [_bFuncCodeOneLine],		61636f6ch	;; loca
							jne	_lFNPIncDecSTXEndSFXD_Pre
							cmp	word ptr [_bFuncCodeOneLine+04h],	206ch		;; l_
							jne	_lFNPIncDecSTXEndSFXD_Pre

							mov	dword ptr [_dFCB],			edi
							mov	edi,					dword ptr [_dFCL]
							mov	esi,					offset _bFuncCodeOneLine
							cmp	dword ptr [_dFCB],			offset _bFuncCodeBase
							jne	_lFNPLoc_06

								;;----------------
								;; norm
								_lFNPLoc_00:
								cmp	word ptr [esi],			0a0dh		;; nl
								je	_lFNPLoc_01
								movsb
								jmp	_lFNPLoc_00						

								_lFNPLoc_01:
								movsw
								mov	dword ptr [_dFCL],		edi
								mov	edi,				dword ptr [_dFCB]
								jmp	_lFNPIncDecSTXEndSFXD
								;;----------------

;;----------------
;; in block
_lFNPLoc_06:
cmp	dword ptr [_dInFuncBlockPnt],	offset _dInFuncBlockStack + 04h
je	_lFNPLoc_02

cmp	dword ptr [esi + 06h],		"tats"
jne	_lFNPLoc_06_ESX
cmp	dword ptr [esi + 09h],		" cit"
je	_lFNPLoc_02

_lFNPLoc_06_ESX:
push	edx
push	ebx
xor	eax,				eax

mov	ecx,				offset _bFuncCodeLocals

	;;----------------
	;; check other variables
	_lFNPLoc_GG:
	cmp	ecx,				dword ptr [_dFCL]
	jge	_lFNPLoc_GG_New

	cmp	word ptr [ecx],			4d23h		;; #M
	jne	_lFNPLoc_GG_GetNext
	cmp	byte ptr [ecx + 02h],		00h		;; #Mabbbb
	jne	_lFNPLoc_GG_GetNext

	mov	edx,				ecx
	mov	ebx,				offset _bFuncCodeOneLine + 06h
	add	ecx,				0fh

	_lFNPLoc_GG_CheckType:
	mov	al,				byte ptr [ecx]
	cmp	byte ptr [_bAscii_00 + eax],	ah
	je	_lFNPLoc_GG_CheckType_00
	cmp	al,				byte ptr [ebx]
	jne	_lFNPLoc_GG_GetNext
	inc	ecx
	inc	ebx
	jmp	_lFNPLoc_GG_CheckType

	_lFNPLoc_GG_CheckType_00:
	cmp	byte ptr [ebx],			20h
	jne	_lFNPLoc_GG_GetNext

	;; array?
	cmp	dword ptr [ecx + 01h],		"arra"
	jne	_lFNPLoc_GG_NoArray
	cmp	dword ptr [ebx + 01h],		"arra"
	jne	_lFNPLoc_GG_GetNext
	cmp	word ptr [ebx + 05h],		" y"
	jne	_lFNPLoc_GG_GetNext
	add	ecx,				06h
	add	ebx,				06h
	jmp	_lFNPLoc_GG_Use

	_lFNPLoc_GG_NoArray:
	cmp	dword ptr [ebx + 01h],		"arra"
	jne	_lFNPLoc_GG_Use
	cmp	word ptr [ebx + 05h],		" y"
	je	_lFNPLoc_GG_GetNext

		;;----------------
		;; use founded variable
		_lFNPLoc_GG_Use:
		mov	byte ptr [edx + 02h],		01h
		mov	eax,				dword ptr [_dInFuncBlockPnt]
		sub	eax,				04h
		mov	eax,				dword ptr [eax]
		mov	dword ptr [edx + 03h],		eax

		mov	edi,				dword ptr [_dFCB]
		mov	word ptr [edi],			4e23h		;; #N

		mov	dword ptr [edi + 02h],		"oljc"
		mov	dword ptr [edi + 06h],		"_ngc"

		mov	eax,				dword ptr [ecx + 09h]
		mov	dword ptr [edi + 0ah],		eax
		mov	eax,				dword ptr [ecx + 0dh]
		mov	dword ptr [edi + 0eh],		eax

		mov	byte ptr [edi + 12h],		" "
		add	edi,				13h

		inc	ebx
		xor	eax,				eax
		push	ebx						;; ebx = name

		_lFNPLoc_GG_UseCopyName:
		mov	al,				byte ptr [ebx]
		cmp	byte ptr [_bAscii_00 + eax],	ah
		je	_lFNPLoc_GG_UseCopyNameEnd
		mov	byte ptr [edi],			al
		inc	ebx
		inc	edi
		jmp	_lFNPLoc_GG_UseCopyName

		_lFNPLoc_GG_UseCopyNameEnd:
		mov	word ptr [edi],			0a0dh
		add	edi,				02h
		cmp	byte ptr [ebx],			"="
		pop	ebx						;; ebx - var name
		jne	_lFNPLoc_GG_UseCopyNameCorrect

		mov	dword ptr [edi],		" tes"
		add	edi,				04h
		mov	esi,				ebx			
		jmp	_lFNPLoc_GG_End

		_lFNPLoc_GG_UseCopyNameCorrect:
		inc	ebx
		cmp	word ptr [ebx - 02h],		0a0dh
		jne	_lFNPLoc_GG_UseCopyNameCorrect
		jmp	_lFNPLoc_GG_End
		;;----------------


	_lFNPLoc_GG_GetNext:
	inc	ecx
	cmp	word ptr [ecx - 02h],		0a0dh
	jne	_lFNPLoc_GG_GetNext
	jmp	_lFNPLoc_GG
	;;----------------

	;;----------------
	;; generate new var
	_lFNPLoc_GG_New:
mov	byte ptr [_bLocGenPreInit],	00h

	mov	word ptr [edi],			4d23h		;; #M
	mov	byte ptr [edi + 02h],		01h
;	mov	eax,				dword ptr [_dGeneratedLocalsID]
mov	eax,				dword ptr [_dInFuncBlockPnt]
sub	eax,				04h
mov	eax,				dword ptr [eax]
	mov	dword ptr [edi + 03h],		eax
	mov	word ptr [edi + 07h],		0a0dh
	mov	dword ptr [edi + 09h],		"acol"
	mov	word ptr [edi + 0dh],		" l"

	add	edi,				0fh

	;; copy type and array keyword
	mov	ebx,				offset _bFuncCodeOneLine + 06h
	_lFNPLoc_GG_New_CopyType:
	mov	al,				byte ptr [ebx]
	cmp	al,				" "
	je	_lFNPLoc_GG_New_CopyTypeEnd
	mov	byte ptr [edi],			al
	inc	ebx
	inc	edi
	jmp	_lFNPLoc_GG_New_CopyType

	_lFNPLoc_GG_New_CopyTypeEnd:
	cmp	dword ptr [ebx + 01h],		"arra"
	jne	_lFNPLoc_GG_New_CopyTypeNext
	cmp	word ptr [ebx + 05h],		" y"
	jne	_lFNPLoc_GG_New_CopyTypeNext
	mov	dword ptr [edi],		"rra "
	mov	word ptr [edi + 04h],		"ya"
	add	ebx,				06h
	add	edi,				06h

	_lFNPLoc_GG_New_CopyTypeNext:
	inc	ebx						;; ebx - var name
	mov	dword ptr [edi],		"ljc "
	mov	dword ptr [edi + 04h],		"ngco"
	mov	byte ptr [edi + 08h],		"_"

	inc	dword ptr [_dGeneratedLocalsID]

	mov	edx,				dword ptr [_dGeneratedLocalsID]
	and	edx,				0ff000000h
	shr	edx,				17h
	mov	ax,				word ptr [edx + _bIntToHexStr]
	mov	word ptr [edi + 09h],		ax
	mov	edx,				dword ptr [_dGeneratedLocalsID]
	and	edx,				00ff0000h
	shr	edx,				0fh
	mov	ax,				word ptr [edx + _bIntToHexStr]
	mov	word ptr [edi + 0bh],		ax
	mov	edx,				dword ptr [_dGeneratedLocalsID]
	and	edx,				0000ff00h
	shr	edx,				07h
	mov	ax,				word ptr [edx + _bIntToHexStr]
	mov	word ptr [edi + 0dh],		ax
	mov	edx,				dword ptr [_dGeneratedLocalsID]
	and	edx,				000000ffh
	shl	edx,				01h
	mov	ax,				word ptr [edx + _bIntToHexStr]
	mov	word ptr [edi + 0fh],		ax

	add	edi,				11h

		;;----------------
		;; ex initialized
		push	ebx
		_lFNPLoc_GG_New_ExInitCheck:
		inc	ebx
		cmp	byte ptr [ebx],			"="
		je	_lFNPLoc_GG_New_ExInitCheckOk
		cmp	word ptr [ebx],			0a0dh
		jne	_lFNPLoc_GG_New_ExInitCheck
		jmp	_lFNPLoc_GG_New_ExInit_EndPre

		_lFNPLoc_GG_New_ExInitCheckOk:
		pop	ebx

		cmp	byte ptr [_bFuncCodeNop],	02h
		je	_lFNPLoc_GG_New_ExInit

		push	ebx
		jmp	_lFNPLoc_GG_New_ExInit_Do

		_lFNPLoc_GG_New_ExInit:
		cmp	byte ptr [_bInVblock],		00h
		je	_lFNPLoc_GG_New_ExInit_End
		cmp	dword ptr [_dInFuncBlockPnt],	offset _dInFuncBlockStack + 08h
		jne	_lFNPLoc_GG_New_ExInit_End

		push	ebx
		xor	eax,				eax
		_lFNPLoc_GG_New_ExInit_GetVal:
		inc	ebx
		cmp	word ptr [ebx],			0a0dh
		je	_lFNPLoc_GG_New_ExInit_EndPre
		cmp	byte ptr [ebx],			"="
		jne	_lFNPLoc_GG_New_ExInit_GetVal

			;;----------------
			;; scan
			_lFNPLoc_GG_New_ExInit_Scan:
			inc	ebx

			_lFNPLoc_GG_New_ExInit_ScanEx:
			cmp	word ptr [ebx],			0a0dh
			je	_lFNPLoc_GG_New_ExInit_Do

			mov	al,				byte ptr [ebx]
			cmp	al,				22h	;; "
			je	_lFNPLoc_GG_New_ExInit_Str

			cmp	al,				30h
			jb	_lFNPLoc_GG_New_ExInit_Scan

			cmp	al,				3ah
			jb	_lFNPLoc_GG_New_ExInit_Dgt

			cmp	byte ptr [_bAscii_00 + eax],	ah
			je	_lFNPLoc_GG_New_ExInit_Scan

				;;----------------
				;; check word
				mov	ebp,				offset _sCodeConst
				push	ebx

				_lFNPLoc_GG_New_ExInit_Word:
				mov	al,				byte ptr [ebx]
				cmp	byte ptr [ebp],			al
				jne	_lFNPLoc_GG_New_ExInit_WordNext
				inc	ebx
				inc	ebp
				jmp	_lFNPLoc_GG_New_ExInit_Word

				_lFNPLoc_GG_New_ExInit_WordNext:
				cmp	byte ptr [_bAscii_00 + eax],	ah
				jne	_lFNPLoc_GG_New_ExInit_WordNextEx
				cmp	byte ptr [ebp],			ah
				jne	_lFNPLoc_GG_New_ExInit_WordNextEx

				add	esp,				04h
				jmp	_lFNPLoc_GG_New_ExInit_ScanEx

				_lFNPLoc_GG_New_ExInit_WordNextEx:
				mov	ebx,				dword ptr [esp]
				_lFNPLoc_GG_New_ExInit_WordNextSx:
				inc	ebp
				cmp	byte ptr [ebp],			ah
				jne	_lFNPLoc_GG_New_ExInit_WordNextSx

				inc	ebp
				cmp	byte ptr [ebp],			00h
				jne	_lFNPLoc_GG_New_ExInit_Word

				pop	ebx
				jmp	_lFNPLoc_GG_New_ExInit_EndPre
				;;----------------

			_lFNPLoc_GG_New_ExInit_Dgt:
			inc	ebx
			mov	al,				byte ptr [ebx]
			cmp	byte ptr [_bAscii_00 + eax],	ah
			jne	_lFNPLoc_GG_New_ExInit_Dgt
			jmp	_lFNPLoc_GG_New_ExInit_ScanEx

			_lFNPLoc_GG_New_ExInit_Str:
			inc	ebx
			_lFNPLoc_GG_New_ExInit_StrDx:
			cmp	byte ptr [ebx],			5ch	;; \ 
			jne	_lFNPLoc_GG_New_ExInit_StrEx
			add	ebx,				02h
			jmp	_lFNPLoc_GG_New_ExInit_StrDx
			_lFNPLoc_GG_New_ExInit_StrEx:
			cmp	byte ptr [ebx],			22h	;; "
			jne	_lFNPLoc_GG_New_ExInit_Str
			jmp	_lFNPLoc_GG_New_ExInit_Scan
			;;----------------

			;;----------------
			;; ex init
			_lFNPLoc_GG_New_ExInit_Do:
			mov	byte ptr [_bLocGenPreInit],	01h
			mov	ebx,				dword ptr [esp]

			_lFNPLoc_GG_New_ExInit_DoEx:
			inc	ebx
			cmp	byte ptr [ebx],			"="
			jne	_lFNPLoc_GG_New_ExInit_DoEx

			_lFNPLoc_GG_New_ExInit_DoCopy:
			mov	al,				byte ptr [ebx]
			mov	byte ptr [edi],			al
			inc	ebx
			inc	edi
			cmp	word ptr [ebx],			0a0dh
			jne	_lFNPLoc_GG_New_ExInit_DoCopy
			;;----------------

		_lFNPLoc_GG_New_ExInit_EndPre:
		pop	ebx

		_lFNPLoc_GG_New_ExInit_End:
		;;----------------

	mov	word ptr [edi],			0a0dh
	add	edi,				02h
	mov	dword ptr [_dFCL],		edi

	;; add special instruction
	mov	edi,				dword ptr [_dFCB]
	mov	word ptr [edi],			4e23h		;; #N

	mov	dword ptr [edi + 02h],		"oljc"
	mov	dword ptr [edi + 06h],		"_ngc"
	mov	edx,				dword ptr [_dGeneratedLocalsID]
	and	edx,				0ff000000h
	shr	edx,				17h
	mov	ax,				word ptr [edx + _bIntToHexStr]
	mov	word ptr [edi + 0ah],		ax
	mov	edx,				dword ptr [_dGeneratedLocalsID]
	and	edx,				00ff0000h
	shr	edx,				0fh
	mov	ax,				word ptr [edx + _bIntToHexStr]
	mov	word ptr [edi + 0ch],		ax
	mov	edx,				dword ptr [_dGeneratedLocalsID]
	and	edx,				0000ff00h
	shr	edx,				07h
	mov	ax,				word ptr [edx + _bIntToHexStr]
	mov	word ptr [edi + 0eh],		ax
	mov	edx,				dword ptr [_dGeneratedLocalsID]
	and	edx,				000000ffh
	shl	edx,				01h
	mov	ax,				word ptr [edx + _bIntToHexStr]
	mov	word ptr [edi + 10h],		ax
	mov	word ptr [edi + 12h],		" "
	add	edi,				13h

	push	ebx
	xor	eax,				eax

	_lFNPLoc_GG_New_CopyName:
	mov	al,				byte ptr [ebx]
	cmp	byte ptr [_bAscii_00 + eax],	ah
	je	_lFNPLoc_GG_New_CopyNameEnd
	mov	byte ptr [edi],			al
	inc	ebx
	inc	edi
	jmp	_lFNPLoc_GG_New_CopyName

	_lFNPLoc_GG_New_CopyNameEnd:
	mov	word ptr [edi],			0a0dh
	add	edi,				02h
	cmp	byte ptr [ebx],			"="
	pop	ebx						;; ebx - var name
	je	_lFNPLoc_GG_New_SetPre

_lFNPLoc_GG_New_Null:
inc	ebx
cmp	word ptr [ebx - 02h],		0a0dh
jne	_lFNPLoc_GG_New_Null
jmp	_lFNPLoc_GG_End
	
_lFNPLoc_GG_New_SetPre:
cmp	byte ptr [_bLocGenPreInit],	00h
je	_lFNPLoc_GG_New_Set
jmp	_lFNPLoc_GG_New_Null

_lFNPLoc_GG_New_Set:
	mov	dword ptr [edi],		" tes"
	add	edi,				04h
	;;----------------

_lFNPLoc_GG_End:
mov	esi,				ebx
pop	ebx
pop	edx

jmp	_lFNPIncDecSTXEndSFXD
;;----------------

								;;----------------
								;; ex
								_lFNPLoc_02:
								cmp	word ptr [esi],			0a0dh		;; nl
								je	_lFNPLoc_01
								cmp	byte ptr [esi],			3dh		;; =
								je	_lFNPLoc_03

								movsb
								jmp	_lFNPLoc_02

									;;----------------
									;; scan
									_lFNPLoc_03:
									mov	ecx,				esi
									xor	eax,				eax

									_lFNPLoc_03_AX:
									inc	ecx

									_lFNPLoc_03_AXX:
									cmp	word ptr [ecx],			0a0dh
									je	_lFNPLoc_00

									_lFNPLoc_03_BX:
									mov	al,				byte ptr [ecx]
									cmp	al,				22h	;; "
									je	_lFNPLoc_03_Str

									cmp	al,				30h
									jb	_lFNPLoc_03_AX
									cmp	al,				3ah
									jb	_lFNPLoc_03_Dgt
									cmp	byte ptr [_bAscii_00+eax],	ah
									je	_lFNPLoc_03_AX

										;;----------------
										;; check word
										mov	ebp,				offset _sCodeConst
										push	ecx

										_lFNPLoc_03_Word:
										mov	al,				byte ptr [ecx]
										cmp	byte ptr [ebp],			al
										jne	_lFNPLoc_03_WordNext
										inc	ecx
										inc	ebp
										jmp	_lFNPLoc_03_Word

										_lFNPLoc_03_WordNext:
										cmp	byte ptr [_bAscii_00+eax],	ah
										jne	_lFNPLoc_03_WordNextFX
										cmp	byte ptr [ebp],			ah
										jne	_lFNPLoc_03_WordNextFX

										add	esp,				04h
										jmp	_lFNPLoc_03_AXX

										_lFNPLoc_03_WordNextFX:
										mov	ecx,				dword ptr [esp]
										_lFNPLoc_03_WordNextEX:
										inc	ebp
										cmp	byte ptr [ebp],			ah
										jne	_lFNPLoc_03_WordNextEX

										inc	ebp
										cmp	byte ptr [ebp],			00h
										jne	_lFNPLoc_03_Word

										pop	ecx
										jmp	_lFNPLoc_05
										;;----------------

									_lFNPLoc_03_Dgt:
									inc	ecx
									mov	al,			byte ptr [ecx]
									cmp	byte ptr [_bAscii_00+eax],	ah
									jne	_lFNPLoc_03_Dgt
									jmp	_lFNPLoc_03_AXX

									_lFNPLoc_03_Str:
									inc	ecx
									_lFNPLoc_03_StrOX:
									cmp	byte ptr [ecx],		5ch	;; \ 
									jne	_lFNPLoc_03_StrEX
									add	ecx,			02h
									jmp	_lFNPLoc_03_StrOX
									_lFNPLoc_03_StrEX:
									cmp	byte ptr [ecx],		22h	;; "
									jne	_lFNPLoc_03_Str
									jmp	_lFNPLoc_03_AX
									;;----------------

								_lFNPLoc_05:
								mov	word ptr [edi],			0a0dh
								add	edi,				02h
								mov	dword ptr [_dFCL],		edi
								mov	edi,				dword ptr [_dFCB]
								mov	dword ptr [edi],		20746573h	;; set_
								add	edi,				04h

								_lFNPLoc_04:
								dec	esi
								cmp	byte ptr [esi-01h],		20h		;; bs
								jne	_lFNPLoc_04
								jmp	_lFNPIncDecSTXEndSFXD
								;;----------------
							;;----------------

						_lFNPIncDecSTXEndSFXD_Pre:
						mov	esi,			offset _bFuncCodeOneLine

						_lFNPIncDecSTXEndSFXD:
						mov	ecx,			edx
						sub	ecx,			esi
						rep	movsb

						mov	al,			byte ptr [_bFCLL]
						cmp	byte ptr [_bFCLLMAX],	al
						jg	_lFNPIncDecSTXEndXX
						mov	byte ptr [_bFCLLMAX],	al
						_lFNPIncDecSTXEndXX:
						mov	byte ptr [_bFCLL],	40h
						;;----------------

					mov	esi,			dword ptr [_dBuffer]

					mov	dword ptr [_dFCB],	edi
					jmp	_lFNPLine
					;;----------------
				;;----------------

			_lbl:
			cmp	cl,			06h		;; ex bs
			je	_lFNPCopyParseNext

				;;----------------
				_lbl:
				cmp	cl,			0fh		;; array
				jne	_next

				cmp	dword ptr [esi-07h],	72726120h	;; _arr
				jne	_lFNPArrAdd
				cmp	word ptr [esi-03h],	7961h		;; ay
				jne	_lFNPArrAdd

				mov	byte ptr [edi],		20h		;; bs
				inc	edi
				jmp	_lFNPCopyParseNext

				_lFNPArrAdd:
				mov	dword ptr [edi],	72726120h	;; _arr
				mov	dword ptr [edi+04h],	00207961h	;; ay_*
				add	edi,			07h

				jmp	_lFNPCopyParseNext
				;;----------------

			_lbl:
			cmp	cl,			01h		;; #
			jne	_lFNPCopyParseCX

				;;----------------
				;; parse #
				cmp	cx,			3001h		;; #0
				jne	_next
				mov	word ptr [esi-01h],	0a0dh		;; new line
				inc	esi
				mov	dword ptr [edi],	65687420h	;; _the
				mov	dword ptr [edi+04h],	000a0d6eh	;; n new line
				add	edi,			07h		;; !
				jmp	_lFNPIncDecSTX

				_lbl:
				cmp	cx,			3101h		;; #1
				jne	_next
				mov	word ptr [esi-01h],	0a0dh		;; new line
				mov	dword ptr [edi],	000a0d29h	;; )__x
				inc	esi
				add	edi,			03h		;; !!!
				jmp	_lFNPIncDecSTX

				_lbl:
				cmp	cx,			6f01h		;; #o
				jne	_next
				mov	byte ptr [esi],		66h		;; #f
				mov	word ptr [edi],		0a0dh		;; nl
				dec	esi
				add	edi,			02h
				jmp	_lFNPIncDecSTX

					;;----------------
					;; func name
					_lbl:
					cmp	cx,			3801h		;; #8
					jne	_next

					inc	esi
					sub	edi,			02h
					mov	ecx,			dword ptr [_dLastStructName]
					xor	eax,			eax
					test	ecx,			ecx
					jz	_lFNPFuncNameCopyEX

					_lFNPFuncNameCopyAX:
					mov	al,			byte ptr [ecx]
					cmp	byte ptr [_bAscii_00+eax],		ah
					je	_lFNPFuncNameCopyBX
					stosb
					inc	ecx
					jmp	_lFNPFuncNameCopyAX
					_lFNPFuncNameCopyBX:
					mov	byte ptr [edi],		2eh	;; .
					inc	edi

					_lFNPFuncNameCopyEX:
					mov	ecx,			dword ptr [_dLastFuncName]
					_lFNPFuncNameCopy:
					mov	al,			byte ptr [ecx]
					cmp	byte ptr [_bAscii_00+eax],		ah
					je	_lFNPCopyParseNext
					stosb
					inc	ecx
					jmp	_lFNPFuncNameCopy
					;;----------------

				_lbl:
				cmp	cx,			3301h		;; #3
				jne	_next
				mov	word ptr [esi-01h],	0a0dh		;; new line
				inc	esi
				mov	dword ptr [edi],	6e650a0dh	;; __en
				mov	dword ptr [edi+04h],	6f6c6764h	;; dglo
				mov	dword ptr [edi+08h],	736c6162h	;; bals
				mov	word ptr [edi+0ch],	0a0dh		;; __
				add	edi,			0eh
				jmp	_lFNPLine

				_lbl:
				cmp	cx,			7801h		;; #x
				je	_lFNPUnBlockErr

				_lbl:
				cmp	cx,			7001h		;; #p
				jne	_next
				mov	al,			2bh		;; +

					;;----------------
					;; inc/dec
					_lFNPIncDec:

						;;----------------
						;; scan
						cmp	byte ptr [edi-01h],	5dh	;; ]
						jne	_lFNPIncDecNormJJ

						mov	edx,			edi
						xor	ecx,			ecx

						_lFNPIncDecFXScan:
						dec	edx

						cmp	byte ptr [edx],		28h	;; (
						jne	_lFNPIncDecFXScan_00
						mov	cl,			byte ptr [edx-01h]
						cmp	byte ptr [_bAscii_00+ecx],		ch
						je	_lFNPIncDecFXScan

							;;----------------
							;; ex index
							_lFNPIncDecEXI_00:
							dec	edx
							cmp	dword ptr [edx-04h],	20746573h	;; set_
							jne	_lFNPIncDecEXI_00

							_lFNPIncDecEXI_01:
							inc	edx
							cmp	byte ptr [edx],		5bh		;; [
							jne	_lFNPIncDecEXI_01

							mov	ebp,			esp
							push	ebx
							mov	ebx,			dword ptr [ebp]

							mov	ecx,			dword ptr [_dFCPL]
							inc	edx

							inc	byte ptr [_bFCLL]
							mov	dword ptr [ecx],	20746573h	;; set_
							mov	ah,			byte ptr [_bFCLL]
							mov	dword ptr [ecx+04h],	3d207871h	;; qx_=
							mov	byte ptr [ecx+06h],	ah
							add	ecx,			08h

							_lFNPIncDecEXI_02:
							mov	ah,			byte ptr [edx]
							mov	byte ptr [ecx],		ah
							mov	byte ptr [edx],		20h
							cmp	ebx,			edx
							jne	_lFNPIncDecEXI_03
							mov	dword ptr [ebp],	ecx
							sub	ebp,			04h
							mov	ebx,			dword ptr [ebp]

							_lFNPIncDecEXI_03:
							inc	ecx
							inc	edx
							cmp	edx,			edi
							jne	_lFNPIncDecEXI_02

							mov	ah,			byte ptr [_bFCLL]
							mov	word ptr [ecx-01h],	0a0dh		;; nl
							mov	dword ptr [edi-04h],	5d207871h	;; qx*]
							inc	ecx
							mov	byte ptr [edi-02h],	ah

							mov	dword ptr [_dFCPL],	ecx
							pop	ebx

							jmp	_lFNPIncDecNormJJ
							;;----------------

						_lFNPIncDecFXScan_00:
						cmp	word ptr [edx],		0a0dh	;; nl
						jne	_lFNPIncDecFXScan
						;;----------------

					_lFNPIncDecNormJJ:
					mov	edx,			edi
					mov	ecx,			edi
					_lFNPIncDecEX:
					dec	edx
					cmp	dword ptr [edx-04h],	20746573h	;; set_
					jne	_lFNPIncDecEX
					mov	byte ptr [edi],		3dh		;; =
					inc	edi
					_lFNPIncDecSX:
					mov	ah,			byte ptr [edx]
					mov	byte ptr [edi],		ah
					inc	edx
					inc	edi
					cmp	edx,			ecx
					jb	_lFNPIncDecSX
					mov	byte ptr [edi],		al
					mov	dword ptr [edi+01h],	000a0d31h	;; 1__x
					add	edi,			04h
					add	esi,			03h		;; !!!
					jmp	_lFNPIncDecSTX
					;;----------------

				_lbl:
				cmp	cx,			6d01h		;; #m
				;;jne	_next
				mov	al,			2dh		;; -
				jmp	_lFNPIncDec
				;;----------------

				;;----------------
				;; multidefined variables
				_lFNPVarX:
				inc	esi
				mov	al,			byte ptr [esi]
				sub	al,			80h
				js	_lFNPVarXEX
				mov	byte ptr [esi],		al
				mov	byte ptr [_bArrayFX],	al

				_lFNPVarXEX:
				mov	edx,			esi		;; store esi
				mov	esi,			dword ptr [_dVarParams]
;				mov	word ptr [edi],		0a0dh
;				add	edi,			02h
				_lbl:						;; search begin of parsed line
				dec	esi
				cmp	word ptr [esi-02h],	0a0dh
				je	_lNPVarXKeyPreX
				cmp	byte ptr [esi-01h],	00h
				jne	_prew

				_lNPVarXKeyPreX:
				mov	eax,			dword ptr [esi]

				cmp	eax,			61636f6ch	;; loca
				jne	_next
				cmp	word ptr [esi+04h],	206ch		;; l_
				jne	_next
				movsd
				movsw
				jmp	_lNPVarXKeyPreX

				_lbl:
				cmp	eax,			76697270h	;; priv
				jne	_next
				cmp	dword ptr [esi+04h],	20657461h	;; ate_
				jne	_next
				movsd
				movsd
				jmp	_lNPVarXKeyPreX

				_lbl:
				cmp	eax,			6c627570h	;; publ
				jne	_next
				cmp	word ptr [esi+04h],	6369h		;; ic
				jne	_next
				cmp	byte ptr [esi+06h],	20h		;; _
				jne	_next
				movsd
				movsw
				movsb
				jmp	_lNPVarXKeyPreX

				_lbl:
				cmp	eax,			74617473h	;; stat
				jne	_next
				cmp	word ptr [esi+04h],	6369h		;; ic
				jne	_next
				cmp	byte ptr [esi+06h],	20h		;; _
				jne	_next
				movsd
				movsw
				movsb
				jmp	_lNPVarXKeyPreX

				_lbl:
				cmp	eax,			736e6f63h	;; cons
				jne	_next
				cmp	dword ptr [esi+04h],	746e6174h	;; tant
				jne	_next
				cmp	byte ptr [esi+08h],	20h		;; _
				jne	_next
				movsd
				movsd
				movsb
				jmp	_lNPVarXKeyPreX

_lbl:
cmp	eax,			"daer"
jne	_next
cmp	dword ptr [esi+04h],	"ylno"
jne	_next
cmp	byte ptr [esi+08h],	" "
jne	_next
movsd
movsd
movsb
jmp	_lNPVarXKeyPreX

				_lbl:
				cmp	eax,			75626564h	;; debu
				jne	_next
				cmp	word ptr [esi+04h],	2067h		;; g_
				jne	_next
				movsd
				movsw
				jmp	_lNPVarXKeyPreX

				_lbl:
				movsb						;; copy type
				cmp	byte ptr [esi-01h],	20h
				jne	_prew

				cmp	byte ptr [_bArrayFX],	00h
				je	_next

				mov	dword ptr [edi],	61727261h	;; arra
				mov	word ptr [edi+04h],	2079h		;; y_
				mov	byte ptr [_bArrayFX],	00h
				add	edi,			06h

				_lbl:	
				mov	esi,			edx		;; restore esi
				xor	eax,			eax
				jmp	_lFNPCopyParseNext
				;;----------------
			;;----------------
		;;----------------

	_lFNPEnd:
;	cmp	word ptr [edi-02h],	0a0dh		;; new line
;	jne	_next
;	sub	edi,			02h
;	_lbl:

;;----------------
;; add generated globals
cmp	word ptr [edi - 02h],		0a0dh
je	_next
mov	word ptr [edi],			0a0dh
add	edi,				02h
_lbl:

cmp	dword ptr [_sCJGenGlobalsTypes],	00h
je	_lGlobalsAdd_EndEx

mov	dword ptr [edi],		"bolg"
mov	dword ptr [edi + 04h],		" sla"
mov	word ptr [edi + 08h],		0a0dh
add	edi,				0ah

	;;----------------
	mov	ecx,				offset _sCJGenGlobalsTypes
	xor	eax,				eax

	_lGlobalsAdd_Start:
	cmp	byte ptr [ecx],			00h
	je	_lGlobalsAdd_End

		;;----------------
		;; add type
		mov	edx,				ecx

		_lGlobalsAdd_DeclareType:
		mov	al,				byte ptr [edx]
		cmp	byte ptr [_bAscii_00 + eax],	ah
		je	_lGlobalsAdd_DeclareTypeEnd

		stosb
		inc	edx
		jmp	_lGlobalsAdd_DeclareType

		_lGlobalsAdd_DeclareTypeEnd:
		mov	byte ptr [edi],			" "
		;;----------------

	mov	dword ptr [edi + 01h],		"v_jc"
	mov	dword ptr [edi + 05h],		"_666"
	add	edi,				09h

	_lGlobalsAdd_ProcessType:
	mov	al,				byte ptr [ecx]
	cmp	byte ptr [_bAscii_00 + eax],	ah
	je	_lGlobalsAdd_ProcessTypeEnd

	stosb
	inc	ecx
	jmp	_lGlobalsAdd_ProcessType

	_lGlobalsAdd_ProcessTypeEnd:
	mov	word ptr [edi],			0a0dh
	inc	ecx
	add	edi,				02h
	jmp	_lGlobalsAdd_Start

	_lGlobalsAdd_End:
	;;----------------

mov	dword ptr [edi],		"gdne"
mov	dword ptr [edi + 04h],		"abol"
mov	dword ptr [edi + 08h],		0a0d736ch	;; ls nl
add	edi,				0ch

_lGlobalsAdd_EndEx:
;;----------------

;;----------------
;; register callback functions
cmp	dword ptr [_dCallbackList],	00h
je	_lCallbackReg_End

push	esi

	;;----------------
	;; preprocess arguments
	push	edi

	mov	ecx,				offset _dCallbackList - _dCBSize
	xor	eax,				eax

	_lCallbackReg_ArgPre_Str:
	add	ecx,				_dCBSize
	cmp	dword ptr [ecx],		00h
	je	_lCallbackReg_ArgPre_End

	cmp	dword ptr [ecx + 08h],		00h
	je	_lCallbackReg_ArgPre_Str

	cmp	word ptr [ecx + 0dh],		00h
	jne	_lCallbackReg_ArgPre_Str

		;;----------------
		;; function in arg?
		mov	esi,				dword ptr [ecx + 08h]

		_lCallbackReg_ArgPre_IsFunc:
		inc	esi
		cmp	byte ptr [esi],			")"
		je	_lCallbackReg_ArgPre_IsFuncEnd
		cmp	byte ptr [esi],			"("
		jne	_lCallbackReg_ArgPre_IsFunc

		mov	byte ptr [ecx + 0fh],		01h

		_lCallbackReg_ArgPre_IsFuncEnd:
		;;----------------

	mov	edx,				ecx
	_lCallbackReg_ArgPre_GetSame:
	add	edx,				_dCBSize
	cmp	dword ptr [edx],		00h
	je	_lCallbackReg_ArgPre_Str

	cmp	dword ptr [edx + 08h],		00h
	je	_lCallbackReg_ArgPre_GetSame

	mov	al,				byte ptr [ecx + 0ch]
	cmp	al,				byte ptr [edx + 0ch]
	jne	_lCallbackReg_ArgPre_GetSame

	cmp	word ptr [edx + 0dh],		00h
	jne	_lCallbackReg_ArgPre_GetSame

		;;----------------
		;; check arg
		mov	esi,				dword ptr [ecx + 08h]
		mov	edi,				dword ptr [edx + 08h]
		xor	ebx,				ebx
		dec	esi
		dec	edi

		_lCallbackReg_ArgPre_Check:
		inc	esi
		inc	edi
		mov	al,				byte ptr [esi]
		cmp	al,				byte ptr [edi]
		je	_lCallbackReg_ArgPre_Check_00
		jmp	_lCallbackReg_ArgPre_GetSame

		_lCallbackReg_ArgPre_Check_00:
		cmp	al,				"("
		je	_lCallbackReg_ArgPre_Check_01
		cmp	al,				")"
		jne	_lCallbackReg_ArgPre_Check

		dec	ebx
		jns	_lCallbackReg_ArgPre_Check

			;;----------------
			mov	bx,				word ptr [ecx + 0dh]
			test	bx,				bx
			jnz	_lCallbackReg_ArgPre_Mod

			mov	bx,				word ptr [_bCallbackArgFam]
			inc	bx
			mov	word ptr [ecx + 0dh],		bx
			mov	word ptr [_bCallbackArgFam],	bx

			_lCallbackReg_ArgPre_Mod:
			mov	al,				byte ptr [ecx + 0fh]
			mov	word ptr [edx + 0dh],		bx
			mov	byte ptr [edx + 0fh],		al
			jmp	_lCallbackReg_ArgPre_GetSame
			;;----------------

		_lCallbackReg_ArgPre_Check_01:
		inc	ebx
		jmp	_lCallbackReg_ArgPre_Check
		;;----------------

	_lCallbackReg_ArgPre_End:
	pop	edi
	;;----------------

mov	esi,				_sCallbackReg_00_Str
mov	ecx,				_sCallbackReg_00_End - _sCallbackReg_00_Str
rep	movsb

	;;----------------
	;; count types
	mov	ecx,				offset _dCallbackList

	_lCallbackReg_GetTypes:
	cmp	dword ptr [ecx],		00h
	je	_lCallbackReg_GetTypesEnd

	mov	al,				byte ptr [ecx + 0ch]
	mov	byte ptr [_bIsExist_BaseOffset + eax * 02h],		01h

	cmp	dword ptr [ecx + 08h],		00h
	je	_lCallbackReg_GetTypes_NoArg
	mov	byte ptr [_bIsExist_BaseOffset + eax * 02h + 01h],	01h

	_lCallbackReg_GetTypes_NoArg:
	add	ecx,				_dCBSize
	jmp	_lCallbackReg_GetTypes

	_lCallbackReg_GetTypesEnd:
	;;----------------

	;;----------------
	;; add functions
	mov	edx,			_bIsExist_BaseOffset	;; skip onInit

	_lCallbackReg_AddFunc_Next:
	add	edx,			02h
	cmp	edx,			_bIsExist_BaseOffsetEnd
	je	_lCallbackReg_AddFunc_End

	cmp	byte ptr [edx],		00h
	je	_lCallbackReg_AddFunc_Next

	mov	esi,			_sCallbackReg_01_Str
	mov	ecx,			_sCallbackReg_01_End - _sCallbackReg_01_Str
	rep	movsb

	mov	eax,			edx
	sub	eax,			_bIsExist_BaseOffset
;	shl	eax,			01h
	mov	ax,			word ptr [eax + _bIntToHexStr]
	mov	word ptr [edi - 22h],	ax

		;;----------------
		;; with args
		mov	ebx,			edx
		sub	ebx,			_bIsExist_BaseOffset
		shr	ebx,			01h
;		mov	byte ptr [_bCallbackTempType],	al

		cmp	byte ptr [edx + 01h],	00h
		je	_lCallbackReg_AddFunc_WithoutArgs

		cmp	edx,			offset _bIsExist_onHeroLevel
		jb	_lCallbackReg_AddFunc_Arg_00

		cmp	edx,			offset _bIsExist_onUnitSpellChannel
		jb	_lCallbackReg_AddFunc_Arg_01

		mov	esi,			_sCallbackReg_Spell_Str
		mov	ecx,			_sCallbackReg_Spell_End - _sCallbackReg_Spell_Str
		rep	movsb
		jmp	_lCallbackReg_AddFunc_GetArged

		_lCallbackReg_AddFunc_Arg_00:
		mov	esi,			_sCallbackReg_Order_Str
		mov	ecx,			_sCallbackReg_Order_End - _sCallbackReg_Order_Str
		rep	movsb
		jmp	_lCallbackReg_AddFunc_GetArged

		_lCallbackReg_AddFunc_Arg_01:
		mov	esi,			_sCallbackReg_Skill_Str
		mov	ecx,			_sCallbackReg_Skill_End - _sCallbackReg_Skill_Str
		rep	movsb

			;;----------------
			;; add
			_lCallbackReg_AddFunc_GetArged:
			mov	byte ptr [_bCallbackArgPickType],	00h

			_lCallbackReg_AddFunc_GetArgedEx:
			mov	ecx,			offset _dCallbackList

			mov	dword ptr [edi],	"i fi"
			mov	word ptr [edi + 04h],	"=="
			add	edi,			06h
;			jmp	_lCallbackReg_AddFunc_GetArgedNext

			_lCallbackReg_AddFunc_GetArgedNext:
			cmp	byte ptr [_bCallbackArgPickType],	00h
			je	_lCallbackReg_AddFunc_GetArgedNextEx

			mov	dword ptr [edi],	"i fi"
			mov	word ptr [edi + 04h],	"=="
			add	edi,			06h

			_lCallbackReg_AddFunc_GetArgedNextEx:
			cmp	byte ptr [ecx + 0ch],		bl
			jne	_lCallbackReg_AddFunc_GetArgedSkip
			cmp	dword ptr [ecx + 08h],		00h
			je	_lCallbackReg_AddFunc_GetArgedSkip

			cmp	word ptr [ecx + 0dh],		0ffffh
			je	_lCallbackReg_AddFunc_GetArgedSkip

			mov	al,				byte ptr [ecx + 0fh]
			cmp	al,				byte ptr [_bCallbackArgPickType]
			jne	_lCallbackReg_AddFunc_GetArgedSkip

				;;----------------
				;; copy arg and func name
				mov	esi,			dword ptr [ecx + 08h]
				xor	ebp,			ebp
				_lCallbackReg_AddFunc_GetArgedCopyArg:
				lodsb
				cmp	al,			"("
				je	_lCallbackReg_AddFunc_GetArgedCopyArg_00
				cmp	al,			")"
				je	_lCallbackReg_AddFunc_GetArgedCopyArg_01
				cmp	al,			22h
				je	_lCallbackReg_AddFunc_GetArgedCopyArg_Str
				stosb
				jmp	_lCallbackReg_AddFunc_GetArgedCopyArg

				_lCallbackReg_AddFunc_GetArgedCopyArg_Str:
				stosb
;; lodsb???
				_lCallbackReg_AddFunc_GetArgedCopyArg_StrEx:
				cmp	byte ptr [esi],		22h
				je	_lCallbackReg_AddFunc_GetArgedCopyArg_Str_00
				cmp	byte ptr [esi],		5ch	;; \ 
				jne	_lCallbackReg_AddFunc_GetArgedCopyArg_Str_01
				movsw
				jmp	_lCallbackReg_AddFunc_GetArgedCopyArg_StrEx

				_lCallbackReg_AddFunc_GetArgedCopyArg_Str_01:
				movsb
				jmp	_lCallbackReg_AddFunc_GetArgedCopyArg_StrEx

				_lCallbackReg_AddFunc_GetArgedCopyArg_Str_00:
				movsb
				jmp	_lCallbackReg_AddFunc_GetArgedCopyArg


				_lCallbackReg_AddFunc_GetArgedCopyArg_00:
				inc	ebp
				stosb
				jmp	_lCallbackReg_AddFunc_GetArgedCopyArg

				_lCallbackReg_AddFunc_GetArgedCopyArg_01:
				dec	ebp
				js	_lCallbackReg_AddFunc_GetArgedCopyArg_End
				stosb
				jmp	_lCallbackReg_AddFunc_GetArgedCopyArg

				_lCallbackReg_AddFunc_GetArgedCopyArg_End:
				mov	dword ptr [edi],	"eht "
				mov	dword ptr [edi + 04h],	630a0d6eh	;; n nl c
				mov	dword ptr [edi + 08h],	" lla"
				add	edi,			0ch

				xor	eax,			eax
				mov	esi,			dword ptr [ecx + 04h]
				test	esi,			esi
				jz	_lCallbackReg_AddFunc_Func

				_lCallbackReg_AddFunc_Method:
				lodsb
				cmp	byte ptr [_bAscii_00 + eax],	ah
				je	_lCallbackReg_AddFunc_MethodEnd
				stosb
				jmp	_lCallbackReg_AddFunc_Method

				_lCallbackReg_AddFunc_MethodEnd:
				mov	byte ptr [edi],		"."
				inc	edi

				_lCallbackReg_AddFunc_Func:
				mov	esi,			dword ptr [ecx]
				_lCallbackReg_AddFunc_FuncEx:
				lodsb
				cmp	byte ptr [_bAscii_00 + eax],	ah
				je	_lCallbackReg_AddFunc_FuncEnd
				stosb
				jmp	_lCallbackReg_AddFunc_FuncEx

				_lCallbackReg_AddFunc_FuncEnd:
				mov	dword ptr [edi],	0a0d2928h	;; () nl
				add	edi,			04h
				cmp	word ptr [ecx + 0dh],	00h
				je	_lCallbackReg_AddFunc_FuncEndNoAdditional

					;;----------------
					;; add functions with same arg
					push	edx

					mov	edx,			ecx
					mov	bp,			word ptr [ecx + 0dh]

					_lCallbackReg_AddFunc_ArgEx:
					add	edx,			_dCBSize
					cmp	dword ptr [edx],	00h
					je	_lCallbackReg_AddFunc_ArgExEnd

					cmp	word ptr [edx + 0dh],	bp
					jne	_lCallbackReg_AddFunc_ArgEx

						;;----------------
						mov	word ptr [edx + 0dh],	0ffffh

						mov	dword ptr [edi],	"llac"
						mov	byte ptr [edi + 04h],	" "
						add	edi,			05h

						mov	esi,			dword ptr [edx + 04h]
						test	esi,			esi
						jz	_lCallbackReg_AddFunc_ArgEx_Func

						_lCallbackReg_AddFunc_ArgEx_Meth:
						lodsb
						cmp	byte ptr [_bAscii_00 + eax],	ah
						je	_lCallbackReg_AddFunc_ArgEx_MethEnd
						stosb
						jmp	_lCallbackReg_AddFunc_ArgEx_Meth

						_lCallbackReg_AddFunc_ArgEx_MethEnd:
						mov	byte ptr [edi],		"."
						inc	edi

						_lCallbackReg_AddFunc_ArgEx_Func:
						mov	esi,			dword ptr [edx]
						_lCallbackReg_AddFunc_ArgEx_FuncEX:
						lodsb
						cmp	byte ptr [_bAscii_00 + eax],	ah
						je	_lCallbackReg_AddFunc_ArgEx_FuncEnd
						stosb
						jmp	_lCallbackReg_AddFunc_ArgEx_FuncEX

						_lCallbackReg_AddFunc_ArgEx_FuncEnd:
						mov	dword ptr [edi],	0a0d2928h	;; () nl
						add	edi,			04h

						jmp	_lCallbackReg_AddFunc_ArgEx
						;;----------------

					_lCallbackReg_AddFunc_ArgExEnd:
					pop	edx
					;;----------------

				_lCallbackReg_AddFunc_FuncEndNoAdditional:
				cmp	byte ptr [_bCallbackArgPickType],	00h
				jne	_lCallbackReg_AddFunc_FuncEndNoAdditionalEx
				mov	word ptr [edi],		"le"
				mov	dword ptr [edi + 02h],	"fies"
				mov	dword ptr [edi + 06h],	"==i "
				add	edi,			0ah
				jmp	_lCallbackReg_AddFunc_GetArgedSkip

				_lCallbackReg_AddFunc_FuncEndNoAdditionalEx:
				mov	dword ptr [edi],	"idne"
				mov	dword ptr [edi + 03h],	0a0d6669h	;; if nl
				add	edi,			07h
				;;----------------

			_lCallbackReg_AddFunc_GetArgedSkip:
			add	ecx,			_dCBSize
			cmp	dword ptr [ecx],	00h
			jne	_lCallbackReg_AddFunc_GetArgedNext

			cmp	byte ptr [_bCallbackArgPickType],	01h
			je	_lCallbackReg_AddFunc_GetArgedSkipEx

;			sub	edi,			05h
			mov	dword ptr [edi - 0ah],	"idne"
			mov	dword ptr [edi - 06h],	"   f"
			mov	word ptr [edi - 02h],	0a0dh

			_lCallbackReg_AddFunc_GetArgedSkipEx:
			;;----------------

			;;----------------
			;; add	with ex args
			cmp	byte ptr [_bCallbackArgPickType],	01h
			je	_lCallbackReg_AddFunc_ArgedEnd

			mov	byte ptr [_bCallbackArgPickType],	01h
			jmp	_lCallbackReg_AddFunc_GetArgedEx

			_lCallbackReg_AddFunc_ArgedEnd:
			;;----------------
		;;----------------

		;;----------------
		;; without args
		_lCallbackReg_AddFunc_WithoutArgs:
		mov	ecx,			offset _dCallbackList

		_lCallbackReg_AddFunc_WithoutArgs_Str:
		cmp	byte ptr [ecx + 0ch],	bl
		jne	_lCallbackReg_AddFunc_NoArgedSkip
		cmp	dword ptr [ecx + 08h],	00h
		jne	_lCallbackReg_AddFunc_NoArgedSkip

		mov	dword ptr [edi],	"llac"
		mov	byte ptr [edi + 04h],	" "
		add	edi,			05h

			;;----------------
			;; add it
			xor	eax,			eax
			mov	esi,			dword ptr [ecx + 04h]
			test	esi,			esi
			jz	_lCallbackReg_XAddFunc_Func

			_lCallbackReg_XAddFunc_Method:
			lodsb
			cmp	byte ptr [_bAscii_00 + eax],	ah
			je	_lCallbackReg_XAddFunc_MethodEnd
			stosb
			jmp	_lCallbackReg_XAddFunc_Method

			_lCallbackReg_XAddFunc_MethodEnd:
			mov	byte ptr [edi],		"."
			inc	edi

			_lCallbackReg_XAddFunc_Func:
			mov	esi,			dword ptr [ecx]
			_lCallbackReg_XAddFunc_FuncEx:
			lodsb
			cmp	byte ptr [_bAscii_00 + eax],	ah
			je	_lCallbackReg_XAddFunc_FuncEnd
			stosb
			jmp	_lCallbackReg_XAddFunc_FuncEx

			_lCallbackReg_XAddFunc_FuncEnd:
			mov	dword ptr [edi],	0a0d2928h	;; () nl
			add	edi,			04h
			jmp	_lCallbackReg_AddFunc_NoArgedSkip
			;;----------------

		_lCallbackReg_AddFunc_NoArgedSkip:
		add	ecx,			_dCBSize
		cmp	dword ptr [ecx],	00h
		jne	_lCallbackReg_AddFunc_WithoutArgs_Str

		mov	dword ptr [edi],	"fdne"
		mov	dword ptr [edi + 04h],	"tcnu"
		mov	dword ptr [edi + 08h],	" noi"
		mov	word ptr [edi + 0ch],	0a0dh
		add	edi,			0eh
		jmp	_lCallbackReg_AddFunc_Next
		;;----------------

	_lCallbackReg_AddFunc_End:
	;;----------------

	;;----------------
	;; add reg function
	mov	esi,				_sCallbackReg_02_Str
	mov	ecx,				_sCallbackReg_02_End - _sCallbackReg_02_Str
	rep	movsb

		;;----------------
		;; TriggerRegisterPlayerEvent
		xor	eax,			eax

		add	al,			byte ptr [_bIsExist_onUnitAttacked]
		add	al,			byte ptr [_bIsExist_onUnitDeath]
		add	al,			byte ptr [_bIsExist_onUnitDecay]
		add	al,			byte ptr [_bIsExist_onUnitIssuedOrder]
		add	al,			byte ptr [_bIsExist_onUnitIssuedPointOrder]
		add	al,			byte ptr [_bIsExist_onUnitIssuedTargetOrder]
		add	al,			byte ptr [_bIsExist_onHeroLevel]
		add	al,			byte ptr [_bIsExist_onHeroSkill]
		add	al,			byte ptr [_bIsExist_onUnitSpellChannel]
		add	al,			byte ptr [_bIsExist_onUnitSpellCast]
		add	al,			byte ptr [_bIsExist_onUnitSpellEffect]
		add	al,			byte ptr [_bIsExist_onUnitSpellFinish]
		add	al,			byte ptr [_bIsExist_onUnitSpellEndcast]

		test	eax,			eax
		jz	_lCallbackReg_NoPlayer

		mov	esi,				_sCallbackReg_03_Str
		mov	ecx,				_sCallbackReg_03_End - _sCallbackReg_03_Str
		rep	movsb

		cmp	byte ptr [_bIsExist_onUnitAttacked],	00h
		je	_next
		mov	esi,				_sCallbackReg_04_Str
		mov	ecx,				_sCallbackReg_04_End - _sCallbackReg_04_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onUnitDeath],	00h
		je	_next
		mov	esi,				_sCallbackReg_05_Str
		mov	ecx,				_sCallbackReg_05_End - _sCallbackReg_05_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onUnitDecay],	00h
		je	_next
		mov	esi,				_sCallbackReg_06_Str
		mov	ecx,				_sCallbackReg_06_End - _sCallbackReg_06_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onUnitIssuedOrder],	00h
		je	_next
		mov	esi,				_sCallbackReg_07_Str
		mov	ecx,				_sCallbackReg_07_End - _sCallbackReg_07_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onUnitIssuedPointOrder],	00h
		je	_next
		mov	esi,				_sCallbackReg_08_Str
		mov	ecx,				_sCallbackReg_08_End - _sCallbackReg_08_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onUnitIssuedTargetOrder],	00h
		je	_next
		mov	esi,				_sCallbackReg_09_Str
		mov	ecx,				_sCallbackReg_09_End - _sCallbackReg_09_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onHeroLevel],	00h
		je	_next
		mov	esi,				_sCallbackReg_0a_Str
		mov	ecx,				_sCallbackReg_0a_End - _sCallbackReg_0a_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onHeroSkill],	00h
		je	_next
		mov	esi,				_sCallbackReg_0b_Str
		mov	ecx,				_sCallbackReg_0b_End - _sCallbackReg_0b_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onUnitSpellChannel],	00h
		je	_next
		mov	esi,				_sCallbackReg_0c_Str
		mov	ecx,				_sCallbackReg_0c_End - _sCallbackReg_0c_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onUnitSpellCast],	00h
		je	_next
		mov	esi,				_sCallbackReg_0d_Str
		mov	ecx,				_sCallbackReg_0d_End - _sCallbackReg_0d_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onUnitSpellEffect],	00h
		je	_next
		mov	esi,				_sCallbackReg_0e_Str
		mov	ecx,				_sCallbackReg_0e_End - _sCallbackReg_0e_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onUnitSpellFinish],	00h
		je	_next
		mov	esi,				_sCallbackReg_0f_Str
		mov	ecx,				_sCallbackReg_0f_End - _sCallbackReg_0f_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onUnitSpellEndcast],	00h
		je	_next
		mov	esi,				_sCallbackReg_10_Str
		mov	ecx,				_sCallbackReg_10_End - _sCallbackReg_10_Str
		rep	movsb

		_lbl:
		mov	esi,				_sCallbackReg_15_Str
		mov	ecx,				_sCallbackReg_15_End - _sCallbackReg_15_Str
		rep	movsb
;		mov	dword ptr [edi],		"ldne"
;		mov	dword ptr [edi + 04h],		" poo"
;		mov	word ptr [edi + 08h],		0a0dh
;		add	edi,				0ah

		mov	edx,				_bIsExist_BaseOffset
		_lCallbackReg_AddActions:
		add	edx,				02h
		cmp	edx,				_bIsExist_BaseOffsetEnd
		je	_lCallbackReg_NoPlayer

		cmp	byte ptr [edx],			00h
		je	_lCallbackReg_AddActions

		mov	esi,				_sCallbackReg_11_Str
		mov	ecx,				_sCallbackReg_11_End - _sCallbackReg_11_Str
		rep	movsb

		mov	eax,				edx
		sub	eax,				_bIsExist_BaseOffset
		mov	ax,				word ptr [eax + _bIntToHexStr]
		mov	word ptr [edi - 05h],		ax
		mov	word ptr [edi - 16h],		ax

		jmp	_lCallbackReg_AddActions

		_lCallbackReg_NoPlayer:
		;;----------------

		;;----------------
		;; TriggerRegisterGameEvent
		cmp	byte ptr [_bIsExist_onGameLoad],	00h
		je	_next
		mov	esi,				_sCallbackReg_12_Str
		mov	ecx,				_sCallbackReg_12_End - _sCallbackReg_12_Str
		rep	movsb

		_lbl:
		cmp	byte ptr [_bIsExist_onGameSave],	00h
		je	_next
		mov	esi,				_sCallbackReg_13_Str
		mov	ecx,				_sCallbackReg_13_End - _sCallbackReg_13_Str
		rep	movsb

		_lbl:
		;;----------------

		;;----------------
		;; onInit
		mov	ecx,			offset _dCallbackList
		xor	eax,			eax

		_lCallbackReg_onInit:
		cmp	byte ptr [ecx + 0ch],	_cbt_onInit
		jne	_lCallbackReg_onInit_GetNext

		mov	dword ptr [edi],	"llac"
		mov	byte ptr [edi + 04h],	" "
		add	edi,			05h

		mov	esi,			dword ptr [ecx + 04h]
		test	esi,			esi
		jz	_lCallbackReg_AAddFunc_Func

		_lCallbackReg_AAddFunc_Method:
		lodsb
		cmp	byte ptr [_bAscii_00 + eax],	ah
		je	_lCallbackReg_AAddFunc_MethodEnd
		stosb
		jmp	_lCallbackReg_AAddFunc_Method

		_lCallbackReg_AAddFunc_MethodEnd:
		mov	byte ptr [edi],		"."
		inc	edi

		_lCallbackReg_AAddFunc_Func:
		mov	esi,			dword ptr [ecx]
		_lCallbackReg_AAddFunc_FuncEx:
		lodsb
		cmp	byte ptr [_bAscii_00 + eax],	ah
		je	_lCallbackReg_AAddFunc_FuncEnd
		stosb
		jmp	_lCallbackReg_AAddFunc_FuncEx

		_lCallbackReg_AAddFunc_FuncEnd:
		mov	dword ptr [edi],	0a0d2928h	;; () nl
		add	edi,			04h

		_lCallbackReg_onInit_GetNext:
		add	ecx,			_dCBSize
		cmp	byte ptr [ecx],		00h
		jne	_lCallbackReg_onInit
		;;----------------

	mov	dword ptr [edi],		"fdne"
	mov	dword ptr [edi + 04h],		"tcnu"
	mov	dword ptr [edi + 08h],		" noi"
	mov	word ptr [edi + 0ch],		0a0dh
	add	edi,				0eh
	;;----------------

	;;----------------
	;; add globals
	xor	eax,			eax

	add	al,			byte ptr [_bIsExist_onUnitAttacked]
	add	al,			byte ptr [_bIsExist_onUnitDeath]
	add	al,			byte ptr [_bIsExist_onUnitDecay]
	add	al,			byte ptr [_bIsExist_onUnitIssuedOrder]
	add	al,			byte ptr [_bIsExist_onUnitIssuedPointOrder]
	add	al,			byte ptr [_bIsExist_onUnitIssuedTargetOrder]
	add	al,			byte ptr [_bIsExist_onHeroLevel]
	add	al,			byte ptr [_bIsExist_onHeroSkill]
	add	al,			byte ptr [_bIsExist_onUnitSpellChannel]
	add	al,			byte ptr [_bIsExist_onUnitSpellCast]
	add	al,			byte ptr [_bIsExist_onUnitSpellEffect]
	add	al,			byte ptr [_bIsExist_onUnitSpellFinish]
	add	al,			byte ptr [_bIsExist_onUnitSpellEndcast]
	add	al,			byte ptr [_bIsExist_onGameLoad]
	add	al,			byte ptr [_bIsExist_onGameSave]

	test	eax,			eax
	jz	_lCallbackReg_NoTrig

	mov	dword ptr [edi],		"bolg"
	mov	dword ptr [edi + 04h],		" sla"
	mov	word ptr [edi + 08h],		0a0dh
	add	edi,				0ah

	mov	edx,			_bIsExist_BaseOffset

	_lCallbackReg_Glob:
	add	edx,				02h
	cmp	edx,				_bIsExist_BaseOffsetEnd
	je	_lCallbackReg_GlobEnd

	cmp	byte ptr [edx],			00h
	je	_lCallbackReg_Glob

	mov	esi,				_sCallbackReg_14_Str
	mov	ecx,				_sCallbackReg_14_End - _sCallbackReg_14_Str
	rep	movsb

	mov	eax,				edx
	sub	eax,				_bIsExist_BaseOffset
	mov	ax,				word ptr [eax + _bIntToHexStr]

	mov	word ptr [edi - 14h],		ax
	jmp	_lCallbackReg_Glob

	_lCallbackReg_GlobEnd:
	mov	dword ptr [edi],		"gdne"
	mov	dword ptr [edi + 04h],		"abol"
	mov	dword ptr [edi + 08h],		0a0d736ch	;; ls nl
	add	edi,				0ch

	_lCallbackReg_NoTrig:
	mov	dword ptr [edi],		"sdne"
	mov	dword ptr [edi + 04h],		"epoc"
	add	edi,				08h
	;;----------------

pop	esi

_lCallbackReg_End:
;;----------------

	;;----------------
;;	add	esi,			04h
mov	esi,			dword ptr [_dFinalParseOffset]	;; esi = code without anon functions
	mov	esp,			_dStackPos	;; restore esp
	sub	edi,			esi		;; edi = new script size
	add	esp,			04h

	;;----------------
	mov	_dCurrStr,		offset _sProg_05
	mov	eax,			64h
	call	_lSetProg
	;;----------------	
	
	retn	

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; parse endp
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;;-------------------------------------------------------------------------

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; proc codep
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	_lOpenMapCode:

	push	THREAD_PRIORITY_TIME_CRITICAL
	push	dword ptr [_hTrd]
	call	_imp__SetThreadPriority@8

	mov	dword ptr [_dPreStackPos],	esp	;; for error

	push	0ffh
	push	04h
	push	offset _sMapPath
	call	_imp__MpqOpenArchiveForUpdate@12

	test	eax,				eax
	jnz	_lCodep_00

		;;----------------
		;; error
		push	MB_ICONERROR
		push	offset _sWinName
		push	offset _sErr_Arch
		push	dword ptr [_hWnd]
		call	_imp__MessageBoxA@16
		push	01h
		call	_imp__ExitProcess@4
		;;----------------

	_lCodep_00:
	push	offset _sAttr
	push	eax

mov	ebx,			eax	;; ebx = mpq archive

;;----------------
;; is have imort scripts
cmp	byte ptr [_bIgnoreCustomBJ],	01h
je	_lIgnoreCustomBJ

push	offset _fScr_BJ
push	00h
push	offset _sBJ
push	ebx
call	_imp__SFileOpenFileEx@16

and	eax,			01h
or	eax,			30h
mov	byte ptr [_sImportBJ],	al

push	dword ptr [_fScr_BJ]
call	_imp__SFileCloseFile@4

_lIgnoreCustomBJ:

cmp	byte ptr [_bIgnoreCustomCJ],	01h
je	_lIgnoreCustomCJ

push	offset _fScr_CJ
push	00h
push	offset _sCJ
push	ebx
call	_imp__SFileOpenFileEx@16

and	eax,			01h
or	eax,			30h
mov	byte ptr [_sImportCJ],	al

push	dword ptr [_fScr_CJ]
call	_imp__SFileCloseFile@4

_lIgnoreCustomCJ:
;;----------------

	push	offset _fScr
	push	00h
	push	offset _sWJ
	push	ebx
	call	_imp__SFileOpenFileEx@16

	test	eax,				eax
	jnz	_next

		;;----------------
		;; error
		push	MB_ICONERROR
		push	offset _sWinName
		push	offset _sErr_Code
		push	dword ptr [_hWnd]
		call	_imp__MessageBoxA@16
		push	01h
		call	_imp__ExitProcess@4
		;;----------------

	_lbl:
	push	00h
	push	_fScr
	call	_imp__SFileGetFileSize@8
	mov	ebx,				eax

		;;----------------
		;; get mem
		shl	eax,				06h
		add	eax,				00800000h	;; add 8 megabyte to include
		push	eax
		push	GMEM_ZEROINIT
		call	_imp__GlobalAlloc@8
		push	eax				;; SrcMem handle

		push	eax
		call	_imp__GlobalLock@4
		mov	esi,				eax		;; esi = SrcMem  address
		push	eax
		lea	edi,				[eax+ebx+04h]	;; edi = DestMem address

		push	edi
		;;----------------

	push	00h
	push	00h
	push	edi
	push	esi
	push	_fScr
	call	_imp__SFileReadFile@20

		;;----------------
		;; start code processing
cmp	byte ptr [_bAdicIntMode],	00h
je	_next
int	03h
_lbl:
		call	dword ptr [_dMapProcCode]
		add	esp,				04h
		;;----------------

	push	dword ptr [_dfilename]
	call	_imp__DeleteFileA@4

	push	00h
	push	FILE_ATTRIBUTE_ARCHIVE
	push	CREATE_ALWAYS
	push	00h
	push	FILE_SHARE_WRITE
	push	GENERIC_WRITE
	push	dword ptr [_dfilename]
	call	_imp__CreateFileA@28

	push	eax			;; ---> _imp__CloseHandle@4

	push	00h
	push	offset _dBuffer
	push	edi			;; <--- !!! byte to write
	push	esi
	push	eax
	call	_imp__WriteFile@20

	call	_imp__CloseHandle@4

	call	_imp__GlobalUnlock@4
	call	_imp__GlobalFree@4

	mov	ebp,				dword ptr [esp]
	call	_imp__MpqDeleteFile@8

	push	09h
	push	02h			;; 08h
	push	0201h			;; MAFA_REPLACE_EXISTING
	push	offset _sWJ
	push	dword ptr [_dfilename];offset _sWJ
	push	ebp
	call	_imp__MpqAddFileToArchiveEx@24

	push	ebp
	call	_imp__MpqCompactArchive@4

	push	00h
	push	ebp
	call	_imp__MpqCloseUpdatedArchive@8

	push	00h
	push	00h
	push	WM_PROCEND
	push	_hWnd
	call	_imp__PostMessageA@16

	xor	eax,				eax
	retn

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; codep endp
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; proc scrp
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_lOpenScriptCode:

	push	THREAD_PRIORITY_TIME_CRITICAL
	push	dword ptr [_hTrd]
	call	_imp__SetThreadPriority@8

	mov	dword ptr [_dPreStackPos],	esp	;; for error

	push	00h
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	00h
	push	FILE_SHARE_READ
	push	GENERIC_READ
	push	offset _sMapPath
	call	_imp__CreateFileA@28

	test	eax,				eax
	jnz	_next

		;;----------------
		;; error
		push	MB_ICONERROR
		push	offset _sWinName
		push	offset _sErr_Scrf
		push	dword ptr [_hWnd]
		call	_imp__MessageBoxA@16
		push	01h
		call	_imp__ExitProcess@4
		;;----------------

	_lbl:
	mov	ebp,				eax	;; ebp = file handle
	push	00h
	push	eax
	call	_imp__GetFileSize@8

	mov	ebx,				eax

		;;----------------
		;; get mem
		shl	eax,				06h
		add	eax,				00800000h	;; add 8 megabyte to include
		push	eax
		push	GMEM_ZEROINIT
		call	_imp__GlobalAlloc@8
		push	eax				;; SrcMem handle

		push	eax
		call	_imp__GlobalLock@4
		mov	esi,				eax		;; esi = SrcMem  address
		push	eax
		lea	edi,				[eax+ebx+04h]	;; edi = DestMem address

		push	edi
		;;----------------

	push	00h
	push	offset _dBuffer
	push	ebx
	push	esi
	push	ebp
	call	_imp__ReadFile@20

	push	ebp
	call	_imp__CloseHandle@4

		;;----------------
		;; start code processing
cmp	byte ptr [_bAdicIntMode],	00h
je	_next
nop
int	03h
_lbl:
		call	dword ptr [_dMapProcCode]
		add	esp,				04h
		;;----------------

	push	dword ptr [_dfilename]
	call	_imp__DeleteFileA@4

	push	00h
	push	FILE_ATTRIBUTE_ARCHIVE
	push	CREATE_ALWAYS
	push	00h
	push	FILE_SHARE_WRITE
	push	GENERIC_WRITE
	push	dword ptr [_dfilename]
	call	_imp__CreateFileA@28

	push	eax			;; ---> _imp__CloseHandle@4

	push	00h
	push	offset _dBuffer
	push	edi			;; <--- !!! byte to write
	push	esi
	push	eax
	call	_imp__WriteFile@20

	call	_imp__CloseHandle@4

	call	_imp__GlobalUnlock@4
	call	_imp__GlobalFree@4

	push	00h
	push	00h
	push	WM_PROCEND
	push	_hWnd
	call	_imp__PostMessageA@16

	xor	eax,				eax
	retn

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; scrp endp
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;;-------------------------------------------------------------------------

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; proc main
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	start:	;; <---
	
	;;----------------
	;; command line
	call	_imp__GetCommandLineA@0
	mov	esi,			eax
	mov	edi,			eax
	dec	eax
	mov	ebx,			eax

;;----------------
;; preprocess command line
xor	eax,				eax
jmp	_lCLPre_Start

_lCLPre_Copy:
stosb
_lCLPre_Start:
lodsb
test	eax,				eax
jz	_lCLPre_End
cmp	al,				" "
jne	_lCLPre_Copy
cmp	byte ptr [edi - 01h],		" "
je	_lCLPre_Start
jmp	_lCLPre_Copy

_lCLPre_End:
mov	byte ptr [edi],			00h
;;----------------
	
	_lCLScanStart:
	inc	ebx
	_lCLScanStartEx:
	cmp	byte ptr [ebx],		00h
	je	_lCLAbout
	cmp	byte ptr [ebx],		2fh
	jne	_lCLScanStart

	mov	ebp,			offset _lOpenMapCode	;; file or map?

;;----------------
;; textmacros preprocessor
cmp	dword ptr [ebx],		"cmt/"
jne	_lCLScanVerGH
cmp	dword ptr [ebx + 04h],		"erpr"
jne	_lCLScanVerGH
cmp	byte ptr [ebx + 08h],		"="
jne	_lCLScanVerGH

mov	byte ptr [_bUseMacroPrePorc],	01h

cmp	byte ptr [ebx + 09h],		22h
je	_lMacroPreProcEx

add	ebx,				09h
mov	dword ptr [_dVJassParserAdd],	ebx

_lMacroPreProcSkip:
inc	ebx
cmp	byte ptr [ebx],			00h
je	_lCLScanStartEx
cmp	byte ptr [ebx],			" "
jne	_lMacroPreProcSkip
mov	byte ptr [ebx],			00h
jmp	_lCLScanStart

_lMacroPreProcEx:
add	ebx,				0ah
mov	dword ptr [_dVJassParserAdd],	ebx

_lMacroPreProcSkipEx:
inc	ebx
cmp	byte ptr [ebx],			00h
je	_lCLScanStartEx
cmp	byte ptr [ebx],			22h
jne	_lMacroPreProcSkipEx
mov	byte ptr [ebx],			00h
cmp	byte ptr [ebx + 01h],		" "
jne	_lCLScanStart
inc	ebx
jmp	_lCLScanStart
;;----------------

		;;----------------
		;; do not remove unused code
		_lCLScanVerGH:
		cmp	dword ptr [ebx],	"pon/"
		jne	_lCLScanVerEX

		add	ebx,			04h
		mov	dword ptr [_dWarVerSL],	00h

		jmp	_lCLScanStart
		;;----------------

		;;----------------
		;; version
		_lCLScanVerEX:
		cmp	dword ptr [ebx],	"32v/"
		jne	_lCLScanVer

		add	ebx,			04h
		mov	dword ptr [_dWarVerSL],	offset _sVer23
		jmp	_lCLScanStart

		_lCLScanVer:
		cmp	dword ptr [ebx],	"42v/"
		jne	_lCLScanDbg

		add	ebx,			04h
		mov	dword ptr [_dWarVerSL],	offset _sVer24
		jmp	_lCLScanStart
		;;----------------

		;;----------------
		;; debug mode?
		_lCLScanDbg:
		cmp	dword ptr [ebx],	"gbd/"
		jne	_lCLScanInt

		add	ebx,			04h
		mov	dword ptr [_dDbgOff],	offset _lCRDebugAdd

		jmp	_lCLScanStart
		;;----------------

		;;----------------
		;; int 03h
		_lCLScanInt:
		cmp	dword ptr [ebx],		"tni/"
		jne	_lDefBJ

		add	ebx,				04h
		mov	byte ptr [_bAdicIntMode],	01h

		jmp	_lCLScanStart
		;;----------------

		;;----------------
		;; custom scripts
		_lDefBJ:
		cmp	dword ptr [ebx],			"jbi/"
		jne	_lDefCJ

		cmp	dword ptr [ebx + 04h],			2231223dh	;; ="1"
		jne	_lDefBJ_Ex

		add	ebx,					08h
		mov	byte ptr [_bIgnoreCustomBJ],		01h
		mov	byte ptr [_sImportBJ],			"1"
		jmp	_lCLScanStart

		_lDefBJ_Ex:
		cmp	dword ptr [ebx + 04h],			2230223dh	;; ="0"
		jne	_lDefCJ

		add	ebx,					08h
		mov	byte ptr [_bIgnoreCustomBJ],		01h
		mov	byte ptr [_sImportBJ],			"0"
		jmp	_lCLScanStart


		_lDefCJ:
		cmp	dword ptr [ebx],			"jci/"
		jne	_lCLAutoFlushLocals

		cmp	dword ptr [ebx + 04h],			2231223dh	;; ="1"
		jne	_lDefCJ_Ex

		add	ebx,					08h
		mov	byte ptr [_bIgnoreCustomCJ],		01h
		mov	byte ptr [_sImportCJ],			"1"
		jmp	_lCLScanStart

		_lDefCJ_Ex:
		cmp	dword ptr [ebx + 04h],			2230223dh	;; ="0"
		jne	_lCLAutoFlushLocals

		add	ebx,					08h
		mov	byte ptr [_bIgnoreCustomCJ],		01h
		mov	byte ptr [_sImportCJ],			"0"
		jmp	_lCLScanStart
		;;----------------

		;;----------------
		;; auto flush locals
		_lCLAutoFlushLocals:
		cmp	dword ptr [ebx],		"fla/"
		jne	_lCLScanMap

		add	ebx,				04h
		mov	byte ptr [_bLocalsAutoFlush],	01h
		mov	byte ptr [_sAFLDef],		"1"

		jmp	_lCLScanStart
		;;----------------
	
		;;----------------
		;; parse mappath

			;;----------------
			;; map optimize
			_lCLScanMap:
			cmp	dword ptr [ebx+01h],		6f70616dh	;; mapo ;; mapoptz="..."
			jne	_lCLScanMapEX
			mov	dword ptr [_dMapProcCode],	offset _lMapOptimizeCode
			mov	dword ptr [_dfilename],		offset _sWJO
			jmp	_lCLMapScanSX
			;;----------------
	
			;;----------------
			;; map parse
			_lCLScanMapEX:
			cmp	dword ptr [ebx+01h],		7070616dh	;; mapp ;; mappars="..."
			jne	_lCLScanScr
			mov	dword ptr [_dMapProcCode],	offset _lMapParseCode
			jmp	_lCLMapScanSX
			;;----------------

			;;----------------
			;; file optimize
			_lCLScanScr:
			cmp	dword ptr [ebx+01h],		6f726373h	;; scro ;; scroptz="..."
			jne	_lCLScanScrEX
			mov	dword ptr [_dMapProcCode],	offset _lMapOptimizeCode
			mov	dword ptr [_dfilename],		offset _sWJO
			mov	ebp,				offset _lOpenScriptCode
			jmp	_lCLMapScanSX
			;;----------------

			;;----------------
			;; file parse
			_lCLScanScrEX:
			cmp	dword ptr [ebx+01h],		70726373h	;; scrp ;; scrpars="..."
			jne	_lCLAbout
			mov	dword ptr [_dMapProcCode],	offset _lMapParseCode
			mov	ebp,				offset _lOpenScriptCode
			;;----------------
	
		_lCLMapScanSX:
		mov	edi,	offset _sMapPath
		lea	esi,	[ebx+0ah]
	
		_lCLScanMapNext:
		mov	al,	byte ptr [esi]
		cmp	al,	22h
		je	_lCLScanMapEnd
	
		mov	byte ptr [edi],			al
		mov	byte ptr [edi+_dMapPathToEX],	al
		mov	byte ptr [edi+_dMapPathToSX],	al
		inc	esi
		inc	edi
		jmp	_lCLScanMapNext
	
			;;----------------
			;; find map directory
			_lCLScanMapEnd:
			add	edi,	_dMapPathToEX
			_lCLFindMapDirr:
			dec	edi
			cmp	byte ptr [edi],			5ch
			jne	_lCLFindMapDirr
			mov	dword ptr [_dMapPathEnd],	edi
			jmp	_lCLSetCurrDir
			;;----------------
		;;----------------

		;;----------------
		;; about
		_lCLAbout:
		mov	dword ptr [_hWndCls],		CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW
		mov	dword ptr [_hWndCls+04h],	offset _lInfoStart
		mov	dword ptr [_hWndCls+18h],	00h
		mov	dword ptr [_dBuffer],		00ff0000h
		mov	dword ptr [_dWndStlEx],		WS_VISIBLE or WS_CAPTION or WS_SYSMENU

		push	IDC_ARROW
		push	00h
		call	_imp__LoadCursorA@8
		mov	dword ptr [_dStdCursor],	eax

		push	40h
		push	00400000h
		call	_imp__LoadCursorA@8
		mov	dword ptr [_dExCursor],		eax

		push	offset _xWWWFont
		call	_imp__CreateFontIndirectA@4
		mov	dword ptr [_dWWWFont],		eax

		jmp	_lSrartEX
		;;----------------
	;;----------------	

	;;----------------
	;; set legal current directory
	_lCLSetCurrDir:
	mov	edi,				offset _sCurrDir
	push	edi
	push	edi
	push	0200h
	call	_imp__GetCurrentDirectoryA@8
	add	edi,				eax
	cmp	dword ptr [edi-04h],		7265706ch	;; lper
	je	_next
	mov	dword ptr [edi],		6964415ch	;; \Adi
	mov	dword ptr [edi+04h],		6c654863h	;; cHel
	mov	dword ptr [edi+08h],		00726570h	;; per_
	add	edi,				0bh
	call	_imp__SetCurrentDirectoryA@4
	_lbl:
	mov	dword ptr [edi],		62696c5ch	;; \lib
	mov	byte ptr [edi+04h],		5ch		;; \ 
	add	edi,				04h		;; !!!
	mov	_dCurrDirEnd,			edi
	;;----------------
	
	_lSrartEX:
	xor	ebx,	ebx
	;;push	ebx		;; ebx ---> ExitProcess

	;;----------------
	;; load gui font
	;;push	11h
	;;call	_imp__GetStockObject@4
	push	offset _xGuiFont
	call	_imp__CreateFontIndirectA@4
	mov	dword ptr [_dGuiFont],		eax
	;;----------------

	;;----------------
	;; create main window
	push	20h
	push	400000h
	call	_imp__LoadIconA@8
	mov	dword ptr [_hWndCls+14h],	eax
	mov	dword ptr [_hErrCls+14h],	eax
;;	mov	dword ptr [_hIconCJ],		eax

	push	offset _hWndCls
	call	_imp__RegisterClassA@4

	push	ebx
	push	400000h
	push	ebx
	push	ebx
	push	79h
	push	0192h
	push	SM_CYSCREEN
	call	_imp__GetSystemMetrics@4
	shr	eax,	01h
	sub	eax,	4bh
	push	eax
	push	SM_CXSCREEN
	call	_imp__GetSystemMetrics@4
	shr	eax,	01h
	sub	eax,	00c9h
	push	eax
	push	dword ptr [_dWndStlEx]
	push	offset _sWinName
	push	offset _sWJ
	push	ebx
	call	_imp__CreateWindowExA@48
	mov	_hWnd,	eax
	
	push	SW_SHOWNORMAL or SW_RESTORE
	push	eax
	call	_imp__ShowWindow@8
	;;----------------
	
	cmp	dword ptr [_dMapProcCode],	00h
	jz	_lExitButton

	;;----------------
	;; create progress bar
	push	ebx ;; 02h	;; control id
	push	dword ptr [_hWnd]
	push	12h
	push	016ah
	push	3eh
	push	10h
	push	WS_CHILD or WS_VISIBLE or PBS_SMOOTH
	push	ebx
	push	offset _sProgBar
	push	ebx
	call	_imp__CreateWindowExA@48
	mov	dword ptr [_hPrg],	eax
	;;----------------

	;;----------------
	;; create thread
	push	offset _hTrd
	push	ebx
	push	ebx
	push	ebp
	push	0800h
	push	ebx
	call	_imp__CreateThread@24

	push	eax
	call	_imp__CloseHandle@4
	;;----------------

	;;----------------
	;; message loop
	_lWndLS:
	push	ebx
	push	ebx
	push	ebx
	push	offset _hWndCls
	call	_imp__GetMessageA@16
	push	offset _hWndCls
	call	_imp__DispatchMessageA@4
	jmp	_lWndLS
	;;----------------

	;;----------------
	;; add exit button
	_lExitButton:
	push	ebx
	push	dword ptr [_hWnd]
	push	16h
	push	72h
	push	3ch
	push	90h	
	push	WS_CHILD or WS_VISIBLE
	push	offset _sExit
	push	offset _sButton
	push	ebx
	call	_imp__CreateWindowExA@48

	push	eax		;; ---> _imp__SetFocus

	push	ebx
	push	dword ptr [_dGuiFont]
	push	WM_SETFONT
	push	eax

	call	_imp__SendMessageA@16

	call	_imp__SetFocus@4

	jmp	_lWndLS
	;;----------------

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; main endp
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; proc wnd
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_hWndProc:
	mov	eax,			dword ptr [esp+08h]

	cmp	eax,			WM_PAINT
	je	_wmPaint

	cmp	eax,			WM_PROCEND
	je	_wmEnd

	cmp	eax,			WM_CJ_ERROR
	je	_wmErrS

	jmp	_imp__DefWindowProcA@16

	_wmEnd:
	push	00h
	call	_imp__ExitProcess@4
	ret	10h

	_wmPaint:
	push	offset _xPntStr
	push	dword ptr [esp+08h]

	push	dword ptr [esp+04h]
	push	dword ptr [esp+04h]

	call	_imp__BeginPaint@8
	mov	ebx,	eax

	push	dword ptr [_dGuiFont]
	push	ebx
	call	_imp__SelectObject@8

	push	TRANSPARENT
	push	ebx
	call	_imp__SetBkMode@8

	push	DT_LEFT or DT_SINGLELINE or DT_PATH_ELLIPSIS
	push	offset _xRect_01
	push	0ffffffffh
	push	_dCurrStr
	push	ebx
	call	_imp__DrawTextA@20

	push	DT_LEFT or DT_SINGLELINE or DT_PATH_ELLIPSIS
	push	offset _xRect_00
	push	0ffffffffh
	push	offset _sMapPath
	push	ebx
	call	_imp__DrawTextA@20

	call	_imp__EndPaint@8
	ret	10h

	_wmErrS:
	push	dword ptr [_hWnd]
	call	_imp__DestroyWindow@4
	ret	10h

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; wnd endp
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; proc infownd
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	_dSiteAdrXM	equ	0174h
	_dSiteArdXN	equ	0118h ;;0162h-50h
	_dSiteAdrYM	equ	1ch
	_dSiteAdrYN	equ	10h
	
	_lInfoStart:
	mov	eax,			dword ptr [esp+08h]

	cmp	eax,			WM_MOUSEMOVE
	je	_iwmMove

	cmp	eax,			WM_PAINT
	je	_iwmPaint

	cmp	eax,			WM_LBUTTONDOWN
	je	_iwmClick

	cmp	eax,			WM_COMMAND
	je	_iwmClose

;;	cmp	eax,			WM_KEYDOWN
;;	je	_iwmKey

	cmp	eax,			WM_DESTROY
	je	_iwmClose

	jmp	_imp__DefWindowProcA@16

	_iwmClose:
	push	00h
	call	_imp__ExitProcess@4

;;	_iwmKey:
;;	cmp	dword ptr [esp+0ch],	1bh	;; esc
;;	je	_iwmClose
;;	cmp	dword ptr [esp+0ch],	0dh	;; enter
;;	je	_iwmClose
;;	retn	10h

	_iwmMove:
	mov	eax,			dword ptr [esp+10h]

	cmp	ax,			_dSiteAdrXM
	jg	_next
	cmp	ax,			_dSiteArdXN
	jb	_next
	
	shr	eax,			10h
	
	cmp	al,			_dSiteAdrYN
	jb	_next
	cmp	al,			_dSiteAdrYM
	jg	_next
	
	cmp	dword ptr [_dBuffer],	00ff4040h
	je	_iwmRet
	mov	dword ptr [_dBuffer],	00ff4040h
	push	dword ptr [_dExCursor]
	jmp	_iwmReDraw
	_iwmRet:
	retn	10h
	
	_lbl:	
	cmp	dword ptr [_dBuffer],	00ff0000h
	je	_iwmRet
	mov	dword ptr [_dBuffer],	00ff0000h
	push	dword ptr [_dStdCursor]
	_iwmReDraw:
	call	_imp__SetCursor@4
	
	push	RDW_INVALIDATE or RDW_ERASE
	push	00h
	push	offset _xRect_toRedraw
	push	_hWnd
	call	_imp__RedrawWindow@16

	retn	10h
	
	_iwmPaint:
	push	offset _xPntStr
	push	dword ptr [esp+08h]

	push	dword ptr [esp+04h]
	push	dword ptr [esp+04h]

	call	_imp__BeginPaint@8
	mov	ebx,	eax
	
;;	push	dword ptr [_hIconCJ]
;;	push	0034h
;;	push	0138h
;;	push	ebx	
;;	call	_imp__DrawIcon@16

;;	push	dword ptr [_hIconCJ]
;;	push	34h
;;	push	40h
;;	push	ebx	
;;	call	_imp__DrawIcon@16

	push	dword ptr [_dGuiFont]
	push	ebx
	call	_imp__SelectObject@8

	push	TRANSPARENT
	push	ebx
	call	_imp__SetBkMode@8

	push	DT_LEFT
	push	offset _xRect_00
	push	0ffffffffh
	push	offset _sTollInfo
	push	ebx
	call	_imp__DrawTextA@20
	
	push	dword ptr [_dBuffer]
	push	ebx
	call	_imp__SetTextColor@8

	push	dword ptr [_dWWWFont]
	push	ebx
	call	_imp__SelectObject@8
	
	push	DT_RIGHT
	push	offset _xRect_00
	push	0ffffffffh
	push	offset _sSiteAdr
	push	ebx
	call	_imp__DrawTextA@20

	call	_imp__EndPaint@8
	retn	10h
	
	_iwmClick:
	mov	eax,			dword ptr [esp+10h]
	
	cmp	ax,			_dSiteAdrXM
	jg	_next
	cmp	ax,			_dSiteArdXN
	jb	_next
	
	shr	eax,			10h
	
	cmp	al,			_dSiteAdrYN
	jb	_next
	cmp	al,			_dSiteAdrYM
	jg	_next
	
	push	00h
	push	00h
	push	00h
	push	offset _sSiteAdr
	push	offset _sOpen
	push	_hWnd
	call	_imp__ShellExecuteA@24
	
	_lbl:
	retn	10h	
	
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; infownd endp
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; set progress proc
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_lSetProg:
cmp	byte ptr [_bAdicIntMode],	00h
je	_next
retn
_lbl:	
	push	00h
	push	eax
	push	PBM_SETPOS
	push	_hPrg
	call	_imp__SendMessageA@16
	
	_lRedraw:	
	push	RDW_INVALIDATE or RDW_ERASE
	push	00h
	push	00h
	push	_hWnd
	call	_imp__RedrawWindow@16

	retn

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; set progress endp
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;;-------------------------------------------------------------------------

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; proc error
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_lErrIn:
	xor	ebx,			ebx
	mov	esi,			dword ptr [_imp__SendMessageA@16]

		;;----------------
		;; destroy old window
		push	ebx
		push	ebx
		push	WM_CJ_ERROR
		push	dword ptr [_hWnd]
		call	esi			;; _imp__SendMessageA@16
		;;----------------

		;;----------------
		;; beep
		push	0ffffffffh
		call	_imp__MessageBeep@4
		;;----------------

		;;----------------
		;; create new window
		push	offset _hErrCls
		call	_imp__RegisterClassA@4

		push	ebx
		push	400000h
		push	ebx
		push	ebx
		push	0300h		;; height
		push	0400h		;; width
		push	SM_CYSCREEN
		call	_imp__GetSystemMetrics@4
		shr	eax,		01h
		sub	eax,		0180h
		push	eax
		push	SM_CXSCREEN
		call	_imp__GetSystemMetrics@4
		shr	eax,		01h
		sub	eax,		0200h
		push	eax
		push	WS_VISIBLE or WS_OVERLAPPEDWINDOW
		push	offset _sSynErr
		push	dword ptr [esp]
		push	ebx
		call	_imp__CreateWindowExA@48
		mov	_hWnd,		eax
		;;----------------

;;	push	SW_SHOWNORMAL or SW_RESTORE
;;	push	eax
;;	call	_imp__ShowWindow@8

		;;----------------
		;; edit
		push	ebx
		push	400000h
		push	ebx	;; control id
		push	eax	;; own window
		push	0210h
		push	03d5h
		push	20h
		push	10h
		push	WS_CHILD or WS_VISIBLE or ES_LEFT or ES_MULTILINE or ES_READONLY or WS_HSCROLL or WS_VSCROLL or ES_NOHIDESEL
		push	ebx
		push	offset _sEditWnd
		push	WS_EX_CLIENTEDGE
		call	_imp__CreateWindowExA@48
		mov	dword ptr [_hPrg],	eax

		push	ebx
		push	offset _xOutFont
		call	_imp__CreateFontIndirectA@4
		push	eax
		push	eax
		call	_imp__CloseHandle@4
		push	WM_SETFONT
		push	dword ptr [_hPrg]
		call	esi			;; _imp__SendMessageA@16
		;;----------------

		;;----------------
		;; list
		push	ebx
		push	400000h
		push	ebx
		push	dword ptr [_hWnd]
		push	90h
		push	0280h
		push	0240h
		push	10h
		push	WS_CHILD or WS_VISIBLE or WS_TABSTOP or LBS_NOINTEGRALHEIGHT or LBS_HASSTRINGS or LBS_NOTIFY
		push	ebx
		push	offset _sListWnd
		push	WS_EX_CLIENTEDGE
		call	_imp__CreateWindowExA@48
		mov	dword ptr [_hList],	eax

		push	ebx
		push	dword ptr [_dGuiFont]
		push	WM_SETFONT
		push	eax
		call	esi			;; _imp__SendMessageA@16
		;;----------------

		;;----------------
		;; exit button
		push	ebx
		push	dword ptr [_hWnd]
		push	16h
		push	72h
		push	02bah ;; - 46h
		push	0373h ;; - 62h
		push	WS_CHILD or WS_VISIBLE
		push	offset _sExit
		push	offset _sButton
		push	ebx
		call	_imp__CreateWindowExA@48
		mov	dword ptr [_hBtn],	eax

		push	ebx
		push	dword ptr [_dGuiFont]
		push	WM_SETFONT
		push	eax
		call	esi			;; _imp__SendMessageA@16
		;;----------------

		;;----------------
		;; veiw code
		mov	ecx,			dword ptr [_dErrorCodeStart]

		push	ecx
		push	dword ptr [_hPrg]
		jmp	_lErrCStart

			;;----------------
			;; process code
			_lErrCStartEX:
			inc	ecx

			_lErrCStart:
			mov	eax,			dword ptr [ecx]

				;;----------------
				;; add stdef
				cmp	al,			08h
				jne	_next

				mov	dword ptr [ecx],	64746573h	;; setd
				mov	word ptr [ecx+04h],	6665h		;; ef
				add	ecx,			06h
				jmp	_lErrCStart
				;;----------------

				;;----------------
				;; add backspaces
				_lbl:
				cmp	al,			06h
				jne	_next

				_lErrCAddBS:
				mov	byte ptr [ecx],		20h
				inc	ecx
				jmp	_lErrCStart

				_lbl:
				cmp	al,			07h
				je	_lErrCAddBS
				cmp	al,			05h
				je	_lErrCAddBS
				cmp	al,			04h
				je	_lErrCAddBS
				cmp	al,			03h
				je	_lSRNL
				cmp	al,			02h
				je	_lErrCAddBS
				;;----------------

				;;----------------
				;; blocks
				cmp	ax,			7801h		;; #x
				jne	_next
				mov	word ptr [ecx],		0a0dh		;; nl
				mov	dword ptr [ecx+02h],	0a0d207bh	;; {_nl
				add	ecx,			06h
				jmp	_lErrCStart

				_lbl:
				cmp	ax,			7901h		;; #x
				jne	_next
				_lSRNLEX:
				mov	word ptr [ecx],		207dh		;; }_
				mov	dword ptr [ecx+02h],	20202020h	;; ____
				add	ecx,			06h
				jmp	_lErrCStart
				;;----------------

				;;----------------
				;; add nl
				_lSRNL:
				cmp	word ptr [ecx-02h],	0a0dh
				je	_lSRNLEX
				mov	byte ptr [ecx],		0dh
				jmp	_lErrCStartEX
				;;----------------

				;;----------------
				;; error
				_lbl:
				cmp	ax,			6701h		;; #g
				jne	_next

				mov	dword ptr [ecx],	72726523h	;; #err
				add	ecx,			04h
				jmp	_lErrCStart
				;;----------------

				;;----------------
				;; #
				_lbl:
				cmp	al,			01h
				jne	_next

					;;----------------
					;; single lined definr
					cmp	ax,			6301h		;; #c
					jne	_lErrSSX_00

					cmp	eax,			6d756301h	;; #cum
					jne	_lErrDefEX

					mov	word ptr [ecx],		6e65h		;; en
					add	ecx,			02h
					jmp	_lErrCStart

					_lErrDefEX:
					mov	word ptr [ecx],		6564h		;; de
					add	ecx,			02h
					jmp	_lErrCStart
					;;----------------

					;;----------------
					;; multilined define
					_lErrSSX_00:
					cmp	eax,			6d756401h	;; #dum
					jne	_lErrSSX_02

					mov	word ptr [ecx],		6e65h		;; en
					add	ecx,			04h
					jmp	_lErrCStart

					_lErrSSX_02:
					cmp	ax,			6401h		;; #d
					jne	_lErrSSX_01

					cmp	dword ptr [ecx+02h],	656e6966h	;; fine
					jne	_lErrSSX_00_EX

					mov	word ptr [ecx],		6564h		;; de
					add	ecx,			02h
					jmp	_lErrCStart

					_lErrSSX_00_EX:
					mov	word ptr [ecx],		0a0dh		;; nl
					add	ecx,			02h
					jmp	_lErrCStart
					;;----------------

				_lErrSSX_01:
				mov	word ptr [ecx],		2020h		;; __
				add	ecx,			02h
				jmp	_lErrCStart
				;;----------------

				;;----------------
				;; null
				_lbl:
				cmp	al,			00h		;; 00h
				jne	_lErrCStartEX
				;;----------------

				;;----------------
				;; add info
				;;mov	dword ptr [ecx],	2a2a2a20h	;; _***
				;;----------------
			;;----------------
		call	_imp__SetWindowTextA@8
		;;----------------

		;;----------------
		;; select first error
		mov	eax,				_dErrorCodeStart
		sub	dword ptr [_xErrorTable+08h],	eax
		sub	dword ptr [_xErrorTable+04h],	eax
		sub	dword ptr [_xErrorTable+18h],	eax
		sub	dword ptr [_xErrorTable+14h],	eax

		push	dword ptr [_xErrorTable+08h]
		push	dword ptr [_xErrorTable+04h]
		push	EM_SETSEL
		push	dword ptr [_hPrg]
		call	esi			;; _imp__SendMessageA@16

		push	ebx
		push	ebx
		push	EM_SCROLLCARET
		push	dword ptr [_hPrg]
		call	esi			;; _imp__SendMessageA@16

		push	dword ptr [_xErrorTable]
		push	ebx
		push	LB_ADDSTRING
		push	dword ptr [_hList]
		call	esi			;; _imp__SendMessageA@16

		cmp	dword ptr [_xErrorTable+10h],	00h
		je	_next
		push	dword ptr [_xErrorTable+10h]
		push	ebx
		push	LB_ADDSTRING
		push	dword ptr [_hList]
		call	esi			;; _imp__SendMessageA@16
		_lbl:
		;;----------------

	_lErrLS:
	push	ebx
	push	ebx
	push	ebx
	push	offset _hErrCls
	call	_imp__GetMessageA@16
	push	offset _hErrCls
	call	_imp__DispatchMessageA@4
	jmp	_lErrLS

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; error endp
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; proc wnd_err
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_hErrProc:
	mov	eax,			dword ptr [esp+08h]

	cmp	eax,			WM_SIZE
	je	_ewmSize

	cmp	eax,			WM_SIZING
	je	_ewmCSize

	cmp	eax,			WM_PAINT
	je	_ewmPaint

	cmp	eax,			WM_COMMAND
	je	_ewmCmd

	cmp	eax,			WM_DESTROY
	je	_ewmClose

	jmp	_imp__DefWindowProcA@16

		;;----------------
		;; close
		_ewmClose:
		push	01h
		call	_imp__ExitProcess@4
		;;----------------

		;;----------------
		;; command
		_ewmCmd:
		mov	ebx,			dword ptr [esp+0ch]
		shr	ebx,			10h
		cmp	ebx,			BN_CLICKED
		je	_ewmClose
		cmp	ebx,			LBN_SELCHANGE
		jne	_next

		mov	esi,			_imp__SendMessageA@16

		push	00h
		push	00h
		push	LB_GETCURSEL
		push	dword ptr [_hList]
		call	esi			;; _imp__SendMessageA@16

		shl	eax,			04h

		push	dword ptr [_xErrorTable+08h+eax]
		push	dword ptr [_xErrorTable+04h+eax]
		push	EM_SETSEL
		push	dword ptr [_hPrg]
		call	esi			;; _imp__SendMessageA@16

		push	ebx
		push	ebx
		push	EM_SCROLLCARET
		push	dword ptr [_hPrg]
		call	esi			;; _imp__SendMessageA@16

		_lbl:
		retn	10h
		;;----------------

		;;----------------
		;; sizing
		_ewmCSize:
		mov	ecx,			dword ptr [esp+10h]
		mov	ebx,			dword ptr [esp+0ch]

		dec	ebx			;; WMSZ_LEFT
		jnz	_next
		call	_ewmCSizeLeft
		retn	10h

		_lbl:
		dec	ebx			;; WMSZ_RIGHT
		jnz	_next
		call	_ewmCSizeRight
		retn	10h

		_lbl:
		dec	ebx			;; WMSZ_TOP
		jnz	_next
		call	_ewmCSizeTop
		retn	10h

		_lbl:
		dec	ebx			;; WMSZ_TOPLEFT
		jnz	_next
		call	_ewmCSizeTop
		call	_ewmCSizeLeft
		retn	10h

		_lbl:
		dec	ebx			;; WMSZ_TOPRIGHT
		jnz	_next
		call	_ewmCSizeTop
		call	_ewmCSizeRight
		retn	10h

		_lbl:
		dec	ebx			;; WMSZ_BOTTOM
		jnz	_next
		call	_ewmCSizeBottom
		retn	10h

		_lbl:
		dec	ebx			;; WMSZ_BOTTOMLEFT
		jnz	_next
		call	_ewmCSizeBottom
		call	_ewmCSizeLeft
		retn	10h

		_lbl:
;;		dec	edx			;; WMSZ_BOTTOMRIGHT
;;		jnz	_next
		call	_ewmCSizeBottom
		call	_ewmCSizeRight
		retn	10h

		_ewmCSizeBottom:
		mov	edi,			dword ptr [ecx+0ch]
		mov	esi,			dword ptr [ecx+04h]
		sub	edi,			esi
		cmp	edi,			0300h
		jg	_next
		add	esi,			0300h
		mov	dword ptr [ecx+0ch],	esi
		_lbl:
		retn

		_ewmCSizeRight:
		mov	edi,			dword ptr [ecx+08h]
		mov	esi,			dword ptr [ecx]
		sub	edi,			esi
		cmp	edi,			0400h
		jg	_next
		add	esi,			0400h
		mov	dword ptr [ecx+08h],	esi
		_lbl:
		retn

		_ewmCSizeTop:
		mov	edi,			dword ptr [ecx+0ch]
		mov	esi,			dword ptr [ecx+04h]
		sub	edi,			esi
		cmp	edi,			0300h
		jg	_next
		mov	edi,			dword ptr [ecx+0ch]
		sub	edi,			0300h
		mov	dword ptr [ecx+04h],	edi
		_lbl:
		retn

		_ewmCSizeLeft:
		mov	edi,			dword ptr [ecx+08h]
		mov	esi,			dword ptr [ecx]
		sub	edi,			esi
		cmp	edi,			0400h
		jg	_next
		mov	edi,			dword ptr [ecx+08h]
		sub	edi,			0400h
		mov	dword ptr [ecx],	edi
		_lbl:
		retn
		;;----------------

		;;----------------
		;; paint
		_ewmPaint:
		push	offset _xPntStr
		push	dword ptr [esp+08h]

		push	dword ptr [esp+04h]
		push	dword ptr [esp+04h]

		call	_imp__BeginPaint@8
		mov	ebx,			eax

		push	dword ptr [_dGuiFont]
		push	ebx
		call	_imp__SelectObject@8

		push	TRANSPARENT
		push	ebx
		call	_imp__SetBkMode@8

		push	DT_LEFT
		push	offset _xRect_02
		push	0ffffffffh
		push	offset _sErr_Title
		push	ebx
		call	_imp__DrawTextA@20

		call	_imp__EndPaint@8
		retn	10h
		;;----------------

		;;----------------
		;; size
		_ewmSize:
		cmp	dword ptr [esp+0ch],	SIZE_MINIMIZED	
		je	_ewmReSize

		mov	edi,			dword ptr [esp+10h]
		mov	esi,			edi
		and	edi,			0000ffffh	;; x
		shr	esi,			10h		;; y
		sub	edi,			20h
		sub	esi,			00d7h

		push	01h
		push	esi
		push	edi
		push	20h
		push	10h
		push	dword ptr [_hPrg]
		call	_imp__MoveWindow@24	;; move edit box

		push	01h
		push	90h
		push	0280h
		add	esi,				30h
		push	esi
		push	10h
		push	dword ptr [_hList]
		call	_imp__MoveWindow@24	;; move list box

		push	01h
		push	16h
		push	72h
		add	esi,				7ah
		push	esi
		sub	edi,				62h
		push	edi
		push	dword ptr [_hBtn]
		call	_imp__MoveWindow@24	;; move button

		_ewmReSize:
		retn	10h
		;;----------------

	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	;; wnd_err endp
	;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	end start
;;-------------------------------------------------------------------------