{*
 * File: ...................... export_hook.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2005 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Hooking the functions at the export address table (EAT)

 $Id: export_hook.pas,v 1.5 2005/12/19 06:09:02 bert Exp $
 $Log: export_hook.pas,v $
 Revision 1.5  2005/12/19 06:09:02  bert
 *** empty log message ***

 Revision 1.4  2005/12/06 11:22:53  bert
 *** empty log message ***

 Revision 1.3  2005/12/05 14:27:45  bert
 *** empty log message ***

 Revision 1.2  2005/12/02 06:07:28  bert
 *** empty log message ***

 Revision 1.1  2005/12/01 14:38:44  bert
 *** empty log message ***


 todo: в стабе могут быть относительные CALL'ы
}

unit export_hook;

interface
uses Windows, disasm_engine;

type
    THookStub = packed record
      jmp_opcode: Byte; jmp_dst_addr: DWORD;
      nop1,
      nop2: Byte;
    end;
    PHookStub = ^THookStub;

    TNewHookStub = packed record
      push_opcode: Byte; push_value: DWORD;
      jmp_opcode: Byte; jmp_dst_addr: DWORD;
      nops_align: array[0..5] of Byte;
    end;
    PNewHookStub = ^TNewHookStub;

    TFunctionEntryPoint = packed record
       bytes: array[0..35] of Char;
    end;


const
    CODE_SIZE = 10;
    nParamCountOffs = 0;
    HookHandlerOffs = 4;
    StubOffs = 8;

