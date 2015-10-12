{*
 * File: ...................... cfg.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Manage main settings in config file

 $Id: cfg.pas,v 1.7 2005/11/28 08:53:59 bert Exp $

 $Log: cfg.pas,v $
 Revision 1.7  2005/11/28 08:53:59  bert
 *** empty log message ***

 Revision 1.6  2005/05/27 12:45:47  bert
 *** empty log message ***

 Revision 1.5  2005/05/12 04:21:21  bert
 *** empty log message ***

 Revision 1.4  2005/04/26 04:52:19  bert
 *** empty log message ***

 Revision 1.3  2005/03/08 16:10:58  bert
 Removed old config (%WINDDIR%\freecap.ini) support

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit cfg;

interface
uses Windows, Messages, sysutils, inifiles, common, misc, reg_config;

const
     WM_MINERESTORE = WM_USER + $877;

var
     WM_CONFIG_RELOAD: UINT;     // Signal to reload config

     WM_PLEASE_REPLY_WHO_ALIVE: UINT; // Signal to send reponse of
                                      // SOCKSified programs to FreeCap
                                      // wParam -- Handle to FreeCap main window

     WM_I_AM_ALIVE: UINT;             // Repsone from SOCKSified program.
                                      // wParam contains Process id (PID)
                                      // lParam -- Handle of main window

     WM_QUERY_PERF_PARAM: UINT;       // Signal to query some perfomance params
     WM_QUERY_PERF_PARAM_REPLY: UINT; // it's reply

const
   LOG_LEVEL_NONE    = $00000000;
   LOG_LEVEL_INJ     = $00000001;
   LOG_LEVEL_CONN    = $00000002;
   LOG_LEVEL_SOCKS   = $00000004;
   LOG_LEVEL_WARN    = $00000008;
   LOG_LEVEL_PLUGIN  = $00000010;
   LOG_LEVEL_DEBUG   = $00000020;
   LOG_LEVEL_FREECAP = $00000040;
   LOG_LEVEL_MEM     = $00000080;

   PROXY_VER_SOCKS4 = 4;
   PROXY_VER_SOCKS5 = 5;
   PROXY_VER_HTTP   = 1;

   METHOD_CONNECT = 1;
   METHOD_BIND = 2;
   METHOD_UDP = 3;
   METHOD_UDP_WITH_CONNECT = 4;

   PERF_PARAM_PROXY_THREADS = 0;
   PERF_PARAM_MEM_ALLOCATED = 1;

var
   socks_log: Boolean;
   socks_log_file: string;
   socks_log_level: integer;
   socks_log_traffic: Boolean;
   socks_udp_hack   : Boolean = False;
   socks_send_log   : Boolean = True; 

   socks_share_using: Boolean;
   socks_share_guid: string;
   socks_share_sharing: Integer; // 0 - only anonymous, 1 - and other

   force_bind: Boolean = false;

   prog_one_instance : Boolean;
   prog_sys_startup  : Boolean;
   prog_run_tray     : Boolean;
   prog_min_tray     : Boolean;
   prog_resolve_dns  : integer; // 0 for local; 1 - local then remote; 2 - remote

   prog_add_caption_text: Boolean;
   prog_show_messages: Boolean;
   prog_view_style   : integer;
   prog_lang         : Integer = 0;
   prog_hide_on_close: Boolean;

   prog_advanced_hooking: Boolean = True;

   UseWideCapCfg     : Boolean = false;  
   isFreecapRegistry: Boolean;


//   function isConfigExists(cfg_file: string): Boolean;
   procedure ReadConfig();
   procedure SaveConfig();


implementation
{
function isConfigExists(cfg_file: string): Boolean;
var
   buf: array[0..MAX_PATH] of Char;
begin
     if ExtractFilePath(cfg_file) = '' then
     begin
          ZeroMemory(@buf, MAX_PATH);
          GetWindowsDirectory(buf, MAX_PATH);
          if not FileExists(GetFreeCapConfig()) then
            cfg_file := string(buf) + '\' + cfg_file
          else
            cfg_file := GetFreeCapConfig();
     end;
     result := FileExists(cfg_file);
end;
}


procedure ReadConfig();
var
   Ini: TRegConfig;
   Buf: array[0..MAX_PATH] of Char;
begin
     WM_CONFIG_RELOAD := RegisterWindowMessage('WM_CONFIG_RELOAD');
     WM_PLEASE_REPLY_WHO_ALIVE := RegisterWindowMessage('WM_PLEASE_REPLY_WHO_ALIVE');
     WM_I_AM_ALIVE := RegisterWindowMessage('WM_I_AM_ALIVE');
     WM_QUERY_PERF_PARAM := RegisterWindowMessage('WM_QUERY_PERF_PARAM');
     WM_QUERY_PERF_PARAM_REPLY := RegisterWindowMessage('WM_QUERY_PERF_PARAM_REPLY');

     if (GetEnvironmentVariable('FreeCAPConfigFile', @Buf, SizeOF(Buf))) <> 0 then
       Ini := TRegConfig.Create(Buf)
     else
       Ini := TRegConfig.Create('freecap.xml');

     socks_log := Ini.ReadBool(PART_MAIN, 'SOCKS', 'Log', False);

     ZeroMemory(@Buf, SizeOf(Buf));
     if (GetEnvironmentVariable('FreeCAPLogFile', @Buf, SizeOF(Buf))) <> 0 then
     begin
          socks_log_file := Buf;
          socks_log := True;
     end
     else
         socks_log_file := ExpandFileName(Ini.ReadString(PART_MAIN, 'SOCKS', 'LogFile', ''));

     ZeroMemory(@Buf, SizeOf(Buf));
     if (GetEnvironmentVariable('FreeCAPLogLevel', @Buf, SizeOF(Buf))) <> 0 then
     begin
          socks_log_level := StrToInt(Buf);
     end
     else
         socks_log_level := Ini.ReadInteger(PART_MAIN, 'SOCKS', 'LogLevel', 0);


     if (socks_log_level = LOG_LEVEL_NONE) then
       socks_log_traffic := False
     else
       socks_log_traffic := Ini.ReadBool(PART_MAIN, 'SOCKS', 'LogTraffic', False);

     socks_udp_hack := Ini.ReadBool(PART_MAIN, 'SOCKS', 'UDPHack', False);

     prog_one_instance := Ini.ReadBool(PART_MAIN, 'Main', 'OneInstance', False);
     prog_sys_startup := Ini.ReadBool(PART_MAIN, 'Main', 'SysStartup', False);
     prog_run_tray := Ini.ReadBool(PART_MAIN, 'Main', 'RunTray', False);
     prog_min_tray := Ini.ReadBool(PART_MAIN, 'Main', 'MinimizeToTray', False);
     prog_view_style := Ini.ReadInteger(PART_MAIN, 'Main', 'ViewStyle', 0);
     prog_resolve_dns := Ini.ReadInteger(PART_MAIN, 'Main', 'ResolveDNS', 2);
     prog_add_caption_text := Ini.ReadBool(PART_MAIN, 'Main', 'AddToCaptionText', True);
     prog_show_messages := Ini.ReadBool(PART_MAIN, 'Main', 'ShowMessages', True);
     prog_hide_on_close := Ini.ReadBool(PART_MAIN, 'Main', 'HideOnClose', True);
     prog_advanced_hooking := Ini.ReadBool(PART_MAIN, 'Main', 'AdvancedHooking', True);

     socks_share_using := Ini.ReadBool(PART_MAIN, 'Main', 'SocksShare', False);
     socks_share_guid := Ini.ReadString(PART_MAIN, 'Main', 'SocksShareGuid', '');
     socks_share_sharing := Ini.ReadInteger(PART_MAIN, 'Main', 'SocksShareSharing', 0);

     socks_send_log := Ini.ReadBool(PART_MAIN, 'Main', 'SocksSendLog', True);

     if prog_lang = 0 then
       prog_lang := Ini.ReadInteger(PART_MAIN, 'Main', 'Language', 0);

     if socks_share_using and (socks_share_guid = '') then
       socks_share_guid := GetNewGUID;

     Ini.Free;
end;

procedure SaveConfig();
var
  Ini: TRegConfig;
begin
     Ini := TRegConfig.Create('freecap.xml');

     Ini.WriteBool(PART_MAIN, 'SOCKS', 'Log', socks_log);
     Ini.WriteString(PART_MAIN, 'SOCKS', 'LogFile', socks_log_file);
     Ini.WriteInteger(PART_MAIN, 'SOCKS', 'LogLevel', socks_log_level);
     Ini.WriteBool(PART_MAIN, 'SOCKS', 'LogTraffic', socks_log_traffic);
     Ini.WriteBool(PART_MAIN, 'SOCKS', 'UDPHack', socks_udp_hack);

     Ini.WriteBool(PART_MAIN, 'Main', 'OneInstance', prog_one_instance);
     Ini.WriteBool(PART_MAIN, 'Main', 'SysStartup', prog_sys_startup);
     Ini.WriteBool(PART_MAIN, 'Main', 'RunTray', prog_run_tray);
     Ini.WriteBool(PART_MAIN, 'Main', 'MinimizeToTray', prog_min_tray);
     Ini.WriteInteger(PART_MAIN, 'Main', 'ResolveDNS', prog_resolve_dns);
     Ini.WriteBool(PART_MAIN, 'Main', 'AddToCaptionText', prog_add_caption_text);
     Ini.WriteBool(PART_MAIN, 'Main', 'ShowMessages', prog_show_messages);
     Ini.WriteInteger(PART_MAIN, 'Main', 'Language', prog_lang);
     Ini.WriteBool(PART_MAIN, 'Main', 'HideOnClose', prog_hide_on_close);
     Ini.WriteBool(PART_MAIN, 'Main', 'AdvancedHooking', prog_advanced_hooking);


     Ini.WriteBool(PART_MAIN, 'Main', 'SocksShare', socks_share_using);
     Ini.WriteString(PART_MAIN, 'Main', 'SocksShareGuid', socks_share_guid);
     Ini.WriteInteger(PART_MAIN, 'Main', 'SocksShareSharing', socks_share_sharing);
     Ini.WriteBool(PART_MAIN, 'Main', 'SocksSendLog', socks_send_log);

     Ini.Free;

     PostMessage(HWND_BROADCAST, WM_CONFIG_RELOAD, 0, 0);
end;

initialization
isFreecapRegistry := CheckFreecapRegistry();
ReadConfig();


end.
