{*
 * File: ...................... win9x.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Windows 9x `kernel` API hooking.

 $Id: win9x.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

 $Log: win9x.pas,v $
 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}

unit win9x;

interface
uses Windows, SysUtils, Classes, imagehlp, loger, cfg;

  function GetModuleNtHeaders(Module: Cardinal): PImageNtHeaders;
  procedure make_pages_writeable (p: Pointer);
  function PlaceHook(pDestAddr, pOrigAddr, pNewAddr: Pointer; bInstall: Boolean): Boolean;

  procedure Init();
  procedure Fini();

var
   bFirstCopy: Boolean = True;        // Assume that inject.dll is one in memory,
                                      // i.e. no other processes who's using us.
   bDoNotRestore: Boolean = False;    // If it isn't true this flag should be set
                                      // for prevent 'restoring'

implementation
uses hook, SharedDispatch;


var
   HookedProcList: TFuncList;

const
     CENEWHDR = $003C;          // offset of new EXE header
     CEMAGIC  = $5A4D;          // old EXE magic id:  'MZ'
     CPEMAGIC = $4550;          // NT portable executable
type
    TImageExportDirectory  = packed record
      Characteristics       : dword;
      TimeDateStamp         : dword;
      MajorVersion          : word;
      MinorVersion          : word;
      Name                  : dword;
      Base                  : dword;
      NumberOfFunctions     : dword;
      NumberOfNames         : dword;
      AddressOfFunctions    : cardinal;
      AddressOfNames        : cardinal;
      AddressOfNameOrdinals : cardinal;
    end;
    TPImageExportDirectory = ^TImageExportDirectory;

    TAWord                 = array [0..maxInt shr 1-1] of word;
    TPAWord                = ^TAWord;
    TACardinal             = array [0..maxInt shr 2-1] of cardinal;
    TPACardinal            = ^TACardinal;
    TAInteger              = array [0..maxInt shr 2-1] of integer;
    TPAInteger             = ^TAInteger;
    PPDWORD                = ^PDWORD;


{* The next stub will be placed in shared memory. So it will be
 * available to all processes, who calls e.g. "kernel"'s functions
 *
asm
    nop                             ; 4 nops for identify our stub block
    nop
    nop
    nop
    pushad                          ; Save all registers
    mov  eax, offset strInjectDll
    push eax
    call GetModuleHandle
    test eax, eax                   ; Check if inject.dll present in address space
    jz  @@nolib
    add eax, func_offset            ; if inject.dll exists, compute the address
    mov func_addr, eax              ; to hook function
    popad
    jmp dword ptr func_addr         ; do not `call` because this code already 'call'ed. Just jump
@@nolib:
    popad                           ; otherwise jump to original function
    jmp orig_func_addr

; Variables
func_addr             dd  0
func_offset           dd  0
orig_func_addr        dd  0
strInjectDll          db 'inject.dll',0
}

    SHARED_HOOK_STUB = packed record
        instr_four_nops: DWORD;
    	instr_pushad   : Byte;

        instr_mov_eax_injectdll : Byte;  op_mov_eax_injectdll : DWORD;
        instr_push_eax: Byte;
        instr_call_GetModuleHandle: Byte; op_call_GetModuleHandle: DWORD;

        instr_test_eax_eax: Word;

        instr_je_nolib : Byte; op_je_nolib: Byte;

        instr_add_eax_orig_func_offset : Byte; op_add_eax_orig_func_offset: DWORD;

        instr_mov_func_addr_eax: Word; op_mov_func_addr_eax: DWORD;

        instr_popad: Byte;
        instr_jmp_func_addr: Word; op_jmp_func_addr: DWORD;

        instr_nolib_nop_label: Byte; // @@nolib label

        instr_nolib_popad : Byte;

        instr_nolib_jmp_orig_addr: Byte; op_nolib_jmp_orig_addr: DWORD;


        {* Variables *}
        str_inject_dll: array [0..MAX_PATH] of char;
        func_offset        : DWORD; // We didnt use "address hardcoding" because it's bad tone. 
                                    // Just keep offset from the inject module's allocation address
        func_addr          : DWORD;
        orig_func_addr     : DWORD;
    end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }

