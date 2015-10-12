function Hook_EnumProcesses (lpidProcess: LPDWORD; cb: DWORD; var cbNeeded: DWORD): BOOL stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := EnumProcesses (lpidProcess, cb, cbNeeded);
end;

function Hook_EnumProcessModules (hProcess: THandle; lphModule: LPDWORD; cb: DWORD; var lpcbNeeded: DWORD): BOOL stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := EnumProcessModules(hProcess, lphModule, cb, lpcbNeeded);
end;

function Hook_GetModuleBaseNameA (hProcess: THandle; hModule: HMODULE; lpBaseName: PAnsiChar; nSize: DWORD): DWORD stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := GetModuleBaseNameA(hProcess, hModule, lpBaseName, nSize);
end;

function Hook_GetModuleBaseNameW (hProcess: THandle; hModule: HMODULE; lpBaseName: PWideChar; nSize: DWORD): DWORD stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := GetModuleBaseNameW(hProcess, hModule, lpBaseName, nSize);
end;

function Hook_GetModuleFileNameExA (hProcess: THandle; hModule: HMODULE; lpFilename: PAnsiChar; nSize: DWORD): DWORD stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := GetModuleFileNameExA(hProcess, hModule, lpFilename, nSize);
end;

function Hook_GetModuleFileNameExW (hProcess: THandle; hModule: HMODULE; lpFilename: PWideChar; nSize: DWORD): DWORD stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := GetModuleFileNameExW(hProcess, hModule, lpFilename, nSize);
end;

function Hook_GetModuleInformation (hProcess: THandle; hModule: HMODULE; lpmodinfo: LPMODULEINFO; cb: DWORD): BOOL stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := GetModuleInformation(hProcess,  hModule, lpmodinfo, cb);
end;

function Hook_EmptyWorkingSet (hProcess: THandle): BOOL stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := EmptyWorkingSet(hProcess);
end;

function Hook_QueryWorkingSet (hProcess: THandle; pv: Pointer; cb: DWORD): BOOL stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := QueryWorkingSet(hProcess, pv, cb);
end;

function Hook_InitializeProcessForWsWatch (hProcess: THandle): BOOL stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := InitializeProcessForWsWatch(hProcess);
end;


function Hook_GetMappedFileNameA (hProcess: THandle; lpv: Pointer; lpFilename: PAnsiChar; nSize: DWORD): DWORD stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := GetMappedFileNameA(hProcess, lpv, lpFilename, nSize);
end;

function Hook_GetMappedFileNameW (hProcess: THandle; lpv: Pointer; lpFilename: PWideChar; nSize: DWORD): DWORD stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := GetMappedFileNameW(hProcess, lpv, lpFilename, nSize);
end;

function Hook_GetDeviceDriverBaseNameA (ImageBase: Pointer; lpBaseName: PAnsiChar; nSize: DWORD): DWORD stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := GetDeviceDriverBaseNameA(ImageBase, lpBaseName, nSize);
end;

function Hook_GetDeviceDriverBaseNameW (ImageBase: Pointer; lpBaseName: PWideChar; nSize: DWORD): DWORD stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := GetDeviceDriverBaseNameW(ImageBase, lpBaseName, nSize);
end;

function Hook_GetDeviceDriverFileNameA (ImageBase: Pointer; lpFileName: PAnsiChar; nSize: DWORD): DWORD stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := GetDeviceDriverFileNameA(ImageBase, lpFileName, nSize);
end;

function Hook_GetDeviceDriverFileNameW (ImageBase: Pointer; lpFileName: PWideChar; nSize: DWORD): DWORD stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := GetDeviceDriverFileNameW(ImageBase, lpFileName, nSize);
end;

function Hook_EnumDeviceDrivers (lpImageBase: PPointer; cb: DWORD; var lpcbNeeded: DWORD): BOOL stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := EnumDeviceDrivers(lpImageBase, cb, lpcbNeeded);
end;

function Hook_GetProcessMemoryInfo (Process: THandle; ppsmemCounters: PPROCESS_MEMORY_COUNTERS; cb: DWORD): BOOL stdcall;
begin
     LOG(LOG_LEVEL_DEBUG, '%s', [__PROC__]);
     result := GetProcessMemoryInfo(Process, ppsmemCounters, cb);
end;

