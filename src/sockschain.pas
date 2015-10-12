{*
 * File: ...................... sockschain.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... SOCKS chains support.

 $Id: sockschain.pas,v 1.9 2005/10/31 14:26:23 bert Exp $

 $Log: sockschain.pas,v $
 Revision 1.9  2005/10/31 14:26:23  bert
 *** empty log message ***

 Revision 1.8  2005/08/11 05:20:36  bert
 *** empty log message ***

 Revision 1.7  2005/07/19 03:52:26  bert
 *** empty log message ***
}
unit sockschain;

interface
uses Windows, Sysutils, Classes, reg_config, inifiles, janXMLParser2,
     pinger, winsock2, base64, AbstractProxy, Socks4Proxy, Socks5Proxy, HTTPProxy;

type
    TProxyTask = (psNone, ptCheck, ptPing);

    TPrxInfo = packed record
       RemoteIp: string;
       RemoteHost: string;
       RemoteCntName: string;
       RemoteCntTld: string;
       RemoteCntSuffix: string;
    end;

    TSocksChainItem = class(TThread)
    private
      FAuth: Boolean;
      FinUse: Boolean;
      FHTTP_Auth: Boolean;
      FPort: integer;
      FVersion: integer;
      FHTTP_Pass: string;
      Fident: string;
      FServer: string;
      FHTTP_User: string;
      FPassword: string;
      FLogin: string;
      FStatus: string;
      FSock: TSocket;
      FOnCheckDone: TNotifyEvent;
      FTask: TProxyTask;
      FData: TObject;
      FOnPingDone: TNotifyEvent;
      FPingMSec: integer;
      FProxyInfo: TPrxInfo;
      FLastErr: string;

      function GetProto: string;
      function GetAnon: string;
      function ResolveIP: DWORD; overload;
      function ResolveIP(HostName: string): DWORD; overload;

      function WaitForConnect: integer;
      function DoPing(): integer;
      function DoConnect(Name: TSockAddr): integer;
      function GetproxyIp: string;
    function GetAuth: Boolean;
    public
      constructor CreateIt(); virtual;
      destructor Destroy; override;

      procedure Assign(Source: TObject);
      function TryToRetrieve(host, SendBuf: string; var Response, LastErr: string): integer;

      function Equals(AItem: TSocksChainItem): Boolean;
      procedure Execute(); override;
      function Check: string;
      procedure Ping();

      function Connect: integer;

      property Protocol: string read GetProto;
      property Anon: string read GetAnon;
      property Status: string read FStatus;

      property Server: string read FServer write FServer;
      property Port: integer read FPort write FPort;
      property Version: integer read FVersion write FVersion;
      property Auth: Boolean read GetAuth write FAuth;

      property Login: string read FLogin write FLogin;
      property Password: string read FPassword write FPassword;
      property ident: string read Fident write Fident;
      property HTTP_User: string read FHTTP_User write FHTTP_User;
      property HTTP_Pass: string read FHTTP_Pass write FHTTP_Pass;
      property HTTP_Auth: Boolean read FHTTP_Auth write FHTTP_Auth;
      property inUse: Boolean read FinUse write FinUse;

      property PingMSec: integer read FPingMSec write FPingMSec;

      property Data: TObject read FData write FData;
      property Task: TProxyTask read FTask write FTask;
      property OnCheckDone: TNotifyEvent read FOnCheckDone write FOnCheckDone;
      property OnPingDone: TNotifyEvent read FOnPingDone write FOnPingDone;
      property ProxyInfo: TPrxInfo read FProxyInfo;
      property LastError: string read FLastErr;
      property ProxyIp: string read GetproxyIp;
    end;

    TSocksChain = class
    private
      FChainList: TList;
      FChainIniFile: string;
      function GetItem(index: integer): TSocksChainItem;
      procedure Clear;
      function GetCount: integer;
      procedure SetItem(index: integer; const Value: TSocksChainItem);
    public
      constructor Create(ChainIniFile : string = ''); virtual;
      destructor Destroy; override;

      function GetFirstIndex(): integer;
      function GetNextIndex(FromIndex: integer): integer;
      function GetLastIndex(): integer;

      function AddSocks(serv: string; port: integer; version: integer; login, pass, ident: string; Auth: Boolean; http_user, http_pass: string; http_auth: boolean): TSocksChainItem;
      procedure DelSocks(index: integer); overload;
      procedure DelSocks(item: TSocksChainItem); overload;

      procedure LoadFromIni;
      procedure SaveToIni;
      function GetLastSOCKS5(): TSocksChainItem;

      procedure Exchange(index1, index2: integer);

      property Items[index: integer]: TSocksChainItem read GetItem write SetItem; default;
      property Count: integer read GetCount;

      function GetStringChain(): string;

    end;

    procedure Init;
    procedure Fini;

