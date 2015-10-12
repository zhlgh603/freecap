{*
 * File: ...................... plugin_disp.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev
 * Desc: ...................... Plugins Dispatcher. Manages plugins

 $Id: plugin_disp.pas,v 1.3 2005/12/19 06:09:02 bert Exp $

 $Log: plugin_disp.pas,v $
 Revision 1.3  2005/12/19 06:09:02  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***

}

unit plugin_disp;

interface

uses Windows, SysUtils, Classes, plugin, loger, winsock2, misc;

const
     CATEGORY_ADDRESS = 0;
     CATEGORY_APP  = 1;
     CATEGORY_PORT = 2;

type
    PPluginInfoEx = ^TPluginInfoEx;

    TPluginInfoEx = packed record
      HMod: HMODULE;
      PluginInfo: TPluginInfo;
    end;

   TPluginDispatcher = class
   private
     FPluginList: TList;
//     function isValueExists(iCat, index: integer; value: PChar): Boolean; overload;
     function isValueExists(iCat, index: integer; value: DWORD): Boolean; overload;
     procedure DoLoad(FileName: string);
    procedure WalkDirectory(ADir: string);
   public
     constructor Create;
     destructor Destroy; override;

     procedure Load;
     procedure Unload;
     function InvokeConnect(App: string; var DestAddr: string): integer;
     function InvokeSend(App: string; DstAddr : PSockAddrIn; Buffer: Pointer; size: DWORD): DWORD;
     function InvokeRecv(App: string; DstAddr : PSockAddrIn; Buffer: Pointer; size: DWORD): DWORD;
     procedure InvokeConfigWnd(Index: integer);

     property Plugins: TList read FPluginList;
   end;


   procedure Init;
   procedure Fini;

var
   PluginDisp: TPluginDispatcher;



implementation

uses cfg;


procedure Log(fmt: PChar; args: array of const); stdcall;
begin
     loger.log(LOG_LEVEL_PLUGIN, fmt, args);
end;

// TPluginDispatcher

constructor TPluginDispatcher.Create;
begin
     FPluginList := TList.Create;
     Load;
end;

procedure TPluginDispatcher.InvokeConfigWnd(Index: integer);
var
   PlugInfo: PPluginInfoEx;
begin
     PlugInfo := PPluginInfoEx(FPluginList[Index]);
     if @PlugInfo^.PluginInfo.InvokeConfigWnd <> nil then
       PlugInfo^.PluginInfo.InvokeConfigWnd();
end;

{
function TPluginDispatcher.isValueExists(iCat, index: integer; value: PChar): Boolean;
var
   PlugInfo : PPluginInfoEx;
   i: integer;
begin
     result := False;
     PlugInfo := PPluginInfoEx(FPluginList[Index]);
     with PlugInfo^.PluginInfo do
     begin
          if iCat = CATEGORY_ADDRESS then
          begin
               if PlugInfo^.PluginInfo.Addrs[0] = nil then
               begin
                    result := True;
                    exit;
               end;

               i := 0;
               while (i <= 255) and (Addrs[i] <> nil) do
               begin
                    if StrComp(Value, Addrs[i]) = 0 then
                    begin
                         result := True;
                         break;
                    end;
                    inc(i);
               end;
          end
          else if iCat = CATEGORY_APP then
          begin
               if PlugInfo^.PluginInfo.Apps[0] = nil then
               begin
                    result := True;
                    exit;
               end;

               i := 0;
               while (i <= 255) and (Apps[i] <> nil) do
               begin
                    if StrComp(Value, Apps[i]) = 0 then
                    begin
                         result := True;
                         break;
                    end;
                    inc(i);
               end;
          end;
     end;
end;
}
function TPluginDispatcher.isValueExists(iCat, index: integer; value: DWORD): Boolean;
var
   PlugInfo : PPluginInfoEx;
   i: integer;
begin
     result := False;
     PlugInfo := PPluginInfoEx(FPluginList[Index]);
     with PlugInfo^.PluginInfo do
     begin

          if iCat = CATEGORY_PORT then
          begin
               if Ports[0] = 0 then
               begin
                    loger.Log(LOG_LEVEL_DEBUG, 'Ports[0] = 0', []);
                    result := True;
                    exit;
               end;

               i := 0;
               while (i < MAX_ARRAY_VALUES) and (Ports[i] <> 0) do
               begin
                    if Value = ntohs(Ports[i]) then
                    begin
                         result := True;
                         break;
                    end;
                    inc(i);
               end;
          end;
     end;
end;


function TPluginDispatcher.InvokeRecv(App: string; DstAddr : PSockAddrIn;
  Buffer: Pointer; size: DWORD): DWORD;
var
   PlugInfo : PPluginInfoEx;
   i        : integer;
   bShouldCall: Boolean;
   SendRecvInfo: TSendRecvInfo;
begin
     result := Size;
     for i := 0 to FPluginList.Count - 1 do
     begin
          PlugInfo := PPluginInfoEx(FPluginList[i]);
          if @PlugInfo^.PluginInfo.Hooks.OnRecv <> nil then
          begin
               bShouldCall := isValueExists(CATEGORY_PORT, i, DstAddr.sin_port);
               if not bShouldCall then continue;
//               bShouldCall := bShouldCall and isValueExists(CATEGORY_ADDRESS, i, PChar(Addr));
//               if not bShouldCall then continue;
//               bShouldCall := bShouldCall and isValueExists(CATEGORY_APP, i, PChar(App));

               if bShouldCall then
               begin
                    SendRecvInfo.App := PChar(App);
                    SendRecvInfo.DstAddr := DstAddr;
                    result := PlugInfo^.PluginInfo.Hooks.OnRecv(SendRecvInfo, Buffer, result);
               end;
          end;

     end;
