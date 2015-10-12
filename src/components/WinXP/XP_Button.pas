(*******************************************************************************

 XP Button v1.0 (c) 2001 Transpear Software

 Coding by Kelvin Westlake

 Contact:  Http://www.transpear.net
          kwestlake@yahoo.com

 Please read enclosed License.txt before continuing any further,  you may also
 find some useful information in the Readme.txt.

 Usage:

 Drop it and use it.

 Known Problems ..

 Assigning an Icon to the Glyph at Runtime - The mask seems stay at 32x32
 causing the Icon to be displayed in the wrong place.


*******************************************************************************)


unit XP_Button;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls,Extctrls, Menus,XP_Color;

Type AlignPos = (glLeft,glRight,glTop,glBottom);

Type
  TtfXPButton = Class(TCustomControl)
  private
    focused      : Boolean;
    FCaption     : String;
    FColors      : TtfXPColor;
    FBorderWidth : Integer;
    FGlyph       : TPicture;
    FMonoMask    : TBitmap;
    FClicked     : Boolean;       // Identifies when mouse is clicked (to set shadow etc)
    FAlign       : AlignPos;
    FShadowOffset: Integer;
    FDropDownMenu: TPopUpMenu;
    FImageList   : TImageList;
    FImageIndex  : Integer;
    FTextOffset,
    ImgX,ImgY,
    TxtX,TxtY    : Integer;
    CopyCanvas   : TBitmap;
//    MouseTimer   : TTimer;
    Procedure SetImageList(List : TImageList);
    Procedure SetImageIndex(idx : Integer);
   protected
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseMove(var Message: TMessage); message WM_MOUSEMOVE;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override ;
    procedure SetCaption(Const cap : String);
    Procedure SetGlyph(const NewGlyph : TPicture);
    Procedure SetGlyphAlign(const NewAlign : AlignPos);
    Procedure SetShadowOffset(const offset : Integer);
    Procedure SetTextOffset(const gap : Integer);
    Procedure DisplayGlyph;
    Procedure CreateMask(gfx: TPicture);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
//    procedure MouseTimerEvent(Sender: TObject);
    Procedure Click; Override;
    Procedure CalcCoord;
    Function MouseWithInBounds:Boolean; // Sometimes MouseEnter does not work ..
  public
    procedure paint; override;
    constructor Create(AOwner : TComponent); override;
    destructor destroy; override;
  Published
     Property Action;
     property Left;
     property Top;
     property Width;
     property Height;
     Property Font;
     Property Visible;
     Property OnClick;
     Property Enabled;
     Property ShowHint;
     Property OnContextPopup;
     Property OnDragDrop;
     Property OnDragOver;
     Property OnEndDock;
     Property OnEndDrag;
     Property OnEnter;
     PRoperty OnExit;
     Property OnKeyDown;
     Property OnKeyUp;
     Property OnMouseDown;
     Property OnMouseMove;
     Property OnMouseUp;
     Property OnStartDock;
     Property OnStartDrag;
     property Caption:string read FCaption write SetCaption;
     property Colors:ttfXPColor read FColors write FColors;
     property DropDownMenu:TPopUpMenu  read FDropDownMenu write FDropDownMenu;
     property BorderWidth:Integer Read FBorderWidth Write FBorderWidth default 1;
     property Glyph:TPicture read FGlyph Write SetGlyph;
     Property Images : TImageList read FImageList write SetImageList;
     Property ImageIndex : Integer read FImageIndex write SetImageIndex default -1;
     property GlyphLayout:AlignPos read FAlign Write SetGlyphAlign;
     property GlyphTextGap : Integer read FTextOffset write SetTextOffset default 4;
     property ShadowSize : Integer read FShadowOffset write setShadowOffset Default 1;
   end;

procedure Register;

implementation

Constructor TtfXPButton.create(AOwner : TComponent);
Begin
  inherited create(AOwner);
  FGlyph:=TPicture.Create;
  FColors:=ttfXPColor.create(self);
  FDropDownMenu:=Nil;
  FImageList:=Nil;
  FImageIndex:=-1;
  Focused:=False;
  Width:=23;
  Height:=22;
  Caption:='';
  FTextOffset:=4;
  FShadowOffset:=1;
  FBorderWidth:=1;
  FClicked:=False;
  fCaption:=name;
  if csDesigning in ComponentState then Exit;
