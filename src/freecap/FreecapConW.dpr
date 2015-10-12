{*
 * File: ......................... freecapCon.dpr
 * Autor: ........................ Max Artemev (Bert Raccoon),
 * Copyright: .................... (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ......................... Console Freecap version


  $Id: FreecapConW.dpr,v 1.1 2005/10/31 14:26:22 bert Exp $

  $Log: FreecapConW.dpr,v $
  Revision 1.1  2005/10/31 14:26:22  bert
  *** empty log message ***

  Revision 1.4  2005/05/12 04:21:22  bert
  *** empty log message ***

  Revision 1.3  2005/03/08 16:50:49  bert
  *** empty log message ***

  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***


}
program FreecapConW;

uses
  Windows,
  SysUtils,
  Dialogs,
  SuspendInject in 'SuspendInject.pas',
  common in '..\common.pas',
  misc in '..\misc.pas',
  cfg in '..\cfg.pas',
  xml_config in '..\xml_config.pas',
  base64 in '..\base64.pas',
  sockschain in '..\sockschain.pas',
  loger in '..\loger.pas',
  rpcrt in '..\rpcrt.pas',
  abs_config in '..\abs_config.pas',
  reg_config in '..\reg_config.pas',
  direct_addr in '..\direct_addr.pas',
  winsock2 in '..\winsock2.pas';

{$I '..\version.inc'}
{$R *.RES}
var
   i: integer;
   SuspendInjector: TSuspendInjector;
   WorkDir, ProgramName, LibName, Params, logfile, loglevel : string;
   BasePath: string;
   OptEnd: Boolean;
   s: string;
begin


   if (ParamCount = 0) or ((ParamStr(1) = '/?') or (ParamStr(1) = '/h') or (ParamStr(1) = '-h') or (ParamStr(1) = '--help')) then
   begin
        s := 'FreeCap v' + FREECAP_VERSION + ' console version. Copyright (c) 2005 by Max Artemev'#13#10;
        s := s + ExtractFileName(ParamStr(0)) + ' <options> <program.exe> "program parameters"'#13#10;
        s := s + 'Where options are:'#13#10;
        s := s + '    -b <base path> '#9'Path where FreeCap is installed, Default is $(APPDATA)\FreeCap'#13#10;
        s := s + '    -f <config.xml> '#9'Path to SOCKS config file. Default is $(WINDIR)\freecap.xml'#13#10;
        s := s + '    -w <workdir>'#9'Set the working directory of running program to <workdir>.'#13#10;
        s := s + '       Use double quotas if directory contains spaces. If omitted, working'#13#10;
        s := s + '       directory will be set to program path'#13#10;
        s := s + '    -o <logfile.txt>'#9'Set the logfile to <logfile.txt>'#13#10;
        s := s + '    -u <library.dll>'#9'Use specified library to inject into process'#13#10;
        s := s + '    -l <loglevel>'#9'Set the log level. Log level can be:'#13#10;
        s := s + '    '#9'0 - No log'#13#10;
        s := s + '    '#9'1 - Injection log'#13#10;
        s := s + '    '#9'2 - Connection status log'#13#10;
        s := s + '    '#9'4 - SOCKS status log'#13#10;
        s := s + '    '#9'8 - Warning messages'#13#10;
        s := s + '    '#9'15 - All'#13#10;
        ShowMessage(s);
        exit;
   end;

   LibName := GetCurrentDir() + '\inject.dll';
   SuspendInjector := TSuspendInjector.Create();

   i := 1;
   OptEnd := False;


   while i <= ParamCount do
   begin
        if (ParamStr(i) = '-b') and (not OptEnd) then
        begin
             inc(i);
             if i > ParamCount then
             begin
                  ShowMessage('Base path wasn''t specified');
                  exit;
             end;
             BasePath := ParamStr(i);
        end
        else if (ParamStr(i) = '-f') and (not OptEnd) then
        begin
             inc(i);
             if i > ParamCount then
             begin
                  ShowMessage('Config file wasn''t specified');
                  exit;
             end;
             SuspendInjector.FreeCapConfig := ExpandFileName(ParamStr(i));
        end
        else if (ParamStr(i) = '-w') and (not OptEnd) then
        begin
             inc(i);
             if i > ParamCount then
             begin
                  ShowMessage('Working directory wasn''t specified');
                  exit;
             end;
             WorkDir := ParamStr(i);
        end
        else if (ParamStr(i) = '-o') and (not OptEnd) then
        begin
             inc(i);
             if i > ParamCount then
             begin
                  ShowMessage('Log file wasn''t specified');
                  exit;
             end;
             logfile := ParamStr(i);
        end
        else if (ParamStr(i) = '-l') and (not OptEnd) then
        begin
             inc(i);
             if i > ParamCount then
             begin
                  ShowMessage('Log level wasn''t specified');
                  exit;
             end;
             loglevel := ParamStr(i);
             if not (StrToIntDef(loglevel, -1) in [0..15]) then
             begin
                  ShowMessage('Log level is not a number in range 0 to 15');
                  exit;
             end;
        end
        else if (ParamStr(i) = '-u') and (not OptEnd) then
        begin
             inc(i);
             if i > ParamCount then
             begin
                  ShowMessage('Library wasn''t specified');
                  exit;
             end;
             LibName := ParamStr(i);
        end
        else
        begin
             OptEnd := True;
             if ProgramName = '' then
             begin
                  ProgramName := ParamStr(i);
             end
             else
             begin
                  if pos(' ', ParamStr(i)) = 0 then
                    Params := Params + ParamStr(i) + ' '
                  else
                    Params := Params + '"' + ParamStr(i) + '" ';
             end;
        end;
        inc(i);
   end;

   if ProgramName = '' then
   begin
        ShowMessage('Program to execute wasn''t specified');
        exit;
   end;

   ProgramName := ExpandFileName(ProgramName);
   Delete(Params, 1, 1);
   Delete(Params, Length(Params) - 1, maxInt);

   LibName := ExpandFileName(LibName);

   if WorkDir = '' then
      WorkDir := ExtractFilePath(ProgramName);

   if (BasePath <> '') then
   begin
        if ExtractFilePath(LibName) = '' then
           LibName := BasePath + '\' + LibName;
        if ExtractFilePath(SuspendInjector.FreeCapConfig) = '' then
           SuspendInjector.FreeCapConfig :=  BasePath + '\' + SuspendInjector.FreeCapConfig;
   end;

   SuspendInjector.SetDLLToInject(LibName);
   SuspendInjector.LogFile := ExpandFileName(LogFile);
   SuspendInjector.LogLevel := LogLevel;
   SuspendInjector.LoadProcess(ProgramName, Params, WorkDir);
   SuspendInjector.Run;
end.