end;

function TPluginDispatcher.InvokeSend(App: string; DstAddr : PSockAddrIn;
  Buffer: Pointer; size: DWORD): DWORD;
var
   PlugInfo : PPluginInfoEx;
   i        : integer;
   bShouldCall: Boolean;
   SendRecvInfo: TSendRecvInfo;
begin
     result := Size;
     for i := 0 to FPluginList.Count - 1 do
     begin
          PlugInfo := PPluginInfoEx(FPluginList[i]);
          if @PlugInfo^.PluginInfo.Hooks.OnSend <> nil then
          begin
               bShouldCall := isValueExists(CATEGORY_PORT, i, DstAddr.sin_port);
//               if not bShouldCall then continue;
//               bShouldCall := bShouldCall and isValueExists(CATEGORY_ADDRESS, i, PChar(Addr));
//               if not bShouldCall then continue;
//               bShouldCall := bShouldCall and isValueExists(CATEGORY_APP, i, PChar(App));

               if bShouldCall then
               begin
                    SendRecvInfo.App := PChar(App);
                    result := PlugInfo^.PluginInfo.Hooks.OnSend(SendRecvInfo, Buffer, result);

                    if Integer(result) < 0 then
                       result := 0;
               end;
         end;
     end;
end;

procedure TPluginDispatcher.DoLoad(FileName: string);
type
    TGetPlugInfo = function(StartUpInfo: TFreeCapMain): TPluginInfo; stdcall;
var
   PlugInfo: PPluginInfoEx;
   GetPlugInfo: TGetPlugInfo;
   hLib: HMODULE;
   FreeCapMain: TFreeCapMain;
begin
     loger.Log(LOG_LEVEL_DEBUG, 'TPluginDispatcher.DoLoad', []);

     FreeCapMain.Log := @Log;

     hLib := LoadLibrary(PChar(FileName));
     if (hLib <> 0) then
     begin
          @GetPlugInfo := GetProcAddress(hLib, 'GetPluginInfo');
          if @GetPlugInfo <> nil then
          begin
               GetMem(PlugInfo, SizeOf(TPluginInfoEx));
               PlugInfo^.HMod := hLib;
               PlugInfo^.PluginInfo := GetPlugInfo(FreeCapMain);
               if @PlugInfo^.PluginInfo.Hooks.Init <> nil then
                 PlugInfo^.PluginInfo.Hooks.Init();

               FPluginList.Add(PlugInfo);
          end
          else
              FreeLibrary(hLib);
     end;
end;

procedure TPluginDispatcher.WalkDirectory(ADir: string);
var
   sr: TSearchRec;
begin
     loger.Log(LOG_LEVEL_DEBUG, 'TPluginDispatcher.WalkDirectory', []);

     if ADir = '' then exit;

     if FindFirst(ADir + '*.dll', faAnyFile, sr) = 0 then
     begin
          if ((sr.Attr and faDirectory) <> faDirectory) and
             ((sr.Attr and faVolumeID) <> faVolumeID) then
             DoLoad(ADir + sr.name);
          while FindNext(sr) = 0 do
            if ((sr.Attr and faDirectory) <> faDirectory) and
               ((sr.Attr and faVolumeID) <> faVolumeID) then
                  DoLoad(ADir + sr.name);
               FindClose(sr);
     end
end;


procedure TPluginDispatcher.Load;
begin
     loger.Log(LOG_LEVEL_DEBUG, 'TPluginDispatcher.Load', []);

     WalkDirectory(GetPluginsDir());
end;

procedure TPluginDispatcher.Unload;
var
   i: integer;
   PlugInfo: PPluginInfoEx;
begin
     loger.Log(LOG_LEVEL_DEBUG, 'TPluginDispatcher.Unload', []);

     for i := FPluginList.Count - 1 downto 0 do
     begin
          PlugInfo := PPluginInfoEx(FPluginList[i]);
          if @PlugInfo^.PluginInfo.Hooks.Fini <> nil then
            PlugInfo^.PluginInfo.Hooks.Fini();
          FreeLibrary(PlugInfo^.HMod);
          FreeMem(PlugInfo);
          FPluginList.Delete(i);
     end;
end;

destructor TPluginDispatcher.Destroy;
begin
     Unload;
     FPluginList.Free;
     inherited Destroy;
end;


procedure Init;
begin
     loger.Log(LOG_LEVEL_DEBUG, 'TPluginDispatcher.Init', []);
     PluginDisp := TPluginDispatcher.Create;
end;

procedure Fini;
begin
     PluginDisp.Free;
     loger.Log(LOG_LEVEL_DEBUG, 'TPluginDispatcher.Free', []);
end;



function TPluginDispatcher.InvokeConnect(App: string; var DestAddr: string): integer;
var
   PlugInfo : PPluginInfoEx;
   i        : integer;
   ConnInfo: TConnectInfo;
begin
     loger.Log(LOG_LEVEL_DEBUG, 'TPluginDispatcher.InvokeConnect', []);
     result := 0;

     for i := 0 to FPluginList.Count - 1 do
     begin
          PlugInfo := PPluginInfoEx(FPluginList[i]);
          if @PlugInfo^.PluginInfo.Hooks.OnConnect <> nil then
          begin
               ConnInfo.App := PChar(App);
               ZeroMemory(@ConnInfo.DestAddr, SizeOf(ConnInfo.DestAddr));
               Move(DestAddr[1], ConnInfo.DestAddr[0], Length(DestAddr));

               result := PlugInfo^.PluginInfo.Hooks.OnConnect(ConnInfo);
               DestAddr := String(PChar(@ConnInfo.DestAddr[0]));
         end;
     end;
end;

end.


