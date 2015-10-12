{*
 * File: ...................... check2ndcopy.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... For prevent secondary loading of another copy of inject.dll

 $Id: check2ndcopy.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

 $Log: check2ndcopy.pas,v $
 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit check2ndcopy;

interface
uses Windows, SysUtils, cfg, loger;

implementation
var
   hMutex: THandle;

initialization

{* Create a mutex with unique name
 *}
hMutex := CreateMutex(nil, True, PChar(Format('FREECAP$PID%d',[GetCurrentProcessId])));
if (hMutex = 0) or (GetLastError() = ERROR_ALREADY_EXISTS) then
begin
     Log(LOG_LEVEL_WARN, 'Mutex found for pid = %d. Leave', [GetCurrentProcessId]);
     halt; // inject.dll already loaded, leave
end;


end.
 