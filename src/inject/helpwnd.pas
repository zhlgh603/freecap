{*
 * File: ...................... helpwnd.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Helper window for trapping messages.

 $Id: helpwnd.pas,v 1.3 2005/04/26 04:52:19 bert Exp $

 $Log: helpwnd.pas,v $
 Revision 1.3  2005/04/26 04:52:19  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***

}
unit helpwnd;

interface
uses Windows, Messages, Classes, SysUtils, loger, cfg, misc, winsock2;

    procedure Init;
    procedure Fini;

var
   HWindow1 : HWND;
   wMsg1: UINT;
   result1: THandle;
   buflen1: Integer;

implementation
uses hook {$IFDEF DEBUG}, memleaks{$ENDIF};

var
   handle : HWND;

{ THelpWnd }

procedure HandleReload(hWnd: HWND);
begin
     if (hWnd <> 0) and (GetParent(hWnd) = 0) and (GetTopWindow(hWnd) = 0) then
     begin
          Reload;
          Log(LOG_LEVEL_INJ, 'FreeCap tells to reload config. Reloading...',[]);
     end;
end;


function DefWndProcedure(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
     if Msg = WM_CLOSE then
     begin
          PostQuitMessage(0);
          Result:=0;
     end

     else if Msg = WM_CONFIG_RELOAD then
     begin
          HandleReload(hwnd);
          result := 0;
     end
     else if (Msg = WM_PLEASE_REPLY_WHO_ALIVE) then
     begin
          SendMessage(wParam, WM_I_AM_ALIVE, GetTopWindow(hWnd), GetCurrentProcessId());
          result := 0;
     end
     else
         Result:=DefWindowProc(hWnd, Msg, wParam, lParam);
end;

procedure TimerProc(hwnd: HWND; uMsg: UINT; idEvent: UINT; dwTime: DWORD); stdcall;
begin
{$IFDEF DEBUG}
//     Log(LOG_LEVEL_DEBUG, 'Proxy threads: %d; Memory allocated: %u', [proxy.ProxyArray.Count, memleaks.GetMemAllocated()]);
{$ENDIF}
end;

procedure Init;
var
   WND: WNDCLASS;
begin
     ZeroMemory(@WND, SizeOf(WND));
     WND.style := 0;
     WND.lpfnWndProc := @DefWndProcedure;
     WND.hInstance := hInstance;
     WND.hIcon:=LoadIcon(hInstance,'MAINICON');
     WND.hCursor:=LoadCursor(0,IDC_ARROW);
     WND.hbrBackground:=COLOR_BTNFACE+1;
     WND.lpszClassName := 'someclass';

     Windows.RegisterClass(WND);
     handle := CreateWindow('someclass','HelperWnd',WS_THICKFRAME or WS_OVERLAPPED or WS_SYSMENU,Integer(CW_USEDEFAULT),Integer(CW_USEDEFAULT),Integer(CW_USEDEFAULT),Integer(CW_USEDEFAULT),0,0,hInstance,nil);

     SetTimer(handle, 1, 10000, @TimerProc);
end;

procedure Fini;
begin

end;


end.
