unit XP_Panel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, extctrls, buttons;

type
  ttfXP_Panel = class(TPanel)
  Private
   FOnPaint : TNotifyEvent;
   FOnEraseBackground : TNotifyEvent;
  public
   Procedure WMEraseBkGnd( Var msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
   Procedure Paint; override;
   Constructor Create(owner : Tcomponent); override;
  Published
   Property Canvas;
   Property OnPaint:TNotifyEvent Read FOnPaint Write FOnPaint;
   Property OnEraseBackGround:TNotifyEvent Read FOnEraseBackground Write FOnEraseBackground;
  end;


procedure Register;

implementation

Constructor ttfXP_Panel.create(owner : TComponent);
begin
  inherited create(owner);
//   OnPaint:=XP_Paint;
end;

Procedure ttfXP_Panel.Paint;
begin
  if Assigned(FOnPaint) then FOnPaint(self) else Inherited;
// PaintBackground;
End;


procedure ttfXP_Panel.WMEraseBkGnd( Var msg: TWMEraseBkGnd );
begin
 if Assigned(FOnEraseBackground) then
 begin
  SetBkMode( msg.DC, TRANSPARENT );
  FOnEraseBackground(self);
  msg.result := 1;
 end else inherited;
end;


{ TFusion_Band }


procedure Register;
begin
  RegisterComponents('Transpear XP', [TtfXP_Panel]);
end;

end.
