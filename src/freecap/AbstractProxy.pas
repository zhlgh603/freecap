{*
 * File: ...................... AbstractProxy.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Base proxy class

 $Id: AbstractProxy.pas,v 1.2 2005/05/12 04:21:21 bert Exp $

 $Log: AbstractProxy.pas,v $
 Revision 1.2  2005/05/12 04:21:21  bert
 *** empty log message ***

 Revision 1.1  2005/04/27 06:39:37  bert
 Initial import

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
     misc, cfg, base64, direct_addr, winsock2;

type
    TAbstractProxy = class
    private
      FLastError: string;
    protected
      Fs: integer;  // For TCP sockets
      Fs2: integer; // for UDP sockets
      FExitFlag: Boolean;
      FLanProxy: Boolean;

      FHost: string;
      Fport: integer;
      FLogin: string;
      FPassword: string;
      FDestAddr: TSockAddr;
      FBindAddr: TSockAddr;

      FUdpDestAddr: TSockAddr;
      FProxyMethod: integer;
      function GetDestAddr: string;

    public
      constructor Create(host, login, password: string; s, port, ProxyMethod: integer; bFirst: Boolean = false); virtual;
      destructor Destroy; override;

      // Do a 'first time' connection to the proxy.
      // Required only when it is first proxy in the list.
      function DoConnection(): integer;
      function RecvData(Buffer: Pointer; Size: integer): integer;
      procedure SendData(Data: Pointer; Size: integer);

      // Connect to destination *VIA* proxy.
      function connect(DestAddr: TSockAddr): integer; virtual;
      function Bind(BindAddr: TSockAddr): integer; virtual;
      function Accept(var AcceptAddr: TSockAddr): integer; virtual;

      function UDP(): integer; virtual;
      function SendTo(s: TSocket; Buf: Pointer; len, flags: Integer;
         addrto: TSockAddr; tolen: Integer): Integer; virtual;

      property SockHandle: integer read Fs;
      property BindedAddr: TSockAddr read FBindAddr write FBindAddr;
      property DestAddr: TSockAddr read FDestAddr write FDestAddr;
      property DestAddrHost: string read GetDestAddr;
      property ExitFlag: Boolean read FExitFlag write FExitFlag;
      property LastError: string read FLastError write FLastError;
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
     FExitFlag := False;

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

     name.sin_addr.S_addr := inet_addr(PChar(Fhost));
     if name.sin_addr.S_addr = INADDR_NONE then
     begin
          HostEnt := winsock2.gethostbyname(PChar(Fhost));
          if HostEnt = nil then
          begin
               FLastError := 'HostEnt = nil';
               exit;
          end;

          ph := PHostAddr(HostEnt^.h_addr_list^);
          if ph = nil then
          begin
               FLastError := 'ph = nil';
               exit;
          end;
          name.sin_addr.S_addr := Cardinal(ph^);
     end;


     name.sin_family := AF_INET;
     name.sin_port := ntohs(FPort);
     namelen := SizeOf(name);

     result := winsock2.connect(Fs, @name, namelen);
end;

function TAbstractProxy.RecvData(Buffer: Pointer; Size: integer): integer;
var
   res     : integer;
   readfd  : TFDSet;
   errorfd : TFDSet;
   timeval : TTimeVal;
   cnt, err: integer;
begin
     result := -1;
     cnt := 0;

     timeval.tv_sec := 1;
     timeval.tv_usec := 0;

     ZeroMemory(@readfd, SizeOf(readfd));
     ZeroMemory(@errorfd, SizeOf(errorfd));
     SetLastError(0);

     while not (FExitFlag) do
     begin
          FD_CLR(Fs, readfd);
          FD_SET(Fs, readfd);

          FD_CLR(Fs, errorfd);
          FD_SET(Fs, errorfd);

          res := select(0, @readfd, nil, @errorfd, @timeval);

          err := GetLastError();
          if (err < WSABASEERR) then
             err := 0;

          if (res < 0) and (err <> 0) then
          begin
               FLastError := Format('RecvData error (select returns -1): %s (%d)', [WSocketErrorDesc(err), err]);
               break;
          end;

          if FD_ISSET(Fs, errorfd) and (err <> 0) then
          begin
               FLastError := Format('RecvData error (socket handle in errorfd): %s (%d)', [WSocketErrorDesc(err), err]);
               break;
          end;


          if FD_ISSET(Fs, readfd) then
          begin
               result := recv(Fs, Buffer, Size, 0);
               err := GetLastError();

               if (result = 0) and (err = 0) then
               begin
                    FLastError := Format('Something wrong. Server silently closed the connection!', []);
                    break;
               end;

               if (err < WSABASEERR) then
                 err := 0;

               if (result <> -1) or (err <> WSAEWOULDBLOCK) then
               begin
                    if err <> 0 then
                      FLastError := Format('RecvData error: (select ok, but recv() returns -1) %s (%d)', [WSocketErrorDesc(err), err]);
                    break;
               end;
          end;
          inc(cnt);

          if (cnt > 15) then
          begin
               SetLastError(WSAETIMEDOUT);
               FLastError := 'recv timeout';
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

     ZeroMemory(@readfd, SizeOf(readfd));
     ZeroMemory(@writefd, SizeOf(writefd));
     ZeroMemory(@errorfd, SizeOf(errorfd));
     SetLastError(0);

     while not (FExitFlag) do
     begin
          if Fs = 0 then break;

          FD_CLR(Fs, readfd);
          FD_SET(Fs, readfd);

          FD_CLR(Fs, writefd);
          FD_SET(Fs, writefd);

          FD_CLR(Fs, errorfd);
          FD_SET(Fs, errorfd);

          res := select(0, @readfd, @writefd, @errorfd, @timeval);

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
               FLastError := Format('SendData error (socket handle in errorfd): %s (%d)', [WSocketErrorDesc(err), err]);
               break;
          end;

          if (res < 0)  and (err <> 0)  then
          begin
               FLastError := Format('SendData error (select returns -1): %s (%d)', [WSocketErrorDesc(err), err]);
               break;
          end;


          if FD_ISSET(Fs, writefd) then
          begin
               nw := send(Fs, Data, Size, 0);
               err := GetLastError();
               if (err < WSABASEERR) then
                 err := 0;

               if (nw <> -1) or (err <> WSAEWOULDBLOCK) then
               begin
                    if err <> 0 then
                      FLastError := Format('SendData error (select ok, but send() returns -1): %s (%d)', [WSocketErrorDesc(err), err]);
                    break;
               end;
          end;
          inc(cnt);

          if (cnt > 15) then
          begin
               SetLastError(WSAETIMEDOUT);
               FLastError := 'send timeout';
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
     result := sendto(s, Buf, len, flags, addrto, tolen);
end;


destructor TAbstractProxy.Destroy;
begin
     if FProxyMethod = METHOD_UDP then
     begin
          Shutdown(FS, SD_BOTH);
          CloseSocket(FS);
     end;
     inherited Destroy;
end;


function TAbstractProxy.GetDestAddr: string;
var
   ip: dword;
begin
     ip := FDestAddr.sin_addr.S_addr;
     result := Format('%d.%d.%d.%d',[ip and $FF,
                                     ip shr 8 and $FF,
                                     ip shr 16 and $FF,
                                     ip shr 24]);

end;


end.
