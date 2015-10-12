{*
 * File: ...................... Proxy.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Proxy managing

 $Id: Proxy.pas,v 1.15 2005/12/19 06:09:02 bert Exp $

 $Log: Proxy.pas,v $
 Revision 1.15  2005/12/19 06:09:02  bert
 *** empty log message ***

 Revision 1.14  2005/11/22 05:56:27  bert
 *** empty log message ***

 Revision 1.13  2005/10/27 19:05:51  bert
 *** empty log message ***

 Revision 1.12  2005/08/11 05:20:36  bert
 *** empty log message ***

 Revision 1.11  2005/05/16 04:31:52  bert
 *** empty log message ***

 Revision 1.10  2005/04/27 11:43:02  bert
 *** empty log message ***

}
unit Proxy;

interface
uses Windows, Messages, Classes, SysUtils, winsock2, syncobjs, loger,
     misc, cfg, sockschain, base64, direct_addr, dns, stub,
     AbstractProxy, Socks4Proxy, Socks5Proxy, HTTPProxy, proxy_intf;

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
      FHEvent     : THandle;
      FCancelEvent: TEvent;

      function GetSockHandle: TSocket;
      procedure CleanUp();
      procedure DoExecute();
      procedure SetBlocking(const Value: Boolean);
      function MyWaitFor: DWORD;
    protected
      procedure Execute(); override;
    public
      constructor CreateIt(hSock: TSocket; af, struct, proto, AChainPtr: integer); virtual;
      destructor Destroy; override;

      function WaitForConnect: integer;
      procedure SetFireEvent(Events: DWORD; WindowHandle: HWND; Msg: UINT);
      procedure ReleaseEvent();

      procedure ClearFireEvent();
      procedure FireEvent(Event : DWORD = 0);

      function SafeWaitFor(): DWORD;
      procedure CancelBLockingCall;

      property Method: integer read FMethod write FMethod;
      property OrigName: TSockAddrIn read FOrigName write FOrigName;
      property SockHandle: TSocket read GetSockHandle;
      property Proxy: TAbstractProxy read FProxy;
      property State: TProxyState read FState write FState;
      property Blocking: Boolean read FBlocking write SetBlocking;
      property NextProxy: TProxyItem read FNextProxy write FNextProxy;
    end;


    TProxyArray = class
    private
      FCritSection: TRTLCriticalSection;
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

      function SelectSockets(num: integer; readfds, writefds, exceptfds: PFDSet): integer;


      property Count : Integer read GetCount;
      property Items[s : TSocket] : TProxyItem read GetSockItem; default;
    end;

    procedure Init;
    procedure Fini;


var
   ProxyArray : TProxyArray;

implementation

{ TProxyItem }

{* Main thread procedure. Last known as 'connect' method.
 *}

procedure TProxyItem.Execute();
begin
     try
        DoExecute();
     except
       on E: Exception do
         Log(LOG_LEVEL_WARN, 'ERROR! TProxyItem.DoExecute() exception!: %s', [E.Message]);
     end;
end;

procedure TProxyItem.DoExecute();
var
   res      : Boolean;
   ProxyItem: TProxyItem;
   serv     : string;
   proxy_type: string;
   login, passwd, ident: string;
   http_login, http_passwd: string;
   port, ver: integer;
   bFirst   : Boolean;
   bAuth    : Boolean;
   DestAddr : TSockAddr;
   conn_err : integer;
   Item: TSocksChainItem;

   procedure NotifyError();
   begin
        ReturnValue := 1;
        FState := psError;
        FireEvent();
   end;
