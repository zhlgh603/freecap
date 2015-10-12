{*
 * File: ...................... ws_hook.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Hook and handle the Winsock functions

 $Id: ws_hook.pas,v 1.8 2005/12/19 06:09:02 bert Exp $

 $Log: ws_hook.pas,v $
 Revision 1.8  2005/12/19 06:09:02  bert
 *** empty log message ***
}
unit ws_hook;

interface
uses Windows, Sysutils, loger, syncobjs, winsock2, common, misc, cfg,
     dns, stub, {$IFDEF DEBUG}JclDebug, {$ENDIF} plugin_disp, plugin;

type
    THookedFunction = record
       fnOrig  : Pointer;
       fnNew   : Pointer;
       fnName  : PChar;
       fnModule: PChar;
    end;

    procedure PrepareWSockHooks();
    procedure InstallWSockHooks(strModule: string);
    procedure InstallWSockHooks2(hMod: HMODULE);

    function GetHookedProc(fnName: string; fnOrig: Pointer): Pointer;

    function Hook_closesocket( const s: TSocket ): Integer; stdcall;
    function Hook_bind( const s: TSocket; const addr: PSockAddr; const namelen: Integer ): Integer; stdcall;
    function Hook_connect( const s: TSocket; const name: PSockAddr; namelen: Integer): Integer; stdcall;
    function Hook_ioctlsocket( const s: TSocket; const cmd: DWORD; var arg: u_long ): Integer; stdcall;
    function Hook_getpeername( const s: TSocket; var name: TSockAddr; var namelen: Integer ): Integer; stdcall;
    function Hook_getsockname( const s: TSocket; var name: TSockAddr; var namelen: Integer ): Integer; stdcall;
    function Hook_getsockopt( const s: TSocket; const level, optname: Integer; optval: PChar; var optlen: Integer ): Integer; stdcall;
    function Hook_recv(s: TSocket; Buf: Pointer; len, flags: Integer): Integer; stdcall;
    function Hook_recvfrom(s: TSocket; Buf: Pointer; len, flags: Integer; var from: TSockAddr; var fromlen: Integer): Integer; stdcall;
    function Hook_select(nfds: Integer; readfds, writefds, exceptfds: PFDSet; timeout: PTimeVal): Integer; stdcall;
    function Hook_send(s: TSocket; Buf: Pointer; len, flags: Integer): Integer; stdcall;
    function Hook_sendto(s: TSocket; Buf: Pointer; len, flags: Integer; var addrto: TSockAddr; tolen: Integer): Integer; stdcall;
    function Hook_setsockopt(s: TSocket; level, optname: Integer; optval: PChar; optlen: Integer): Integer; stdcall;
    function Hook_shutdown(s: TSocket; how: Integer): Integer; stdcall;
    function Hook_socket( const af, struct, protocol: Integer ): TSocket; stdcall;
    function Hook_gethostbyname(name: PChar): PHostEnt; stdcall;
    function Hook_WSAStartup(wVersionRequired: word; var WSData: TWSAData): Integer; stdcall;
    function Hook_WSACleanup: Integer; stdcall;
    function Hook_WSAEventSelect( s : TSocket; hEventObject : WSAEVENT; lNetworkEvents : LongInt ): Integer; stdcall;
    function Hook_WSAGetLastError: Integer; stdcall;

    function Hook_WSAAsyncGetHostByName(HWindow: HWND; wMsg: u_int; name: PChar; buf: PHostEnt; buflen: Integer): THandle; stdcall;
    function Hook_WSAAsyncSelect(s: TSocket; HWindow: HWND; wMsg: u_int; lEvent: Longint): Integer; stdcall;
    function Hook_WSAAccept( s : TSocket; addr : TSockAddr; addrlen : PInteger; lpfnCondition : LPCONDITIONPROC; dwCallbackData : DWORD ): TSocket; stdcall;
    function Hook_WSAConnect( s : TSocket; const name : PSockAddr; namelen : Integer; lpCallerData,lpCalleeData : LPWSABUF; lpSQOS,lpGQOS : LPQOS ) : Integer; stdcall;
    function Hook_WSAIoctl( s : TSocket; dwIoControlCode : DWORD; lpvInBuffer : Pointer; cbInBuffer : DWORD; lpvOutBuffer : Pointer; cbOutBuffer : DWORD; lpcbBytesReturned : LPDWORD; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ) : Integer; stdcall;
    function Hook_WSARecv( s : TSocket; lpBuffers : LPWSABUF; dwBufferCount : DWORD; var lpNumberOfBytesRecvd : DWORD; var lpFlags : DWORD; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ): Integer; stdcall;
    function Hook_WSARecvDisconnect( s : TSocket; lpInboundDisconnectData : LPWSABUF ): Integer; stdcall;
    function Hook_WSARecvFrom( s : TSocket; lpBuffers : LPWSABUF; dwBufferCount : DWORD; var lpNumberOfBytesRecvd : DWORD; var lpFlags : DWORD; lpFrom : PSockAddr; lpFromlen : PInteger; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ): Integer; stdcall;
    function Hook_WSASend( s : TSocket; lpBuffers : LPWSABUF; dwBufferCount : DWORD; var lpNumberOfBytesSent : DWORD; dwFlags : DWORD; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ): Integer; stdcall;
    function Hook_WSASendDisconnect( s : TSocket; lpOutboundDisconnectData : LPWSABUF ): Integer; stdcall;
    function Hook_WSASendTo( s : TSocket; lpBuffers : LPWSABUF; dwBufferCount : DWORD; var lpNumberOfBytesSent : DWORD; dwFlags : DWORD; lpTo : PSockAddr; iTolen : Integer; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ): Integer; stdcall;
    function Hook_WSASocketA( af, iType, protocol : Integer; lpProtocolInfo : LPWSAProtocol_InfoA; g : GROUP; dwFlags : DWORD ): TSocket; stdcall;
    function Hook_WSASocketW( af, iType, protocol : Integer; lpProtocolInfo : LPWSAProtocol_InfoW; g : GROUP; dwFlags : DWORD ): TSocket; stdcall;

    function Hook_getaddrinfo(nodename, servname: PChar; hints: PAddrInfo; res: PPAddrInfo): integer; stdcall;
    procedure Hook_freeaddrinfo(ai: PAddrInfo); stdcall;

