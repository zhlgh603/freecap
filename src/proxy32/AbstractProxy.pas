{*
 * File: ...................... AbstractProxy.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Base proxy class

 $Id: AbstractProxy.pas,v 1.9 2005/12/19 06:09:02 bert Exp $

 $Log: AbstractProxy.pas,v $
 Revision 1.9  2005/12/19 06:09:02  bert
 *** empty log message ***

 Revision 1.8  2005/08/11 05:20:36  bert
 *** empty log message ***

 Revision 1.7  2005/05/24 04:28:52  bert
 *** empty log message ***

 Revision 1.6  2005/04/18 04:49:55  bert
 *** empty log message ***

 Revision 1.5  2005/04/06 04:58:56  bert
 *** empty log message ***

 Revision 1.4  2005/03/08 16:28:54  bert
 *** empty log message ***

 Revision 1.3  2005/02/15 12:37:23  bert
 Added 'exit' flag for preventing from deadlock

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit AbstractProxy;

interface
uses Windows, Messages, Classes, SysUtils, syncobjs, loger,
     misc, cfg, sockschain, base64, direct_addr, dns, winsock2,
     stub, proxy_intf, common;

type
    TAbstractProxy = class
    private
      function GetDestAddr: string;
    protected
      Fs: integer;  // For TCP sockets
      Fs2: integer; // for UDP sockets
      FExitFlag: Boolean;
      FLanProxy: Boolean;
      FCancelEvent: TEvent;

      FHost: string;
      Fport: integer;
      FLogin: string;
      FPassword: string;
      FDestAddr: TSockAddr;
      FBindAddr: TSockAddr;

      FUdpDestAddr: TSockAddr;
      FProxyMethod: integer;
      function RecvData(Buffer: Pointer; Size: integer; Flags: integer = 0): integer;
      procedure SendData(Data: Pointer; Size: integer);
    public
      constructor Create(host, login, password: string; s, port, ProxyMethod: integer; bFirst: Boolean = false); virtual;
      destructor Destroy; override;

      procedure CancelBlockingCall;

      // Do a 'first time' connection to the proxy.
      // Required only when it is first proxy in the list.
      function DoConnection(): integer;
      function isPseudoDestAddr(): Boolean; overload;
      function isPseudoDestAddr(addr: TSockAddrIn): Boolean; overload;

      // Connect to destination *VIA* proxy.
      function connect(DestAddr: TSockAddr): integer; virtual;
      function Bind(BindAddr: TSockAddr): integer; virtual;
      function Accept(var AcceptAddr: TSockAddr): integer; virtual;

      function UDP(): integer; virtual;
      function SendTo(s: TSocket; Buf: Pointer; len, flags: Integer;
         addrto: TSockAddr; tolen: Integer): Integer; virtual;

      function GetHost(addr: TSockAddr): string;

      property SockHandle: integer read Fs;
      property BindedAddr: TSockAddr read FBindAddr write FBindAddr;
      property DestAddr: TSockAddr read FDestAddr write FDestAddr;
      property DestAddrHost: string read GetDestAddr;
      property ExitFlag: Boolean read FExitFlag write FExitFlag;
    end;

implementation

{ TAbstractProxy }

function TAbstractProxy.Accept(var AcceptAddr: TSockAddr): integer;
begin
     result := 0;
end;

function TAbstractProxy.Bind(BindAddr: TSockAddr): integer;
begin
     move(BindAddr, FBindAddr, SizeOf(BindAddr));
     result := 0;
end;

function TAbstractProxy.connect(DestAddr: TSockAddr): integer;
begin
     move(DestAddr, FDestAddr, SizeOf(DestAddr));
     if (not isPseudoDestAddr()) and not FLanProxy and IsLANAddr(FDestAddr.sin_addr.S_addr) then
     begin
          Log(LOG_LEVEL_WARN, 'Trying to connect to local LAN resource trought external proxy!',[]);
     end;

     FCancelEvent.ResetEvent;
     result := 0;
end;

constructor TAbstractProxy.Create(host, login, password: string; s, port, ProxyMethod: integer; bFirst: Boolean{ = false});
begin
     inherited Create;
     Fhost := Host;
     FPort := Port;
     Flogin := login;
     Fpassword := password;
     Fs := s;
     FS2 := -1;
     FProxyMethod := ProxyMethod;
     FExitFlag := False;
     FCancelEvent := TEvent.Create(nil, False, False, '');

     if FProxyMethod = METHOD_UDP then
     begin
          Fs := Stub_socket(AF_INET, SOCK_STREAM, 0);
          FS2 := s;
     end;

     if (bFirst) then
     begin
          DoConnection();
     end;
end;

function TAbstractProxy.DoConnection: integer;
var
   name   : TSockAddr;
   HostEnt: PHostEnt;
   ph     : PHostAddr;
   namelen: integer;
begin
     result := -1;


     name.sin_addr.S_addr := inet_addr(PChar(Fhost));
     if name.sin_addr.S_addr = INADDR_NONE then
     begin
          HostEnt := winsock2.gethostbyname(PChar(Fhost));
          if HostEnt = nil then
          begin
               Log(LOG_LEVEL_DEBUG, 'HostEnt = nil',[]);
               exit;
          end;

          ph := PHostAddr(HostEnt^.h_addr_list^);
          if ph = nil then
          begin
               Log(LOG_LEVEL_DEBUG, 'ph = nil',[]);
               exit;
          end;
          name.sin_addr.S_addr := Cardinal(ph^);
     end;

     FLanProxy := isLanAddr(name.sin_addr.S_addr);

     name.sin_family := AF_INET;
     name.sin_port := ntohs(FPort);
     namelen := SizeOf(name);

     result := Stub_connect(Fs, @name, namelen);
end;

function TAbstractProxy.RecvData(Buffer: Pointer; Size: integer; Flags: integer { = 0}): integer;
var
   res     : integer;
   readfd  : TFDSet;
   errorfd : TFDSet;
   timeval : TTimeVal;
   cnt, err: integer;
begin
     result := -1;
     cnt := 0;
     err := 0;

     timeval.tv_sec := 1;
     timeval.tv_usec := 0;

     ZeroMemory(@readfd, SizeOf(readfd));
     ZeroMemory(@errorfd, SizeOf(errorfd));
     SetLastError(0);

     while not (FExitFlag) do
     begin
          if FCancelEvent.WaitFor(10) <> wrTimeout then
          begin
               Log(LOG_LEVEL_SOCKS, '[%d] Recv Cancel event signaled! Exiting...', [Fs]);
               break;
          end;

          FD_CLR(Fs, readfd);
          FD_SET(Fs, readfd);

          FD_CLR(Fs, errorfd);
          FD_SET(Fs, errorfd);

          res := Stub_select(0, @readfd, nil, @errorfd, @timeval);

          err := GetLastError();
          if (err < WSABASEERR) then
            err := 0;

          if (res < 0) and (err <> 0) then
          begin
               Log(LOG_LEVEL_SOCKS, 'RecvData error (select returns -1): %s (%d)', [WSocketErrorDesc(err), err]);
               break;
          end;

          if FD_ISSET(Fs, errorfd) and (err <> 0) then
          begin
               Log(LOG_LEVEL_SOCKS, 'RecvData error (socket handle in errorfd): %s (%d)', [WSocketErrorDesc(err), err]);
               break;
          end;


          if FD_ISSET(Fs, readfd) then
          begin
               result := Stub_recv(Fs, Buffer, Size, Flags);
               err := GetLastError();

               if (result = 0) and (err = 0) then
               begin
                    Log(LOG_LEVEL_SOCKS, 'Something wrong. Server silently closed the connection!', []);
                    break;
               end;

               if (err < WSABASEERR) then
                  err := 0;

               if (result <> -1) or (err <> WSAEWOULDBLOCK) then
               begin
                    if err <> 0 then
                      Log(LOG_LEVEL_SOCKS, 'RecvData error: (select ok, but recv() returns -1) %s (%d)', [WSocketErrorDesc(err), err]);
                    break;
               end;
          end;
          inc(cnt);

          if (cnt > 120) then
          begin
               SetLastError(WSAETIMEDOUT);
               Log(LOG_LEVEL_SOCKS, 'recv timeout', []);
               exit;
          end;
     end;

     FD_CLR(Fs, errorfd);
     FD_CLR(Fs, readfd);
     // Reset last error for prevent possible main program crash (IE have very
     // strange process sockets errors -- it just crashes. stupid M$ n00bs)
     SetLastError(0);
end;

procedure TAbstractProxy.SendData(Data: Pointer; Size: integer);
var
   res     : integer;
   readfd  : TFDSet;
   writefd : TFDSet;
   errorfd : TFDSet;
   timeval : TTimeVal;
   nw, err : integer;
   cnt     : integer;
begin
     timeval.tv_sec := 1;
     timeval.tv_usec := 0;
     cnt := 0;
     err := 0;

     ZeroMemory(@readfd, SizeOf(readfd));
     ZeroMemory(@writefd, SizeOf(writefd));
     ZeroMemory(@errorfd, SizeOf(errorfd));
     SetLastError(0);

     while not (FExitFlag) do
     begin
          if FCancelEvent.WaitFor(10) <> wrTimeout then
          begin
               Log(LOG_LEVEL_SOCKS, '[%d] Recv Cancel event signaled! Exiting...', [Fs]);
               break;
          end;

          if Fs = 0 then break;

          FD_CLR(Fs, readfd);
          FD_SET(Fs, readfd);

          FD_CLR(Fs, writefd);
          FD_SET(Fs, writefd);

          FD_CLR(Fs, errorfd);
          FD_SET(Fs, errorfd);

          res := Stub_select(0, @readfd, @writefd, @errorfd, @timeval);

          err := GetLastError();
          if (err < WSABASEERR) then
             err := 0;


          if FD_ISSET(Fs, readfd) then
          begin
               if (err <> WSAEWOULDBLOCK) then
               begin
                    break;
               end;
          end;

          if FD_ISSET(Fs, errorfd)  and (err <> 0) then
          begin
               Log(LOG_LEVEL_SOCKS, 'SendData error (socket handle in errorfd): %s (%d)', [WSocketErrorDesc(err), err]);
               break;
          end;

          if (res < 0)  and (err <> 0)  then
          begin
               Log(LOG_LEVEL_SOCKS, 'SendData error (select returns -1): %s (%d)', [WSocketErrorDesc(err), err]);
               break;
          end;


          if FD_ISSET(Fs, writefd) then
          begin
               nw := Stub_send(Fs, Data, Size, 0);
               err := GetLastError();
               if (err < WSABASEERR) then
                 err := 0;

               if (nw <> -1) or (err <> WSAEWOULDBLOCK) then
               begin
                    if err <> 0 then
                      Log(LOG_LEVEL_SOCKS, 'SendData error (select ok, but send() returns -1): %s (%d)', [WSocketErrorDesc(err), err]);
                    break;
               end;
          end;
          inc(cnt);

          if (cnt > 60) then
          begin
               SetLastError(WSAETIMEDOUT);
               Log(LOG_LEVEL_SOCKS, 'send timeout', []);
               exit;
          end;

     end;
     FD_CLR(Fs, writefd);
     FD_CLR(Fs, errorfd);

     SetLastError(0);
end;


function TAbstractProxy.UDP(): integer;
begin
     result := 0;
end;



function TAbstractProxy.SendTo(s: TSocket; Buf: Pointer; len, flags: Integer;
  addrto: TSockAddr; tolen: Integer): Integer;
begin
     result := Stub_sendto(s, Buf, len, flags, addrto, tolen);
end;


function TAbstractProxy.GetDestAddr: string;
begin
     result := GetAddrString(FDestAddr.sin_addr.S_addr);
end;

function TAbstractProxy.isPseudoDestAddr: Boolean;
begin
     result := UpcallIntf.pIsPseudoAddr(FDestAddr.sin_addr.S_addr);
end;


function TAbstractProxy.isPseudoDestAddr(addr: TSockAddrIn): Boolean;
begin
     result := UpcallIntf.pIsPseudoAddr(addr.sin_addr.S_addr);
end;

function TAbstractProxy.GetHost(addr: TSockAddr): string;
begin
     result := GetAddrString(addr.sin_addr.S_addr);
end;

destructor TAbstractProxy.Destroy;
begin
     if FProxyMethod = METHOD_UDP then
     begin
          Stub_Shutdown(FS, SD_BOTH);
          Stub_CloseSocket(FS);
     end;
     FCancelEvent.Free;
     inherited Destroy;
end;

procedure TAbstractProxy.CancelBlockingCall;
begin
     FCancelEvent.SetEvent;
end;

end.
