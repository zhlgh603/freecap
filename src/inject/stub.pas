{
 $Id: stub.pas,v 1.6 2005/12/19 06:09:02 bert Exp $

 $Log: stub.pas,v $
 Revision 1.6  2005/12/19 06:09:02  bert
 *** empty log message ***

 Revision 1.5  2005/08/11 05:20:36  bert
 *** empty log message ***

 Revision 1.4  2005/05/12 04:21:22  bert
 *** empty log message ***

 Revision 1.3  2005/03/08 16:25:28  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit stub;

interface
uses Windows, SysUtils, Winsock2, dns, loger, proxy_intf;


procedure Init;
procedure Fini;

var
   MineIntf: TFreeCapIntf;
   ProxyIntf: TWSockIntf;

implementation
uses xml_config, misc, cfg;

function GetStartupDir(): string;
var
   Buf: array[0..MAX_PATH] of Char;
begin
     GetModuleFileName(hInstance, @Buf, SizeOf(Buf));
     result := ExtractFilePath(String(Buf));
end;


function pLogger(facility: integer; fmt: PChar; args: array of const): integer; stdcall;
begin
     Log(facility, fmt, args);
     result := 0;
end;

function stub_Resolve  (host: PChar): DWORD; stdcall;
begin
     result := Resolve(Host);
end;

function stub_ResolveIP (host: PChar): DWORD; stdcall;
begin
     result := ResolveIP(Host);
end;

function stub_IsPseudoAddr(ip: dword): Boolean; stdcall;
begin
     result := IsPseudoAddr(ip);
end;



function _WSAAccept (s: TSocket; var addr: TSockAddr; var addrlen: integer;
  lpfnCondition: LPCONDITIONPROC; dwCallbackData: DWORD;
  lpErrno: PInteger): TSocket; stdcall;
begin
     result := winsock2.WSAAccept(s, addr, @addrlen, lpfnCondition, dwCallbackData );
end;

function _WSABind(s : TSocket; const name: PSockAddr; namelen: integer;
  lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.bind(s, name, namelen);
end;


function _WSAAsyncSelect (s: TSOCKET; hWnd: HWND; wMsg: Word; lEvent: DWORD;
  lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.WSAAsyncSelect(s, hWnd, wMsg, lEvent);
end;


function _WSACancelBlockingCall (lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.WSACancelBlockingCall();
end;

function _WSACleanup (lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.WSACleanup ();
end;

function _WSACloseSocket (s: TSOCKET; lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.closesocket(s);
end;

function _WSAConnect (s: TSOCKET; const name: PSockaddr; namelen: integer;
  lpCallerData, lpCalleeData: LPWSABUF; lpSQOS, lpGQOS: LPQOS;
  lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.WSAConnect(s, name, namelen, lpCallerData, lpCalleeData, lpSQOS, lpGQOS);
     if result <> ERROR_SUCCESS then
       lpErrno^ := GetLastError();
end;


function _WSAGetPeerName (s: TSocket; name: PSockAddr; namelen,
  lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.GetPeerName(s, name^, namelen^);
end;


function _WSAGetSockName (s: TSocket; name: PSockAddr; namelen,
  lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.GetSockName(s, name^, namelen^);
end;

function _WSAGetSockOpt (s: TSocket; level, optname: integer; optval: Pointer;
  optlen, lpErrno: PInteger): integer;  stdcall;
begin
     result := winsock2.GetSockOpt(s, level, optname, optval, optlen^);
end;

function _WSAIoctl (s: TSocket; dwIoControlCode: DWORD; lpvInBuffer: Pointer;
  cbInBuffer: DWORD; lpvOutBuffer: Pointer; cbOutBuffer: DWORD;
  lpcbBytesReturned: LPDWORD; lpOverlapped: LPWSAOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE;
  lpThreadId: LPWSATHREADID; lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.WSAIoctl (s, dwIoControlCode, lpvInBuffer,
         cbInBuffer, lpvOutBuffer, cbOutBuffer, lpcbBytesReturned,
         lpOverlapped, lpCompletionRoutine);
end;

function _WSAListen (s: TSocket; backlog: integer; lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.Listen (s, backlog);
end;

function _WSARecv (s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD;
  lpNumberOfBytesRecvd: LPDWORD; lpFlags: LPDWORD; lpOverlapped: LPWSAOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE;
  lpThreadId: LPWSATHREADID; lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.WSARecv (s, lpBuffers, dwBufferCount,
         lpNumberOfBytesRecvd^, lpFlags^, lpOverlapped, lpCompletionRoutine);
end;

function _WSARecvDisconnect (s: TSocket; lpInboundDisconnectData: LPWSABUF;
  lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.WSARecvDisconnect (s, lpInboundDisconnectData);
end;

function _WSARecvFrom (s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD;
  lpNumberOfBytesRecvd: LPDWORD; lpFlags: LPDWORD; lpFrom: PSockAddr;
  lpFromlen: PInteger; lpOverlapped: LPWSAOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE;
  lpThreadId: LPWSATHREADID; lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.WSARecvFrom(s, lpBuffers, dwBufferCount,
         lpNumberOfBytesRecvd^, lpFlags^, lpFrom, lpFromlen, lpOverlapped,
         lpCompletionRoutine);
end;

function _WSASelect (nfds: integer; readfds, writefds, exceptfds: PFDSet;
  timeout: PTimeval; lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.select(nfds, readfds, writefds, exceptfds, timeout);
     lpErrno^ := WSAGetLastError;
end;

function _WSASend (s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD;
  lpNumberOfBytesSent: LPDWORD; dwFlags: DWORD; lpOverlapped: LPWSAOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE;
  lpThreadId: LPWSATHREADID; lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.WSASend (s, lpBuffers, dwBufferCount,
         lpNumberOfBytesSent^, dwFlags, lpOverlapped, lpCompletionRoutine);
end;

function _WSASendDisconnect (s: TSocket; lpOutboundDisconnectData: LPWSABUF;
  lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.WSASendDisconnect(s, lpOutboundDisconnectData);
end;

function _WSASendTo (s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD;
  lpNumberOfBytesSent: LPDWORD; dwFlags: DWORD; const lpTo : PSockAddr;
  iTolen: integer; lpOverlapped: LPWSAOVERLAPPED;
  lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE;
  lpThreadId: LPWSATHREADID; lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.WSASendTo (s, lpBuffers, dwBufferCount,
             lpNumberOfBytesSent^, dwFlags, lpTo, iTolen, lpOverlapped,
             lpCompletionRoutine);
end;

function _WSASetSockOpt (s: TSocket; level: integer; optname: integer;
  const optval: Pointer; optlen: integer; lpErrno: PInteger): integer;  stdcall;
begin
     result := winsock2.setsockopt (s, level, optname, optval, optlen);
end;

function _WSAShutdown (s: TSocket; how: integer; lpErrno: PInteger): integer; stdcall;
begin
     result := winsock2.shutdown (s, how);
end;

function _WSAEventSelect( s : TSocket; hEventObject : WSAEVENT; lNetworkEvents : LongInt; lpErrno: PInteger ): Integer; stdcall;
begin
     result := winsock2.WSAEventSelect(s, hEventObject, lNetworkEvents);
end;


{ Unicode version of WSASocket !!!}
function _WSASocket (af: integer; type_: integer; protocol: integer;
  lpProtocolInfo: LPWSAPROTOCOL_INFOW; g: GROUP; dwFlags: DWORD;
  lpErrno: PInteger): TSocket; stdcall;
begin
     result := winsock2.WSASocketW(af, type_, protocol, lpProtocolInfo, g, dwFlags);
end;


procedure Init;
var
   hMod: HMODULE;
   startupdir: string;
   GetProxyInterface: function (upCall: TFreeCapIntf): TWSockIntf; stdcall;
begin
     with MineIntf, MineIntf.WSockUpcall do
     begin
          pLogMessage := @pLogger;

          pResolve  := @stub_Resolve;
          pResolveIP := @stub_ResolveIP;
          pIsPseudoAddr := @stub_IsPseudoAddr;
          pFindhost := @stub_Findhost;

          pWSAAccept := @_WSAAccept;
          pWSAAsyncSelect := @_WSAAsyncSelect;
          pWSACancelBlockingCall := @_WSACancelBlockingCall;
          pWSACleanup := @_WSACleanup;
          pWSACloseSocket := @_WSACloseSocket;
          pWSAConnect := @_WSAConnect;
          pWSAGetPeerName := @_WSAGetPeerName;
          pWSAGetSockName := @_WSAGetSockName;
          pWSABind := @_WSABind;
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
          pAllocSocket := nil;
          pOnStartup := nil;
          pOnFinish := nil;
          pOnReload := nil;
     end;

     startupdir := GetStartupDir() + 'proxy32.dll';

     hMod := LoadLibrary(PChar(startupdir));

     if (hMod <> 0) then
     begin
          @GetProxyInterface := GetProcAddress(hMod, 'GetProxyInterface');
          ProxyIntf := GetProxyInterface(MineIntf);

          if (@ProxyIntf.pOnStartup <> nil) then
             ProxyIntf.pOnStartup(False);
     end
     else
         DisplayMessage('Unable to locate proxy32.dll!'#13#10'FreeCapStartupDir: "' + startupdir + '"');

end;

procedure Fini;
begin
    if (@ProxyIntf.pOnFinish <> nil) then
      ProxyIntf.pOnFinish();
end;


end.
