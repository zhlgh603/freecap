{*
 * File: ...................... proxy32.dpr
 * Author: .................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2005 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... FreeCap proxy engine, part of FreeCap and WideCap
  $Id: proxy32.dpr,v 1.18 2005/12/19 06:09:02 bert Exp $

  $Log: proxy32.dpr,v $
  Revision 1.18  2005/12/19 06:09:02  bert
  *** empty log message ***

  Revision 1.17  2005/11/01 14:07:10  bert
  *** empty log message ***

  Revision 1.16  2005/10/31 14:26:22  bert
  *** empty log message ***

  Revision 1.15  2005/10/27 19:05:51  bert
  *** empty log message ***

  Revision 1.14  2005/08/11 05:20:36  bert
  *** empty log message ***
}
Library proxy32;

uses
  Windows,
  SysUtils,
  proxy_intf in '..\proxy_intf.pas',
  winsock2 in 'winsock2.pas',
  AbstractProxy in 'AbstractProxy.pas',
  base64 in 'base64.pas',
  cfg in 'cfg.pas',
  common in 'common.pas',
  direct_addr in 'direct_addr.pas',
  dns in 'dns.pas',
  HTTPProxy in 'HTTPProxy.pas',
  Misc in 'misc.pas',
  Proxy in 'Proxy.pas',
  Socks4Proxy in 'Socks4Proxy.pas',
  Socks5Proxy in 'Socks5Proxy.pas',
  sockschain in 'sockschain.pas',
  loger in 'loger.pas',
  reg_config in '..\reg_config.pas',
  abs_config in '..\abs_config.pas',
  xml_config in '..\xml_config.pas',
  stub in 'stub.pas';
//  DebugExcept in 'DebugExcept.pas';


{const
     SYNC_CONNECT_MUTEX = 'FreeCap$MUTEX$CONNECT';
}

{$R *.res}

// ----------------------------------------------------------------------------

function _WSAAccept (s: TSocket; var addr: TSockAddr; var addrlen: integer;
  lpfnCondition: LPCONDITIONPROC; dwCallbackData: DWORD;
  lpErrno: PInteger): TSocket; stdcall;
begin
     result := UpcallIntf.WSockUpcall.pWSAAccept(s, addr, addrlen, lpfnCondition, dwCallbackData, lpErrno);
end;

// ----------------------------------------------------------------------------
function GetEventsStr(lEvents: DWORD): string;
begin
     result := '';
     if (lEvents and FD_READ) = FD_READ then result := result + ' FD_READ';
     if (lEvents and FD_WRITE) = FD_WRITE then result := result + ' FD_WRITE';
     if (lEvents and FD_OOB) = FD_OOB then result := result + ' FD_OOB';
     if (lEvents and FD_ACCEPT) = FD_ACCEPT then result := result + ' FD_ACCEPT';
     if (lEvents and FD_CONNECT) = FD_CONNECT then result := result + ' FD_CONNECT';
     if (lEvents and FD_CLOSE) = FD_CLOSE then result := result + ' FD_CLOSE';
     if (lEvents and FD_QOS) = FD_QOS then result := result + ' FD_QOS';
     if (lEvents and FD_GROUP_QOS) = FD_GROUP_QOS then result := result + ' FD_GROUP_QOS';

     if lEvents = 0 then
       result := 'FD_CLEAR';
end;

// ----------------------------------------------------------------------------
function _WSAAsyncSelect (s: TSOCKET; hWnd: HWND; wMsg: Word; lEvent: DWORD;
  lpErrno: PInteger): integer; stdcall;
var
   Item: TProxyItem;
begin
     Item := ProxyArray.GetItem(s);
     Log(LOG_LEVEL_CONN, 'WSAAsyncSelect(%d, %x, %s)', [s, wMsg, GetEventsStr(lEvent)]);

     if (Item <> nil) and ((FD_CONNECT and lEvent) = FD_CONNECT) then
     begin
          Item.Blocking := False;
          Item.SetFireEvent(lEvent, HWnd, wMsg);
          lEvent := lEvent and (not FD_CONNECT);
     end
     else if (Item <> nil) and (wMsg = 0) and (lEvent = 0) then
     begin
          if Item.State = psConnecting then
          begin
              Item.CancelBlockingCall;
              Item.SafeWaitFor();
          end;
          Item.Blocking := True;
          Item.ClearFireEvent();
     end;
     result := UpcallIntf.WSockUpcall.pWSAAsyncSelect(s, hWnd, wMsg, lEvent, lpErrno);
end;

// ----------------------------------------------------------------------------
function _WSAEventSelect (s: TSocket; hEventObject: WSAEVENT; lNetworkEvents: LongInt; lpErrno: PInteger): Integer; stdcall;
var
   Item: TProxyItem;
