(*******************************************************************************

 XP List Box v1.1 (c) 2001 Transpear Software

 Coding by Kelvin Westlake

 Contact:  Http://www.transpear.net
          kwestlake@yahoo.com

 Please read enclosed License.txt before continuing any further,  you may also
 find some useful information in the Readme.txt.

   This is the Original Menubar Component that was released by Borland,
   It has been updated to ONLY to accept XP menus,   XP style is ensured
   by a calling 'ForceXPStyle()' from the Menu being passed to it.
   This Ensures that all custom Draw routines get intialised for the
   TMenuItems (else you will only get a standard look).

   to get it to except normal menus change all 'TtfXPMainMenu' to 'TMainMenu'.


*******************************************************************************)


unit XP_MenuBar;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolWin, ComCtrls, XP_MainMenu;

type
  TtfXPMenuBar = class(TToolBar)
  private
    FRedraw : Boolean;
    FMenu: TtfXPMainMenu;
    procedure SetMenu(const Value: TtfXPMainMenu);
  protected
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property EdgeBorders default [];
    property Menu: TtfXPMainMenu read FMenu write SetMenu;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Transpear XP', [TtfXPMenuBar]);
end;

{ TMenuBar }



constructor TtfXPMenuBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Flat := True;
  ShowCaptions := True;
  EdgeBorders := [];
  ControlStyle := [csCaptureMouse, csClickEvents,
    csDoubleClicks, csMenuEvents, csSetCaption];
end;

procedure TtfXPMenuBar.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TtfXPMenuBar.SetMenu(const Value: TtfXPMainMenu);
var
  i: Integer;
  Button: TToolButton;
begin
  if FMenu = Value then exit;
  if Assigned(FMenu) then
    for i := ButtonCount - 1 downto 0 do
      Buttons[i].Free;
  Value.ForceXpStyle;
  FMenu := Value;
  if not Assigned(FMenu) then exit;
  for i := ButtonCount to FMenu.Items.Count - 1 do
  begin
    Button := TToolButton.Create(Self);
    try
      Button.AutoSize := True;
      Button.Grouped := True;
      Button.Parent := Self;
      Buttons[i].MenuItem := FMenu.Items[i];
    except
      Button.Free;
     raise;
    end;
  end;
  { Copy attributes from each menu item }
  for i := 0 to FMenu.Items.Count - 1 do
    Buttons[i].MenuItem := FMenu.Items[i];
 If Owner is TCustomForm Then           // Remove Parent menu if needed ;)
    TCustomForm(Owner).Menu:=nil;
end;

end.