//  MouseTimer:=TTimer.Create(self);
//  MouseTimer.Interval:=35;
//  MouseTimer.OnTimer:=MouseTimerEvent;
end;

destructor TtfXPButton.destroy;
Begin
// MouseTimer.free;
// CopyCanvas.free;
// fGlyph.free;
    FMonoMask.free;
    inherited destroy;
end;

{procedure TtfXPButton.MouseTimerEvent(Sender: TObject);
begin
 If Not MouseWithInBounds Then
 Begin
   MouseTimer.Enabled:=False;
   Focused:=False;
   Paint;
 End;
end; }

procedure TtfXPButton.CreateMask(gfx: TPicture);
begin
  FMonoMask := TBitmap.Create;
  with FMonoMask do
  begin
    if gfx.Graphic is TBitmap then
    begin
      Assign(gfx.Bitmap);
      Transparent := True;
      Mask(transparentColor);
      Monochrome := true;
    end
    else
    if gfx.Graphic is TIcon then
    begin
      	Height := gfx.Height;
        Width := gfx.Width;
        Canvas.Brush.Color := clWhite;
        Canvas.FillRect(Bounds(0,0,width, height));
        DrawIconEx(FMonoMask.Canvas.Handle, 0,0, gfx.Icon.Handle, Width, Height, 0,0, DI_Mask);
       Monochrome := true;
     end
    else
    begin
      Height := gfx.Height;
      Width := gfx.Width;
      Canvas.Brush.Color := clWhite;
      Canvas.FillRect(Bounds(0,0,width, height));
      Canvas.Draw(0,0, gfx.Graphic);
      Monochrome := true;
    end;
  end;
end;

Procedure TtfXPButton.SetImageList(List : TImageList);
Begin
  FImageList:=List;
  If assigned(FMonoMask) then FMonoMask.free;
  FMonoMask:=TBitmap.create;
  Paint;
  Invalidate;
End;

Procedure TtfXPButton.SetImageIndex(idx : Integer);
Begin
  FImageIndex:=idx;
  Paint;
  Invalidate;
End;


Procedure TtfXPButton.SetGlyph(const NewGlyph : TPicture);
Begin
  If assigned(FMonoMask) then FMonoMask.free;
  FMonoMask:=TBitmap.create;
  FGlyph.Assign(NewGlyph);
  Paint;
  Invalidate;
End;

Procedure TtfXPButton.SetGlyphAlign(const NewAlign : AlignPos);
Begin
 FAlign:=NewAlign;
 Paint;
End;


Procedure TtfXPButton.SetTextOffset(const gap : Integer);
Begin
 FTextOffset:=Gap;
 Paint;
End;

Procedure TtfXPButton.SetShadowOffset(const offset : Integer);
Begin
FShadowOffset:=offset;
 Paint;
End;

procedure TtfXPButton.SetCaption(const cap : String);
begin
  FCaption:=cap;
  Invalidate;
End;


procedure TtfXPButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
 If Operation = opRemove then
 Begin
    if AComponent = FDropDownMenu then FDropDownMenu:=nil;
    if AComponent = FImageList then
    Begin
      FMonoMask.free;
      FImageList:=nil;
    End;

  End;
end;

Function TtfXPButton.MouseWithInBounds:Boolean;
var pt : TPoint;
Begin
     GetCursorPos(pt);
     pt := Parent.ScreenToClient(pt);
     if  ((pt.y > top) and (pt.y < top + height)
       and (pt.x > left-1) and (pt.x < left + width)) then
          Result:=True Else Result:=False;
End;


procedure TtfXPButton.WMMouseMove(var Message: TMessage);
Begin
  Focused:=MouseWithInBounds;     // Get type of focus needed ..
  Paint;
//  If MouseWithInBounds Then
//  Begin
//    MouseTimer.Enabled:=True;
//  End;
End;