const
     WINSOCKLIB = 'wsock32.dll';
     SYNC_CONNECT_MUTEX = 'FreeCap$MUTEX$CONNECT';


var
    HookedFunctions : array[0..34]  of THookedFunction = (
    (fnOrig : nil; fnNew: @Hook_bind; fnName: 'bind'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_closesocket; fnName: 'closesocket'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_connect; fnName: 'connect'; fnModule: WINSOCKLIB),

    (fnOrig : nil; fnNew: @Hook_ioctlsocket; fnName: 'ioctlsocket'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_getpeername; fnName: 'getpeername'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_getsockname; fnName: 'getsockname'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_getsockopt; fnName: 'getsockopt'; fnModule: WINSOCKLIB),


    (fnOrig : nil; fnNew: @Hook_recv; fnName: 'recv'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_recvfrom; fnName: 'recvfrom'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_select; fnName: 'select'; fnModule: WINSOCKLIB),

    (fnOrig : nil; fnNew: @Hook_send; fnName: 'send'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_sendto; fnName: 'sendto'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_setsockopt; fnName: 'setsockopt'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_shutdown; fnName: 'shutdown'; fnModule: WINSOCKLIB),

    (fnOrig : nil; fnNew: @Hook_socket; fnName: 'socket'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_gethostbyname; fnName: 'gethostbyname'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_WSAGetLastError; fnName: 'WSAGetLastError'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_WSAStartup; fnName: 'WSAStartup'; fnModule: WINSOCKLIB),
    (fnOrig : nil; fnNew: @Hook_WSACleanup; fnName: 'WSACleanup'; fnModule: WINSOCKLIB),

    (fnOrig : nil; fnNew: @Hook_WSAAsyncGetHostByName; fnName: 'WSAAsyncGetHostByName'; fnModule: 'ws2_32.dll'),
    (fnOrig : nil; fnNew: @Hook_getaddrinfo; fnName: 'getaddrinfo'; fnModule: 'ws2_32.dll'),
    (fnOrig : nil; fnNew: @Hook_freeaddrinfo; fnName: 'freeaddrinfo'; fnModule: 'ws2_32.dll'),
    (fnOrig : nil; fnNew: @Hook_WSARecv; fnName: 'WSARecv'; fnModule: 'ws2_32.dll'),

    (fnOrig : nil; fnNew: @Hook_WSARecvFrom; fnName: 'WSARecvFrom'; fnModule: 'ws2_32.dll'),
    (fnOrig : nil; fnNew: @Hook_WSASend; fnName: 'WSASend'; fnModule: 'ws2_32.dll'),
    (fnOrig : nil; fnNew: @Hook_WSASendTo; fnName: 'WSASendTo'; fnModule: 'ws2_32.dll'),
    (fnOrig : nil; fnNew: @Hook_WSAAsyncSelect; fnName: 'WSAAsyncSelect'; fnModule: 'ws2_32.dll'),

    (fnOrig : nil; fnNew: @Hook_WSAConnect; fnName: 'WSAConnect'; fnModule: 'ws2_32.dll'),
    (fnOrig : nil; fnNew: @Hook_WSASocketA; fnName: 'WSASocketA'; fnModule: 'ws2_32.dll'),
    (fnOrig : nil; fnNew: @Hook_WSASocketW; fnName: 'WSASocketW'; fnModule: 'ws2_32.dll'),
    (fnOrig : nil; fnNew: @Hook_WSAAccept; fnName: 'WSAAccept'; fnModule: 'ws2_32.dll'),
    (fnOrig : nil; fnNew: @Hook_WSAEventSelect; fnName: 'WSAEventSelect'; fnModule: 'ws2_32.dll'),

    (fnOrig : nil; fnNew: @Hook_WSAIoctl; fnName: 'WSAIoctl'; fnModule: 'ws2_32.dll'),
    (fnOrig : nil; fnNew: @Hook_WSARecvDisconnect; fnName: 'WSARecvDisconnect'; fnModule: 'ws2_32.dll'),
    (fnOrig : nil; fnNew: @Hook_WSASendDisconnect; fnName: 'WSASendDisconnect'; fnModule: 'ws2_32.dll')
     );

