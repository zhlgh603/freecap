{*
 * File: ...................... Socks4Proxy.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... HTTP client side proxy implementation
                                according to RFC2817
 $Id: HTTPProxy.pas,v 1.2 2005/05/12 04:21:22 bert Exp $

 $Log: HTTPProxy.pas,v $
 Revision 1.2  2005/05/12 04:21:22  bert
 *** empty log message ***

 Revision 1.1  2005/04/27 06:39:37  bert
 Initial import

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit HTTPProxy;

interface
uses Windows, Messages, Classes, SysUtils,
     winsock2, loger, misc, cfg, base64, AbstractProxy{, encryption, ntlmmsgs};

type
    THTTPProxy = class(TAbstractProxy)
    public
      function connect(DestAddr: TSockAddr): integer; override;
    end;

implementation

{ THTTPProxy }

function THTTPProxy.connect(DestAddr: TSockAddr): integer;
var
   Buf: array [0..1023] of char;
   s  : string;
   res: integer;
   code: integer;
begin
     inherited connect(DestAddr);
     result := -1;

     s := Format('CONNECT %s:%d HTTP/1.1'#13#10,[DestAddrHost, ntohs(FDestAddr.sin_port)]);
     s := s + Format('Host: %s:%d'#13#10, [DestAddrHost, ntohs(FDestAddr.sin_port)]);
     if (FLogin <> '') then
     begin
          s := s + Format('Proxy-Authorization: Basic %s'#13#10,[MimeEncodeString(FLogin + ':' + FPassword)]);
     end;
     s := s + #13#10;

     SendData(@s[1], Length(s));
     res := RecvData(@Buf, SizeOf(Buf));

     if res <= 0 then
        exit;

     s := copy(buf, 0, res);
     Delete(s, pos(#13#10, s), MaxInt);

     if pos('HTTP', s) = 0 then
     begin
          LastError := 'Not a HTTPS proxy';
          result := -1;
          exit;
     end;


     LastError := s;


     Delete(s, 1, pos(' ', s));
     Delete(s, pos(' ', s), MaxInt);
     code := StrToIntDef(s, -1);

     if (code >= 200) and (code < 300) then
     begin
          result := 0;
     end
     else
     begin
          exit;
     end;
end;

end.