function WriteTargetMemory(pAddr, pBuffer: Pointer; cb: DWORD): Boolean;
var
   cbWrite: DWORD;
begin
     result := WriteProcessMemory(GetCurrentProcess(), pAddr, pBuffer, cb, cbWrite);
     result := result and (cbWrite = cb);
end;

function GetModuleNtHeaders(Module: Cardinal): PImageNtHeaders;
begin
     result := nil;
     try
        if (PWord(module)^ <> CEMAGIC) then
           exit;
        result := Pointer(Module + PWord(module + CENEWHDR)^);
        if (result^.signature <> CPEMAGIC) then
           result:=nil;
     except
        result := nil;
     end;
end;


function GetProcAddress_(module: cardinal; ord: cardinal) : pointer;
var
   exp: TPImageExportDirectory;
begin
     result := nil;
     try
        exp := Pointer( Module + GetModuleNtHeaders(module)^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress);
        if (exp <> nil) then
        begin
             with exp^ do
             begin
                  if (ord < NumberOfFunctions) then
                    result := Pointer(Module + TPACardinal(Module + AddressOfFunctions)^[ord]);
             end;
        end;
     except
     end;
end;

{*
 *  Because of shared memory of mapped kernel32, user32 and others marked as
 *  non-writable for `user-mode` code, we should switch to zero ring to mark it
 *  writable with undocumented function call `VxdCall0` -- this function always
 *  first in the export table of kernel32.dll
 *  I don't want to fuck with VxD on Delphi :)
 *}
procedure make_pages_writeable (p: Pointer);
const
    PC_WRITEABLE = $00020000;
    PC_USER      = $00040000;
    PC_STATIC    = $20000000;
var
   VxDCall: Pointer;
   hMod: HMODULE;
   FirstAddress   : cardinal;
   FirstPage      : cardinal;
begin
     hMod := GetModuleHandle('kernel32');
     FirstAddress := dword(p);
     FirstPage := FirstAddress shr 12; // pages on x386 as you know equal to 4K (or 4 MB :))
     VxDCall := GetProcAddress_(hMod, 1);
     asm
        push (PC_WRITEABLE or PC_USER or PC_STATIC)     // PC_WRITEABLE | PC_USER | PC_STATIC
        push 00h                                        // Keep all previous bits
        push 01h                                        // Number of pages. One page (4K) will be enough to change 4 bytes :)
        push FirstPage                                  // Page number
        push 1000Dh                                     // _PageModifyPermissions (win32_service_table #)
        call dword ptr [vxdcall]                        // VxDCall0
     end;
end;



function OffsetOf(start, stop: Pointer): DWORD;
begin
     result := DWORD(stop) - DWORD(start);
end;

function CalcJMPOffset(destaddr, jmp_addr: Pointer): DWORD;
begin
     result := DWORD(DWORD(destaddr) - DWORD(jmp_addr) - 5);
end;


function PlaceHook(pDestAddr, pOrigAddr, pNewAddr: Pointer; bInstall: Boolean): Boolean;
var
   nops : DWORD;
   hFileMapping : THandle;
   mem_base: Pointer;
   HookStub: SHARED_HOOK_STUB;
   filemapflags: DWORD;
   map_flags: DWORD;


   {* Calculate virtual address from RVA
    *}
   function GetVA(Target: Pointer): DWORD;
   begin
        result := DWORD(mem_base) + OffsetOf(@HookStub, Target);
   end;

