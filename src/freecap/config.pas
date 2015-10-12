{
  $Id: config.pas,v 1.12 2005/12/19 06:09:02 bert Exp $

  $Log: config.pas,v $
  Revision 1.12  2005/12/19 06:09:02  bert
  *** empty log message ***

  Revision 1.11  2005/10/31 14:26:22  bert
  *** empty log message ***

  Revision 1.10  2005/10/27 19:05:51  bert
  *** empty log message ***

  Revision 1.9  2005/07/19 03:52:25  bert
  *** empty log message ***
}

unit config;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, registry, sockschain, direct_addr, CheckLst, HH, pinger,
  Menus, ImgList, plugin_disp, plugin, langs, reg_config, janXMLParser2, winsock2, CLipbrd,
  Spin;

type
  TfrmConfig = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    PopupMenu1: TPopupMenu;
    Pingselectedproxy1: TMenuItem;
    Checkselectedproxy1: TMenuItem;
    Moveup1: TMenuItem;
    Movedown1: TMenuItem;
    N1: TMenuItem;
    Addnew1: TMenuItem;
    Edit1: TMenuItem;
    Deleteselected1: TMenuItem;
    N2: TMenuItem;
    Panel1: TPanel;
    PageControl1: TPageControl;
    tabDefault: TTabSheet;
    Image1: TImage;
    Label1: TLabel;
    GroupBox6: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    GroupBox4: TGroupBox;
    labUSERID: TLabel;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    editLogin: TEdit;
    editPass: TEdit;
    Radio1: TRadioButton;
    checkAuth: TCheckBox;
    Radio2: TRadioButton;
    editUserID: TEdit;
    Radio3: TRadioButton;
    checkHttpAuth: TCheckBox;
    GroupBox2: TGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    editHttpUser: TEdit;
    editHttpPass: TEdit;
    editSocksServ: TEdit;
    editSocksPort: TEdit;
    tabChain: TTabSheet;
    lvProxy: TListView;
    tabDirect: TTabSheet;
    Image4: TImage;
    Label11: TLabel;
    GroupBox7: TGroupBox;
    Button8: TButton;
    Button9: TButton;
    lstDirect: TListBox;
    GroupBox5: TGroupBox;
    Button2: TButton;
    Button3: TButton;
    lstDirectPorts: TListBox;
    tabProgram: TTabSheet;
    Image3: TImage;
    Label8: TLabel;
    GroupBox8: TGroupBox;
    checkOne: TCheckBox;
    checkRunAtStartup: TCheckBox;
    checkRunTray: TCheckBox;
    checkMinTray: TCheckBox;
    checkCaption: TCheckBox;
    checkWarns: TCheckBox;
    DNSGroup: TRadioGroup;
    tabLog: TTabSheet;
    Label6: TLabel;
    Image2: TImage;
    Label7: TLabel;
    GroupBox3: TGroupBox;
    checkINJ: TCheckBox;
    checkCONN: TCheckBox;
    checkSOCKS: TCheckBox;
    checkWARN: TCheckBox;
    checkTraffic: TCheckBox;
    checkLog: TCheckBox;
    editLogFile: TEdit;
    tabPlugins: TTabSheet;
    Image5: TImage;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    lstPlugins: TListBox;
    Button1: TButton;
    plugName: TEdit;
    plugAuthor: TEdit;
    memoDescr: TMemo;
    NavTree: TTreeView;
    NavSplitter: TSplitter;
    checkUDP: TCheckBox;
    checkHide: TCheckBox;
    btnApply: TButton;
    Panel2: TPanel;
    btnProxyAdd: TButton;
    btnProxyDel: TButton;
    btnUp: TButton;
    btnDown: TButton;
    tabShare: TTabSheet;
    groupSocksShare: TGroupBox;
    edGUID: TEdit;
    labGUID: TLabel;
    checkSocksShare: TCheckBox;
    radioAnon: TRadioButton;
    radioNonAnon: TRadioButton;
    btnImportFile: TButton;
    btnImportShare: TButton;
    ImportDlg: TOpenDialog;
    comboProxy: TComboBox;
    ShareLabel: TLabel;
    ShareMemo: TMemo;
    checkSendLogs: TCheckBox;
    GroupBox9: TGroupBox;
    CheckBox1: TCheckBox;
    Label16: TLabel;
    SpinEdit1: TSpinEdit;
    Label17: TLabel;
    Button4: TButton;
    comboUpdateProxy: TComboBox;
    Label18: TLabel;
    checkAdvHook: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure checkLogClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnProxyAddClick(Sender: TObject);
    procedure Pingselectedproxy1Click(Sender: TObject);
    procedure Checkselectedproxy1Click(Sender: TObject);
    procedure lvProxyColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvProxyCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvProxyKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit1Click(Sender: TObject);
    procedure Moveup1Click(Sender: TObject);
    procedure Movedown1Click(Sender: TObject);
    procedure Radio1Click(Sender: TObject);
    procedure Radio2Click(Sender: TObject);
    procedure Radio3Click(Sender: TObject);
    procedure checkAuthClick(Sender: TObject);
    procedure checkHttpAuthClick(Sender: TObject);
    procedure tabDefaultShow(Sender: TObject);
    procedure btnProxyDelClick(Sender: TObject);
    procedure tabPluginsShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure NavTreeChange(Sender: TObject; Node: TTreeNode);
    procedure PageControl1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure lvProxyCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure checkSocksShareClick(Sender: TObject);
    procedure btnImportFileClick(Sender: TObject);
    procedure UpdateComboProxy;
    procedure btnImportShareClick(Sender: TObject);
    procedure lvProxySelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Button4Click(Sender: TObject);
  private
    procedure SetLogEnabled(Value: Boolean);
    procedure SaveCfg;
    procedure AddToList(ChainItem: TSocksChainItem);
    procedure CheckHandler(Sender: TObject);
    procedure PingHandler(Sender: TObject);
    procedure TerminateCheck();
    procedure MoveProxy(ItemF, ItemT: Word);
    procedure MoveProxyUp();
    procedure MoveProxyDown();
    procedure DeleteProxies();
    procedure SetSocksVer(Ver: integer);
    procedure SetSocks5Auth(Value: boolean);
    procedure SetHttpAuth(Value: boolean);
    procedure UpdateDefaultProxy();
    procedure LoadProxiesFromStrings(Strings: TStringList);
    procedure checkUpdate(ProxyItem: TSocksChainItem);
    procedure DefaultItemShow;

    { Private declarations }
  public
      DefaultItem: TSocksChainItem;
      procedure LoadCfg;

    { Public declarations }
  end;

  TPluginObject = class
  public
    PlugInfo : TPluginInfo;
  end;

