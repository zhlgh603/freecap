(*******************************************************************************

 XP Edit v1.0 (c) 2001 Transpear Software

 Coding by Kelvin Westlake

 Contact:  Http://www.transpear.net
          kwestlake@yahoo.com

 Please read enclosed License.txt before continuing any further,  you may also
 find some useful information in the Readme.txt.

 Usage:

 Drop it, set the colors and use it.  BackColor is the Background color
 that is used when the control is not focused and mouse is not over it.

 Known Problems ..

 Shadow color is not used.

*******************************************************************************)


unit XP_Edit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, XP_Color, Extctrls;

type
  TtfXPEdit = class(TCustomEdit)
  private
    MouseIn : Boolean;
    PROCEDURE MouseEnter(VAR Message : TMessage); message CM_MOUSEENTER;
    PROCEDURE MouseLeave(VAR Message : TMessage); message CM_MOUSELEAVE;
    PROCEDURE DrawBorder;
    PROCEDURE SetFocus(VAR Message : TWMSetFocus); message WM_SETFOCUS;
    PROCEDURE KillFocus(VAR Message : TWMKillFocus); message WM_KILLFOCUS;
    PROCEDURE Paint(VAR Message : TMessage); message WM_PAINT;
    Procedure ColorChange(sender : TObject);
  protected
    FColors : TtfXPColor;
  public
    CONSTRUCTOR Create(AOwner : TComponent); override;
  published
    property Colors:ttfXPColor read FColors write FColors;
    property AutoSelect;
    property Anchors;
    property Align;
    property BiDiMode;
    property CharCase;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

CONSTRUCTOR TtfXPEdit.Create(AOwner : TComponent);
BEGIN
 INHERITED;
 MouseIn := False;
 AutoSize := False;
 Ctl3D := False;
 Height := 21;
 FColors:=ttfXPColor.create(self);
 fColors.BackHiColor:=clWindow;
 fColors.OnChange:=ColorChange;
END;

Procedure TtfXPEdit.ColorChange(sender : TObject);
Begin
 repaint;
End;

PROCEDURE TtfXPEdit.DrawBorder;
VAR DC : HDC;
    R : TRect;
    t : TCanvas;
    BtnFaceColor : HBRUSH;
BEGIN
 t:=tcanvas.Create;
 DC := GetWindowDC(Handle);
 t.handle:=dc;
 TRY
  GetWindowRect(Handle, R);
  OffsetRect(R, -R.Left, -R.Top);
  IF Focused OR MouseIn THEN
   BEGIN
      color:=fColors.BackHiColor;
      Frame3D(t,r,fColors.BorderColor,fColors.BorderColor,1);
      Frame3D(t,r,fColors.BackHiColor,fColors.BackHiColor,1);
   END
  ELSE
   BEGIN
    BtnFaceColor := GetSysColorBrush(COLOR_BTNFACE);
    FrameRect (DC, R, BtnFaceColor);
    InflateRect (R, -1, -1);
    FrameRect (DC, R, BtnFaceColor);
    InflateRect (R, -1, -1);
    Color:=FColors.BackColor;
   END;
  FINALLY
    ReleaseDC (Handle, DC);
    t.handle:=0;
  END;
END;

PROCEDURE TtfXPEdit.MouseEnter(VAR Message : TMessage);
BEGIN
 INHERITED;
 MouseIn  := TRUE;
 DrawBorder;
END;

PROCEDURE TtfXPEdit.MouseLeave(VAR Message : TMessage);
BEGIN
 INHERITED;
 MouseIn  := FALSE;
 DrawBorder;
END;

PROCEDURE TtfXPEdit.SetFocus(VAR Message : TWMSetFocus);
BEGIN
 INHERITED;
 DrawBorder;
END;

procedure TtfXPEdit.KillFocus (var Message: TWMKillFocus);
BEGIN
 INHERITED;
 DrawBorder;
END;

PROCEDURE TtfXPEdit.Paint(VAR Message : TMessage);
BEGIN
 INHERITED;
 DrawBorder;
END;

procedure Register;
begin
  RegisterComponents('Transpear XP', [TtfXPEdit]);
end;

end.
