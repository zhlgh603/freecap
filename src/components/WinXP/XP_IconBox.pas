unit XP_IconBox;
(*******************************************************************************

 XP Icon Box v1.1 (c) 2001 Transpear Software

 Coding by Kelvin Westlake

 Contact:  Http://www.transpear.net
          kwestlake@yahoo.com

 Please read enclosed License.txt before continuing any further,  you may also
 find some useful information in the Readme.txt.

  Usage:

  Drop it on a form,  set the file that holds the icons with LoadIcons(),
  the selected icon is returned in the ItemIndex.

  Brief:

  Its difficult to create an interface for an Icon Dialog thats work both
  on Win9x and Win2k(NT), so in my early days of Delphi programming I created
  my Own Icon Dialog and used this Icon-list within.

  Known problems:

  The border flickers when the box is resized.

*******************************************************************************)


interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Menus, Extctrls,XP_Color;

type
  TtfXPIconBox = class(TCustomListBox)
  private
    FNumberOfIcons: integer;
    FColors : TtfXPColor;
    PROCEDURE DrawBorder;
    PROCEDURE Paint(VAR Message : TMessage); message WM_PAINT;
    Procedure ColorChange(sender : TObject);
    Property Columns;
  protected
    function GetIcon(const Index: integer): TIcon;
    procedure MeasureItem(Index: Integer; var Height: Integer); override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    Procedure LoadIcons(FileName: string);
  published
    property NumberOfIcons: integer read FNumberOfIcons default -1;
    property Colors:ttfXPColor read FColors write FColors;
    property Align;
    Property DragKind;
    property DragMode;
    property DragCursor;
    property Enabled;
    property ItemIndex;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
  end;

procedure Register;

implementation

uses ShellAPI;


constructor TtfXPIconBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Style := lbOwnerDrawFixed;
  FNumberOfIcons := -1;
  ItemHeight := GetSystemMetrics(SM_CYICON) + 6;
  FColors:=ttfXPColor.create(self);
  fColors.OnChange:=ColorChange;
//  Columns:= (GetSystemMetrics(SM_CYICON));
 fColors.OnChange:=ColorChange;
end;

destructor TtfXPIconBox.Destroy;
begin
  inherited Destroy;
end;


{ Used to extract icons from files and assign them to a TIcon object }

Procedure TtfXPIconBox.LoadIcons(FileName: string);
var
  Icon	: TIcon;
  Count  : Integer;
begin
  Columns:=(Width div (GetSystemMetrics(SM_CYICON)+8));
  if Items.Count>0 then		 // delete only existing icon
  For Count:=Items.Count-1 DownTo 0 Do
  begin
    TIcon(Items.Objects[Count]).Free;
    Items.Objects[Count] := nil;
    Items.Delete(Count);
  End;
  FNumberOfIcons:=0;
  Clear;
  count:=0;
   Repeat
    Icon := TIcon.Create;
    Icon.Handle := ExtractIcon(hInstance, PChar(FileName), count);
    If Icon.Handle<>0 Then
    Begin
    DrawBorder;
     Items.AddObject(Format('%d', [count]), Icon);
     if FNumberOfIcons = -1 then
       FNumberOfIcons := 1
     else
       Inc(FNumberOfIcons);
      Inc(count);
     End;
   Until Icon.Handle=0;
end;


function TtfXPIconBox.GetIcon(const Index: integer): TIcon;
begin
  Result := TIcon(Items.Objects[Index]);
end;


procedure TtfXPIconBox.MeasureItem(Index: Integer; var Height: Integer);
begin
  Height := GetSystemMetrics(SM_CYICON);
end;


procedure TtfXPIconBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Icon: TIcon;
begin
  with Canvas do
  begin
    try
     If odSelected in State Then Canvas.Brush.Color:=fColors.BackHiColor;
      FillRect(Rect);
      Icon := TIcon(Items.Objects[Index]);
     if Icon <> nil then
        with Rect do
          Draw(Left + (Right - Left - Icon.Width) div 2,
               Top + (Bottom - Top - Icon.Width) div 2, Icon);
    except
    end;
  end;
end;

Procedure TtfXPIconBox.ColorChange(sender : TObject);
Begin
 repaint;
End;

PROCEDURE TtfXPIconBox.DrawBorder;
VAR DC : HDC;
    R : TRect;
    t : TCanvas;
BEGIN
 t:=tcanvas.Create;
 DC := GetWindowDC(Handle);
 t.handle:=dc;
 TRY
  GetWindowRect(Handle, R);
  OffsetRect(R, -R.Left, -R.Top);
  color:=fColors.BackColor;
  Frame3D(t,r,fColors.BorderColor,fColors.BorderColor,1);
  Frame3D(t,r,fColors.BackColor,fColors.BackColor,1);
  FINALLY
    ReleaseDC (Handle, DC);
    t.handle:=0;
  END;
END;

PROCEDURE TtfXPIconBox.Paint(VAR Message : TMessage);
BEGIN
 INHERITED;
 DrawBorder;
END;

procedure Register;
begin
  RegisterComponents('Transpear XP', [TtfXPIconBox]);
end;

end.

