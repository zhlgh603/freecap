{
  $Id: newDirectIP.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

  $Log: newDirectIP.pas,v $
  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}

unit newDirectIP;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, winsock;

type
  TfrmNewDirectIP = class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    edIP: TEdit;
    edMask: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    function CalcIPAddr: string;
    function CalcCIDRMask: string;
  private
    FIPAddr: string;
    FNetMask: string;
    FErr: Boolean;
    { Private declarations }
  public
    { Public declarations }
    function GetIPAddr(): string;
  end;

var
  frmNewDirectIP: TfrmNewDirectIP;

implementation
uses common;
{$R *.DFM}

const
     CIDRMask : array [1..32] of string = (
       '128.0.0.0', '192.0.0.0', '224.0.0.0', '240.0.0.0', '248.0.0.0', '252.0.0.0',
       '254.0.0.0', '255.0.0.0', '255.128.0.0', '255.192.0.0', '255.224.0.0', '255.240.0.0',
       '255.248.0.0', '255.252.0.0', '255.254.0.0', '255.255.0.0', '255.255.128', '255.255.192.0',
       '255.255.224.0', '255.255.240.0', '255.255.248.0', '255.255.252.0', '255.255.254.0',
       '255.255.255.0', '255.255.255.128', '255.255.255.192', '255.255.255.224', '255.255.255.240',
       '255.255.255.248', '255.255.255.252', '255.255.255.254', '255.255.255.255');


procedure TfrmNewDirectIP.Button1Click(Sender: TObject);
var
   s: string;
begin
     FErr := False;
     s := GetIPAddr;
     if (not IsCorrectIP(s)) or FErr then
     begin
          if not FErr then
            ShowMessage('Invalid IP');
          exit;
     end;

     ModalResult := mrOk;
end;

procedure TfrmNewDirectIP.Button2Click(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

procedure TfrmNewDirectIP.RadioButton2Click(Sender: TObject);
begin
     Label2.Enabled := True;
     edMask.Enabled := True;
     edMask.Color := clWindow;
end;

procedure TfrmNewDirectIP.RadioButton1Click(Sender: TObject);
begin
     Label2.Enabled := False;
     edMask.Enabled := False;
     edMask.Color := clInactiveBorder;
end;

function TfrmNewDirectIP.GetIPAddr: string;
begin
     result := CalcIPAddr + CalcCIDRMask;
end;

function TfrmNewDirectIP.CalcCIDRMask: string;
var
   tmp, i: integer;
   addr: TInAddr;
   mask: string;
begin
     if RadioButton1.Checked then
     begin
          if pos('/', edIP.Text) > 0 then
            FNetMask := copy(edIP.Text, pos('/', edIP.Text) + 1, MaxInt)
          else
            FNetMask := '';

          tmp := StrToIntDef(FNetMask, -1);

          if (FNetMask <> '') and ((tmp = -1) or ((tmp < 1) or (tmp > 32))) then
          begin
               FNetMask := '';
               FErr := True;
               ShowMessage('Invalid CIDR bits');
          end;
     end
     else
     begin
          FNetMask := edMask.Text;
          tmp := inet_addr(PChar(FNetMask));
          if (tmp <> LongInt(INADDR_NONE)) then
          begin
               addr.S_addr := tmp;
               mask := inet_ntoa(addr);
               FNetMask := '';
               for i:=1 to 32 do
                 if (CIDRMask[i] = mask) then
                 begin
                      FNetMask := IntToStr(i);
                      break;
                 end;
               if FNetMask = '' then
               begin
                    FErr := True;
                    ShowMessage('Invalid netmask!');
               end;
          end
          else
          begin
               FNetMask := '';
               ShowMessage('Invalid netmask!');
               FErr := True;
          end;

     end;

     if FNetMask <> '' then
       FNetMask := '/' + FNetMask;
     result := FNetMask;
end;

function TfrmNewDirectIP.CalcIPAddr: string;
begin
     if pos('/', edIP.Text) > 0 then
       FIPAddr := copy(edIP.Text, 1, pos('/', edIP.Text) - 1)
     else
       FIPAddr := edIP.Text;
     result := FIPAddr;
end;

end.