procedure TtfXPButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var pt : TPoint;
begin
   fClicked:=True;
   Focused:=True;
   Paint;
   inherited MouseDown(button,shift,X,Y); // *** RUN BEFORE MENU POP UP ..
   If assigned(FDropDownMenu) AND (Button=mbLeft) Then
   Begin
     pt:=Self.ClientOrigin;
     Pt.y:=pt.y+Height;
     FDropDownMenu.Popup(pt.x,pt.y);
     fClicked:=False;
     Focused:=MouseWithInBounds;     // Get type of focus needed ..
     Paint;                          // Show the button as such ..
   End;
end;


Procedure TtfXPButton.Click;
Begin
     Inherited Click;
     fClicked:=False;
     Focused:=MouseWithInBounds;     // Get type of focus needed ..
     Paint;                          // Show the button as such ..
End;


procedure TtfXPButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   fClicked:=False;       // No need to draw shadow or anything
   Invalidate;            // Ensure update ..
   inherited MouseDown(button,shift,X,Y);
end;

procedure TtfXPButton.CMMouseEnter(var Message: TMessage);
begin
  focused := True;
  paint;          // Mouse Entering does not ensure a repaint, so just in case
end;

procedure TtfXPButton.CMMouseLeave(var Message: TMessage);
begin
  focused := False;
  paint;          // Mouse Entering does not ensure a repaint, so just in case
end;

Procedure TtfXPButton.DisplayGlyph;
var
  ShadowOffset  : Integer;
  oldFontColor,
  oldBrushColor : TColor;
  TempGlyph     : TPicture;
Begin
 Try
 ShadowOffSet:=0;
 TempGlyph:=TPicture.Create;
 If (FImageIndex>-1) And (Assigned(FImageList)) Then  // ImageList or Glyph??
 FImageList.GetBitmap(FImageIndex,TempGlyph.Bitmap)
 Else If Assigned(FGlyph) Then TempGlyph.Assign(fGlyph);     // Try a glyph ...
 If Assigned(TempGlyph) Then                      // Ensure an image is present
 Begin
   FMonoMask.free;           // A bit silly creating a mask each time
   CreateMask(TempGlyph);    // but I without this the ImageList Mask will not work
   FMonoMask.Transparent:=True;  // I will fix this soon (If I can be botherd)
   If (Focused) AND (not FClicked) Then ShadowOffSet:=-FShadowOffset;
    With CopyCanvas.Canvas Do          // Draw everything tp the Temp Canvas ..
    Begin
      oldFontColor:=Font.Color; OldBrushColor:=Brush.Color;
      Brush.Color:=clWhite;      Font.Color:=clBlack;
      CopyMode:=cmSrcAnd;
      Draw(imgX,imgY, FMonoMask);              // Draw First Mask ..
      Brush.Color:=clBlack;  Font.Color:=FColors.ShadowColor;
      CopyMode:=cmSrcPaint;
      Draw(imgX, imgY, FMonoMask);  // Draw Second and then merge em
      CopyMode := cmSrcCopy;
      Font.Color  := oldFontColor;
      Brush.Color := oldBrushColor;
    If TempGlyph.Graphic is TBitmap Then TempGlyph.Bitmap.Transparent:=True;
    CopyCanvas.canvas.Draw(ImgX+ShadowOffset,ImgY+ShadowOffset,TempGlyph.graphic);
   end;
 End;
  Finally
   TempGlyph.free;
  End;
End;



// A very long winded way of generating the co-ords, but its quick
// and most importantly it works ..
Procedure TtfXPButton.CalcCoord;
var Center     : Integer;
    TextOffSet : Integer;        // Set to FTextOffSet when Glyph is present
    GWidth,
    GHeight    : Integer;