begin
     Log(LOG_LEVEL_CONN, 'WSAEventSelect(%d)', [s]);

{     Item := ProxyArray.GetItem(s);

     if Item <> nil then
     begin
          result := 0;

          if lNetworkEvents <> 0 then
          begin
               Item.Blocking := False;
               Item.SetSignalEvent(hEventObject, lNetworkEvents);
          end
          else
             Item.Blocking := True;

          if Item.State = psEstablished then
             Item.SignalEvent();
     end;
}
     result := UpcallIntf.WSockUpcall.pWSAEventSelect(s, hEventObject, lNetworkEvents, lpErrno);
//     Log(LOG_LEVEL_CONN, 'WSAEventSelect(%d, %s) = %d', [s, GetEventsStr(lNetworkEvents), result]);
end;

// ----------------------------------------------------------------------------
function _WSABind (s : TSocket; const name: PSockAddr; namelen: integer;
  lpErrno: PInteger): integer; stdcall;
begin
     result := UpcallIntf.WSockUpcall.pWSABind (s, name, namelen, lpErrno);
end;

// ----------------------------------------------------------------------------

function _WSACancelBlockingCall (lpErrno: PInteger): integer; stdcall;
begin
     result := UpcallIntf.WSockUpcall.pWSACancelBlockingCall(lpErrno);
end;

// ----------------------------------------------------------------------------

function _WSACleanup (lpErrno: PInteger): integer; stdcall;
begin
     result := UpcallIntf.WSockUpcall.pWSACleanup (lpErrno);
end;

// ----------------------------------------------------------------------------

function _WSACloseSocket (s: TSOCKET; lpErrno: PInteger): integer; stdcall;
begin
     ProxyArray.Del(s);
     result := UpcallIntf.WSockUpcall.pWSACloseSocket(s, lpErrno);
end;

// ----------------------------------------------------------------------------

function _WSAConnect (s: TSOCKET; const name: PSockaddr; namelen: integer;
  lpCallerData, lpCalleeData: LPWSABUF; lpSQOS, lpGQOS: LPQOS;
  lpErrno: PInteger): integer; stdcall;
var
   HostEnt  : PHostEnt;
   ph       : PHostAddr;
   oldName  : TSockAddr;
   res      : integer;
   FirstSocksServ: string;
   FirstSocksPort: integer;
   idx, err : integer;
   Item     : TProxyItem;
   hMutex   : THandle;

begin
     Log(LOG_LEVEL_CONN, '[%d] Connecting to (%s, %d)...',[s, GetAddrString(name.sin_addr.S_addr), ntohs(name.sin_port)]);

     if DirectAddr.IsAddrDirect(name^.sin_addr.S_addr) or (DirectAddr.IsPortDirect(name^.sin_port)) then
     begin
          Item := ProxyArray.GetItem(s);
          if (Item <> nil) then
          begin
               Item.ReleaseEvent();

               if (Item.Method = METHOD_UDP) then
                 ProxyArray.Del(s)
               else
                 Item.State := psDirect;
          end;

          SetLastError(0);

          result := UpcallIntf.WSockUpcall.pWSAConnect(s, name, namelen, lpCallerData, lpCalleeData,
              lpSQOS, lpGQOS, lpErrno);

          if (result <> ERROR_SUCCESS) then
             SetLastError(lpErrno^);

          Log(LOG_LEVEL_CONN, '[%d] Direct connection to (%s, %d) = %d', [s, GetAddrString(name.sin_addr.S_addr), ntohs(name.sin_port), result]);
          exit;
     end;


     oldName := Name^;
     Item := ProxyArray.GetItem(s);

     if (Item <> nil) and (Item.Method = METHOD_UDP) then
     begin
          Item.OrigName := oldName;
