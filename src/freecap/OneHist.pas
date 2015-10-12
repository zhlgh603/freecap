{
  $Id: OneHist.pas,v 1.3 2005/05/27 12:45:47 bert Exp $

  $Log: OneHist.pas,v $
  Revision 1.3  2005/05/27 12:45:47  bert
  *** empty log message ***

  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}

unit OneHist;

interface

implementation
uses Windows, Messages, SysUtils, cfg, Forms;

var
  Mutex : THandle;
  hwnd  : THandle;

function StopLoading() : boolean;
begin
   Mutex := CreateMutex(nil,false,'MYSUPERCOOLMUTEX$FREESOCKSCAP');
   Result := (Mutex = 0) or // If mutex hasn't been created
   (GetLastError = ERROR_ALREADY_EXISTS); // or already exists
end;


initialization
  if StopLoading() then
  begin
       cfg.ReadConfig;
       if not cfg.prog_one_instance then
          exit;

       hwnd := FindWindow(nil, 'FreeCap');
       if (hwnd <> 0) then
       begin
            {* Good tone: show program window when trying to run second instance.
             *}
            PostMessage(hWnd, WM_MINERESTORE, 0, 0);
            SetForegroundWindow(hwnd);
       end;
       halt;
  end;
finalization
  if Mutex <> 0 then
    CloseHandle(Mutex);
end.

