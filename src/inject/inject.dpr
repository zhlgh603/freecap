{*
 * File: ...................... inject.dpr
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Injection library
 *}
{$C+} // Should be enabled in Compiler options dialog (!!! mandatory !!!)
Library inject;

uses
  check2ndcopy,
  Windows,
  SysUtils,
  tlhelp32,
  registry,
  cfg in '..\cfg.pas',
  hook in 'hook.pas',
  winsock2 in '..\winsock2.pas',
  hook_func in 'hook_func.pas',
  loger in '..\loger.pas',
  ws_hook in 'ws_hook.pas',
  misc in '..\misc.pas',
  base64 in '..\base64.pas',
  abs_config in '..\abs_config.pas',
  xml_config in '..\xml_config.pas',
  reg_config in '..\reg_config.pas',
  dns in 'dns.pas',
  common in '..\common.pas',
  Injector in 'Injector.pas',
  win9x in 'win9x.pas',
  SharedDispatch in 'SharedDispatch.pas',
  helpwnd in 'helpwnd.pas',
  packdll in 'packdll.pas',
  proxy_intf in '..\proxy_intf.pas',
  rpcrt in '..\rpcrt.pas',
  stub in 'stub.pas' {$IFDEF DEBUG},
  DebugExcept in 'DebugExcept.pas',
  memleaks in '..\memleaks.pas' {$ENDIF},
  export_hook in 'export_hook.pas',
  Plugin in '..\Plugin.pas',
  Plugin_Disp in '..\Plugin_Disp.pas';
{$R *.res}



{* For debugging with IE.
 * call "tregsvr inject.dll" for register and embedding into IE
 * Click right button on the IE toolbar and re-check the 'Just a test'
 * for initiate IE to load our dll. This is very useful for debuging inject.dll under Delphi IDE :)
 *}
function DllRegisterServer: HRESULT; stdcall;
var
   Buf: array[0..7] of byte;
begin
     result := S_OK;

     with TRegistry.Create do
     begin
          RootKey := HKEY_CLASSES_ROOT;
          OpenKey('\CLSID\{A2FB692D-7037-4B0F-B1AF-98902F58F686}',True);
          WriteString('','Just a test');
          OpenKey('\CLSID\{A2FB692D-7037-4B0F-B1AF-98902F58F686}\InprocServer32',True);
          WriteString('',GetCurrentDir() + '\inject.dll');
          WriteString('ThreadingModel','Apartment');
          RootKey := HKEY_LOCAL_MACHINE;
          OpenKey('\Software\Microsoft\Internet Explorer\Explorer Bars\{A2FB692D-7037-4B0F-B1AF-98902F58F686}',True);

          ZeroMemory(@Buf, SizeOf(Buf));
          Buf[0] := $41;
          WriteBinaryData('BarSize',Buf, SizeOf(Buf));
          OpenKey('\Software\Microsoft\Internet Explorer\Toolbar',False);
          WriteBinaryData('{A2FB692D-7037-4B0F-B1AF-98902F58F686}',Buf[1], 1);
          Free;
     end;
end;

function DllUnregisterServer: HRESULT; stdcall;
begin
     result := S_OK;

     with TRegistry.Create do
     begin
          RootKey := HKEY_CLASSES_ROOT;
          DeleteKey('\CLSID\{A2FB692D-7037-4B0F-B1AF-98902F58F686}');
          RootKey := HKEY_LOCAL_MACHINE;
          DeleteKey('\Software\Microsoft\Internet Explorer\Explorer Bars\{A2FB692D-7037-4B0F-B1AF-98902F58F686}');
          OpenKey('\Software\Microsoft\Internet Explorer\Toolbar',False);
          DeleteValue('{A2FB692D-7037-4B0F-B1AF-98902F58F686}');
          Free;
     end;
end;


{*  Unique function name (based on generated GUID) for prevent second loading by LoadLibrary() call
 *}
function B6EC7AD52BE349E98013DE8B6D544ADF(): Boolean; stdcall;
begin
     result := True;
end;


procedure AssertHdr(const Message, Filename: string; LineNumber: Integer; ErrorAddr: Pointer);
begin
     Log(LOG_LEVEL_WARN, 'Assertion failed! (%s) Filename: %s; Linenumber: %d; Error Address: %p', [Message, Filename, LineNumber, ErrorAddr]);
end;



{* if DLL has at least one exported procedure, win loader
 * won't unload unless FreeLibrary() was called
 *}
exports
  B6EC7AD52BE349E98013DE8B6D544ADF,
  DllRegisterServer,
  DllUnregisterServer;

begin
    {$IFDEF DEBUG}
//     StartTracking();
    {$ENDIF}
     IsMultiThread := True;
     AssertErrorProc := @AssertHdr;
     MainThreadId := GetCurrentThreadId; // I hope this is unneccessary.
     InitModule();
     DllProc := @DllHandler;

end.



