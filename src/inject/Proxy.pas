{*
 * File: ...................... Proxy.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Proxy managing

 $Id: Proxy.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

 $Log: Proxy.pas,v $
 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit Proxy;

interface
uses Windows, Messages, Classes, SysUtils, winsock2, syncobjs, loger,
     misc, cfg, sockschain, base64, direct_addr, dns,
     AbstractProxy, Socks4Proxy, Socks5Proxy, HTTPProxy;

type
    TSocksState = (ssNone, ssAuth, ssConn, ssData, ssTransf, ssClosed);
    TSocksVersion = (socks4, socks5);
    TProxyState = (psNone, psConnecting, psEstablished, psError, psDirect);

    {*
     * TProxyItem now descendant of TThread. Using threads here more
     * simple in syncronization (and terminating) than using critical sections
     * and some dirty methods in the whole class.
     *}
    TProxyItem = class(TThread)
    private
      FProxy      : TAbstractProxy;
      FHSock      : TSocket;
      FHSock2     : TSocket;
      FOrigName   : TSockAddr;
      Faf         : integer;
      Fstruct     : integer;
      Fproto      : integer;
      FChainPtr   : integer;
      FMethod     : integer;
      FState      : TProxyState;
      FEvents     : DWORD;
      FMsg        : UINT;
      FWindowHandle: HWND;
      FBlocking   : Boolean;
      FNextProxy  : TProxyItem;
      FChildProxyItem: TProxyItem;

      function GetSockHandle: TSocket;
      procedure FireEvent();
      procedure CleanUp();

    protected
      procedure Execute(); override;
    public
      constructor CreateIt(hSock: TSocket; af, struct, proto, AChainPtr: integer); virtual;
      destructor Destroy; override;

      function WaitForConnect: integer;
      procedure SetFireEvent(Events: DWORD; WindowHandle: HWND; Msg: UINT);
      procedure ClearFireEvent();

      property Method: integer read FMethod write FMethod;
      property OrigName: TSockAddrIn read FOrigName write FOrigName;
      property SockHandle: TSocket read GetSockHandle;
      property Proxy: TAbstractProxy read FProxy;
      property State: TProxyState read FState write FState;
      property Blocking: Boolean read FBlocking write FBlocking;
      property NextProxy: TProxyItem read FNextProxy write FNextProxy;
    end;


    TProxyArray = class
    private
      FCritSection: TCriticalSection;
      FItems: TList;
      FLastItem: integer;
      FLastSockItem: TSocket;

      function GetIndex(s: TSocket): integer;
      function GetSockItem(s: TSocket): TProxyItem;
      procedure Clear;
    function GetCount: Integer;
    public
      constructor Create; virtual;
      destructor Destroy; override;
      procedure Add(hSock: TSocket; af, struct, proto: integer);
      procedure Del(hSock: TSocket);
      function  Exists(hSock: TSocket): Boolean;
      function GetItem(s: TSocket): TProxyItem;

      property Count : Integer read GetCount;
      property Items[s : TSocket] : TProxyItem read GetSockItem; default;
    end;

    procedure Init;
    procedure Fini;


var
   ProxyArray : TProxyArray;

implementation
uses ws_hook;

{ TProxyItem }

{* Main thread procedure. Last known as 'connect' method.
 *}
procedure TProxyItem.Execute();
var
   res      : Boolean;
   ProxyItem: TProxyItem;
   serv     : string;
   login, passwd, ident: string;
   http_login, http_passwd: string;
   port, ver: integer;
   bFirst   : Boolean;
   bAuth    : Boolean;
   DestAddr : TSockAddr;
   conn_err : integer;
begin
     ver := SocksChains[FChainPtr].Version;
     serv  := SocksChains[FChainPtr].Server;
     port  := SocksChains[FChainPtr].Port;
     login := SocksChains[FChainPtr].Login;
     passwd:= SocksChains[FChainPtr].Password;
     ident := SocksChains[FChainPtr].ident;
     bAuth := SocksChains[FChainPtr].Auth;
     http_login := SocksChains[FChainPtr].HTTP_User;
     http_passwd := SocksChains[FChainPtr].HTTP_Pass;
     bFirst := False;

     if not bAuth then
     begin
          login := '';
          ident := '';
     end;

     if not SocksChains[FChainPtr].HTTP_Auth then
       http_login := '';

     if (FChainPtr = SocksChains.GetFirstIndex()) then
     begin
          bFirst := True;
          Log(LOG_LEVEL_SOCKS, 'Using first proxy (%s:%d) in the chain',[serv, port]);
          conn_err := WaitForConnect();
          if conn_err = 1 then
          begin
               ReturnValue := 1;
               FState := psError;
               Log(LOG_LEVEL_WARN, 'WaitForConnect() error? ', []);
               exit;
          end;
     end
     else // Others child threads doesn't require to wait until connected. SOCKS server take care about it
         Log(LOG_LEVEL_SOCKS, 'Using proxy #%d (%s:%d) in the chain',[succ(FChainPtr), serv, port]);

     if (FChainPtr = SocksChains.GetLastIndex()) then
     begin
          FChainPtr := SocksChains.Count;
          DestAddr := FOrigName;
     end
     else
     begin
          FChainPtr := SocksChains.GetNextIndex(FChainPtr);
          DestAddr.sin_family := AF_INET;
          DestAddr.sin_port := htons(SocksChains[FChainPtr].Port);
          DestAddr.sin_addr.S_addr := Resolve(SocksChains[FChainPtr].Server);
     end;

     {* Choose the proxy method you wish to use
      *}
     case Ver of
       1: FProxy := THTTPProxy.Create(serv, http_login, http_passwd, FHSock, port, METHOD_CONNECT, bFirst);
       4: FProxy := TSocks4Proxy.Create(serv, ident, '', FHSock, port, METHOD_CONNECT, bFirst);
       5: FProxy := TSocks5Proxy.Create(serv, login, passwd, FHSock, port,  FMethod, bFirst);
     end;
     res := (FProxy.connect(DestAddr) = 0);

     if not res then
     begin
          Log(LOG_LEVEL_WARN, 'Connection to %s:%d through %s:%d server failed', [GetAddrString(DestAddr.sin_addr.S_addr), ntohs(DestAddr.sin_port), serv, port]);
          ReturnValue := WSAGetLastError();
          if ReturnValue = 0 then
             ReturnValue := 1;
          FState := psError;
     end
     else
     begin
          ReturnValue := 0;
     end;

     // If something wrong, just leave
     if (ReturnValue <> 0) then exit;

     if FChainPtr < SocksChains.Count  then
     begin
          ProxyItem := TProxyItem.CreateIt(FhSock, Faf, Fstruct, Fproto, FChainPtr);
          ProxyItem.OrigName := FOrigName;    // Keep original sockaddr_in structure for connect to.
          ProxyItem.Method := FMethod;
          ProxyItem.Resume;                   // Run!
          ReturnValue := ProxyItem.WaitFor(); // Wait until child tread will be done
          FChildProxyItem := ProxyItem;
{          ProxyItem.Terminate;
          ProxyItem.Free;}
     end;


     if (ReturnValue = 0) and ((FChainPtr = 1) or (FChainPtr >= SocksChains.GetLastIndex())) then
     begin
          FState := psEstablished;
          FireEvent();
     end;
end;


constructor TProxyItem.CreateIt(hSock: TSocket; af, struct, proto, AChainPtr: integer);
var
   serv, login, passwd: string;
   port: Word;
   Item: TSocksChainItem;
begin
     inherited Create(true); // Create suspended thread

     FHSock := hSock;
     FState := psNone;
     FBlocking := True;
     FChildProxyItem := nil;

     if struct = SOCK_DGRAM then
     begin
          FMethod := METHOD_UDP;
          Item := SocksChains.GetLastSOCKS5();

          Assert(Item <> nil);

          serv  := Item.Server;
          port  := Item.Port;
          login := Item.Login;
          passwd:= Item.Password;
          if not Item.Auth then
          begin
               login  := '';
               passwd := '';
          end;
          FProxy := TSocks5Proxy.Create(serv, login, passwd, FHSock, port, FMethod{, True});
     end;

     Faf := af;
     Fstruct := struct;

     FProto := proto;
     FChainPtr := AChainPtr;

     if (FChainPtr = -1) then
       raise Exception.Create('No proxy servers in use. Please select at least one. Program will be terminated.');

     if SocksChains.Count = 0 then
        raise Exception.Create('No proxy servers specified. Please specify at least one. Program will be terminated.');

     Log(LOG_LEVEL_SOCKS, '[%d] Create ProxyItem for %d', [ThreadID, FHSock]);
end;

destructor TProxyItem.Destroy;
begin
     Cleanup();
     Log(LOG_LEVEL_SOCKS, '[%d] Destroy ProxyItem %d', [ThreadID, FHSock]);
     inherited Destroy;
end;


function TProxyItem.WaitForConnect: integer;
var
   res     : integer;
   readfd  : TFDSet;
   writefd : TFDSet;
   errorfd : TFDSet;
   timeval : TTimeVal;
   hSocket : TSocket;
begin
     if FStruct = SOCK_DGRAM then
       hSocket := FHSock2
     else
       hSocket := FHSock;

     {* Wait until socket will be connected
      *}
     res := 1;
     timeval.tv_sec := 1;
     timeval.tv_usec := 0;

     ZeroMemory(@readfd, SizeOf(readfd));
     ZeroMemory(@writefd, SizeOf(writefd));
     ZeroMemory(@errorfd, SizeOf(errorfd));
     FState := psConnecting;

     while (not Terminated) do
     begin
          FD_CLR(hSocket, readfd);
          FD_SET(hSocket, readfd);

          FD_CLR(hSocket, writefd);
          FD_SET(hSocket, writefd);

          FD_CLR(hSocket, errorfd);
          FD_SET(hSocket, errorfd);

          res := select(0, @readfd, @writefd, @errorfd, @timeval);

          if FD_ISSET(hSocket, writefd) then
          begin
               if (WSAGetLastError() = 0) then
               begin
                    result := 0;
                    exit;
               end;
          end;

          if FD_ISSET(hSocket, readfd) then
          begin
               if (WSAGetLastError() <> WSAEWOULDBLOCK) then
               begin
                    break;
               end;
          end;

          if FD_ISSET(hSocket, errorfd) then
          begin
               WSASetLastError(WSAECONNREFUSED);
               Log(LOG_LEVEL_SOCKS, 'connect error: %s (%d)', [WSocketErrorDesc(WSAGetLastError()), WSAGetLastError()]);
               break;
          end;

          if (res < 0) then
          begin
               WSASetLastError(WSAECONNREFUSED);
               Log(LOG_LEVEL_SOCKS, 'connect error: %s (%d)', [WSocketErrorDesc(WSAGetLastError()), WSAGetLastError()]);
               break;
          end;
     end;
     result := res;
end;


{****************************************************************************
 *                              TProxyArray                                 *
 ****************************************************************************}

procedure TProxyArray.Add(hSock: TSocket; af, struct, proto: integer);
var
   Item: TProxyItem;
begin
     FCritSection.Enter;

     try
        Item := TProxyItem.CreateIt(hSock, af, struct, proto, SocksChains.GetFirstIndex());
        FItems.Add(Item);
     except
       on E: Exception do
         begin
              Log(LOG_LEVEL_WARN, 'TProxyArray.Add exception! %s ', [E.Message]);
              halt;
         end;
     end;
     FCritSection.Leave;
end;


constructor TProxyArray.Create;
begin
     FCritSection := TCriticalSection.Create;
     FItems := TList.Create;
     FLastItem := -1;
end;

procedure TProxyArray.Clear();
var
   i    : integer;
   Item : TProxyItem;
begin
     FCritSection.Enter;
     try

     for i := FItems.Count - 1 downto 0 do
     begin
          Item := TProxyItem(FItems[i]);
          if (Item <> nil) then
          begin
               Item.Terminate;
               Item.Free;
//               FreeAndNil(Item); // should de-allocate
               FItems.Delete(i);
          end;
     end;
     FLastItem := -1;
     FLastSockItem := 0;
     except
       on E: Exception do
         Log(LOG_LEVEL_DEBUG, 'Exception! TProxyArray.Clear: %s', [E.Message]);
     end;

     FCritSection.Leave;
end;


procedure TProxyArray.Del(hSock: TSocket);
var
   i    : integer;
   Item : TProxyItem;
begin
     FCritSection.Enter;
     {* IMPORTANT!
      * Deletion MUST be syncronized!
      *}
     try
     for i := FItems.Count - 1 downto 0 do
     begin
          Item := TProxyItem(FItems[i]);
          if (Item <> nil) and (Item.SockHandle = hSock) then
          begin
               Item.Terminate; // Stop the thread
               Item.Free;
//               FreeAndNil(Item); // should de-allocate
               FItems.Delete(i);
          end;
     end;
     FLastItem := -1;
     FLastSockItem := 0;
     except
       on E: Exception do
         Log(LOG_LEVEL_DEBUG, 'Exception! TProxyArray.Del: %s', [E.Message]);
     end;
     FCritSection.Leave;
end;


destructor TProxyArray.Destroy;
begin
     FCritSection.Enter;
     Log(LOG_LEVEL_SOCKS, 'Destroying ProxyArray',[]);
     Clear();
     FItems.Free;
     FCritSection.Leave;

     FCritSection.Free;
     FCritSection := nil;
     Log(LOG_LEVEL_SOCKS, 'Done destroying ProxyArray...',[]);
     inherited Destroy;
end;

function TProxyArray.GetIndex(s: TSocket): integer;
var
   i   : integer;
   Item: TProxyItem;
begin
     result := -1;
     if FItems = nil then exit;

     try
        for i := 0 to FItems.Count - 1 do
        begin
             Item := TProxyItem(FItems[i]);
             if Item.SockHandle = s then
             begin
                  result := i;
                  exit;
             end;
        end;
     except
       on E: Exception do
         Log(LOG_LEVEL_DEBUG, 'Exception! TProxyArray.GetIndex: %s', [E.Message]);
     end;
end;

function TProxyArray.GetSockItem(s: TSocket): TProxyItem;
var
   idx : integer;
begin
     result := nil;
     idx := GetIndex(s);
     if idx <> -1 then
       result := TProxyItem(FItems[idx])
     else
       Log(LOG_LEVEL_DEBUG, 'Error! GetSockItem(%d) == NULL', [s]);
end;

function TProxyArray.Exists(hSock: TSocket): Boolean;
begin
     result := GetIndex(hSock) <> -1;
end;


function TProxyArray.GetItem(s: TSocket): TProxyItem;
var
   i: integer;
begin
     result := nil;
//     FCritSection.Enter;

     try
        if s = FLastSockItem then
        begin
             result := TProxyItem(FItems[FLastItem]);
        end
        else
        begin
             i := GetIndex(s);
             if (i <> -1) then
             begin
                  result := TProxyItem(FItems[i]);
                  FLastItem := i;
             end
             else
             begin
                  FLastItem := -1;
                  FLastSockItem := 0;
             end;
        end;
     except
       on E: Exception do
         Log(LOG_LEVEL_DEBUG, 'Exception! TProxyArray.GetItem: %s ', [E.Message]);
     end;
//     FCritSection.Leave;
end;


procedure Init;
begin
     ProxyArray  := TProxyArray.Create;
end;

procedure Fini;
begin
     ProxyArray.Free;
     ProxyArray := nil;
end;


function TProxyItem.GetSockHandle: TSocket;
begin
     result := FHSock;
end;

procedure TProxyItem.FireEvent;
begin
     if FWindowHandle = 0 then
       exit;
     if ReturnValue = 0 then
       PostMessage(FWindowHandle, FMsg, FHSock, FD_CONNECT)
     else
       PostMessage(FWindowHandle, FMsg, FHSock, (WSAECONNREFUSED shl 16) or FD_CONNECT);
end;

procedure TProxyItem.SetFireEvent(Events: DWORD; WindowHandle: HWND; Msg: UINT);
var
   argp: u_long;
begin
     if (FD_CONNECT and Events) = FD_CONNECT then
     begin
          // Almost forgot: WSAAsyncSelect automatically turns
          // non-blocking mode. This fixes "freezing" issue with Opera

          argp := 1;
          ioctlsocket(FHSock, FIONBIO, argp); // Turn on non-blocking mode
          FBlocking := False;

          FEvents := Events;
          FWindowHandle := WindowHandle;
          FMsg := Msg;
          if FState = psEstablished then
            FireEvent();
     end;
end;


procedure TProxyItem.CleanUp;
begin
     if (FProxy <> nil) then
     begin
          FProxy.Free;
          FProxy := nil;
     end;
     if (FChildProxyItem <> nil) then
     begin
          FChildProxyItem.Free;
          FChildProxyItem := nil;
     end;

end;

function TProxyArray.GetCount: Integer;
begin
     result := FItems.Count;
end;

procedure TProxyItem.ClearFireEvent;
begin
     FWindowHandle := 0;
end;

end.
