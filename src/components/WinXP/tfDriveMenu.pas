unit tfDriveMenu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   Menus, StdCtrls, ShellAPI, ExtCtrls, ImgList, XP_PopUpMenu,XP_Utils;

Type TDriveMenuItem = Class(TMenuItem)   // extend the standard to hold some info
Private
Protected
  DType   : uInt;        // just some basic drive information ..
  DName   : String;
  DLetter : String;
  DNum    : Integer;
  DSize   : Int64;
Public
End;

Type TtfXPDriveMenu = Class(TPopUpMenu)
Private
    LP : TPopUpList;
    FVTitle : XPMenuTitle;
    FBorder : Boolean;
    FColors : tfBarColors;
    PopupHeight: Integer;
    Drawn: Boolean;
    StoreHeight : Integer;
    ExtraWidth : Integer;     // ONLY USE if you want wider menus ..
    FAllowExclusion : Boolean;
    Icons : TImageList;
    FLargeMenus : Boolean;
    procedure SetItemSize(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);     // Used for OnMeasure of MenuItems ..
    Procedure ItemClick(Sender : TObject);
    Procedure ReadDrives;
    procedure AdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
    Procedure DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    Procedure DrawGlpyh(Item : TMenuItem; Canvas : TCanvas; Arect : TRect; Idx : Integer);
    Procedure DrawCaption(Item : TMenuItem; Canvas : TCanvas; Arect : TRect);
    Procedure DrawXPItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    Procedure DrawStandardItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
Public
    ExcludeRect : TRect;
    SColor, EColor : TColor;
    Procedure PopUp(X,Y : Integer); Override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
Published
    Property LargeMenus:Boolean read FLargeMenus Write FLargeMenus default true;
    Property BarColors:tfBarColors read FColors write fColors;
    Property ExtraWidthIfNeeded : Integer read ExtraWidth write ExtraWidth default 0;
    Property XP_Border: Boolean read FBorder write FBorder default True;
    Property MenuTitle:XPMenuTitle read FVTitle write FVTitle;
    Property ExclusionZone:Boolean Read FAllowExclusion Write FAllowExclusion default false;
    Property ExclusionArea:TRect read ExcludeRect Write ExcludeRect;
End;


Type ttfDriveMenu = Class (TComponent)   // so that the drive menu cannot be
private                                  // interfered with we hide the menu
   StartColor : TColor;                  // and allow access to only the
   EndColor   : TColor;                  // needed properties ..
   DMenu : TtfXPDriveMenu;
Public
    Procedure PopUp(X,Y : Integer);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
Published
    Property GradStart:TColor Read StartColor Write StartColor default clHighlight;
    Property GradEnd:TColor Read EndColor Write EndColor default clHighlight;
End;

procedure Register;

implementation


procedure getinfo(fn:tfilename;var i:tshfileinfo);
begin
     shgetfileinfo(pchar(fn),0,i,
     sizeof(tshfileinfo),
     SHGFI_SYSICONINDEX or SHGFI_ICON or shgfi_displayname or shgfi_typename or shgfi_smallicon)
end;


//------------------------------------------------------------------------------
// ttfDriveMenu Class methods ....

constructor ttfDriveMenu.Create(AOwner: TComponent);
Begin
  Inherited create(AOwner);
  DMenu:=TtfXPDriveMenu.create(self);
  StartColor:=clHighlight;         // Initialise Default Attributes ...
  EndColor:=clHighlight
End;


destructor ttfDriveMenu.Destroy;
Begin
  DMenu.free;
  inherited destroy;
End;

Procedure ttfDriveMenu.PopUp(x,y : Integer);
Begin
  DMenu.SColor:=StartColor;                   // Set Colors for Gradient Bar
  DMenu.EColor:=EndColor;
  DMenu.PopUp(X,Y);
End;


//------------------------------------------------------------------------------
// Drive Menu Class methods ....


Constructor TtfXPDriveMenu.Create(AOwner : TComponent);
Begin
  Inherited Create(AOwner);
  if csDesigning in ComponentState then Exit;
  FLargeMenus:=True;
  LP:=TPopUpList.create;
  LP.Add(Self);
  StoreHeight:=0;           // used as a protective storage
  FAllowExclusion:=false;
  FColors:=tfBarColors.create;
  FVTitle:=XPMenuTitle.create;
//  OwnerDraw := True;
//  FBorder:=False;
  XP_Border:=True;
  ExtraWidth:=0;
  Icons:=TImageList.create(self);
  Icons.DrawingStyle:=dsTransparent;
  Images:=Icons;
  Ownerdraw:=True;
//  ReadDrives;
End;


procedure TtfXPDriveMenu.Popup(X, Y: Integer);
var c: integer;
  pm : TTPMParams;
  Store : TpopUpList;
begin
  ReadDrives;
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
 If Items.Count>0 Then
  for c:=0 To Items.Count-1  Do
  Begin
    Items[C].OnAdvancedDrawItem:=AdvancedDrawItem;
    Items[C].OnMeasureItem:=SetItemSize;
    Items[c].OnClick:=ItemClick;
  End;
   TrackPopupMenuEx(self.Handle,TPM_VERTICAL or TPM_HORIZONTAL,X,Y,PopUpList.Window,@pm);
   if StoreHeight=0 then StoreHeight:=PopUpHeight;
   PopUpList:=Store;     // Restore the Default ..
