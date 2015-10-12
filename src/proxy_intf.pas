{ 
  $Id: proxy_intf.pas,v 1.4 2005/08/11 05:20:36 bert Exp $

  $Log: proxy_intf.pas,v $
  Revision 1.4  2005/08/11 05:20:36  bert
  *** empty log message ***

  Revision 1.3  2005/02/15 11:21:21  bert
  *** empty log message ***

}
unit proxy_intf;

interface

uses Windows, winsock2 {$IFDEF WIDECAP}, ws2spi{$ENDIF};

type
    {$IFNDEF WIDECAP}
      LPINT = PInteger;
    {$ENDIF}

    TWSockIntf = packed record
      pWSAAccept : function (s: TSocket; var addr: TSockAddr; var addrlen: integer; lpfnCondition: LPCONDITIONPROC;
        dwCallbackData: DWORD; lpErrno: LPINT): TSocket; stdcall;
      pWSAAsyncSelect: function (s: TSOCKET; hWnd: HWND; wMsg: Word; lEvent: DWORD; lpErrno: LPINT): integer; stdcall;
      pWSABind: function (s : TSocket; const name: PSockAddr; namelen: integer; lpErrno: LPINT): integer; stdcall;
      pWSACancelBlockingCall : function  (lpErrno: LPINT): integer; stdcall;
      pWSACleanup : function (lpErrno: LPINT): integer; stdcall;
      pWSACloseSocket: function  (s: TSOCKET; lpErrno: LPINT): integer; stdcall;
      pWSAConnect : function (s: TSOCKET; const name: PSockaddr; namelen: integer; lpCallerData, lpCalleeData: LPWSABUF;
         lpSQOS, lpGQOS: LPQOS; lpErrno: LPINT): integer; stdcall;
      pWSAGetPeerName: function (s: TSocket; name: PSockAddr; namelen, lpErrno: LPINT): integer; stdcall;
      pWSAGetSockName: function (s: TSocket; name: PSockAddr; namelen, lpErrno: LPINT): integer; stdcall;
      pWSAGetSockOpt: function (s: TSocket; level, optname : integer; optval: Pointer; optlen, lpErrno: LPINT): integer; stdcall;

      pWSAEventSelect: function (s: TSocket; hEventObject: WSAEVENT; lNetworkEvents: LongInt; lpErrno: LPINT): Integer; stdcall;

      pWSAIoctl: function (s: TSocket; dwIoControlCode: DWORD; lpvInBuffer: Pointer; cbInBuffer: DWORD;
         lpvOutBuffer: Pointer; cbOutBuffer: DWORD; lpcbBytesReturned: LPDWORD; lpOverlapped: LPWSAOVERLAPPED;
         lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE; lpThreadId: LPWSATHREADID; lpErrno: LPINT): integer; stdcall;

      pWSAListen:  function (s: TSocket; backlog: integer; lpErrno: LPINT): integer; stdcall;
      pWSARecv: function (s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD; lpNumberOfBytesRecvd: LPDWORD;
         lpFlags: LPDWORD; lpOverlapped: LPWSAOVERLAPPED; lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE;
         lpThreadId: LPWSATHREADID; lpErrno: LPINT): integer; stdcall;

      pWSARecvDisconnect: function (s: TSocket; lpInboundDisconnectData: LPWSABUF;
         lpErrno: LPINT): integer; stdcall;

      pWSARecvFrom: function (s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD; lpNumberOfBytesRecvd: LPDWORD;
         lpFlags: LPDWORD; lpFrom: PSockAddr; lpFromlen: LPINT; lpOverlapped: LPWSAOVERLAPPED;
         lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE; lpThreadId: LPWSATHREADID;
         lpErrno: LPINT): integer; stdcall;

      pWSASelect: function (nfds: integer; readfds, writefds, exceptfds: PFDSet;
         timeout: PTimeval; lpErrno: LPINT): integer; stdcall;

      pWSASend: function (s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD;
         lpNumberOfBytesSent: LPDWORD; dwFlags: DWORD; lpOverlapped: LPWSAOVERLAPPED;
         lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE; lpThreadId: LPWSATHREADID;
         lpErrno: LPINT): integer; stdcall;

      pWSASendDisconnect: function (s: TSocket; lpOutboundDisconnectData: LPWSABUF;
         lpErrno: LPINT): integer; stdcall;

      pWSASendTo: function (s: TSocket; lpBuffers: LPWSABUF; dwBufferCount: DWORD;
         lpNumberOfBytesSent: LPDWORD; dwFlags: DWORD; const lpTo : PSockAddr;
         iTolen: integer; lpOverlapped: LPWSAOVERLAPPED; lpCompletionRoutine: LPWSAOVERLAPPED_COMPLETION_ROUTINE;
         lpThreadId: LPWSATHREADID; lpErrno: LPINT): integer; stdcall;

      pWSASetSockOpt: function (s: TSocket; level: integer; optname: integer;
         const optval: Pointer; optlen: integer; lpErrno: LPINT): integer; stdcall;

      pWSAShutdown: function (s: TSocket; how: integer; lpErrno: LPINT): integer; stdcall;

      pWSASocket: function (af: integer; type_: integer; protocol: integer;
         lpProtocolInfo: LPWSAPROTOCOL_INFOW; g: GROUP; dwFlags: DWORD; lpErrno: LPINT): TSocket; stdcall;

      // These procedures should be filled at the client-side

      // When host application loads, it calls this function (if it isn't nil of course)
      pOnStartup: procedure(isWideCap: Boolean); stdcall;

      // If return value other than zero proxy32.dll won't be unloaded
      pOnFinish: function: integer; stdcall;

      // Host application calls when recieved 'RELOAD' message
      pOnReload: procedure; stdcall;
   end;


    TFreeCapIntf = packed record
      // upcalls to host application
      pLogMessage: function (facility: integer; fmt: PChar; args: array of const): integer; stdcall;
      pResolve : function (host: PChar): DWORD; stdcall;
      pResolveIP: function (host: PChar): DWORD; stdcall;
      pIsPseudoAddr: function(ip: dword): Boolean; stdcall;
      pFindhost: procedure (IP: DWORD; buf: PChar; bufsize: integer); stdcall;
      pAllocSocket: function (af: integer; type_: integer; protocol: integer): TSocket; stdcall;

      // WinSock upcalls
      WSockUpcall: TWSockIntf;
    end;



implementation

end.
