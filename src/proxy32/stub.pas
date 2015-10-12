{
  $Id: stub.pas,v 1.8 2005/11/01 14:07:10 bert Exp $

  $Log: stub.pas,v $
  Revision 1.8  2005/11/01 14:07:10  bert
  *** empty log message ***

  Revision 1.7  2005/10/27 19:05:51  bert
  *** empty log message ***

  Revision 1.6  2005/04/18 04:46:23  bert
  *** empty log message ***

  Revision 1.5  2005/04/07 10:28:35  bert
  *** empty log message ***

  Revision 1.4  2005/04/06 04:58:56  bert
  *** empty log message ***

  Revision 1.3  2005/02/15 12:41:23  bert
  *** empty log message ***

  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}
unit stub;

interface
uses Windows, Winsock2, proxy_intf;

    function Stub_Bind (s : TSocket; const name: PSockAddr; namelen: integer): integer;
    function Stub_CloseSocket (s: TSocket): integer;
    function Stub_Connect (s: TSocket; const name: PSockaddr; namelen: integer): integer;
    function Stub_Recv(s: TSocket; Buf: Pointer; len, flags: Integer): Integer;
    function Stub_RecvFrom (s: TSocket; Buf: Pointer; len, flags: Integer; var from: TSockAddr; var fromlen: Integer): Integer;
    function Stub_Select (nfds: integer; readfds, writefds, exceptfds: PFDSet; timeout: PTimeval): integer;
    function Stub_Send (s: TSocket; Buf: Pointer; len, flags: Integer): Integer;
    function Stub_SendTo (s: TSocket; Buf: Pointer; len, flags: Integer; var addrto: TSockAddr; tolen: Integer): Integer;
    function Stub_SetSockOpt (s: TSocket; level, optname: Integer; optval: PChar; optlen: Integer): Integer;
    function Stub_Shutdown (s: TSocket; how: integer): integer;
    function Stub_Socket (af: integer; type_: integer; protocol: integer): TSocket;
    function Stub_ioctlsocket ( const s: TSocket; const cmd: DWORD; var arg: u_long ): Integer;
    function Stub_getsockname ( const s: TSocket; var name: TSockAddr; var namelen: Integer ): Integer;

    function SelectForRecv(S: TSocket): integer;
    function SelectForSend(S: TSocket): integer;

var
   UpcallIntf: TFreeCapIntf;

implementation
uses cfg, loger, misc;

function Stub_Bind (s : TSocket; const name: PSockAddr; namelen: integer): integer;
var
   RetErr: DWORD;
begin
     result := UpcallIntf.WSockUpcall.pWSABind(s, name, namelen, @RetErr);
end;


function Stub_getsockname ( const s: TSocket; var name: TSockAddr; var namelen: Integer ): Integer;
var
   RetErr: DWORD;
begin
     result := UpcallIntf.WSockUpcall.pWSAGetSockName(s, @name, @namelen, @RetErr);
end;


function Stub_CloseSocket (s: TSocket): integer;
var
   RetErr: DWORD;
begin
     result := UpcallIntf.WSockUpcall.pWSACloseSocket(s, @RetErr);
end;

function Stub_Connect (s: TSocket; const name: PSockaddr; namelen: integer): integer;
var
   RetErr: DWORD;
   Dummy: LPWSABUF;
begin
     Dummy[0] := nil;
     result := UpcallIntf.WSockUpcall.pWSAConnect(s, name, namelen, Dummy, Dummy, nil, nil, @RetErr);
     if result <> ERROR_SUCCESS then
     begin
          SetLastError(RetErr);
          result := SOCKET_ERROR;
     end
end;

function Stub_Recv(s: TSocket; Buf: Pointer; len, flags: Integer): Integer;
var
   RetErr, RetVal, res: DWORD;
   Buffer: WSABUF;
   ThreadId: TWSATHREADID;
