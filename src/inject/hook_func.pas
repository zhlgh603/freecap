{*
 * File: ...................... hook_func.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Hooking mandatory functions

 $Id: hook_func.pas,v 1.10 2005/12/19 06:09:02 bert Exp $

 $Log: hook_func.pas,v $
 Revision 1.10  2005/12/19 06:09:02  bert
 *** empty log message ***
}
unit hook_func;

interface
uses Windows, Messages, Classes, ImageHlp, SysUtils, loger, ws_hook, winsock2, cfg, misc, psapi,
     shellapi, Injector, win9x, packdll{$IFDEF DEBUG}, jcldebug{$ENDIF}, export_hook;

type
    TMandatoryFunction = record
       fnOrig  : Pointer;  // Pointer to original function entry point
       fnNew   : Pointer;  // Pointer to hook procedure
       fnName  : PChar;    // Name of original function
       fnModule: PChar;    // Module which contains this functions in exports section
       bFlag   : Boolean;
    end;


   procedure InstallHookToHandle(hMod: HMODULE);

   function Hook_LoadLibraryA(lpLibFileName: PAnsiChar): HMODULE; stdcall;


   function Hook_VirtualProtect(lpAddress: Pointer; dwSize, flNewProtect: DWORD;
    lpflOldProtect: Pointer): BOOL; stdcall;
   function Hook_VirtualAlloc(lpvAddress: Pointer; dwSize, flAllocationType, flProtect: DWORD): Pointer; stdcall;
   function Hook_VirtualQuery(lpAddress: Pointer; var lpBuffer: TMemoryBasicInformation; dwLength: DWORD): DWORD; stdcall;
   function Hook_VirtualQueryEx(hProcess: THandle; lpAddress: Pointer; var lpBuffer: TMemoryBasicInformation; dwLength: DWORD): DWORD; stdcall;


   function Hook_LoadLibraryW(lpLibFileName: PWideChar): HMODULE; stdcall;
   function Hook_LoadLibraryExA(lpLibFileName: PAnsiChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
   function Hook_LoadLibraryExW(lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
   function Hook_FreeLibrary(hLibModule: HMODULE): BOOL; stdcall;
   procedure Hook_FreeLibraryAndExitThread(hLibModule: HMODULE; dwExitCode: DWORD); stdcall;
   function Hook_GetProcAddress(LibHandle: HMODULE; FuncName: PChar): FARPROC; stdcall;
   function second_GetProcAddress(ret_addr: Pointer; LibHandle: HMODULE; FuncName: PChar): FARPROC; //stdcall;

   {* Misc  *}
   function Hook_CreateProcessA(lpApplicationName: PAnsiChar; lpCommandLine: PAnsiChar;
     lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
     bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer;
     lpCurrentDirectory: PAnsiChar; const lpStartupInfo: TStartupInfo;
     var lpProcessInformation: TProcessInformation): BOOL; stdcall;
   function Hook_CreateProcessW(lpApplicationName: PWideChar; lpCommandLine: PWideChar;
     lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
     bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer;
     lpCurrentDirectory: PWideChar; const lpStartupInfo: TStartupInfo;
     var lpProcessInformation: TProcessInformation): BOOL; stdcall;

   function Hook_SetWindowTextA(Handle: HWND; lpString: PAnsiChar): Boolean; stdcall;
   function Hook_SetWindowTextW(Handle: HWND; lpString: PWideChar): Boolean; stdcall;

   function Hook_SetConsoleTitleA(lpString: PAnsiChar): Boolean; stdcall;
   function Hook_SetConsoleTitleW(lpString: PWideChar): Boolean; stdcall;

   function Hook_DefWindowProcA(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
   function Hook_DefWindowProcW(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

   function Hook_ShowWindow(hWnd: HWND; nCmdSHow: integer): Boolean; stdcall;

   function Hook_GetFileVersionInfoA(lptstrFilename: PAnsiChar; dwHandle, dwLen: DWORD; lpData: Pointer): BOOL; stdcall;


//   {$I psapi_h.inc}

var
   bReloaded: Boolean = False;

   MandatoryFunctions: array[0..15 + 2 {+ 18}]  of TMandatoryFunction = (
     {* Mandatory functions. *}

     (fnOrig : nil; fnNew: @Hook_LoadLibraryA; fnName: 'LoadLibraryA'; fnModule: 'kernel32.dll'; bFlag: False),
     (fnOrig : nil; fnNew: @Hook_LoadLibraryW; fnName: 'LoadLibraryW'; fnModule: 'kernel32.dll'; bFlag: False),
     (fnOrig : nil; fnNew: @Hook_LoadLibraryExA; fnName: 'LoadLibraryExA'; fnModule: 'kernel32.dll'; bFlag: False),
     (fnOrig : nil; fnNew: @Hook_LoadLibraryExW; fnName: 'LoadLibraryExW'; fnModule: 'kernel32.dll'; bFlag: False),
     (fnOrig : nil; fnNew: @Hook_FreeLibrary; fnName: 'FreeLibrary'; fnModule: 'kernel32.dll'; bFlag: False),
     (fnOrig : nil; fnNew: @Hook_FreeLibraryAndExitThread; fnName: 'FreeLibraryAndExitThread'; fnModule: 'kernel32.dll'; bFlag: False),
     (fnOrig : nil; fnNew: @Hook_GetProcAddress; fnName: 'GetProcAddress'; fnModule: 'kernel32.dll'; bFlag: True),

     (fnOrig : nil; fnNew: @Hook_VirtualQuery; fnName: 'VirtualQuery'; fnModule: 'kernel32.dll'; bFlag: False),
     (fnOrig : nil; fnNew: @Hook_VirtualQueryEx; fnName: 'VirtualQueryEx'; fnModule: 'kernel32.dll'; bFlag: False),
      {* non-mandatory functions *}

     (fnOrig : nil; fnNew: @Hook_SetWindowTextA; fnName: 'SetWindowTextA'; fnModule: 'user32.dll'; bFlag: False),
     (fnOrig : nil; fnNew: @Hook_SetWindowTextW; fnName: 'SetWindowTextW'; fnModule: 'user32.dll'; bFlag: False),

     (fnOrig : nil; fnNew: @Hook_SetConsoleTitleA; fnName: 'SetConsoleTitleA'; fnModule: 'kernel32.dll'; bFlag: False),
     (fnOrig : nil; fnNew: @Hook_SetConsoleTitleW; fnName: 'SetConsoleTitleW'; fnModule: 'kernel32.dll'; bFlag: False),

     (fnOrig : nil; fnNew: @Hook_DefWindowProcA; fnName: 'DefWindowProcA'; fnModule: 'user32.dll'; bFlag: False),
     (fnOrig : nil; fnNew: @Hook_DefWindowProcW; fnName: 'DefWindowProcW'; fnModule: 'user32.dll'; bFlag: False),
     (fnOrig : nil; fnNew: @Hook_ShowWindow; fnName: 'ShowWindow'; fnModule: 'user32.dll'; bFlag: False),

     (fnOrig : nil; fnNew: @Hook_CreateProcessA; fnName: 'CreateProcessA'; fnModule: 'kernel32.dll'; bFlag: False),
     (fnOrig : nil; fnNew: @Hook_CreateProcessW; fnName: 'CreateProcessW'; fnModule: 'kernel32.dll'; bFlag: False)

   );


implementation
uses hook;

const
   TF      : array [False..True] of string = ('False', 'True');
   sFreeCap: string = ' via FreeCap';

function isStringPresent(sStr: PChar): boolean;
begin
     result := (pos(sFreeCap, sStr) > 0);
end;

{$IFDEF DEBUG}
function GetProcByAddr(Addr: Pointer): string;
var
   File_, Module_, Proc_: string;
   Line_: integer;
begin
     MapOfAddr(Addr, File_, Module_, Proc_, Line_);
     result := Format('%s::%s::%s (%d)', [File_, Module_, Proc_, Line_]);
end;
{$ENDIF}

procedure InstallHookToHandle(hMod: HMODULE);
var
   name: string;
   i, num_hooks: integer;
begin
     if (hMod = 0) or Unloaded then
        exit;

     {* Check if loaded library is ours, but another version
      *}
     if wrapper_GetProcAddress(hMod, 'B6EC7AD52BE349E98013DE8B6D544ADF') <> nil then
     begin
          Log(LOG_LEVEL_INJ, 'Trying to load another copy of inject.dll', []);
          FreeLibrary(hMod);
          exit;
     end;

     name := lowercase(GetModuleByHandle(hMod));
     if (name = '') or (hMod = GetMyModule()) then exit;

     Log(LOG_LEVEL_INJ, 'Installing hooks to %s', [name]);

     num_hooks := 0;
     for i:=0 to High(MandatoryFunctions) do
       inc(num_hooks, ReplaceIATEntryInOneMod(MandatoryFunctions[i].fnModule, MandatoryFunctions[i].fnOrig, MandatoryFunctions[i].fnNew, hMod, True));

     Log(LOG_LEVEL_INJ, '%d hooks placed in %s', [num_hooks, name]);

     InstallWSockHooks2(hMod);

     Log(LOG_LEVEL_INJ, 'Leave %s',[name]);
end;

function GetProtectStr(flProtect: DWORD): string;
begin
     result := '';
     if (flProtect and PAGE_NOACCESS) = PAGE_NOACCESS then result := result + ' PAGE_NOACCESS';
     if (flProtect and PAGE_READONLY) = PAGE_READONLY then result := result + ' PAGE_READONLY';
     if (flProtect and PAGE_READWRITE) = PAGE_READWRITE then result := result + ' PAGE_READWRITE';
     if (flProtect and PAGE_WRITECOPY) = PAGE_WRITECOPY then result := result + ' PAGE_WRITECOPY';
     if (flProtect and PAGE_EXECUTE) = PAGE_EXECUTE then result := result + ' PAGE_EXECUTE';
     if (flProtect and PAGE_EXECUTE_READ) = PAGE_EXECUTE_READ then result := result + ' PAGE_EXECUTE_READ';
     if (flProtect and PAGE_EXECUTE_READWRITE) = PAGE_EXECUTE_READWRITE then result := result + ' PAGE_EXECUTE_READWRITE';
     if (flProtect and PAGE_EXECUTE_WRITECOPY) = PAGE_EXECUTE_WRITECOPY then result := result + ' PAGE_EXECUTE_WRITECOPY';
     if (flProtect and PAGE_GUARD) = PAGE_GUARD then result := result + ' PAGE_GUARD';
     if (flProtect and PAGE_NOCACHE) = PAGE_NOCACHE then result := result + ' PAGE_NOCACHE';
end;

function Hook_VirtualProtect(lpAddress: Pointer; dwSize, flNewProtect: DWORD;
  lpflOldProtect: Pointer): BOOL; stdcall;
begin
     result := VirtualProtect(lpAddress, dwSize, flNewProtect, lpflOldProtect);
     Log(LOG_LEVEL_INJ, 'VirtualProtect(%p, %s)' ,[lpAddress, GetProtectStr(flNewProtect)]);
end;


function Hook_VirtualAlloc(lpvAddress: Pointer; dwSize, flAllocationType, flProtect: DWORD): Pointer; stdcall;
begin
     result := VirtualAlloc(lpvAddress, dwSize, flAllocationType, flProtect);
     Log(LOG_LEVEL_INJ, 'VirtualAlloc(%p, %s) = %p' ,[lpvAddress, GetProtectStr(flProtect), result]);
end;


function Hook_GetFileVersionInfoA(lptstrFilename: PAnsiChar; dwHandle, dwLen: DWORD; lpData: Pointer): BOOL; stdcall;
var
   strFilename: string;
begin
     strFilename := String(PChar(lptstrFilename));

     Log(LOG_LEVEL_DEBUG, 'GetFileVersionInfoA(%s)...', [strFilename]);
     result := GetFileVersionInfo(lptstrFilename, dwHandle, dwLen, lpData);
end;

function Hook_GetModuleHandleW(lpLibFileName: PWideChar): HMODULE; stdcall;
begin
     result := GetModuleHandleW(lpLibFileName);
     if lpLibFileName <> nil then
       Log(LOG_LEVEL_INJ, 'GetModuleHandleW(%s) = %08x', [lpLibFileName, result]);
end;


function Hook_VirtualQuery(lpAddress: Pointer;
  var lpBuffer: TMemoryBasicInformation; dwLength: DWORD): DWORD; stdcall;
begin
     result := VirtualQuery(lpAddress, lpBuffer, dwLength);
     if (ModuleFromAddress(lpAddress) = GetMyModule) then
     begin
          Log(LOG_LEVEL_WARN, '[VirtualQuery] Somebody looking for us in memory :) Decline!! DECLINE!!!', [lpAddress]);
          ZeroMemory(@lpBuffer, SizeOf(TMemoryBasicInformation));
          result := 0;
     end;
end;

function Hook_VirtualQueryEx(hProcess: THandle; lpAddress: Pointer;
  var lpBuffer: TMemoryBasicInformation; dwLength: DWORD): DWORD; stdcall;
begin
     result := VirtualQueryEx(hProcess, lpAddress, lpBuffer, dwLength);
     if (ModuleFromAddress(lpAddress) = GetMyModule) then
     begin
          Log(LOG_LEVEL_WARN, '[VirtualQueryEx] Somebody looking for us in memory :) Decline!! DECLINE!!!', [lpAddress]);
          ZeroMemory(@lpBuffer, SizeOf(TMemoryBasicInformation));
          result := 0;
     end;
end;







function Hook_LoadLibraryA(lpLibFileName: PAnsiChar): HMODULE; stdcall;
var
   ws: PWideChar;
   size: DWORD;
begin
     size := strlen(lpLibFileName) * 2 + 2;
     GetMem(ws, size);
     ws := StringToWideChar(lpLibFileName, ws, size);
     result := Hook_LoadLibraryExW(ws, 0, 0);
     FreeMem(ws);
end;

function Hook_LoadLibraryW(lpLibFileName: PWideChar): HMODULE; stdcall;
begin
     result := Hook_LoadLibraryExW(lpLibFileName, 0, 0);
end;

function Hook_LoadLibraryExA(lpLibFileName: PAnsiChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
var
   ws: PWideChar;
   size: DWORD;
begin
     size := strlen(lpLibFileName) * 2 + 2; // Unicode string is 2 bytes plus zero trailing byte
     GetMem(ws, size);
     ws := StringToWideChar(lpLibFileName, ws, size);
     result := Hook_LoadLibraryExW(ws, hFile, dwFlags);
     FreeMem(ws);
end;

function Hook_LoadLibraryExW(lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
begin
     if Unloaded then
     begin
          result := wrapper_LoadLibraryExW(lpLibFileName, hFile, dwFlags);
          exit;
     end;

     if (DWORD(lpLibFileName) <= $7FFF) or (DWORD(lpLibFileName) >= $7FFFFFFF) then
       lpLibFileName := '<ERROR VALUE>';

     Log(LOG_LEVEL_INJ, 'AltLoadLibrary(%s, %d)...',[lpLibFileName, dwFlags]);
     result := iLoadLibrary(lpLibFileName, dwFlags);
     Log(LOG_LEVEL_INJ, 'AltLoadLibrary() = %x',[result]);
end;

function Hook_FreeLibrary(hLibModule: HMODULE): BOOL; stdcall;
begin
     if Unloaded then
     begin
          result := FreeLibrary(hLibModule);
          exit;
     end;

     {* if someone trying to unload our module *}
     if hLibModule = GetMyModule() then
        result := True
     else
        result := iFreeLibrary(hLibModule);
//         FreeLibraryAndExitThread(hLibModule, 0);

     Log(LOG_LEVEL_INJ, 'FreeLibrary(0x%X) = %s',[hLibModule, TF[result]]);

end;

procedure Hook_FreeLibraryAndExitThread(hLibModule: HMODULE; dwExitCode: DWORD); stdcall;
begin
     if hLibModule <> GetMyModule() then
       FreeLibraryAndExitThread(hLibModule, dwExitCode);

     if Unloaded then
       exit;

     Log(LOG_LEVEL_INJ, 'FreeLibraryAndExitThread(0x%X aka "%s", %d)',[hLibModule, GetModuleByHandle(hLibModule), dwExitCode]);
end;


{*
 *  We should get return address from this function
 *  Its need because in ws2_32.dll has an protection from function hooking
 *}

{* First stage GetProcAddress() function
 *}
function Hook_GetProcAddress(LibHandle: HMODULE; FuncName: PChar): FARPROC; stdcall; assembler;
{*  This function must be pure assembler,
 *  for generate by Delphi only stack frame creation instruction and no more
 *}
asm
   mov   ECX, [EBP + 12]        // FuncName parameter
   mov   EDX, [EBP + 8]         // LibHandle
   mov   EAX, [EBP + 4]         // return point from this function
   call  second_GetProcAddress  // call second stage procedure
   push  EBX                    // Save registers
   push  EDX                    //
   push  EAX                    // Save GetProcAddress() result
   mov   EAX, [EBP + 4]         // First parameter is some address
   call  ModuleFromAddress      // Get module handle from this address
   cmp   EAX, ws2_hlib          // Check if caller is winsock2 library
   je    @@begin
   cmp   EAX, wsock_hlib        // Check if caller is winsock library
   jne   @@exit                 // if no, don't try to do anything, just leave
@@begin:
   mov   EBX, [ESP + 16]        // get the return address
   add   EBX, 2                 // skip "test eax,eax" instruction
   mov   EDX, [EBX]             // get the next instructions
   and   EDX, $0000FFFF         // reset high address bits, we need the instruction opcode only
   cmp   EDX, $0000840F         // Win95(win98?)/Win2k SP2 has long "jz" code, so opcode size pretty long (6 bytes instead of 2)
   je    @@w95_w2kSP2           // Yes it is
   add   EBX, 2                 // Okay it is no "jz +$00009c89" it perhaps Win2k with SP3 / (what about XP?) installed which has just "jz +$1e"
   mov   EDX, [EBX]
   jmp   @@w2kSP3               // Patch according to this situation
@@w95_w2kSP2:
   add   EBX, 6                 // Okay skip rest of "jz" and get the comparasion instructions with internal tables of winsock
   mov   EDX, [EBX]
@@w2kSP3:
   and   EDX, $0000FFFF         // reset high address bits, we need the instruction opcode only
   cmp   EDX, $0000863B         // test for instrcution "cmp eax, [esi + orig_addr]" which compares returned and original address of function in WinSock
   jne   @@exit                 // No, this is something else. Don't touch it anymore
   add   EBX, 6                 // I'm a suspicus nature, we need to test for long "jnz" in Win95/Win2k sp2
   mov   EDX, [EBX]
   and   EDX, $0000FFFF         // reset high address bits, we need the instruction opcode only
   cmp   EDX, $0000850F         // test for long "jnz" in w95/Win2000 sp2
   jne   @@fini                 // No this is sp3 or winxp(?) -- leave
   add   EBX, 6                 // Okay that is. Patch address to run after "jnz" of "cmp eax, [esi + ....]", so this protection block won't be executed! :)
   mov   [ESP + 16], EBX        // Set the return address from this function, we'll jump there when RET command will be executed
   jmp   @@exit                 // leave
@@fini:
   add   EBX, 2                 // Patching code for win2k sp3 / winxp(?)
   mov   [ESP + 16], EBX        // Set the return address from this function, we'll jump there when RET command will be executed
@@exit:
   pop   EAX                    // Restore used registers
   pop   EDX                    //
   pop   EBX                    //
end;

{* Second stage GetProcAddress() function
 *}
function second_GetProcAddress(ret_addr: Pointer; LibHandle: HMODULE; FuncName: PChar): FARPROC; register;
var
   IsOrdinal : Boolean;
   Ordinal,i : LongWord;
   temp      : pointer;
   s         : string;
begin
     if Unloaded then
     begin
          result := GetProcAddress(LibHandle, FuncName);
          exit;
     end;

     {* Now we know who call GetProcAddress() :)
      *}
     s := Format('%s issuing', [GetModuleByHandle(ModuleFromAddress(ret_addr))]);

     result := GetProcAddress(LibHandle, FuncName);

     IsOrdinal := (LongWord(FuncName) shr 16) = 0;
     Ordinal := LongWord(FuncName) and $FFFF;

     {* We don't care here about winsock anti-hook-protection. First stage GetProcAddress() will care about it.
      *}
     if not IsOrdinal then
       temp := GetHookedProc(string(FuncName), result)
     else
       temp := GetHookedProc('', result);

     if temp <> nil then
       result := temp;

     {* Executable packers (like UPX) issues GetProcAddress for the all
      * mandatory functions. We should take care about it.
      *}

     for i:=0 to High(MandatoryFunctions) do
     begin
          if MandatoryFunctions[i].fnOrig = result then
          begin
               result := MandatoryFunctions[i].fnNew;
               break;
          end;
     end;

     if IsOrdinal then
       Log(LOG_LEVEL_INJ, s + ' GetProcAddress(%s) Ordinal: %d = %p',[GetModuleByHandle(LibHandle), Ordinal, result])
     else
       Log(LOG_LEVEL_INJ, s + ' GetProcAddress(%s, "%s") = 0x%p',[GetModuleByHandle(LibHandle), FuncName, result]);

end;


{******************************************************************************
 * Functions for adding to caption "via FreeCap"
 ******************************************************************************}

function Hook_SetWindowTextA(Handle: HWND; lpString: PAnsiChar): Boolean; stdcall;
var
   s: string;
begin
     if cfg.prog_add_caption_text and (not isStringPresent(lpString)) then
     begin
          if GetParent(Handle) = 0 then
            s := string(lpString) + sFreeCap
          else
            s := string(lpString);
          result := SetWindowTextA(Handle, @s[1]);
     end
     else
         result := SetWindowTextA(Handle, lpString);
end;


function Hook_SetWindowTextW(Handle: HWND; lpString: PWideChar): Boolean; stdcall;
var
   s: WideString;
begin
     if cfg.prog_add_caption_text and (not isStringPresent(PChar(AnsiString(lpString)))) then
     begin
          if GetParent(Handle) = 0 then
            s := WideString(lpString) + WideString(sFreeCap)
          else
            s := WideString(lpString);

          result := SetWindowTextW(Handle, @s[1]);
     end
     else
         result := SetWindowTextW(Handle, lpString);
end;


function Hook_SetConsoleTitleA(lpString: PAnsiChar): Boolean; stdcall;
var
   s: string;
begin
     if cfg.prog_add_caption_text then
     begin
          if not isStringPresent(PChar(AnsiString(lpString))) then
            s := string(lpString) + sFreeCap
          else
            s := string(lpString);
          result := SetConsoleTitleA(@s[1]);
     end
     else
          result := SetConsoleTitleA(lpString);
end;


function Hook_SetConsoleTitleW(lpString: PWideChar): Boolean; stdcall;
var
   s: WideString;
begin
     if cfg.prog_add_caption_text then
     begin
          if not isStringPresent(PChar(AnsiString(lpString))) then
            s := WideString(lpString) + WideString(sFreeCap)
          else
            s := WideString(lpString);
          result := SetConsoleTitleW(@s[1]);
     end
     else
         result := SetConsoleTitleW(lpString);
end;



function Hook_DefWindowProcA(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
   s: String;
   lpString: PChar;
begin
     if cfg.prog_add_caption_text and (Msg = WM_SETTEXT) and (GetParent(hWnd) = 0) then
     begin
          lpString := PChar(lParam);
          if not isStringPresent(PChar(AnsiString(lpString))) then
            s := String(lpString) + sFreeCap
          else
            s := String(lpString);

          result := DefWindowProcA(hWnd, Msg, wParam, DWORD(@s[1]));
     end
     else
         result := DefWindowProcA(hWnd, Msg, wParam, lParam);
end;


function Hook_DefWindowProcW(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
   s: WideString;
   lpString: PWideChar;
begin
     if cfg.prog_add_caption_text and (Msg = WM_SETTEXT) and (GetParent(hWnd) = 0) then
     begin
          lpString := PWideChar(lParam);
          if not isStringPresent(PChar(AnsiString(lpString))) then
            s := String(lpString) + sFreeCap
          else
            s := String(lpString);

          result := DefWindowProcW(hWnd, Msg, wParam, DWORD(@s[1]));
     end
     else
         result := DefWindowProcW(hWnd, Msg, wParam, lParam);
end;



function Hook_ShowWindow(hWnd: HWND; nCmdSHow: integer): Boolean; stdcall;
var
   lpString: PChar;
   s: String;
   BufSize: integer;
begin
     result := ShowWindow(hWnd, nCmdSHow);
     if not cfg.prog_add_caption_text then
       exit;

     BufSize := GetWindowTextLength(hWnd);
     GetMem(lpString, BufSize + 2);
     GetWindowText(hWnd, lpString, BufSize + 1);

     if (GetParent(hWnd) = 0) and (not isStringPresent(PChar(AnsiString(lpString)))) then
     begin
          s := String(lpString) + sFreeCap;
          SetWindowText(hWnd, @s[1]);
     end;
     FreeMem(lpString);
end;



function Hook_CreateProcessA(lpApplicationName: PAnsiChar; lpCommandLine: PAnsiChar;
     lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
     bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer;
     lpCurrentDirectory: PAnsiChar; const lpStartupInfo: TStartupInfo;
     var lpProcessInformation: TProcessInformation): BOOL; stdcall;
var
   Injector: TSuspendInjector;
   Buf: array[0..MAX_PATH] of char;
   sDll: string;
   sApplicationName, sCommandLine: AnsiString;
   bSuspended: Boolean;
begin
     ZeroMemory(@Buf,SizeOf(Buf));
     if GetModuleFileName(GetMyModule(), @Buf, SizeOf(Buf)) > 0 then
        sDll := Buf;

     bSuspended := ((dwCreationFlags and CREATE_SUSPENDED) <> 0);

     if not bSuspended then
       dwCreationFlags := dwCreationFlags or CREATE_SUSPENDED;

     result := CreateProcessA(lpApplicationName, lpCommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInformation);

     sApplicationName := AnsiString(lpApplicationName);
     sCommandLine := AnsiString(lpCommandLine);
     Log(LOG_LEVEL_INJ, 'CreateProcessA(%s, %s) = %d',[sApplicationName, sCommandLine, Integer(result)]);

     if result then
     begin
          Injector := TSuspendInjector.Create;
          Injector.ProcessInformation := lpProcessInformation;
          Injector.SetDLLToInject(sDll);
          Injector.ShouldRunAfter := not bSuspended;
          Injector.Run();
     end;

end;

function Hook_CreateProcessW(lpApplicationName: PWideChar; lpCommandLine: PWideChar;
     lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
     bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer;
     lpCurrentDirectory: PWideChar; const lpStartupInfo: TStartupInfo;
     var lpProcessInformation: TProcessInformation): BOOL; stdcall;
var
   Injector: TSuspendInjector;
   Buf: array[0..MAX_PATH] of char;
   sDll: string;
   sApplicationName, sCommandLine: WideString;
   bSuspended: Boolean;
begin
     ZeroMemory(@Buf,SizeOf(Buf));
     if GetModuleFileName(GetMyModule(), @Buf, SizeOf(Buf)) > 0 then
        sDll := Buf;


     bSuspended := ((dwCreationFlags and CREATE_SUSPENDED) <> 0);

     if not bSuspended then
       dwCreationFlags := dwCreationFlags or CREATE_SUSPENDED;


     result := CreateProcessW(lpApplicationName, lpCommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInformation);

     sApplicationName := WideString(lpApplicationName);
     sCommandLine := WideString(lpCommandLine);
     Log(LOG_LEVEL_INJ, 'CreateProcessW(%s, %s) = %d',[sApplicationName, sCommandLine, Integer(result)]);

     if result then
     begin
          Injector := TSuspendInjector.Create;
          Injector.ProcessInformation := lpProcessInformation;
          Injector.ShouldRunAfter := not bSuspended;
          Injector.SetDLLToInject(sDll);
          Injector.Run();
     end;

end;

//{$I psapi_impl.inc}


end.
