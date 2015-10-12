  function Hook_EnumProcesses (lpidProcess: LPDWORD; cb: DWORD; var cbNeeded: DWORD): BOOL stdcall;
  function Hook_EnumProcessModules (hProcess: THandle; lphModule: LPDWORD; cb: DWORD; var lpcbNeeded: DWORD): BOOL stdcall;
  function Hook_GetModuleBaseNameA (hProcess: THandle; hModule: HMODULE; lpBaseName: PAnsiChar; nSize: DWORD): DWORD stdcall;
  function Hook_GetModuleBaseNameW (hProcess: THandle; hModule: HMODULE; lpBaseName: PWideChar; nSize: DWORD): DWORD stdcall;
  function Hook_GetModuleFileNameExA (hProcess: THandle; hModule: HMODULE; lpFilename: PAnsiChar; nSize: DWORD): DWORD stdcall;
  function Hook_GetModuleFileNameExW (hProcess: THandle; hModule: HMODULE; lpFilename: PWideChar; nSize: DWORD): DWORD stdcall;
  function Hook_GetModuleInformation (hProcess: THandle; hModule: HMODULE; lpmodinfo: LPMODULEINFO; cb: DWORD): BOOL stdcall;
  function Hook_EmptyWorkingSet (hProcess: THandle): BOOL stdcall;
  function Hook_QueryWorkingSet (hProcess: THandle; pv: Pointer; cb: DWORD): BOOL stdcall;
  function Hook_InitializeProcessForWsWatch (hProcess: THandle): BOOL stdcall;
  function Hook_GetMappedFileNameA (hProcess: THandle; lpv: Pointer; lpFilename: PAnsiChar; nSize: DWORD): DWORD stdcall;
  function Hook_GetMappedFileNameW (hProcess: THandle; lpv: Pointer; lpFilename: PWideChar; nSize: DWORD): DWORD stdcall;
  function Hook_GetDeviceDriverBaseNameA (ImageBase: Pointer; lpBaseName: PAnsiChar; nSize: DWORD): DWORD stdcall;
  function Hook_GetDeviceDriverBaseNameW (ImageBase: Pointer; lpBaseName: PWideChar; nSize: DWORD): DWORD stdcall;
  function Hook_GetDeviceDriverFileNameA (ImageBase: Pointer; lpFileName: PAnsiChar; nSize: DWORD): DWORD stdcall;
  function Hook_GetDeviceDriverFileNameW (ImageBase: Pointer; lpFileName: PWideChar; nSize: DWORD): DWORD stdcall;
  function Hook_EnumDeviceDrivers (lpImageBase: PPointer; cb: DWORD; var lpcbNeeded: DWORD): BOOL stdcall;
  function Hook_GetProcessMemoryInfo (Process: THandle; ppsmemCounters: PPROCESS_MEMORY_COUNTERS; cb: DWORD): BOOL stdcall;