implementation
uses hook, hook_func, helpwnd;

var
   has_sent : Boolean = False;
   last_connect: integer = -1;


function Hook_bind(const s: TSocket; const addr: PSockAddr; const namelen: Integer ): Integer; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSABind(s, addr, namelen, @RetErr);
     Log(LOG_LEVEL_CONN, 'binding to (%s, %d) = %d...',[GetDottedIP(addr^.sin_addr.S_addr), ntohs(addr^.sin_port), result]);
end;

function Hook_getsockname( const s: TSocket; var name: TSockAddr; var namelen: Integer ): Integer; stdcall;
var
   RetErr: DWORD;
begin

     result := ProxyIntf.pWSAGetSockName(s, @name, @namelen, @RetErr);
end;


function Hook_closesocket( const s: TSocket ): Integer; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSACloseSocket(s, @RetErr);
end;

function Hook_connect(const s: TSocket; const name: PSockAddr; namelen: Integer): Integer; stdcall;
var
   Dummy: LPWSABUF;
begin
     Dummy[0] := nil;
     result := Hook_WSAConnect(s, name, namelen, Dummy, Dummy, nil, nil);
end;

function Hook_ioctlsocket( const s: TSocket; const cmd: DWORD; var arg: u_long ): Integer; stdcall;
var
   DontCare: DWORD;
begin
     result := Hook_WSAIoctl(s, cmd, @arg, sizeof(u_long), @arg,
         sizeof(u_long), @DontCare, nil, nil);
end;

function Hook_getpeername( const s: TSocket; var name: TSockAddr; var namelen: Integer ): Integer; stdcall;
var
   retErr: DWORD;
begin
     result := ProxyIntf.pWSAGetPeerName(s, @name, @namelen, @retErr);
end;


function Hook_getsockopt( const s: TSocket; const level, optname: Integer; optval: PChar; var optlen: Integer ): Integer; stdcall;
var
   retErr: DWORD;
begin
     result := ProxyIntf.pWSAGetSockOpt(s, level, optname, optval, @optlen, @retErr);
end;


function Hook_recv(s: TSocket; Buf: Pointer; len, flags: Integer): Integer; stdcall;
var
   res: Integer;
   Buffer: WSABUF;
begin
     Buffer.len := len;
     Buffer.buf := Buf;
     res := Hook_WSARecv (s, LPWSABUF(@Buffer), 1, DWORD(result), DWORD(flags), nil, nil);

     Move(Buffer.buf^, Buf^, len);

     if res <> 0 then
     begin
          result := -1;
          SetLastError(WSAEWOULDBLOCK);
     end;
end;

function Hook_recvfrom(s: TSocket; Buf: Pointer; len, flags: Integer; var from: TSockAddr; var fromlen: Integer): Integer; stdcall;
var
   res: Integer;
   Buffer: WSABUF;
