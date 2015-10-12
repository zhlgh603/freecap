{*******************************************************************************

  Transpear XP Main Menu v1.0b

  (c) Transpear Software 2001

  http://www.transpear.net

  email:  kwestlake@yahoo.com

  Please read enclosed License.txt before continuing any further,  you may also
  find some useful information in the Readme.txt.

  How to use it:

  XP Menu is really 2 menu systems in 1,  by Turning the XP property on
  the menus will assume a XP style look. through turning it off you can
  you can use a Gradient for the Menu Bar.

  almost every single color used by the menu system can be customised by
  setting the appropriate value in the BarColors property.

  How Does it Work:

  Through using Owner Draw (see my website for links to some cool tutorials),
  Each TMenuItem's OwnerDraw handlers are set through overriding the standard
  Forms handler (This is dagerous to do, and can make applications unstable).

  ***** NOTE *****

  If you find you IDE keeps behaving wierdly or crashing then find the
  XPMainMenu.create() and comment the Marked block out. then call
  ForceXPStyle() at the end of your forms OnCreate().


  Please read all enclosed documentation BEFORE installing/using this software



{******************************************************************************}



unit XP_MainMenu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus,XP_PopUpMenu,XP_Utils,Extctrls;

Type ttfXPMainMenu = class(TMainMenu)
Private
   FBorder : Boolean;
   FColors : tfBarColors;
   FOriginalWndProc: TWndMethod;
   FakeImageList : TImageList;
    Procedure DrawItem(Sender: TObject; ACanvas: TCanvas;ARect: TRect; Selected: Boolean);
    procedure ExpandItemWidth(Sender: TObject; ACanvas: TCanvas; var Width,Height: Integer);
    Procedure DrawGlpyh(Item : TMenuItem; Canvas : TCanvas; Arect : TRect; Idx : Integer);
    Procedure DrawCaption(Item : TMenuItem; Canvas : TCanvas; Arect : TRect);
    Procedure DrawChecked(Item : TMenuItem; ACanvas : TCanvas; ARect : TRect);
    Procedure DrawTick(ACanvas : TCanvas; CheckedRect : TRect; Selected : Boolean);
    Procedure DrawXPItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    Procedure DrawStandardItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    Procedure MakeSubCustomDraw(SubMenu : TMenuItem);
Public
    procedure ForceXPStyle;
    procedure WndProc(var Message: TMessage); virtual;
    procedure Notification(AComponent: TComponent;Operation: TOperation); override;
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;
Published
    Property BarColors:tfBarColors read FColors write fColors;
    Property XP_Border: Boolean read FBorder write FBorder default True;
End;

procedure Register;

implementation

{*****************************************************************************}
{*  Initialisation and Hooking Routines
{*****************************************************************************}

constructor ttfXPMainMenu.create(AOwner : TComponent);
Begin
  inherited create(AOwner);
  FakeImageList:=TImageList.create(self);
  With FakeImageList Do                   // Image.Width is used to set the draw
  Begin                                   // Coordinates, so if no image list
   Width:=16;                             // is present then we need a fake one
   Height:=16;
  End;
  Images:=FakeImageList;
  FColors:=tfBarColors.create;
  OwnerDraw := True;
  FBorder:=False;
  XP_Border:=True;
  OwnerDraw:=True;
  {-------- Comment the following block if your IDE keeps on crashing -----}
  if Owner is TCustomForm then
  begin
    FOriginalWndProc := TCustomForm(Owner).WindowProc;  // Save the Window Handler
    TCustomForm(Owner).WindowProc := WndProc;          // Hook in the new one ..
  end else
  raise EInvalidOperation.Create('Owner must be a form');
  {--------- END BLOCK -------}
  ForceXPStyle;
End;

destructor ttfXPMainMenu.Destroy;
Begin
   inherited Destroy;
End;

procedure ttfXPMainMenu.Notification(AComponent: TComponent;Operation: TOperation);
Begin
//     If (AComponent=Images) and (Operation=OpRemove) Then
//        Images:=FakeImageList;   // Ensure Fakelist is used ..

     Inherited Notification(AComponent,Operation);
End;


procedure ttfXPMainMenu.WndProc(var Message: TMessage);
begin
  Try
  FOriginalWndProc(Message);    // Make sure we process all other messages ..
  case Message.Msg of
        WM_INITMENUPOPUP,WM_ENTERMENULOOP: Begin  // when Menu is called
                              ForceXPStyle;       // Ensure XP draw style
                           End;
    End;
    except
    Application.HandleException(self);
  end;
End;

Procedure ttfXPMainMenu.MakeSubCustomDraw(SubMenu : TMenuItem);
var i: Integer;
begin
  if (SubMenu.Count > 0) then      // Set all MenuItems and Iterate for SubMenus
    for i := 0 to SubMenu.Count-1 do
    begin
      SubMenu.Items[i].OnMeasureItem := ExpandItemWidth;
      SubMenu.Items[i].OnDrawItem := DrawItem;
      If SubMenu.Items[i].Count>0 Then MakeSubCustomDraw(SubMenu.Items[i]);
    end;
End;

procedure ttfXPMainMenu.ForceXPStyle;
var count : Integer;
Begin
If  Items.Count>0 Then              // We only make Sub items custom drawn
 For Count:=0 To Items.Count-1 Do   // Else it screws up the menu bar ..
   If Items[Count].Count>0 Then MakeSubCustomDraw(Items[Count]);

End;



{*****************************************************************************}
{*  Drawing and Measuring Functions ..
{*****************************************************************************}

procedure ttfXPMainMenu.ExpandItemWidth(Sender: TObject;
  ACanvas: TCanvas; var Width, Height: Integer);
var
  MenuItem: TMenuItem;
begin
 MenuItem := TMenuItem(Sender);
  Width := Width;
    if Trim(ShortCutToText(MenuItem.ShortCut)) <> '' then
       Width:=Width+(ACanvas.TextWidth(Trim(ShortCutToText(MenuItem.ShortCut))) div 2)-10;
  if MenuItem.Visible then
  Begin
  If (Sender as TMenuItem).Caption='-' then Height:=3   // Set height for Divider
  else If XP_Border Then height:=height+8;
  End;
End;


Procedure ttfXPMainMenu.DrawGlpyh(Item : TMenuItem; Canvas : TCanvas; Arect : TRect; Idx : Integer);
Begin
   If (Item.Parent.SubMenuImages<>nil) Then
     Item.Parent.SubMenuImages.Draw(canvas,ARect.Left+4,
                         ((Arect.Bottom+Arect.Top)-Images.Height) Div 2,Idx,True)
  Else
   Images.Draw(canvas,ARect.Left+4,
               ((Arect.Bottom+Arect.Top)-Images.Height) Div 2,Idx,True);
End;


Procedure ttfXPMainMenu.DrawCaption(Item : TMenuItem; Canvas : TCanvas; Arect : TRect);
Var TextLeft   : Integer;
    Caption    : String;
    OldColor   : TColor;
    AccelIdx   : Integer;  // Accelerator index,  so we know were to draw the _
Begin
SetBKMode( canvas.Handle, TRANSPARENT );
If Assigned(Images) Then TextLeft:=Images.Width+12+Arect.Left
                    Else TextLeft:=Arect.Left+6;
If Item.Caption='-' then                 // Draw the divider bar and exit ..
Begin
   Canvas.Pen.Color:=$00ADAEAD;
   Canvas.MoveTo(TextLeft+4,Arect.Top+1);
   Canvas.LineTo(Arect.Right,Arect.Top+1);
   Exit;
End;
 OldColor:=Canvas.Font.Color;
 If Not Item.Enabled Then Canvas.Font.Color:=clGray;
 Caption:=RemoveChar(Item.Caption,'&',AccelIdx);  //  Remove controls chars from caption
 canvas.TextOut(TextLeft+4,
                   ((Arect.Bottom+Arect.Top)-
                   canvas.TextHeight('H')) Div 2,Caption);
 if Trim(ShortCutToText(Item.ShortCut)) <> '' then          // show Shortcut keys ..
 Begin
   TextLeft:=(ARect.Right-Arect.Left)-
         Canvas.TextWidth(Trim(ShortCutToText(Item.ShortCut))+'X')-4;
   canvas.TextOut(TextLeft,
                   ((Arect.Bottom+Arect.Top)-
                   canvas.TextHeight('H')) Div 2,Trim(ShortCutToText(Item.ShortCut)));
   Canvas.Font.Color:=OldColor;
 End;
End;

// Tick routine taken from XPMenu by Khaled Shagrouni .. http://www.shagrouni.com
Procedure ttfXPMainMenu.DrawTick(ACanvas : TCanvas; CheckedRect : TRect; Selected : Boolean);
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




Procedure ttfXPMainMenu.DrawChecked(Item : TMenuItem; ACanvas : TCanvas; ARect : TRect);
Begin
  ACanvas.Brush.Color:=FColors.CheckBoxBackground;
  With Arect Do
  Begin
    ACanvas.FillRect(Rect(Left+2,Top+4,Left+22,Bottom-4));
    If (Item.ImageIndex=-1) OR ((Images=FakeImageList) AND (Item.Parent.SubMenuImages=nil))
    Then DrawTick(ACanvas,Rect(Left+2,Top+4,Left+20,Bottom-4),true);
  End;
End;

Procedure ttfXPMainMenu.DrawXPItem(Sender: TObject; ACanvas: TCanvas;
                                    ARect: TRect; Selected: Boolean);
Var Item       : TMenuItem;
    InnerRect  : TRect;
    TempCanvas : TBitmap;
Begin
 TempCanvas := TBitmap.Create;    // Create a intermediary canvas
 Item:=(Sender As TMenuItem);
 With TempCanvas Do
 Begin
  // give it the same dimensions as menu Item
 width:=ARect.Right;   height:=ARect.Bottom;
 Canvas.font:=ACanvas.Font;
 Transparent:=true;
 ARect.Right:=ARect.Right+6;
 InnerRect:=ARect;
 dec(InnerRect.right,7);  // Rect inside XP border
 Inc(InnerRect.top,2);  dec(InnerRect.bottom,2);
 Case Selected Of
    True : Begin
             canvas.Brush.Color:=FColors.BackgroundColor;
             canvas.FillRect (ARect);
             canvas.Brush.Color:=FColors.IconBackground;
             Canvas.FillRect(Rect(ARect.Left,ARect.Top,ARect.Left+Images.Width+8,ARect.Bottom));
             canvas.Font.Color:=FColors.FontHiLightColor;
             canvas.Brush.Color:=FColors.ItemGradientEnd;
             canvas.FillRect (InnerRect);
           End;
    False: Begin
            Canvas.font.Color:=FColors.FontNormalColor;
            canvas.Brush.Color:=FColors.BackgroundColor;
            canvas.FillRect (ARect);
            canvas.Brush.Color:=FColors.IconBackground;
            Canvas.FillRect(Rect(ARect.Left,ARect.Top,ARect.Left+24,ARect.Bottom));
           End;
    End;
   If Item.Checked Then DrawChecked(item,Canvas,ARect);
   If Assigned(Images) Then DrawGlpyh(TMenuItem(Sender),Canvas,ARect,Item.ImageIndex);
   DrawCaption(Item,canvas,Arect);
   ACanvas.CopyRect(ARect,canvas,ARect);
 End;
 If (XP_Border) and (selected) then    // Only Draw XP border on main canvas..
 Begin
    ACanvas.Brush.Color:=FColors.XPBorderColor;
    ACanvas.FrameRect(InnerRect);
 End;
 ACanvas.Refresh;                      // Force an Update
 TempCanvas.Free;

End;


//  Only called when XP Border is turned off, this Draw routine
//  lets the Hilight Bar have a gradient
Procedure ttfXPMainMenu.DrawStandardItem(Sender: TObject; ACanvas: TCanvas;
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
 ARect.Right:=ARect.Right+6;
 Case Selected Of
    True : Begin
             tmp.canvas.Font.Color:=FColors.FontHilightColor;
             TmpRect:=ARect;
            if (Assigned(Images)) And (Images.Width>24) Then Inc(TmpRect.Left,20);
             HorizGradient(tmp.Canvas,TmpRect,
                           FColors.ItemGradientStart,FColors.ItemGradientEnd);
           End;
    False: Begin
             tmp.Canvas.font.Color:=FColors.FontNormalColor;
             tmp.canvas.Brush.Color:=FColors.BackgroundColor;
             tmp.canvas.FillRect (ARect);
            End;
     End;
   If Item.Checked Then DrawChecked(item,Canvas,ARect);
  If Assigned(Images) Then DrawGlpyh(TMenuItem(Sender),Canvas,ARect,Item.ImageIndex);
  DrawCaption(Item,canvas,Arect);
  ACanvas.CopyRect(ARect,canvas,ARect);
 End;
 ACanvas.Refresh;
 tmp.Free;
End;


Procedure ttfXPMainMenu.DrawItem(Sender: TObject; ACanvas: TCanvas;
                                    ARect: TRect; Selected: Boolean);
Begin
 If XP_Border Then
   DrawXPItem(Sender,ACanvas,Arect,Selected)
 Else
   DrawStandardItem(Sender,ACanvas,Arect,Selected)
End;


procedure Register;
begin
  RegisterComponents('Transpear XP', [ttfXPMainMenu]);
end;

end.