//          Item.BindName := oldName;
     end;

     if (Item <> nil) and (Item.Method <> METHOD_UDP) then
     begin
          idx := SocksChains.GetFirstIndex();

          if idx = SocksChains.Count then
          begin
               result := -1;
               SetLastError(WSAECONNREFUSED);
               Log(LOG_LEVEL_SOCKS, 'end of chain reached...',[]);
               exit;
          end;

          FirstSocksServ := SocksChains[idx].Server;
          FirstSocksPort := SocksChains[idx].Port;

          name^.sin_addr.S_addr := inet_addr(PChar(FirstSocksServ));

          if name^.sin_addr.S_addr = INADDR_NONE then
          begin
               // Not in a dotted notation...
               // Try to resolve
               HostEnt := gethostbyname(PChar(FirstSocksServ));
               if HostEnt = nil then
               begin
                    DisplayMessage(Format('SOCKS server "%s" not found. No DNS records',[FirstSocksServ]));
                    ProxyArray.Del(s);

                    result := UpcallIntf.WSockUpcall.pWSAConnect(s, name, namelen, lpCallerData, lpCalleeData,
                      lpSQOS, lpGQOS, lpErrno);
                    exit;
               end;
               ph := PHostAddr(HostEnt^.h_addr_list^);
               name^.sin_addr.S_addr := Cardinal(ph^);
          end;
          name^.sin_port := ntohs(FirstSocksPort);

          result := Stub_connect(s, name, namelen);

          err := 0;
          if (result = -1) or (result = 0) then
          begin
               if (result = -1) then
                 err := GetLastError();

               if (err = WSAEWOULDBLOCK) or (err = 0) then
               begin
                    Item.OrigName := oldName;
