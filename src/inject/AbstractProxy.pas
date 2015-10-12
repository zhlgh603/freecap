{*
 * File: ...................... AbstractProxy.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Base proxy class

 $Id: AbstractProxy.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

 $Log: AbstractProxy.pas,v $
 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***

}
unit AbstractProxy;

interface
uses Windows, Messages, Classes, SysUtils, winsock2, syncobjs, loger,
     misc, cfg, sockschain, base64, direct_addr, dns;

type
    TAbstractProxy = class
    private
      function GetDestAddr: string;
    protected
      Fs: integer;  // For TCP sockets
      Fs2: integer; // for UDP sockets

      FHost: string;
      Fport: integer;
      FLogin: string;
      FPassword: string;
      FDestAddr: TSockAddr;
      FBindAddr: TSockAddr;

      FUdpDestAddr: TSockAddr;
      FProxyMethod: integer;
      function RecvData(Buffer: Pointer; Size: integer): integer;
      procedure SendData(Data: Pointer; Size: integer);

    public
      constructor Create(host, login, password: string; s, port, ProxyMethod: integer; bFirst: Boolean = false); virtual;
      destructor Destroy; override;

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

     if FProxyMethod = METHOD_UDP then
     begin
          Fs := socket(AF_INET, SOCK_STREAM, 0);
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

     name.sin_family := AF_INET;
     name.sin_addr.S_addr := Cardinal(ph^);
     name.sin_port := ntohs(FPort);
     namelen := SizeOf(name);

     winsock2.connect(Fs, @name, namelen);
end;

function TAbstractProxy.RecvData(Buffer: Pointer; Size: integer): integer;
var
   res     : integer;
   readfd  : TFDSet;
   errorfd : TFDSet;
   timeval : TTimeVal;
   cnt     : integer;
   LastErr : Integer;
begin
     result := -1;
     cnt := 0;

     timeval.tv_sec := 1;
     timeval.tv_usec := 0;

     ZeroMemory(@readfd, SizeOf(readfd));
     ZeroMemory(@errorfd, SizeOf(errorfd));

     while True do
     begin
          FD_CLR(Fs, readfd);
          FD_SET(Fs, readfd);

          FD_CLR(Fs, errorfd);
          FD_SET(Fs, errorfd);

          res := select(0, @readfd, nil, @errorfd, @timeval);

          if (res < 0) then
          begin
               LastErr := WSAGetLastError();
               Log(LOG_LEVEL_SOCKS, 'RecvData error: %s (%d)', [WSocketErrorDesc(LastErr), LastErr]);
               break;
          end;

          if FD_ISSET(Fs, errorfd) then
          begin
               LastErr := WSAGetLastError();
               Log(LOG_LEVEL_SOCKS, 'RecvData error (errorfd): %s (%d)', [WSocketErrorDesc(LastErr), LastErr]);
               break;
          end;


          if FD_ISSET(Fs, readfd) then
          begin
               result := winsock2.recv(Fs, Buffer, Size, 0);
               LastErr := WSAGetLastError();

               if (result <> -1) or (LastErr <> WSAEWOULDBLOCK) then
               begin
                    if LastErr <> 0 then
                      Log(LOG_LEVEL_SOCKS, 'RecvData error: %s (%d)', [WSocketErrorDesc(WSAGetLastError()), WSAGetLastError()]);
                    break;
               end;
          end;
          inc(cnt);

          if (cnt > 120) then
          begin
               WSASetLastError(WSAETIMEDOUT);
               Log(LOG_LEVEL_SOCKS, 'recv timeout', []);
               exit;
          end;
     end;

     FD_CLR(Fs, errorfd);
     FD_CLR(Fs, readfd);
     // Reset last error for prevent possible main program crash (IE have very
     // strange process sockets errors -- it just crashes. stupid M$ n00bs)
     WSASetLastError(0);
end;

procedure TAbstractProxy.SendData(Data: Pointer; Size: integer);
var
   res     : integer;
   readfd  : TFDSet;
   writefd : TFDSet;
   errorfd : TFDSet;
   timeval : TTimeVal;
   nw      : integer;
   cnt     : integer;
begin
     timeval.tv_sec := 1;
     timeval.tv_usec := 0;
     cnt := 0;

     ZeroMemory(@readfd, SizeOf(readfd));
     ZeroMemory(@writefd, SizeOf(writefd));
     ZeroMemory(@errorfd, SizeOf(errorfd));

     while True do
     begin
          if Fs = 0 then break;

          FD_CLR(Fs, readfd);
          FD_SET(Fs, readfd);

          FD_CLR(Fs, writefd);
          FD_SET(Fs, writefd);

          FD_CLR(Fs, errorfd);
          FD_SET(Fs, errorfd);

          res := select(0, @readfd, @writefd, @errorfd, @timeval);

          if FD_ISSET(Fs, readfd) then
          begin
               if (WSAGetLastError() <> WSAEWOULDBLOCK) then
               begin
                    break;
               end;
          end;

          if FD_ISSET(Fs, errorfd) then
          begin
               Log(LOG_LEVEL_SOCKS, 'SendData error: %s (%d)', [WSocketErrorDesc(WSAGetLastError()), WSAGetLastError()]);
               break;
          end;

          if (res < 0) then
          begin
               Log(LOG_LEVEL_SOCKS, 'SendData error: %s (%d)', [WSocketErrorDesc(WSAGetLastError()), WSAGetLastError()]);
               break;
          end;


          if FD_ISSET(Fs, writefd) then
          begin
               nw := winsock2.send(Fs, Data, Size, 0);
               if (nw <> -1) or (WSAGetLastError() <> WSAEWOULDBLOCK) then
               begin
                    if WSAGetLastError() <> 0 then
                      Log(LOG_LEVEL_SOCKS, 'SendData error: %s (%d)', [WSocketErrorDesc(WSAGetLastError()), WSAGetLastError()]);
                    break;
               end;
          end;
          inc(cnt);

          if (cnt > 60) then
          begin
               WSASetLastError(WSAETIMEDOUT);
               Log(LOG_LEVEL_SOCKS, 'send timeout', []);
               exit;
          end;

     end;
     FD_CLR(Fs, writefd);
     FD_CLR(Fs, errorfd);
     WSASetLastError(0);
end;


function TAbstractProxy.UDP(): integer;
begin
     result := 0;
end;



function TAbstractProxy.SendTo(s: TSocket; Buf: Pointer; len, flags: Integer;
  addrto: TSockAddr; tolen: Integer): Integer;
begin
     result := winsock2.sendto(s, Buf, len, flags, addrto, tolen);
end;


function TAbstractProxy.GetDestAddr: string;
begin
     result := GetAddrString(FDestAddr.sin_addr.S_addr);
end;

function TAbstractProxy.isPseudoDestAddr: Boolean;
begin
     result := IsPseudoAddr(FDestAddr.sin_addr.S_addr);
end;


function TAbstractProxy.isPseudoDestAddr(addr: TSockAddrIn): Boolean;
begin
     result := IsPseudoAddr(addr.sin_addr.S_addr);
end;

function TAbstractProxy.GetHost(addr: TSockAddr): string;
begin
     result := GetAddrString(addr.sin_addr.S_addr);
end;

destructor TAbstractProxy.Destroy;
begin
     if FProxyMethod = METHOD_UDP then
     begin
          shutdown(FS, SD_BOTH);
          closesocket(FS);
     end;
     inherited Destroy;
end;

end.
