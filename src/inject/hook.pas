{*
 * File: ...................... hook.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Hook the functions in IAT (Import Address Table) of loaded image and modules

 $Id: hook.pas,v 1.10 2005/12/19 06:09:02 bert Exp $

 $Log: hook.pas,v $
 Revision 1.10  2005/12/19 06:09:02  bert
 *** empty log message ***
}
unit hook;

interface
uses Windows, Classes, SysUtils, ImageHlp, tlhelp32, winsock2,
     hook_func, ws_hook, loger, cfg, misc, dns, win9x, dialogs,
     helpwnd, packdll {$IFDEF DEBUG}, memleaks{$ENDIF}, stub, export_hook, plugin_disp;
var
   wsock_hlib: HMODULE;
   ws2_hlib  : HMODULE;

   Imported  : Boolean = False;
   Imported2 : Boolean = False;

   function GetRealAddress(addr: Pointer): Pointer;
   function GetFuncByAddr(addr: Pointer): string;

   function ReplaceIATEntryInOneMod(pszCalleeModName: PChar; pfnCurrent, pfnNew: PDWORD; hmodCaller: HMODULE; bInstall: Boolean): integer;
   function ReplaceIATEntryInAllMods(pszCalleeModName: PChar; pfnCurrent, pfnNew: PDWORD; bInstall: Boolean): integer;

   function GetMyModule(): HMODULE;

   function GetModuleByHandle(hmod: HMODULE): string;

   function ModuleFromAddress(pv: Pointer): HMODULE;

   function isValidModule(hMod: HMODULE): Boolean;
   function IsImported(ModHandle: HMODULE; ModuleName: string): Boolean;

   function InstallHook(libname, funcname: string; NewHookProc: Pointer): Pointer;
   procedure InstallHooks;

   procedure InitModule();
   procedure CleanUp();
   procedure Reload();

   procedure DllHandler(reason: integer);
implementation

{*
 * Declarations was taken from winnt.h
 * I'm using Delphi5 and don't know has Borland updated windows.pas in the Delphi6 or Delphi7
 * with this declaration. Anyway if you get an error about 'Duplicate declarations or
 * something like this, just comment the following define
 *}
{$DEFINE NOT_HAVE_DECLARATIONS}

{$IFDEF NOT_HAVE_DECLARATIONS}
const
    IMAGE_DIRECTORY_ENTRY_IMPORT = 1;
    IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT = 11;
    IMAGE_DIRECTORY_ENTRY_IAT = 12;
    IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT = 13;


    IMAGE_ORDINAL_FLAG = $80000000;
type
    PIMAGE_IMPORT_BY_NAME = ^IMAGE_IMPORT_BY_NAME;
    IMAGE_IMPORT_BY_NAME = record
	    Hint: Word;
      Name: Byte;
    end;

    PIMAGE_THUNK_DATA = ^IMAGE_THUNK_DATA;
    IMAGE_THUNK_DATA = record
       case Integer of
         0: (ForwarderString: PByte);
         1: (_Function: PDWORD);
         2: (Ordinal: DWORD);
	 3: (AddressOfData: PIMAGE_IMPORT_BY_NAME);
    end;

    PIMAGE_IMPORT_DESCRIPTOR = ^IMAGE_IMPORT_DESCRIPTOR;
    IMAGE_IMPORT_DESCRIPTOR = record
       Characteristics: DWORD;
       TimeDateStamp: DWORD;
       ForwarderChain: DWORD;
       Name: DWORD;
       FirstThunk: PIMAGE_THUNK_DATA;
    end;



    PImgDelayDescr = ^TImgDelayDescr;
    ImgDelayDescr = packed record
      grAttrs: DWORD;                 // attributes
      szName: DWORD;                  // pointer to dll name
      phmod: PDWORD;                  // address of module handle
      pIAT: TImageThunkData;          // address of the IAT
      pINT: TImageThunkData;          // address of the INT
      pBoundIAT: TImageThunkData;     // address of the optional bound IAT
      pUnloadIAT: TImageThunkData;    // address of optional copy of original IAT
      dwTimeStamp: DWORD;             // 0 if not bound,
                                      // O.W. date/time stamp of DLL bound to (Old BIND)
    end;


  PImageBoundImportDescriptor = ^TImageBoundImportDescriptor;
  _IMAGE_BOUND_IMPORT_DESCRIPTOR = record
    TimeDateStamp: DWORD;
    OffsetModuleName: Word;
    NumberOfModuleForwarderRefs: Word;
    // Array of zero or more IMAGE_BOUND_FORWARDER_REF follows
  end;
  TImageBoundImportDescriptor = _IMAGE_BOUND_IMPORT_DESCRIPTOR;
  IMAGE_BOUND_IMPORT_DESCRIPTOR = _IMAGE_BOUND_IMPORT_DESCRIPTOR;

  PImageBoundForwarderRef = ^TImageBoundForwarderRef;
  _IMAGE_BOUND_FORWARDER_REF = record
    TimeDateStamp: DWORD;
    OffsetModuleName: Word;
    Reserved: Word;
  end;
  TImageBoundForwarderRef = _IMAGE_BOUND_FORWARDER_REF;
  IMAGE_BOUND_FORWARDER_REF = _IMAGE_BOUND_FORWARDER_REF;