end;


Destructor TtfXPDriveMenu.Destroy;
Begin
 Try
  FVTitle.free;
  FColors.free;
  LP.Remove(self);
  LP.Free;
//  Icons.Handle:=nil;
  icons.free;
  Inherited Destroy;
 Finally
 end;
End;

Procedure TtfXPDriveMenu.ReadDrives;
var
 Count     : Integer;
 SysIL     : uint;
 SFI       : TSHFileInfo;
 drives    : set of 0..25;
 ct        : byte;
 info      : tshfileinfo;
 drv       : string;
 DriveItem : TDriveMenuItem;
begin
if Items.count>0 then
for count:=Items.Count-1 DownTo 0 do    // Iterate
  (Items[Count] as TDriveMenuItem).free;
integer(drives):=getlogicaldrives;
 if LargeMenus then
 Begin
  SysIL := SHGetFileInfo('', 0, SFI, SizeOf(SFI), SHGFI_SYSICONINDEX or SHGFI_LargeIcon);
  Icons.Width:=32; Icons.Height:=32;
 End
 Else
 Begin
  SysIL := SHGetFileInfo('', 0, SFI, SizeOf(SFI), SHGFI_SYSICONINDEX or SHGFI_SmallIcon);
  Icons.Width:=16; Icons.Height:=16;
 End;

   if SysIL <> 0 then
  begin
    Icons.Handle := SysIL;
    Icons.ShareImages := TRUE;  // DON'T FREE THE SYSTEM IMAGE LIST!!!!!  BAD IDEA (tm)!
  end;
  for ct := 0 to 25 do
    If ct in drives then
    Begin
     drv:=char(ct+ord('A'))+':\'; // Make a drive' root path from ct
     getinfo (drv,info); // get shell information about this drive
     DriveItem:=TDriveMenuItem.create(self);
     DriveItem.ImageIndex:=Info.iIcon;
     DriveItem.DName:=Info.szDisplayName;
     DriveItem.DLetter:=drv;
     DriveItem.DNum:=ct+1;
     If GetDriveType(pchar(Drv))<>DRIVE_REMOVABLE Then
                              DriveItem.DSize:=DiskFree(DriveItem.DNum);
     If DriveItem.DSize=-1 Then DriveItem.DSize:=0;
     Items.Add(DriveItem);
    End;
End;





Procedure TtfXPDriveMenu.ItemClick(Sender : TObject);
Begin
  shellexecute(application.Handle,'open',
               PChar((Sender as TDriveMenuItem).DLetter), nil,nil,sw_show);
End;

procedure TtfXPDriveMenu.SetItemSize(Sender: TObject; ACanvas: TCanvas; var Width,
          Height: Integer);
var    Item  : TDriveMenuItem;
Begin
  Item:=(Sender As TDriveMenuItem);
  Width := ACanvas.TextWidth(item.DName) + FVTitle.TitleBarWidth+40; { make space for graphical bar }
  If XP_Border Then height:=height+6;
  PopupHeight := PopupHeight + Height;
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


procedure TtfXPDriveMenu.AdvancedDrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
var
  x, y: Integer;
  r: TRect;
  MenuItem: TMenuItem;
begin
  MenuItem := TMenuItem(Sender);
  r := ARect;
  r.Right := r.Right - FVTitle.TitleBarWidth; { remove bar width }
  OffsetRect(r, FVTitle.TitleBarWidth, 0);
  DrawItem(MenuItem, ACanvas, r, ODSelected in State);
  If StoreHeight<>0 Then PopUpHeight:=StoreHeight;    // ensure the Protected height is always used if needed ..
  if not Drawn then
  begin
    ACanvas.Brush.Style := bsSolid;
    if (FVTitle.GradientStart = FVTitle.GradientEnd) then { same color, just one fillrect required }
      begin
        ACanvas.Brush.Color := FVTitle.GradientStart;
        ACanvas.FillRect(Rect(0, ARect.Top, FVTitle.TitleBarWidth - BarSpace, ARect.Bottom{ + 1}));
      end
    else { draw smooth gradient bar part for this item }
    begin
     VertGradient(ACanvas,Rect(0,0,FVtitle.TitleBarWidth-BarSpace,PopUpHeight),FVTitle.GradientStart,FVTitle.GradientEnd);
    end;
    r := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom + 1);
    y := PopupHeight + FVTitle.VerticalTextOffsetY;
    ACanvas.Font:=fvTitle.VerticalFont;
    x := Round((FVTitle.TitleBarWidth - ACanvas.TextHeight('X')) / 2 - 0.5);
    if Assigned(FVTitle.Bitmap) and (FVTitle.BitmapVertAlignment = bvaBottom)
                                              then y := y - FVTitle.Bitmap.Height;
    DrawTitleBar(X-1, Y, FVTitle.VerticalText,FVTitle.VerticalFont,ACanvas);
