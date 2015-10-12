{
  $Id: pass_promt.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

  $Log: pass_promt.pas,v $
  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}

unit pass_promt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmPassPromt = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure Prepare;
    { Public declarations }
  end;

var
  frmPassPromt: TfrmPassPromt;

implementation
uses cfg;

{$R *.DFM}

procedure TfrmPassPromt.Button1Click(Sender: TObject);
begin
{     cfg.socks_login := Edit1.Text;
     cfg.socks_pass := Edit2.Text;
}
     cfg.SaveConfig;
     ModalResult := mrOk;
end;

procedure TfrmPassPromt.Button2Click(Sender: TObject);
begin
     ModalResult := mrCancel;
end;


procedure TfrmPassPromt.Prepare;
begin
     ReadConfig();
//     Edit1.Text := cfg.socks_login;
     Edit2.Text := '';
end;

procedure TfrmPassPromt.FormCreate(Sender: TObject);
begin
     Prepare;
end;

end.