TImgDelayDescr = ImgDelayDescr;

{$ENDIF}


function GetRealAddress(addr: Pointer): Pointer;
var
   si : SYSTEM_INFO;
begin
     result := addr;
     GetSystemInfo(si);

    {* Check if library is shared, i.e. loaded at address > lpMaximumApplicationAddress
     *}
     if DWORD(addr) > DWORD(si.lpMaximumApplicationAddress) then
     begin
          // The Win9x anti-debugger joke. The $68 is a PUSH opcode, real address follows
          if PBYTE(addr)^ = $68 then
          begin
               result := PDWORD(DWORD(PBYTE(addr)) + 1);
               result := PDWORD(result^);
          end;
     end;
end;




{*
 *  Replace references to specified "pfnCurrent" (original) entry point by
 *  "pfnNew" (our) function imported from "pszCalleeModName" in one loaded module (hmodCaller)
 *}
function ReplaceIATEntryInOneMod(pszCalleeModName: PChar; pfnCurrent, pfnNew: PDWORD; hmodCaller: HMODULE; bInstall: Boolean): integer;
type
   PPDWORD = ^PDWORD;
var
   pImportDesc : PIMAGE_IMPORT_DESCRIPTOR;
   pThunk      : PIMAGE_THUNK_DATA;
   ulSize      : LongWord;
   pszModName  : PChar;
   ppfn        : PPDWORD;
   rva_addr    : PPDWORD;
   bFound      : Boolean;
   mbi         : MEMORY_BASIC_INFORMATION;
   dwOldProtect: DWord;
   si          : SYSTEM_INFO;
   res         : Boolean;
   num_written : DWORD;
   bWin9x      : Boolean;
   funcPtr     : Pointer;

