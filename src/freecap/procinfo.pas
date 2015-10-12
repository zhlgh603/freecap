{
  $Id: procinfo.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

  $Log: procinfo.pas,v $
  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}

unit procinfo;

interface
uses Windows, SysUtils, tlhelp32;

type
    TEnumProcCallback = procedure (pid: dword);

    procedure EnumProcesses(callback: TEnumProcCallback);


implementation

function CheckModule(module: string): Boolean;
var
   hMod: HMODULE;
begin
     hMod := LoadLibrary(PChar(module));
     result := GetProcAddress(hMod, 'B6EC7AD52BE349E98013DE8B6D544ADF') <> nil;
     FreeLibrary(hMod);
end;


function IsFuncPresent(pid: DWORD): Boolean;
var
   SnapShot: THandle;
   ModuleEntry: TModuleEntry32;
begin
     result := False;
     if pid = GetCurrentProcessId() then
        exit;

     SnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, pid);
     ZeroMemory(@ModuleEntry,SizeOf(TModuleEntry32));
     ModuleEntry.dwSize:=SizeOf(TModuleEntry32);

     if Module32First(SnapShot, ModuleEntry) then
     begin
          if pos('inject', lowercase(ModuleEntry.szModule)) > 0 then
          begin
               result := CheckModule(ModuleEntry.szExePath);
          end;

          if result then
          begin
               CloseHandle(SnapShot);
               exit;
          end;

          while Module32Next(SnapShot, ModuleEntry) do
          begin
               if pos('inject', lowercase(ModuleEntry.szModule)) > 0 then
               begin
                    result := CheckModule(ModuleEntry.szExePath);
               end;

               if result then
               begin
                    CloseHandle(SnapShot);
                    exit;
               end;
          end;
     end;
     CloseHandle(SnapShot);
end;



procedure EnumProcesses(callback: TEnumProcCallback);
var
   SnapShot: THandle;
   ProcessEntry: TProcessEntry32;
begin
     if @callback = nil then
        exit;

     SnapShot:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
     ZeroMemory(@ProcessEntry,SizeOf(TProcessEntry32));
     ProcessEntry.dwSize:=SizeOf(TProcessEntry32);

     if Process32First(SnapShot, ProcessEntry) then
     begin
          if IsFuncPresent(ProcessEntry.th32ProcessID) then
             callback(ProcessEntry.th32ProcessID);

          while Process32Next(SnapShot, ProcessEntry) do
          begin
               if IsFuncPresent(ProcessEntry.th32ProcessID) then
                 callback(ProcessEntry.th32ProcessID);
          end;
     end;
end;


end.
