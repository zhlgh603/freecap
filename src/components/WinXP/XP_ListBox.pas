(*******************************************************************************

 XP List Box v1.1 (c) 2001 Transpear Software

 Coding by Kelvin Westlake

 Contact:  Http://www.transpear.net
          kwestlake@yahoo.com

 Please read enclosed License.txt before continuing any further,  you may also
 find some useful information in the Readme.txt.

  Usage:

  Drop it on a form,  set the colors and use it.

  PLEASE NOTE:

  Only BorderColor and BackHiColor are used.

  Known Problems:

  The border flickers when the box is resized.

*******************************************************************************)



unit XP_ListBox;

interface

Uses  stdctrls,Windows, Messages, SysUtils, Classes, Graphics, Forms, Dialogs,
       Extctrls,XP_Color;

Type
 TtfXPListBox = class (TListBox)
  private
   FColors : TtfXPColor;
   Procedure DrawBorder;
   Procedure Paint(VAR Message : TMessage); message WM_PAINT;
   Procedure ColorChange(sender : TObject);
   Procedure SetBorderColor(newCol : TColor);
   Function  GetBorderColor: TColor;

  public
    constructor Create(AOwner : TComponent); override;
  published
    property BorderColor:TColor read GetBorderColor write SetBorderColor default $006B2408;
  end;

procedure Register;

implementation

constructor TtfXPListBox.Create(AOwner : TComponent);
begin
 inherited Create(AOwner);
 FColors:=ttfXPColor.create(self);
 fColors.BackHiColor:=clWindow;
 BorderColor:=$006B2408;
 fColors.OnChange:=ColorChange;
End;


Procedure TtfXPListBox.SetBorderColor(newCol : TColor);
Begin
  FColors.BorderColor:=newCol;
End;

Function TtfXPListBox.GetBorderColor: TColor;
Begin
  Result:=  FColors.BorderColor;
End;

Procedure TtfXPListBox.ColorChange(sender : TObject);
Begin
 repaint;
End;

Procedure TtfXPListBox.DrawBorder;
Var DC : HDC;
    R : TRect;
    t : TCanvas;
Begin
 t:=tcanvas.Create;
 DC := GetWindowDC(Handle);
 t.handle:=dc;
 Try
  GetWindowRect(Handle, R);
  OffsetRect(R, -R.Left, -R.Top);
  color:=fColors.BackHiColor;
  Frame3D(t,r,fColors.BorderColor,fColors.BorderColor,1);
  Frame3D(t,r,Color,Color,1);
 Finally
    ReleaseDC (Handle, DC);
    t.handle:=0;
  End;
End;


Procedure TtfXPListBox.Paint(VAR Message : TMessage);
Begin
 Inherited;
 DrawBorder;
End;


procedure Register;
begin
  RegisterComponents('Transpear XP', [TtfXPListBox]);
end;


end.