{
var
   pDOSHeader: PIMAGEDOSHEADER;
   pNTHeader: PIMAGENTHEADERS;
   oldProtect: DWORD;
   mbi: MEMORY_BASIC_INFORMATION;
   pBase: Pointer;
   ImportDesc: PIMAGE_IMPORT_DESCRIPTOR;
   Size: DWORD;


   function RvaToVa(Rva: DWORD): Pointer;
   begin
        Result := Pointer(DWORD(pBase) + Rva);
   end;

   function RvaToVaEx(Rva: DWORD): Pointer;
   begin
        if (Rva > pNtHeader^.OptionalHeader.SizeOfImage) and (Rva > pNtHeader^.OptionalHeader.ImageBase) then
          Dec(Rva, pNtHeader^.OptionalHeader.ImageBase);
        Result := RvaToVa(Rva);
   end;

   procedure EnumImportedFunctions(Module: PChar; ImportDesc: PIMAGE_IMPORT_DESCRIPTOR; Thunk: PImageThunkData);
   var
      pThunk: PImageThunkData;
   begin
        pThunk := PImageThunkData(RvaToVaEx(DWORD(ImportDesc^.FirstThunk)));

        if Thunk = nil then
          Exit;
        while Thunk^.Ordinal <> 0 do
        begin
             if pfnCurrent = pThunk^._Function then
             begin
                  pThunk^._Function := pfnNew;
                  inc(result);
             end;

             Inc(Thunk);
             inc(pThunk);
        end;
   end;
}
begin
     result := 0;
{
     pBase := Pointer(hmodCaller);
     if (pBase = nil) then
       exit;

     pDOSHeader  := PIMAGEDOSHEADER(MakePtr(pBase, 0));
     pNTHeader  := PIMAGENTHEADERS(MakePtr(pDOSHeader, pDOSHeader^._lfanew));


     VirtualQuery(pBase, mbi, sizeof(MEMORY_BASIC_INFORMATION));
     if not VirtualProtect(mbi.BaseAddress, pNTHeader^.OptionalHeader.SizeOfImage, PAGE_EXECUTE_READWRITE, oldProtect) then
       Log(LOG_LEVEL_WARN, 'VirtualProtect failed. GetLastError = %d', [getLastError()]);


     //* We have loaded our DLL with DONT_RESOLVE_DLL_REFERENCES, it means that no dependans libraries
     //* are loaded and there're no filled IAT in the mapped image. We should to do it by our hands
     //*
     ImportDesc := ImageDirectoryEntryToData(pBase, True, IMAGE_DIRECTORY_ENTRY_IMPORT, Size);
     if ImportDesc <> nil then
       while ImportDesc^.Name <> 0 do
       begin
            if ImportDesc^.Characteristics = 0 then
              EnumImportedFunctions(RvaToVa(ImportDesc^.Name), ImportDesc, PImageThunkData(RvaToVa(DWORD(ImportDesc^.FirstThunk))))
            else
              EnumImportedFunctions(RvaToVa(ImportDesc^.Name), ImportDesc, PImageThunkData(RvaToVa(ImportDesc^.Characteristics)));
            Inc(ImportDesc);
       end;
}



     bWin9x := isWin9x();

     pImportDesc := ImageDirectoryEntryToData(Pointer(hmodCaller), True, IMAGE_DIRECTORY_ENTRY_IMPORT, ulSize);
     if pImportDesc = nil then
        exit;

     GetSystemInfo(si);


     while (pImportDesc^.Name <> 0) do
     begin
          pszModName := PChar(PBYTE(hmodCaller + pImportDesc^.Name));

          if (stricomp(pszModName, pszCalleeModName) = 0) then
          begin

               pThunk := PIMAGE_THUNK_DATA(PBYTE(hmodCaller + DWORD(pImportDesc^.FirstThunk)));

               if pThunk = nil then
               begin
                    Log(LOG_LEVEL_DEBUG, 'pThunk = nil???', []);

                    inc(pImportDesc);
                    continue;
               end;

               while (pThunk <> nil) and (pThunk^._Function <> nil) do
               begin
                    ppfn   := PPDWORD(@pThunk^._Function);
                    bFound := (ppfn^ = pfnCurrent);

                    //* Check if library is shared, i.e. loaded at address > lpMaximumApplicationAddress
                    //*
                    if (not bFound) and (DWORD(ppfn^) > DWORD(si.lpMaximumApplicationAddress)) then
                    begin
                         // The Win9x anti-debugger joke. The $68 is a PUSH opcode, real address follows
                         if PByte(ppfn^)^ = $68 then
                         begin
                              if (not bWin9x) then
                              begin
                                   ppfn := PPDWORD(DWORD(PByte(ppfn^)) + 1);
                                   bFound := (ppfn^ = pfnCurrent);
                              end
                              else
                              begin
                                   rva_addr := PPDWORD(DWORD(PByte(ppfn^)) + 1);
                                   bFound := (rva_addr^ = pfnCurrent);
                              end;
                         end;
                    end;


                    if (bFound) then
                    begin
                         //*
                         //* We should change protection of ".idata" which has "r--" permission to "rw-"
                         //*
                         ZeroMemory(@mbi, sizeof(MEMORY_BASIC_INFORMATION));
                         VirtualQuery(ppfn, mbi, sizeof(MEMORY_BASIC_INFORMATION));

                         if VirtualProtect(mbi.BaseAddress, mbi.RegionSize, PAGE_READWRITE, mbi.Protect) then
                         begin

                              if (not bWin9x) then
                              begin
                                   //* Write data *
                                   try
                                      ppfn^ := pfnNew;
                                   except
                                      on E: Exception do
                                        Log(LOG_LEVEL_WARN, ':::>  An error occured while writing memory: %s', [E.Message]);
                                   end;
                              end
                              else
                              begin
                                   if bInstall then
                                     PlaceHook(ppfn, pfnCurrent, pfnNew, bInstall)
                                   else
                                   begin
                                        ppfn^ := pfnNew;
                                   end;

                              end;
                              //* change protection back *

                              VirtualProtect(mbi.BaseAddress, mbi.RegionSize, mbi.Protect, dwOldProtect);
