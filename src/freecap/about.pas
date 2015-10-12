{
  $Id: about.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

  $Log: about.pas,v $
  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}
unit about;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, shellapi;

{$I '..\version.inc'}

type
  TfrmAbout = class(TForm)
    Label1: TLabel;
    Image1: TImage;
    Button1: TButton;
    Label2: TLabel;
    Memo1: TMemo;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.DFM}

procedure TfrmAbout.Button1Click(Sender: TObject);
begin
     CLose;
end;

procedure TfrmAbout.Label4Click(Sender: TObject);
begin
     ShellExecute(Handle, 'open', PChar('mailto:' + Label4.Caption), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
     Label2.Caption := 'FreeCap v' + FREECAP_VERSION;
end;

procedure TfrmAbout.Label5Click(Sender: TObject);
begin
     ShellExecute(Handle, 'open', PChar('http://' + Label5.Caption), nil, nil, SW_SHOWNORMAL);
end;

end.