begin
     nops := PPDWORD(pDestAddr)^^;

     if nops = $90909090 then
     begin
          if bFirstCopy then
          begin
               bFirstCopy := False;
               bDoNotRestore := True;
          end;

          Log(LOG_LEVEL_WARN, '!!! Hook at %p already placed. Do not panic.', [pOrigAddr]);
          result := True;
          exit;
     end;

     if HookedProcList.Exists(pOrigAddr) then
     begin
          make_pages_writeable(pDestAddr);
          PDWORD(pDestAddr)^ := DWORD(HookedProcList.GetAssociatedAddress(pOrigAddr));
          result := True;
          exit;
     end;

     filemapflags := PAGE_READWRITE or PAGE_WRITECOPY or PAGE_EXECUTE or PAGE_EXECUTE_READ or PAGE_EXECUTE_READWRITE or PAGE_EXECUTE_WRITECOPY;

     hFileMapping := CreateFileMapping(INVALID_HANDLE_VALUE, nil, filemapflags, 0, sizeof(SHARED_HOOK_STUB), nil);
     if (hFileMapping <> 0) then
     begin
          map_flags := FILE_MAP_ALL_ACCESS;
          mem_base := MapViewOfFile(hFileMapping, map_flags, 0, 0, sizeof(SHARED_HOOK_STUB));
          if (mem_base = nil) then
          begin
               Log(LOG_LEVEL_WARN, '!!! mem_base = nil', []);
               result := False;
               CloseHandle(hFileMapping);
               exit;
          end;
     end
     else
         CloseHandle(hFileMapping);

     ZeroMemory(@HookStub, SizeOf(SHARED_HOOK_STUB));

     with HookStub do
     begin
          // Fill the variables
          str_inject_dll := 'inject.dll';
          orig_func_addr := DWORD(pOrigAddr);
          func_offset := DWORD(pNewAddr) - DWORD(GetModuleHandle('inject.dll'));
          instr_four_nops := $90909090;

          // pushad
          instr_pushad := $60;

          // mov eax, offset 'inject.dll'
          instr_mov_eax_injectdll := $B8;
          op_mov_eax_injectdll := GetVA(@HookStub.str_inject_dll);

          // push eax
          instr_push_eax := $50;

          // call GetModuleHandleA
          instr_call_GetModuleHandle := $E8;
          op_call_GetModuleHandle := DWORD(GetRealAddress(GetProcAddress(GetModuleHandle('kernel32.dll'), 'GetModuleHandleA')));
          op_call_GetModuleHandle := op_call_GetModuleHandle - GetVA(@instr_call_GetModuleHandle) - 5;

          // test eax, eax
          instr_test_eax_eax := $C085;

          // jz @@nolib
          instr_je_nolib := $74;
          op_je_nolib := OffsetOf(@instr_je_nolib, @instr_nolib_nop_label) - 2;

          // add eax, func_offset
          instr_add_eax_orig_func_offset := $05;
          op_add_eax_orig_func_offset := func_offset;

          // mov func_addr, eax
          instr_mov_func_addr_eax := $0589;
          op_mov_func_addr_eax := GetVA(@func_addr);

          // popad
          instr_popad := $61;

          // jmp func_addr
          instr_jmp_func_addr := $25FF;
          op_jmp_func_addr := GetVA(@func_addr);

          // @@nolib:
          instr_nolib_nop_label := $90;

          instr_nolib_popad := $61;

          // jmp orig_addr
          instr_nolib_jmp_orig_addr := $E9;
          op_nolib_jmp_orig_addr := CalcJMPOffset(Pointer(orig_func_addr), Pointer(GetVA(@instr_nolib_jmp_orig_addr)));
     end; {* end of stub *}

     WriteTargetMemory(mem_base, @HookStub, SizeOf(SHARED_HOOK_STUB));
     make_pages_writeable(pDestAddr);

     PDWORD(pDestAddr)^ := DWORD(mem_base);
     result := True;
     HookedProcList.Add(pDestAddr, pOrigAddr, mem_base);
end;

procedure Init();
begin
     HookedProcList := TFuncList.Create;
end;

procedure Fini();
begin
     HookedProcList.Restore();
     HookedProcList.Free;
end;


end.