type
    TExportEntry = packed record
       nParamCount: DWORD;
       Hook_Handler: Pointer;
       Stub: TFunctionEntryPoint;
       FunctionName: PChar;
       LibraryName: PChar;
    end;

    TLoadLibraryExWStub = packed record
      op_push1: Word;
      op_push2: Byte;
      val_push2: DWORD;
      jmp_opcode: Byte;
      jmp_orig_addr: DWORD;
    end;



    function HookExport_LoadLibraryExW(Caller: POinter; lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
    function wrapper_LoadLibraryExW(lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
//    function Hook_GetProcAddress_export(LibHandle: HMODULE; lpFuncName: PChar): Pointer; stdcall;
    function wrapper_GetProcAddress(lpLib: THandle; FuncName: PChar): Pointer; stdcall; assembler;


    function HookExport_GetProcAddress(Caller: POinter; LibHandle: HMODULE; lpFuncName: PChar): Pointer; stdcall;


    procedure PlaceExportHook();


var
   LoadLibraryExW_ExportStub: TLoadLibraryExWStub;
//   ExportStub: TExportStub;


   entries: array [0..1] of TExportEntry = (
     (nParamCount: 3; Hook_Handler: @HookExport_GetProcAddress; FunctionName: 'GetProcAddress'; LibraryName: 'kernel32.dll'),
     (nParamCount: 4; Hook_Handler: @HookExport_LoadLibraryExW; FunctionName: 'LoadLibraryExW'; LibraryName: 'kernel32.dll')
   );

implementation
uses hook, hook_func, cfg, misc, loger;


function wrapper_GetProcAddress(lpLib: THandle; FuncName: PChar): Pointer; stdcall; assembler;
asm
       mov al, prog_advanced_hooking
       test al, al
       jnz @@_asm_version
       mov  eax, [ebp + 12]
       push eax
       mov  eax, [ebp + 8]
       push eax
       call GetProcAddress
       pop  ebp
       ret 8
@@_asm_version:
       pop ebp
       lea eax, dword ptr entries
       add eax, StubOffs
       jmp eax
end;

procedure Hook_Multiplexer(); stdcall; assembler;
asm
   pop    eax                          // function index

   push   ebp                          // save stack frame
   mov    ebp, esp                     //

   push   ebx                          // Save all used registers and flags
   push   ecx
   push   edx
   push   esi
   push   edi
   pushfd

   mov    ebx, eax

   mov    eax, sizeof(TExportEntry)    // get entries item
   mov    edx, ebx                     //
   mul    edx                          // eax = entries + index * sizeof(one item)
   lea    ecx, dword ptr entries       // get ptr to entries array
   add    ecx, eax
   xchg   eax, ecx
   mov    ecx, [eax + nParamCountOffs] // ecx = entries[index].nParamCount
   mov    edx, [eax + HookHandlerOffs] // get entries[index].handler

   push   eax

@@next:
   mov    eax, [ebp + ecx * 4 ]        // Push all parameters
   push   eax
   dec    ecx
   jnz    @@next                       // loop until ecx == 0 (with zero included)

   call   edx                          // call it
   pop    ecx
   cmp    eax, -2
   jne    @@_exit_1                      // if handler returns good value, just leave

   mov    eax, ecx

   lea    ecx, [EAX + StubOffs]        // get entries[index].stub

   mov eax, ecx

   popfd
   pop   edi
   pop   esi
   pop   edx
   pop   ecx
   pop   ebx
   mov   esp, ebp
   pop   ebp
   jmp   eax                             // jump to stub

@@_exit_1:
   mov edx, [ecx]
   cmp edx, 4
   je @@_ret12
   jmp @@_ret8

@@_ret8:
   popfd
   pop   edi
   pop   esi
   pop   edx             // Restore registers
   pop   ecx
   pop   ebx
   mov   esp, ebp
   pop   ebp
   ret   8

@@_ret12:
   popfd
   pop   edi
   pop   esi
   pop   edx             // Restore registers
   pop   ecx
   pop   ebx
   mov   esp, ebp
   pop   ebp
   ret   12
end;



function wrapper_LoadLibraryExW(lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall; assembler;
begin
     result := LoadLibraryExW(lpLibFileName, hFile, dwFlags);
end;


function HookExport_LoadLibraryExW(Caller: POinter; lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
begin
     if DWORD(ModuleFromAddress(Caller)) <> GetMyModule() then
     begin
          result := Hook_LoadLibraryExW(lpLibFileName, hFile, dwFlags);
     end
     else
       result := DWORD(-2);

     Log(LOG_LEVEL_DEBUG, 'Hook_LoadLibraryExW_export2::%s@%p loading %s = %x', [GetModuleByHandle(ModuleFromAddress(Caller)), Caller, lpLibFileName, result]);
end;

{ -------------------------------------------------------------------- }

function HookExport_GetProcAddress(Caller: POinter; LibHandle: HMODULE; lpFuncName: PChar): Pointer; stdcall;
var
   _getaddr: Pointer;
begin
     if (DWORD(ModuleFromAddress(Caller)) <> GetMyModule)  then
     begin
          result := wrapper_GetProcAddress(LibHandle, lpFuncName);
          _getaddr := wrapper_GetProcAddress(GetModuleHandle('kernel32.dll'), 'GetProcAddress');
          if result <> _getaddr then
            result := second_GetProcAddress(Caller, LibHandle, lpFuncName);
     end
     else
         result := Pointer(-2);
end;


procedure PlaceExportHook();
var
   mbi         : MEMORY_BASIC_INFORMATION;
   CodeSize    : integer;
   NopAlign    : integer;
   i,j         : integer;
   FuncAddr    : Pointer;
   hModule     : THandle;
   function CalcJMPOffset(destaddr, jmp_addr: Pointer): DWORD;
   begin
        result := DWORD(destaddr) - DWORD(jmp_addr) - 5; // Sizeof(jmp_opcode) + SizeOf(jmp_operand) = 5
   end;
begin
     disasm_engine.Init;



     for j:=0 to High(entries) do
       with entries[j] do
       begin
            hModule := GetModuleHandle(LibraryName);
            if hModule = 0 then
               hModule := LoadLibrary(LibraryName);
            if hModule = 0 then continue;

            FuncAddr := GetProcAddress(hModule, FunctionName);
            if FuncAddr = nil then continue;


            ZeroMemory(@mbi, sizeof(MEMORY_BASIC_INFORMATION));
            VirtualQuery(FuncAddr, mbi, sizeof(MEMORY_BASIC_INFORMATION));
            if VirtualProtect(mbi.BaseAddress, mbi.RegionSize, PAGE_READWRITE, mbi.Protect) then
            begin
                 GetCodeSizeInfo(FuncAddr, CODE_SIZE, CodeSize, NopAlign);
                 RealignCallOffsets(FuncAddr, CodeSize, @Stub.bytes);

                 CopyMemory(@Stub.bytes, FuncAddr, CodeSize);

                 with PNewHookStub(FuncAddr)^ do
                 begin
                      push_opcode := $68; push_value := j;
                      jmp_opcode := $E9;
                      jmp_dst_addr := CalcJMPOffset(Pointer(@Hook_Multiplexer), @PNewHookStub(FuncAddr)^.jmp_opcode);
                      for i:=0 to NopAlign - 1 do
                        nops_align[i] := $90;
                 end;
                 Pbyte(@entries[j].Stub.bytes[CodeSize])^ := $E9; // jmp
                 PDWORD(@Stub.bytes[CodeSize + 1])^ := CalcJMPOffset(Pointer(DWORD(FuncAddr) + CODE_SIZE + DWORD(NopAlign)),
                         @Stub.bytes[CodeSize]);
            end;
       end;
end;

end.
