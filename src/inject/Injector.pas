{*
 * File: ......................... Injector.pas
 * Autor: ........................ Max Artemev (Bert Raccoon),
 * Copyright: .................... (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ......................... Handle CreateProcess injection

 $Id: Injector.pas,v 1.3 2005/05/23 04:41:08 bert Exp $

 $Log: Injector.pas,v $
 Revision 1.3  2005/05/23 04:41:08  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***

}
unit Injector;

interface

uses Windows, SysUtils, misc, common;

type
    LOADLIBRARY_STUB = packed record
        instr_push_eip  : Byte;  op_push_eip: DWORD;  // Save EIP
        instr_pushad    : Byte;                       // Save all registers
        instr_push      : Byte;  op_push    : DWORD;  // push  offset_lib_path            ; Save LoadLibrary parameter
	instr_mov_eax   : Byte;  op_mov_eax : DWORD;  // mov   EAX, addr_of_LoadLibraryA
        instr_call_eax  : Word;                       // call  EAX                       ; Call LoadLibrary to load our function
        instr_popad     : Byte;                       // restore all registers
        instr_ret       : Byte;                       // return to original EIP
        Dummy           : Byte;                       // used for pointer calculations. Don't touch
	LibPath         : array [0..MAX_PATH] of Char;
    end;

    TSuspendInjector = class
    private
       FProcessInformation: PROCESS_INFORMATION;
       FDLLToInject: string;
       FThreadContext: CONTEXT;
       Fstub           : LOADLIBRARY_STUB;
       FStubInTarget   : ^LOADLIBRARY_STUB;
       FFreeCapConfig  : string;
       FLogLevel: string;
       FLogFile: string;
       FShouldRunAfter: Boolean;
       procedure BuildStub();
    protected
       function PlaceInjectionStub(): Boolean;
       function GetMemoryForLoadLibraryStub(): Pointer;
       function ReadTargetMemory(pAddr, pBuffer: Pointer; cb: DWORD): Boolean;
       function WriteTargetMemory(pAddr, pBuffer: Pointer; cb: DWORD): Boolean;
    public
       constructor Create();
       destructor Destroy(); override;
       property ProcessInformation: PROCESS_INFORMATION read FProcessInformation write FProcessInformation;

       function SetDLLToInject(pszDLL: string): Boolean;
       function Run(): Boolean;
       property FreeCapConfig: string read FFreeCapConfig write FFreeCapConfig;
       property LogFile: string read FLogFile write FLogFile;
       property LogLevel: string read FLogLevel write FLoglevel;
       property ShouldRunAfter: Boolean read FShouldRunAfter write FShouldRunAfter;
    end;


implementation

{ TSuspendInjector }

{* width between two pointers
 *}
function OffsetOf(start, stop: Pointer): DWORD;
begin
     result := DWORD(stop) - DWORD(start);
end;

{* Fill all fields with opcodes
 *}
procedure TSuspendInjector.BuildStub;
begin
     with FStub do
     begin
          instr_pushad   := $60;
          instr_push_eip := $68;

          instr_PUSH     := $68;
          instr_MOV_EAX  := $B8;
          instr_CALL_EAX := $D0FF;
          instr_popad    := $61;

          instr_ret      := $C3;
     end;
end;

constructor TSuspendInjector.Create;
begin
     ZeroMemory(@Fstub, SizeOf(LOADLIBRARY_STUB));
     ZeroMemory(@FThreadContext, SizeOf(CONTEXT));
     ZeroMemory(@FProcessInformation, SizeOf(PROCESS_INFORMATION));
     FShouldRunAfter := True;
end;

destructor TSuspendInjector.Destroy;
begin
//    CloseHandle(FProcessInformation.hThread);
//    CloseHandle(FProcessInformation.hProcess);
    inherited Destroy;
end;

function TSuspendInjector.GetMemoryForLoadLibraryStub: Pointer;
var
   osvi        : OSVERSIONINFO;
   hFileMapping: THandle;
begin
     osvi.dwOSVersionInfoSize := SizeOf(OSVERSIONINFO);
     GetVersionEx(osvi);

     if (osvi.dwPlatformId = VER_PLATFORM_WIN32_NT) then
     begin
          {*
           * If we're under NT just call the VirtualAllocEx() which allocates small
           * piece of memory in another process.
           * Why I use "fnVirtualAllocEx" instead of "VirtualAllocEx"? look
           * comments in common.pas
           *}
          result := fnVirtualAllocEx(FProcessInformation.hProcess, nil, sizeof(LOADLIBRARY_STUB), MEM_COMMIT, PAGE_EXECUTE_READWRITE);
          exit;
     end
     else if (osvi.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS) then
     begin
          {* If it Win9x, so make a little memory mapped file. Under this system
           * memory mapped file maps onto the top 2GB and accessable to all processes,
           * e.g. shared space.
           *}
          hFileMapping := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE or SEC_COMMIT, 0, sizeof(LOADLIBRARY_STUB), nil);
          if (hFileMapping <> 0) then
          begin
               result := MapViewOfFile(hFileMapping, FILE_MAP_WRITE, 0, 0, sizeof(LOADLIBRARY_STUB));
               exit;
          end
          else
              CloseHandle(hFileMapping);
     end;
     result := nil;
