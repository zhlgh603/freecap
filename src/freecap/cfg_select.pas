unit cfg_select;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, shellapi;

type
  TfrmCfgSelect = class(TForm)
    lvItems: TListView;
    btnImport: TButton;
    btnOpenFolder: TButton;
    btnOpenBrows: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOpenFolderClick(Sender: TObject);
    procedure lvItemsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btnOpenBrowsClick(Sender: TObject);
  private
    FCfgList: TStringList;
    { Private declarations }
  public
    { Public declarations }
    property CfgList: TStringList read FCfgList;
  end;

var
  frmCfgSelect: TfrmCfgSelect;

implementation

{$R *.DFM}

procedure TfrmCfgSelect.FormCreate(Sender: TObject);
begin
     FCfgList := TStringList.Create;
end;

procedure TfrmCfgSelect.btnImportClick(Sender: TObject);
begin
     ModalResult := mrOk;
end;

procedure TfrmCfgSelect.btnCancelClick(Sender: TObject);
begin
     ModalResult := mrCancel;
end;

procedure TfrmCfgSelect.btnOpenFolderClick(Sender: TObject);
begin
     if lvItems.Selected <> nil then
       ShellExecute(Handle, 'explore', PChar(ExtractFilePath(lvItems.Selected.Caption)), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmCfgSelect.lvItemsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
     btnOpenFolder.Enabled :=  lvItems.Selected <> nil;
     btnOpenBrows.Enabled := btnOpenFolder.Enabled;
end;

procedure TfrmCfgSelect.btnOpenBrowsClick(Sender: TObject);
begin
     if lvItems.Selected <> nil then
       ShellExecute(Handle, 'open', PChar(lvItems.Selected.Caption), nil, nil, SW_SHOWNORMAL);
end;

end.
