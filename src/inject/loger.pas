{*
 * File: ...................... loger.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Logging debug messages to file

 $Id: loger.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

 $Log: loger.pas,v $
 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit loger;

interface
uses Windows, Classes, SysUtils, winsock2, cfg, misc;

type
    TTrafficKind = (tkSend, tkRecv);

   procedure OpenLog();
   procedure Log(level: integer; fmt: string; args: array of const);stdcall;
   procedure RawLog(hsock : THandle; Buf: PChar; Size: integer; kind : TTrafficKind);
   procedure CloseLog();
   procedure Init;
   procedure Fini;


implementation
var
   DataStream: TFileStream;
   Crit      : TRTLCriticalSection;
   ProcInfo  : string;
   send_cnt  : integer = 0;
   recv_cnt  : integer = 0;

procedure OpenLog();
var
   hFile: integer;
begin
     if Unloaded then
        exit;

     if socks_log and not FileExists(socks_log_file) then
     begin
          if not FileExists(socks_log_file) then
          begin
               hFile := FileCreate(socks_log_file);
               if (hFile <> -1) then
                 FileClose(hFile);
          end;
     end;
end;

procedure Puts(buf: PChar);
var
   wsError: integer;
   hFile  : integer;
begin
     if Unloaded then
        exit;

     {* Remember last winsock error. It need because winsock have strange love
      * to file operations. Maybe it because of HSOCK could be used with ReadFile()/WriteFile() ?
      *}
     wsError := WSAGetLastError();

     if not FileExists(socks_log_file) then
     begin
          hFile := FileCreate(socks_log_file);
          if hFile <> -1 then
            FileClose(hFile);
     end;


     hFile := FileOpen(socks_log_file, fmOpenWrite or fmShareDenyWrite);

     if hFile <> -1 then
     begin
          FileSeek(hFile, 0, soFromEnd);
          FileWrite(hFile, buf^, strlen(buf));
          FileClose(hFile);
     end;

     WSASetLastError(wsError);
end;



procedure Log(level: integer; fmt: string; args: array of const); stdcall;
var
   buf : string;
begin
     if Unloaded then
        exit;

     if socks_log then
     begin
//          Puts(@(Fmt + #13#10)[1]);

          Buf := procInfo + FormatDateTime('dd-mmm-yyyy hh:nn:ss ', now);

          case level of
            LOG_LEVEL_INJ   : buf := buf + '[INJ] ';
            LOG_LEVEL_CONN  : buf := buf + '[CONN] ';
            LOG_LEVEL_SOCKS : buf := buf + '[SOCKS] ';
            LOG_LEVEL_WARN  : buf := buf + '[WARN] ';
            LOG_LEVEL_DEBUG : buf := buf + '[DEBUG] ';
          end;
          Buf := Buf + Format(fmt + #13#10, args);

          if (level and socks_log_level) > 0 then
            Puts(@Buf[1]);
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

end;

procedure Init;
begin
     InitializeCriticalSection(Crit);
     cfg.ReadConfig();
     ProcInfo := Format('[%s] (0x%X) ',[GetProcessName(GetCurrentProcessId), GetCurrentProcessId])
end;

procedure Fini;
begin
     DeleteCriticalSection(Crit);
end;


end.
