{
  $Id: newProxy.pas,v 1.4 2005/12/19 06:09:02 bert Exp $

  $Log: newProxy.pas,v $
  Revision 1.4  2005/12/19 06:09:02  bert
  *** empty log message ***

  Revision 1.3  2005/10/31 14:26:22  bert
  *** empty log message ***

  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}

unit newProxy;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, SocksChain;

type
  TfrmNewProxy = class(TForm)
    GroupBox5: TGroupBox;
    Label12: TLabel;
    Label13: TLabel;
    GroupBox9: TGroupBox;
    labUSERID: TLabel;
    GroupBox10: TGroupBox;
    Label15: TLabel;
    Label16: TLabel;
    editLogin: TEdit;
    editPass: TEdit;
    radio1: TRadioButton;
    checkAuth: TCheckBox;
    radio2: TRadioButton;
    editUserId: TEdit;
    radio3: TRadioButton;
    checkHttpAuth: TCheckBox;
    GroupBox11: TGroupBox;
    Label17: TLabel;
    Label18: TLabel;
    editHttpUser: TEdit;
    editHttpPass: TEdit;
    editSocksServ: TEdit;
    editSocksPort: TEdit;
    Button13: TButton;
    Button15: TButton;
    procedure Button13Click(Sender: TObject);
    procedure SetSocksVer(Ver: integer);
    procedure SetSocks5Auth(Value: boolean);
    procedure SetHttpAuth(Value: boolean);
    procedure checkAuthClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure checkHttpAuthClick(Sender: TObject);
    procedure radio2Click(Sender: TObject);
    procedure radio1Click(Sender: TObject);
    procedure radio3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button15Click(Sender: TObject);

  private
    FMultiply: Boolean;
    procedure SetMultiply(const Value: Boolean);
    procedure EnableControl(Control: TEdit);
    { Private declarations }
  public
    { Public declarations }
    ProxyItem: TSocksChainItem;
    property MultiplyProxies: Boolean read FMultiply write SetMultiply;
  end;

var
  frmNewProxy: TfrmNewProxy;

implementation

{$R *.DFM}


procedure TfrmNewProxy.SetSocks5Auth(Value: boolean);
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

procedure TfrmNewProxy.SetHttpAuth(Value: boolean);
begin
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

procedure TfrmNewProxy.SetSocksVer(Ver: integer);
begin
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

          if (ProxyItem <> nil) then
            checkAuth.Checked := ProxyItem.Auth
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

          if (ProxyItem <> nil) then
            checkHttpAuth.Checked := ProxyItem.HTTP_Auth
          else
            checkHttpAuth.Checked := False;

          SetHttpAuth(checkHTTPAuth.Checked)
     end;

     SetMultiply(FMultiply);
end;


procedure TfrmNewProxy.Button13Click(Sender: TObject);
var
   ver: integer;
begin
     ver := 0;
     if radio1.Checked then
       ver := 4;
     if radio2.Checked then
       ver := 5;
     if radio3.Checked then
       ver := 1;

     if editSocksServ.Text <> '' then
     begin
          if ProxyItem = nil then
          begin
               ProxyItem := SocksChains.AddSocks(editSocksServ.Text,
                          StrToIntDef(editSocksPort.Text, 1080),
                          ver,
                          editLogin.Text,
                          editPass.Text,
                          editUserId.Text,
                          checkAuth.Checked,
                          editHttpUser.Text,
                          editHttpPass.Text,
                          checkHttpAuth.Checked);
          end
          else
          begin
               with ProxyItem do
               begin
                    Server := editSocksServ.Text;
                    Port := StrToIntDef(editSocksPort.Text, 1080);
                    Login := editLogin.Text;
                    Password := editPass.Text;
                    ident := editUserId.Text;
                    Auth := checkAuth.Checked;
                    HTTP_User := editHttpUser.Text;
                    HTTP_Pass := editHttpPass.Text;
                    HTTP_Auth := checkHttpAuth.Checked;
                    Version := ver;
               end;
          end;
     end;
     ModalResult := mrOk;
end;

procedure TfrmNewProxy.checkAuthClick(Sender: TObject);
begin
     if not FMultiply then
       SetSocks5Auth(checkAuth.Checked);
end;

procedure TfrmNewProxy.FormCreate(Sender: TObject);
begin
     SetSocks5Auth(False);
end;

procedure TfrmNewProxy.checkHttpAuthClick(Sender: TObject);
begin
     if not FMultiply then
       SetHttpAuth(checkHttpAuth.Checked);
end;

procedure TfrmNewProxy.radio2Click(Sender: TObject);
begin
     SetSocksVer(5);
end;

procedure TfrmNewProxy.radio1Click(Sender: TObject);
begin
     SetSocksVer(4);
end;

procedure TfrmNewProxy.radio3Click(Sender: TObject);
begin
     SetSocksVer(1);
end;

procedure TfrmNewProxy.FormShow(Sender: TObject);
begin
     if ProxyItem <> nil then
     begin
          editSocksServ.Text := ProxyItem.Server;
          editSocksPort.Text := IntToStr(ProxyItem.Port);
          editLogin.Text := ProxyItem.Login;
          editPass.Text := ProxyItem.Password;
          editUserId.Text := ProxyItem.ident;
          checkAuth.Checked := ProxyItem.Auth;
          editHttpUser.Text := ProxyItem.HTTP_User;
          editHttpPass.Text := ProxyItem.HTTP_Pass;
          checkHttpAuth.Checked  := ProxyItem.HTTP_Auth;
          SetSocksVer(ProxyItem.Version);
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
     end;
end;

procedure TfrmNewProxy.Button15Click(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

procedure TfrmNewProxy.EnableControl(Control: TEdit);
begin
     if Control.Enabled then
       Control.Color := clWindow
     else
       Control.Color := clInactiveBorder;
end;




procedure TfrmNewProxy.SetMultiply(const Value: Boolean);
begin
     FMultiply := Value;

     if FMultiply then
     begin
          editSocksServ.Enabled := not FMultiply;
          editSocksPort.Enabled := not FMultiply;
          editLogin.Enabled := not FMultiply;
          editPass.Enabled := not FMultiply;
          editUserId.Enabled := not FMultiply;
          checkAuth.Enabled := not FMultiply;
          editHttpUser.Enabled := not FMultiply;
          editHttpPass.Enabled := not FMultiply;
          checkHttpAuth.Enabled := not FMultiply;

          EnableControl(editSocksServ);
          EnableControl(editSocksPort);
          EnableControl(editLogin);
          EnableControl(editPass);
          EnableControl(editUserId);
          EnableControl(editHttpUser);
          EnableControl(editHttpPass);
     end;
end;

end.