//                              Log(LOG_LEVEL_INJ, ':::> Function %s hooked', [GetFuncByAddr(pfnCurrent)]);
                              inc(result);
                         end
                         else
                         begin
                              if (not bWin9x) then
                              begin
                                   res := WriteProcessMemory(GetCurrentProcess(), ppfn^, pfnNew, sizeof(pfnNew), num_written);
//                                   Log(LOG_LEVEL_INJ, ':::> Function %s hooked', [GetFuncByAddr(ppfn^)]);

                                   if (not res) or (num_written <> sizeof(pfnNew)) then
                                   begin
                                        Log(LOG_LEVEL_WARN, ':::> Unable to change %s to 0x%p',[GetFuncByAddr(ppfn^), pfnNew]);
                                   end
                                   else
                                       inc(result);
                              end
                              else
                              begin
                                   funcPtr := ppfn^;
                                   Log(LOG_LEVEL_WARN, 'Unable to change address of %s. Will try in "cheater mode"', [GetFuncByAddr(funcPtr)]);

                                   if bInstall then
                                   begin
                                        if PlaceHook(ppfn, pfnCurrent, pfnNew, bInstall) then
                                          Log(LOG_LEVEL_INJ, 'Hooking %s in cheater mode completed succesfully', [GetFuncByAddr(funcPtr)])
                                        else
                                          Log(LOG_LEVEL_WARN, '!!! Unable to change even in cheater mode %s in %s !!!', [GetFuncByAddr(funcPtr), GetModuleByHandle(ModuleFromAddress(ppfn))]);
                                   end
                                   else
                                   begin
                                        ppfn^ := pfnNew;
                                   end;
                              end;

                         end;
                    end;
                    inc(pThunk);
               end;
          end;
          inc(pImportDesc);
     end;
end;



procedure PrintModules();
var
   SnapShot:THandle;
   ModuleEntry:TModuleEntry32;
begin
     SnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
     ZeroMemory(@ModuleEntry,SizeOf(TModuleEntry32));
     ModuleEntry.dwSize:=SizeOf(TModuleEntry32);

     if Module32First(SnapShot, ModuleEntry) then
     begin
          Log(LOG_LEVEL_INJ, '0x%p %s', [ModuleEntry.modBaseAddr, ModuleEntry.szExePath]);
          while Module32Next(SnapShot, ModuleEntry) do
             Log(LOG_LEVEL_INJ, '0x%p %s', [ModuleEntry.modBaseAddr, ModuleEntry.szExePath]);
     end;
     CloseHandle(SnapShot);
end;


function GetModuleByHandle(hmod: HMODULE): string;
var
   Buf: array[0..MAX_PATH] of char;
begin
     ZeroMemory(@Buf,SizeOf(Buf));
     if GetModuleFileName(hMod, @Buf, SizeOf(Buf)) > 0 then
       result := ExtractFileName(buf)
     else
       result := Format('Unknown module 0x%x', [hMod]);
end;


function GetAddress(libname: pchar): HMODULE;
var
   pb       : PBYTE;
   nLen     : DWORD;
   mbi      : MEMORY_BASIC_INFORMATION;
   szModName: array[0..MAX_PATH] of char;