var
   SocksChains: TSocksChain;

implementation
uses cfg, loger, misc;

{ TSocksChain }


function TSocksChain.AddSocks(serv: string; port: integer; version: integer; login, pass, ident: string; Auth: Boolean; http_user, http_pass: string; http_auth: boolean): TSocksChainItem;
var
   Item: TSocksChainItem;
begin
     Item := TSocksChainItem.CreateIt();
     Item.Server := serv;
     Item.Port := port;
     Item.Version := version;
     Item.Login := login;
     Item.Password := pass;
     Item.Auth := auth;
     Item.ident := ident;
     Item.HTTP_User := http_user;
     Item.HTTP_Pass := http_pass;
     Item.HTTP_Auth := http_auth;

     FChainList.Add(Item);
     result := Item;
end;

constructor TSocksChain.Create(ChainIniFile : string { = '' });
begin
     FChainList := TList.Create;
     FChainIniFile := ChainIniFile;
     LoadFromIni;
end;

procedure TSocksChain.Clear;
var
   i: integer;
   Item: TSocksChainItem;
begin
     for i := FChainList.Count - 1 downto 0 do
     begin
          Item := TSocksChainItem(FChainList[i]);
          Item.Terminate();
          Item.Free;
     end;
     FChainList.CLear;
end;

function TSocksChain.GetCount: integer;
begin
     result := FChainList.Count;
end;


procedure TSocksChain.DelSocks(index: integer);
begin
     TSocksChainItem(FChainList[index]).Terminate();
     TSocksChainItem(FChainList[index]).Free;
     FChainList.Delete(index);
end;


destructor TSocksChain.Destroy;
begin
     SaveToIni;
     Clear();
     FChainList.Free;
     FChainList := nil;
     inherited Destroy;
end;


function TSocksChain.GetItem(index: integer): TSocksChainItem;
begin
     result := nil;
     if (index >= 0) and (index < FChainList.Count) then
        result := TSocksChainItem(FChainList[index]);
end;


procedure TSocksChain.LoadFromIni;
var
   ini: TRegConfig;
   Sections, Values: TStringList;
   i: integer;
   Item: TSocksChainItem;
begin
{     if isConfigExists('freechain.ini') and (not isConfigExists('widecap')) then
     begin
          LoadFromOldIni();
          exit;
     end;
}
     Clear;
     Sections := TStringList.Create;
     Values   := TStringList.Create;

     if FChainIniFile = '' then
          {$IFDEF WIDECAP}
            Ini := TRegConfig.Create('widecap')
          {$ELSE}
            Ini := TRegConfig.Create('')
          {$ENDIF}
     else
        Ini := TRegConfig.Create(FChainIniFile);

     Ini.ReadSections(PART_SOCKSCHAIN, Sections);
     for i:=0 to Sections.Count - 1 do
     begin
          Values.Clear;
          Ini.ReadSectionValues(PART_SOCKSCHAIN, Sections[i], Values);
          Item := TSocksChainItem.CreateIt();
          Item.Server := Sections[i];

          if Values.Values['Server'] <> '' then
            Item.Server := Values.Values['Server'];


          Item.Port := StrToIntDef(Values.Values['Port'], 1080);
          Item.Version := StrToIntDef(Values.Values['Version'], PROXY_VER_SOCKS5);
          Item.Login := Values.Values['Login'];
          Item.ident := Values.Values['Socks4Ident'];
          Item.Password := Values.Values['Password'];

          Item.HTTP_User := Values.Values['HttpUser'];
          Item.HTTP_Pass := Values.Values['HttpPass'];
          Item.HTTP_Auth := Boolean(StrToIntDef(Values.Values['HttpAuth'], 0));
          Item.inUse := Boolean(StrToIntDef(Values.Values['InUse'], 1));

          Item.Auth := Boolean(StrToIntDef(Values.Values['Auth'], 0));
          FChainList.Add(Item);
     end;
     Values.Free;
     Sections.Free;
     ini.Free;