begin
     Buffer.len := len;
     Buffer.buf := Buf;
     res := Hook_WSARecvFrom (s, LPWSABUF(@Buffer), 1, DWORD(result), DWORD(flags), @from, @fromlen, nil, nil);
     if res <> 0 then
     begin
          result := -1;
          SetLastError(WSAEWOULDBLOCK);
     end;
end;

function Hook_select(nfds: Integer; readfds, writefds, exceptfds: PFDSet; timeout: PTimeVal): Integer; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSASelect(nfds, readfds, writefds, exceptfds, timeout, @RetErr);
//     log(LOG_LEVEL_CONN, 'select = %d', [result]);
end;

function Hook_send(s: TSocket; Buf: Pointer; len, flags: Integer): Integer; stdcall;
var
   res: DWORD;
   Buffer: WSABUF;
begin
     Buffer.len := len;
     Buffer.buf := Buf;

     result := Hook_WSASend(s, LPWSABUF(@Buffer), 1, res, flags, nil, nil);
     if (result = ERROR_SUCCESS) then
     begin
          result := res;
          exit;
     end;
     result := SOCKET_ERROR;
end;

function Hook_sendto(s: TSocket; Buf: Pointer; len, flags: Integer; var addrto: TSockAddr; tolen: Integer): Integer; stdcall;
var
   res: DWORD;
   Buffer: WSABUF;
begin
     Buffer.len := len;
     Buffer.buf := Buf;
     result := Hook_WSASendTo(s, LPWSABUF(@Buffer), 1, res, flags, @addrto, tolen, nil, nil);
     if (result = ERROR_SUCCESS) then
     begin
          result := res;
          exit;
     end;
     result := SOCKET_ERROR;
end;

function Hook_setsockopt(s: TSocket; level, optname: Integer; optval: PChar; optlen: Integer): Integer; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSASetSockOpt(s, level, optname, optval, optlen, @RetErr);
end;

function Hook_shutdown(s: TSocket; how: Integer): Integer; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSAShutdown(s, how, @RetErr);
end;

function Hook_socket( const af, struct, protocol: Integer ): TSocket; stdcall;
var
   OpenType, flag: DWORD;
   optlen: integer;
begin
     OpenType := DWORD(0);

     getsockopt(INVALID_SOCKET, SOL_SOCKET, SO_OPENTYPE, @OpenType, optLen);

     if (OpenType = 0) then
        flag := WSA_FLAG_OVERLAPPED
     else
        flag := 0;

     result := Hook_WSASocketA(af, struct, protocol, nil, 0, flag);
end;

function Hook_WSAGetLastError: Integer; stdcall;
begin
     result := WSAGetLastError;
//     LOG(LOG_LEVEL_DEBUG, '%s = %d', [__PROC__, result]);
//     log(LOG_LEVEL_CONN, 'WSAGetLastError = %d', [result]);
end;


function Hook_WSAStartup(wVersionRequired: word; var WSData: TWSAData): Integer; stdcall;
begin
     result := WSAStartup(wVersionRequired, WSData);
     Log(LOG_LEVEL_CONN, 'WSAStartup (%d): ',[wVersionRequired]);
     Log(LOG_LEVEL_CONN, '     wVersion       : %d',[WSData.wVersion]);
     Log(LOG_LEVEL_CONN, '     wHighVersion   : %d',[WSData.wHighVersion]);
     Log(LOG_LEVEL_CONN, '     szDescription  : %s',[WSData.szDescription]);
     Log(LOG_LEVEL_CONN, '     szSystemStatus : %s',[WSData.szSystemStatus]);
     Log(LOG_LEVEL_CONN, '     iMaxSockets    : %d',[WSData.iMaxSockets]);
     Log(LOG_LEVEL_CONN, '     iMaxUdpDg      : %d',[WSData.iMaxUdpDg]);
end;

function Hook_WSACleanup: Integer; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSACleanup(@RetErr);
end;

function Hook_WSAEventSelect( s : TSocket; hEventObject : WSAEVENT; lNetworkEvents : LongInt ): Integer; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSAEventSelect(s, hEventObject, lNetworkEvents, @RetErr)
end;

function Hook_WSAAsyncSelect(s: TSocket; HWindow: HWND; wMsg: u_int; lEvent: Longint): Integer; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSAAsyncSelect(s, HWindow, wMsg, lEvent, @RetErr);
end;


function Hook_WSAAccept( s : TSocket; addr : TSockAddr; addrlen : PInteger; lpfnCondition : LPCONDITIONPROC; dwCallbackData : DWORD ): TSocket; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSAAccept(s, addr, addrlen^, lpfnCondition, dwCallbackData, @RetErr);
end;


