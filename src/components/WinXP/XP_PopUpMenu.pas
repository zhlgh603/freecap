{*******************************************************************************

  Transpear XP Pop Up Menu v2.0

  (c) Transpear Software 2001

  http://www.transpear.net

  email:  kwestlake@yahoo.com

  Please read enclosed License.txt before continuing any further,  you may also
  find some useful information in the Readme.txt.

 How to use it:
 -------------

  XP PopUpMenu is really 2 menu systems in 1,  by Turning the XP property on
  the menus will assume a XP style look. through turning it off you can
  you can use a Gradient for the selected Menu Bar.

  almost every single color used by the menu system can be customised by
  setting the appropriate value in the BarColors property.

  As measuring the height of a menu is impossible (until popup is intiated)
  Windows provides an exclusion zone, you can use this to ensure that a Menu
  never pops up in a rectangle. This is useful if you wish too avoid the menu
  popping up and covering the button that showed it ..

  Please see the enclosed Demo's for examples of usage.

 How Does it Work:
 ----------------

  This is a enhanced menu system (not only through looks) it has been designed
  to work PROPERLY with ActiveX/bandOjects. Delphi standard TPopUPMenu wrapper
  has several very limiting factors -

  Through using Owner Draw (see my website for links to some cool tutorials),
  Each TMenuItem's OwnerDraw handlers are set through overriding the standard
  Forms handler (This is dagerous to do, and can make applications unstable).

 The Advanced Stuff:
 ------------------

  BandObjects thread themselves when ever more than one instance of them is
  active, because TPopUpList is global and continually resides in the SAME thread
  so all the instances of the BandObject have too share the same PopUpList.

  How can this be? only one band exists at a time?

  The first thing you must understand, BandObjects CAN-AND-DO exist in multiple
  instances.  When you activate a Deskband on the Taskbar only 1 instance of it
  is running, but when ever you relocate the Deskband (removing it from the taskbar)
  another instance of it is created and the Taskbar band is removed -
  NOT DESTROYED, BUT MERELY HIDDEN.

  This is similar to a Internet Explorer band, there might be several IE
  Windows present at anyone time - each of these could be running an instance
  of your band. The same problem above.

  Many Thanks
  -----------

   Khaled Shagrouni - For his XP gfx rountines, his XPMenu is included and is
                      freeware.


{******************************************************************************}


unit XP_PopUpMenu;

interface

uses
  Messages,Windows, SysUtils, Classes, Graphics, Menus,Controls, extctrls, Forms,
  XP_Utils;

const
  BarSpace = 2;

type
  TBitmapVertAlignment = (bvaTop, bvaBottom, bvaMiddle);
  TBitmapHorzAlignment = (bhaLeft, bhaRight, bhaCenter);


  TfBarColors = class (TPersistent)
  private
    FOnChange : TNotifyEvent;
    IconColor,
    CheckBoxColor,
    ItemGradStart,
    ItemGradEnd,
    FontHiColor,
    FontLoColor,
    BorderColor,
    MenuBackColor : TColor;
  Protected
    property OnChange:TNotifyEvent read FOnChange write FOnChange;
  public
  constructor create;
  published
    property ItemGradientEnd: TColor read ItemGradEnd write ItemGradEnd default clHighLight;
    property ItemGradientStart: TColor read ItemGradStart write ItemGradStart default clHighlight;
    property BackgroundColor : TColor Read MenuBackColor write MenuBackColor default clBtnFace;
    property FontHilightColor : TColor Read FontHiColor write FontHiColor default clHighLightText;
    property FontNormalColor : TColor Read FontLoColor write FontLoColor default clMenuText;
    property XPBorderColor : TColor Read BorderColor write BorderColor default clHighLight;
    property IconBackground : TColor Read IconColor write IconColor default $00DFE2E6;
    property CheckBoxBackground : TColor Read CheckBoxColor write CheckBoxColor default $009C7173;
  end;

  Type XPMenuTitle = Class(TPersistent)
  Private
    FBarWidth: Integer;
    FBitmap: TBitmap;
    FBitmapOffsetX,
    FBitmapOffsetY: Integer;
    FBitmapVertAlignment: TBitmapVertAlignment;
    FBitmapHorzAlignment: TBitmapHorzAlignment;
    FVerticalFont: TFont;
    FVerticalText: string;
    FVerticalTextOffsetY: Integer;
    FclStart,
    FclEnd: TColor;
    function GetBitmap: TBitmap;
    procedure SetBitmap(Value: TBitmap);
    procedure SetVerticalFont(Value: TFont);
    procedure SetTransparent(Value: Boolean);
    function  GetTransparent: Boolean;
    Procedure  SetVerticalBarWidth(width : Integer);
 Public
    Constructor Create;
    Destructor  Destroy; override;
 Published
    property Bitmap: TBitmap read GetBitmap write SetBitmap;
    property BitmapOffsetX: Integer read FBitmapOffsetX write FBitmapOffsetX default 0;
    property BitmapOffsetY: Integer read FBitmapOffsetY write FBitmapOffsetY default 0;
    property BitmapVertAlignment: TBitmapVertAlignment read FBitmapVertAlignment
             write FBitmapVertAlignment default bvaBottom;
    property BitmapHorzAlignment: TBitmapHorzAlignment read FBitmapHorzAlignment
             write FBitmapHorzAlignment default bhaLeft;
    property BitmapTransparent: Boolean read GetTransparent write SetTransparent default True;
    property GradientEnd: TColor read FclEnd write FclEnd default clBlack;
    property GradientStart: TColor read FclStart write FclStart default clBlue;
    property TitleBarWidth: Integer read FBarWidth write SetVerticalBarWidth default 31;
    property VerticalFont: TFont read FVerticalFont write SetVerticalFont;
    property VerticalText: string read FVerticalText write FVerticalText;
    property VerticalTextOffsetY: Integer read FVerticalTextOffsetY
             write FVerticalTextOffsetY default-6;
    End;


  TtfXPPopUpMenu = class(TPopupMenu)
  private
    { Private declarations }
    FakeImageList : TImageList;
    FVTitle : XPMenuTitle;
    FBorder : Boolean;
    FColors : tfBarColors;
    PopupHeight: Integer;
    Drawn: Boolean;
    StoreHeight : Integer;
    ExtraWidth : Integer;     // ONLY USE if you want wider menus ..
    FAllowExclusion : Boolean;
    LP : TPopUpList;
  protected
    { Protected declarations }
    procedure Notification(AComponent: TComponent;Operation: TOperation); override;
    Procedure DrawSubItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    Procedure DrawItem(Sender: TObject; ACanvas: TCanvas;ARect: TRect; Selected: Boolean);
    procedure ExpandItemWidth(Sender: TObject; ACanvas: TCanvas; var Width,Height: Integer);
    procedure ExpandSubItemWidth(Sender: TObject;ACanvas: TCanvas; var Width,Height: Integer);
    procedure AdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;State: TOwnerDrawState);
    Procedure DrawGlpyh(Item : TMenuItem; Canvas : TCanvas; Arect : TRect; Idx : Integer);
    Procedure DrawCaption(Item : TMenuItem; Canvas : TCanvas; Arect : TRect);
    Procedure DrawTick(ACanvas : TCanvas; CheckedRect : TRect; Selected : Boolean);
    Procedure DrawChecked(Item : TMenuItem; ACanvas : TCanvas; ARect : TRect);
    Procedure DrawXPItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    Procedure DrawStandardItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    Procedure MakeSubCustomDraw(SubMenu : TMenuItem);
  public
    { Public declarations }
    ExcludeRect : TRect;
    constructor Create(AOwner: TComponent);  override;
    destructor Destroy; override;
    procedure Popup(X, Y: Integer); overload; override;
    Procedure SetCustomDrawn;
  published
    { Published declarations }
    Property BarColors:tfBarColors read FColors write fColors;
    Property ExtraWidthIfNeeded : Integer read ExtraWidth write ExtraWidth default 0;
    Property XP_Border: Boolean read FBorder write FBorder default True;
    Property MenuTitle:XPMenuTitle read FVTitle write FVTitle;
    Property ExclusionZone:Boolean Read FAllowExclusion Write FAllowExclusion default false;
    Property ExclusionArea:TRect read ExcludeRect Write ExcludeRect;
  end;




