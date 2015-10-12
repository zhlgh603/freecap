{*
 * File: ...................... Socks5Proxy.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... SOCKSv5 client side proxy implementation
                                according to RFC1928, RFC1929
 $Id: Socks5Proxy.pas,v 1.1 2005/04/27 06:39:37 bert Exp $

 $Log: Socks5Proxy.pas,v $
 Revision 1.1  2005/04/27 06:39:37  bert
 Initial import

 Revision 1.4  2005/04/18 04:49:55  bert
 *** empty log message ***

 Revision 1.3  2005/04/06 04:58:56  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***

}
unit Socks5Proxy;

interface

uses Windows, Messages, Classes, SysUtils, direct_addr,
     winsock2, loger, misc, cfg, AbstractProxy;

type
    TSOCKS5Proxy = class(TAbstractProxy)
    private
      function DoConnect(): integer;
      function DoAuth(): integer;
    public
      function connect(DestAddr: TSockAddr): integer; override;
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

     if GetLastError() = WSAECONNREFUSED then
        exit;

     ZeroMemory(@Buf, SizeOf(Buf));

     RecvData(@buf, 2);

     if Buf[0] <> SOCKS5_VER then
     begin
          {* This should never occurs. Otherwise it indicates that our program is buggy
           *}
     end
     else if Buf[1] = SOCKS5_AUTH_NONE then
     begin
          if FProxyMethod = METHOD_CONNECT then
            result := DoConnect()
          else
            result := 0;
     end
     else if Buf[1] = SOCKS5_AUTH_GSSAPI then
     begin
     end
     else if Buf[1] = SOCKS5_AUTH_PASS then
     begin
          result := DoAuth();
    end
    else if Buf[1] = SOCKS5_AUTH_NO_METHODS then
    begin
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

     SendData(@Buf, I);
     ZeroMemory(@Buf, SizeOf(Buf));
     RecvData(@buf, 2);

     if Buf[1] = #$00 then
     begin
          if FProxyMethod = METHOD_CONNECT then
            result := DoConnect()
          else
            result := 0;
          LastError := 'Login ok';
     end
     else
         LastError := 'Login to SOCKS failed';
end;

function TSOCKS5Proxy.DoConnect: integer;
var
   Buf     : array [0..255] of char;
   i       : Integer;
begin
     ZeroMemory(@Buf, SizeOf(Buf));
     Buf[0] := SOCKS5_VER;
     Buf[1] := SOCKS5_REQ_CMD_CONNECT;
     Buf[2] := SOCKS5_REQ_RSV;

     i := 3;
     Buf[I] := SOCKS5_REQ_ATYP_IP4;
     { Should check buffer overflow }
     inc(i);
     PDWORD(@Buf[I])^ := FDestAddr.sin_addr.S_addr;
     inc(i, SizeOf(integer));

     PWord(@Buf[I])^ := FDestAddr.sin_port;
     I := I + 2;
     SendData(@Buf, I);

     ZeroMemory(@Buf, SizeOf(Buf));

     RecvData(@Buf, I);

     if (buf[0] = SOCKS5_REP_VER) and (buf[1] = SOCKS5_REP_REP_OK) then
     begin
          result := 0;
          LastError := 'Tunnel opened';
     end
     else
     begin
          case buf[1] of
             SOCKS5_REP_REP_GENFAIL: LastError := 'Tunnel opening error: general SOCKS server failure';
             SOCKS5_REP_REP_CONN_NOT_ALLOWED: LastError := 'Tunnel opening error: connection not allowed by ruleset';
             SOCKS5_REP_REP_NET_UNREACH: LastError := 'Tunnel opening error: Network unreachable';
             SOCKS5_REP_REP_HOST_UNREACH: LastError := 'Tunnel opening error: Host unreachable';
             SOCKS5_REP_REP_CONN_REFUSED: LastError := 'Tunnel opening error: Connection refused';
             SOCKS5_REP_REP_TTL_EXPIRED: LastError := 'Tunnel opening error: TTL expired';
             SOCKS5_REP_REP_CMD_NOT_SUPP: LastError := 'Tunnel opening error: Command not supported';
             SOCKS5_REP_REP_ATYPE_NOT_SUPP: LastError := 'Tunnel opening error: Address type not supported';
          else
             LastError := 'Tunnel opening error: Unknown';
          end;
          result := -1;
     end;
end;




end.