end;


function TSuspendInjector.PlaceInjectionStub: Boolean;
var
   stubContext: CONTEXT;
begin
     BuildStub();
     result := False;
     //=====================================================
     // Allocate memory for our stub
     FStubInTarget := GetMemoryForLoadLibraryStub();

     if (FStubInTarget = nil) then
        exit;

     // fill the T-string with path to our DLL
     Move(FDLLToInject[1], FStub.LibPath[0], Length(FDLLToInject));

     // Offset for PUSH
     FStub.op_PUSH := DWORD(FStubInTarget) + offsetof(@FStub, @FStub.LibPath);
     FStub.op_push_eip := FThreadContext.Eip;

     // LoadLibraryA() address
     // KERNEL32.DLL mapped in all processes at the same address, so in the
     // alien process all function adresses will be identically with ours.
     FStub.op_MOV_EAX := DWORD(GetProcAddress(GetModuleHandle('KERNEL32.DLL'), 'LoadLibraryA'));

     // Write our stub in the target process
     result := WriteTargetMemory(FStubInTarget, @FStub, sizeof(FStub));
     if (not result) then
       exit;

     // Patch EIP to begin of our stub
     StubContext := FThreadContext;
     StubContext.EIP := DWORD(FStubInTarget);  // M$ rulez here :)
     result := SetThreadContext(FProcessInformation.hThread, StubContext); // So cool function sometimes can be found in WinAPI
end;

function TSuspendInjector.ReadTargetMemory(pAddr, pBuffer: Pointer; cb: DWORD): Boolean;
var
   cbRead: DWORD;
begin
    result := ReadProcessMemory(FProcessInformation.hProcess, pAddr, pBuffer, cb, cbRead);
    result := result and (cbRead = cb);
end;


function TSuspendInjector.Run: Boolean;
begin
     ZeroMemory(@FThreadContext,SizeOf(CONTEXT));
     FThreadContext.ContextFlags := CONTEXT_FULL;
     GetThreadContext(FProcessInformation.hThread, FThreadContext);

     PlaceInjectionStub();

     if FShouldRunAfter then
     begin
          ResumeThread(FProcessInformation.hThread);
//          CloseHandle(FProcessInformation.hThread);
     end;

     result := True;
end;


function TSuspendInjector.SetDLLToInject(pszDLL: string): Boolean;
begin
     FDLLToInject := pszDLL;
     result := True;
end;


function TSuspendInjector.WriteTargetMemory(pAddr, pBuffer: Pointer;
  cb: DWORD): Boolean;
var
   cbWrite: DWORD;
begin
     result := WriteProcessMemory(FProcessInformation.hProcess, pAddr, pBuffer, cb, cbWrite);
     result := result and (cbWrite = cb);
end;

end.