var
  frmConfig: TfrmConfig;
  ColumnToSort: integer;
  frmShown: Boolean = False;

implementation
uses cfg, Main, common, newProxy, newDirectIP, misc, updater;

{$R *.DFM}

function GetProxy(index: integer): TSocksChainItem;
begin
     result := SocksChains.Items[index];
end;

procedure RunOnStartup(WindowTitle, CommandLn: String; MustDelete: Boolean);
var
   RegIniFile  : TRegIniFile;
begin
     RegIniFile := TRegIniFile.Create('');
     with RegIniFile do
     begin
          RootKey := HKEY_CURRENT_USER;
          if not MustDelete then
             RegIniFile.WriteString('Software\Microsoft\Windows\CurrentVersion\Run'#0, WindowTitle, CommandLn)
          else
             RegIniFile.DeleteKey('Software\Microsoft\Windows\CurrentVersion\Run'#0, WindowTitle);
          Free;
     end;
end;


procedure TfrmConfig.SetSocks5Auth(Value: boolean);
begin
     if Value then
     begin
          editLogin.Color := clWindow;
          editPass.Color := clWindow;
     end
     else
     begin
          editLogin.Color := clInactiveBorder;
          editPass.Color := clInactiveBorder;
     end;

     editLogin.Enabled := Value;
     editPass.Enabled := Value;
end;

procedure TfrmConfig.SetHttpAuth(Value: boolean);
begin
     if not frmShown then exit;

     if Value then
     begin
          editHttpUser.Color := clWindow;
          editHttpPass.Color := clWindow;
     end
     else
     begin
          editHttpUser.Color := clInactiveBorder;
          editHttpPass.Color := clInactiveBorder;
     end;

     editHttpUser.Enabled := Value;
     editHttpPass.Enabled := Value;
end;


procedure TfrmConfig.SetSocksVer(Ver: integer);
begin
     if not frmShown then exit;

     editUserid.Color := clInactiveBorder;
     editLogin.Color := clInactiveBorder;
     editPass.Color := clInactiveBorder;
     checkAuth.Enabled := False;
     labUSERID.Enabled := False;
     editUserid.Enabled := False;
     checkAuth.Enabled := False;

     checkHttpAuth.Enabled := False;
     editHttpUser.Color := clInactiveBorder;
     editHttpPass.Color := clInactiveBorder;

     SetSocks5Auth(False);
     SetHttpAuth(False);


     radio1.Checked := (Ver = 4);
     radio2.Checked := (Ver = 5);
     radio3.Checked := (Ver = 1);

     if Ver = 5 then
     begin
          editUserid.Color := clInactiveBorder;
          editLogin.Color := clWindow;
          editPass.Color := clWindow;
          checkAuth.Enabled := True;

          if (DefaultItem <> nil) then
            checkAuth.Checked := DefaultItem.Auth
          else
            checkAuth.Checked := False;

          SetSocks5Auth(checkAuth.Checked);
     end
     else if Ver = 4 then
     begin
          editUserid.Color := clWindow;
          labUSERID.Enabled := True;
          editUserid.Enabled := True;
     end
     else if Ver = 1 then
     begin
          editHttpUser.Color := clInactiveBorder;
          editHttpPass.Color := clInactiveBorder;
          checkHttpAuth.Enabled := True;

          if (DefaultItem <> nil) then
            checkHttpAuth.Checked := DefaultItem.HTTP_Auth
          else
            checkHttpAuth.Checked := False;

          SetHttpAuth(checkAuth.Checked)
     end;
end;



procedure TfrmConfig.SetLogEnabled(Value: Boolean);
begin
     editLogFile.Enabled := Value;
     if Value then
       editLogFile.Color := clWindow
     else
       editLogFile.Color := clInactiveBorder;

     Label6.Enabled := Value;
     checkINJ.Enabled := Value;
     checkCONN.Enabled := Value;
     checkSOCKS.Enabled := Value;
     checkWARN.Enabled := Value;
     checkTraffic.Enabled := Value;
end;

procedure TfrmConfig.AddToList(ChainItem: TSocksChainItem);
var
   Item: TListItem;
   i: integer;
   Itm: TSocksChainItem;
begin
     for i:=0 to lvProxy.Items.Count - 1 do
     begin
          Itm := TSocksChainItem(lvProxy.Items[i].Data);
          if (ChainItem.Equals(Itm)) then
          begin
               ShareMemo.Lines.Add(Format('Proxy %s already exists in your list', [Itm.Server]));
               SocksChains.DelSocks(ChainItem);
               exit;
          end;
     end;

     Item := lvProxy.Items.Add();
     Item.Data := ChainItem;
     Item.Caption := ChainItem.Server + ':' + IntToStr(ChainItem.Port);
     Item.Checked := ChainItem.inUse;
     Item.SubItems.Add(ChainItem.Protocol);
     Item.SubItems.Add(ChainItem.Anon);
     Item.SubItems.Add('9999');
     Item.SubItems.Add('');
     Item.SubItems.Add('');
     Item.SubItems.Add('');
     Item.SubItems.Add('');
     ChainItem.Data := Item;
     ChainItem.OnCheckDone := CheckHandler;
     ChainItem.OnPingDone := PingHandler;
     Item.ImageIndex := -1;
end;


procedure TfrmConfig.LoadCfg();
var
   i: integer;
begin
     ReadConfig();
     SocksChains.LoadFromIni;
     DirectAddr.Load;
     lstDirect.Items.Clear;
     lvProxy.Items.Clear;
     ColumnToSort := 0;

     for i := 0 to SocksChains.Count - 1 do
     begin
//          lstSocks.Items.Add(SocksChains[i].Server);
//          lstSocks.Checked[lstSocks.Items.Count - 1] := SocksChains[i].inUse;
          AddToList(SocksChains[i]);
     end;

     for i := 0 to DirectAddr.AddrCount - 1 do
     begin
          lstDirect.Items.Add(DirectAddr.Addr[i]);
     end;

     for i := 0 to DirectAddr.PortCount - 1 do
     begin
          lstDirectPorts.Items.Add(DirectAddr.Port[i]);
     end;

     checkLog.Checked  := cfg.socks_log;
     SetLogEnabled(checkLog.Checked);

     editLogFile.Text := cfg.socks_log_file;

     checkINJ.Checked := (cfg.socks_log_level and LOG_LEVEL_INJ) > 0;
     checkCONN.Checked := (cfg.socks_log_level and LOG_LEVEL_CONN) > 0;
     checkSOCKS.Checked := (cfg.socks_log_level and LOG_LEVEL_SOCKS) > 0;
     checkWARN.Checked := (cfg.socks_log_level and LOG_LEVEL_WARN) > 0;
     checkTraffic.Checked := cfg.socks_log_traffic;

     checkOne.Checked := cfg.prog_one_instance;
     checkRunAtStartup.Checked := cfg.prog_sys_startup;
     checkRunTray.Checked := cfg.prog_run_tray;
     checkMinTray.Checked := cfg.prog_min_tray;
     checkUDP.checked := cfg.socks_udp_hack;
     checkHide.checked := cfg.prog_hide_on_close;

     checkAdvHook.checked := cfg.prog_advanced_hooking;

     DNSGroup.ItemIndex := cfg.prog_resolve_dns;

     checkCaption.Checked := cfg.prog_add_caption_text;

     checkWarns.Checked := prog_show_messages;

     frmMain.TrayIcon1.Enabled := cfg.prog_min_tray or cfg.prog_run_tray;
     RunOnStartup('FreeSOCKS Cap',Application.ExeName, not cfg.prog_sys_startup);

     checkSocksShare.Checked := cfg.socks_share_using;
     edGUID.Text := cfg.socks_share_guid;
     if cfg.socks_share_sharing = 0 then
       radioAnon.Checked := True
     else
       radioNonAnon.Checked := True;

     btnImportShare.Enabled := cfg.socks_share_using;
     comboProxy.Enabled := btnImportShare.Enabled;
     ShareLabel.Enabled := btnImportShare.Enabled;

     checkSendLogs.Checked := cfg.socks_send_log;

     UpdateComboProxy();
     comboProxy.ItemIndex := 0;
end;


procedure TfrmConfig.SaveCfg();
begin
     cfg.socks_log := checkLog.Checked;
     cfg.socks_log_file := editLogFile.Text;

     cfg.socks_log_level := 0;
     if checkINJ.Checked then
       cfg.socks_log_level := cfg.socks_log_level or LOG_LEVEL_INJ;

     if checkCONN.Checked then
       cfg.socks_log_level := cfg.socks_log_level or LOG_LEVEL_CONN;

     if checkSOCKS.Checked then
       cfg.socks_log_level := cfg.socks_log_level or LOG_LEVEL_SOCKS;

     if checkWARN.Checked then
       cfg.socks_log_level := cfg.socks_log_level or LOG_LEVEL_WARN;

     cfg.socks_log_traffic := checkTraffic.Checked;

     cfg.prog_one_instance := checkOne.Checked;
     cfg.prog_sys_startup := checkRunAtStartup.Checked;
     cfg.prog_run_tray := checkRunTray.Checked;

     cfg.prog_min_tray := checkMinTray.Checked;
     cfg.prog_add_caption_text := checkCaption.Checked;

     cfg.socks_udp_hack := checkUDP.checked;
     cfg.prog_hide_on_close := checkHide.checked;

     cfg.prog_advanced_hooking := checkAdvHook.checked;

     cfg.socks_share_using := checkSocksShare.Checked;

     if radioAnon.Checked then
       cfg.socks_share_sharing := 0
     else if radioNonAnon.Checked then
       cfg.socks_share_sharing := 1;


     prog_show_messages := checkWarns.Checked;

     try
        cfg.prog_resolve_dns := DNSGroup.ItemIndex;
     except
     end;

     frmMain.TrayIcon1.Enabled := cfg.prog_min_tray or cfg.prog_run_tray;
     RunOnStartup('FreeSOCKS Cap',Application.ExeName, not cfg.prog_sys_startup);

     btnImportShare.Enabled := cfg.socks_share_using;
     comboProxy.Enabled := btnImportShare.Enabled;
     ShareLabel.Enabled := btnImportShare.Enabled;

     cfg.socks_send_log := checkSendLogs.Checked;

     cfg.SaveConfig();
     SocksChains.SaveToIni;
     DirectAddr.Save;
end;


procedure TfrmConfig.FormCreate(Sender: TObject);
var
   Ini : TRegConfig;
begin
//     ChangeLang(Self, 1);
     LoadCfg;
     Ini := TRegConfig.Create();
     NavTree.Width := Ini.ReadInteger(PART_MAIN, 'Main','NavTreeWidth', NavTree.Width);
     Ini.Free;
end;


procedure TfrmConfig.checkLogClick(Sender: TObject);
begin
     SetLogEnabled(checkLog.Checked);
end;

procedure TfrmConfig.btnCancelClick(Sender: TObject);
begin
     TerminateCheck();
     LoadCfg;
     close;
end;

procedure TfrmConfig.btnOKClick(Sender: TObject);
begin
     btnApply.Click;
     close;
end;


procedure TfrmConfig.FormDestroy(Sender: TObject);
begin
     SaveCfg;
end;

procedure TfrmConfig.UpdateDefaultProxy();
var
   ver: integer;
   LVItem: TListItem;
begin
     if PageControl1.ActivePageIndex <> 0 then exit;

     ver := 0;
     if radio1.Checked then
       ver := 4;
     if radio2.Checked then
       ver := 5;
     if radio3.Checked then
       ver := 1;

     if editSocksServ.Text <> '' then
     begin
          if DefaultItem = nil then
          begin
               DefaultItem := SocksChains.AddSocks(editSocksServ.Text,
                          StrToIntDef(editSocksPort.Text, 1080),
                          ver,
                          editLogin.Text,
                          editPass.Text,
                          editUserId.Text,
                          checkAuth.Checked,
                          editHttpUser.Text,
                          editHttpUser.Text,
                          checkHttpAuth.Checked);
               DefaultItem.inUse := True;
               AddToList(DefaultItem);
          end
          else
          begin
               DefaultItem.Auth := checkAuth.Checked;
               DefaultItem.Server := editSocksServ.Text;
               DefaultItem.Port := StrToIntDef(editSocksPort.Text, 1080);
               DefaultItem.Login := editLogin.Text;
               DefaultItem.Password := editPass.Text;
               DefaultItem.ident := editUserId.Text;
               DefaultItem.HTTP_User := editHttpUser.Text;
               DefaultItem.HTTP_Pass := editHttpPass.Text;
               DefaultItem.HTTP_Auth := checkHttpAuth.Checked;
               DefaultItem.Version := ver;

          end;
          LVItem := lvProxy.FindData(0, DefaultItem, True, False);
          LVItem.Caption := DefaultItem.Server;
          LVItem.SubItems[0] := DefaultItem.Protocol;
          LVItem.SubItems[1] := DefaultItem.Anon;


     end;
end;

procedure TfrmConfig.Button8Click(Sender: TObject);
var
   s: string;
begin
     if frmNewDirectIP.ShowModal = mrOk then
     begin
          s := frmNewDirectIP.GetIPAddr();
          DirectAddr.Add(s);
          lstDirect.Items.Add(s);
     end;
end;

procedure TfrmConfig.Button9Click(Sender: TObject);
var
   i: integer;
begin
     if lstDirect.ItemIndex <> -1 then
     begin
          i := lstDirect.ItemIndex;
          DirectAddr.Del(lstDirect.Items[i]);
          lstDirect.Items.Delete(i);

          if i >= lstDirect.Items.Count then
            lstDirect.ItemIndex := lstDirect.Items.Count - 1
          else
            lstDirect.ItemIndex := i;

     end;
end;

procedure TfrmConfig.btnHelpClick(Sender: TObject);
begin
     Application.HelpContext(PageControl1.ActivePage.HelpContext);
end;

procedure TfrmConfig.btnProxyAddClick(Sender: TObject);
begin
     frmNewProxy.ProxyItem := nil;
     frmNewProxy.MultiplyProxies := False;
     if frmNewProxy.ShowModal() = mrOK then
     begin
          frmNewProxy.ProxyItem.inUse := True;
          AddToList(frmNewProxy.ProxyItem);
     end;
end;

procedure TfrmConfig.Pingselectedproxy1Click(Sender: TObject);
var
   i: integer;
   Item: TListItem;
begin
     for i:=0 to lvProxy.Items.Count - 1 do
     begin
          Item := lvProxy.Items[i];
          if (Item.Selected) then
             GetProxy(i).Ping;
     end;
end;

procedure TfrmConfig.Checkselectedproxy1Click(Sender: TObject);
var
   i: integer;
   Item: TListItem;
   ProxyItem: TSocksChainItem;
begin
     for i:=0 to lvProxy.Items.Count - 1 do
     begin
          Item := lvProxy.Items[i];
          if (Item.Selected) then
          begin
               ProxyItem := sockschains.items[i];
               Item.SubItems[3] := 'In progress...';
               ProxyItem.Check;
          end;
     end;
end;

procedure TfrmConfig.CheckHandler(Sender: TObject);
var
   Item: TListItem;
   SocksItem: TSocksChainItem;
begin
     SocksItem := (Sender as TSocksChainItem);
     Item := TListItem(SocksItem.Data);
     Item.SubItems[3] := SocksItem.Status;
     Item.SubItems[4] := SocksItem.ProxyInfo.RemoteCntSuffix;
     Item.SubItems[5] := SocksItem.LastError;

     if SocksItem.Status = 'OK' then
     begin
          if (SocksItem.ProxyInfo.RemoteIp = SocksItem.ProxyIp) then
            Item.SubItems[6] := 'Passed, external address equals proxy address'
          else
            Item.SubItems[6] := 'Failed! External address is ' + SocksItem.ProxyInfo.RemoteIp;
     end;
     lvProxy.Repaint;
end;

procedure TfrmConfig.PingHandler(Sender: TObject);
var
   Item: TListItem;
   SocksItem: TSocksChainItem;
begin
     SocksItem := (Sender as TSocksChainItem);
     Item := TListItem(SocksItem.Data);
     Item.SubItems[2] := IntToStr(SocksItem.PingMSec);;
end;

procedure TfrmConfig.lvProxyColumnClick(Sender: TObject;
  Column: TListColumn);
var
   i: integer;
begin
     ColumnToSort := Column.Index;
     if Column.Tag = 0 then
       Column.Tag := 1
     else
       Column.Tag := 0;
     (Sender as TCustomListView).AlphaSort;

     for i := 0 to SocksChains.Count - 1 do
       SocksChains[i] := TSocksChainItem(lvProxy.Items[i].Data);
end;

procedure TfrmConfig.lvProxyCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  ix: Integer;
  ping1, ping2: integer;
begin
     if ColumnToSort = 3 then
     begin
          ix := ColumnToSort - 1;
          ping1 := StrToIntDef(Item1.SubItems[ix], 0);
          ping2 := StrToIntDef(Item2.SubItems[ix], 0);
          if (ping1 = ping2) then
            Compare := 0
          else if (ping1 > ping2) then
            Compare := 1
          else if (ping1 < ping2) then
            Compare := -1;
     end
     else if ColumnToSort = 4 then
     begin
          ix := ColumnToSort - 1;
          if (Item1.SubItems[ix] = 'OK') and (Item2.SubItems[ix] = 'OK') then
            Compare := 0
          else if (Item1.SubItems[ix] = 'OK') and (Item2.SubItems[ix] <> 'OK') then
            Compare := 1
          else if (Item1.SubItems[ix] <> 'OK') and (Item2.SubItems[ix] = 'OK') then
            Compare := -1;
     end
     else
     begin
          if ColumnToSort = 0 then
            Compare := CompareText(Item1.Caption,Item2.Caption)
          else
          begin
               ix := ColumnToSort - 1;
               Compare := CompareText(Item1.SubItems[ix],Item2.SubItems[ix]);
          end;
     end;

     if lvProxy.Columns.Items[ColumnToSort].Tag = 1 then
       Compare := Compare * (-1);
end;


function GetClipBrdText(): string;
var
   MyHandle: THandle;
   TextPtr: PChar;
begin
     ClipBoard.Open;
     try
        MyHandle := Clipboard.GetAsHandle(CF_TEXT);
        TextPtr := GlobalLock(MyHandle);
        result := StrPas(TextPtr);
        GlobalUnlock(MyHandle);
     finally
        Clipboard.Close;
     end;
end;



procedure TfrmConfig.lvProxyKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   StringList: TStringList;
begin

     if (not (ssShift in Shift)) and (Key = VK_INSERT) then
        btnProxyAddClick(Self);

     if Key = VK_DELETE then
        DeleteProxies();

     if (ssCtrl in Shift) and (Key = VK_UP) then
        MoveProxyUp();
     if (ssCtrl in Shift) and (Key = VK_DOWN) then
        MoveProxyDown();


     if ((ssShift in Shift) and (Key = VK_INSERT)) or ((ssCtrl in Shift) and (Key = ord('V'))) and (Clipboard.HasFormat(CF_TEXT)) then
     begin
          StringList := TStringList.Create();
          StringList.Text := GetClipBrdText();
          LoadProxiesFromStrings(StringList);
          StringList.Free;
     end;
end;

procedure TfrmConfig.Edit1Click(Sender: TObject);
var
   Item: TSocksChainItem;
   LVItem: TListItem;
   i: integer;
begin
     if lvProxy.Selected <> nil then
     begin
          LVItem := lvProxy.Selected;
          Item := GetProxy(LVItem.Index);

          frmNewProxy.MultiplyProxies := lvProxy.SelCount > 1;
          frmNewProxy.ProxyItem := Item;
          if frmNewProxy.ShowModal() = mrOK then
          begin
               if (lvProxy.SelCount <= 1) then
               begin
                    GetProxy(LVItem.Index).Assign(frmNewProxy.ProxyItem);
                    LVItem.Caption := Item.Server  + ':' + IntToStr(Item.Port);
                    LVItem.SubItems[0] := Item.Protocol;
                    LVItem.SubItems[1] := Item.Anon;
               end
               else
               begin
                    for i := lvProxy.Selected.Index to lvProxy.Selected.Index + lvProxy.SelCount - 1 do
                    begin
                         LVItem := lvProxy.Items[i];
                         if LVItem.Selected then
                         begin
                              GetProxy(i).Version := Item.Version;
                              LVItem.Caption := GetProxy(i).Server  + ':' + IntToStr(GetProxy(i).Port);
                              LVItem.SubItems[0] := Item.Protocol;
                              LVItem.SubItems[1] := Item.Anon;
                         end;

                    end;



               end;

          end;
     end;
end;

procedure TfrmConfig.TerminateCheck();
var
   Item: TSocksChainItem;
   i: integer;
begin
     for i:=0 to lvProxy.Items.Count - 1 do
     begin
          Item := GetProxy(i);
          Item.Suspend;
     end;
end;


procedure TfrmConfig.MoveProxy(ItemF, ItemT: Word);
var
   Caption: string;
   Checked: Boolean;
   SubItems: TStringList;
begin
     Caption := lvProxy.Items[ItemF].Caption;
     Checked := lvProxy.Items[ItemF].Checked;
     SubItems := TStringList.Create;
     SubItems.Assign(lvProxy.Items[ItemF].SubItems);

     lvProxy.Items[ItemF].Caption := lvProxy.Items[ItemT].Caption;
     lvProxy.Items[ItemF].Checked := lvProxy.Items[ItemT].Checked;
     lvProxy.Items[ItemF].SubItems := lvProxy.Items[ItemT].SubItems;

     lvProxy.Items[ItemT].Caption := Caption;
     lvProxy.Items[ItemT].Checked := Checked;
     lvProxy.Items[ItemT].SubItems := SubItems;

     SubItems.Free;
end;


procedure TfrmConfig.MoveProxyUp();
var
   from_idx, to_idx: integer;
begin
     if (lvProxy.Selected <> nil) then
     begin
          from_idx := lvProxy.Selected.Index;

          lvProxy.Selected := nil;

          to_idx := from_idx - 1;
          if to_idx < 0 then
             to_idx := 0;

          MoveProxy(from_idx, to_idx);
          SocksChains.Exchange(from_idx, to_idx);
          lvProxy.Selected := lvProxy.Items[to_idx];
     end;
end;

procedure TfrmConfig.MoveProxyDown();
var
   from_idx, to_idx: integer;
begin
     if (lvProxy.Selected <> nil) then
     begin
          from_idx := lvProxy.Selected.Index;

          lvProxy.Selected := nil;

          to_idx := from_idx + 1;
          if to_idx > lvProxy.Items.Count - 1 then
             to_idx := lvProxy.Items.Count - 1;

          MoveProxy(from_idx, to_idx);
          SocksChains.Exchange(from_idx, to_idx);
          lvProxy.Selected := lvProxy.Items[to_idx];
     end;
end;

procedure TfrmConfig.DeleteProxies();
var
   i: integer;
   Item: TSocksChainItem;
begin
     for i := lvProxy.Items.Count - 1 downto 0 do
     begin
          if (lvProxy.Items[i].Selected) then
          begin
               Item := GetProxy(i);
               Item.Suspend;
               SocksChains.DelSocks(i);
               lvProxy.Items[i].Delete;
          end;
     end;

     if SocksChains.GetFirstIndex >= 0 then
         DefaultItem := GetProxy(SocksChains.GetFirstIndex)
     else
         DefaultItem := nil;

end;


procedure TfrmConfig.Moveup1Click(Sender: TObject);
begin
     MoveProxyUp();
end;

procedure TfrmConfig.Movedown1Click(Sender: TObject);
begin
     MoveProxyDown();
end;

procedure TfrmConfig.Radio1Click(Sender: TObject);
begin
     SetSocksVer(4);
end;

procedure TfrmConfig.Radio2Click(Sender: TObject);
begin
     SetSocksVer(5);
end;

procedure TfrmConfig.Radio3Click(Sender: TObject);
begin
     SetSocksVer(1);
end;

procedure TfrmConfig.checkAuthClick(Sender: TObject);
begin
     SetSocks5Auth(checkAuth.Checked);
end;

procedure TfrmConfig.checkHttpAuthClick(Sender: TObject);
begin
     SetHttpAuth(checkHttpAuth.Checked);
end;

procedure TfrmConfig.DefaultItemShow();
begin
     if SocksChains.GetFirstIndex >= 0 then
     begin
          DefaultItem := SocksChains.Items[SocksChains.GetFirstIndex];
          editSocksServ.Text := DefaultItem.Server;
          editSocksPort.Text := IntToStr(DefaultItem.Port);
          editLogin.Text := DefaultItem.Login;
          editPass.Text := DefaultItem.Password;
          editUserId.Text := DefaultItem.ident;
          checkAuth.Checked := DefaultItem.Auth;
          editHttpUser.Text := DefaultItem.HTTP_User;
          editHttpPass.Text := DefaultItem.HTTP_Pass;
          checkHttpAuth.Checked  := DefaultItem.HTTP_Auth;
          SetSocksVer(DefaultItem.Version);
          if DefaultItem.Version = 1 then
            SetHttpAuth(checkHttpAuth.Checked);
     end
     else
     begin
          editSocksServ.Text := '';
          editSocksPort.Text := '1080';
          editLogin.Text := '';
          editPass.Text := '';
          editUserId.Text := '';
          checkAuth.Checked := False;
          editHttpUser.Text := '';
          editHttpPass.Text := '';
          checkHttpAuth.Checked  := False;
          SetSocksVer(5);
          SetHttpAuth(False);
     end;
     SetSocks5Auth(checkAuth.Checked);
end;


procedure TfrmConfig.tabDefaultShow(Sender: TObject);
begin
     DefaultItemShow();
end;

procedure TfrmConfig.btnProxyDelClick(Sender: TObject);
begin
     DeleteProxies;
end;

procedure TfrmConfig.tabPluginsShow(Sender: TObject);
var
   i: integer;
begin
     for i := 0 to lstPlugins.Items.Count - 1 do
        TPluginObject(lstPlugins.Items.Objects[i]).Free;
     lstPlugins.Items.Clear;
end;

procedure TfrmConfig.Button2Click(Sender: TObject);
var
   s: string;
begin
     s := InputBox('New port', 'Enter new port value', '');
     if (s <> '') then
     begin
          if (not IsCorrectPort(s)) then
          begin
               ShowMessage('Invalid port');
               exit;
          end;
          DirectAddr.Add(StrToInt(s));
          lstDirectPorts.Items.Add(s);
     end;
end;

procedure TfrmConfig.Button3Click(Sender: TObject);
var
   i: integer;
begin
     if lstDirectPorts.ItemIndex <> -1 then
     begin
          i := lstDirectPorts.ItemIndex;
          DirectAddr.Del(StrToInt(lstDirectPorts.Items[i]));
          lstDirectPorts.Items.Delete(i);

          if i >= lstDirectPorts.Items.Count then
            lstDirectPorts.ItemIndex := lstDirectPorts.Items.Count - 1
          else
            lstDirectPorts.ItemIndex := i;
     end;
end;

procedure TfrmConfig.NavTreeChange(Sender: TObject; Node: TTreeNode);
begin
     if NavTree.Selected <> nil then
       PageControl1.ActivePageIndex := NavTree.Selected.StateIndex;
end;

procedure TfrmConfig.PageControl1Change(Sender: TObject);
begin
     NavTree.Selected := NavTree.Items[PageControl1.ActivePageIndex];
end;

procedure TfrmConfig.FormShow(Sender: TObject);
begin
     NavTree.Selected := NavTree.Items[PageControl1.ActivePageIndex];
     frmShown := True;
     DefaultItemShow();
end;

procedure TfrmConfig.btnApplyClick(Sender: TObject);
var
   i: integer;
   Ini: TRegConfig;
begin
     UpdateDefaultProxy();
     for i := 0 to lvProxy.Items.Count - 1 do
        GetProxy(i).inUse := lvProxy.Items[i].Checked;

     Ini := TRegConfig.Create();
     Ini.WriteInteger(PART_MAIN, 'Main','NavTreeWidth', NavTree.Width);
     Ini.Free;

     SaveCfg;
end;

procedure TfrmConfig.lvProxyCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
   Itemstate: string;
begin
     with lvProxy.Canvas.Font do
     begin
          Itemstate := Item.SubItems[3];
          if (Itemstate <> '') then
          begin
               if (Itemstate = 'OK') then
                 Color := clGreen
               else if (Itemstate = 'In progress...') then
                 Color := clGray
               else
                 Color := clRed;
          end;
     end;
     DefaultDraw := True;
end;

procedure TfrmConfig.checkSocksShareClick(Sender: TObject);
begin
     if checkSocksShare.Checked and (cfg.socks_share_guid = '') then
     begin
          cfg.socks_share_guid := GetNewGUID;
          edGUID.Text := cfg.socks_share_guid;
     end;
end;


procedure TfrmConfig.LoadProxiesFromStrings(Strings : TStringList);
var
   Item: TSocksChainItem;
   i: integer;
   s, user, pass, host: string;
   port, ver: Integer;
begin
     for i:=0 to Strings.Count - 1 do
     begin
          s := Strings[i];
          if (s = '') or (s[1] = ';') or (s[1] = '#') then
            continue;

          port := 1080;
          host := '';
          user := '';
          pass := '';

          if pos('@', s) > 0 then // entry in the form user:pass@server or user@server
          begin
               user := copy(s, 1, pos('@', s) - 1);
               if pos(':', user) > 0 then
               begin
                    pass := copy(user, pos(':', user) + 1, MaxInt);
                    Delete(user, pos(':', user), MaxInt);
               end;
               Delete(s, 1, pos('@', s));
          end;

          if pos(':', s) > 0 then // entry in the form server:port
          begin
               host := copy(s, 1, pos(':', s) - 1);
               port := StrToIntDef(copy(s, pos(':', s) + 1, MaxInt), 1080);
          end
          else
              host := s;

          case Port of
            80, 8080, 3128: ver := 1;
            1080, 81: ver := 5;
          else
              if (user <> '') and (pass = '') then
                ver := 4
              else
                ver := 5;
          end;
          Item := SocksChains.AddSocks(host, port, ver, user, pass, user, user <> '', user, pass, user <> '');
          AddToList(Item);
     end;
end;


procedure TfrmConfig.btnImportFileClick(Sender: TObject);
var
   ImportFile: TStringList;
begin
     if ImportDlg.Execute then
     begin
          ImportFile := TStringList.Create;
          ImportFile.LoadFromFile(ImportDlg.FileName);
          LoadProxiesFromStrings(ImportFile);
          ImportFile.Free;
     end;
end;

procedure TfrmConfig.UpdateComboProxy;
var
   i: integer;
begin
     comboProxy.Items.BeginUpdate();
     comboProxy.Items.Clear;
     comboProxy.Items.Add('<Direct connection>');
     for i:=0 to SocksChains.Count - 1 do
        comboProxy.Items.Add(SocksChains[i].Server + ':' + IntToStr(SocksChains[i].Port));
     comboProxy.Items.EndUpdate();

     comboUpdateProxy.Items.BeginUpdate();
     comboUpdateProxy.Items.Clear;
     comboUpdateProxy.Items.Add('<Direct connection>');
     for i:=0 to SocksChains.Count - 1 do
        comboUpdateProxy.Items.Add(SocksChains[i].Server + ':' + IntToStr(SocksChains[i].Port));
     comboUpdateProxy.Items.EndUpdate();
     comboUpdateProxy.ItemIndex := 0;

end;

procedure TfrmConfig.btnImportShareClick(Sender: TObject);
var
   ProxyItem : TSocksChainItem;
   Request, Response, LastErr: string;
   header, body: string;
   XMLDOM: TjanXMLParser2;
   Nodes: TjanXMLNode2;
   Item: TjanXMLNode2;
   i, cnt, ver, res: integer;
   host, port, login, password, ident, httpuser, httppass, sVer: string;
   NeedAuth, http_auth: Boolean;
   Name: TSockAddrIn;
   Sock: TSocket;
   arg: DWORD;
begin
     if comboProxy.ItemIndex <= 0 then
     begin
          ProxyItem := TSocksChainItem.CreateIt();
          ProxyItem.Version := 0; // Dummy proxy, e.g. "direct connection"
          ProxyItem.Server := 'freecap.ru';
          ProxyItem.Port := 80;

     end
     else
         ProxyItem := TSocksChainItem(lvProxy.Items[comboProxy.ItemIndex - 1].Data);

     Request := 'GET /informer.php?a=socks&UserGUID=' + cfg.socks_share_guid + ' HTTP/1.0' + #13#10
              + 'Host: freecap.ru' + #13#10
              + 'User-agent: FreeCap built-in checker' + #13#10#13#10;


     if ProxyItem.Connect() = 0 then
     begin
          if ProxyItem.TryToRetrieve('freecap.ru', Request, Response, LastErr) <> 0 then
          begin
               DisplayMessage('Unable to grab proxies! Last error was: ' + LastErr);
               exit;
          end;
          ShareMemo.Lines.Add('Getting proxies...');

          SplitHtml(Response, header, body);

          XMLDOM := TjanXMLParser2.Create();
          XMLDOM.name := 'freecap';
          XMLDOM.xml := Body;
          if XMLDOM.getChildByName('message') <> nil then
            DisplayMessage(XMLDOM.getChildByName('message').text)
          else
          begin
               Nodes := XMLDOM.getChildByName('proxies');
               cnt := StrToIntDef(Nodes.attribute['count'], 0);
               ShareMemo.Lines.Add(Format('%d proxies retrived.', [cnt]));
               for i:=0 to cnt - 1 do
               begin
                    Item := TjanXMLNode2(Nodes.nodes.Items[i]);
                    host := Item.getChildByName('host').Text;
                    port := Item.getChildByName('port').Text;
                    login := Item.getChildByName('login').Text;
                    password := Item.getChildByName('password').Text;

                    sVer := Item.getChildByName('type').Text;

                    ver := 5;

                    if sVer = 'SOCKS5' then
                      ver := 5
                    else if sVer = 'SOCKS4' then
                      ver := 4
                    else if sVer = 'HTTPS' then
                      ver := 1;

                    NeedAuth := ((ver = 4) or (ver = 5)) and (login <> '');
                    http_auth := (ver = 1) and (login <> '') and (password <> '');
                    AddToList(SocksChains.AddSocks(Host, StrToIntDef(Port, 1080), ver, login, password, ident, NeedAuth, httpuser, httppass, http_auth));
               end;
               ShareMemo.Lines.Add('Done');
          end;
          XMLDOM.Free;
     end
     else
         DisplayMessage('Unable to connect to ' + ProxyItem.Server + ' proxy server!');

     if comboProxy.ItemIndex <= 0 then
       ProxyItem.Free;
end;

procedure TfrmConfig.lvProxySelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
     if Selected then
     begin
          if (comboProxy.Items.COunt <> SocksChains.Count) then
            UpdateComboProxy();

          comboProxy.ItemIndex := Item.Index + 1;
     end;

end;

procedure TfrmConfig.checkUpdate(ProxyItem: TSocksChainItem);
var
   UpdateThrd: TCheckerThread;
begin
     UpdateThrd := TCheckerThread.Create(ProxyItem);
     UpdateThrd.Resume;
end;


procedure TfrmConfig.Button4Click(Sender: TObject);
var
   ProxyItem: TSocksChainItem;
begin
     if comboUpdateProxy.ItemIndex <= 0 then
     begin
          ProxyItem := TSocksChainItem.CreateIt();
          ProxyItem.Version := 0; // Dummy proxy, e.g. "direct connection"
          ProxyItem.Server := 'freecap.ru';
          ProxyItem.Port := 80;

     end
     else
         ProxyItem := TSocksChainItem(lvProxy.Items[comboUpdateProxy.ItemIndex - 1].Data);

     checkUpdate(ProxyItem);

     if comboUpdateProxy.ItemIndex <= 0 then
       ProxyItem.Free;
end;

end.
