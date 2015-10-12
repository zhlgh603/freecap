{*
 * File: ...................... common.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev
 * Desc: ...................... Miscleanous functions.

 $Id: common.pas,v 1.3 2005/04/06 04:58:56 bert Exp $

 $Log: common.pas,v $
 Revision 1.3  2005/04/06 04:58:56  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit common;

interface
uses Windows, SysUtils;

   function OEM(const St: string): string;
   function GetErrorDesc(dwError: DWORD): String;

implementation

const
     sCopy = 'FreeCap (c) Copyright 2004 by Max Artemev. All rights reserved.';




function CalcNetMask(bits: DWORD): DWORD;
begin
     result := DWORD((1 shl bits) - 1);
end;



function GetDottedIP(const IP: DWORD): string;
begin

     result := Format('%d.%d.%d.%d',[IP and $FF,
                                     IP shr 8 and $FF,
                                     IP shr 16 and $FF,
                                     IP shr 24]);
end;


function MAKELANGID(p, s: WORD): DWORD;
begin
     result := (s shl 10) or p;
end;


function OEM(const St: string): string;
var
  Len: Integer;
begin
  Len := Length(St);
  if Len > 0 then
  begin
    SetLength(Result, Len);
    CharToOemBuff(PChar(St), PChar(Result), Len);
  end;
end;


function GetErrorDesc(dwError: DWORD): String;
var
   Buf: PChar;
begin
     Buf := AllocMem(4096);
     FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,  nil, dwError, 0, Buf,  4096,  nil);
     result := String(Buf);
     FreeMem(Buf);
end;




end.
