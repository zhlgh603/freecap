{
  $Id: profile.pas,v 1.3 2005/02/18 13:50:16 bert Exp $

  $Log: profile.pas,v $
  Revision 1.3  2005/02/18 13:50:16  bert
  Added "autorun" checkbox

  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}

unit profile;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, versinfo;

type
  TfrmProfile = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button2: TButton;
    Button3: TButton;
    OpenDialog1: TOpenDialog;
    Label4: TLabel;
    Edit4: TEdit;
    checkAutorun: TCheckBox;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    function GetFullPath: string;
    function GetProfName: string;
    function GetWorkingDir: string;
    procedure SetFullPath(const Value: string);
    procedure SetProfName(const Value: string);
    procedure SetWorkingDir(const Value: string);
    function GetProgramParams: string;
    procedure SetProgramDir(const Value: string);
    function GetAutorun: Boolean;
    procedure SetAutorun(const Value: Boolean);
    { Private declarations }
  public
    { Public declarations }
    property ProfileName: string read GetProfName write SetProfName;
    property FullPath: string read GetFullPath write SetFullPath;
    property WorkingDir: string read GetWorkingDir write SetWorkingDir;
    property ProgramParams: string read GetProgramParams write SetProgramDir;
    property Autorun: Boolean read GetAutorun write SetAutorun;

  end;

  function GetProgramName(FileName: string): string;

var
  frmProfile: TfrmProfile;

implementation

{$R *.DFM}


function GetProgramName(FileName: string): string;
var
   VI: TVersionInfo;
begin
     VI := TVersionInfo.Create();
     VI.Filename := FileName;
     if VI.ProductName <> '' then
        result := VI.FileDescription
     else
        result := ExtractFileName(FileName);

     VI.Free;
end;

procedure TfrmProfile.Button2Click(Sender: TObject);
begin
     if Edit1.Text = '' then
     begin
          ShowMEssage('Please enter profile name');
          Edit1.SetFocus();
          exit;
     end;

     if Edit2.Text = '' then
     begin
          ShowMessage('Program path cannot be null');
          Edit2.SetFocus();
          exit;
     end;

     ModalResult := mrOK;
end;

procedure TfrmProfile.Button3Click(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

function TfrmProfile.GetProfName: string;
begin
     result := Edit1.Text;
end;

function TfrmProfile.GetFullPath: string;
begin
     result := Edit2.Text;
end;

function TfrmProfile.GetWorkingDir: string;
begin
     result := Edit3.Text;
end;

procedure TfrmProfile.Button1Click(Sender: TObject);
begin
     if OpenDialog1.Execute then
     begin

          Edit1.Text := GetProgramName(OpenDialog1.FileName);
          Edit2.Text := OpenDialog1.FileName;
          Edit3.Text := ExtractFilePath(OpenDialog1.FileName);
     end;
end;


procedure TfrmProfile.SetProfName(const Value: string);
begin
     Edit1.Text := Value;
end;

procedure TfrmProfile.SetFullPath(const Value: string);
begin
     Edit2.Text := Value;
end;

procedure TfrmProfile.SetWorkingDir(const Value: string);
begin
     Edit3.Text := Value;
end;

function TfrmProfile.GetProgramParams: string;
begin
     result := Edit4.Text;
end;

procedure TfrmProfile.SetProgramDir(const Value: string);
begin
     Edit4.Text := Value;
end;

function TfrmProfile.GetAutorun: Boolean;
begin
     result := checkAutorun.Checked;
end;

procedure TfrmProfile.SetAutorun(const Value: Boolean);
begin
     checkAutorun.Checked := Value;
end;

end.