function Hook_WSAConnect( s : TSocket; const name : PSockAddr; namelen : Integer; lpCallerData,lpCalleeData : LPWSABUF; lpSQOS,lpGQOS : LPQOS ) : Integer; stdcall;
var
   RetErr: DWORD;
   DestAddr: string;
begin
     DestAddr := GetAddrString(name^.sin_addr.S_addr);
     if (PluginDisp.InvokeConnect(GetProcessName(GetCurrentProcessId), DestAddr) = -1) then
     begin
          Result := -1;
          SetLastError(WSAECONNREFUSED);
          exit;
     end;

     name^.sin_addr.S_addr := resolve(DestAddr);
     result := ProxyIntf.pWSAConnect(s, name, namelen, lpCallerData, lpCalleeData, lpSQOS, lpGQOS, @RetErr);
end;


function Hook_WSAIoctl( s : TSocket; dwIoControlCode : DWORD; lpvInBuffer : Pointer; cbInBuffer : DWORD; lpvOutBuffer : Pointer; cbOutBuffer : DWORD; lpcbBytesReturned : LPDWORD; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ) : Integer; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSAIoctl(s, dwIoControlCode, lpvInBuffer, cbInBuffer,
         lpvOutBuffer, cbOutBuffer, lpcbBytesReturned,
         lpOverlapped, lpCompletionRoutine, nil, @RetErr);
end;


function Hook_WSARecv( s : TSocket; lpBuffers : LPWSABUF; dwBufferCount : DWORD; var lpNumberOfBytesRecvd : DWORD; var lpFlags : DWORD; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ): Integer; stdcall;
var
   RetErr: DWORD;
   RecvLen, DstAddrSize: integer;
   buffer: TBuffer;
   DstAddr: TSockAddrIn;
begin
     ZeroMemory(@DstAddr, SizeOf(DstAddr));
     DstAddrSize := SizeOf(DstAddr);
     ProxyIntf.pWSAGetPeerName(s, @DstAddr, @DstAddrSize, @RetErr);

     result := ProxyIntf.pWSARecv(s , lpBuffers, dwBufferCount, @lpNumberOfBytesRecvd, @lpFlags, lpOverlapped,
         lpCompletionRoutine, nil, @RetErr);

     if (result = 0) then // Data has been arrived to socket
     begin
          ZeroMemory(@buffer, SIzeOf(buffer));
          Move(lpBuffers[0]^.buf^, buffer[0], lpBuffers[0]^.len);

          RecvLen := PluginDisp.InvokeRecv(GetProcessName(GetCurrentProcessId), @DstAddr, @buffer, lpNumberOfBytesRecvd);

          if (RecvLen <> -1) then
          begin
               if RecvLen <= Integer(lpBuffers[0]^.len) then
                 Move(buffer[0], lpBuffers[0].buf^, RecvLen);
               lpNumberOfBytesRecvd := RecvLen;
          end;
     end;
end;

function Hook_WSARecvDisconnect( s : TSocket; lpInboundDisconnectData : LPWSABUF ): Integer; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSARecvDisconnect(s, lpInboundDisconnectData, @RetErr);
end;

function Hook_WSARecvFrom( s : TSocket; lpBuffers : LPWSABUF; dwBufferCount : DWORD; var lpNumberOfBytesRecvd : DWORD; var lpFlags : DWORD; lpFrom : PSockAddr; lpFromlen : PInteger; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ): Integer; stdcall;
var
   RetErr: DWORD;
begin
//     LOG(LOG_LEVEL_DEBUG, '%s (lpBuffers = %p, lpFlags = %d; lpFrom = %p; lpFromlen = %p)', [__PROC__, lpBuffers[0], lpFlags, lpFrom, lpFromlen]);

     if (lpFrom = nil) or (lpFromlen = nil) then
     begin
          result := WSARecvFrom(s, lpBuffers, dwBufferCount, lpNumberOfBytesRecvd, lpFlags, lpFrom,
             lpFromlen, lpOverlapped, lpCompletionRoutine);
     end
     else
       result := ProxyIntf.pWSARecvFrom(s, lpBuffers, dwBufferCount, @lpNumberOfBytesRecvd, @lpFlags, lpFrom,
           lpFromlen, lpOverlapped, lpCompletionRoutine, nil, @RetErr);
end;