//    if PopupHeight = ARect.Bottom then
      begin
        Drawn := True;         { draw bitmap }
        if Assigned(FVTitle.Bitmap) then
        begin
          y := 0; x := 0;
          case FVTitle.BitmapVertAlignment of
            bvaTop:    y := FVTitle.BitmapOffsetY;
            bvaBottom: y := PopupHeight + FVTitle.BitmapOffsetY - FVtitle.Bitmap.Height;
            bvaMiddle: y := ((PopupHeight - FVTitle.bitmap.Height) div 2) + FVTitle.BitmapOffsetY;
          end;
          case FVTitle.BitmapHorzAlignment of
            bhaLeft:   x := FVTitle.BitmapOffsetX;
            bhaRight:  x := (FVTitle.TitleBarWidth - BarSpace) + FVTitle.BitmapOffsetX - FVTitle.Bitmap.Width;
            bhaCenter: x := ((FVTitle.TitleBarWidth - BarSpace - FVTitle.Bitmap.Width) div 2) + FVTitle.BitmapOffsetX;
          end;
          ACanvas.Draw(x, y, FVTitle.Bitmap);
        end;
      end;
  end;
end;


Procedure TtfXPDriveMenu.DrawGlpyh(Item : TMenuItem; Canvas : TCanvas; Arect : TRect; Idx : Integer);
Begin
 SetBKMode( Canvas.Handle, TRANSPARENT );
 Icons.Draw(Canvas,ARect.Left+4,
               ((Arect.Bottom+Arect.Top)-Icons.Height) Div 2,Item.ImageIndex,True);
End;


Procedure TtfXPDriveMenu.DrawCaption(Item : TMenuItem; Canvas : TCanvas; Arect : TRect);
Var TextLeft   : Integer;
Begin
SetBKMode( canvas.Handle, TRANSPARENT );
TextLeft:=Icons.Width+12+Arect.Left;
 Canvas.TextOut(TextLeft, Arect.Top+6,TDriveMenuItem(item).DName);
 if LargeMenus then
   
  Canvas.TextOut(TextLeft, ARect.Top+6+Canvas.TextHeight('H'),
                             IntToStr(TDriveMenuItem(item).DSize div 1048576)+'MB');
End;


Procedure TtfXPDriveMenu.DrawXPItem(Sender: TObject; ACanvas: TCanvas;
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
            Canvas.FillRect(Rect(ARect.Left,ARect.Top,ARect.Left+Icons.Width+8,ARect.Bottom));
            canvas.Font.Color:=FColors.FontHilightColor;
            canvas.Brush.Color:=FColors.ItemGradientStart;
            canvas.FillRect (InnerRect);
           End;
    False: Begin
            Canvas.font.Color:=FColors.FontNormalColor;
            canvas.Brush.Color:=FColors.BackgroundColor;
            canvas.FillRect (InnerRect);
            canvas.Brush.Color:=FColors.IconBackground;
            Canvas.FillRect(Rect(ARect.Left,ARect.Top,ARect.Left+Icons.Width+8,ARect.Bottom));
           End;
    End;
   If Assigned(Images) Then DrawGlpyh(Item,Canvas,ARect,Item.ImageIndex);
   DrawCaption(Item,canvas,Arect);
   ACanvas.CopyRect(ARect,canvas,ARect);
 End;
 If (XP_Border) and (selected) then    // Only Draw XP border on main canvas..
    Frame3d(ACanvas,InnerRect,FColors.XPBorderColor,FColors.XPBorderColor,1);
 ACanvas.Refresh;                      // Force an Update
 TempCanvas.Free;
End;

Procedure TtfXPDriveMenu.DrawStandardItem(Sender: TObject; ACanvas: TCanvas;
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
             tmp.canvas.Font.Color:=FColors.FontHilightColor;
             TmpRect:=ARect;
             If FColors.ItemGradientStart=FColors.ItemGradientEnd Then
             Begin
               tmp.Canvas.Brush.Color:=FColors.ItemGradientStart;
               tmp.canvas.FillRect (ARect);
             End
             Else HorizGradient(tmp.Canvas,TmpRect,
                        FColors.ItemGradientStart,FColors.ItemGradientEnd);
           End;
    False: Begin
             tmp.Canvas.font.Color:=FColors.FontNormalColor;
             tmp.canvas.Brush.Color:=FColors.BackgroundColor;
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


Procedure TtfXPDriveMenu.DrawItem(Sender: TObject; ACanvas: TCanvas;
                                    ARect: TRect; Selected: Boolean);
Begin
 If XP_Border Then
   DrawXPItem(Sender,ACanvas,Arect,Selected)
 Else
   DrawStandardItem(Sender,ACanvas,Arect,Selected)
End;


//------------------------------------------------------------------------------
// Initialization and Registration Code ...

procedure Register;
begin
  RegisterComponents('Transpear XP', [ttfDriveMenu]);
RegisterComponents('Transpear XP', [TtfXPDriveMenu]);
end;

initialization
  RegisterClass(TDriveMenuItem);   // this must be registered else the class
end.                               // cannot be found when compiling

