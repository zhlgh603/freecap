{*
 * File: ......................... DebugInject.pas
 * Autor: ........................ Max Artemev (Bert Raccoon)
 * Copyright: .................... (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc:
 *    Implementation of DLL injection by using debugging the process
 *    Works both on WinNT and 9x
 *}
unit DebugInject;

interface
uses Windows, common;

type
{*  base idea:
 * EXE.EntryPoint -> int 3h
 *                          ->  push "inject.dll"
 *                              mov eax, LoadLibraryA
 *                              call eax
 *                              int 3h
 *                          <-
 *}
    LOADLIBRARY_STUB = packed record
        instr_push     : Byte;
        operand_push   : DWORD;
	instr_mov_eax  : Byte;
        operand_mov_eax: DWORD;
        instr_call_eax : Word;
        instr_int_3    : Byte;
	LibPath        : array [0..MAX_PATH] of Char;
    end;

    TDebugInjector = class
    private
       FProcessInformation: PROCESS_INFORMATION;
       FCreateProcessDebugInfo: CREATE_PROCESS_DEBUG_INFO;
       FDLLToInject: string;
       FExeEntryPoint: Pointer;
       ForigExeEntryPointOpcode: Byte;
       ForigThreadContext: CONTEXT;
       Fstub           : LOADLIBRARY_STUB;
       FStubInTarget   : ^LOADLIBRARY_STUB;
       FStubInTargetBP : Pointer;
       FFirstBP        : Boolean;
       FFreeCapConfig  : string;
       procedure BuildStub();
    protected
       function HandleDebugEvent(dbgEvent: DEBUG_EVENT): DWORD;
       function HandleException(dbgEvent: DEBUG_EVENT): DWORD;
       function SetEntryPointBP(): Boolean;
       function RemoveEntryPointBP(): Boolean;
       function SaveEntryPointContext(dbgEvent: DEBUG_EVENT): Boolean;
       function RestoreEntryPointContext(): Boolean;
       function PlaceInjectionStub(): Boolean;
       function GetMemoryForLoadLibraryStub(): Pointer;
       function ReadTargetMemory(pAddr, pBuffer: Pointer; cb: DWORD): Boolean;
       function WriteTargetMemory(pAddr, pBuffer: Pointer; cb: DWORD): Boolean;
    public
       bInjected: Boolean; // Ставится в true сразу после вызова LoadLibrary ибо оно может и не загрузить
       constructor Create();
       destructor Destroy(); override;
       function LoadProcess(pszCmdLine, pszWorkDir: string): Boolean;
       function SetDLLToInject(pszDLL: string): Boolean;
       function Run(): Boolean;
       property FreeCapConfig: string read FFreeCapConfig write FFreeCapConfig;
    end;


implementation

{ TDebugInjector }

function offsetof(start, stop: Pointer): DWORD;
begin
     result := DWORD(stop) - DWORD(start);
end;

procedure TDebugInjector.BuildStub;
begin
     with FStub do
     begin
          instr_PUSH     := $68;   // Opcode for "PUSH offset"
          instr_MOV_EAX  := $B8;   // Opcode for instruction "MOV EAX, something_integer"
          instr_CALL_EAX := $D0FF;
          instr_INT_3    := $CC;   // int 3h -- Debugger system call
     end;
end;

constructor TDebugInjector.Create;
begin
     ZeroMemory(@Fstub, SizeOf(LOADLIBRARY_STUB));
     ZeroMemory(@FCreateProcessDebugInfo, SizeOf(CREATE_PROCESS_DEBUG_INFO));
     ZeroMemory(@ForigThreadContext, SizeOf(CONTEXT));
     ZeroMemory(@FProcessInformation, SizeOf(PROCESS_INFORMATION));
     FFirstBP := FALSE;
end;

destructor TDebugInjector.Destroy;
begin
    CloseHandle(FProcessInformation.hThread);
    CloseHandle(FProcessInformation.hProcess);
    CloseHandle(FCreateProcessDebugInfo.hProcess);
    CloseHandle(FCreateProcessDebugInfo.hThread);
    inherited Destroy;
end;

function TDebugInjector.GetMemoryForLoadLibraryStub: Pointer;
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
          result := fnVirtualAllocEx(FCreateProcessDebugInfo.hProcess, nil, sizeof(LOADLIBRARY_STUB), MEM_COMMIT, PAGE_READWRITE);
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

function TDebugInjector.HandleDebugEvent(dbgEvent: DEBUG_EVENT): DWORD;
var
   dwContinueStatus: DWORD;
begin
     dwContinueStatus := DBG_CONTINUE;
     case dbgEvent.dwDebugEventCode of
       CREATE_PROCESS_DEBUG_EVENT:
          begin
               FCreateProcessDebugInfo := dbgEvent.CreateProcessInfo;
               CloseHandle(FCreateProcessDebugInfo.hFile);
          end;
       // That is! debugger interrupt was called!
       EXCEPTION_DEBUG_EVENT: dwContinueStatus := HandleException(dbgEvent);
       CREATE_THREAD_DEBUG_EVENT: CloseHandle(dbgEvent.CreateThread.hThread);
       LOAD_DLL_DEBUG_EVENT: CloseHandle(dbgEvent.LoadDll.hFile);
    end;
    result := dwContinueStatus;
end;

function TDebugInjector.HandleException(dbgEvent: DEBUG_EVENT): DWORD;
var
   exceptRec: EXCEPTION_RECORD;
   dwContinueStatus: DWORD;
begin
     exceptRec := dbgEvent.Exception.ExceptionRecord;
     // If this is a second chance exception, the debuggee is going to
     // die.  Spit out the exception code and address
     if (dbgEvent.Exception.dwFirstChance = 0) then
     begin
          {$IFDEF CONSOLE}
             Writeln('Exception code: ', exceptRec.ExceptionCode, ' Addr: ', DWORD(exceptRec.ExceptionAddress));
          {$ENDIF}
         
          { printf( "Exception code: %X  Addr: %08X\r\n",
             exceptRec.ExceptionCode, exceptRec.ExceptionAddress );
          }
     end;

     //  If injection was already, just pass handling execption to the next.
     //  Maybe process under real debugger.
     if (bInjected) then
     begin
          result := DBG_EXCEPTION_NOT_HANDLED;
          exit;
     end;

     // If not breakpoint just skip the rest
     if (exceptRec.ExceptionCode <> EXCEPTION_BREAKPOINT) then
     begin
          result := DBG_EXCEPTION_NOT_HANDLED;
          exit;
     end;

     dwContinueStatus := DBG_CONTINUE;

     // Is it BP from DebugBreak()?
     if (not FFirstBP) then
     begin
          SetEntryPointBP();
          FFirstBP := True;
     end
     // Is it BP which placed at EntryPoint of our EXE?
     else if (exceptRec.ExceptionAddress = FExeEntryPoint) then
     begin
          RemoveEntryPointBP();
          SaveEntryPointContext( dbgEvent );
          PlaceInjectionStub();
     end
     // Is it BP which placed after LoadLibrary call?
     else if (exceptRec.ExceptionAddress = FStubInTargetBP) then
     begin
          RestoreEntryPointContext();
          bInjected := True;
     end;
     result := dwContinueStatus;
end;

function TDebugInjector.LoadProcess(pszCmdLine, pszWorkDir: string): Boolean;
var
   StartInfo: STARTUPINFO;
begin
     ZeroMemory(@startInfo, SizeOf(STARTUPINFO));
     StartInfo.cb := SizeOf(STARTUPINFO);
     if FFreeCapConfig <> '' then
        SetEnvironmentVariable('FreeCAPConfigFile', PChar(FFreeCapConfig));
     // Create process with debuging
     result := CreateProcess(
                    nil,                          // lpszImageName
                    PChar(pszCmdLine),            // lpszCommandLine
                    nil,                          // lpsaProcess
                    nil,                          // lpsaThread
                    FALSE,                        // fInheritHandles
                    DETACHED_PROCESS or DEBUG_ONLY_THIS_PROCESS,      // fdwCreate
                    nil,                          // lpvEnvironment
                    PChar(pszWorkDir),            // lpszCurDir
                    StartInfo,                    // lpsiStartupInfo
                    FProcessInformation);         // lppiProcInfo
end;

function TDebugInjector.PlaceInjectionStub: Boolean;
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

     // Find where our BP is located
     FStubInTargetBP := Pointer(DWORD(FStubInTarget) + offsetof(@FStub, @FStub.instr_INT_3));

     // Fill all fields
     Move(FDLLToInject[1], FStub.LibPath[0], Length(FDLLToInject));

     // Offset for PUSH
     FStub.operand_PUSH := DWORD(FStubInTarget) + offsetof(@FStub, @FStub.LibPath);

     // LoadLibraryA() address
     // KERNEL32.DLL mapped in all processes at the same address, so in the
     // alien process all function adresses will be identically with ours.
     FStub.operand_MOV_EAX := DWORD(GetProcAddress(GetModuleHandle('KERNEL32.DLL'), 'LoadLibraryA'));

     // Write our stub in the target process
     result := WriteTargetMemory(FStubInTarget, @FStub, sizeof(FStub));
     if (not result) then
       exit;

     StubContext := FOrigThreadContext;
     // Patch EIP to begin of our stub
     StubContext.Eip := DWORD(FStubInTarget);
     SetThreadContext(FCreateProcessDebugInfo.hThread, StubContext);
     result := True;
end;

function TDebugInjector.ReadTargetMemory(pAddr, pBuffer: Pointer; cb: DWORD): Boolean;
var
   cbRead: DWORD;
begin
    result := ReadProcessMemory(FCreateProcessDebugInfo.hProcess, pAddr, pBuffer, cb, cbRead);
    result := result and (cbRead = cb);
end;

function TDebugInjector.RemoveEntryPointBP: Boolean;
begin
    result := WriteTargetMemory(FExeEntryPoint, @FOrigExeEntryPointOpcode, sizeof(Byte));
end;

function TDebugInjector.RestoreEntryPointContext: Boolean;
begin
     result := SetThreadContext(FCreateProcessDebugInfo.hThread, FOrigThreadContext);
end;

function TDebugInjector.Run: Boolean;
var
   dbgEvent: DEBUG_EVENT;
   dwContinueStatus: DWORD;
begin
    // Main cycle
    while True do
    begin
         WaitForDebugEvent(dbgEvent, INFINITE);
         dwContinueStatus := HandleDebugEvent(dbgEvent);
         if (dbgEvent.dwDebugEventCode = EXIT_PROCESS_DEBUG_EVENT) then
            break;
         if bInjected then
         begin
              CloseHandle(FProcessInformation.hThread);
              CloseHandle(FProcessInformation.hProcess);
              CloseHandle(FCreateProcessDebugInfo.hProcess);
              CloseHandle(FCreateProcessDebugInfo.hThread);
              break;
         end;
         ContinueDebugEvent(dbgEvent.dwProcessId, dbgEvent.dwThreadId, dwContinueStatus);
         // put here Application.ProcessMessages() for prevent FreeCap freezing
    end;

    result := True;
end;

function TDebugInjector.SaveEntryPointContext(dbgEvent: DEBUG_EVENT): Boolean;
begin
    // Make sure that the thread we have the handle for is
    // the same thread that hit the BP
    if (FProcessInformation.dwThreadId <> dbgEvent.dwThreadId) then
      DebugBreak();

    FOrigThreadContext.ContextFlags := CONTEXT_FULL;

    if not (GetThreadContext(FCreateProcessDebugInfo.hThread, FOrigThreadContext)) then
    begin
         result := False;
         exit;
    end;

    // The EIP in the context structure points past the BP, so
    // decrement EIP to point at the original instruction
    FOrigThreadContext.Eip := FOrigThreadContext.Eip - 1;
    result := True;
end;

function TDebugInjector.SetDLLToInject(pszDLL: string): Boolean;
begin
     FDLLToInject := pszDLL;
     result := True;
end;


function TDebugInjector.SetEntryPointBP: Boolean;
var
   Opcode: Byte;
begin
    FExeEntryPoint := FCreateProcessDebugInfo.lpStartAddress;
    result := ReadTargetMemory(FExeEntryPoint, @FOrigExeEntryPointOpcode, sizeof(Byte));
    if (not result) then
       exit;
    Opcode := $CC; // int 3h
    result := WriteTargetMemory(FExeEntryPoint, @Opcode, sizeof(Byte));
end;

function TDebugInjector.WriteTargetMemory(pAddr, pBuffer: Pointer;
  cb: DWORD): Boolean;
var
   cbWrite: DWORD;
begin
     result := WriteProcessMemory(FCreateProcessDebugInfo.hProcess, pAddr, pBuffer, cb, cbWrite);
     result := result and (cbWrite = cb);
end;

end.