//                    Item.BindName := oldName;
                    Item.Method := METHOD_CONNECT;
                    //* Thread was created in the suspend mode
                    //*
                    Item.Resume;

                    if not Item.Blocking then
                    begin
                         Log(LOG_LEVEL_CONN, '[%d] Socket in non-blocking mode, will complete connection later',[s]);
                         SetLastError(WSAEWOULDBLOCK);
                         result := -1;
                         lpErrno^ := WSAEWOULDBLOCK;
                    end
                    else
                    begin
                         Log(LOG_LEVEL_CONN, '[%d] Socket in blocking mode, have to complete connection now',[s]);
                         res := Item.SafeWaitFor();
                         if res <> 0 then
                         begin
                              result := -1;
                              SetLastError(WSAECONNREFUSED);
                              exit;
                         end;

                         SetLastError(0);
                         result := 0;
                     end;
               end
               else
               begin
                    if (err = WSAECONNREFUSED) or (err = WSAECONNRESET) then
                      DisplayMessage(Format('Error connecting to the SOCKS server (%s:%d)'#13#10'Winsock error: %s (%d)',[FirstSocksServ, FirstSocksPort, WSocketErrorDesc(WSAGetLastError()), WSAGetLastError()]));
                    Log(LOG_LEVEL_WARN, 'connect()  error: %s (%d)',[WSocketErrorDesc(err), err]);
               end;
          end;
     end
     else if (Item <> nil) and (Item.Method = METHOD_UDP) then
     begin
          if (TSOCKS5Proxy(Item.Proxy).DoConnectUDP() = -1) then
          begin
               err := GetLastError();
               Log(LOG_LEVEL_WARN, 'UDP tunnel connect() error: %s (%d)',[WSocketErrorDesc(err), err]);
               result := -1;
               exit;
          end;

          TSOCKS5Proxy(Item.Proxy).NegotiateUDP();
          TSOCKS5Proxy(Item.Proxy).DoOpenUDP();
          SetLastError(0);
          result := 0;
     end
     else
         result := UpcallIntf.WSockUpcall.pWSAConnect(s, name, namelen, lpCallerData, lpCalleeData,
             lpSQOS, lpGQOS, lpErrno);

end;

// ----------------------------------------------------------------------------
function _WSAGetPeerName (s: TSocket; name: PSockAddr; namelen,
  lpErrno: PInteger): integer; stdcall;
var
   Item: TProxyItem;
begin
     result := UpcallIntf.WSockUpcall.pWSAGetPeerName(s, name, namelen, lpErrno);
     Item := ProxyArray.GetItem(s);
     if (Item <> nil) and (result = 0) then
       Move(Item.OrigName, name^, SizeOf(Item.OrigName));
     Log(LOG_LEVEL_CONN, 'getpeername = %s',[GetFullAddr(name^)]);
end;

// ----------------------------------------------------------------------------
function _WSAGetSockName (s: TSocket; name: PSockAddr; namelen,
  lpErrno: PInteger): integer; stdcall;
begin
     result := UpcallIntf.WSockUpcall.pWSAGetSockName(s, name, namelen, lpErrno);
end;

// ----------------------------------------------------------------------------
function _WSAGetSockOpt (s: TSocket; level, optname: integer; optval: Pointer;
  optlen, lpErrno: PInteger): integer; stdcall;
begin
     result := UpcallIntf.WSockUpcall.pWSAGetSockOpt(s, level, optname, optval,
         optlen, lpErrno);
end;

// ----------------------------------------------------------------------------
function _WSAIoctl (s: TSocket; dwIoControlCode: DWORD; lpvInBuffer: Pointer;
  cbInBuffer: DWORD; lpvOutBuffer: Pointer; cbOutBuffer: DWORD;
  lpcbBytesReturned: LPDWORD; lpOverlapped: LPWSAOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE;
  lpThreadId: LPWSATHREADID; lpErrno: PInteger): integer; stdcall;
var
   str: string;
   Item: TProxyItem;
   cmd, arg: DWORD;
begin
     if lpvInBuffer = nil then
     begin
          result := UpcallIntf.WSockUpcall.pWSAIoctl (s, dwIoControlCode, lpvInBuffer,
              cbInBuffer, lpvOutBuffer, cbOutBuffer, lpcbBytesReturned,
              lpOverlapped, lpCompletionRoutine, lpThreadId, lpErrno);
          exit;
     end;

     arg := DWORD(lpvInBuffer^);
     cmd := dwIoControlCode;
     case cmd of
       FIONBIO: begin
                     str := 'Setting socket to';
                     if arg > 0 then
                       str := str + ' nonblocking mode'
                     else
                       str := str + ' blocking mode';
                     Item := ProxyArray.GetItem(s);
                     if (Item <> nil) then
                       Item.Blocking := not (arg > 0); //False;
                end;
       FIONREAD: str := 'FIONREAD';
       SIOCATMARK: str := 'SIOCATMARK';
     end;
     result := UpcallIntf.WSockUpcall.pWSAIoctl (s, dwIoControlCode, lpvInBuffer,
         cbInBuffer, lpvOutBuffer, cbOutBuffer, lpcbBytesReturned,
         lpOverlapped, lpCompletionRoutine, lpThreadId, lpErrno);
     Log(LOG_LEVEL_CONN, '[%d] ioctlsocket (%s)',[s, str]);
end;


// ----------------------------------------------------------------------------
function _WSAListen (s: TSocket; backlog: integer; lpErrno: PInteger): integer; stdcall;
begin
     result := UpcallIntf.WSockUpcall.pWSAListen (s, backlog, lpErrno);
end;


// ----------------------------------------------------------------------------
function _WSARecv (s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD;
  lpNumberOfBytesRecvd: LPDWORD; lpFlags: LPDWORD; lpOverlapped: LPWSAOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE;
  lpThreadId: LPWSATHREADID; lpErrno: PInteger): integer; stdcall;
var
   buffer: array[0..65535] of char;
   pWBuf: PWSABUF;
   from: TSockAddrIn;
   fromlen: integer;
   Item : TProxyItem;
begin
     Item := ProxyArray.GetItem(s);
     result := ERROR_NOT_ENOUGH_MEMORY;


     if (Item = nil) or ((Item <> nil) and (Item.State = psDirect)) or (dwBufferCount = 0) then
     begin
          result := UpcallIntf.WSockUpcall.pWSARecv (s, lpBuffers, dwBufferCount,
              lpNumberOfBytesRecvd, lpFlags, lpOverlapped, lpCompletionRoutine,
              lpThreadId, lpErrno);
          exit;
     end;

     if (Item <> nil) {and (not Item.Blocking)} and (not (Item.State in [psEstablished, psError])) then
     begin
          Log(LOG_LEVEL_DEBUG, 'WSARecv(start)', []);
          if Item.Method <> METHOD_UDP then
            Item.SafeWaitFor;
          Log(LOG_LEVEL_DEBUG, 'WSARecv(end)', []);
     end
     else
     begin
          SetLastError(0);
     end;

     GetMem(pWBuf, SizeOf(WSABuf));
     try

     try
        pWBuf^.len := lpBuffers[0]^.len;
        pWBuf^.buf := lpBuffers[0]^.buf;
        lpBuffers[0]^.buf := @Buffer;


        if (Item <> nil) and (Item.Method = METHOD_UDP)  then
        begin
             from := Item.Proxy.DestAddr;
             fromlen := SizeOf(TSockAddrIn);
             Log(LOG_LEVEL_CONN, 'UDP recv(socket = %d; len = %d; from = %s:%d)', [s, dwBufferCount, GetDottedIP(from.sin_addr.s_addr), ntohs(from.sin_port)]);
             lpBuffers[0]^.len := lpBuffers[0]^.len + 10;

             result := UpcallIntf.WSockUpcall.pWSARecvFrom (s, lpBuffers, dwBufferCount,
                lpNumberOfBytesRecvd, lpFlags, @from, @fromlen, lpOverlapped, lpCompletionRoutine,
                lpThreadId, lpErrno);

             if (result = ERROR_SUCCESS) and (lpNumberOfBytesRecvd^ > 10) then
             begin
                  Move(buffer[10], pWBuf^.buf^, lpNumberOfBytesRecvd^ - 10);
                  dec(lpBuffers[0]^.len, 10);
                  dec(lpNumberOfBytesRecvd^, 10);
                  exit;
             end;
        end
        else
        begin
             lpBuffers[0]^.len := pWBuf^.len;

              result := UpcallIntf.WSockUpcall.pWSARecv (s, lpBuffers, dwBufferCount,
                      lpNumberOfBytesRecvd, lpFlags, lpOverlapped, lpCompletionRoutine,
                      lpThreadId, lpErrno);

              if (result <> ERROR_SUCCESS) and (lpErrno^ = WSAEWOULDBLOCK) then
              begin
                   Log(LOG_LEVEL_DEBUG, 'Selecting for Recv...', []);

                   if SelectForRecv(s) = 1 then
                   begin
                        Log(LOG_LEVEL_DEBUG, 'Selecting for Recv done...', []);
                        result := UpcallIntf.WSockUpcall.pWSARecv (s, lpBuffers, dwBufferCount,
                           lpNumberOfBytesRecvd, lpFlags, lpOverlapped, lpCompletionRoutine,
                           lpThreadId, lpErrno);
                   end
                   else
                       Log(LOG_LEVEL_DEBUG, 'SelectForRecv failed!', []);
              end;
        end;


        if (result = ERROR_SUCCESS) and (lpNumberOfBytesRecvd^ > 0) then
        begin
             if (Item <> nil) and (Item.Method = METHOD_UDP) then
             begin
                  if (result = ERROR_SUCCESS) and (lpNumberOfBytesRecvd^ > 10) then
                  begin
                       Move(buffer[10], pWBuf^.buf^, lpNumberOfBytesRecvd^ - 10);
                       dec(lpBuffers[0]^.len, 10);
                       dec(lpNumberOfBytesRecvd^, 10);
                       exit;
                  end;
             end;
             Move(buffer[0], pWBuf^.buf^, lpNumberOfBytesRecvd^);
        end;
     except
       on E: Exception do
         Log(LOG_LEVEL_DEBUG, 'Exception in WSARecv try...except block! %s', [E.Message]);
     end;
     finally
       FreeMem(pWBuf);
     end;
end;

// ----------------------------------------------------------------------------
function _WSARecvDisconnect (s: TSocket; lpInboundDisconnectData: LPWSABUF;
  lpErrno: PInteger): integer; stdcall;
begin
     result := UpcallIntf.WSockUpcall.pWSARecvDisconnect (s, lpInboundDisconnectData,
         lpErrno);
end;

// ----------------------------------------------------------------------------
function _WSARecvFrom (s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD;
  lpNumberOfBytesRecvd: LPDWORD; lpFlags: LPDWORD; lpFrom: PSockAddr;
  lpFromlen: PInteger; lpOverlapped: LPWSAOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE;
  lpThreadId: LPWSATHREADID; lpErrno: PInteger): integer; stdcall;
var
   buffer: array[0..65535] of char;
   udp_addr: TSockAddrIn;
   Item : TProxyItem;
   pWBuf: PWSABUF;
   function isDirect(): Boolean;
   begin
        result := DirectAddr.IsAddrDirect(lpFrom^.sin_addr.S_addr) or (DirectAddr.IsPortDirect(lpFrom^.sin_port));
   end;

begin
     if (dwBufferCount = 0) then
     begin
          result := UpcallIntf.WSockUpcall.pWSARecvFrom(s, lpBuffers, dwBufferCount,
              lpNumberOfBytesRecvd, lpFlags, lpFrom, lpFromlen, lpOverlapped,
              lpCompletionRoutine, lpThreadId, lpErrno);

          exit;
     end;

     Item := ProxyArray.GetItem(s);

     GetMem(pWBuf, SizeOf(WSABuf));
     pWBuf^.len := lpBuffers[0]^.len;
     pWBuf^.buf := lpBuffers[0]^.buf;
     lpBuffers[0]^.buf := @Buffer;

     if (Item <> nil) and (Item.Method = METHOD_UDP) and (not isDirect()) then
     begin
          inc(lpBuffers[0]^.len, 10);

          udp_addr := Item.Proxy.DestAddr;

          result := UpcallIntf.WSockUpcall.pWSARecvFrom(s, lpBuffers, dwBufferCount,
              lpNumberOfBytesRecvd, lpFlags, @udp_addr, lpFromlen, lpOverlapped,
              lpCompletionRoutine, lpThreadId, lpErrno);

          if (result = ERROR_SUCCESS) and (lpNumberOfBytesRecvd^ > 0) then
            Log(LOG_LEVEL_CONN, '[%d] recvfrom(length = %d; flags = %d; from = %s:%d; fromlen = %d) = %d',[s, lpBuffers[0]^.len, lpFlags^, GetDottedIP(udp_addr.sin_addr.S_addr), htons(udp_addr.sin_port), lpFromlen^, lpNumberOfBytesRecvd^]);
     end
     else
     begin
          result := UpcallIntf.WSockUpcall.pWSARecvFrom(s, lpBuffers, dwBufferCount,
              lpNumberOfBytesRecvd, lpFlags, @udp_addr, lpFromlen, lpOverlapped,
              lpCompletionRoutine, lpThreadId, lpErrno);

          if (result = ERROR_SUCCESS) and (lpNumberOfBytesRecvd^ > 0) then
            Log(LOG_LEVEL_CONN, '[%d] recvfrom(length = %d; flags = %d; from = %s:%d; fromlen = %d) = %d',[s, lpBuffers[0]^.len, lpFlags^, GetDottedIP(udp_addr.sin_addr.S_addr), htons(udp_addr.sin_port), lpFromlen^, lpNumberOfBytesRecvd^]);
     end;


     if (result = ERROR_SUCCESS) and (lpNumberOfBytesRecvd^ > 0) then
     begin
          if (Item <> nil) and (Item.Method = METHOD_UDP) and (not isDirect()) then
          begin
               Log(LOG_LEVEL_CONN, '[%d] recvfrom() in ProxyArray', [s]);

               assert(lpNumberOfBytesRecvd^ > 10);
               lpFrom^.sin_family := AF_INET;
               lpFrom^.sin_addr.S_addr := PDWORD(@Buffer[4])^;
               lpFrom^.sin_port := PWORD(@Buffer[8])^;
               lpfromlen^ := SizeOf(TSockAddrIn);

               Move(buffer[10], pWBuf^.buf^, lpNumberOfBytesRecvd^ - 10);
               dec(lpBuffers[0]^.len, 10);
               dec(lpNumberOfBytesRecvd^, 10);
               FreeMem(pWBuf);
               exit;
          end;

          Move(buffer[0], pWBuf^.buf^, lpNumberOfBytesRecvd^);
          FreeMem(pWBuf);
     end;
end;

// ----------------------------------------------------------------------------
function _WSASelect (nfds: integer; readfds, writefds, exceptfds: PFDSet;
  timeout: PTimeval; lpErrno: PInteger): integer; stdcall;
begin
     result := UpcallIntf.WSockUpcall.pWSASelect(nfds, readfds, writefds,
         exceptfds, timeout, lpErrno);

     if result > 0 then
       result := ProxyArray.SelectSockets(result, readfds, writefds, exceptfds);
end;

// ----------------------------------------------------------------------------
function _WSASend (s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD;
  lpNumberOfBytesSent: LPDWORD; dwFlags: DWORD; lpOverlapped: LPWSAOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE;
  lpThreadId: LPWSATHREADID; lpErrno: PInteger): integer; stdcall;
var
   buffer: array[0..65535] of char;
   addrto: TSockAddr;
   tolen: integer;
   Item: TProxyItem;
   origLen: Integer;
begin
     Item := ProxyArray.GetItem(s);

     if (Item = nil) or ((Item <> nil) and (Item.State = psDirect)) then
     begin
          result := UpcallIntf.WSockUpcall.pWSASend (s, lpBuffers, dwBufferCount,
              lpNumberOfBytesSent, dwFlags, lpOverlapped, lpCompletionRoutine,
              lpThreadId, lpErrno);
          exit;
     end;

     if (Item <> nil) {and (not Item.Blocking)} and (not (Item.State in [psEstablished, psError])) then
     begin
          Log(LOG_LEVEL_DEBUG, 'WSASend(start)', []);
          if Item.Method <> METHOD_UDP then
            Item.SafeWaitFor();
          Log(LOG_LEVEL_DEBUG, 'WSASend(end)', []);
{          result := -1;
          SetLastError(WSAEWOULDBLOCK);
          exit;}
     end
     else
     begin
          SetLastError(0);
     end;

     origLen := lpBuffers[0]^.len;
     Move(lpBuffers[0]^.Buf^, buffer[0], lpBuffers[0]^.len);


     if (Item <> nil) and (Item.Method = METHOD_UDP) then
     begin
          ZeroMemory(@addrto, SizeOf(addrto));
          addrto := Item.OrigName;
          tolen := SizeOf(Item.OrigName);
          Log(LOG_LEVEL_CONN, '[%d] UDP send...', [s]);
          lpNumberOfBytesSent^ := Item.Proxy.Sendto(s, lpBuffers[0]^.Buf, lpBuffers[0]^.len, 0, addrto, tolen);
          Log(LOG_LEVEL_CONN, '[%d] UDP send(lenght = %d; flags = %d) = %d',[s, lpBuffers[0]^.len, dwFlags, lpNumberOfBytesSent^]);
          result := ERROR_SUCCESS;
     end
     else
     begin
          result := UpcallIntf.WSockUpcall.pWSASend (s, lpBuffers, dwBufferCount,
            lpNumberOfBytesSent, dwFlags, lpOverlapped, lpCompletionRoutine,
            lpThreadId, lpErrno);

          if (result = ERROR_SUCCESS) and (lpNumberOfBytesSent^ <> DWORD(origLen)) then
             lpNumberOfBytesSent^ := origLen;
     end;
end;

// ----------------------------------------------------------------------------
function _WSASendDisconnect (s: TSocket; lpOutboundDisconnectData: LPWSABUF;
  lpErrno: PInteger): integer; stdcall;
begin
     result := UpcallIntf.WSockUpcall.pWSASendDisconnect(s, lpOutboundDisconnectData,
         lpErrno);
end;

// ----------------------------------------------------------------------------
function _WSASendTo (s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD;
  lpNumberOfBytesSent: LPDWORD; dwFlags: DWORD; const lpTo : PSockAddr;
  iTolen: integer; lpOverlapped: LPWSAOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE;
  lpThreadId: LPWSATHREADID; lpErrno: PInteger): integer; stdcall;
var
   buffer: array[0..65535] of char;
   Item : TProxyItem;
   res : integer;

   function isDirect(): Boolean;
   begin
        result := DirectAddr.IsAddrDirect(lpTo^.sin_addr.S_addr) or (DirectAddr.IsPortDirect(lpTo^.sin_port));
   end;

begin
     Move(lpBuffers[0]^.Buf^, buffer[0], lpBuffers[0]^.len);

     if ProxyArray.Exists(s) and (ProxyArray.Items[s].Method = METHOD_UDP) and not (isDirect()) then
     begin
          Item := ProxyArray.Items[s];

          if Item.State <> psEstablished then
          begin
               Log(LOG_LEVEL_CONN, 'Establishing tunnel for UDP...', []);
               TSOCKS5Proxy(Item.Proxy).DoConnectUDP;
               res := TSOCKS5Proxy(Item.Proxy).NegotiateUDP;
               if res = 0 then
                 Item.State := psEstablished;
//               Item.Resume;
//               Item.WaitFor();
          end;
          lpNumberOfBytesSent^ := Item.Proxy.Sendto(s, lpBuffers[0]^.Buf, lpBuffers[0]^.len, 0, lpTo^, iTolen);
          result := ERROR_SUCCESS;
     end
     else
         result := UpcallIntf.WSockUpcall.pWSASendTo (s, lpBuffers, dwBufferCount,
             lpNumberOfBytesSent, dwFlags, lpTo, iTolen, lpOverlapped,
             lpCompletionRoutine, lpThreadId, lpErrno);
end;

// ----------------------------------------------------------------------------
function _WSASetSockOpt (s: TSocket; level: integer; optname: integer;
  const optval: Pointer; optlen: integer; lpErrno: PInteger): integer; stdcall;
begin
     result := UpcallIntf.WSockUpcall.pWSASetSockOpt (s, level, optname, optval,
         optlen, lpErrno);
end;

// ----------------------------------------------------------------------------
function _WSAShutdown (s: TSocket; how: integer; lpErrno: PInteger): integer; stdcall;
begin
     result := UpcallIntf.WSockUpcall.pWSAShutdown (s, how, lpErrno);
end;

// ----------------------------------------------------------------------------
// Unicode version of WSASocket !!!
function _WSASocket (af: integer; type_: integer; protocol: integer;
  lpProtocolInfo: LPWSAPROTOCOL_INFOW; g: GROUP; dwFlags: DWORD;
  lpErrno: PInteger): TSocket; stdcall;
var
   s: string;
begin
     result := UpcallIntf.WSockUpcall.pWSASocket (af, type_, protocol,
         lpProtocolInfo, g, dwFlags, lpErrno);

     case type_ of
       SOCK_STREAM: s := 'tcp';
       SOCK_DGRAM: s := 'udp';
     else
       s := 'Unknown';
     end;


     if ((type_ = SOCK_STREAM) or (type_ = SOCK_DGRAM)) and (result <> INVALID_SOCKET) then
     begin
          if (type_ = SOCK_DGRAM) and (SocksChains.GetLastSOCKS5() = nil) then
          begin
               Log(LOG_LEVEL_WARN, 'No SOCKS5 servers found at the end of the chain. UDP traversing supported only by SOCKS v5 related servers.',[]);
               exit;
          end;
          // Add only TCP or UDP sockets
          if not ProxyArray.Exists(result) then
          begin
               ProxyArray.Add(result, af, type_, protocol);
               Log(LOG_LEVEL_CONN, '[%d] Adding %s socket to our table', [result, s]);
          end;
     end;
end;


{*****************************************************************************}

procedure D721F525FE944F9389AE200FF536FA23(); stdcall;
begin
     { Dummy procedure-marker for preventing hooking WinSock API calls by FreeCap :) }
end;

procedure OnStartup(isWideCap: Boolean); stdcall;
begin
     UpcallIntf.pLogMessage(LOG_LEVEL_FREECAP, '%s loaded', ['proxy32.dll']);

     UseWideCapCfg := isWideCap;


     winsock2.Init;
     direct_addr.Init;
     SocksChain.Init();
     proxy.Init;
end;

procedure OnRealod; stdcall;
begin
     UpcallIntf.pLogMessage(LOG_LEVEL_FREECAP, '%s reloading configuration', ['proxy32.dll']);
     if (SocksChains <> nil) then
     begin
          DirectAddr.Load;
          SocksChains.Reload();
     end;
end;

function OnFinish: integer; stdcall;
begin
     proxy.Fini;
     result := 0;
end;

procedure AssertNoNull();
begin
     if @UpcallIntf.pLogMessage = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.pLogMessage = nil!', []);
     if @UpcallIntf.pResolve = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.pResolve = nil!', []);
     if @UpcallIntf.pResolveIP = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.pResolveIP = nil!', []);
     if @UpcallIntf.pIsPseudoAddr = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.pIsPseudoAddr = nil!', []);
     if @UpcallIntf.pFindhost = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.pFindhost = nil!', []);
     if @UpcallIntf.pAllocSocket = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.pAllocSocket = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSAAccept = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSAAccept = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSAAsyncSelect = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSAAsyncSelect = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSABind = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSABind = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSACancelBlockingCall = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSACancelBlockingCall = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSACleanup = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSACleanup = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSACloseSocket = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSACloseSocket = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSAConnect = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSAConnect = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSAGetPeerName = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSAGetPeerName = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSAGetSockName = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSAGetSockName = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSAGetSockOpt = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSAGetSockOpt = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSAEventSelect = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSAEventSelect = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSAIoctl = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSAIoctl = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSAListen = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSAListen = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSARecv = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSARecv = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSARecvDisconnect = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSARecvDisconnect = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSARecvFrom = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSARecvFrom = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSASelect = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSASelect = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSASend = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSASend = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSASendDisconnect = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSASendDisconnect = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSASendTo = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSASendTo = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSASetSockOpt = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSASetSockOpt = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSAShutdown = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSAShutdown = nil!', []);
     if @UpcallIntf.WSockUpcall.pWSASocket = nil then Log(LOG_LEVEL_WARN, 'UpcallIntf.WSockUpcall.pWSASocket = nil!', []);
end;

function GetProxyInterface(upCall: TFreeCapIntf): TWSockIntf; stdcall;
begin
//     StartTracking();
     UpcallIntf := upCall;
     with result do
     begin
          pWSAAccept := @_WSAAccept;
          pWSAAsyncSelect := @_WSAAsyncSelect;
          pWSABind := @_WSABind;
          pWSACancelBlockingCall := @_WSACancelBlockingCall;
          pWSACleanup := @_WSACleanup;
          pWSACloseSocket := @_WSACloseSocket;
          pWSAConnect := @_WSAConnect;
          pWSAGetPeerName := @_WSAGetPeerName;
          pWSAGetSockName := @_WSAGetSockName;
          pWSAGetSockOpt := @_WSAGetSockOpt;
          pWSAIoctl := @_WSAIoctl;
          pWSAListen := @_WSAListen;
          pWSARecv := @_WSARecv;
          pWSARecvDisconnect := @_WSARecvDisconnect;
          pWSARecvFrom := @_WSARecvFrom;
          pWSASelect := @_WSASelect;
          pWSASend := @_WSASend;
          pWSASendDisconnect := @_WSASendDisconnect;
          pWSASendTo := @_WSASendTo;
          pWSASetSockOpt := @_WSASetSockOpt;
          pWSAShutdown := @_WSAShutdown;
          pWSASocket := @_WSASocket;
          pWSAEventSelect := @_WSAEventSelect;

          pOnStartup := @OnStartup;
          pOnFinish := @OnFinish;
          pOnReload := @OnRealod;
     end;

end;

exports
  D721F525FE944F9389AE200FF536FA23,
  GetProxyInterface;

begin
end.