begin
     Buffer.len := len;
     Buffer.buf := Buf;
     ThreadId.ThreadHandle := GetCurrentThread();
     ThreadId.Reserved := 0;

     res := 0;
     RetErr := 0;

     RetVal := UpcallIntf.WSockUpcall.pWSARecv (s, LPWSABUF(@Buffer), 1, @res,
         @flags, nil, nil, @ThreadId, @RetErr);


     if (RetVal = ERROR_SUCCESS) then
     begin
          if ((flags and MSG_PARTIAL) = 0) then
          begin
               result := integer(res);
               DumpBuf('recv', Buf, len);
               exit;
          end;
          RetErr := WSAEMSGSIZE;
     end;
     SetLastError(RetErr);
     result := SOCKET_ERROR;
     Log(LOG_LEVEL_DEBUG, 'Recv() error. %s (%d)', [WSocketErrorDesc(WSAGetLastError()), WSAGetLastError()]);
end;

function Stub_RecvFrom (s: TSocket; Buf: Pointer; len, flags: Integer; var from: TSockAddr; var fromlen: Integer): Integer;
var
   RetErr, RetVal, res: DWORD;
   Buffer: WSABUF;
   ThreadId: TWSATHREADID;
begin
     Buffer.len := len;
     Buffer.buf := Buf;
     ThreadId.ThreadHandle := GetCurrentThreadId();
     ThreadId.Reserved := 0;

     RetVal := UpcallIntf.WSockUpcall.pWSARecvFrom (s, LPWSABUF(@Buffer), 1, @res,
         @flags, @from, @fromlen, nil, nil, @ThreadId, @RetErr);

     if (RetVal = ERROR_SUCCESS) then
     begin
          result := Integer(res);
          exit;
     end;

     SetLastError(RetErr);
     result := SOCKET_ERROR;
end;

function Stub_Select (nfds: integer; readfds, writefds, exceptfds: PFDSet; timeout: PTimeval): integer;
var
   RetErr: DWORD;
begin
     result := UpcallIntf.WSockUpcall.pWSASelect(nfds, readfds, writefds, exceptfds, timeout, @RetErr);
     if (result = SOCKET_ERROR) then
     begin
          SetLastError(RetErr);
          result := SOCKET_ERROR;
     end;
end;

function Stub_Send (s: TSocket; Buf: Pointer; len, flags: Integer): Integer;
var
   RetErr, res: DWORD;
   Buffer: WSABUF;
   ThreadId: TWSATHREADID;
begin
     Buffer.len := len;
     Buffer.buf := Buf;
     ThreadId.ThreadHandle := GetCurrentThreadId();
     ThreadId.Reserved := 0;

     result := UpcallIntf.WSockUpcall.pWSASend(s, LPWSABUF(@Buffer), 1, @res, flags, nil, nil, @ThreadId, @RetErr);
     if (result = ERROR_SUCCESS) then
     begin
          result := res;
          exit;
     end;
     SetLastError(RetErr);
     result := SOCKET_ERROR;
end;

function Stub_SendTo (s: TSocket; Buf: Pointer; len, flags: Integer; var addrto: TSockAddr; tolen: Integer): Integer;
var
   RetErr, res: DWORD;
   Buffer: WSABUF;
   ThreadId: TWSATHREADID;
begin
     Buffer.len := len;
     Buffer.buf := Buf;
     ThreadId.ThreadHandle := GetCurrentThreadId();
     ThreadId.Reserved := 0;

     result := UpcallIntf.WSockUpcall.pWSASendTo(s, LPWSABUF(@Buffer), 1,
         @res, flags, @addrto, tolen, nil, nil, @ThreadId, @RetErr);

     if (result = ERROR_SUCCESS) then
     begin
          result := res;
          exit;
     end;
     SetLastError(RetErr);
     result := SOCKET_ERROR;
end;

function Stub_SetSockOpt (s: TSocket; level, optname: Integer; optval: PChar; optlen: Integer): Integer;
var
   RetErr: DWORD;
begin
     result := UpcallIntf.WSockUpcall.pWSASetSockOpt(s, level, optname, optval, optlen, @RetErr);
end;

function Stub_Shutdown (s: TSocket; how: integer): integer;
var
   RetErr: DWORD;
