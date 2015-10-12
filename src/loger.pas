{*
 * File: ...................... loger.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Logging debug messages to file

 $Id: loger.pas,v 1.10 2005/12/19 06:09:02 bert Exp $

 $Log: loger.pas,v $
 Revision 1.10  2005/12/19 06:09:02  bert
 *** empty log message ***

 Revision 1.9  2005/12/02 06:07:28  bert
 *** empty log message ***

 Revision 1.8  2005/11/29 14:44:57  bert
 Rewritten Log procedure. There's an unreachable exception when Log() doing the CloseHandle() API call

 Revision 1.7  2005/05/12 04:21:21  bert
 *** empty log message ***

 Revision 1.6  2005/04/26 04:52:19  bert
 *** empty log message ***

 Revision 1.5  2005/04/08 20:04:13  bert
 Added LogException()

 Revision 1.4  2005/04/06 04:58:56  bert
 *** empty log message ***

 Revision 1.3  2005/03/08 16:13:00  bert
 Nonblocking mode for socket for UDP logging, because of freezing winsock with Outpost FW installed

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit loger;

interface
uses Windows, Classes, SysUtils, winsock2, cfg, misc, dialogs;

type
    TTrafficKind = (tkSend, tkRecv);
    TLogBlock = packed record
      ProcessId: DWORD;
      ProcessName: array[0..255] of Char;
      LogDate: TDateTime;
      LogFacility: Integer;
      LogText: array[0..4095] of Char;
    end;


   procedure OpenLog();
   procedure Log(level: integer; const fmt: string; args: array of const);stdcall;
   procedure LogException(str: string; E: Exception); stdcall;
   procedure HandleError(str1, str2: string);
   procedure RawLog(hsock : THandle; Buf: PChar; Size: integer; kind : TTrafficKind);
   procedure CloseLog();
   procedure Init;
   procedure Fini;


implementation
var
   DataStream: TFileStream;
   Crit      : TRTLCriticalSection;
   ProcName  : string;
   ProcInfo  : string;
   send_cnt  : integer = 0;
   recv_cnt  : integer = 0;
   s         : TSocket = INVALID_HANDLE_VALUE;
   hLogFile: integer = -1;

procedure OpenLog();
begin
     if Unloaded then
        exit;

     if hLogFile = -1 then
     begin
          if socks_log and not FileExists(socks_log_file) then
          begin
               if not FileExists(socks_log_file) then
               begin
                    hLogFile := FileCreate(socks_log_file);
                    if (hLogFile <> -1) then
                      FileClose(hLogFile);
               end;
          end;
          hLogFile := FileOpen(socks_log_file, fmOpenReadWrite or fmShareDenyNone);
     end;
end;

procedure SendLog(buf: PChar; bufsize: integer);
var
   addrto : TSockAddrIn;
   wsError: integer;
   WSAData: TWSAData;
   argp: u_long;
begin
     wsError := WSAGetLastError();

     addrto.sin_family := AF_INET;
     addrto.sin_port := htons(12541);
     addrto.sin_addr.S_addr := $0100007F; // inet_addr('127.0.0.1');

     if s = INVALID_HANDLE_VALUE then
     begin
          WSAStartup($101, WSAData);
          s := winsock2.socket(AF_INET, SOCK_DGRAM, 0);
          argp := 1;
          ioctlsocket(s, FIONBIO, argp); // Turn on non-blocking mode
     end;
     if s <> INVALID_HANDLE_VALUE then
       winsock2.sendto(s, Buf, bufsize, 0, addrto, sizeof(addrto));

     WSASetLastError(wsError);
end;


procedure Puts(const buf: string);
var
   wsError: integer;
begin
     if Unloaded then
        exit;


     {* Remember last winsock error. It need because winsock have strange love
      * to file operations. Maybe it because of HSOCK could be used with ReadFile()/WriteFile() ?
      *}
     wsError := WSAGetLastError();


     if hLogFile <> -1 then
     begin
          FileSeek(hLogFile, 0, soFromEnd);
          FileWrite(hLogFile, buf[1], length(buf));
          WSASetLastError(wsError);
     end
     else
        ShowMessage(Buf);

end;



procedure Log(level: integer; const fmt: string; args: array of const); stdcall;
var
   buf, fmtstr : string;
   LogBlock: TLogBlock;
begin
     if Unloaded then
        exit;

     if socks_log then
     begin
          EnterCriticalSection(Crit);

          if (level = LOG_LEVEL_PLUGIN) or
             (level = LOG_LEVEL_FREECAP) or
             (level = LOG_LEVEL_DEBUG) or
             ((level and socks_log_level) > 0) then
          begin
               case level of
                  LOG_LEVEL_INJ   : buf := buf + '[INJ] ';
                  LOG_LEVEL_CONN  : buf := buf + '[CONN] ';
                  LOG_LEVEL_SOCKS : buf := buf + '[SOCKS] ';
                  LOG_LEVEL_WARN  : buf := buf + '[WARN] ';
                  LOG_LEVEL_DEBUG : buf := buf + '[DEBUG] ';
                  LOG_LEVEL_PLUGIN: buf := buf + '[PLUGIN] ';
                  LOG_LEVEL_FREECAP: buf := buf + '[FreeCap] ';
               end;
               try
                  fmtstr := Format(fmt, args);
               except
                 on E: Exception do
                  fmtstr := 'Error in parameters: "' + fmt + '" (' + E.Message + ')';
               end;

               Buf := Buf + fmtstr + #13#10;


               LogBlock.ProcessId := GetCurrentProcessId();
               ZeroMemory(@LogBlock, SizeOf(LogBlock));
               strPLCopy(@LogBlock.ProcessName[0], ProcName, 255);
               LogBlock.LogDate := now;
               LogBlock.LogFacility := level;
               strPLCopy(@LogBlock.LogText[0], fmtstr, 4095);

               if cfg.socks_send_log then
                 SendLog(@LogBlock, SizeOf(LogBlock));

               Buf := procInfo + FormatDateTime('hh:nn:ss ', now) + Buf;

               Puts(Buf);
          end;
          LeaveCriticalSection(Crit);
     end;
end;


procedure RawLog(hsock : THandle; Buf: PChar; Size: integer; kind : TTrafficKind);
var
   fn: string;
begin
     if Unloaded then
        exit;

     EnterCriticalSection(Crit);

     if (socks_log = true) and (socks_log_traffic = true) then
     begin
          if (Buf = nil) or (Size <= 0) then
          begin
               LeaveCriticalSection(Crit);
               exit;
          end;

          if kind = tkSend then
          begin
               inc(send_cnt);
               fn := Format(socks_log_file + '.%d.%03d.asend',[hsock, send_cnt])
          end
          else
          begin
               inc(recv_cnt);
               fn := Format(socks_log_file + '.%d.%03d.brecv',[hsock, recv_cnt])
          end;

          if not FileExists(fn) then
          begin
               DataStream := TFileStream.Create(fn, fmCreate or fmOpenReadWrite);
               DataStream.Free;
          end;

          DataStream := TFileStream.Create(fn, fmOpenWrite or fmShareDenyNone);
          DataStream.Seek(0, soFromEnd);
          DataStream.WriteBuffer(Buf^, Size);
          DataStream.Free;
     end;
     LeaveCriticalSection(Crit);
end;


procedure CloseLog();
begin
     CloseHandle(hLogFile);
//     closesocket(s);
//     s := INVALID_HANDLE_VALUE;
end;

procedure LogException(str: string; E: Exception); stdcall;
begin
     Log(LOG_LEVEL_WARN, str + ' %s', [E.Message]);
end;

procedure Init;
begin
     InitializeCriticalSection(Crit);
     OpenLog();
     cfg.ReadConfig();

     ProcName := GetProcessName(GetCurrentProcessId);
     ProcInfo := Format('[%s] ', [ProcName, GetCurrentProcessId])
end;

procedure Fini;
begin
     DeleteCriticalSection(Crit);
     ProcInfo := '';
     socks_log_file := '';
     CloseLog();
end;


procedure HandleError(str1, str2: string);
begin
end;


end.