Begin
 If ((ImageIndex>-1) AND (Assigned(FImageList))) Then // Find out glyph Location
 Begin                                                // and obtains its sizes.
   TextoffSet:=FTextOffSet;
   GWidth:=FImageList.Width;
   GHeight:=FImageList.Height;
 End
 Else If Assigned(FGlyph) Then
      Begin
       TextoffSet:=FTextOffSet;
       GWidth:=FGlyph.Width;
       GHeight:=FGlyph.Height;
      End
      Else
      Begin
       TextOffSet:=0;
       GWidth:=0;
       GHeight:=0;
      End;
 Case FAlign Of
 glLeft : begin
            ImgY:=1+((Height-GHeight) div 2);
            If Length(FCaption)=0 Then
              ImgX:=((Width-GWidth) div 2)+1
            Else
            Begin
              Center:=(Width-(gWidth+TextOffset+Canvas.TextWidth(FCaption))) Div 2;
              ImgX:=Center;
              TxtX:=Center+TextOffset+GWidth;
              TxtY:=(Height-Canvas.TextHeight('H')) div 2;
            End;
           End;
 glRight : begin
             ImgY:=1+((Height-GHeight) div 2);
             If Length(FCaption)=0 Then
             ImgX:=(Width-GWidth) div 2
            Else
            Begin
              Center:=(Width-(GWidth+TextOffset+Canvas.TextWidth(FCaption))) Div 2;
              TxtX:=Center;
              ImgX:=Center+TextOffset+canvas.TextWidth(fCaption);
              TxtY:=(Height-Canvas.TextHeight('H')) div 2;
            End;
           End;
 glTop  : begin
             ImgY:=1+((Height-GHeight) div 2);
             If Length(FCaption)=0 Then
             ImgX:=(Width-GWidth) div 2
            Else
            Begin
              Center:=(Height-(GHeight+TextOffset+Canvas.TextHeight('H'))) Div 2;
              ImgY:=Center+1;
              ImgX:=(Width-GWidth) div 2;
              TxtY:=Center+TextOffset+canvas.TextHeight('H')+1;
              TxtX:=(Width-Canvas.TextWidth(fCaption)) div 2;
            End;
           End;
 glBottom : begin
             ImgY:=1+((Height-GHeight) div 2);
             If Length(FCaption)=0 Then
             ImgX:=(Width-GWidth) div 2
            Else
            Begin
              Center:=(Height-(GHeight+TextOffset+Canvas.TextHeight('H'))) Div 2;
              TxtY:=Center;
              ImgX:=(Width-GWidth) div 2;
              ImgY:=Center+TextOffset+canvas.TextHeight('H');
              TxtX:=(Width-Canvas.TextWidth(fCaption)) div 2;
            End;
           End;
  End;
End;


Procedure TtfXPButton.Paint;
var ARect : TRect;
Begin
  CopyCanvas:=TBitmap.create;       // Create a Temporary Canvas ..
  CopyCanvas.Transparent:=false;
  CopyCanvas.Width:=Width;
  CopyCanvas.Height:=Height;
  ARect:=rect(0,0,width,height);    // Get the work area ..
 With CopyCanvas DO
 Begin
  If Focused Then                   // Draw XP border when Focused ..
  Begin
    CopyCanvas.Canvas.Brush.Color:=FColors.BackHiColor;
    CopyCanvas.Canvas.FillRect(ARect);
  End
  Else
  Begin
    CopyCanvas.Canvas.Brush.Color:=FColors.BackColor;  // Else just draw plain view ..
    CopyCanvas.Canvas.FillRect(ARect);
  End;
  CalcCoord;
  DisplayGlyph;
  End;
  SetBKMode( CopyCanvas.Handle, TRANSPARENT );
  CopyCanvas.Canvas.Pen.Color:=CopyCanvas.Canvas.Font.Color;
  CopyCanvas.Canvas.TextOut(TxtX,TxtY,FCaption);
  Canvas.CopyMode := cmSrcCopy;
  self.Canvas.CopyRect(ARect,CopyCanvas.Canvas,Arect);  // Copy temp canvas ..
   If Focused Then Frame3d(Canvas,ARect,FColors.BorderColor,
                           FColors.BorderColor,FBorderWidth);  // draw hilight border

  CopyCanvas.Free;
end;

procedure Register;
begin
  RegisterComponents('Transpear XP', [TtfXPButton]);
end;

end.