begin
     pb := nil;
     result := 0;
     while (VirtualQuery(pb, mbi, sizeof(mbi)) = sizeof(mbi)) do
     begin
         if (mbi.State = MEM_FREE) then
            mbi.AllocationBase := mbi.BaseAddress;

         if ((DWORD(mbi.AllocationBase) = hInstance) or
             (mbi.AllocationBase <> mbi.BaseAddress) or
             (mbi.AllocationBase = nil)) then
         begin
            nLen := 0;
         end
         else
         begin
              nLen := GetModuleFileNameA(DWORD(mbi.AllocationBase),
               szModName, sizeof(szModName));
         end;

         if (nLen > 0) and (lowercase(ExtractFileName(szModName)) = lowercase(libname)) then
         begin
              result := HMODULE(mbi.BaseAddress);
              exit;
         end;
         inc(pb, mbi.RegionSize);
     end;
end;

{*
 * Get an HMODULE from some address
 *}
function ModuleFromAddress(pv: Pointer): HMODULE;
var
   mbi: MEMORY_BASIC_INFORMATION;
begin
     if (VirtualQuery(pv, mbi, sizeof(mbi)) <> 0) then
        result := HMODULE(mbi.AllocationBase)
     else
        result := 0;
end;


function GetMyModule(): HMODULE;
begin
     result := ModuleFromAddress(@GetMyModule);
end;


function isValidModule(hMod: HMODULE): Boolean;
var
   SnapShot:THandle;
   ModuleEntry:TModuleEntry32;
begin
     result := False;
     SnapShot:=CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, 0);
     ZeroMemory(@ModuleEntry,SizeOf(TModuleEntry32));
     ModuleEntry.dwSize:=SizeOf(TModuleEntry32);

     if Module32First(SnapShot, ModuleEntry) then
     begin
          if hMod = ModuleEntry.hModule then
          begin
               result := True;
          end;

          while (not result) and Module32Next(SnapShot, ModuleEntry) do
          begin
               if hMod = ModuleEntry.hModule then
               begin
                    result := True;
                    break;
               end;
          end;
     end;
     CloseHandle(SnapShot);
end;


function GetFuncByAddr(addr: Pointer): string;
var
   i: integer;
   addr2: Pointer;
begin
     result := 'Unknown';
     for i:=0 to High(MandatoryFunctions) do
     begin
          if MandatoryFunctions[i].fnOrig = nil then
             addr2 := GetRealAddress(GetProcAddress(GetModuleHandle(MandatoryFunctions[i].fnModule), MandatoryFunctions[i].fnName))
          else
             addr2 := MandatoryFunctions[i].fnOrig;

          if addr2 = addr then
          begin
               result := MandatoryFunctions[i].fnName;
               break;
          end;
     end;
     if result = 'Unknown' then
     begin
          for i:=0 to High(HookedFunctions) do
          begin
               if HookedFunctions[i].fnOrig = nil then
                 addr2 := GetRealAddress(GetProcAddress(GetModuleHandle(HookedFunctions[i].fnModule), HookedFunctions[i].fnName))
               else
                 addr2 := HookedFunctions[i].fnOrig;

               if addr2 = addr then
               begin
                    result := HookedFunctions[i].fnName;
                    break;
               end;
          end;
     end;
     if result = 'Unknown' then
       result := Format('%p',[addr]);
end;

function ReplaceIATEntryInAllMods(pszCalleeModName: PChar; pfnCurrent, pfnNew: PDWORD; bInstall: Boolean): integer;
var
   SnapShot: THandle;
   ModuleEntry: TModuleEntry32;
   me: HMODULE;
   numHooks: integer;
   funcName: string;
begin
     result := 0;
     me := GetMyModule();

     funcName := GetFuncByAddr(pfnCurrent);

     SnapShot:=CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, 0);
     ZeroMemory(@ModuleEntry,SizeOf(TModuleEntry32));
     ModuleEntry.dwSize:=SizeOf(TModuleEntry32);