end;

procedure TSocksChain.SaveToIni;
var
   ini: TRegConfig;
   Sections: TStringList;
   i  : integer;
   Item: TSocksChainItem;
   ident: string;
begin
     Sections := TStringList.Create;

     if FChainIniFile = '' then
          {$IFDEF WIDECAP}
            Ini := TRegConfig.Create('widecap')
          {$ELSE}
            Ini := TRegConfig.Create('')
          {$ENDIF}
     else
        Ini := TRegConfig.Create(FChainIniFile);

     Ini.ReadSections(PART_SOCKSCHAIN, Sections);
     for i:=0 to Sections.Count - 1 do
       ini.EraseSection(PART_SOCKSCHAIN, Sections[i]);

     for i:=0 to FChainList.Count - 1 do
     begin
          Item := TSocksChainItem(FChainList[i]);
          Ident := IntToStr(i);

          ini.WriteString(PART_SOCKSCHAIN, Ident, 'Server', Item.Server);
          ini.WriteInteger(PART_SOCKSCHAIN, Ident, 'Port', Item.Port);
          ini.WriteInteger(PART_SOCKSCHAIN, Ident, 'Version', Item.Version);
          ini.WriteString(PART_SOCKSCHAIN, Ident, 'Login', Item.Login);
          ini.WriteString(PART_SOCKSCHAIN, Ident, 'Socks4Ident', Item.ident);
          ini.WriteString(PART_SOCKSCHAIN, Ident, 'Password', Item.Password);
          ini.WriteBool(PART_SOCKSCHAIN, Ident, 'Auth', Item.Auth);
          ini.WriteString(PART_SOCKSCHAIN, Ident, 'HttpUser', Item.HTTP_User);
          ini.WriteString(PART_SOCKSCHAIN, Ident, 'HttpPass', Item.HTTP_Pass);
          ini.WriteBool(PART_SOCKSCHAIN, Ident, 'HttpAuth', Item.HTTP_Auth);
          ini.WriteBool(PART_SOCKSCHAIN, Ident, 'InUse', Item.inUse);
     end;

     ini.Free;
     Sections.Free;
end;

procedure TSocksChain.Exchange(index1, index2: integer);
var
  Item: Pointer;
begin
     Item := FChainList[Index1];
     FChainList[Index1] := FChainList[Index2];
     FChainList[Index2] := Item;
end;


function TSocksChain.GetFirstIndex(): integer;
var
   i: integer;
begin
     result := -1;
     if Count = 0 then exit;

     i := 0;
     while (i < Count) and (not SocksChains[i].inUse) do
       inc(i);

     if (i <> Count) then
        result := i;
end;


function TSocksChain.GetNextIndex(FromIndex: integer): integer;
begin
     repeat
          inc(FromIndex);
     until (FromIndex = Count) or (SocksChains[FromIndex].inUse);
     result := FromIndex;
end;

function TSocksChain.GetLastIndex: integer;
begin
     result := Count - 1;
     if result = 0 then
     begin
          if not SocksChains[result].inUse then
            result := -1;
     end
     else
     begin
          while (result >= 0) and (not SocksChains[result].inUse) do
            dec(result);
     end;
end;


function TSocksChain.GetLastSOCKS5: TSocksChainItem;
var
   i: integer;
begin
     result := nil;
     i := Count - 1;

     if (i = 0) then
     begin
          if (SocksChains[i].inUse) and (SocksChains[i].Version = 5) then
            result := SocksChains[i];
     end
     else
     begin
          while (i >= 0) and ((not SocksChains[i].inUse) or (SocksChains[i].Version <> 5)) do
            dec(i);
          if i = -1 then
          begin
               Log(LOG_LEVEL_WARN, 'GetLastSOCKS5 = nil', []);
               exit;
          end;
          result := SocksChains[i];
     end;
end;

function TSocksChain.GetStringChain: string;
var
   i: integer;
begin
     result := '';
     for i := 0 to SocksChains.Count - 1 do
     begin
          result := result + Format('(Server: %s; Port: %d)', [SocksChains[i].Server, SocksChains[i].Port])
     end;