begin
     Item := SocksChains[FChainPtr];

     if (Item <> nil) then
     begin
          Item.Lock;
          ver := Item.Version;
          serv  := Item.Server;
          port  := Item.Port;
          login := Item.Login;
          passwd:= Item.Password;
          ident := Item.ident;
          bAuth := Item.Auth;
          http_login := Item.HTTP_User;
          http_passwd := Item.HTTP_Pass;
          bFirst := False;
          Item.Unlock;
     end
     else
     begin
          NotifyError();
          Log(LOG_LEVEL_WARN, 'Chain item #%d are not valid. Proxy change?', [FChainPtr]);
          exit;
     end;


     if not bAuth then
     begin
          login := '';
          ident := '';
     end;

     if not Item.HTTP_Auth then
       http_login := '';

     case ver of
       1: proxy_type := 'HTTPS';
       4: proxy_type := 'SOCKSv4';
       5: proxy_type := 'SOCKSv5';
     else
       proxy_type := 'unknown';
     end;

     if (FChainPtr = SocksChains.GetFirstIndex()) then
     begin
          bFirst := True;
          Log(LOG_LEVEL_SOCKS, 'Using first %s proxy (%s:%d) in the chain', [proxy_type, serv, port]);
          conn_err := WaitForConnect();
          if conn_err = 1 then
          begin
               NotifyError();
               Log(LOG_LEVEL_WARN, 'WaitForConnect() error? ', []);
               exit;
          end;
     end
     else // Others child threads doesn't require to wait until connected. SOCKS server take care about it
         Log(LOG_LEVEL_SOCKS, 'Using %s proxy #%d (%s:%d) in the chain',[proxy_type, succ(FChainPtr), serv, port]);

     if (FChainPtr = SocksChains.GetLastIndex()) then
     begin
          FChainPtr := SocksChains.Count;
          DestAddr := FOrigName;
     end
     else
     begin
          FChainPtr := SocksChains.GetNextIndex(FChainPtr);
          Item := SocksChains[FChainPtr];

          if (Item <> nil) then
          begin
               Item.Lock;
               DestAddr.sin_family := AF_INET;
               DestAddr.sin_port := htons(Item.Port);

               DestAddr.sin_addr.S_addr := UpcallIntf.pResolve(PChar(Item.Server));
               Item.unlock;
          end
          else
          begin
               NotifyError();
               Log(LOG_LEVEL_WARN, 'SocksChainItem#1 are not valid. Proxy change?', []);
               exit;
          end;
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
          ReturnValue := GetLastError();
          if ReturnValue = 0 then
             ReturnValue := 1;
          FState := psError;
          FireEvent();
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
          ReturnValue := ProxyItem.SafeWaitFor(); // Wait until child tread will be done
          FChildProxyItem := ProxyItem;
{          ProxyItem.Terminate;
          ProxyItem.Free;}
     end;


     if (ReturnValue = 0) and ((FChainPtr = succ(SocksChains.GetFirstIndex())) or (FChainPtr >= SocksChains.GetLastIndex())) then
     begin
          Log(LOG_LEVEL_SOCKS, 'Tcp tunnel opened (%s)', [serv]);
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

     FCancelEvent := TEvent.Create(nil, False, False, '');
     FCancelEvent.ResetEvent;

     if struct = SOCK_DGRAM then
     begin
          FMethod := METHOD_UDP;
          Item := SocksChains.GetLastSOCKS5();
          Item.Lock();

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
          Item.UnLock();
     end;

     Faf := af;
     Fstruct := struct;

     FProto := proto;
     FChainPtr := AChainPtr;

     if (FChainPtr = -1) then
     begin
          DisplayMessage('No proxy servers in use. Please select at least one. Program will be terminated.');
          Halt;
     end;

     if SocksChains.Count = 0 then
     begin
          DisplayMessage('No proxy servers specified. Please specify at least one. Program will be terminated.');
          Halt;
     end;

end;

