{*
 * File: ...................... loger.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Logging debug messages to file

 $Id: loger.pas,v 1.4 2005/05/12 04:21:22 bert Exp $

 $Log: loger.pas,v $
 Revision 1.4  2005/05/12 04:21:22  bert
 *** empty log message ***

 Revision 1.3  2005/04/06 04:58:56  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit loger;

interface
uses Windows, stub;

   procedure Log(level: integer; fmt: string; args: array of const);stdcall;
   procedure DumpBuf(prefix: string; Buf: Pointer; Size: integer);
   procedure HandleError(str1, str2: string);

implementation
uses cfg;

procedure Log(level: integer; fmt: string; args: array of const); stdcall;
begin
     UpcallIntf.pLogMessage(level, PChar(fmt), args);
end;


procedure DumpBuf(prefix: string; Buf: Pointer; Size: integer);
var
   s: string;
   i: integer;
begin
     s := '';
     for i := 0 to Size - 1 do
     if PChar(Pointer(DWORD(Buf) + DWORD(i)))^ = #0 then
        s := s  + '0 '
     else
        s := s + PChar(Pointer(DWORD(Buf) + DWORD(i)))^ + ' ';

     Log(LOG_LEVEL_DEBUG, '%s(len = %d; data = %s)', [prefix, Size, s]);
end;

procedure HandleError(str1, str2: string);
begin
end;

end.