{     Log(LOG_LEVEL_INJ, 'Placing hooks for %s in module `%s`', [GetFuncByAddr(pfnCurrent), GetModuleByHandle(GetModuleHandle(nil))]);
     numHooks := ReplaceIATEntryInOneMod(pszCalleeModName, pfnCurrent, pfnNew, GetModuleHandle(nil), bInstall);
     inc(result, numHooks);
}
     if Module32First(SnapShot, ModuleEntry) then
     begin

          if (ModuleEntry.hModule <> me) and (GetProcAddress(ModuleEntry.hModule, 'D721F525FE944F9389AE200FF536FA23') = nil)
            and (ModuleEntry.hModule <> GetModuleHandle('disasm_engine.dll')) then
          begin
               numHooks := ReplaceIATEntryInOneMod(pszCalleeModName, pfnCurrent, pfnNew, ModuleEntry.hModule, bInstall);
               if (numHooks > 0) and bInstall then
                  Log(LOG_LEVEL_INJ, #9'Placing hook for "%s" in module `%s`', [funcName, ModuleEntry.szModule]);
               inc(result, numHooks);
          end;

          while Module32Next(SnapShot, ModuleEntry) do
          begin
               if (ModuleEntry.hModule <> me)  and (GetProcAddress(ModuleEntry.hModule, 'D721F525FE944F9389AE200FF536FA23') = nil)
                and (ModuleEntry.hModule <> GetModuleHandle('disasm_engine.dll')) then
               begin
                    numHooks := ReplaceIATEntryInOneMod(pszCalleeModName, pfnCurrent, pfnNew, ModuleEntry.hModule, bInstall);
                    if (numHooks > 0) and bInstall then
                      Log(LOG_LEVEL_INJ, #9'Placing hook for "%s" in module `%s`', [funcName, ModuleEntry.szModule]);
                    inc(result, numHooks);
               end;
          end;
     end;
     CloseHandle(SnapShot);
end;

function IsImported(ModHandle: HMODULE; ModuleName: string): Boolean;
var
   pImportDesc: PIMAGE_IMPORT_DESCRIPTOR;
   ulSize: LongWord;
   ModName: string;
   hmodCaller: HMODULE;
begin
     result := false;
     ModuleName := lowercase(ModuleName);
     hmodCaller := ModHandle;
     pImportDesc := PIMAGE_IMPORT_DESCRIPTOR(ImageDirectoryEntryToData(Pointer(hmodCaller), True, IMAGE_DIRECTORY_ENTRY_IMPORT, ulSize));
     if pImportDesc = nil then
        exit;

     while (pImportDesc^.Name <> 0) do
     begin
          ModName := lowercase(PChar(PBYTE(hmodCaller + pImportDesc^.Name)));
          if ModName = ModuleName then
          begin
               result := True;
               exit;
          end;
          inc(pImportDesc);
     end;
end;

procedure InstallHooks;
var
   i: integer;
   HookStub: PHookStub;

   function OffsetOf(start, stop: Pointer): DWORD;
   begin
        result := DWORD(stop) - DWORD(start);
   end;

   function CalcJMPOffset(destaddr, jmp_addr: Pointer): DWORD;
   begin
        result := DWORD(destaddr) - DWORD(jmp_addr) - 5;
   end;

   function GetVA(mem_base: DWORD; Target: Pointer): DWORD;
   begin
        result := DWORD(mem_base) + OffsetOf(HookStub, Target);
   end;

   function GetVA_(mem_base: DWORD; Target: Pointer): DWORD;
   begin
        result := DWORD(mem_base) + OffsetOf(@LoadLibraryExW_ExportStub, Target);
   end;

begin
     // check if winsock is already static imported
     Imported := IsImported(GetModuleHandle(nil), 'wsock32.dll');
     Imported2 := IsImported(GetModuleHandle(nil), 'ws2_32.dll');

     {*
      * Don't wonder, kernel32.dll is not a real 'kernel' executed in the zero ring.
      * This is a ordinary DLL like our. Kernel32.dll issuing all calls through the
      * multiplexor interrupt i.e. via "int 2Eh"
      *}

     for i:=0 to High(MandatoryFunctions) do
     begin
          MandatoryFunctions[i].fnOrig := InstallHook(MandatoryFunctions[i].fnModule, MandatoryFunctions[i].fnName, MandatoryFunctions[i].fnNew);
     end;

     if prog_advanced_hooking then
       PlaceExportHook();

     wsock_hlib := LoadLibrary('wsock32.dll');
     ws2_hlib := LoadLibrary('ws2_32.dll');

     Log(LOG_LEVEL_INJ, 'Prepare for install WSOCK hooks...',[]);

     PrepareWSockHooks();
     Log(LOG_LEVEL_INJ, 'Installing WSOCK hooks...',[]);
     InstallWSockHooks('wsock32.dll');

     if Imported then
       Log(LOG_LEVEL_INJ, 'Module wsock32.dll statically imported',[]);

     if Imported2 then
       Log(LOG_LEVEL_INJ, 'Module ws2_32.dll statically imported',[]);
end;

function InstallHook(libname, funcname: string; NewHookProc: Pointer): Pointer;
var
   hMod: HMODULE;
   numHooks: integer;
begin
     result := nil;
     hMod := GetModuleHandle(PChar(libname));

     if hMod = 0 then
     begin
          Log(LOG_LEVEL_WARN, 'Module %s hasn''t mapped',[libname]);
          exit;
     end;

     result := GetProcAddress(hMod, PChar(funcname));

     if result = nil then
     begin
          Log(LOG_LEVEL_WARN, 'Function `%s` not found in module %s',[funcname, libname]);
          exit;
     end;

     if result = NewHookProc then
     begin
          Log(LOG_LEVEL_WARN, 'Function `%s` already hooked',[funcname]);
          exit;
     end;

     result := GetRealAddress(result);
     // Okay, We've got all what we need, process it!

     numHooks := ReplaceIATEntryInAllMods(PChar(libname), result, NewHookProc, True);
     if numHooks > 1 then
       Log(LOG_LEVEL_INJ, 'There''re %d hooks for "%s" placed',[numHooks, funcname]);
end;



{*********************** DLL specific procedures ****************************}

{*  InitModule()
 *  Like DLLMain() with DLL_PROCESS_ATTACH
 *}
procedure InitModule();
begin
//     memLeaks.Init();

     winsock2.Init();

     loger.Init;
     OpenLog();

     stub.Init;
     dns.init;

     win9x.Init();
     helpwnd.Init();
     packdll.Init();
     plugin_disp.Init();


     Log(LOG_LEVEL_FREECAP, 'Module init(%s, FreeCap v%s)',[GetWinVer(), FREECAP_VERSION]);

     LoadLibrary('psapi.dll');
     PrintModules();
     InstallHooks();
end;


{*  CleanUp()
 *  Like DLLMain() with DLL_PROCESS_DETACH
 *}
procedure CleanUp();
var
   i: integer;
//   HookStub: PHookStub;
begin
     Log(LOG_LEVEL_INJ, 'Module cleanup()',[]);
     for i:=0 to High(MandatoryFunctions) do
        MandatoryFunctions[i].fnOrig := InstallHook(MandatoryFunctions[i].fnModule, MandatoryFunctions[i].fnName, MandatoryFunctions[i].fnNew);
{
     dns.Fini;
     win9x.Fini();
     packdll.fini();
     Plugin_Disp.Fini;
     CloseLog();
     loger.Fini;}
end;

procedure Reload();
begin
     try
        CloseLog();
        cfg.ReadConfig();
        OpenLog();
        if (@ProxyIntf.pOnReload <> nil) then
          ProxyIntf.pOnReload;
     except
       on E: Exception do
        Log(LOG_LEVEL_WARN, 'Reload() exception! %s', [E.Message]);
     end;

end;

{*  DllHandler()
 *  Delphi analog of C DLLMain() procedure
 *}
procedure DllHandler(reason: integer);
begin
     if reason = DLL_PROCESS_DETACH then
     begin
          CleanUp();
          Unloaded := True;
     end;
end;


end.


