unit HightlightButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons;

type
  TButtonState = (bsNormal, bsUp, bsDown);

  THightlightButton = class(TSpeedButton)
  private
    FHightlightIndex: integer;
    FNormalIndex     : integer;
    FPushedIndex     : integer;
    FNormalImages    : TImageList;
    FHightlightImages: TImageList;
    FPushedImages    : TImageList;
    FState           : TButtonState;
    FMouseInControl  : Boolean;

    procedure SetHightlightImages(const Value: TImageList);
    procedure SetNormalImages(const Value: TImageList);
    procedure SetPushedImages(const Value: TImageList);
    procedure SetSize(w, h: integer);

    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure SetHightlightIndex(const Value: integer);
    procedure SetNormalIndex(const Value: integer);
    procedure SetPushedIndex(const Value: integer);

    { Private declarations }
  protected
    { Protected declarations }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
  public
    { Public declarations }
  published

    property NormalImages: TImageList read FNormalImages write SetNormalImages;
    property NormalIndex: integer read FNormalIndex write SetNormalIndex;

    property HightlightImages: TImageList read FHightlightImages write SetHightlightImages;
    property HightlightIndex: integer read FHightlightIndex write SetHightlightIndex;

    property PushedImages: TImageList read FPushedImages write SetPushedImages;
    property PushedIndex: integer read FPushedIndex write SetPushedIndex;

    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [THightlightButton]);
end;

{ THightlightButton }


procedure THightlightButton.CMMouseEnter(var Msg: TMessage);
begin
     if not (FState = bsDown) then
     begin
          FState := bsUp;
          Repaint;
     end;
     FMouseInControl := True;
end;

procedure THightlightButton.CMMouseLeave(var Msg: TMessage);
begin
     if not (FState = bsDown) then
     begin
          FState := bsNormal;
          Invalidate;
     end;
     FMouseInControl := False;
end;

procedure THightlightButton.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   inherited MouseDown(Button, Shift, X, Y);
   FState := bsDown;
   Invalidate;
end;

procedure THightlightButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
   inherited MouseMove(Shift, X, Y);
   FMouseInControl := True;
end;

procedure THightlightButton.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   inherited MouseUp(Button, Shift, X, Y);
   FState := bsNormal;
   Invalidate;
end;

procedure THightlightButton.Paint;
begin
    case FState of
      bsNormal: begin
                     if Assigned(FNormalImages) and (FNormalIndex <> -1)
                       and (FNormalIndex < FNormalImages.Count) then
                       FNormalImages.Draw(Canvas, 0, 0, FNormalIndex);
                end;
          bsUp: begin
                     if Assigned(FHightlightImages) and (FHightlightIndex <> -1)
                       and (FHightlightIndex < FHightlightImages.Count) then
                       FHightlightImages.Draw(Canvas, 0, 0, FHightlightIndex);
                end;
        bsDown: begin
                     if Assigned(FPushedImages) and (FPushedIndex <> -1)
                       and (FPushedIndex < FPushedImages.Count) then
                       FPushedImages.Draw(Canvas, 0, 0, FPushedIndex);
                end;
    end;
end;

procedure THightlightButton.SetHightlightImages(const Value: TImageList);
begin
   FHightlightImages := Value;
   SetSize(FHightlightImages.Width, FHightlightImages.Height);
end;

procedure THightlightButton.SetHightlightIndex(const Value: integer);
begin
  FHightlightIndex := Value;
  Invalidate;
end;

procedure THightlightButton.SetNormalImages(const Value: TImageList);
begin
   FNormalImages := Value;
   SetSize(FNormalImages.Width, FNormalImages.Height);
end;

procedure THightlightButton.SetNormalIndex(const Value: integer);
begin
  FNormalIndex := Value;
  Invalidate;

end;

procedure THightlightButton.SetPushedImages(const Value: TImageList);
begin
   FPushedImages := Value;
   SetSize(FPushedImages.Width, FPushedImages.Height);
end;

procedure THightlightButton.SetPushedIndex(const Value: integer);
begin
  FPushedIndex := Value;
  Invalidate;
end;

procedure THightlightButton.SetSize(w, h: integer);
begin
     ClientWidth := w;
     ClientHeight := h;
end;


end.
