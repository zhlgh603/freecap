{*
 * File: ...................... Socks4Proxy.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... SOCKS v4 client side proxy implementation

 $Id: Socks4Proxy.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

 $Log: Socks4Proxy.pas,v $
 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit Socks4Proxy;

interface
uses Windows, Messages, Classes, SysUtils,
     winsock2, loger, misc, cfg, AbstractProxy;

type
    TSOCKS4Proxy = class(TAbstractProxy)
    public
      function connect(DestAddr: TSockAddr): integer; override;
    end;

const
     { SOCKS v4 related constants }
     SOCKS4_VER                    = #04;
     SOCKS4_CMD_CONNECT            = #01;
     SOCKS4_CMD_BIND               = #02;
     SOCKS4_REP_VER                = #00;
     SOCKS4_REP_VER_4              = #04;
     SOCKS4_REP_REQ_GRANTED        = #90;
     SOCKS4_REP_REQ_REJ_OR_FAIL    = #91;
     SOCKS4_REP_REQ_REJ_IDENTD     = #92;
     SOCKS4_REP_REQ_REJ_IDENTD_DIFF= #93;

implementation

{ TSOCKS4Proxy }


function TSOCKS4Proxy.connect(DestAddr: TSockAddr): integer;
var
   Buf: array [0..255] of char;
   i: integer;
   host: string;
begin
     inherited Connect(DestAddr);
     result := -1;

     ZeroMemory(@Buf, SizeOf(Buf));
     Buf[0] := SOCKS4_VER;
     Buf[1] := SOCKS4_CMD_CONNECT;
     i := 2;

     PWord(@Buf[i])^ := DestAddr.sin_port;               // DSTPORT
     inc(i, SizeOf(Word));

     if isPseudoDestAddr() then
     begin
          host := DestAddrHost;
          inc(i, 3); // First three zero bytes indicates a hostname not IP
          Move(Host[1], Buf[i], Length(host));
          inc(i, Length(host) + 1); // trailing zero byte after hostname
     end
     else
     begin
          PDWORD(@Buf[i])^ := DestAddr.sin_addr.S_addr;       // DSTIP
          inc(i, SizeOf(DWORD));
     end;


     if (Flogin <> '') then
     begin
          Move(Flogin[1], Buf[I], Length(Flogin));
          inc(i, Length(Flogin));
     end;
     inc(i); // trailing zero byte

     SendData(@Buf, I);
     ZeroMemory(@Buf, SizeOf(Buf));

     RecvData(@Buf, 8);

     if (Buf[0] <> SOCKS4_REP_VER) and (Buf[0] <> SOCKS4_REP_VER_4) then
     begin
          Log(LOG_LEVEL_SOCKS, 'Error while trying to establish connection: Got first byte in reply %d (expected: %d)',[Integer(Buf[0]), Integer(SOCKS4_REP_VER)]);
     end
     else
     begin
       case Buf[1] of
       SOCKS4_REP_REQ_GRANTED: begin
                 Log(LOG_LEVEL_SOCKS, 'Request granted',[]);
                 result := 0;
            end;
       SOCKS4_REP_REQ_REJ_OR_FAIL: begin
                 Log(LOG_LEVEL_SOCKS, 'Request rejected or failed' ,[]);
            end;
       SOCKS4_REP_REQ_REJ_IDENTD: begin
                 Log(LOG_LEVEL_SOCKS, 'Request rejected becasue SOCKS server cannot connect to identd on the client',[]);
            end;
       SOCKS4_REP_REQ_REJ_IDENTD_DIFF: begin
                 Log(LOG_LEVEL_SOCKS, 'Request rejected because the client program and identd report different user-ids',[]);
            end;
       else
           Log(LOG_LEVEL_SOCKS, 'Unknown error = %d', [Byte(Buf[1])]);
       end;
     end;
end;


end.