end;


procedure TSocksChain.SetItem(index: integer;
  const Value: TSocksChainItem);
begin
     FChainList[index] := Value;
end;

procedure TSocksChain.DelSocks(item: TSocksChainItem);
var
   i: integer;
begin
     for i:=FChainList.COunt - 1 downto 0 do
     begin
          if FChainList[i] = item then
          begin
               TSocksChainItem(FChainList[i]).Free;
               FChainList.Delete(i);
               exit;
          end;
     end;
end;

{ TSocksChainItem }

constructor TSocksChainItem.CreateIt;
begin
     inherited Create(True);
     FTask := psNone;
     FreeOnTerminate := False;
end;


function TSocksChainItem.GetProto: string;
begin
     case FVersion of
       1: result := 'http';
       4: result := 'socks4';
       5: result := 'socks5';
     else
        result := 'Unknown';
     end;
end;


function TSocksChainItem.GetAnon: string;
begin
     result := 'Y';
     if Auth or FHTTP_Auth then
        result := 'N'
end;



function TSocksChainItem.DoPing: integer;
begin
     result := pinger.Ping(FServer);
end;

function TSocksChainItem.ResolveIP(HostName: string): DWORD;
var
   host: string;
begin
     if FServer = HostName then
       host := FServer
     else
       host := HostName;
     result := winsock2.ResolveIP(host);
end;


function TSocksChainItem.ResolveIP: DWORD;
begin
     result := ResolveIP(FServer);

end;

function TSocksChainItem.Check: string;
begin
     if not Suspended then
     begin
          closesocket(FSock);
          Suspend;
     end;

     FTask := ptCheck;
     Resume;
end;

procedure TSocksChainItem.Ping;
begin
     if not Suspended then
     begin
          closesocket(FSock);
          Suspend;
     end;

     FTask := ptPing;
     Resume;
end;


function TSocksChainItem.DoConnect(Name: TSockAddr): integer;
begin
     winsock2.connect(FSock, @Name, SizeOf(name));
     result := WaitForConnect();
end;

function TSocksChainItem.WaitForConnect: integer;
var
   res     : integer;
   writefd : TFDSet;
   errorfd : TFDSet;
   timeval : TTimeVal;
begin
     {* Wait until socket will be connected
      *}
     res := 1;
     timeval.tv_sec := 1;
     timeval.tv_usec := 0;

     ZeroMemory(@writefd, SizeOf(writefd));
     ZeroMemory(@errorfd, SizeOf(errorfd));

     while (not Terminated) do
     begin
          FD_CLR(FSock, writefd);
          FD_SET(FSock, writefd);

          FD_CLR(FSock, errorfd);
          FD_SET(FSock, errorfd);

          res := select(0, nil, @writefd, @errorfd, @timeval);

          if FD_ISSET(FSock, writefd) then
          begin
               result := 0;
               exit;
          end;

          if FD_ISSET(FSock, errorfd) or (res < 0) then
          begin
               FStatus := 'Connection refused';
               break;
          end;
     end;
     result := res;
end;


procedure TSocksChainItem.Execute();
var
   res: integer;
   AvgPing: integer;
   LastErr: string;
   Response, SendBuf, ParamsStr: string;
   sLogin, sPass: string;

   XMLDOM: TjanXMLParser2;
   Node: TJanXMLNode2;
   header, body: string;
