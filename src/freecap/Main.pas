{*
 * File: ......................... Main.pas
 * Autor: ........................ Max Artemev (Bert Raccoon),
 * Copyright: .................... (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc:
 *   Main form unit


  $Id: Main.pas,v 1.14 2005/12/19 06:09:02 bert Exp $

  $Log: Main.pas,v $
  Revision 1.14  2005/12/19 06:09:02  bert
  *** empty log message ***

  Revision 1.13  2005/08/11 05:20:36  bert
  *** empty log message ***

  Revision 1.12  2005/05/27 12:45:47  bert
  *** empty log message ***

  Revision 1.11  2005/05/24 04:28:51  bert
  *** empty log message ***

  Revision 1.10  2005/05/23 13:01:11  bert
  *** empty log message ***

  Revision 1.9  2005/05/12 04:21:22  bert
  *** empty log message ***

  Revision 1.8  2005/04/27 11:43:02  bert
  *** empty log message ***

  Revision 1.7  2005/04/26 04:52:19  bert
  *** empty log message ***

  Revision 1.6  2005/04/06 04:58:56  bert
  *** empty log message ***

  Revision 1.5  2005/03/08 16:50:49  bert
  *** empty log message ***

  Revision 1.4  2005/02/18 13:49:51  bert
  Added autorun support for programs

  Revision 1.3  2005/02/15 11:21:21  bert
  *** empty log message ***

}

unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ImageHlp,
  tlhelp32, StdCtrls, Menus, ExtCtrls, ComCtrls, ToolWin, ImgList, Buttons, ShellAPi,
  OleListView, comobj, shlobj, activex, ActnList, TrayIcon, AppEvnts, sockschain, direct_addr, inifiles,
  reg_config, cfg, DebugInject, RemoteThreadInject, SuspendInject, HH, HH_funcs, langs, textlangs,
  WinXP, WSocket, winsock;



type
  TDataItem = record
     ProfileName: string[255];
     FullPath   : string[255];
     WorkDir    : string[255];
     ProgramParams: string[255];
     hIco       : HICON;
     hSmallIco  : HICON;
     IconIndex  : integer;
     Autorun    : Boolean;
  end;
  PDataItem = ^TDataItem;

type
    TFooBarCfg = class
    public
      tFileTime: TDateTime;
    end;

  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Newapplication1: TMenuItem;
    Deleteapplication1: TMenuItem;
    N1: TMenuItem;
    Settings1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    ControlBar1: TControlBar;
    IcoList: TImageList;
    View1: TMenuItem;
    LargeIcons1: TMenuItem;
    SmallIcons1: TMenuItem;
    List1: TMenuItem;
    Details1: TMenuItem;
    Modifyapplication1: TMenuItem;
    ActionList1: TActionList;
    NewAppCmd: TAction;
    ModifyAppCmd: TAction;
    DeleteAppCmd: TAction;
    RunAppCmd: TAction;
    DeleteAppCmd1: TMenuItem;
    TrayIcon1: TTrayIcon;
    ApplicationEvents1: TApplicationEvents;
    ExitAppCmd: TAction;
    PopupMenu1: TPopupMenu;
    Modify1: TMenuItem;
    Run1: TMenuItem;
    Deleteapplication2: TMenuItem;
    N4: TMenuItem;
    Newapplication2: TMenuItem;
    ToolBar1: TToolBar;
    tb1: TToolButton;
    tb3: TToolButton;
    tb2: TToolButton;
    tb4: TToolButton;
    PopupMnu: TPopupMenu;
    N3: TMenuItem;
    SHowmainwindow1: TMenuItem;
    CloseFreeCap1: TMenuItem;
    About2: TMenuItem;
    N5: TMenuItem;
    Settings2: TMenuItem;
    ImageList1: TImageList;
    HelpIndex1: TMenuItem;
    N6: TMenuItem;
    Language1: TMenuItem;
    WSocket: TWSocket;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    lstProgram: TOLEListView;
    Rich: TRichEdit;
    Splitter1: TSplitter;
    SmallIco: TImageList;
    ImageList2: TImageList;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    HelpCmd: TAction;
    N7: TMenuItem;
    Importconfig1: TMenuItem;
    Exportconfig1: TMenuItem;
    ImportDlg: TOpenDialog;
    ExportDlg: TSaveDialog;
    ImportCmd: TAction;
    ExportCmd: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Settings1Click(Sender: TObject);
    procedure Details1Click(Sender: TObject);
    procedure lstProgramSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormShow(Sender: TObject);
    procedure NewAppCmdExecute(Sender: TObject);
    procedure ModifyAppCmdExecute(Sender: TObject);
    procedure DeleteAppCmdExecute(Sender: TObject);
    procedure RunAppCmdExecute(Sender: TObject);
    procedure lstProgramKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure About1Click(Sender: TObject);
    procedure TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure Showmainwindow1Click(Sender: TObject);
    procedure CloseFreeCap1Click(Sender: TObject);
    procedure ExitAppCmdExecute(Sender: TObject);
    procedure Settings2Click(Sender: TObject);
    function ApplicationEvents1Help(Command: Word; Data: Integer;
      var CallHelp: Boolean): Boolean;
    procedure DeleteApp();
    procedure NewApp();
    procedure FormDestroy(Sender: TObject);
    procedure lstProgramShellLinkCreate(Sender: TObject; var DestFileName, WorkDir, Args, IconFile, Desc: String);
    procedure lstProgramDragOver(Sender: TObject; DataObject: IDataObject;
      State: TShiftState; MousePt: TPoint; var Effect, Result: Integer);
    procedure lstProgramDrop(Sender: TObject; DataObject: IDataObject;
      State: TShiftState; MousePt: TPoint; var Effect, Result: Integer);
    procedure lstProgramResize(Sender: TObject);
    procedure LangMenuClick(Sender: TObject);
    procedure WSocketDataAvailable(Sender: TObject; ErrCode: Word);
    procedure HelpCmdExecute(Sender: TObject);
    procedure ImportCmdExecute(Sender: TObject);
    procedure ExportCmdExecute(Sender: TObject);
  private
    procedure AddDataItem(ProfileName, Path, WorkDir, ProgramParams: string; Autorun: Boolean);
    procedure DelDataItem(Item: PDataItem);
    procedure UpdateEntry(Item: PDataItem; ProfileName, Path,
      WorkDir, ProgramParams: string; Autorun: Boolean);
    procedure LoadPrograms;
    procedure SavePrograms;
    procedure MenuClick(Sender: TObject);
    procedure LoadOldPrograms;
    procedure UpdateContextMenu;
    { Private declarations }
    procedure ResolveLinkInfo(LinkPath: string; var ProgramPath, ProgramWorkPath, ProgramInfo, ProgramParams: string);

  protected
    procedure MineRestore(var Msg: TMessage); message WM_MINERESTORE;
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure DefaultHandler(var Message); override;
    procedure QueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
  public

    { Public declarations }
  end;

  procedure CheckOldCfg();



var
  frmMain: TfrmMain;
  ini_file: string;
  WndList : TStringList;
   _pt: TPoint;
  mFile: string;
  bReallyExit: Boolean = False;
  bShown: Boolean = False;

implementation

uses config, profile, about, cfg_select;

{$R *.DFM}

type
    TLogBlock = packed record
      ProcessId: DWORD;
      ProcessName: array[0..255] of Char;
      LogDate: TDateTime;
      LogFacility: Integer;
      LogText: array[0..4095] of Char;
    end;


procedure CheckOldCfg();
var
   ppidl: PItemIDList;
   cAppDataPath: array[0..MAX_PATH] of Char;
   pathentry, AppDataPath: string;
   Lst: TStringList;
   CfgEntry: TFooBarCfg;
   i: integer;

   function MyCustomSort(List: TStringList; Index1, Index2: Integer): Integer;
   begin
        if TFooBarCfg(List.Objects[Index1]).tFileTime = TFooBarCfg(List.Objects[Index2]).tFileTime then
          result := 0
        else if TFooBarCfg(List.Objects[Index1]).tFileTime > TFooBarCfg(List.Objects[Index2]).tFileTime then
          result := -1
        else
          result := 1;
   end;

   procedure CheckForAdd(FilePath: string);
   begin
     if FileExists(FilePath) then
     begin
          if Lst.IndexOf(FilePath) = -1 then
          begin
               CfgEntry := TFooBarCfg.Create;
               CfgEntry.tFileTime := FileDateToDateTime(FileAge(FilePath));
               Lst.AddObject(FilePath, CfgEntry);
          end;
     end;
   end;

begin
     Lst := TStringList.Create;

     if SHGetSpecialFolderLocation(frmMain.Handle, CSIDL_APPDATA, ppidl) = S_OK then
     begin
          if SHGetPathFromIDLista(ppidl, cAppDataPath) then
             AppDataPath := String(cAppDataPath);
     end;

     CheckForAdd(AppDataPath + '\FreeCap\freecap.xml');
     CheckForAdd(ExtractFilePath(ParamStr(0)) + 'freecap.xml');
     CheckForAdd(GetWinDir() + '\freecap.xml');
     CheckForAdd(GetCurrentDir() + '\freecap.xml');
     CheckForAdd(ParamStr(0) + '\freecap.xml');

     Lst.CustomSort(@MyCustomSort);
     if (Lst.Count <> 0) and not isFreecapRegistry then
     begin
          Application.CreateForm(TfrmCfgSelect, frmCfgSelect);
          
          frmCfgSelect.CfgList.Assign(Lst);

          for i:=0 to Lst.COunt - 1 do
            with frmCfgSelect.lvItems.Items.Add do
            begin
                 Caption := Lst[i];
                 SubItems.Add(FormatDateTime('dd/mmmm/yyyy hh:nn:ss', TFooBarCfg(Lst.Objects[i]).tFileTime));
            end;


          if MessageDlg('There are no FreeCap configuration in registry, would you import your old config?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          begin
               if (frmCfgSelect.ShowModal = mrOk) and (frmCfgSelect.lvItems.Selected <> nil) then
               begin
                    Importer(frmCfgSelect.lvItems.Selected.Caption, True);
                    for i:=0 to frmMain.lstProgram.Items.Count - 1 do
                       frmMain.DelDataItem(PDataItem(frmMain.lstProgram.Items[i].Data));
                    frmMain.lstProgram.Items.Clear;
                    frmMain.LoadPrograms();
                    frmConfig.LoadCfg;
                    ReadConfig();
               end;

          end
          else
              frmCfgSelect.Close;
     end;
end;


procedure TfrmMain.AddDataItem(ProfileName, Path, WorkDir, ProgramParams: string; Autorun: Boolean);
var
   Item      : TListItem;
   pData     : PDataItem;
   icoIndex  : word;
   ico       : TIcon;
   bmp, bmp2 : TBitmap;
   progname  : string;
   res       : integer;

   function CreateProgramImage(ico: TIcon; Width, Height: Integer): TBitmap;
   var
      rect: TRect;
   begin
        result := TBitmap.Create;
        result.Width := Width;
        result.Height := Height;
        result.Canvas.Draw(0, 0, ico);
        rect.Left := 0;
        rect.Top := 0;
        rect.Right := Width;
        rect.Bottom := Height;
        result.Canvas.StretchDraw(rect, ico);
   end;

   function canTransparent(bmp: TBitmap): Boolean;
   var
      cl: TColor;
   begin
        cl := bmp.Canvas.Pixels[0, 0];
        result := (cl = bmp.Canvas.Pixels[bmp.Width - 1, 0])
          and (cl = bmp.Canvas.Pixels[bmp.Width - 1, bmp.Height - 1])
          and (cl = bmp.Canvas.Pixels[0, bmp.Height - 1]);
   end;


begin
     Item := lstProgram.Items.Add;

     GetMem(pData, SizeOf(TDataItem));
     Item.Data := pData;
     Item.Caption := ProfileName;
     pData^.ProfileName := ProfileName;

     icoIndex := 0;
     pData^.FullPath := Path;
     pData^.WorkDir := WorkDir;
     pData^.ProgramParams := ProgramParams;
     pData^.Autorun := Autorun;


     progname := ExtractFileName(Path);
     Delete(progname, pos(' ', progname), MaxInt);

//     pData^.hIco := ExtractAssociatedIcon(hInstance, PChar(ExtractFilePath(Path) + progname), icoIndex);
     res := ExtractIconEx(PChar(ExtractFilePath(Path) + progname), icoIndex, pData^.hIco, pData^.hSmallIco, 1);
     if res <= 1 then
     begin
          pData^.hIco := ExtractAssociatedIcon(hInstance, PChar(ExtractFilePath(Path) + progname), icoIndex);
          pData^.hSmallIco := pData^.hIco;

          {Big icon 32x32}
          ico := TIcon.Create;
          ico.Handle := pData^.hIco;
          bmp := CreateProgramImage(ico, 32, 32);

          if canTransparent(bmp) then
            pData^.IconIndex := IcoList.AddMasked(bmp, bmp.Canvas.Pixels[0,0])
          else
            pData^.IconIndex := IcoList.Add(bmp, nil);

          {Small icon 16x16}
          bmp2 := CreateProgramImage(ico, 16, 16);
          if canTransparent(bmp2) then
            SmallIco.AddMasked(bmp2, bmp2.Canvas.Pixels[0,0])
          else
            SmallIco.Add(bmp2, nil);
     end
     else
     begin
          {Big icon 32x32}
          ico := TIcon.Create;
          ico.Handle := pData^.hIco;
          bmp := CreateProgramImage(ico, 32, 32);

          if canTransparent(bmp) then
            pData^.IconIndex := IcoList.AddMasked(bmp, bmp.Canvas.Pixels[0,0])
          else
            pData^.IconIndex := IcoList.Add(bmp, nil);

          {Small icon 16x16}
          ico.Handle := pData^.hSmallIco;
          bmp2 := CreateProgramImage(ico, 16, 16);

          if canTransparent(bmp2) then
            SmallIco.AddMasked(bmp2, bmp2.Canvas.Pixels[0,0])
          else
            SmallIco.Add(bmp2, nil);
     end;


     Item.ImageIndex := pData^.IconIndex;
     Item.SubItems.Add(Path);
     Item.SubItems.Add(WorkDir);
     ico.Free;
     bmp.Free;
     bmp2.Free;
     UpdateContextMenu();
end;


procedure TfrmMain.UpdateEntry(Item: PDataItem; ProfileName, Path, WorkDir, ProgramParams: string; Autorun: Boolean);
var
   lItem     : TListItem;
   icoIndex  : word;
   ico       : TIcon;
   i         : integer;
   res       : integer;
begin
     lItem := nil;
     for i:=0 to lstProgram.Items.Count - 1 do
        if lstProgram.Items[i].Data = Item then
        begin
             lItem := lstProgram.Items[i];
             break;
        end;
     if lItem = nil then exit;


     Item^.ProfileName := ProfileName;
     Item^.FullPath := Path;
     Item^.WorkDir := WorkDir;
     Item^.ProfileName := ProfileName;
     Item^.ProgramParams := ProgramParams;
     Item^.Autorun := Autorun;

     icoIndex := 0;
//     hIco := ExtractAssociatedIcon(hInstance, PChar(Path), icoIndex);
     res := ExtractIconEx(PChar(Path), icoIndex, Item^.hIco, Item^.hSmallIco, 1);
     if res <= 1 then
     begin
          Item^.hIco := ExtractAssociatedIcon(hInstance, PChar(Path), icoIndex);
          Item^.hSmallIco := Item^.hIco;
     end;

     ico := TIcon.Create;
     ico.Handle := Item^.hIco;
     IcoList.ReplaceIcon(Item^.IconIndex, ico);
     ico.Handle := Item^.hSmallIco;
     SmallIco.ReplaceIcon(Item^.IconIndex, ico);

     lItem.Caption := ProfileName;
     lItem.SubItems.Clear;
     lItem.SubItems.Add(Path);
     lItem.SubItems.Add(WorkDir);
     ico.Free;
     UpdateContextMenu();
end;


procedure TfrmMain.DelDataItem(Item: PDataItem);
begin
     FreeMem(Item);
end;



procedure TfrmMain.LoadOldPrograms();
var
   Sections: TStringList;
   i  : integer;
   Ini: TIniFile;
begin
     Sections  := TStringList.Create;
     Ini := TIniFile.Create('freecapp.ini');
     Ini.ReadSections(Sections);
     for i:=0 to Sections.Count - 1 do
        AddDataItem(Sections[i], ini.ReadString(Sections[i],'Path',''), ini.ReadString(Sections[i],'WorkDir',''), '', False);
     Ini.Free;
     Sections.Free;
end;


procedure TfrmMain.LoadPrograms();
var
   Sections: TStringList;
   i  : integer;
   Ini: TRegConfig;
   injector  : TSuspendInjector;

   s_name, s_path, s_workdir, s_params: string;
   b_autorun: Boolean;
begin
{     if isConfigExists('freecapp.ini') and (not isConfigExists('freecap.xml')) then
     begin
          LoadOldPrograms();
          exit;
     end;
}
     Sections  := TStringList.Create;
     Ini := TRegConfig.Create();

     frmMain.Width := Ini.ReadInteger(PART_MAIN, 'Main','Width', frmMain.Width);
     frmMain.Height := Ini.ReadInteger(PART_MAIN, 'Main','Height', frmMain.Height);
     frmMain.Left := Ini.ReadInteger(PART_MAIN, 'Main','Left', frmMain.Left);
     frmMain.Top := Ini.ReadInteger(PART_MAIN, 'Main','Top', frmMain.Top);

     Rich.Height := Ini.ReadInteger(PART_MAIN, 'Main','LogHeight', Rich.Height);


     Ini.ReadSections(PART_PROGRAMS, Sections);
     for i:=0 to Sections.Count - 1 do
     begin
          s_name := ini.ReadString(PART_PROGRAMS, Sections[i],'name', Sections[i]);
          s_path := ini.ReadString(PART_PROGRAMS, Sections[i],'Path','');
          s_workdir := ini.ReadString(PART_PROGRAMS, Sections[i],'WorkDir','');
          s_params := ini.ReadString(PART_PROGRAMS, Sections[i],'Params','');
          b_autorun := ini.ReadBool(PART_PROGRAMS, Sections[i],'Autorun',False);

          AddDataItem(s_name, s_path, s_workdir , s_params, b_autorun);
          if (b_autorun) then
          begin
               injector := TSuspendInjector.Create;
               injector.LoadProcess(s_path, s_params, s_workdir);
//               injector.FreeCapConfig := GetFreeCapConfig();
               injector.SetDLLToInject(ExtractFilePath(Application.Exename) + 'inject.dll');
               injector.Run();
          end;
     end;

     Ini.Free;
     Sections.Free;
end;


procedure TfrmMain.SavePrograms();
var
   Sections: TStringList;
   i  : integer;
   Ini: TRegConfig;
   Item: TDataItem;
begin
     Sections  := TStringList.Create;
     Ini := TRegConfig.Create('freecap.xml');
     Ini.ReadSections(PART_PROGRAMS, Sections);
     for i:=0 to Sections.Count - 1 do
        Ini.EraseSection(PART_PROGRAMS, Sections[i]);
     Sections.Free;

     for i:=0 to lstProgram.Items.Count - 1 do
     begin
          Item := PDataItem(lstProgram.Items[i].Data)^;
          Ini.WriteString(PART_PROGRAMS, Item.ProfileName, 'Path', Item.FullPath);
          Ini.WriteString(PART_PROGRAMS, Item.ProfileName, 'WorkDir', Item.WorkDir);
          Ini.WriteString(PART_PROGRAMS, Item.ProfileName, 'Params', Item.ProgramParams);
          Ini.WriteBool(PART_PROGRAMS, Item.ProfileName, 'Autorun', Item.Autorun);
     end;

     Ini.WriteInteger(PART_MAIN, 'Main', 'ViewStyle', Integer(lstProgram.ViewStyle));

     Ini.WriteInteger(PART_MAIN, 'Main','Width', frmMain.Width);
     Ini.WriteInteger(PART_MAIN, 'Main','Height', frmMain.Height);
     Ini.WriteInteger(PART_MAIN, 'Main','Left', frmMain.Left);
     Ini.WriteInteger(PART_MAIN, 'Main','Top', frmMain.Top);
     Ini.WriteInteger(PART_MAIN, 'Main','LogHeight', Rich.Height);

     Ini.Free;
end;


procedure TfrmMain.FormCreate(Sender: TObject);
var
   vs, i : integer;
   MI: TMenuItem;
   LCID: integer;
begin
     mFile := ExtractFilePath(paramStr(0)) + 'freecap.chm';

     LoadPrograms();
     ReadConfig();

     WndList := TStringList.Create;


     vs := cfg.prog_view_style;

     if not (vs in [0..3]) then
       vs := 0;
     lstProgram.ViewStyle := TViewStyle(vs);
     lstProgram.Visible := True;
     lstProgram.Update;
     case vs of
       0: LargeIcons1.Checked := True;
       1: SmallIcons1.Checked := True;
       2: List1.Checked := True;
       3: Details1.Checked := True;
     end;
     sockschain.init;
     direct_addr.init;
     DragAcceptFiles(lstProgram.Handle, True);


     if SupportedLangs.Count > 0 then
     begin
          N6.Visible := True;
          Language1.Visible := True;
          for i :=0 to SupportedLangs.Count - 1 do
          begin
               MI := TMenuItem.Create(Self);
               MI.Caption := SupportedLangs[i].LangName;
               MI.RadioItem := True;
               MI.Tag := MAKELANGID(SupportedLangs[i].LangID, SupportedLangs[i].SublangID);
               MI.OnClick := LangMenuClick;
               if MI.Tag = prog_lang then
               begin
                    MI.Checked := True;
                    SupportedLangs.SwitchAllFormsTo(SupportedLangs[i].LangID, SupportedLangs[i].SublangID);
               end;
               Language1.Add(MI);
          end;
     end;

    WSocket.Proto             := 'udp';
    WSocket.Addr              := '127.0.0.1';
    WSocket.Port              := '12541';
    WSocket.Listen;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
     SavePrograms();

     if prog_hide_on_close and (not bReallyExit) and (prog_min_tray) then
     begin
          CanClose := False;
          Application.Minimize;
     end;
end;

procedure TfrmMain.Settings1Click(Sender: TObject);
begin
     frmConfig.Show;
end;

procedure TfrmMain.Details1Click(Sender: TObject);
begin
     lstProgram.ViewStyle := TViewStyle((Sender as TComponent).Tag);
     (Sender as TMenuItem).Checked := True;
end;

procedure TfrmMain.lstProgramSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
     ModifyAppCmd.Enabled := Selected;
     DeleteAppCmd.Enabled := Selected;
     RunAppCmd.Enabled := Selected;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
     if not bShown then
     begin
          bShown := True;
          CheckOldCfg();
     end;


     ModifyAppCmd.Enabled := (lstProgram.Selected <> nil);
     DeleteAppCmd.Enabled := (lstProgram.Selected <> nil);
     RunAppCmd.Enabled := (lstProgram.Selected <> nil);
end;

procedure TfrmMain.NewApp();
begin
     frmProfile.ProfileName := '';
     frmProfile.WorkingDir := '';
     frmProfile.FullPath := '';
     if frmProfile.ShowModal = mrOk then
       AddDataItem(frmProfile.ProfileName, frmProfile.FullPath, frmProfile.WorkingDir, frmProfile.ProgramParams, frmProfile.AutoRun);
end;

procedure TfrmMain.NewAppCmdExecute(Sender: TObject);
begin
     NewApp();
end;

procedure TfrmMain.ModifyAppCmdExecute(Sender: TObject);
var
   Item: TDataItem;
begin
     if lstProgram.Selected <> nil then
     begin
          Item := PDataItem(lstProgram.Selected.Data)^;
          frmProfile.ProfileName := Item.ProfileName;
          frmProfile.FullPath := Item.FullPath;
          frmProfile.WorkingDir := Item.WorkDir;
          frmProfile.ProgramParams := Item.ProgramParams;
          frmProfile.Autorun := Item.Autorun;

          if frmProfile.ShowModal = mrOk then
          begin
               UpdateEntry(lstProgram.Selected.Data, frmProfile.ProfileName, frmProfile.FullPath, frmProfile.WorkingDir, frmProfile.ProgramParams, frmProfile.Autorun);
               SavePrograms();
          end;
     end;
end;

procedure TfrmMain.DeleteApp();
var
   ini: TRegConfig;
begin
     if lstProgram.Selected <> nil then
     begin
          if (MessageDlg(Format('Are you sure you want to delete %s?',[lstProgram.Selected.Caption]),mtConfirmation, [mbYes, mbNo], 0)) = mrYes then
          begin
               Ini := TRegConfig.Create('freecap.xml');
               Ini.EraseSection(PART_PROGRAMS, lstProgram.Selected.Caption);
               Ini.Free;

               DelDataItem(lstProgram.Selected.Data);
               lstProgram.Items.Delete(lstProgram.Items.IndexOf(lstProgram.Selected));
               UpdateContextMenu();
          end;
     end;
end;


procedure TfrmMain.DeleteAppCmdExecute(Sender: TObject);
begin
     DeleteApp();
end;

procedure TfrmMain.RunAppCmdExecute(Sender: TObject);
var
   injector1: TSuspendInjector;
   injector2: TDebugInjector;
   injector3: TRemoteInjector;
   filename, workdir, params : string;
begin
     if lstProgram.Selected <> nil then
     begin
          filename := PDataItem(lstProgram.Selected.Data)^.FullPath;
          workdir := PDataItem(lstProgram.Selected.Data)^.WorkDir;
          params := PDataItem(lstProgram.Selected.Data)^.ProgramParams;
     {$DEFINE USE_SUSPEND_INJECT}
//     {$DEFINE USE_DEBUG_INJECT}
     {*
      *  Suspend-thread injection is an unvirsal solution. Works both on Win9x and WinNT platforms. (tested)
      *  Other methods, provided just for information how it can implement in another way
      *}
     {$IFDEF USE_SUSPEND_INJECT}
          injector1 := TSuspendInjector.Create;
          injector1.LoadProcess(filename, params, workdir);
          injector1.SetDLLToInject(ExtractFilePath(Application.Exename) + '\inject.dll');
          injector1.Run();
     {$ENDIF}

     {$IFDEF USE_DEBUG_INJECT}
     {* This method has it owns minuses. First: debugger process *CANNOT* detach from debugee program
      * And you need to place ProcessMessages() function into the Run() class method
      *}
          injector2 := TDebugInjector.Create;
          injector2.LoadProcess(filename, workdir);
          injector2.SetDLLToInject(ExtractFilePath(Application.Exename) + '\inject.dll');
          injector2.Run();
     {$ENDIF}

     {$IFDEF USE_REMOTE_THREAD_INJECT}
     {* This method is easy to implement, but it works only under WinNT.
      *}
           injector3 := TRemoteInjector.Create(filename, workdir, ExtractFilePath(Application.Exename) + '\inject.dll');
           injector3.Run();
     {$ENDIF}


     {* Other methods such as `registry injection` or static spy library linking not listed here.
      * I already weary without it.
      *}
     end;
end;

procedure TfrmMain.lstProgramKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if Key = VK_RETURN then
        RunAppCmd.Execute;
     if Key = VK_DELETE then
       DeleteApp();
     if Key = VK_INSERT then
       NewApp();
end;

procedure TfrmMain.About1Click(Sender: TObject);
begin
{     WndList.Clear;
     SendMessage(HWND_BROADCAST, WM_PLEASE_REPLY_WHO_ALIVE, frmMain.Handle, 0);
     ShowMessage(WndList.Text);}
     frmAbout.Show;
end;

procedure TfrmMain.TrayIcon1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     if (Sender is TTrayIcon) and (Button = mbRight) then
     begin
          SetForegroundWindow(Handle);
          PopupMnu.Popup(X, Y);
     end;
end;

procedure TfrmMain.ApplicationEvents1Minimize(Sender: TObject);
begin
     if cfg.prog_min_tray then
     begin
          ShowWindow(Application.Handle, SW_HIDE);
          ShowWindow(frmMain.Handle, SW_HIDE);
     end;
end;

procedure TfrmMain.Showmainwindow1Click(Sender: TObject);
begin
     if cfg.prog_min_tray or cfg.prog_run_tray then
     begin
          ShowWindow(Application.Handle, SW_RESTORE);
          ShowWindow(Application.Handle, SW_SHOW);
          ShowWindow(frmMain.Handle, SW_RESTORE);
          ShowWindow(frmMain.Handle, SW_SHOW);
          frmMain.Visible := True;
          SetForegroundWindow(Handle);
     end;
end;

procedure TfrmMain.MenuClick(Sender: TObject);
var
   Item: TMenuItem;
begin
     Item := TMenuItem(Sender);
     lstProgram.Selected := lstProgram.Items[-Item.Tag];
     RunAppCmd.Execute;
end;

procedure TfrmMain.CloseFreeCap1Click(Sender: TObject);
begin
     ExitAppCmd.Execute;
end;

procedure TfrmMain.ExitAppCmdExecute(Sender: TObject);
begin
     bReallyExit := True;
     Close;
end;

procedure TfrmMain.Settings2Click(Sender: TObject);
begin
     if cfg.prog_min_tray or cfg.prog_run_tray then
     begin
          ShowWindow(frmConfig.Handle, SW_RESTORE);
          ShowWindow(frmConfig.Handle, SW_SHOW);
          frmConfig.Visible := True;
     end;
end;


procedure TfrmMain.UpdateContextMenu();
var
   Item: TMenuItem;
   i: integer;
   Bmp: TBitmap;
   AItems: array of TMenuItem;
   Index: integer;
begin
     for i:=0 to PopupMnu.Items.Count - 1 do
     begin
          if PopupMnu.Items[i].Tag = 1 then
          begin
               Index := Length(AItems);
               SetLength(AItems, Succ(Index));
               AItems[Index] := PopupMnu.Items[i];
          end;
     end;

     for i:=PopupMnu.Items.Count - 1 downto 0 do
       PopupMnu.Items.Delete(i);

     for i:=0 to lstProgram.Items.Count - 1 do
     begin
          Bmp := TBitmap.Create;
          Bmp.Width := 32;
          Bmp.Height := 32;

               Item := TMenuItem.Create(Self);
               Item.Caption := lstProgram.Items[i].Caption;
               IcoList.GetBitmap(lstProgram.Items[i].ImageIndex, Bmp);
               Bmp.TransparentColor := Bmp.Canvas.pixels[0,0];

               Item.Bitmap.Assign(Bmp);
               Item.Bitmap.Width := 16;
               Item.Bitmap.Height := 16;
               Item.OnClick := MenuClick;
               Item.Tag := -i;
               Item.Bitmap.Canvas.StretchDraw(Rect(0,0,16,16), Bmp);

               PopupMnu.Items.Add(Item);

               Bmp.Free;
          end;
          PopupMnu.Items.Add(AItems);
end;

procedure TfrmMain.MineRestore(var Msg: TMessage);
begin
     if (Msg.Msg = WM_MINERESTORE) then
     begin
          Application.ShowMainForm := True;
          ShowWindow(Application.Handle, SW_RESTORE);
          ShowWindow(Application.Handle, SW_SHOW);
          ShowWindow(frmMain.Handle, SW_RESTORE);
          ShowWindow(frmMain.Handle, SW_SHOW);
          frmMain.Visible := True;
          SetForegroundWindow(Handle);
     end;
end;


procedure TfrmMain.WMDropFiles(var Msg: TMessage);
var
   i, Amount, Size: integer;
   Filename: PChar;
   S, path, path_work, prog_info, prog_params : string;
begin
  inherited;
  Filename := nil;

  Amount := DragQueryFile(Msg.WParam, $FFFFFFFF, Filename, 255);
  for i := 0 to (Amount - 1) do
  begin
       Size := DragQueryFile(Msg.WParam, i , nil, 0) + 1;
       Filename := StrAlloc(size);

       DragQueryFile(Msg.WParam,i , Filename, Size);
       s := Extractfileext(Filename);
       if s = '.lnk' then
       begin
            ResolveLinkInfo(Filename, path, path_work, prog_info, prog_params);
            AddDataItem(GetProgramName(path), path, path_work, prog_params, False);
       end
       else if s = '.exe' then
       begin
            s := StrPas(Filename);
            AddDataItem(GetProgramName(s), ExtractFilePath(s), ExtractFilePath(s), '', False);
       end
       else
           ShowMessage('Shortcut is not executable file or link!');

       StrDispose(Filename);
  end;
  DragFinish(Msg.WParam);
end;


procedure TfrmMain.ResolveLinkInfo(LinkPath: string; var ProgramPath, ProgramWorkPath, ProgramInfo, ProgramParams: string);
Var
   Desc : Array[0..MAX_PATH] of Char;
   IU   : IUnknown;
   SL   : IShellLink;
   PF   : IPersistFile;
   HRES : HRESULT;
   FD   : TWin32FindData;
begin
     CoInitialize(nil);
     IU := CreateComObject(CLSID_ShellLink);
     SL := IU as IShellLink;
     PF := SL as IPersistFile;

     PF.Load(PWideChar(WideString(LinkPath)), STGM_READ);
     SL.Resolve(Handle, SLR_ANY_MATCH);
     SL.GetPath(Desc, MAX_PATH, FD, SLGP_UNCPRIORITY);
     ProgramPath := StrPas(Desc);


     SL.GetDescription(Desc, MAX_PATH);
     ProgramInfo := StrPas(Desc);

     SL.GetWorkingDirectory(Desc, MAX_PATH);
     ProgramWorkPath := StrPas(Desc);

     SL.GetArguments(Desc, MAX_PATH);
     ProgramParams := StrPas(Desc);

end;


procedure TfrmMain.DefaultHandler(var Message);
var
   Buf: array[0..1023] of Char;
begin
     inherited DefaultHandler(Message);
     with TMessage(Message) do
     begin
          if (Msg = WM_I_AM_ALIVE) and (WParam <> 0) then
          begin
               WndList.Add(Format('%u',[WParam]));
          end;
     end;
end;


function HH_ShowPopupHelp2(resID: integer; XYPos: TPoint): HWND;
var
   hhpopup: THHPopup;
begin
     with hhpopup do
     begin
          cbStruct := SizeOf(THHPopup);
          hinst := 0;
          idString := resID;
          pszText := nil;
          pt := XYPos;
          clrForeground := COLORREF(-1);
          clrBackground := COLORREF(-1);
          rcMargins := Rect(-1, -1, -1, -1);
          pszFont := '';
     end;

     if resID < 3000 then
       result := HtmlHelp(0, @(mFile + '::/popuphelp.txt')[1], HH_DISPLAY_TEXT_POPUP, DWORD(@hhpopup))
     else
       result := HtmlHelp(0, @mFile[1], HH_HELP_CONTEXT, resID);
end;


function TfrmMain.ApplicationEvents1Help(Command: Word; Data: Integer;
  var CallHelp: Boolean): Boolean;
begin
     CallHelp := False;
     case Command of
         HELP_CONTEXT: HtmlHelp(0, @mFile[1], HH_HELP_CONTEXT, Data);
         HELP_SETPOPUP_POS: _pt := SmallPointToPoint(TSmallPoint(Data));
         HELP_CONTEXTPOPUP: HH_ShowPopupHelp2(Data, _pt);
     else
         CallHelp := True;
     end;

     result := True;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
   i: integer;
begin
     for i:= 0 to lstProgram.Items.Count - 1 do
        DelDataItem(lstProgram.Items[i].Data);
     lstProgram.Items.Clear;
end;

procedure TfrmMain.lstProgramShellLinkCreate(Sender: TObject;
  var DestFileName, WorkDir, Args, IconFile, Desc: String);
var
   destPath: string;
   Item: TDataItem;
begin
     if lstProgram.Selected <> nil then
     begin
          Item := PDataItem(lstProgram.Selected.Data)^;
          destPath := ExtractFilePath(Application.Exename);
          DestFileName := destPath + 'freecapConW.exe';
          WorkDir := Item.WorkDir;
          Args := '-u "' + destPath + 'inject.dll" "' + Item.FullPath + '" ' + Item.ProgramParams;
          IconFile := Item.FullPath;
          Desc := Item.ProfileName + ' via FreeCap';
     end;
end;

procedure TfrmMain.lstProgramDragOver(Sender: TObject;
  DataObject: IDataObject; State: TShiftState; MousePt: TPoint; var Effect,
  Result: Integer);
begin
     Effect := DROPEFFECT_COPY or DROPEFFECT_LINK;
end;

procedure TfrmMain.lstProgramDrop(Sender: TObject; DataObject: IDataObject;
  State: TShiftState; MousePt: TPoint; var Effect, Result: Integer);
var
  Medium : TSTGMedium;
  Format : TFormatETC;
  NumFiles: Integer;
  i : Integer;
  rslt : Integer;
  DropInfo : TDragDropInfo;
  szFilename : array [0..MAX_PATH] of char;
  InClient : Boolean;
  DropPoint : TPoint;

  Size: integer;
  Filename: PChar;
  S, path, path_work, prog_info, prog_params : string;
begin
     DataObject._AddRef;

     Format.cfFormat := CF_HDROP;
     Format.ptd      := nil;
     Format.dwAspect := DVASPECT_CONTENT;
     Format.lindex   := -1;
     Format.tymed    := TYMED_HGLOBAL;


     rslt := DataObject.GetData (Format, Medium);

     // If successful -- do like an 'deprecated' style drag-drop
     if (rslt = S_OK) then
     begin
          // Getting files count
          NumFiles := DragQueryFile (Medium.hGlobal, $FFFFFFFF, nil, 0);

          InClient := DragQueryPoint(Medium.hGlobal, DropPoint);

          // Create the TDragDropInfo object
          DropInfo := TDragDropInfo.Create(DropPoint, InClient);

          for i := 0 to NumFiles - 1 do
          begin
               Size := DragQueryFile(Medium.hGlobal, i , nil, 0) + 1;
               Filename := StrAlloc(size);
               DragQueryFile(Medium.hGlobal,i , Filename, Size);
               s := Extractfileext(Filename);
               if Lowercase(s) = '.lnk' then
               begin
                    ResolveLinkInfo(Filename, path, path_work, prog_info, prog_params);
                    if path_work = '' then
                       path_work := ExtractFilePath(path);
                    if (pos('freecapcon.exe', lowercase(path)) = 0) and (pos('freecapconw.exe', lowercase(path)) = 0) then
                      AddDataItem(GetProgramName(path), path, path_work, prog_params, false);
               end
               else if Lowercase(s) = '.exe' then
               begin
                    s := StrPas(Filename);
                    if (pos('freecapcon.exe', lowercase(Filename)) = 0) and (pos('freecapconw.exe', lowercase(Filename)) = 0) then
                      AddDataItem(GetProgramName(s), s, ExtractFilePath(s), '', false);
               end
               else
                   ShowMessage('Shortcut is not executable file nor link!');

               StrDispose(Filename);
          end;

          DropInfo.Free;
     end;
     if (Medium.unkForRelease = nil) then
       ReleaseStgMedium (Medium);

     DataObject._Release;
     Effect := DROPEFFECT_COPY;
     result := S_OK;
end;

procedure TfrmMain.lstProgramResize(Sender: TObject);
begin
     lstProgram.Repaint;
end;

procedure TfrmMain.LangMenuClick(Sender: TObject);
var
   MI: TMenuItem;
begin
     MI := TMenuItem(Sender);
     SupportedLangs.SwitchAllFormsTo(MI.Tag and $3F, MI.Tag shr 10);
     MI.Checked := True;
     cfg.prog_lang := MI.Tag;
end;

procedure TfrmMain.WSocketDataAvailable(Sender: TObject; ErrCode: Word);
var
    Buffer : array [0..65535] of char;
    Len    : Integer;
    Src    : TSockAddrIn;
    SrcLen : Integer;
    LogBlock: TLogBlock;
    facility: string;
begin
    SrcLen := SizeOf(Src);
    ZeroMemory(@Buffer, SizeOf(Buffer));
    ZeroMemory(@LogBlock, SizeOf(LogBlock));

    Len    := WSocket.ReceiveFrom(@Buffer, SizeOf(LogBlock), Src, SrcLen);
    if Len >= 0 then begin
        begin
             Move(Buffer, LogBlock, SizeOf(LogBlock));
             case LogBlock.LogFacility of

             LOG_LEVEL_INJ: begin
                                 facility := '[INJ]';
                                 Rich.SelAttributes.COlor := clNavy;
                            end;
             LOG_LEVEL_CONN: begin
                                  facility := '[CONN]';
                                  Rich.SelAttributes.COlor := clGreen;
                             end;
             LOG_LEVEL_SOCKS: begin
                                   facility := '[SOCKS]';
                                   Rich.SelAttributes.COlor := clPurple;
                              end;
             LOG_LEVEL_WARN: begin
                                  facility := '[WARN]';
                                  Rich.SelAttributes.COlor := clRed;
                             end;
             LOG_LEVEL_DEBUG: begin
                                   facility := '[DEBUG]';
                                   Rich.SelAttributes.COlor := clTeal;
                              end;
             LOG_LEVEL_FREECAP: begin
                                     facility := '[FREECAP]';
                                     Rich.SelAttributes.COlor := clBlue;
                              end;
             end;

             Rich.Lines.Add(string(LogBlock.ProcessName) + ' ' + facility + ' ' + LogBlock.LogText);
{            Buffer[Len] := #0;
            Memo1.Lines.Add(StrPas(inet_ntoa(Src.sin_addr)) +
                                          ':'  + IntToStr(ntohs(Src.sin_port)) +
                                          '--> ' + StrPas(Buffer));}
        end;
    end;
end;

procedure TfrmMain.HelpCmdExecute(Sender: TObject);
begin
     HtmlHelp(0, @mFile[1], HH_HELP_CONTEXT, 3020);
end;

procedure TfrmMain.QueryEndSession(var Message: TMessage);
begin
     Message.WParam := 1;
     Message.Result := 1;
     bReallyExit := True;
end;

procedure TfrmMain.ImportCmdExecute(Sender: TObject);
var
   i: integer;
begin
     if ImportDlg.Execute then
     begin
          Importer(ImportDlg.FileName, True);
          for i:=0 to lstProgram.Items.Count - 1 do
            DelDataItem(PDataItem(lstProgram.Items[i].Data));
          lstProgram.Items.Clear;

          LoadPrograms();
          frmConfig.LoadCfg;

          ReadConfig();
     end;
end;

procedure TfrmMain.ExportCmdExecute(Sender: TObject);
begin
     if ExportDlg.Execute then
     begin
          Importer(ExportDlg.FileName, False);
     end;
end;

end.
