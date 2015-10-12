{*
 * File: ...................... packdll.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev
 * Desc: ...................... Handle the hooking of packed DLL.
 *
 * The purpose of loader emulation is that packed DLL have modified entry point,
 * that points to section with decompressor code, which performs filling in-memory IAT
 * by calling LoadLibrary/GetProcAddress. The problem is that this table located
 * in memory and visible to DLL as IAT trought packer-specific mechanism (relocations or jmps').
 * So, we need to intercept functions in IAT before beginning decomressing.

 $Id: packdll.pas,v 1.9 2005/12/01 14:38:44 bert Exp $

 $Log: packdll.pas,v $
 Revision 1.9  2005/12/01 14:38:44  bert
 *** empty log message ***

 Revision 1.8  2005/11/29 14:42:37  bert
 Added wrapper for LoadLibrary for preventing recursion

 Revision 1.7  2005/11/28 08:53:59  bert
 *** empty log message ***

 Revision 1.6  2005/10/27 19:05:51  bert
 *** empty log message ***

 Revision 1.5  2005/07/19 03:52:26  bert
 *** empty log message ***

 Revision 1.4  2005/03/08 16:24:38  bert
 Fxied call to DllMain() when unloading DLL

 Revision 1.3  2005/03/04 14:13:56  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}

unit packdll;

interface
uses Windows, Classes, SysUtils, ImageHlp, win9x, loger, cfg, misc, export_hook;


function iLoadLibrary(lpFileName: PWideChar; dwFlags: DWORD): HMODULE; stdcall;
function iFreeLibrary(hMod: HMODULE): Boolean;

procedure Init();
procedure Fini();


type
    PLibraryModule = ^TLibraryModule;

    TLibraryModule = packed record
       libName: String[255];
       libHandle: HMODULE;
       loadCnt: integer;
       loadMode: integer;
    end;

    TLibraryModules = class
    private
      FLibs: TList;
      function CallDllMain(HMod: HMODULE): Boolean;
    public
      constructor Create; virtual;
      destructor Destroy; override;
      function GetIndex(libName: PWideChar): integer; overload;
      function GetIndex(hMod: HMODULE): integer; overload;
      function GetLoadCnt(hMod: HMODULE): integer; overload;
      function GetMode(hMod: HMODULE): integer; overload;
      function Exists(libName: PWideChar): Boolean;
      function LoadLib(libName: PWideChar; dwFlags: DWORD): HMODULE;
      function UnloadLib(hMod: HMODULE): Boolean;
    end;


var
   LibraryModules: TLibraryModules;


implementation
uses hook, hook_func, ws_hook;

var
   lpCriticalSection: TRTLCriticalSection;

function PeMapImgSections(NtHeaders: PImageNtHeaders): PImageSectionHeader;
begin
  if NtHeaders = nil then
    Result := nil
  else
    Result := PImageSectionHeader(DWORD(@NtHeaders^.OptionalHeader) +
      NtHeaders^.FileHeader.SizeOfOptionalHeader);
end;

//--------------------------------------------------------------------------------------------------

function PeMapImgFindSection(NtHeaders: PImageNtHeaders;
  const SectionName: string): PImageSectionHeader;
var
  Header: PImageSectionHeader;
  I: Integer;
begin
  Result := nil;
  if NtHeaders <> nil then
  begin
    Header := PeMapImgSections(NtHeaders);
    with NtHeaders^ do
      for I := 1 to FileHeader.NumberOfSections do
        if pos(lowercase(SectionName), lowercase(PChar(@Header^.Name))) > 0 then
        begin
          Result := Header;
          Break;
        end
        else
          Inc(Header);
  end;
end;



function isPacked(lpFileName: PWideChar; var anotherCopy: Boolean): Boolean;
var
   pDOSHeader: PIMAGEDOSHEADER;
   pNTHeader: PIMAGENTHEADERS;
   pBase: Pointer;
   sPacked: string;
   bAspack, bUPX: Boolean;
   hDLLModule: HModule;

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
begin
     result := False;
     hDLLModule := wrapper_LoadLibraryExW(lpFileName, 0, DONT_RESOLVE_DLL_REFERENCES);
     anotherCopy := GetProcAddress(hDLLModule, 'B6EC7AD52BE349E98013DE8B6D544ADF') <> nil;

     pBase := Pointer(hDLLModule);

     if pBase = nil then exit;

     pDOSHeader  := PIMAGEDOSHEADER(MakePtr(pBase, 0));
     pNTHeader  := PIMAGENTHEADERS(MakePtr(pDOSHeader, pDOSHeader^._lfanew));

     {*  Executable packers creates new section with decomrpessor code. Try to determine
      *  if there ASPack's or UPX's related sections. Perhaps this code should be fixed
      *  for another packers (ZiPack, etc)
      *}
     bAspack := (PeMapImgFindSection(pNTHeader, 'aspack') <> nil) or
            (PeMapImgFindSection(pNTHeader, 'adata') <> nil);
     bUPX := (PeMapImgFindSection(pNTHeader, 'upx') <> nil);

     sPacked := '';
     if bAspack then
       sPacked := 'ASPack'
     else if bUPX then
       sPacked := 'UPX';
     if (sPacked <> '') then
       Log(LOG_LEVEL_INJ, 'Library %s is packed by %s', [lpFileName, sPacked])
     else
       Log(LOG_LEVEL_INJ, 'Library %s is not packed', [lpFileName]);


     result := bAspack or bUPX;
     FreeLibrary(DWORD(pBase));
end;



function iLoadLibrary(lpFileName: PWideChar; dwFlags: DWORD): HMODULE; stdcall;
var
   DllMain : function (hinstDLL: HINST; fdwReason, lpvReserved: DWORD): Boolean; stdcall;

   pDOSHeader: PIMAGEDOSHEADER;
   pNTHeader: PIMAGENTHEADERS;
   oldProtect: DWORD;
   mbi: MEMORY_BASIC_INFORMATION;
   pBase: Pointer;
   ImportDesc: PIMAGE_IMPORT_DESCRIPTOR;
   Size: DWORD;
   anotherCopy: Boolean;

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
      OrdinalName: PImage_Import_By_Name;
      FOrdinal: DWORD;
      FName: PChar;
      hLib: HMODULE;
      pThunk: PImageThunkData;
   begin
        // Recursive load
        hLib := iLoadLibrary(PWideChar(WideString(AnsiString(Module))), 0);

        pThunk := PImageThunkData(RvaToVaEx(DWORD(ImportDesc^.FirstThunk)));

        if Thunk = nil then
          Exit;
        while Thunk^.Ordinal <> 0 do
        begin
             if Thunk^.Ordinal and IMAGE_ORDINAL_FLAG <> 0 then
             begin
                  FOrdinal := Thunk^.Ordinal and $FFFF;
                  pThunk^._Function := GetProcAddress(hLib, PChar(FOrdinal));
             end
             else
             begin
                  OrdinalName := PImage_Import_By_Name(RvaToVaEx(DWORD(Thunk^.AddressOfData)));
                  FName := PChar(@OrdinalName.Name);

                  Log(LOG_LEVEL_DEBUG, 'FName = %s', [FName]);

                  pThunk^._Function := GetProcAddress(hLib, FName);
             end;
             Inc(Thunk);
             inc(pThunk);
        end;
   end;

begin
     if dwFlags = 3 then
        dwFlags := 0;


     {* Win9x doesnt support DONT_RESOLVE_DLL_REFERENCES flag
      *}
//     Log(LOG_LEVEL_DEBUG, 'lpFileName = %s', [lpFileName]);

     if isWin9x() or ((not isWin9x()) and (GetModuleHandleW(lpFileName) <> 0)) then
     begin
          if LibraryModules.Exists(lpFileName) then
            result := LibraryModules.LoadLib(lpFileName, dwFlags)
          else
            result := wrapper_LoadLibraryExW(lpFileName, 0, dwFlags);

          if dwFlags <> LOAD_LIBRARY_AS_DATAFILE then
            InstallHookToHandle(result);

          exit;
     end;

     if dwFlags = LOAD_LIBRARY_AS_DATAFILE then
     begin
          if LibraryModules.Exists(lpFileName) then
            result := LibraryModules.LoadLib(lpFileName, dwFlags)
          else
            result := wrapper_LoadLibraryExW(lpFileName, 0, dwFlags);

          exit;
     end;

     if not isPacked(lpFileName, anotherCopy) then
     begin
          if anotherCopy then
          begin
               Log(LOG_LEVEL_WARN, 'Trying to load another copy of inject.dll!', []);
               result := 0;
          end
          else
          begin
              result := wrapper_LoadLibraryExW(lpFileName, 0, dwFlags);
              if GetProcAddress(result, 'D721F525FE944F9389AE200FF536FA23') = nil then
                InstallHookToHandle(result);
          end;

          exit;
     end;

     EnterCriticalSection(lpCriticalSection);

     result := LibraryModules.LoadLib(lpFileName, DONT_RESOLVE_DLL_REFERENCES);

     pBase := Pointer(result);
     if (pBase = nil) then
     begin
          Log(LOG_LEVEL_WARN, 'pBase = nil', []);
          LeaveCriticalSection(lpCriticalSection);
          exit;
     end;

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
     begin
          while ImportDesc^.Name <> 0 do
          begin
               if ImportDesc^.Characteristics = 0 then
                 EnumImportedFunctions(RvaToVa(ImportDesc^.Name), ImportDesc, PImageThunkData(RvaToVa(DWORD(ImportDesc^.FirstThunk))))
               else
                 EnumImportedFunctions(RvaToVa(ImportDesc^.Name), ImportDesc, PImageThunkData(RvaToVa(ImportDesc^.Characteristics)));
               Inc(ImportDesc);
          end;


          // IMPORTANT! We intercept functions in IAT *BEFORE* calling DllMain()
          InstallHookToHandle(result);

          if (pNTHeader^.OptionalHeader.AddressOfEntryPoint <> 0) then
          begin
               // And finally call the DllMain() to continue normal DLL initialization.
               @DllMain := RVAToVa(pNTHeader^.OptionalHeader.AddressOfEntryPoint);


               try
                  if not DllMain(result, DLL_PROCESS_ATTACH, 0) then
                  begin
                       Log(LOG_LEVEL_WARN, 'iLoadLibrary() call to DllMain of %s was unsuccessfull', [lpFileName]);
                       LibraryModules.UnloadLib(result);
                       result := 0;
                  end;
               except
                     Log(LOG_LEVEL_WARN, 'Exception in DllMain!', []);
                     LibraryModules.UnloadLib(result);
                     result := 0;
               end;
          end
          else
              Log(LOG_LEVEL_WARN, 'No entry point', []);
     end;
     LeaveCriticalSection(lpCriticalSection);
end;




function iFreeLibrary(hMod: HMODULE): Boolean;
var
   pDOSHeader: PIMAGEDOSHEADER;
   pNTHeader: PIMAGENTHEADERS;
   pBase: Pointer;
   ImportDesc: PIMAGE_IMPORT_DESCRIPTOR;
   Size: DWORD;
   lpFileNameA : PChar;
   hUnloadMod: HMODULE;

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

begin
     if isWin9x() then
     begin
          result := FreeLibrary(hMod);
          exit;
     end;

     if (hMod = 0) or (hMod = INVALID_HANDLE_VALUE) then
     begin
          result := False;
          exit;
     end;

     if LibraryModules.GetIndex(hMod) = -1 then
     begin
          result := FreeLibrary(hMod);
          exit;
     end;

     EnterCriticalSection(lpCriticalSection);

     pDOSHeader  := PIMAGEDOSHEADER(MakePtr(Pointer(hMod), 0));
     pNTHeader  := PIMAGENTHEADERS(MakePtr(pDOSHeader, pDOSHeader^._lfanew));

     // Unload all dependant libraries
     ImportDesc := ImageDirectoryEntryToData(pBase, True, IMAGE_DIRECTORY_ENTRY_IMPORT, Size);
     if ImportDesc <> nil then
     begin
          while ImportDesc^.Name <> 0 do
          begin
               lpFileNameA := PChar(RvaToVa(ImportDesc^.Name));

               hUnloadMod := GetModuleHandle(lpFileNameA);
               if hUnloadMod <> 0 then
                  LibraryModules.UnloadLib(hUnloadMod);
               Inc(ImportDesc);
          end;
     end;
     result := LibraryModules.UnloadLib(hMod);
     LeaveCriticalSection(lpCriticalSection);
end;



{ TLibraryModule }

function TLibraryModules.CallDllMain(HMod: HMODULE): Boolean;
var
   DllMain : function (hinstDLL: HINST; fdwReason, lpvReserved: DWORD): Boolean; stdcall;
   pDOSHeader: PIMAGEDOSHEADER;
   pNTHeader: PIMAGENTHEADERS;
   pBase: DWORD;
   function RvaToVa(Rva: DWORD): Pointer;
   begin
        Result := Pointer(DWORD(pBase) + Rva);
   end;
begin
     result := True;
     pBase := hMod;
     pDOSHeader  := PIMAGEDOSHEADER(MakePtr(Pointer(pBase), 0));
     pNTHeader  := PIMAGENTHEADERS(MakePtr(pDOSHeader, pDOSHeader^._lfanew));
     if (pNTHeader^.OptionalHeader.AddressOfEntryPoint <> 0) then
     begin
          @DllMain := RVAToVa(pNTHeader^.OptionalHeader.AddressOfEntryPoint);
          try
             if not DllMain(hMod, DLL_PROCESS_DETACH, 0) then
               result := False;
          except
              result := False;
          end;
     end;
end;

constructor TLibraryModules.Create;
begin
     FLibs := TList.Create;
end;

destructor TLibraryModules.Destroy;
var
   i: integer;
begin
     for i:=0 to FLibs.Count - 1 do
       FreeMem(FLibs[i]);
     FLibs.Free;
     inherited Destroy;
end;

function TLibraryModules.GetIndex(libName: PWideChar): integer;
var
   i: integer;
   s: string;
begin
     result := -1;
     try
        for i:=0 to FLibs.Count - 1 do
        begin
             s := PLibraryModule(FLibs[i])^.libName;

             if StrIComp(@s[1], PChar(AnsiString(WideString(libName)))) = 0 then
             begin
                  result := i;
                  exit;
             end;
        end;
     except
       on E: Exception do
         Log(LOG_LEVEL_WARN, 'TLibraryModules.GetIndex() exception! %s', [E.Message]);

     end;
end;

function TLibraryModules.Exists(libName: PWideChar): Boolean;
begin
     result := GetIndex(libName) >= 0;
end;

function TLibraryModules.GetIndex(hMod: HMODULE): integer;
var
   i: integer;
begin
     result := -1;
     if Self = nil then exit;

     for i:=0 to FLibs.Count - 1 do
         if PLibraryModule(FLibs[i])^.libHandle = hMod then
         begin
              result := i;
              exit;
         end;
end;

function TLibraryModules.GetLoadCnt(hMod: HMODULE): integer;
var
   idx: integer;
begin
     result := -1;
     idx := GetIndex(hMod);
     if (idx <> -1) then
       result := PLibraryModule(FLibs[idx])^.loadCnt;
end;

function TLibraryModules.GetMode(hMod: HMODULE): integer;
var
   idx: integer;
begin
     result := -1;
     idx := GetIndex(hMod);
     if (idx <> -1) then
       result := PLibraryModule(FLibs[idx])^.loadMode;
end;

function TLibraryModules.LoadLib(libName: PWideChar; dwFlags: DWORD): HMODULE;
var
   LibMod: PLibraryModule;
   idx : integer;
begin

     result := wrapper_LoadLibraryExW(PWideChar(libName), 0, dwFlags);
     if result > 0 then
     begin
          idx := GetIndex(libName);
          if (idx = -1) then
          begin
               EnterCriticalSection(lpCriticalSection);
               GetMem(LibMod, SizeOf(TLibraryModule));
               if (LibMod = nil) then
               begin
                    Log(LOG_LEVEL_WARN, 'Unable to allocate memory for LibMod!', []);
                    LeaveCriticalSection(lpCriticalSection);
                    exit;
               end;

               LibMod^.libName := string(libName);
               LibMod^.libHandle := result;
               LibMod^.loadCnt := 1;
               LibMod^.loadMode := dwFlags;
               Flibs.Add(LibMod);
               LeaveCriticalSection(lpCriticalSection);
          end
          else
          begin
               EnterCriticalSection(lpCriticalSection);
               LibMod := PLibraryModule(FLibs[idx]);
               inc(LibMod^.loadCnt);
               LeaveCriticalSection(lpCriticalSection);
          end;
     end;
end;

function TLibraryModules.UnloadLib(hMod: HMODULE): Boolean;
var
   idx: integer;
   LibMod: PLibraryModule;
begin
     result := False;
     idx := GetIndex(hMod);
     if (idx <> -1) then
     begin
          LibMod := PLibraryModule(FLibs[idx]);
          dec(LibMod^.loadCnt);

          if (LibMod^.loadCnt <= 0)  then
          begin
               EnterCriticalSection(lpCriticalSection);
               CallDllMain(LibMod^.libHandle);
               FreeMem(PLibraryModule(FLibs[idx]));
               FLibs.Delete(idx);
               LeaveCriticalSection(lpCriticalSection);
          end;
          result := FreeLibrary(hMod);
     end;
end;

procedure Init();
begin
     InitializeCriticalSection(lpCriticalSection);
     LibraryModules := TLibraryModules.Create;
end;


procedure Fini();
begin
     DeleteCriticalSection(lpCriticalSection);
     LibraryModules.Free;
end;


end.