destructor TProxyItem.Destroy;
begin
     Cleanup();
     Log(LOG_LEVEL_SOCKS, '[%d] Removing socket from our table', [FHSock]);
     FCancelEvent.Free;
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
          if FCancelEvent.WaitFor(1) <> wrTimeout then
          begin
               Log(LOG_LEVEL_SOCKS, '[%d] WaitForConnect Cancel event signaled! Exiting...', [SockHandle]);
               res := -1;
               SetLastError(WSAECONNREFUSED);
               break;
          end;

          FD_CLR(hSocket, readfd);
          FD_SET(hSocket, readfd);

          FD_CLR(hSocket, writefd);
          FD_SET(hSocket, writefd);

          FD_CLR(hSocket, errorfd);
          FD_SET(hSocket, errorfd);
          SetLastError(0);

          res := Stub_select(0, @readfd, @writefd, @errorfd, @timeval);

          if FD_ISSET(hSocket, writefd) then
          begin
               if (GetLastError() = 0) then
               begin
                    result := 0;
                    exit;
               end;
          end;

          if FD_ISSET(hSocket, readfd) then
          begin
               if (GetLastError() <> WSAEWOULDBLOCK) then
               begin
                    Log(LOG_LEVEL_SOCKS, 'connect error?: %s (%d)', [WSocketErrorDesc(GetLastError()), GetLastError()]);
                    break;
               end;
          end;

          if FD_ISSET(hSocket, errorfd) then
          begin
               SetLastError(WSAECONNREFUSED);
               Log(LOG_LEVEL_SOCKS, 'connect error: %s (%d)', [WSocketErrorDesc(GetLastError()), GetLastError()]);
               break;
          end;

          if (res < 0) then
          begin
               SetLastError(WSAECONNREFUSED);
               Log(LOG_LEVEL_SOCKS, 'connect error: %s (%d)', [WSocketErrorDesc(GetLastError()), GetLastError()]);
               break;
          end;
     end;
     result := res;
end;


function TProxyItem.GetSockHandle: TSocket;
begin
     result := FHSock;
end;

procedure TProxyItem.FireEvent(Event : DWORD{ = 0});
begin
     if FWindowHandle = 0 then
       exit;

     if (ReturnValue = 0) then
     begin
          Log(LOG_LEVEL_CONN, '[%d] Firing event notification to 0x%x window', [FHSock, FWindowHandle]);
          if (FEvents and FD_CONNECT) = FD_CONNECT then
            PostMessage(FWindowHandle, FMsg, FHSock, MAKELONG(FD_CONNECT, 0));

          if (FEvents and FD_WRITE) = FD_WRITE then
            PostMessage(FWindowHandle, FMsg, FHSock, MAKELONG(FD_WRITE, 0));
     end
     else
     begin
          Log(LOG_LEVEL_CONN, '[%d] Connection failed. Firing event notification to 0x%x window', [FHSock, FWindowHandle]);
          PostMessage(FWindowHandle, FMsg, FHSock, MAKELONG(FD_CONNECT, WSAECONNREFUSED));
     end;
end;

procedure TProxyItem.SetFireEvent(Events: DWORD; WindowHandle: HWND; Msg: UINT);
{var
   argp: u_long;
   optlen: integer;}
begin
     if (FD_CONNECT and Events) = FD_CONNECT then
     begin
          // Almost forgot: WSAAsyncSelect automatically turns
          // non-blocking mode. This fixes "freezing" issue with Opera

{          argp := 1;
          Stub_ioctlsocket(FHSock, FIONBIO, argp); // Turn on non-blocking mode
}
          FBlocking := False;

          FEvents := Events;
          FWindowHandle := WindowHandle;
          FMsg := Msg;
          if FState = psEstablished then
          begin
               FireEvent();
          end;
          Log(LOG_LEVEL_CONN, '[%d] Calling thread assumes to accept notify when FD_CONNECT occurs', [FHSock]);
     end;
end;

procedure TProxyItem.ReleaseEvent();
var
   RetErr: DWORD;
begin
     UpcallIntf.WSockUpcall.pWSAAsyncSelect(FHSock, FWindowHandle, FMsg, FEvents, @RetErr);
end;


procedure TProxyItem.CleanUp;
begin
     if (FProxy <> nil) then
     begin
          FProxy.CancelBlockingCall;
          FProxy.ExitFlag := True;
          FProxy.Free;
          FProxy := nil;
     end;
     if (FChildProxyItem <> nil) then
     begin
          FChildProxyItem.Free;
          FChildProxyItem := nil;
     end;
