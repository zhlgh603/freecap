(*******************************************************************************

 XP Form v1.0 (c) 2001 Transpear Software

 Coding by Kelvin Westlake

 Contact:  Http://www.transpear.net
           kwestlake@yahoo.com

 Please read enclosed License.txt before continuing any further,  you may also
 find some useful information in the Readme.txt.

 USAGE:

 To use this simply make sure it is the first thing dropped on your Form,
 Add a TPanel and set its Align to alClient, now use this panel as the parent
 for all your other control.

 During Runtime XP Form will remove the Forms borders and give the XP look.

 How does it work:

 the Title bar is divided into 3 bitmap sections, the corners and the centre.
 the corners stay the exact same size (to maintain the curve) but when
 you stretch the form the Centre bitmap is stretched. The bottom bar
 is operates the same way as the, except the bitmaps are inverted. The
 sides are draw through using the standard canvas drawing routines.



*******************************************************************************)
unit XP_Form;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Imglist,
  ExtCtrls, StdCtrls, Buttons, HightlightButton, XP_Utils;


type
   TXPTitle = Class (TCustomPanel)
   private
      FDragging: Boolean;
      FLastPos : TPoint;
      LPic,rPic,MPic : TBitmap;
      FCanvas : TBitmap;
      FCaption : String;
      FCaptionX,
      FCaptionY  : Integer;
      ParentForm : TComponent;

      property ALign;
      procedure PaintXPBar;
      Procedure LoadTopTitleBitmaps;
      procedure SetCaption(st : String);
      procedure MouseDownHandler(Sender: TObject; Button: TMouseButton;
         Shift: TShiftState; X, Y: Integer);
      procedure MouseMoveHandler(Sender: TObject; Shift: TShiftState; X,
         Y: Integer);
      procedure MouseUpHandler(Sender: TObject; Button: TMouseButton;
         Shift: TShiftState; X, Y: Integer);
      Procedure DoubleClickHandler(Sender : TObject);
   protected
      Procedure Paint; override;
   public
      Procedure LoadBottomBitmaps;
      procedure Resize; override;
      constructor create(AOwner : TComponent); override;
      destructor destroy; override;
   published
      property TitleText:string read fCaption write setCaption;
      Property CaptionX:Integer read FCaptionX write FCaptionX;
      property CaptionY:Integer read FCaptionY write FCaptionY;
   end;

   PanelPosition = (xpLeft,xpRight,xpBottom);

   TXPSidePanel = class(TCustomPanel)
   private
      PanelPos : PanelPosition;
   public
      procedure paint; override;
   published
   end;

  TtfXPForm = class(TCustomPanel)
  private
    FTitle : TXPTitle;
    FBottomBar : TXPTitle;
    FLeftPanel : TXPSidePanel;
    FRightPanel : TXPSidePanel;
    FBottomPanel : TXPSidePanel;
    ClientPanel  : TPanel;
    FBorderColor: TColor;

    FNormalImg    : TImageList;
    FHightLightImg: TImageList;
    FPushedImg    : TImageList;

    FMinimizeBtn : THightlightButton;
    FMaximizeBtn : THightlightButton;
    FCloseBtn    : THightlightButton;

    FParentForm  : TForm;

    procedure OnMinimizeClick(Sender: TObject);
    procedure OnMaximizeClick(Sender: TObject);
    procedure OnCloseClick(Sender: TObject);

    procedure SetBorderColor(const Value: TColor);
    function GetRegion: HRgn;
    procedure DrawFormShape(Canvas: TCanvas);
    Procedure InitializeSidePanels;
    Property Align;
    Function  GetCaption:string;
    Procedure SetCaption(st : String);
    Function  GetCaptionFont:TFont;
    Procedure SetCaptionFont(fnt : TFont);
    Function  GetCaptionHeight:Integer;
    Procedure SetCaptionHeight(h : Integer);
    Function  GetCaptionX:Integer;
    Procedure SetCaptionX(xoffset : Integer);
    Function  GetCaptionY:Integer;
    Procedure SetCaptionY(Yoffset : Integer);

    Function  GetBottomCaption:string;
    Procedure SetBottomCaption(st : String);
    Function  GetBottomCaptionFont:TFont;
    Procedure SetBottomCaptionFont(fnt : TFont);
    Function  GetBottomCaptionHeight:Integer;
    Procedure SetBottomCaptionHeight(h : Integer);
    Function  GetBottomCaptionX:Integer;
    Procedure SetBottomCaptionX(xoffset : Integer);
    function  GetBottomStatus:Boolean;
    procedure SetBottomStatus(st : Boolean);
    procedure BuildFormControls(ABar: TXPTitle);
    procedure SetControlsPosition();
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetParent(AParent: TWinControl); override;
    procedure Resize; override;
  published
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property TitleCaption:String read GetCaption write SetCaption;
    Property TitleFont: TFont read GetCaptionFont write SetCaptionFont;
    property TitleHeight:Integer read GetCaptionHeight write SetCaptionHeight;
    Property TitleXOffset:Integer read GetCaptionX write SetCaptionX;
    Property TitleYOffset:Integer read GetCaptionY write SetCaptionY;

    property BottomTitleCaption:String read GetBottomCaption write SetBottomCaption;
    Property BottomTitleFont: TFont read GetBottomCaptionFont write SetBottomCaptionFont;
    property BottomTitleHeight:Integer read GetBottomCaptionHeight write SetBottomCaptionHeight;
    Property BottomTitleXOffset:Integer read GetBottomCaptionX write SetBottomCaptionX;
    Property BottomBarEnabled:boolean read GetBottomStatus write SetBottomStatus default true;
    property Color;
  end;