begin
     while not Terminated do
     begin
          if FTask = ptCheck then
          begin
               AvgPing := Self.DoPing();
               AvgPing := AvgPing + Self.DoPing();
               AvgPing := AvgPing + Self.DoPing();
               AvgPing := AvgPing + Self.DoPing();
               AvgPing := AvgPing div 4;
               FPingMSec := AvgPing;
               if Assigned(FOnPingDone) then
                 FOnPingDone(Self);


               if (ResolveIP() = 0) then
               begin
                    FStatus := 'Host not found';
               end
               else
               begin
                    res := Self.Connect();
                    if res = 0 then
                    begin
                         if not Auth then
                         begin
                              sLogin := '';
                              sPass := '';
                         end
                         else
                         begin
                              case FVersion of
                                1: begin
                                        sLogin := FHTTP_User;
                                        sPass := FHTTP_Pass;
                                   end;
                                4: begin
                                        sLogin := Fident;
                                        sPass := '';
                                   end;
                                5: begin
                                        sLogin := FLogin;
                                        sPass := FPassword;
                                   end;
                              end;
                         end;

                         SendBuf := 'POST /informer.php?a=ip HTTP/1.0' + #13#10
                                  + 'Host: freecap.ru' + #13#10
                                  + 'User-agent: FreeCap builtin checker' + #13#10
                                  + 'Content-length: %d' + #13#10
                                  + 'Content-Type: %s' + #13#10
                                  + #13#10
                                  + '%s';

                         ParamsStr := '';

                         if cfg.socks_share_using then
                         begin
                              if (cfg.socks_share_sharing = 0) and not Auth then
                                ParamsStr := Format('ProxyHost=%s&ProxyPort=%d&ProxyVersion=%d&UserGUID=%s', [encodeUrl(Server), Port, FVersion, encodeUrl(cfg.socks_share_guid)])
                              else if cfg.socks_share_sharing > 0 then
                                ParamsStr := Format('ProxyHost=%s&ProxyPort=%d&ProxyVersion=%d&ProxyLogin=%s&ProxyPassword=%s&UserGUID=%s', [encodeUrl(Server), Port, FVersion, encodeUrl(sLogin), encodeUrl(sPass), encodeUrl(cfg.socks_share_guid)]);
                         end;

                         SendBuf := Format(SendBuf, [Length(ParamsStr), 'application/x-www-form-urlencoded', ParamsStr]);

                         res := Self.TryToRetrieve('freecap.ru', SendBuf, Response, LastErr);
                         if (res = 0) then
                         begin
                              FStatus := 'OK';
                              SplitHtml(Response, header, body);
                              if Body = '' then
                              begin
                                   exit;
                              end;


                              XMLDOM := TjanXMLParser2.Create();
                              XMLDOM.name := 'freecap';
                              XMLDOM.xml := Body;

                              with FProxyInfo do
                              begin
                                   if (XMLDOM.getChildByName('ip') <> nil) then
                                     RemoteIp := XMLDOM.getChildByName('ip').text;

                                   if XMLDOM.getChildByName('host') <> nil then
                                     RemoteHost := XMLDOM.getChildByName('host').text;

                                   if XMLDOM.getChildByName('country') <> nil then
                                   begin
                                        Node := XMLDOM.getChildByName('country');
                                        if Node.getChildByName('name') <> nil then
                                        RemoteCntName := Node.getChildByName('name').Text;
                                        if XMLDOM.getChildByName('country').getChildByName('tld') <> nil then
                                        RemoteCntTld := Node.getChildByName('tld').Text;
                                        if XMLDOM.getChildByName('country').getChildByName('suffix') <> nil then
                                        RemoteCntSuffix := Node.getChildByName('suffix').Text;
                                   end;
                              end;

                              XMLDOM.Free;
                         end
                         else
                           FStatus := LastErr;
                    end;

                    closesocket(FSock);
               end;
               if Assigned(FOnCheckDone) then
                 FOnCheckDone(Self);
               Suspend;
          end;

          if FTask = ptPing then
          begin
               AvgPing := Self.DoPing();
               AvgPing := AvgPing + Self.DoPing();
               AvgPing := AvgPing + Self.DoPing();
               AvgPing := AvgPing + Self.DoPing();
               AvgPing := AvgPing div 4;
               FPingMSec := AvgPing;
               if Assigned(FOnPingDone) then
                 FOnPingDone(Self);
               Suspend;
          end;
     end;
end;



procedure TSocksChainItem.Assign(Source: TObject);
var
   Src: TSocksChainItem;
begin
     if Source is TSocksChainItem then
     begin
          Src := (Source as TSocksChainItem);
          FServer := Src.Server;
          FPort :=  Src.Port;
          FVersion := Src.Version;
          FAuth := Src.Auth;
          FLogin := Src.Login;
          FPassword := Src.Password;
          Fident := Src.ident;
          FHTTP_User := Src.HTTP_User;
          FHTTP_Pass := Src.HTTP_Pass;
          FHTTP_Auth := Src.HTTP_Auth;
          FinUse := Src.inUse;
          FData := Src.Data;
          FOnCheckDone := Src.OnCheckDone;
          FOnPingDone := Src.OnPingDone;
     end;