end;

procedure TProxyItem.ClearFireEvent;
var
{   argp: u_long;}
   RetErr: DWORD;
begin
     FWindowHandle := 0;
{     argp := 0;
     Stub_ioctlsocket(FHSock, FIONBIO, argp); // Turn on non-blocking mode
}
     UpcallIntf.WSockUpcall.pWSAAsyncSelect(FHSock, FWindowHandle, 0, 0, @RetErr);
     Log(LOG_LEVEL_CONN, '[%d] Clearing firing event', [FHSock]);
     FBlocking := True;
end;

procedure TProxyItem.SetBlocking(const Value: Boolean);
begin
     FBlocking := Value;
//     if FBlocking and (FState in [psConnecting]) then
//        SafeWaitFor();
end;

function TProxyItem.MyWaitFor: DWORD;
var
   h: THandle;
   ws: DWORD;
begin
     H := Handle;
     ws := WaitForSingleObject(H, 5000);

     if (ws = WAIT_ABANDONED) or (ws = WAIT_TIMEOUT) or (ws = WAIT_FAILED) then
     begin
          CancelBLockingCall;
{          Beep;
          Log(LOG_LEVEL_DEBUG, '[%d] ¿’“”Õ√!', [FHSock]);
          Log(LOG_LEVEL_DEBUG, '[%d] WaitForSingleObject = %d', [FHSock, ws]);
          Log(LOG_LEVEL_DEBUG, '[%d] FState = %d', [FHSock, Integer(FState)]);
}
     end;

     GetExitCodeThread(H, Result);
end;

procedure TProxyItem.CancelBLockingCall;
begin
     FCancelEvent.SetEvent;
     if FProxy <> nil then
        FProxy.CancelBlockingCall;
end;


function TProxyItem.SafeWaitFor: DWORD;
begin
     Log(LOG_LEVEL_DEBUG, '(%d) TProxyItem.SafeWaitFor', [FHSock]);

     if Suspended then
     begin
          Log(LOG_LEVEL_DEBUG, '(%d) thread suspended. Resuming...', [FHSock]);
          Resume;
     end;

     if Terminated or (FState in [psEstablished, psError, psDirect]) then
     begin
          Log(LOG_LEVEL_DEBUG, '(%d) thread terminated.', [FHSock]);
          result := ReturnValue;
          exit;
     end;

     if (FMethod <> METHOD_UDP) then
       result := MyWaitFor()
     else
       result := 0;
end;



{****************************************************************************
 *                              TProxyArray                                 *
 ****************************************************************************}

procedure TProxyArray.Add(hSock: TSocket; af, struct, proto: integer);
var
   Item: TProxyItem;
begin
     try
        EnterCriticalSection(FCritSection);
        Item := TProxyItem.CreateIt(hSock, af, struct, proto, SocksChains.GetFirstIndex());
        FItems.Add(Item);
        LeaveCriticalSection(FCritSection);
     except
       on E: Exception do
         begin
              Log(LOG_LEVEL_WARN, 'TProxyArray.Add exception! %s ', [E.Message]);
              halt;
         end;
     end;

end;


constructor TProxyArray.Create;
begin
     InitializeCriticalSection(FCritSection);
     FItems := TList.Create;
     FLastItem := -1;
end;

procedure TProxyArray.Clear();
var
   i    : integer;
   Item : TProxyItem;
begin
     try
        EnterCriticalSection(FCritSection);

        for i := FItems.Count - 1 downto 0 do
        begin
             Item := TProxyItem(FItems[i]);
             if (Item <> nil) then
             begin
                  Item.Terminate;
                  Item.Free;
                  FItems.Delete(i);
             end;
        end;
        FLastItem := -1;
        FLastSockItem := 0;
        LeaveCriticalSection(FCritSection);
     except
       on E: Exception do
         Log(LOG_LEVEL_DEBUG, 'Exception! TProxyArray.Clear: %s', [E.Message]);
     end;