procedure Register;

implementation



{*****************************************************************************}
{*  Color Class Setting ..
{*****************************************************************************}

constructor tfBarColors.create;
begin
  ItemGradStart:=$00E7D3CE;
  ItemGradEnd:=$00E7D3CE;
  MenuBackColor:=$00F7F8F9;
  FontHiColor:=clHighLightText;
  FontHiColor:=clMenuText;
  BorderColor:=$009C7173;
  IconColor:=$00DFE2E6;
  CheckBoxColor:=$009C7173;
End;

{*****************************************************************************}
{*  Vertical Title Class Code
{*****************************************************************************}

Constructor XPMenuTitle.create;
Begin
  FBitmapOffsetX := 0;
  FBitmapOffsetY := 0;
  BitmapOffsetY:=-4;
  FBitmapVertAlignment := bvaBottom;
  FBitmapHorzAlignment := bhaLeft;
  FBarWidth := 20;
  FVerticalFont := TFont.Create;
  with FVerticalFont do
  begin
    Name := 'Arial Black';
    Size := 12;
    Color := $009C3031;
    Style := [fsBold];
  end;
  FVerticalTextOffsetY := -6;
  FclStart := clWhite;
  FclEnd :=   clWhite;
  if (Application.Handle <> 0) then
     FVerticalText:=Application.Name;
End;


Destructor XPMenuTitle.destroy;
Begin
 Try
   FVerticalFont.Free;
   if Assigned(FBitmap) then FBitmap.Free;
   FVerticalText := Application.Title; { some defaults }
   Inherited Destroy;
 Finally
 end;
End;


Procedure XPMenuTitle.SetVerticalBarWidth(width : Integer);
Begin
 if Width<1 then width:=1;
 FBarWidth:=Width;
End;


procedure XPMenuTitle.SetTransparent(Value: Boolean);
begin
  if FBitmap = nil then Exit;
//  if (Value <> FBitmap.Transparent) then
    FBitmap.Transparent := Value;
end;

function XPMenuTitle.GetTransparent: Boolean;
begin
  if FBitmap = nil then
    Result := False
  else
    Result := FBitmap.Transparent;
end;

procedure XPMenuTitle.SetBitmap(Value: TBitmap);
begin
  if FBitmap = nil then
  begin
    FBitmap := TBitmap.Create;
    FBitmap.Transparent:=True;
    BitmapTransparent := True;
  end;
    FBitmap.Assign(Value);
end;

function XPMenuTitle.GetBitmap: TBitmap;
begin
  if FBitmap = nil then
  begin
    FBitmap := TBitmap.Create;
    FBitmap.Transparent := True;
  end;
  Result := FBitmap;
end;

procedure XPMenuTitle.SetVerticalFont(Value: TFont);
begin
  FVerticalFont.Assign(Value);
end;



{*****************************************************************************}
{*  Menu Class Code
{*****************************************************************************}

constructor TtfXPPopUpMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  LP:=TPopUpList.Create;
  LP.Add(Self);
  StoreHeight:=0;           // used as a protective storage
  FAllowExclusion:=false;
  FColors:=tfBarColors.create;
  FVTitle:=XPMenuTitle.create;
  OwnerDraw := True;
  FBorder:=False;
  XP_Border:=True;
  FakeImageList:=TImageList.create(self);
  ExtraWidth:=0;
  With FakeImageList Do                   // Image.Width is used to set the draw
  Begin                                   // Coordinates, so if no image list
   Width:=16;                             // is present then we need a fake one
   Height:=16;
  End;
  Images:=FakeImageList;
end;


destructor TtfXPPopUpMenu.Destroy;
begin
 Try
  LP.Remove(self);
  LP.free;
  FColors.free;
  FVTitle.free;
  FakeImageList.free;
  inherited Destroy;
 Finally
 End;
end;

{    FakeImageList : TImageList;
    FVTitle : XPMenuTitle;
    FBorder : Boolean;
    FColors : tfBarColors;
    PopupHeight: Integer;
    Drawn: Boolean;
    StoreHeight : Integer;
    ExtraWidth : Integer;     // ONLY USE if you want wider menus ..
    FAllowExclusion : Boolean;
    LP : TPopUpList; }

procedure TtfXPPopUpMenu.Notification(AComponent: TComponent;Operation: TOperation);
Begin
If (AComponent=Images) Then
    If (Operation=OpRemove) Then Images:=FakeImageList;
Inherited Notification(AComponent,Operation);
End;


Procedure TtfXPPopUpMenu.SetCustomDrawn;
var i: Integer;
begin
  PopupHeight := 0;
  Drawn := False;
  if (Items.Count > 0) then
    for i := 0 to Items.Count-1 do
    begin
      Items[i].OnMeasureItem := ExpandItemWidth;
      Items[i].OnAdvancedDrawItem := AdvancedDrawItem;
      If Items[i].Count>0 Then MakeSubCustomDraw(Items[i]);
    end;
End;


procedure TtfXPPopUpMenu.Popup(X, Y: Integer);
var i: Integer;
  pm : TTPMParams;
  Store : TpopUpList;
begin
  Store:=PopUpList;             // Store the global list ..
  PopUpList:=LP;                // replace it with OUR Local Popup List ..
  with pm, pm.rcexclude do
  begin
    if FAllowExclusion then
    begin                       // set up our PopUp exclusion area
     Top    := ExcludeRect.Top;
     Bottom := ExcludeRect.Bottom;
     Left   := ExcludeRect.Left;
     Right  := ExcludeRect.Right;
     cbSize := SizeOf(pm);
    End
    Else
    Begin
     Top    := 0;
     Bottom := 0;
     Left   := 0;
     Right  := 0;
     cbSize := SizeOf(pm);
    End;
  end;
  PopupHeight := 0;
  Drawn := False;
  if (Items.Count > 0) then
    for i := 0 to Items.Count-1 do
    begin
      Items[i].OnMeasureItem := ExpandItemWidth;
      Items[i].OnAdvancedDrawItem := AdvancedDrawItem;
      If Items[i].Count>0 Then MakeSubCustomDraw(Items[i]);
    end;
   TrackPopupMenuEx(self.Handle,TPM_VERTICAL or TPM_HORIZONTAL,X,Y,PopUpList.Window,@pm);
   if StoreHeight=0 then StoreHeight:=PopUpHeight;  // If ensure the height
                                                    // is only recorded once,
                                                    // cause our own PopUp routine
                                                    // only returns the correct
                                                    // height on its first run ..
   PopUpList:=Store;     // Restore the Default ..
end;

Procedure TtfXPPopUpMenu.MakeSubCustomDraw(SubMenu : TMenuItem);
var i: Integer;
begin
  if (SubMenu.Count > 0) then
    for i := 0 to SubMenu.Count-1 do
    begin
      SubMenu.Items[i].OnMeasureItem := ExpandSubItemWidth;
      SubMenu.Items[i].OnDrawItem := DrawSubItem;
      If SubMenu.Items[i].Count>0 Then MakeSubCustomDraw(SubMenu.Items[i]);
    end;
End;


procedure TtfXPPopUpMenu.ExpandSubItemWidth(Sender: TObject;
  ACanvas: TCanvas; var Width, Height: Integer);
var
  MenuItem: TMenuItem;
begin
 MenuItem := TMenuItem(Sender);
 Width:=Width+ExtraWidth+6;  // NOT a good way of widening, but works for personal use
    if Trim(ShortCutToText(MenuItem.ShortCut)) <> '' then
       Width:=Width+(ACanvas.TextWidth(Trim(ShortCutToText(MenuItem.ShortCut))) div 2);
  if MenuItem.Visible then
  Begin
  If (Sender as TMenuItem).Caption='-' then Height:=3   // Set height for Divider
  else If XP_Border Then height:=height+6;
    PopupHeight := PopupHeight + Height;
  End;
End;


procedure TtfXPPopUpMenu.ExpandItemWidth(Sender: TObject;
  ACanvas: TCanvas; var Width, Height: Integer);
var
  MenuItem: TMenuItem;
begin
 MenuItem := TMenuItem(Sender);
 Width:=Width+ExtraWidth+6;
  If MenuItem.Owner is TPopUpMenu Then
  Width := Width + FVTitle.FBarWidth; { make space for graphical bar }
    if Trim(ShortCutToText(MenuItem.ShortCut)) <> '' then
       Width:=Width+(ACanvas.TextWidth(Trim(ShortCutToText(MenuItem.ShortCut))) div 2);
  if MenuItem.Visible then
  Begin
  If (Sender as TMenuItem).Caption='-' then Height:=3   // Set height for Divider
  else If XP_Border Then height:=height+6;
  PopupHeight := PopupHeight + Height;

  End;
End;

Procedure VertGradient(Canvas : TCanvas; ARect : TRect;
                                        StartCol, Endcol : TColor);
Var rc1, rc2, gc1, gc2, bc1, bc2: Byte;
    ColorStart, ColorEnd: Longint;
    i : Integer;
Begin
   begin
      ColorStart := ColorToRGB(StartCol);
      ColorEnd := ColorToRGB(endCol);
      rc1 := GetRValue(ColorStart); gc1 := GetGValue(ColorStart);
      bc1 := GetBValue(ColorStart); rc2 := GetRValue(ColorEnd);
      gc2 := GetGValue(ColorEnd);   bc2 := GetBValue(ColorEnd);
      for i := 0 to (Arect.Bottom-arect.Top) do  // Draw gradient to Length
      begin
        canvas.Brush.Color := RGB(
          (rc1 + (((rc2 - rc1) * (ARect.Top + i)) div arect.Bottom-arect.Top)),
          (gc1 + (((gc2 - gc1) * (ARect.Top + i)) div arect.Bottom-arect.Top)),
          (bc1 + (((bc2 - bc1) * (ARect.Top + i)) div arect.Bottom-arect.Top)));
          canvas.FillRect(Rect(Arect.Left, Arect.Top+i,
                          Arect.Right, (Arect.Bottom-Arect.Top)+i));
      end;
    end;
End;

procedure DrawTitleBar(x,y : Integer; Title : string ;nFont : TFont; Canvas: TCanvas);
var
  lf: TLogFont;
Begin
  With Canvas Do Begin
    Canvas.Font:=nFont;
    GetObject( Font.Handle, Sizeof(lf), @lf );
    lf.lfEscapement := 900;
    Font.Handle := CreateFontIndirect( lf );
    SetBKMode( canvas.Handle, TRANSPARENT );
    TextOut( X,Y, Title );
    DeleteObject( Font.Handle );
    Font.Handle := 0;
  End;
End;

////////////////////////////////////////////////////////////////////////////////
// Menu Title draw routine (but also calls Item Draw by swapping draw handlers

procedure TtfXPPopUpMenu.AdvancedDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
var
  x, y: Integer;
  r: TRect;
  MenuItem: TMenuItem;
begin
  MenuItem := TMenuItem(Sender);
  r := ARect;
  r.Right := r.Right - FVTitle.FBarWidth; { remove bar width }
  OffsetRect(r, FVTitle.FBarWidth, 0);
  DrawItem(MenuItem, ACanvas, r, ODSelected in State);
  If StoreHeight<>0 Then PopUpHeight:=StoreHeight;    // ensure the Protected height is always used if needed ..
  if not Drawn then
  begin
    ACanvas.Brush.Style := bsSolid;
     VertGradient(ACanvas,Rect(0,0,FVtitle.FBarWidth-barSpace,PopUpHeight),FVTitle.GradientStart,FVTitle.GradientEnd);
    y := PopupHeight + FVTitle.FVerticalTextOffsetY;
    ACanvas.Font:=FVTitle.VerticalFont;
    x := Round((FVTitle.FBarWidth - ACanvas.TextHeight('X')) / 2 - 0.5); { gives much better centering }
    if Assigned(FVTitle.FBitmap) and (FVTitle.FBitmapVertAlignment = bvaBottom)
                                              then y := y - FVTitle.FBitmap.Height;
    DrawTitleBar(x-1, y, FVTitle.VerticalText, FVTitle.VerticalFont, ACanvas);
    if PopupHeight = ARect.Bottom then
      begin
        Drawn := True;         { draw bitmap }
        if Assigned(FVTitle.FBitmap) then
        begin
          y := 0; x := 0;
          case FVTitle.FBitmapVertAlignment of
            bvaTop:    y := FVTitle.FBitmapOffsetY;
            bvaBottom: y := PopupHeight + FVTitle.FBitmapOffsetY - FVtitle.FBitmap.Height;
            bvaMiddle: y := ((PopupHeight - FVTitle.Fbitmap.Height) div 2) + FVTitle.FBitmapOffsetY;
          end;
          case FVTitle.FBitmapHorzAlignment of
            bhaLeft:   x := FVTitle.FBitmapOffsetX;
            bhaRight:  x := (FVTitle.FBarWidth - BarSpace) + FVTitle.FBitmapOffsetX - FVTitle.FBitmap.Width;
            bhaCenter: x := ((FVTitle.FBarWidth - BarSpace - FVTitle.FBitmap.Width) div 2) + FVTitle.FBitmapOffsetX;
          end;
          ACanvas.Draw(x, y, FVTitle.FBitmap);
        end;
      end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Menu Item Draw routines ...

Procedure TtfXPPopUpMenu.DrawTick(ACanvas : TCanvas; CheckedRect : TRect; Selected : Boolean);
var X1, X2: integer;
begin
IF Selected Then ACanvas.Pen.color := clWhite else ACanvas.Pen.color:=clBlack;
    ACanvas.Brush.Color := clWhite;
    ACanvas.Brush.Style := bsSolid;
    x1:= CheckedRect.Left + 1;
    x2 := CheckedRect.Top + 5;
    ACanvas.MoveTo(x1, x2);
    x1 := CheckedRect.Left + 4;
    x2 := CheckedRect.Bottom - 2;
    ACanvas.LineTo(x1, x2);
    x1:= CheckedRect.Left + 2;
    x2 := CheckedRect.Top + 5;
    ACanvas.MoveTo(x1, x2);
    x1 := CheckedRect.Left + 4;
    x2 := CheckedRect.Bottom - 3;
    ACanvas.LineTo(x1, x2);
    x1:= CheckedRect.Left + 2;
    x2 := CheckedRect.Top + 4;
    ACanvas.MoveTo(x1, x2);
    x1 := CheckedRect.Left + 5;
    x2 := CheckedRect.Bottom - 3;
    ACanvas.LineTo(x1, x2);
    x1 := CheckedRect.Left + 4;
    x2 := CheckedRect.Bottom - 3;
    ACanvas.MoveTo(x1, x2);
    x1:= CheckedRect.Right + 2;
    x2 := CheckedRect.Top - 1;
    ACanvas.LineTo(x1, x2);
    x1 := CheckedRect.Left + 4;
    x2 := CheckedRect.Bottom - 2;
    ACanvas.MoveTo(x1, x2);
    x1:= CheckedRect.Right - 2;
    x2 := CheckedRect.Top + 3;
    ACanvas.LineTo(x1, x2);
 end;



Procedure TtfXPPopUpMenu.DrawChecked(Item : TMenuItem; ACanvas : TCanvas; ARect : TRect);
Begin
  ACanvas.Brush.Color:=FColors.CheckBoxBackground;
  With Arect Do
  Begin
    ACanvas.FillRect(Rect(Left+2,Top+4,Left+20,Bottom-4));
    If (Item.ImageIndex<0) OR ((Images=FakeImageList) AND (Item.Parent.SubMenuImages=nil))
    Then DrawTick(ACanvas,Rect(Left+2,Top+4,Left+20,Bottom-4),true);
  End;
End;




Procedure TtfXPPopUpMenu.DrawGlpyh(Item : TMenuItem; Canvas : TCanvas; Arect : TRect; Idx : Integer);
Begin
   If (Item.Parent.SubMenuImages<>nil) Then
     Item.Parent.SubMenuImages.Draw(canvas,ARect.Left+4,
                         ((Arect.Bottom+Arect.Top)-Images.Height) Div 2,Idx,True)
  Else
   Images.Draw(canvas,ARect.Left+4,
               ((Arect.Bottom+Arect.Top)-Images.Height) Div 2,Idx,True);
End;


Procedure TtfXPPopUpMenu.DrawCaption(Item : TMenuItem; Canvas : TCanvas; Arect : TRect);
Var TextLeft   : Integer;
    Caption    : String;
    OldColor   : TColor;
    AccelIdx   : Integer;  // Accelerator index,  so we know were to draw the _
Begin
SetBKMode( canvas.Handle, TRANSPARENT );
If Assigned(Images) Then TextLeft:=Images.Width+12+Arect.Left
                    Else TextLeft:=Arect.Left+6;
If Item.Caption='-' then
Begin
   Canvas.Pen.Color:=$00ADAEAD;
   Canvas.MoveTo(TextLeft+4,Arect.Top+1);
   Canvas.LineTo(Arect.Right,Arect.Top+1);
   Exit;
End;
 OldColor:=Canvas.Font.Color;
 If Not Item.Enabled Then Canvas.Font.Color:=clGray;
 Caption:=RemoveChar(Item.Caption,'&',AccelIdx);  //  Remove controls chars from caption
 canvas.TextOut(TextLeft,
                   ((Arect.Bottom+Arect.Top)-
                   canvas.TextHeight('H')) Div 2,Caption);
 if Trim(ShortCutToText(Item.ShortCut)) <> '' then   // Show Shortcut Key ..
 Begin
   TextLeft:=(ARect.Right-Arect.Left)-
         Canvas.TextWidth(Trim(ShortCutToText(Item.ShortCut))+'X')-4;
   canvas.TextOut(TextLeft,
                   ((Arect.Bottom+Arect.Top)-
                   canvas.TextHeight('H')) Div 2,Trim(ShortCutToText(Item.ShortCut)));
   Canvas.Font.Color:=OldColor;
 End;
End;


Procedure TtfXPPopUpMenu.DrawXPItem(Sender: TObject; ACanvas: TCanvas;
                                    ARect: TRect; Selected: Boolean);
Var Item       : TMenuItem;
    InnerRect  : TRect;
    TempCanvas : TBitmap;
Begin
 TempCanvas := TBitmap.Create;    // Create a intermediary canvas
 Item:=(Sender As TMenuItem);
 With TempCanvas Do
 Begin
  Canvas.Brush.Color:=FColors.BackgroundColor;
  Canvas.FillRect(Arect);
  // give TempCanvas the same dimensions as menu Item
  width:=ARect.Right;   height:=ARect.Bottom;
 Canvas.font:=ACanvas.Font;
 Transparent:=true;
 Arect.Left:=Arect.Left-2;      // Extend size of Rect to fill all gaps ..
 ARect.Right:=ARect.Right+6;
 InnerRect:=ARect;
 inc(InnerRect.Left,1); dec(InnerRect.right,7);  // Rect inside XP border
 Inc(InnerRect.top,2);  dec(InnerRect.bottom,2);
 Case Selected Of
    True : Begin
            canvas.Brush.Color:=FColors.BackgroundColor;  // Clear Current background
            canvas.FillRect (ARect);
            canvas.Brush.Color:=FColors.IconBackground;  // Drawn Icon Box before Hilight, so that Bits above/below look uniform
            Canvas.FillRect(Rect(ARect.Left,ARect.Top,ARect.Left+Images.Width+8,ARect.Bottom));
            canvas.Font.Color:=FColors.FontHiColor;
            canvas.Brush.Color:=FColors.ItemGradStart;
            canvas.FillRect (InnerRect);
           End;
    False: Begin
            Canvas.font.Color:=FColors.FontLoColor;
            canvas.Brush.Color:=FColors.MenuBackColor;
            canvas.FillRect (InnerRect);
            canvas.Brush.Color:=FColors.IconBackground;
            Canvas.FillRect(Rect(ARect.Left,ARect.Top,ARect.Left+Images.Width+8,ARect.Bottom));
           End;
    End;
   If Item.Checked Then DrawChecked(item,Canvas,ARect);
   If Assigned(Images) Then DrawGlpyh(Item,Canvas,ARect,Item.ImageIndex);
   DrawCaption(Item,canvas,Arect);
   ACanvas.CopyRect(ARect,canvas,ARect);
 End;
 If (XP_Border) and (selected) then    // Only Draw XP border on main canvas..
    Frame3d(ACanvas,InnerRect,FColors.BorderColor,FColors.BorderColor,1);
 ACanvas.Refresh;                      // Force an Update
 TempCanvas.Free;
End;


Procedure TtfXPPopUpMenu.DrawStandardItem(Sender: TObject; ACanvas: TCanvas;
                                    ARect: TRect; Selected: Boolean);
Var Item : TMenuItem;
    TmpRect   : TRect;
    tmp : TBitmap;
Begin
 tmp := TBitmap.Create;    // Create a intermediary canvas
 tmp.width:=ARect.Right; tmp.height:=ARect.Bottom;
 tmp.Canvas.font:=ACanvas.Font;
 With Tmp Do
 Begin
  Item:=(Sender As TMenuItem);
  Arect.Left:=Arect.Left-2;
  ARect.Right:=ARect.Right+6;
 Case Selected Of
    True : Begin
             tmp.canvas.Font.Color:=FColors.FontHiColor;
             TmpRect:=ARect;
//            if (Assigned(Images)) And (Images.Width>24) Then Inc(TmpRect.Left,20);
             If FColors.ItemGradStart=FColors.ItemGradEnd Then
             Begin
               tmp.Canvas.Brush.Color:=FColors.ItemGradStart;
               tmp.canvas.FillRect (ARect);
             End
             Else HorizGradient(tmp.Canvas,TmpRect,
                        FColors.ItemGradStart,FColors.ItemGradEnd);
           End;
    False: Begin
             tmp.Canvas.font.Color:=FColors.FontLoColor;
             tmp.canvas.Brush.Color:=FColors.MenuBackColor;
             tmp.canvas.FillRect (ARect);
            End;
     End;
  If Assigned(Images) Then DrawGlpyh(Item,Canvas,ARect,Item.ImageIndex);
  DrawCaption(Item,canvas,Arect);
  ACanvas.CopyRect(ARect,canvas,ARect);
 End;
 ACanvas.Refresh;
 tmp.Free;
End;

Procedure TtfXPPopUpMenu.DrawSubItem(Sender: TObject; ACanvas: TCanvas;
                                    ARect: TRect; Selected: Boolean);
Begin
 Inc(Arect.Left,2);
 If XP_Border Then
   DrawXPItem(Sender,ACanvas,Arect,Selected)
 Else
   DrawStandardItem(Sender,ACanvas,Arect,Selected)
End;



Procedure TtfXPPopUpMenu.DrawItem(Sender: TObject; ACanvas: TCanvas;
                                    ARect: TRect; Selected: Boolean);
Begin
 If XP_Border Then
   DrawXPItem(Sender,ACanvas,Arect,Selected)
 Else
   DrawStandardItem(Sender,ACanvas,Arect,Selected)
End;




procedure Register;
begin
  RegisterComponents('Transpear XP', [TtfXPPopUpMenu]);
end;

end.