function Hook_WSASend( s : TSocket; lpBuffers : LPWSABUF; dwBufferCount : DWORD; var lpNumberOfBytesSent : DWORD; dwFlags : DWORD; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ): Integer; stdcall;
var
   RetErr: DWORD;
   OrigLen, DstAddrSize: integer;
   buffer: TBuffer;
   DstAddr: TSockAddrIn;
begin
     ZeroMemory(@buffer, SIzeOf(buffer));
     OrigLen := lpBuffers[0]^.len;

     Move(lpBuffers[0]^.buf^, buffer[0], lpBuffers[0]^.len);

     DstAddrSize := SizeOf(DstAddr);
     ProxyIntf.pWSAGetPeerName(s, @DstAddr, @DstAddrSize, @RetErr);

     lpBuffers[0]^.len := PluginDisp.InvokeSend(GetProcessName(GetCurrentProcessId), @DstAddr, @buffer, lpBuffers[0]^.len);
     lpBuffers[0]^.buf := @buffer;

     result := ProxyIntf.pWSASend(s, lpBuffers, dwBufferCount, @lpNumberOfBytesSent,
         dwFlags, lpOverlapped, lpCompletionRoutine, nil, @RetErr);

     if lpNumberOfBytesSent = lpBuffers[0]^.len then
       lpNumberOfBytesSent := OrigLen;
end;

function Hook_WSASendDisconnect( s : TSocket; lpOutboundDisconnectData : LPWSABUF ): Integer; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSASendDisconnect(s, lpOutboundDisconnectData, @RetErr);
end;

function Hook_WSASendTo( s : TSocket; lpBuffers : LPWSABUF; dwBufferCount : DWORD; var lpNumberOfBytesSent : DWORD; dwFlags : DWORD; lpTo : PSockAddr; iTolen : Integer; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ): Integer; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSASendTo(s, lpBuffers, dwBufferCount, @lpNumberOfBytesSent, dwFlags,
         lpTo, iTolen, lpOverlapped, lpCompletionRoutine, nil, @RetErr);
end;


function MapAnsiProtocolInfoToUnicode(AnsiProtocolInfo: LPWSAPROTOCOL_INFOA;
   UnicodeProtocolInfo: LPWSAPROTOCOL_INFOW): Integer;
begin
     if AnsiProtocolInfo = nil then
     begin
          UnicodeProtocolInfo := nil;
          result := 0;
          exit;
     end;

     Move(AnsiProtocolInfo^, UnicodeProtocolInfo, sizeof(AnsiProtocolInfo^) - sizeof(AnsiProtocolInfo^.szProtocol));
     result := MultiByteToWideChar(
                 CP_ACP,                                    // CodePage (ANSI)
                 0,                                         // dwFlags
                 AnsiProtocolInfo^.szProtocol,              // lpMultiByteStr
                 -1,                                        // cchWideChar
                 UnicodeProtocolInfo^.szProtocol,           // lpWideCharStr
                 sizeof(UnicodeProtocolInfo^.szProtocol)    // cchMultiByte
                 );
end;

function Hook_WSASocketA(af, iType, protocol : Integer; lpProtocolInfo : LPWSAProtocol_InfoA; g : GROUP; dwFlags : DWORD ): TSocket; stdcall;
var
   ProtocolInfoW: TWSAPROTOCOL_INFOW;
begin
     if lpProtocolInfo <> nil then
     begin
          MapAnsiProtocolInfoToUnicode(lpProtocolInfo, @ProtocolInfoW);
          result := Hook_WSASocketW(af, iType, protocol, @ProtocolInfoW, g, dwFlags);
     end
     else
         result := Hook_WSASocketW(af, iType, protocol, nil, g, dwFlags);

end;




function Hook_WSASocketW( af, iType, protocol : Integer; lpProtocolInfo : LPWSAProtocol_InfoW; g : GROUP; dwFlags : DWORD ): TSocket; stdcall;
var
   RetErr: DWORD;
begin
     result := ProxyIntf.pWSASocket(af, iType, protocol, lpProtocolInfo, g, dwFlags, @RetErr);
end;




{* DNS stuff *}
function Hook_getaddrinfo(nodename, servname: PChar; hints: PAddrInfo; res: PPAddrInfo): integer; stdcall;
begin

     result := my_getaddrinfo(nodename, servname, hints, res);
     Log(LOG_LEVEL_CONN, 'getaddrinfo(%s) = %d', [nodename, result]);
end;

procedure Hook_freeaddrinfo(ai: PAddrInfo); stdcall;
begin

     Log(LOG_LEVEL_CONN, 'freeaddrinfo',[]);
     my_freeaddrinfo(ai);