procedure Register;

implementation

{$R XP_Form_Bitmaps}


(*******************************************************************************
  TSidePanel

  The Side Panel is used by the XPForm to draw the Sides+bottom borders.
  They ensure that no other onform component can screw up the sides,
  although if another control has its alignment set to  top/bottom this will
  side/border panel therefore also ruining the effect.
  to get around this simple drop a Panel onto the XPForm and set it alignment
  to Client ONLY,  then place all of your controls on this.

(******************************************************************************)
procedure TXPSidePanel.paint;
begin
  If Visible Then
  with Canvas do
  begin
   If PanelPos=xpLeft Then
   Begin
    Brush.Style := bsSolid;   // Draw Left Hand side of the form ..
    Pen.Color := $00CE1800;    // Left Outter Limit
    MoveTo(0,0);
    LineTo(0,Height);
    Pen.Color :=$00DE3000;     // Left Middle Limit
    MoveTo(1,0);
    LineTo(1,height);
    Pen.Color := $00FF5220;    // Left Inner Limit
    MoveTo(2,0);
    LineTo(2,Height);
   End;
   If PanelPos=xpBottom Then
   Begin
   Pen.Color := $00BD1418;    // Bttom Outter Edge
    MoveTo(0,Height);
    LineTo(Width,Height);
    Pen.Color := $00EF5D08;    // Right Middle
    MoveTo(0,Height-1);
    LineTo(Width,Height-1);
    Pen.Color :=  $00EF6908;   // Right Inner
    MoveTo(0,Height-2);
    LineTo(Width,Height-2);
   End;
   If PanelPos=xpRight Then
   Begin
    Pen.Color := $00941400;    // Right Outter Edge
    MoveTo(Width,0);
    LineTo(Width,Height);
    Pen.Color := $00E74108;    // Right Middle
    MoveTo(Width-1,0);
    LineTo(Width-1,Height);
    Pen.Color :=  $00F54508;   // Right Inner
    MoveTo(Width-2,0);
    LineTo(Width-2,Height);
    Pen.Color :=  $00F54508;   // Right Inner
    MoveTo(Width-3,0);
    LineTo(Width-3,Height);
   End;
  End;
End;


(*******************************************************************************
  TXPTitle Panel

  The title uses 3 Bitmaps loaded in from the XP_Form_Bitmaps.res file.
  these are used to set the left,middle,right border effect (respectively).
  because the Left + Right bitmaps have rounded corners and so these are
  staticlly placed.  The middle bitmap on the other hand is stretched from
  Left to Right (the colours used are very well blended, hence the reason for
  very little pixelation).

(******************************************************************************)

////////////////////////////////////////////////////////////////////////////////
// Creation ..

constructor TXPTitle.Create(AOwner: TComponent);
Begin
  Inherited;
  FCanvas:=TBitmap.create;             // Temporary Canvas (stops flicker)
  MPic:=TBitmap.create;                // Title bitmap containters
  LPic:=TBitmap.create;
  RPic:=TBitmap.Create;
  LoadTopTitleBitmaps;
  self.OnMouseDown:=MouseDownHandler;              // Assign Drag Handling
  self.OnMouseMove:=MouseMoveHandler;
  self.OnMouseUp:=MouseUpHandler;
  Self.OnDblClick:=DoubleClickHandler;             // assign Size handling ..
  fCaption:=''; // Set some defaults
  FCaptionX:=8;          FCaptionY:=7;
  Font.Name:='Tahoma';   Font.Size:=10;
  Font.Style:=[fsBold];  Font.Color:=clWhite;
  AutoSize:=false;
End;

Procedure TXPTitle.LoadTopTitleBitmaps;
Begin
    LPic.LoadFromResourceName(HInstance,'TOP_LEFT_BMP');  // load bitmaps from resource
    MPic.LoadFromResourceName(HInstance,'TOP_MID_BMP');
    RPic.LoadFromResourceName(HInstance,'TOP_RIGHT_BMP');
End;


Procedure TXPTitle.LoadBottomBitmaps;
Begin
    LPic.LoadFromResourceName(HInstance,'BOTTOM_LEFT_BMP');  // load bitmaps from resource
    MPic.LoadFromResourceName(HInstance,'BOTTOM_MID_BMP');
    RPic.LoadFromResourceName(HInstance,'BOTTOM_RIGHT_BMP');
End;


destructor TXPTitle.Destroy;
begin
  LPic.free;
  RPic.free;
  MPic.Free;
  FCanvas.Free;
  inherited;
end;

////////////////////////////////////////////////////////////////////////////////
// Painting + Resizing

procedure TXPTitle.SetCaption(st : String);
Begin
  fCaption:=st;
  Paint;
End;

procedure TXPTitle.PaintXPBar;
Var ARect : Trect;
Begin
 FCanvas.Width:=Width;               // Always make sure Temp canvas is correct size
 FCanvas.Height:=Height;
 ARect:=Rect(0,0,LPic.Width,Height);
 FCanvas.Canvas.StretchDraw(ARect,LPic);   // Stretch to Left to correct Height, NEVER strech width
 Arect:=Rect(Width-RPic.Width-2,0,Width,Height);  // Calc Right Bitmap placement ..
 FCanvas.Canvas.StretchDraw(ARect,RPic);           // stretch it to write height
 Arect:=Rect(LPic.Width-2,0,Width-RPic.Width-2,Height);  // Calculate centre from Left to right
 fCanvas.Canvas.StretchDraw(ARect,mPic);    // Stretch Middle .. Both Width and Height ..
 Invalidate;
End;

procedure TXPTitle.resize;
begin
 inherited;
 PaintXPBar;
End;

procedure TXPTitle.paint;
var OldColor : TColor;
begin
 inherited;
 Canvas.Draw(0,0,FCanvas);
 OldColor:=Canvas.Font.Color;
 Canvas.Font.Color:=clBlack;                         // Draw title shadow
 Canvas.TextOut(FCaptionX+2,FCaptionY+2,fCaption);
 Canvas.Font.Color:=OldColor;
 Canvas.TextOut(FCaptionX,FCaptionY,fCaption);
End;


////////////////////////////////////////////////////////////////////////////////
// Mouse Handlers

// removing the comments braces and this will allow the form to
// be resized to Maximum when the title is double clicked ..
Procedure TXPTitle.DoubleClickHandler(Sender : TObject);
Begin
{  ParentForm :=owner;
  while (parentForm <> nil) and not (ParentForm Is TCustomform) do     // Search for parent ..
    ParentForm := ParentForm.owner;
   TCustomForm(ParentForm).Hide;      //Enabled Maximise / Normalise
 If TCustomForm(ParentForm).Windowstate=wsMaximized Then TCustomForm(ParentForm).Windowstate:=wsNormal else
  TCustomForm(ParentForm).Windowstate:=wsMaximized;
 TCustomForm(ParentForm).show;       }
End;


procedure TXPTitle.MouseDownHandler(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ParentForm :=owner;
  while (parentForm <> nil) and not (ParentForm Is TCustomform) do     // Search for parent ..
    ParentForm := ParentForm.owner;
  if parentForm = nil then
  begin
    halt;                        // !!! Halt if no Parent form is found
  end;                           // VERY DANGEROUS, really needs exception handling
  SetCaptureControl( Sender As TXPTitle );
  FDragging := True;           // Ok were is business .. start dragging
  FLastPos := TWinControl(Sender).ClientToScreen( Point(X, Y));
end;

procedure TXPTitle.MouseMoveHandler(Sender: TObject; Shift: TShiftState; X, Y: Integer);
Var
  pos: TPoint;
begin
  If FDragging Then Begin
   pos:= (Sender As TXPTitle).ClientToScreen( Point(X, Y));
    If (pos.X <> FLastPos.X) or (pos.Y <> FLastPos.Y) Then Begin
      (ParentForm as TCustomForm).SetBounds( (ParentForm as TCustomForm).Left + (Pos.X - FLastPos.X),
                 (ParentForm as TCustomForm).Top  + (Pos.Y - FLastPos.Y),
                 (ParentForm as TCustomForm).Width, (ParentForm as TCustomForm).Height );
      FLastPos := Pos;
    End;
  End;
end;

procedure TXPTitle.MouseUpHandler(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If FDragging Then Begin
    FDragging := False;
    SetCaptureControl( nil );
  End; { If }
end;



(*******************************************************************************
  TtfXPForm

  Is actually a Custom Panel and then at run time its Canvas is used to create
  the outline for form.  The shape is achieved through drawing a rounded
  rectangle and then just offset below that we draw a normal rectangle this
  ensure the top has rounded corners,  the Canvas is then converted to a bitmap
  and the region inside these Shapes (the rectangles) is calculated, this info
  is then passed to the API so that the new shape of the form can be achieved.

*******************************************************************************)

////////////////////////////////////////////////////////////////////////////////
// Initialisation Routines

constructor TtfXPForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := alClient;
  Color := clInfoBk;
  FBorderColor := clWindowFrame;
  FTitle := TXPTitle.Create(self);


  FBottomBar := TXPTitle.Create(self);
  InitializeSidePanels;
  with FTitle do
  begin
    Align := alTop;
    Alignment := taCenter;
    AutoSize := false;
    BevelOuter := bvNone;
    Parent := self;
    FTitle.Height := 32; //GetSystemMetrics(SM_CYCAPTION);
    ControlStyle := ControlStyle - [csAcceptsControls];
  end;
  InitializeSidePanels;
  with FBottomBar do
  begin
    Align := alBottom;
    Alignment := taCenter;
    AutoSize := false;
    BevelOuter := bvNone;
    Parent := self;
    Height := 32;
    ControlStyle := ControlStyle - [csAcceptsControls];
    LoadBottomBitmaps;
  end;
//   FBottomPanel.Hide;
  BuildFormControls(FTitle);
end;


destructor TtfXPForm.Destroy;
begin
    FNormalImg.Free;
    FHightLightImg.Free;
    FPushedImg.Free;

    FMinimizeBtn.Free;
    FMaximizeBtn.Free;
    FCloseBtn.Free;

  inherited Destroy;
end;


Procedure ttfXPForm.InitializeSidePanels;
Var Extra : Integer;
Begin
  Extra:=0;
  If (Assigned(FBottomBar)) then
   If FBottomBar.Visible Then Extra:=FBottomBar.Height;
  If Not Assigned(FLeftPanel) Then FLeftPanel := TXPSidePanel.create(self);  // Set up Side panels ..
  With FLeftPanel Do
  Begin
    Align := alLeft;
    Alignment := taCenter;
    AutoSize := false;
    BevelOuter := bvNone;
    Parent := self;
    Width:=1;
    ControlStyle := ControlStyle - [csAcceptsControls];
    PanelPos:=xpLeft;
  End;
  If Not Assigned(FRightPanel) Then FRightPanel := TXPSidePanel.create(self);
  With FRightPanel Do
  Begin
    Align := alRight;
    Alignment := taCenter;
    AutoSize := false;
    BevelOuter := bvNone;
    Parent := self;
    Width:=1;
    BorderWidth:=0;
    ControlStyle := ControlStyle - [csAcceptsControls];
    PanelPos:=xpRight;
  End;

  IF Not FBottomBar.visible Then
  Begin
   If Not Assigned(FBottomPanel) Then   FBottomPanel := TXPSidePanel.create(self);
   With FBottomPanel Do
   Begin
     Align := alBottom;
     color:= clInfobk;
     Alignment := taCenter;
     AutoSize := false;
     BevelOuter := bvNone;
     Parent := self;
     BorderWidth:=0;
     Height:=2;
     ControlStyle := ControlStyle - [csAcceptsControls];
     PanelPos:=xpBottom;
   End;
  End;
End;


////////////////////////////////////////////////////////////////////////////////
// Custom Form Drawing Routines ..


procedure TtfXPForm.DrawFormShape(Canvas: TCanvas);
begin
   Canvas.RoundRect(0,0,Width,Height,20,20);
  If not FBottomBar.Visible then Canvas.Rectangle(0,10,width,height);
   canvas.pen.color:=clBlue;
//   Canvas.FrameRect(Rect(1,10,Width-2,Height-2));
end;

function TtfXPForm.GetRegion: HRgn;
var
  B: TBitmap;
begin
  B := TBitmap.Create;
  try
    B.Width := Width;
    B.Height := Height;
    B.Canvas.Brush.Style := bsSolid;
    B.Canvas.Brush.Color := clBlack;
    B.Canvas.Pen.Color := clBlack;
    DrawFormShape(B.Canvas);
    Result := CreateRegionFromBitmap(B, clWhite);
  finally
    B.Free;
  end;
end;

procedure TtfXPForm.Paint;
begin
  with Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := Color;
    DrawFormShape(Canvas);
    SetControlsPosition();
  end;
end;

procedure TtfXPForm.Resize;
var
  Rgn: HRgn;
begin
  inherited ;
  if csDesigning in ComponentState then Exit;
  if (Owner is TWinControl) then
    with (Owner as TWinControl) do
    begin
      Rgn := GetRegion;
      if Rgn <> 0 then
        SetWindowRgn(Handle, Rgn, true);
      SetControlsPosition();
    end;
end;


////////////////////////////////////////////////////////////////////////////////
// Accessors and Mutators ...

procedure TtfXPForm.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  Invalidate;
end;

procedure TtfXPForm.SetParent(AParent: TWinControl);
begin
  inherited;
  if (AParent <> nil) and (AParent is TForm) then
  begin
       FParentForm := (AParent as TForm);
       FParentForm.BorderStyle := bsNone;
  end;
end;

Function TtfXPForm.GetCaptionFont:TFont;
begin
 result:=FTitle.Font;
End;

Procedure TtfXPForm.SetCaptionFont(fnt : TFont);
Begin
 FTitle.font:=fnt;
 Invalidate                 // We need to force a the boundaries to reset ..
End;                     // else some Corners will appear in the top ..

Function TtfXPForm.GetCaptionHeight:Integer;
begin
  result:=fTitle.Height;
End;

Procedure TtfXPForm.SetCaptionHeight(h : Integer);
Begin
 FTitle.Height:=h;
 Invalidate;             // We need to force a the boundaries to reset ..
End;                     // else some Corners will appear in the top ..

Function TtfXPForm.GetCaptionX:Integer;
begin
  result:=fTitle.CaptionX;
End;

Procedure TtfXPForm.SetCaptionX(xoffset : Integer);
Begin
 FTitle.CaptionX:=Xoffset;
 Resize;             // We need to force a the boundaries to reset ..
 paint;
 End;                     // else some Corners will appear in the top ..


Function TtfXPForm.GetCaptionY:Integer;
begin
  result:=fTitle.CaptionY;
End;

Procedure TtfXPForm.SetCaptionY(Yoffset : Integer);
Begin
 FTitle.CaptionY:=Yoffset;
 Resize;             // We need to force a the boundaries to reset ..
 paint;
End;                     // else some Corners will appear in the top ..


Function TtfXPForm.GetCaption:string;
begin
 result:=FTitle.titleText;
 End;

Procedure TtfXPForm.SetCaption(st : String);
Begin
 FTitle.Titletext:=st;
 Invalidate                 // We need to force a the boundaries to reset ..
End;                     // else some Corners will appear in the top ..


Function TtfXPForm.GetBottomCaptionFont:TFont;
begin
 result:=FBottomBar.Font;
End;

Procedure TtfXPForm.SetBottomCaptionFont(fnt : TFont);
Begin
 FBottomBar.font:=fnt;
 Invalidate                 // We need to force a the boundaries to reset ..
End;                     // else some Corners will appear in the top ..

Function TtfXPForm.GetBottomCaptionHeight:Integer;
begin
  result:=FBottomBar.Height;
End;

Procedure TtfXPForm.SetBottomCaptionHeight(h : Integer);
Begin
 FBottomBar.Height:=h;
 Invalidate;             // We need to force  the boundaries to reset ..
End;                     // else some Corners will appear in the top ..

Function TtfXPForm.GetBottomCaptionX:Integer;
begin
  result:=FBottomBar.CaptionX;
End;

Procedure TtfXPForm.SetBottomCaptionX(xoffset : Integer);
Begin
 FBottomBar.CaptionX:=Xoffset;
 FBottomBar.Invalidate;

 // Resize;             // We need to force a the boundaries to reset ..
// paint;
End;                     // else some Corners will appear in the top ..


Function TtfXPForm.GetBottomCaption:string;
begin
 result:=FBottomBar.titleText;
End;

Procedure TtfXPForm.SetBottomCaption(st : String);
Begin
FBottomBar.Titletext:=st;
 Invalidate                 // We need to force a the boundaries to reset ..
End;                     // else some Corners will appear in the top ..

function TtfXPForm.GetBottomStatus:Boolean;
Begin
  Result:=FBottomBar.Visible;
end;

Procedure TtfXPForm.SetBottomStatus(st : Boolean);
Begin
  FBottomBar.Visible:=st;
//  If St Then FBottomPanel.Free;
  Resize;
End;

procedure Register;
begin
  RegisterComponents('Transpear XP', [TtfXPForm]);
end;

procedure TtfXPForm.BuildFormControls(ABar: TXPTitle);
var
   bmp, maskBmp: TBitmap;
begin
    bmp    := TBitmap.Create;
    maskBmp:= TBitmap.Create;

    FNormalImg  := TImageList.CreateSize(23, 23);
    FNormalImg.DrawingStyle := dsTransparent;
    bmp.LoadFromResourceName(HInstance, 'XP_WND_NORMAL');
    FNormalImg.Add(bmp, nil);

    FHightLightImg := TImageList.CreateSize(23, 23);
    FHightLightImg.DrawingStyle := dsTransparent;
    bmp.LoadFromResourceName(HInstance, 'XP_WND_HIGHTLIGHT');
    FHightLightImg.Add(bmp, nil);

    FPushedImg    := TImageList.CreateSize(23, 23);
    FPushedImg.DrawingStyle := dsTransparent;
    bmp.LoadFromResourceName(HInstance, 'XP_WND_PUSHED');
    FPushedImg.Add(bmp, nil);



    FCloseBtn    := THightlightButton.Create(Self);
    with FCloseBtn do
    begin
         Parent := ABar;
         NormalImages := FNormalImg;
         NormalIndex := 4;
         HightlightImages := FHightLightImg;
         HightlightIndex := 4;
         PushedImages := FPushedImg;
         PushedIndex := 4;
         Top := 5;
         OnClick := OnCloseClick;
//         Width := GetSystemMetrics(SM_CXSIZE);
//         Height := GetSystemMetrics(SM_CYSIZE);
    end;

    FMaximizeBtn := THightlightButton.Create(Self);
    with FMaximizeBtn do
    begin
         Parent := ABar;
         NormalImages := FNormalImg;
         NormalIndex := 2;
         HightlightImages := FHightLightImg;
         HightlightIndex := 2;
         PushedImages := FPushedImg;
         PushedIndex := 2;
         OnClick := OnMaximizeClick;
         Top := 5;
//         Width := GetSystemMetrics(SM_CXSIZE);
//         Height := GetSystemMetrics(SM_CYSIZE);
    end;

    FMinimizeBtn := THightlightButton.Create(Self);
    with FMinimizeBtn do
    begin
         Parent := ABar;
         NormalImages := FNormalImg;
         NormalIndex := 1;
         HightlightImages := FHightLightImg;
         HightlightIndex := 1;
         PushedImages := FPushedImg;
         PushedIndex := 1;
         OnClick := OnMinimizeClick;
         Top := 5;
//         Width := GetSystemMetrics(SM_CXSIZE);
//         Height := GetSystemMetrics(SM_CYSIZE);
    end;


    bmp.Free;
    maskBmp.Free;
end;

procedure TtfXPForm.SetControlsPosition;
begin
     FCloseBtn.Visible := True;
     FMaximizeBtn.Visible := True;
     FMinimizeBtn.Visible := True;

     if biSystemMenu in FParentForm.BorderIcons then
     begin
          FCloseBtn.Top := (Self.TitleHeight div 2) - (FCloseBtn.Height div 2);
          FMaximizeBtn.Top := (Self.TitleHeight div 2) - (FMaximizeBtn.Height div 2);
          FMinimizeBtn.Top := (Self.TitleHeight div 2) - (FMinimizeBtn.Height div 2);

          FCloseBtn.Left := Width - FCloseBtn.Width - 5;
          FMaximizeBtn.Left := FCloseBtn.Left - FMaximizeBtn.Width - 1;
          FMinimizeBtn.Left := FMaximizeBtn.Left - FMinimizeBtn.Width - 1;

          FMaximizeBtn.Enabled := (biMaximize in FParentForm.BorderIcons);
          FMinimizeBtn.Enabled := (biMinimize in FParentForm.BorderIcons);

          if not (biMaximize in FParentForm.BorderIcons) and not (biMinimize in FParentForm.BorderIcons) then
          begin
               FMaximizeBtn.Visible := False;
               FMinimizeBtn.Visible := False;
          end;
     end
     else
     begin
          FCloseBtn.Visible := False;
          FMaximizeBtn.Visible := False;
          FMinimizeBtn.Visible := False;
     end;
end;

procedure TtfXPForm.OnCloseClick(Sender: TObject);
begin
     FParentForm.Close;
end;

procedure TtfXPForm.OnMaximizeClick(Sender: TObject);
begin
     if IsZoomed(FParentForm.Handle) then
     begin
          ShowWindow(FParentForm.Handle, SW_RESTORE);
          FMaximizeBtn.NormalIndex := 2;
          FMaximizeBtn.HightlightIndex := 2;
          FMaximizeBtn.PushedIndex := 2;
     end
     else
     begin
          ShowWindow(FParentForm.Handle, SW_MAXIMIZE);
          FMaximizeBtn.NormalIndex := 3;
          FMaximizeBtn.HightlightIndex := 3;
          FMaximizeBtn.PushedIndex := 3;
     end;
end;

procedure TtfXPForm.OnMinimizeClick(Sender: TObject);
begin
     Application.Minimize;
end;

end.