begin
     result := UpcallIntf.WSockUpcall.pWSAShutdown(s, how, @RetErr);
end;

function Stub_Socket (af: integer; type_: integer; protocol: integer): TSocket;
var
   RetErr: DWORD;
begin
     if @UpcallIntf.pAllocSocket <> nil then
       result := UpcallIntf.pAllocSocket(af, type_, protocol)
     else
       result := UpcallIntf.WSockUpcall.pWSASocket(af, type_, protocol, nil, 0, 0, @RetErr);

     if (result = INVALID_SOCKET) then
     begin
          Log(LOG_LEVEL_WARN, 'Stub_Socket error! Invalid socket!', []);
          result := INVALID_SOCKET;
     end;
end;

function Stub_ioctlsocket ( const s: TSocket; const cmd: DWORD; var arg: u_long ): Integer;
var
   DontCare, RetErr: DWORD;
   ThreadId: TWSATHREADID;
begin
     ThreadId.ThreadHandle := GetCurrentThreadId();
     ThreadId.Reserved := 0;

     result := UpcallIntf.WSockUpcall.pWSAIoctl(s, cmd, @arg, sizeof(u_long), @arg,
         sizeof(u_long), @DontCare, nil, nil, @ThreadId, @RetErr);

     if (result <> ERROR_SUCCESS) then
     begin
          SetLastError(RetErr);
          result := SOCKET_ERROR;
     end;
end;


function SelectForRecv(S: TSocket): integer;
var
   res     : integer;
   readfd, writefd  : TFDSet;
   errorfd : TFDSet;
   timeval : TTimeVal;
   err: integer;
begin
     result := -1;

     timeval.tv_sec := 1;
     timeval.tv_usec := 0;

     ZeroMemory(@readfd, SizeOf(readfd));
     ZeroMemory(@writefd, SizeOf(writefd));
     ZeroMemory(@errorfd, SizeOf(errorfd));
     SetLastError(0);

     while True do
     begin
          FD_CLR(s, readfd);
          FD_SET(s, readfd);

          FD_CLR(s, writefd);
          FD_SET(s, writefd);


          FD_CLR(s, errorfd);
          FD_SET(s, errorfd);

          res := Stub_select(0, @readfd, @writefd, @errorfd, {@timeval} nil);
          Log(LOG_LEVEL_DEBUG, 'Stub_select = %d', [res]);

          err := GetLastError();
          if (err < WSABASEERR) then
             err := 0;

          if (res < 0) and (err <> 0) then
          begin
               break;
          end;

          if FD_ISSET(s, errorfd) and (err <> 0) then
            break;


          if FD_ISSET(s, readfd) or FD_ISSET(s, writefd) then
          begin
               result := 1;
               exit;
          end;
     end;

     FD_CLR(s, errorfd);
     FD_CLR(s, readfd);
     FD_CLR(s, writefd);

     // Reset last error for prevent possible main program crash (IE have very
     // strange process sockets errors -- it just crashes. stupid M$ n00bs)
     SetLastError(0);
end;

function SelectForSend(S: TSocket): integer;
var
   res     : integer;
   writefd  : TFDSet;
   errorfd : TFDSet;
   timeval : TTimeVal;
   err: integer;
begin
     result := -1;

     timeval.tv_sec := 1;
     timeval.tv_usec := 0;

     ZeroMemory(@writefd, SizeOf(writefd));
     ZeroMemory(@errorfd, SizeOf(errorfd));
     SetLastError(0);

     while True do
     begin
          FD_CLR(s, writefd);
          FD_SET(s, writefd);

          FD_CLR(s, errorfd);
          FD_SET(s, errorfd);

          res := Stub_select(0, nil, @writefd, @errorfd, @timeval);

          err := GetLastError();
          if (err < WSABASEERR) then
             err := 0;

          if (res < 0) and (err <> 0) then
          begin
               break;
          end;

          if FD_ISSET(s, errorfd) and (err <> 0) then
          begin
               break;
          end;


          if FD_ISSET(s, writefd) then
          begin
               result := 1;
               exit;
          end;
     end;
end;

end.