end;

function Hook_gethostbyname(name: PChar): PHostEnt; stdcall;
var
   ph: PHostAddr;
   nm: string;
begin


     result := my_gethostbyname(name);

     if (result <> nil) then
     begin
          if name = nil then
             nm := 'nil'
          else
             nm := name;

          ph := PHostAddr(result^.h_addr_list^);
          if (ph <> nil) then
             Log(LOG_LEVEL_CONN, 'gethostbyname (%s) = %s', [nm, GetDottedIP(DWORD(ph^))])
          else
             Log(LOG_LEVEL_CONN, 'gethostbyname (%s) = nil', [nm]);
     end
     else
          Log(LOG_LEVEL_CONN, 'gethostbyname (%s) = nil', [nm]);
end;

function Hook_WSAAsyncGetHostByName(HWindow: HWND; wMsg: u_int; name: PChar; buf: PHostEnt; buflen: Integer): THandle; stdcall;
var
   buf1: PHostEnt;
   ph: PHostAddr;
begin


     result := 0;

     if (prog_resolve_dns = 0) then
       result := WSAAsyncGetHostByName(HWindow, wMsg, name, buf, buflen)
     else if (prog_resolve_dns = 1) then
     begin
          result := WSAAsyncGetHostByName(HWindow, wMsg, name, buf, buflen);
          if result = 0 then
          begin
               result := 2;
               buf1 := my_gethostbyname(name);

               if (buf1 <> nil) then
               begin
                    Move(buf1^, buf^, SizeOf(THostEnt));
                    ph := PHostAddr(buf1^.h_addr_list^);
                    if (ph <> nil) then
                      Log(LOG_LEVEL_CONN, 'WSAAsyncGetHostByName (%s) = %s', [name, GetDottedIP(DWORD(ph^))])
                    else
                      Log(LOG_LEVEL_CONN, 'WSAAsyncGetHostByName(%s) = nil', [name]);
               end
               else
               begin
                    Log(LOG_LEVEL_CONN, 'WSAAsyncGetHostByName(%s) = nil', [name]);
               end;
               PostMessage(HWindow, wMsg, result, buflen);
          end;
     end
     else if (prog_resolve_dns = 2) then
     begin
          result := 2;
          buf1 := my_gethostbyname(name);

          if (buf1 <> nil) then
          begin
               Move(buf1^, buf^, SizeOf(THostEnt));
               ph := PHostAddr(buf1^.h_addr_list^);
               if (ph <> nil) then
                 Log(LOG_LEVEL_CONN, 'WSAAsyncGetHostByName (%s) = %s', [name, GetDottedIP(DWORD(ph^))])
               else
                 Log(LOG_LEVEL_CONN, 'WSAAsyncGetHostByName(%s) = nil', [name]);
          end
          else
          begin
               Log(LOG_LEVEL_CONN, 'WSAAsyncGetHostByName(%s) = nil', [name]);
          end;
          PostMessage(HWindow, wMsg, result, buflen);
     end;

end;


{ * * * * * *  * * * * * *  * * * * * *  * * * * * *  * * * * * *  * * * * * * }
{ * * * * * *  * * * * * *  * * * * * *  * * * * * *  * * * * * *  * * * * * * }

{* Init our hook table with "real" function addresses
 *}
procedure PrepareWSockHooks();
var
   Import_ws2: Boolean;
   Import_ws: Boolean;

   i: integer;
   ws2h: HMODULE;
begin
     i := 0;
     Import_ws2 := IsImported(GetModuleHandle(nil), 'ws2_32.dll');
     Import_ws := IsImported(GetModuleHandle(nil), 'wsock32.dll');
     ws2h := GetModuleHandle('ws2_32.dll');

     while i <= High(HookedFunctions) do
     begin
          if isWin9x then
          begin
               HookedFunctions[i].fnOrig := GetRealAddress(GetProcAddress(GetModuleHandle(HookedFunctions[i].fnModule), PChar(HookedFunctions[i].fnName)));
