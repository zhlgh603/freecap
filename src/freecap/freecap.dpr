{*
 * File: ......................... freecap.dpr
 * Autor: ........................ Max Artemev (Bert Raccoon),
 * Copyright: .................... (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ......................... Delphi project file


  $Id: freecap.dpr,v 1.11 2005/12/19 06:09:02 bert Exp $

  $Log: freecap.dpr,v $
  Revision 1.11  2005/12/19 06:09:02  bert
  *** empty log message ***

  Revision 1.10  2005/10/31 14:26:22  bert
  *** empty log message ***
}
program freecap;

uses
  Forms,
  Windows,
  SysUtils,
  Menus,
  Dialogs,
  OneHist in 'OneHist.pas',
  sockschain in '..\sockschain.pas',
  cfg in '..\cfg.pas',
  loger in '..\loger.pas',
  Main in 'Main.pas' {frmMain},
  config in 'config.pas' {frmConfig},
  profile in 'profile.pas' {frmProfile},
  about in 'about.pas' {frmAbout},
  DebugInject in 'DebugInject.pas',
  RemoteThreadInject in 'RemoteThreadInject.pas',
  SuspendInject in 'SuspendInject.pas',
  common in '..\common.pas',
  base64 in '..\base64.pas',
  direct_addr in '..\direct_addr.pas',
  VersInfo in 'versinfo.pas',
  misc in '..\misc.pas',
  winsock2 in '..\winsock2.pas',
  Pinger in 'Pinger.pas',
  plugin_disp in '..\plugin_disp.pas',
  plugin in '..\plugin.pas',
  langs in 'langs.pas',
  newProxy in 'newProxy.pas' {frmNewProxy},
  textlangs in '..\textlangs.pas',
  xml_config in '..\xml_config.pas',
  abs_config in '..\abs_config.pas',
  reg_config in '..\reg_config.pas',
  rpcrt in '..\rpcrt.pas',
  newDirectIP in 'newDirectIP.pas' {frmNewDirectIP},
  cfg_select in 'cfg_select.pas' {frmCfgSelect},
  updater in 'updater.pas' {frmUpdates};

{$R *.RES}
var
   WSAData: TWSAData;
   LCID: integer;
begin

     cfg.ReadConfig;

     winsock2.Init();
     WSAStartup($202, WSAData);

     SetEnvironmentVariable('FreeCapStartupDir', PChar(ExtractFilepath(ParamStr(0))));
     textlangs.Init;
     langs.Init;


//   plugin_disp.Init();


   Application.CreateForm(TfrmMain, frmMain);

   Application.CreateForm(TfrmNewProxy, frmNewProxy);
   Application.CreateForm(TfrmNewDirectIP, frmNewDirectIP);
   Application.CreateForm(TfrmUpdates, frmUpdates);
  if cfg.prog_run_tray then
   begin
        frmMain.TrayIcon1.Enabled := True;
        Application.ShowMainForm := False;
        ShowWindow(Application.Handle, SW_HIDE);
   end;

   Application.CreateForm(TfrmConfig, frmConfig);
   Application.CreateForm(TfrmProfile, frmProfile);
   Application.CreateForm(TfrmAbout, frmAbout);


   if prog_lang = 0 then
   begin
        LCID := GetSystemDefaultLCID();
        LCID := LCID and $FFFF;
   end
   else
   begin
        LCID := prog_lang;
   end;
{
   for i:=0 to Screen.FormCount - 1 do
     if Screen.Forms[i].Tag = 0 then
       SaveText(Screen.Forms[i], 0, 0);
}
   try
      SupportedLangs.SwitchAllFormsTo(LCID and $3F, LCID shr 10);
   except
   end;


   Application.Run;
end.