end;


procedure TProxyArray.Del(hSock: TSocket);
var
   i    : integer;
   Item : TProxyItem;
begin
     {* IMPORTANT!
      * Deletion MUST be syncronized!
      *}
     try
        EnterCriticalSection(FCritSection);

        for i := FItems.Count - 1 downto 0 do
        begin
             Item := TProxyItem(FItems[i]);
             if (Item <> nil) and (Item.SockHandle = hSock) then
             begin
                  Item.CancelBLockingCall;
                  Item.Terminate; // Stop the thread
                  Item.SafeWaitFor();
                  Item.Free;
                  FItems.Delete(i);
             end;
        end;
        FLastItem := -1;
        FLastSockItem := 0;
        LeaveCriticalSection(FCritSection);
     except
       on E: Exception do
         Log(LOG_LEVEL_DEBUG, 'Exception! TProxyArray.Del: %s', [E.Message]);
     end;
end;


destructor TProxyArray.Destroy;
begin
     EnterCriticalSection(FCritSection);
     Log(LOG_LEVEL_SOCKS, 'Destroying ProxyArray',[]);
     Clear();
     FItems.Free;
     LeaveCriticalSection(FCritSection);

     DeleteCriticalSection(FCritSection);
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
     try
        EnterCriticalSection(FCritSection);
        if (s = FLastSockItem) and (s <> 0) then
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
        LeaveCriticalSection(FCritSection);
     except
       on E: Exception do
         Log(LOG_LEVEL_DEBUG, 'Exception! TProxyArray.GetItem: %s (s = %d; FLastItem = %d; FLastSockItem = %d)', [E.Message, s, FLastItem, FLastSockItem]);
     end;
end;



function TProxyArray.GetCount: Integer;
begin
     result := FItems.Count;
end;


function TProxyArray.SelectSockets(num: integer; readfds, writefds,
  exceptfds: PFDSet): integer;
var
   i: integer;
   Item: TProxyItem;

   procedure DelEntryFDSet(fdset: PFDSet; s: TSocket);
   var
      i, j: integer;
      tmpSet: TFDSet;
   begin
        ZeroMemory(@tmpSet, SIzeof(tmpSet));
        j := 0;

        for i := 0 to fdset^.fd_count - 1 do
        begin
             if fdset^.fd_array[i] <> s then
             begin
                  inc(tmpSet.fd_count);
                  tmpSet.fd_array[j] := s;
                  inc(j);
             end;
        end;
        Move(tmpSet, fdset^, SizeOf(fdset^));
   end;

begin
     result := num;

     if readfds <> nil then
     begin
          for i := 0 to readfds^.fd_count - 1 do
          begin
               Item := GetItem(readfds^.fd_array[i]);
               if (Item <> nil) and (Item.State in [psConnecting]) then
               begin
//                    Log(LOG_LEVEL_WARN, 'readfds^[%d] = %d', [writefds^.fd_array[i], Integer(Item.State)]);
                    DelEntryFDSet(readfds, readfds^.fd_array[i]);
                    dec(result);
               end;
          end;
     end;

     if writefds <> nil then
     begin
          for i := 0 to writefds^.fd_count - 1 do
          begin
               Item := GetItem(writefds^.fd_array[i]);
               if (Item <> nil) and (Item.State in [psConnecting]) then
               begin
//                    Log(LOG_LEVEL_WARN, 'writefds^[%d] = %d', [writefds^.fd_array[i], Integer(Item.State)]);
                    DelEntryFDSet(writefds, writefds^.fd_array[i]);
                    dec(result);
               end;
          end;
     end;
     if result < 0 then
       result := 0;
end;



{* Initialization routines
 *}
procedure Init;
begin
     ProxyArray  := TProxyArray.Create;
end;

procedure Fini;
begin
     ProxyArray.Free;
     ProxyArray := nil;
end;



end.
