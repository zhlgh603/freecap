{*
 * File: ......................... RemoteThreadInject.pas
 * Autor: ........................ Max Artemev (Bert Raccoon)
 * Copyright: .................... (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc:
 *    Implementation of DLL injection by using creation remote thread.
 *    WinNT only!

  $Id: RemoteThreadInject.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

  $Log: RemoteThreadInject.pas,v $
  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}
unit RemoteThreadInject;

interface
uses Windows, SysUtils, common;

type
    TRemoteInjector = class
    private
      FProcessPath: string;
      FWorkDir: string;
      FInjectDll: PChar;
      FFreeCapConfig: string;
    protected
      function InjectLib(dwProcessId: DWORD; pszLibFile: PChar): Boolean;
    public
      constructor Create(ProcessPath, pszWorkDir, InjectDll: string);
      destructor Destroy; override;
      procedure Run();
      property FreeCapConfig: string read FFreeCapConfig write FFreeCapConfig;
    end;


implementation

{ TRemoteInjector }

constructor TRemoteInjector.Create(ProcessPath, pszWorkDir, InjectDll: string);
begin
     FProcessPath := ProcessPath;
     FWorkDir := pszWorkDir;
     FInjectDll := PChar(InjectDll);
end;

destructor TRemoteInjector.Destroy;
begin
  inherited;

end;


function TRemoteInjector.InjectLib(dwProcessId: DWORD; pszLibFile: PChar): Boolean;
var
   hProcess, hThread: THandle;
   pszLibFileRemote: PChar;
   cch, cb: integer;
   num_written, unused: dword;
   pfnThreadRtn: Pointer;
begin
     result := False; // Assume that the function fails
     num_written := 0;
     unused := 0;

     // Get a handle for the target process.
     hProcess := OpenProcess(
         PROCESS_QUERY_INFORMATION or   // Required by Alpha
         PROCESS_CREATE_THREAD     or   // For CreateRemoteThread
         PROCESS_VM_OPERATION      or   // For VirtualAllocEx/VirtualFreeEx
         PROCESS_VM_WRITE,              // For WriteProcessMemory
         FALSE, dwProcessId);
      if (hProcess = 0) then
         exit;

      // Calculate the number of bytes needed for the DLL's pathname
      cch := strlen(pszLibFile) + 1;
      cb  := cch * sizeof(Char);

      // Allocate space in the remote process for the pathname
      pszLibFileRemote := PChar(fnVirtualAllocEx(hProcess, nil, cb, MEM_COMMIT, PAGE_READWRITE));
      if (pszLibFileRemote = '') then
         exit;

      // Copy the DLL's pathname to the remote process's address space
      if not (WriteProcessMemory(hProcess, pszLibFileRemote, pszLibFile, cb, num_written)) then
        exit;

      // Get the real address of LoadLibraryW in Kernel32.dll
      pfnThreadRtn := GetProcAddress(GetModuleHandle('kernel32.dll'), 'LoadLibraryA');
      if (pfnThreadRtn = nil) then
         exit;

      // Create a remote thread that calls LoadLibraryA(DLLPathname)
      hThread := CreateRemoteThread(hProcess, nil, 0, pfnThreadRtn, pszLibFileRemote, 0, unused);
      if (hThread = 0) then
         exit;

      // Wait for the remote thread to terminate
      WaitForSingleObject(hThread, INFINITE);

      // Everything executed successfully
      // Now, we can clean everthing up
      // Free the remote memory that contained the DLL's pathname
      if (pszLibFileRemote <> nil) then
         VirtualFreeEx(hProcess, pszLibFileRemote, 0, MEM_RELEASE);

      if (hThread  <> 0) then
         CloseHandle(hThread);

      if (hProcess <> 0) then
         CloseHandle(hProcess);

      result := true;
end;

procedure TRemoteInjector.Run;
var
   ProcInfo : PROCESS_INFORMATION;
   StartInfo: STARTUPINFO;
begin
     if FFreeCapConfig <> '' then
        SetEnvironmentVariable('FreeCAPConfigFile', PChar(FFreeCapConfig));

     ZeroMemory(@ProcInfo, SizeOf(PROCESS_INFORMATION));
     ZeroMemory(@StartInfo, SizeOf(STARTUPINFO));
     if CreateProcess(Pchar(FProcessPath), nil, nil, nil, true, DETACHED_PROCESS or NORMAL_PRIORITY_CLASS, nil, PChar(FWorkDir), StartInfo, ProcInfo) then
       InjectLib(ProcInfo.dwProcessId, FInjectDll);
end;

end.
