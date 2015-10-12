{*
 * File: ...................... Socks5Proxy.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... SOCKSv5 client side proxy implementation
                                according to RFC1928, RFC1929
 $Id: Socks5Proxy.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

 $Log: Socks5Proxy.pas,v $
 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit Socks5Proxy;

interface

uses Windows, Messages, Classes, SysUtils, direct_addr, dns,
     winsock2, loger, misc, cfg, AbstractProxy;

type
    TSOCKS5Proxy = class(TAbstractProxy)
    private
      FUdpTunnelOpened: Boolean;
      function DoConnect(): integer;
      function DoAuth(): integer;
      function DoUDPAuth: Integer;
    public
      function DoOpenUDP(): Boolean;
      function DoConnectUDP: Integer;
      function NegotiateUDP: Integer;

      function connect(DestAddr: TSockAddr): integer; override;
      function Bind(BindAddr: TSockAddr): integer; override;
      function Accept(var AcceptAddr: TSockAddr): integer; override;
      function SendTo(s: TSocket; Buf: Pointer; len, flags: Integer;
         addrto: TSockAddr; tolen: Integer): Integer; override;
      function UDP(): integer; override;
    end;

const
     { SOCKS v5 related constants }

     SOCKS5_VER                    = #$05;
     SOCKS5_AUTH_NONE              = #$00;
     SOCKS5_AUTH_GSSAPI            = #$01;
     SOCKS5_AUTH_PASS              = #$02;
     SOCKS5_AUTH_NO_METHODS        = #$FF;

     SOCKS5_REQ_VER                = #$05;
     SOCKS5_REQ_CMD_CONNECT        = #$01;
     SOCKS5_REQ_CMD_BIND           = #$02;
     SOCKS5_REQ_CMD_UDP            = #$03;

     SOCKS5_REQ_RSV                = #$00;

     SOCKS5_REQ_ATYP_IP4           = #$01;
     SOCKS5_REQ_ATYP_DOMAIN        = #$03;
     SOCKS5_REQ_ATYP_IP6           = #$04;


     SOCKS5_REP_VER                  = #$05;
     SOCKS5_REP_REP_OK               = #$00;
     SOCKS5_REP_REP_GENFAIL          = #$01;
     SOCKS5_REP_REP_CONN_NOT_ALLOWED = #$02;
     SOCKS5_REP_REP_NET_UNREACH      = #$03;
     SOCKS5_REP_REP_HOST_UNREACH     = #$04;
     SOCKS5_REP_REP_CONN_REFUSED     = #$05;
     SOCKS5_REP_REP_TTL_EXPIRED      = #$06;
     SOCKS5_REP_REP_CMD_NOT_SUPP     = #$07;
     SOCKS5_REP_REP_ATYPE_NOT_SUPP   = #$08;
     SOCKS5_REP_RSV                  = #$00;
     SOCKS5_REP_ATYP_IP4             = #$01;
     SOCKS5_REP_ATYP_DOMAIN          = #$03;
     SOCKS5_REP_ATYP_IP6             = #$04;

implementation

{* SOCKS5 BIND stuff *}

function TSOCKS5Proxy.Accept(var AcceptAddr: TSockAddr): integer;
var
   Buf     : array [0..9] of char;
   s       : string;
begin
     inherited Accept(AcceptAddr);
     result := -1;
     RecvData(@Buf, SizeOf(Buf));
     if (buf[0] = SOCKS5_REP_VER) and (buf[1] = SOCKS5_REP_REP_OK) then
     begin
          Log(LOG_LEVEL_SOCKS, 'SOCKS bind successfull',[]);
          AcceptAddr.sin_addr.S_addr := PDWORD(@Buf[4])^;
          AcceptAddr.sin_port := PWord(@Buf[8])^;
          result := 0;
     end
     else
     begin
          case buf[1] of
             SOCKS5_REP_REP_GENFAIL: s := 'general SOCKS server failure';
             SOCKS5_REP_REP_CONN_NOT_ALLOWED: s := 'connection not allowed by ruleset';
             SOCKS5_REP_REP_NET_UNREACH: s := 'Network unreachable';
             SOCKS5_REP_REP_HOST_UNREACH: s := 'Host unreachable';
             SOCKS5_REP_REP_CONN_REFUSED: s := 'Connection refused';
             SOCKS5_REP_REP_TTL_EXPIRED: s := 'TTL expired';
             SOCKS5_REP_REP_CMD_NOT_SUPP: s := 'Command not supported';
             SOCKS5_REP_REP_ATYPE_NOT_SUPP: s := 'Address type not supported';
             #$09..#$FF: s := 'Unknown';
          end;
          Log(LOG_LEVEL_SOCKS, 'SOCKS connection failure: %s %s',[s, buf]);
     end;
end;


function TSOCKS5Proxy.Bind(BindAddr: TSockAddr): integer;
var
   Buf: array [0..9] of char;
   I  : Integer;
   s: string;
begin
     inherited Bind(BindAddr);
     result := -1;

     Buf[0] := SOCKS5_VER;
     Buf[1] := SOCKS5_REQ_CMD_BIND;
     Buf[2] := SOCKS5_REQ_RSV;

     i := 3;

     Buf[I] := SOCKS5_REQ_ATYP_IP4;
     PDWORD(@Buf[I + 1])^ := FBindAddr.sin_addr.S_addr;
     inc(i, SizeOf(integer) + 1);


     PWord(@Buf[I])^ := FBindAddr.sin_port;
     I := I + 2;
     SendData(@Buf, I);

     Log(LOG_LEVEL_SOCKS, 'Telling SOCKS to wait connection from address %s...',[GetDottedIP(FBindAddr.sin_addr.S_addr)]);

     ZeroMemory(@Buf, SizeOf(Buf));

     RecvData(@Buf, I);

     if (buf[0] = SOCKS5_REP_VER) and (buf[1] = SOCKS5_REP_REP_OK) then
     begin
          Log(LOG_LEVEL_SOCKS, 'SOCKS bind successfull',[]);
          FBindAddr.sin_addr.S_addr := FDestAddr.sin_addr.S_addr;
          FBindAddr.sin_port := PWord(@Buf[8])^;
          result := 0;
     end
     else
     begin
          case buf[1] of
             SOCKS5_REP_REP_GENFAIL: s := 'general SOCKS server failure';
             SOCKS5_REP_REP_CONN_NOT_ALLOWED: s := 'connection not allowed by ruleset';
             SOCKS5_REP_REP_NET_UNREACH: s := 'Network unreachable';
             SOCKS5_REP_REP_HOST_UNREACH: s := 'Host unreachable';
             SOCKS5_REP_REP_CONN_REFUSED: s := 'Connection refused';
             SOCKS5_REP_REP_TTL_EXPIRED: s := 'TTL expired';
             SOCKS5_REP_REP_CMD_NOT_SUPP: s := 'Command not supported';
             SOCKS5_REP_REP_ATYPE_NOT_SUPP: s := 'Address type not supported';
             #$09..#$FF: s := 'Unknown';
          end;
          Log(LOG_LEVEL_SOCKS, 'SOCKS connection failure: %s %s',[s, buf]);
     end;
end;

{* SOCKS5 CONNECT stuff *}

function TSOCKS5Proxy.connect(DestAddr: TSockAddr): integer;
var
   Buf: array [0..2] of char;
begin
     inherited connect(DestAddr);

     result := -1;
     Buf[0] := SOCKS5_VER;
     Buf[1] := #$01;      // Number of our methods

     if (Flogin <> '') then
       Buf[2] := SOCKS5_AUTH_PASS
     else
       Buf[2] := SOCKS5_AUTH_NONE;

     SendData(@Buf, 3);

     if WSAGetLastError() = WSAECONNREFUSED then
        exit;

     ZeroMemory(@Buf, SizeOf(Buf));

     RecvData(@buf, 2);

     if Buf[0] <> SOCKS5_VER then
     begin
          {* This should never occurs. Otherwise it indicates that our program is buggy
           *}
          Log(LOG_LEVEL_SOCKS, 'Error while trying to establish connection: Got first byte in reply %d (expected: %d)',[Integer(Buf[0]), Integer(SOCKS5_VER)]);
     end
     else if Buf[1] = SOCKS5_AUTH_NONE then
     begin
          Log(LOG_LEVEL_SOCKS, 'No authentication required',[]);
          if FProxyMethod = METHOD_CONNECT then
            result := DoConnect()
          else
            result := 0;
     end
     else if Buf[1] = SOCKS5_AUTH_GSSAPI then
     begin
          Log(LOG_LEVEL_SOCKS, 'GSSAPI (not supported)',[]);
     end
     else if Buf[1] = SOCKS5_AUTH_PASS then
     begin
          Log(LOG_LEVEL_SOCKS, 'SOCKS server selected username/password',[]);
          result := DoAuth();
    end
    else if Buf[1] = SOCKS5_AUTH_NO_METHODS then
    begin
         Log(LOG_LEVEL_SOCKS, 'No acceptable methods',[]);
    end;
end;

function TSOCKS5Proxy.DoAuth: integer;
var
   Buf    : array [0..255] of char;
   I      : Integer;
begin
     result := -1;
     Buf[0] := #$01;
     I      := 1;
     Buf[I] := chr(Length(FLogin));
     Move(FLogin[1], Buf[I + 1], Length(FLogin));
     I := I + 1 + Length(FLogin);
     Buf[I] := chr(Length(FPassword));
     Move(FPassword[1], Buf[I + 1], Length(FPassword));
     I := I + 1 + Length(FPassword);

     Log(LOG_LEVEL_SOCKS, 'SOCKS doing login for %s',[FLogin]);
     SendData(@Buf, I);
     ZeroMemory(@Buf, SizeOf(Buf));
     RecvData(@buf, 2);

     if Buf[1] = #$00 then
     begin
          Log(LOG_LEVEL_SOCKS, 'SOCKS success login',[]);
          if FProxyMethod = METHOD_CONNECT then
            result := DoConnect()
          else
            result := 0;
     end
     else
     begin
          DisplayMessage('Login to SOCKS failed! "' + FLogin + '"');
          Log(LOG_LEVEL_SOCKS, 'SOCKS rejected',[]);
     end;
end;

function TSOCKS5Proxy.DoConnect: integer;
var
   Buf     : array [0..255] of char;
   I       : Integer;
   s, host : string;
begin
     ZeroMemory(@Buf, SizeOf(Buf));
     Buf[0] := SOCKS5_VER;
     Buf[1] := SOCKS5_REQ_CMD_CONNECT;
     Buf[2] := SOCKS5_REQ_RSV;

     i := 3;
     if isPseudoDestAddr() then
     begin
          host := DestAddrHost;
          Buf[I] := SOCKS5_REQ_ATYP_DOMAIN;
          inc(i);
          Buf[I] := Char(Byte(Length(host)));
          inc(i);
          Move(Host[1], Buf[i], Length(host));
          inc(i, Length(host));
     end
     else
     begin
          Buf[I] := SOCKS5_REQ_ATYP_IP4;
          { Should check buffer overflow }
          inc(i);
          PDWORD(@Buf[I])^ := FDestAddr.sin_addr.S_addr;
          inc(i, SizeOf(integer));
     end;

     PWord(@Buf[I])^ := FDestAddr.sin_port;
     I := I + 2;
     SendData(@Buf, I);

     Log(LOG_LEVEL_SOCKS, 'SOCKS attempt to TCP connection to (%s:%d)...',[GetAddrString(FDestAddr.sin_addr.S_addr), ntohs(FDestAddr.sin_port)]);

     ZeroMemory(@Buf, SizeOf(Buf));

     RecvData(@Buf, I);

     if (buf[0] = SOCKS5_REP_VER) and (buf[1] = SOCKS5_REP_REP_OK) then
     begin
          Log(LOG_LEVEL_SOCKS, 'SOCKS connection established',[]);
          result := 0;
     end
     else
     begin
          case buf[1] of
             SOCKS5_REP_REP_GENFAIL: s := 'general SOCKS server failure';
             SOCKS5_REP_REP_CONN_NOT_ALLOWED: s := 'connection not allowed by ruleset';
             SOCKS5_REP_REP_NET_UNREACH: s := 'Network unreachable';
             SOCKS5_REP_REP_HOST_UNREACH: s := 'Host unreachable';
             SOCKS5_REP_REP_CONN_REFUSED: s := 'Connection refused';
             SOCKS5_REP_REP_TTL_EXPIRED: s := 'TTL expired';
             SOCKS5_REP_REP_CMD_NOT_SUPP: s := 'Command not supported';
             SOCKS5_REP_REP_ATYPE_NOT_SUPP: s := 'Address type not supported';
          else
             s := 'Unknown';
          end;
          Log(LOG_LEVEL_SOCKS, 'SOCKS connection failure: %s %s',[s, buf]);
          result := -1;
     end;
end;

{* SOCKS5 UDP stuff *}

function TSOCKS5Proxy.UDP(): integer;
var
   Buf     : array [0..9] of char;
   I       : Integer;
   s       : string;
   BndAddr : TSockAddrIn;
   BndAddrlen: integer;
begin
     inherited UDP();
     result := -1;

     Buf[0] := SOCKS5_VER;
     Buf[1] := SOCKS5_REQ_CMD_UDP;
     Buf[2] := SOCKS5_REQ_RSV;
     Buf[3] := SOCKS5_REQ_ATYP_IP4;

     BndAddrlen := SizeOf(TSockAddrIn);
     ZeroMemory(@BndAddr, BndAddrlen);
     BndAddr.sin_family := AF_INET;

     getsockname(Fs2, BndAddr, BndAddrLen);

     if (BndAddr.sin_port = 0) then
     begin
          winsock2.bind(Fs2, @BndAddr, BndAddrLen);
          getsockname(Fs2, BndAddr, BndAddrLen);
          Log(LOG_LEVEL_SOCKS, 'UDP getsockname after bind(), port = %d', [ntohs(BndAddr.sin_port)]);
     end;

     Log(LOG_LEVEL_SOCKS, 'UDP getsockname %s, port = %d', [GetDottedIP(BndAddr.sin_addr.S_addr), ntohs(BndAddr.sin_port)]);

     if cfg.socks_udp_hack then
     begin
          PDWORD(@Buf[4])^ := 0; // let assignment to the SOCKS server
          I := 4 + SizeOf(integer);
          PWord(@Buf[I])^ := 0;
     end
     else
     begin
          PDWORD(@Buf[4])^ := BndAddr.sin_addr.S_addr;
          I := 4 + SizeOf(integer);
          PWord(@Buf[I])^ := BndAddr.sin_port;
     end;

     I := I + 2;
     SendData(@Buf, I);

     ZeroMemory(@Buf, SizeOf(Buf));
     RecvData(@Buf, SizeOf(Buf));

     if (buf[0] = SOCKS5_REP_VER) and (buf[1] = SOCKS5_REP_REP_OK) then
     begin
          Log(LOG_LEVEL_SOCKS, 'UDP association successfull',[]);
          FDestAddr.sin_addr.S_addr := PDWORD(@Buf[4])^;
          FDestAddr.sin_port := PWord(@Buf[8])^;
          result := 0;
     end
     else
     begin
          case buf[1] of
             SOCKS5_REP_REP_GENFAIL: s := 'general SOCKS server failure';
             SOCKS5_REP_REP_CONN_NOT_ALLOWED: s := 'connection not allowed by ruleset';
             SOCKS5_REP_REP_NET_UNREACH: s := 'Network unreachable';
             SOCKS5_REP_REP_HOST_UNREACH: s := 'Host unreachable';
             SOCKS5_REP_REP_CONN_REFUSED: s := 'Connection refused';
             SOCKS5_REP_REP_TTL_EXPIRED: s := 'TTL expired';
             SOCKS5_REP_REP_CMD_NOT_SUPP: s := 'Command not supported';
             SOCKS5_REP_REP_ATYPE_NOT_SUPP: s := 'Address type not supported';
          else
             s := 'Unknown';
          end;
          Log(LOG_LEVEL_SOCKS, 'SOCKS UDP association failure: %s "%d"',[s, Integer(buf[1])]);
     end;
end;




function TSOCKS5Proxy.SendTo(s: TSocket; Buf: Pointer; len, flags: Integer;
  addrto: TSockAddr; tolen: Integer): Integer;
var
   buffer: PChar;
   size  : integer;
   pd    : PDWORD;
   pw    : PWORD;
   i     : dword;
   host  : string;
begin
     if DirectAddr.IsAddrDirect(addrto.sin_addr.S_addr) or (DirectAddr.IsPortDirect(addrto.sin_port))  then
     begin
          result := winsock2.sendto(s, buf, len, flags, addrto, tolen);
          Log(LOG_LEVEL_CONN, 'Direct sendto() to (%s: %d)',[GetDottedIP(addrto.sin_addr.S_addr), ntohs(addrto.sin_port)]);
          exit;
     end;

     GetMem(buffer, 65535);
     result := -1;

     DoOpenUDP;

     if not FUdpTunnelOpened then
     begin
          Log(LOG_LEVEL_CONN, 'no UdpTunnelOpened. Leave',[]);
          FreeMem(Buffer);
          exit;
     end
     else
          Log(LOG_LEVEL_CONN, 'UDP Tunnel opened...',[]);


     size := len;
     inc(buffer, 10);
     Move(Buf^, buffer^, len);
     dec(buffer, 10);

     buffer^ := SOCKS5_REQ_RSV;
     (buffer + 1)^ := SOCKS5_REQ_RSV;
     (buffer + 2)^ := SOCKS5_REQ_RSV;

//     (buffer + 3)^ := SOCKS5_REQ_ATYP_IP4;

     i := 3;
     if isPseudoDestAddr(addrto) then
     begin
          host := GetHost(addrto);
          (buffer + i)^ := SOCKS5_REQ_ATYP_DOMAIN;
          inc(i);
          (buffer + i)^ := Char(Byte(Length(host)));
          inc(i);
          Move(Host[1], (buffer + i)^, Length(host));
          inc(i, Length(host));
     end
     else
     begin
          (buffer + i)^ := SOCKS5_REQ_ATYP_IP4;
          { Should check buffer overflow }
          inc(i);
          pd := PDWORD(DWORD(buffer) + i);
          pd^ := addrto.sin_addr.S_addr;
          inc(i, SizeOf(integer));
     end;

     // Should check buffer overflow

     pw := PWORD(DWORD(buffer) + i);
     pw^ := addrto.sin_port;

     inc(i, SizeOf(word));

     inc(size, i);

     FDestAddr.sin_family := AF_INET;
     FDestAddr.sa_family := AF_INET;

     result := winsock2.sendto(FS2, buffer, size, flags, FDestAddr, SizeOf(FDestAddr));
     if result = -1 then
       Log(LOG_LEVEL_WARN, 'TSOCKS5Proxy.SendTo::winsock2.sendto error = %d (%s)',[result, WSocketErrorDesc(WSAGetLastError)]);

     FreeMem(Buffer);
     result := len;
     WSASetLastError(0);
end;

function TSOCKS5Proxy.DoUDPAuth(): Integer;
var
   Buf    : array [0..255] of char;
   I      : Integer;
begin
     result := -1;
     Buf[0] := #$01;
     I      := 1;
     Buf[I] := chr(Length(FLogin));
     Move(FLogin[1], Buf[I + 1], Length(FLogin));
     I := I + 1 + Length(FLogin);
     Buf[I] := chr(Length(FPassword));
     Move(FPassword[1], Buf[I + 1], Length(FPassword));
     I := I + 1 + Length(FPassword);

     Log(LOG_LEVEL_SOCKS, '[UDP] SOCKS doing login for %s',[FLogin]);
     SendData(@Buf, I);
     ZeroMemory(@Buf, SizeOf(Buf));
     RecvData(@buf, 2);

     if Buf[1] = #$00 then
     begin
          Log(LOG_LEVEL_SOCKS, '[UDP] SOCKS success login',[]);
          result := 0;
     end
     else
     begin
          DisplayMessage('[UDP] Login to SOCKS failed! "' + FLogin + '"');
          Log(LOG_LEVEL_SOCKS, '[UDP] SOCKS rejected',[]);
     end;
end;


function TSOCKS5Proxy.NegotiateUDP(): Integer;
var
   Buf: array [0..2] of char;
begin
     result := -1;
     Buf[0] := SOCKS5_VER;
     Buf[1] := #$01;      // Number of our methods

     if (Flogin <> '') then
       Buf[2] := SOCKS5_AUTH_PASS
     else
       Buf[2] := SOCKS5_AUTH_NONE;

     SendData(@Buf, 3);

     if WSAGetLastError() = WSAECONNREFUSED then
        exit;

     ZeroMemory(@Buf, SizeOf(Buf));

     RecvData(@buf, 3);

     if Buf[0] <> SOCKS5_VER then
     begin
          {* This should never occurs. Otherwise it indicates that our program is buggy
           *}
          Log(LOG_LEVEL_SOCKS, '[UDP] Error while trying to establish connection: Got first byte in reply %d (expected: %d)',[Integer(Buf[0]), Integer(SOCKS5_VER)]);
     end
     else if Buf[1] = SOCKS5_AUTH_NONE then
     begin
          Log(LOG_LEVEL_SOCKS, '[UDP] No authentication required',[]);
          result := 0;
     end
     else if Buf[1] = SOCKS5_AUTH_GSSAPI then
     begin
          Log(LOG_LEVEL_SOCKS, '[UDP] GSSAPI (not supported)',[]);
     end
     else if Buf[1] = SOCKS5_AUTH_PASS then
     begin
          Log(LOG_LEVEL_SOCKS, '[UDP] SOCKS server selected username/password',[]);
          result := DoUDPAuth();
    end
    else if Buf[1] = SOCKS5_AUTH_NO_METHODS then
    begin
         Log(LOG_LEVEL_SOCKS, '[UDP] No acceptable methods',[]);
    end;
end;


function TSOCKS5Proxy.DoOpenUDP(): Boolean;
begin
     result := FUdpTunnelOpened;
     if result then
       exit;
     Log(LOG_LEVEL_SOCKS, 'Using %s:%d for UDP association', [FHost, FPort]);

     // Ask SOCKS to UDP association
     result := (Self.UDP() = 0);
     Log(LOG_LEVEL_SOCKS, 'UDP() passed', []);

     FUdpTunnelOpened := result;
end;

function TSOCKS5Proxy.DoConnectUDP: Integer;
begin
     result := DoConnection;
end;

end.