//               if HookedFunctions[i].fnOrig = nil then
//                 HookedFunctions[i].fnOrig := GetRealAddress(GetProcAddress(GetModuleHandle('ws2_32.dll'), PChar(HookedFunctions[i].fnName)))
          end
          else
          begin
               if Import_ws2 and not Import_ws then
                 HookedFunctions[i].fnOrig := GetRealAddress(GetProcAddress(ws2h, PChar(HookedFunctions[i].fnName)))
               else
                 HookedFunctions[i].fnOrig := GetRealAddress(GetProcAddress(GetModuleHandle(HookedFunctions[i].fnModule), PChar(HookedFunctions[i].fnName)));
          end;

          if (HookedFunctions[i].fnOrig = nil) then
          begin
               if (not isWinXP) and (HookedFunctions[i].fnName <> 'getaddrinfo') and (HookedFunctions[i].fnName <> 'freeaddrinfo') then
                 Log(LOG_LEVEL_WARN, 'PrepareWSockHooks() !!!ERROR!!! I failed to get function %s from %s!!!',[HookedFunctions[i].fnName, HookedFunctions[i].fnModule]);
          end;
          inc(i);
     end;
end;

{* Install winsock hooks of module strModule (can be wsock32.dll or ws2_32.dll)
 *}
procedure InstallWSockHooks(strModule: string);
var
   i: integer;
   Import_ws, Import_ws2, bWin9x: Boolean;
begin
     Import_ws := IsImported(GetModuleHandle(nil), 'wsock32.dll');

     Import_ws2 := IsImported(GetModuleHandle(nil), 'ws2_32.dll');

     bWin9x := isWin9x();

     for i:=0 to High(HookedFunctions) do
     begin
          if HookedFunctions[i].fnOrig <> nil then
          begin
               if bWin9x then
               begin
                    HookedFunctions[i].fnOrig := InstallHook(HookedFunctions[i].fnModule, HookedFunctions[i].fnName, HookedFunctions[i].fnNew);
//                    if HookedFunctions[i].fnOrig = nil then
//                       HookedFunctions[i].fnOrig := InstallHook('ws2_32.dll', HookedFunctions[i].fnName, HookedFunctions[i].fnNew)
               end
               else
               begin
                    if Import_ws2 and not Import_ws then
                      HookedFunctions[i].fnOrig := InstallHook('ws2_32.dll', HookedFunctions[i].fnName, HookedFunctions[i].fnNew)
                    else
                      HookedFunctions[i].fnOrig := InstallHook(HookedFunctions[i].fnModule, HookedFunctions[i].fnName, HookedFunctions[i].fnNew)
               end;
          end
          else
          begin
               if (not isWinXP) and (HookedFunctions[i].fnName <> 'getaddrinfo') and (HookedFunctions[i].fnName <> 'freeaddrinfo') then
                 Log(LOG_LEVEL_WARN, 'InstallWSockHooks() !!!ERROR!!! I failed to install function %s in %s!!!',[HookedFunctions[i].fnName, HookedFunctions[i].fnModule]);
          end;
     end;
end;


procedure InstallWSockHooks2(hMod: HMODULE);
var
   i: integer;
   Import_wsock : Boolean;
   Import_ws2: Boolean;
   num_hooks: integer;
begin
     num_hooks := 0;
     Import_wsock := IsImported(hMod, 'wsock32.dll');
     Import_ws2 := IsImported(hMod, 'ws2_32.dll');

     if (not Import_wsock) and (not Import_ws2) then exit;


     for i:=0 to High(HookedFunctions) do
     begin
          if HookedFunctions[i].fnOrig <> nil then
          begin
               if Import_wsock then
                 inc(num_hooks, ReplaceIATEntryInOneMod('wsock32.dll', HookedFunctions[i].fnOrig, HookedFunctions[i].fnNew, hMod, True));
               if Import_ws2 then
                 inc(num_hooks, ReplaceIATEntryInOneMod('ws2_32.dll', HookedFunctions[i].fnOrig, HookedFunctions[i].fnNew, hMod, True));
          end;
     end;
     Log(LOG_LEVEL_INJ, '%d''s WinSock hooks placed', [num_hooks]);
end;


function GetHookedProc(fnName: string; fnOrig: Pointer): Pointer;
var
   i: integer;
begin
     result := nil;
     for i:=0 to High(HookedFunctions) do
     begin
          if isWin9x then
          begin
               if (fnOrig <> nil) and ((HookedFunctions[i].fnOrig = fnOrig)) then
               begin
                    result := HookedFunctions[i].fnNew;
                    exit;
               end;
          end
          else
          begin
              if (fnOrig <> nil) and ((HookedFunctions[i].fnOrig = fnOrig) or (HookedFunctions[i].fnName = fnName)) then
              begin
                   result := HookedFunctions[i].fnNew;
                   exit;
              end;
          end;
     end;
end;



end.