end;


procedure Init;
var
   Buf: array[0..MAX_PATH] of Char;
begin
     ZeroMemory(@Buf, SizeOf(Buf));
     if GetEnvironmentVariable('FreeCAPConfigFile', @Buf, SizeOf(Buf)) <> 0 then
       SocksChains := TSocksChain.Create(Buf)
     else
       SocksChains := TSocksChain.Create;
end;


procedure Fini;
begin
     SocksChains.Clear();
     SocksChains.Free;
end;


destructor TSocksChainItem.Destroy;
begin
     inherited Destroy;
end;

function TSocksChainItem.TryToRetrieve(host, SendBuf: string; var Response, LastErr: string): integer;
var
   Proxy: TAbstractProxy;
   sLogin, sPass: string;
   Name: TSockAddrIn;
   RecvBuffer: string;
   RecvBuf: array[0..4095] of Char;
   BufSize: integer;
begin
     if not Auth then
     begin
          sLogin := '';
          sPass := '';
     end
     else
     begin
          case FVersion of
            1: begin
                    sLogin := FHTTP_User;
                    sPass := FHTTP_Pass;
               end;
            4: begin
                    sLogin := Fident;
                    sPass := '';
               end;
            5: begin
                    sLogin := FLogin;
                    sPass := FPassword;
               end;
          end;
     end;

     case FVersion of
        0: Proxy := TAbstractProxy.Create('', '', '', FSock, 0, METHOD_CONNECT);
        1: Proxy := THTTPProxy.Create(Server, sLogin, sPass, FSock, Port, METHOD_CONNECT);
        4: Proxy := TSOCKS4Proxy.Create(Server, sLogin, sPass, FSock, Port, METHOD_CONNECT);
        5: Proxy := TSOCKS5Proxy.Create(Server, sLogin, sPass, FSock, Port, METHOD_CONNECT);
     else
        raise Exception.Create('Unknown proxy type!');
     end;

     Name.sin_family := AF_INET;
     Name.sin_addr.S_addr := ResolveIP(Host);
     Name.sin_port := ntohs(80);

     result := Proxy.connect(Name);
     LastErr := Proxy.LastError;
     FLastErr := LastErr;


     if result = 0 then
     begin
          Proxy.SendData(@SendBuf[1], Length(SendBuf));

          repeat
                ZeroMemory(@RecvBuf, SizeOf(RecvBuf));
                BufSize := Proxy.RecvData(@RecvBuf[0], SizeOf(RecvBuf));
                RecvBuffer := RecvBuffer + PChar(@RecvBuf[0]);
          until (BufSize < SizeOf(RecvBuf));
          Response := RecvBuffer;
     end;

     Proxy.Free;
end;

function TSocksChainItem.GetproxyIp: string;
var
   ip: dword;
begin
     ip := ResolveIP();
     result := Format('%d.%d.%d.%d',[ip and $FF,
                                     ip shr 8 and $FF,
                                     ip shr 16 and $FF,
                                     ip shr 24]);

end;



function TSocksChainItem.Connect: integer;
var
   Name: TSockAddr;
   arg: DWORD;
begin
     Name.sin_family := AF_INET;
     Name.sin_addr.S_addr := ResolveIP();
     Name.sin_port := ntohs(port);

     FSock := socket(AF_INET, SOCK_STREAM, 0);
     arg := 1;
     ioctlsocket(FSock, FIONBIO, arg);
     result := Self.DoConnect(Name);
end;

function TSocksChainItem.Equals(AItem: TSocksChainItem): Boolean;
begin
     result :=  (FServer = AItem.Server) and
                (FPort = AItem.Port) and
                (FVersion = AItem.Version) and
                (FAuth = AItem.Auth) and
                (FLogin = AItem.Login) and
                (FPassword = AItem.Password) and
                (Fident = AItem.ident) and
                (FHTTP_User = AItem.HTTP_User) and
                (FHTTP_Pass = AItem.HTTP_Pass) and
                (FHTTP_Auth = AItem.HTTP_Auth);
end;

function TSocksChainItem.GetAuth: Boolean;
begin
     if FVersion = 4 then
        Result := (Fident <> '')
     else
        Result := FAuth;
end;

end.
