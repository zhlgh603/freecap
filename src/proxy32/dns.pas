{*
 * File: ...................... dns.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Hook DNS queries for mapping via SOCKS server.

 $Id: dns.pas,v 1.3 2005/12/19 06:09:02 bert Exp $

 $Log: dns.pas,v $
 Revision 1.3  2005/12/19 06:09:02  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit dns;

interface

uses Windows, Classes, SysUtils, winsock2, misc, stub;


  function GetAddrString(ip: DWORD): string;

implementation


function GetAddrString(ip: DWORD): string;
var
   buf : array[0..255] of char;
begin
     if UpcallIntf.pIsPseudoAddr(ip) then
     begin
          UpcallIntf.pFindhost(IP, @buf, SizeOf(buf));
          result := string(Buf);
     end
     else
        result := GetDottedIP(ip);
end;





end.
