{
XPMenu for Delphi
Author: Khaled Shagrouni
URL: http://www.shagrouni.com
e-mail: shagrouni@hotmail.com
Version 1.5 (BETA), 25 July, 2001


XPMenu is a Delphi component to mimic Office XP menu and toolbar style.
Copyright (C) 2001 Khaled Shagrouni.

This component is FREEWARE with source code. I still hold the copyright.
If you make any modifications to the code, please send them to me.
If you have any ideas for improvement or bug reports, don't hesitate to e-mail me.



History:
========

July 25, 2001
   - Support for TToolbar.
   - Getting closer to XP style appearance.
   - New options.
june 23, 2001
   - Compatibility issues with Delphi4.
   - Changing the way of menus itration.
   - Making the blue select rectangle little thinner.

june 21, 2001
  Bug fixes:
   - Items correctly sized even if no image list assigned.
   - Shaded colors for top menu items if fixed for some menu bar colors.
  (Actually the bugs was due to two statements deleted by me stupidly/accidentally)

June 19, 2001
  This component is based on code which I have posted at Delphi3000.com
  (http://www.delphi3000/articles/article_2246.asp) and Borland Code-Central
  (http://codecentral.borland.com/codecentral/ccweb.exe/listing?id=16120).


}
//____________________________________________________________________________


{$IFDEF VER130}
{$DEFINE VER5U}
{$ENDIF}

{$IFDEF VER140}
{$DEFINE VER5U}
{$ENDIF}


unit XPMenu;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, ComCtrls,  Forms,
  Menus, Messages, Commctrl;

type
  TXPMenu = class(TComponent)
  private
    FActive: boolean;
    FForm: TForm;
    FFont: TFont;
    FColor: TColor;
    FIconBackColor: TColor;
    FMenuBarColor: TColor;
    FCheckedColor: TColor;
    FSeparatorColor: TColor;
    FSelectBorderColor: TColor;
    FSelectColor: TColor;
    FDisabledColor: TColor;
    FSelectFontColor: TColor;
    FIconWidth: integer;
    FDrawSelect: boolean;
    FUseSystemColors: boolean;

    FFColor, FFIconBackColor, FFSelectColor, FFSelectBorderColor,
    FFSelectFontColor, FCheckedAreaColor, FCheckedAreaSelectColor,
    FFCheckedColor, FFMenuBarColor, FFDisabledColor, FFSeparatorColor,
    FMenuBorderColor, FMenuShadowColor: TColor;

    Is16Bit: boolean;
    FOverrideOwnerDraw: boolean;
    {FRefreshOnChange: boolean;}
    FGradient: boolean;
    ImgLstHandle: HWND;
    ImgLstIndex: integer;
    FFlatMenu: boolean;

    procedure SetActive(const Value: boolean);
    procedure SetForm(const Value: TForm);
    procedure SetFont(const Value: TFont);
    procedure SetColor(const Value: TColor);
    procedure SetIconBackColor(const Value: TColor);
    procedure SetMenuBarColor(const Value: TColor);
    procedure SetCheckedColor(const Value: TColor);
    procedure SetDisabledColor(const Value: TColor);
    procedure SetSelectColor(const Value: TColor);
    procedure SetSelectBorderColor(const Value: TColor);
    procedure SetSeparatorColor(const Value: TColor);
    procedure SetSelectFontColor(const Value: TColor);
    procedure SetIconWidth(const Value: integer);
    procedure SetDrawSelect(const Value: boolean);
    procedure SetUseSystemColors(const Value: boolean);
    procedure SetOverrideOwnerDraw(const Value: boolean);
    {procedure SetRefreshOnChange(const Value: boolean);}
    procedure SetGradient(const Value: boolean);
    procedure SetFlatMenu(const Value: boolean);


  protected
    procedure InitMenueItems(Enable: boolean);
    procedure DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      Selected: Boolean);
    procedure MenueDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      Selected: Boolean);
    procedure ActivateMenuItem(MenuItem: TMenuItem);
    procedure SetGlobalColor(ACanvas: TCanvas);
    procedure DrawTopMenuItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      IsRightToLeft: boolean);
    procedure DrawCheckedItem(FMenuItem: TMenuItem; Selected,
     HasImgLstBitmap: boolean; ACanvas: TCanvas; CheckedRect: TRect);
    procedure DrawTheText(txt, ShortCuttext: string; ACanvas: TCanvas;
     TextRect: TRect; Selected, Enabled, Default, TopMenu,
     IsRightToLeft: boolean; TextFormat: integer);
    procedure DrawIcon(Sender: TObject; ACanvas: TCanvas; B: TBitmap;
     IconRect: Trect; Hot, Selected, Enabled, Checked, FTopMenu,
     IsRightToLeft: boolean);
    procedure DrawArrow(ACanvas: TCanvas; X, Y: integer);
    procedure MeasureItem(Sender: TObject; ACanvas: TCanvas;
      var Width, Height: Integer);

    {procedure MenuChange(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);}
    function GetImageExtent(MenuItem: TMenuItem): TPoint;
    procedure ToolBarDrawButton(Sender: TToolBar;
      Button: TToolButton; State: TCustomDrawState; var DefaultDraw: Boolean);

    function TopMenuFontColor(ACanvas: TCanvas; Color: TColor): TColor;
    procedure DrawGradient(ACanvas: TCanvas; ARect: TRect;
     IsRightToLeft: boolean);

    procedure DrawWindowBorder(hWnd: HWND; IsRightToLeft: boolean);
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;


  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Form: TForm read FForm write SetForm;
  published
    property Font: TFont read FFont write SetFont;
    property Color: TColor read FColor write SetColor;
    property IconBackColor: TColor read FIconBackColor write SetIconBackColor;
    property MenuBarColor: TColor read FMenuBarColor write SetMenuBarColor;
    property SelectColor: TColor read FSelectColor write SetSelectColor;
    property SelectBorderColor: TColor read FSelectBorderColor
     write SetSelectBorderColor;
    property SelectFontColor: TColor read FSelectFontColor
     write SetSelectFontColor;
    property DisabledColor: TColor read FDisabledColor write SetDisabledColor;
    property SeparatorColor: TColor read FSeparatorColor
     write SetSeparatorColor;
    property CheckedColor: TColor read FCheckedColor write SetCheckedColor;
    property IconWidth: integer read FIconWidth write SetIconWidth;
    property DrawSelect: boolean read FDrawSelect write SetDrawSelect;
    property UseSystemColors: boolean read FUseSystemColors
     write SetUseSystemColors;
    property OverrideOwnerDraw: boolean read FOverrideOwnerDraw
     write SetOverrideOwnerDraw;
    {property RefreshOnChange: boolean read FRefreshOnChange
      write SetRefreshOnChange}
    property Gradient: boolean read FGradient write SetGradient;
    property FlatMenu: boolean read FFlatMenu write SetFlatMenu;
    property Active: boolean read FActive write SetActive;
  end;

function GetShadeColor(ACanvas: TCanvas; clr: TColor; Value: integer): TColor;
function NewColor(ACanvas: TCanvas; clr: TColor; Value: integer): TColor;
procedure DimBitmap(ABitmap: TBitmap; Value: integer);
function GrayColor(ACanvas: TCanvas; clr: TColor; Value: integer): TColor;
procedure GrayBitmap(ABitmap: TBitmap; Value: integer);
procedure DrawBitmapShadow(B: TBitmap; ACanvas: TCanvas; X, Y: integer;
  ShadowColor: TColor);



procedure GetSystemMenuFont(Font: TFont);
procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('Transpear XP', [TXPMenu]);
end;

{ TXPMenue }

constructor TXPMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFont := TFont.Create;
  GetSystemMenuFont(FFont);
  FForm := TForm(Owner);

  FUseSystemColors := true;


  FColor := clBtnFace;
  FIconBackColor := clBtnFace;
  FSelectColor := clHighlight;
  FSelectBorderColor := clHighlight;
  FMenuBarColor := clBtnFace;
  FDisabledColor := clInactiveCaption;
  FSeparatorColor := clBtnFace;
  FCheckedColor := clHighlight;
  FSelectFontColor := FFont.Color;

  FIconWidth := 24;
  FDrawSelect := true;

  if FActive then
  begin
    InitMenueItems(true);
  end;

end;

destructor TXPMenu.Destroy;
begin
  InitMenueItems(false);
  FFont.Free;

  inherited;
end;



procedure TXPMenu.ActivateMenuItem(MenuItem: TMenuItem);

  procedure Activate(MenuItem: TMenuItem);
  begin
    if addr(MenuItem.OnDrawItem) <> addr(TXPMenu.DrawItem) then
    begin
      if (not assigned(MenuItem.OnDrawItem)) or (FOverrideOwnerDraw) then
        MenuItem.OnDrawItem := DrawItem;
      if (not assigned(MenuItem.OnMeasureItem)) or (FOverrideOwnerDraw) then
        MenuItem.OnMeasureItem := MeasureItem;
    end
  end;

var
  i, j: integer;

begin
  Activate(MenuItem);
  for i := 0 to MenuItem.Parent.Count -1 do
  begin
    Activate(MenuItem.Parent.Items[i]);
    for j := 0 to MenuItem.Parent.Items[i].Count - 1 do
      ActivateMenuItem(MenuItem.Parent.Items[i].Items[j]);
  end;
end;

procedure TXPMenu.InitMenueItems(Enable: boolean);

  procedure Activate(MenuItem: TMenuItem);
  begin
    if Enable then
    begin
      if (not assigned(MenuItem.OnDrawItem)) or (FOverrideOwnerDraw) then
        MenuItem.OnDrawItem := DrawItem;
      if (not assigned(MenuItem.OnMeasureItem)) or (FOverrideOwnerDraw) then
        MenuItem.OnMeasureItem := MeasureItem;
    end
    else
    begin
      if addr(MenuItem.OnDrawItem) = addr(TXPMenu.DrawItem) then
        MenuItem.OnDrawItem := nil;
      if addr(MenuItem.OnMeasureItem) = addr(TXPMenu.MeasureItem) then
        MenuItem.OnMeasureItem := nil;
    end;
  end;

  procedure ItrateMenu(MenuItem: TMenuItem);
  var
    i: integer;
  begin
    Activate(MenuItem);
    for i := 0 to MenuItem.Count - 1 do
      ItrateMenu(MenuItem.Items[i]);
  end;


var
  i, x: integer;
begin
  for i := 0 to FForm.ComponentCount - 1 do
  begin
    if FForm.Components[i] is TMainMenu then
    begin
      for x := 0 to TMainMenu(FForm.Components[i]).Items.Count - 1 do
      begin
        TMainMenu(FForm.Components[i]).OwnerDraw := Enable;//Thanks Yann.
        Activate(TMainMenu(FForm.Components[i]).Items[x]);
        ItrateMenu(TMainMenu(FForm.Components[i]).Items[x]);
      end;
     {
      if Enable then
      begin
        if (not assigned(TMainMenu(FForm.Components[i]).OnChange))
          and (FRefreshOnChange) then
          TMainMenu(FForm.Components[i]).OnChange := MenuChange;
      end
      else
        if addr(TMainMenu(FForm.Components[i]).OnChange) =
          addr(TXPMenu.MenuChange) then
          TMainMenu(FForm.Components[i]).OnChange := nil;
     }
    end;
    if FForm.Components[i] is TPopupMenu then
    begin
      for x := 0 to TPopupMenu(FForm.Components[i]).Items.Count - 1 do
      begin
        TPopupMenu(FForm.Components[i]).OwnerDraw := Enable;
        Activate(TMainMenu(FForm.Components[i]).Items[x]);
        ItrateMenu(TMainMenu(FForm.Components[i]).Items[x]);
      end;
      {
      if Enable then
      begin
        if (not assigned(TPopupMenu(FForm.Components[i]).OnChange))
          and (FRefreshOnChange) then
          TPopupMenu(FForm.Components[i]).OnChange := MenuChange;
      end
      else
        if addr(TPopupMenu(FForm.Components[i]).OnChange) =
         addr(TXPMenu.MenuChange) then
          TPopupMenu(FForm.Components[i]).OnChange := nil;
      }
    end;

    if FForm.Components[i] is TToolBar then
      if not (csDesigning in ComponentState) then
      begin
        if not TToolBar(FForm.Components[i]).Flat then
          TToolBar(FForm.Components[i]).Flat := true;

        if Enable then
        begin
          for x := 0 to TToolBar(FForm.Components[i]).ButtonCount - 1 do
            if (not assigned(TToolBar(FForm.Components[i]).OnCustomDrawButton))
              or (FOverrideOwnerDraw) then
            begin
              TToolBar(FForm.Components[i]).OnCustomDrawButton :=
                ToolBarDrawButton;

            end;
        end
        else
        begin
          if addr(TToolBar(FForm.Components[i]).OnCustomDrawButton) =
            addr(TXPMenu.ToolBarDrawButton) then
            TToolBar(FForm.Components[i]).OnCustomDrawButton := nil;

        end;
      end;
  end;
end;

procedure TXPMenu.DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
  Selected: Boolean);
begin
  if FActive then
    MenueDrawItem(Sender, ACanvas, ARect, Selected);
end;



function TXPMenu.GetImageExtent(MenuItem: TMenuItem): TPoint;
var
  HasImgLstBitmap: boolean;
  B: TBitmap;
  FTopMenu: boolean;
begin
  FTopMenu := false;
  B := TBitmap.Create;
  B.Width := 0;
  B.Height := 0;
  Result.x := 0;
  Result.Y := 0;
  HasImgLstBitmap := false;

  if FForm.Menu <> nil then
    if MenuItem.GetParentComponent.Name = FForm.Menu.Name then
    begin
      FTopMenu := true;
      if FForm.Menu.Images <> nil then
        if MenuItem.ImageIndex <> -1 then
          HasImgLstBitmap := true;

    end;

  if (MenuItem.Parent.GetParentMenu.Images <> nil)
  {$IFDEF VER5U}
  or (MenuItem.Parent.SubMenuImages <> nil)
  {$ENDIF}
  then
  begin
    if MenuItem.ImageIndex <> -1 then
      HasImgLstBitmap := true
    else
      HasImgLstBitmap := false;
  end;

  if HasImgLstBitmap then
  begin
  {$IFDEF VER5U}
    if MenuItem.Parent.SubMenuImages <> nil then
      MenuItem.Parent.SubMenuImages.GetBitmap(MenuItem.ImageIndex, B)
    else
  {$ENDIF}
      MenuItem.Parent.GetParentMenu.Images.GetBitmap(MenuItem.ImageIndex, B)
  end
  else
    if MenuItem.Bitmap.Width > 0 then
      B.Assign(TBitmap(MenuItem.Bitmap));

  Result.x := B.Width;
  Result.Y := B.Height;

  if not FTopMenu then
    if Result.x < FIconWidth then
      Result.x := FIconWidth;

  B.Free;
end;

procedure TXPMenu.MeasureItem(Sender: TObject; ACanvas: TCanvas;
  var Width, Height: Integer);
var
  s: string;
  W, H: integer;
  P: TPoint;
  IsLine: boolean;
begin
  if FActive then
  begin
    S := TMenuItem(Sender).Caption;
      //------
    if S = '-' then IsLine := true else IsLine := false;
    if IsLine then

      //------
      if IsLine then
        S := '';

    if Trim(ShortCutToText(TMenuItem(Sender).ShortCut)) <> '' then
      S := S + ShortCutToText(TMenuItem(Sender).ShortCut) + 'WWW';



    ACanvas.Font.Assign(FFont);
    W := ACanvas.TextWidth(s);
    if pos('&', s) > 0 then
      W := W - ACanvas.TextWidth('&');

    P := GetImageExtent(TMenuItem(Sender));

    W := W + P.x + 10;

    if Width < W then
      Width := W;

    if IsLine then
      Height := 4
    else
    begin
      H := ACanvas.TextHeight(s) + Round(ACanvas.TextHeight(s) * 0.75);
      if P.y + 4 > H then
        H := P.y + 4;

      if Height < H then
        Height := H;
    end;
  end;

end;

procedure TXPMenu.MenueDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
  Selected: Boolean);
var
  txt: string;
  B: TBitmap;
  IconRect, TextRect, CheckedRect: TRect;
  i, X1, X2: integer;
  TextFormat: integer;
  HasImgLstBitmap: boolean;
  FMenuItem: TMenuItem;
  FMenu: TMenu;
  FTopMenu: boolean;
  ISLine: boolean;
  ImgListHandle: HImageList;        {Commctrl.pas}
  ImgIndex: integer;
  hWndM: HWND;
  hDcM: HDC;
begin
  FTopMenu := false;
  FMenuItem := TMenuItem(Sender);

  SetGlobalColor(ACanvas);

  if FMenuItem.Caption = '-' then IsLine := true else IsLine := false;

  FMenu := FMenuItem.Parent.GetParentMenu;

  if FMenu is TMainMenu then
    for i := 0 to FMenuItem.GetParentMenu.Items.Count - 1 do
      if FMenuItem.GetParentMenu.Items[i] = FMenuItem then
      begin
        FTopMenu := True;
        break;
      end;


  ACanvas.Font.Assign(FFont);
  if FMenu.IsRightToLeft then
    ACanvas.Font.Charset := ARABIC_CHARSET;

  Inc(ARect.Bottom, 1);
  TextRect := ARect;
  txt := ' ' + FMenuItem.Caption;

  B := TBitmap.Create;

  HasImgLstBitmap := false;


  if FMenuItem.Bitmap.Width > 0 then
    B.Assign(TBitmap(FMenuItem.Bitmap));

  if (FMenuItem.Parent.GetParentMenu.Images <> nil)
  {$IFDEF VER5U}
  or (FMenuItem.Parent.SubMenuImages <> nil)
  {$ENDIF}
  then
  begin
    if FMenuItem.ImageIndex <> -1 then
      HasImgLstBitmap := true
    else
      HasImgLstBitmap := false;
  end;



  if FMenu.IsRightToLeft then
  begin
    X1 := ARect.Right - FIconWidth;
    X2 := ARect.Right;
  end
  else
  begin
    X1 := ARect.Left;
    X2 := ARect.Left + FIconWidth;
  end;
  IconRect := Rect(X1, ARect.Top, X2, ARect.Bottom);


  if HasImgLstBitmap then
  begin
    CheckedRect := IconRect;
    Inc(CheckedRect.Left, 1);
    Inc(CheckedRect.Top, 2);
    Dec(CheckedRect.Right, 3);
    Dec(CheckedRect.Bottom, 2);

  end
  else
  begin
    CheckedRect.Left := IconRect.Left +
      (IConRect.Right - IconRect.Left - 10) div 2;
    CheckedRect.Top := IconRect.Top +
      (IConRect.Bottom - IconRect.Top - 10) div 2;
    CheckedRect.Right := CheckedRect.Left + 10;
    CheckedRect.Bottom := CheckedRect.Top + 10;

  end;


  if FMenu.IsRightToLeft then
  begin
    X1 := ARect.Left;
    X2 := ARect.Right - FIconWidth;
    if B.Width > FIconWidth then
      X2 := ARect.Right - B.Width - 4;
  end
  else
  begin
    X1 := ARect.Left + FIconWidth;
    if B.Width > X1 then
      X1 := B.Width + 4;
    X2 := ARect.Right;
  end;

  TextRect := Rect(X1, ARect.Top, X2, ARect.Bottom);

  if FTopMenu then
  begin
    if not HasImgLstBitmap then
    begin
      TextRect := ARect;
    end
    else
    begin
      if FMenu.IsRightToLeft then
        TextRect.Right := TextRect.Right + 5
      else
        TextRect.Left := TextRect.Left - 5;
    end

  end;

  if FTopMenu then
  begin
    ACanvas.brush.color := FFMenuBarColor;
    ACanvas.Pen.Color := FFMenuBarColor;

    ACanvas.FillRect(ARect);
  end
  else
  begin
    if (Is16Bit and FGradient) then
    begin
      inc(ARect.Right,2);  //needed for RightToLeft
      DrawGradient(ACanvas, ARect, FMenu.IsRightToLeft);
      Dec(ARect.Right,2);

    end
    else
    begin
      ACanvas.brush.color := FFColor;
      ACanvas.FillRect(ARect);

      ACanvas.brush.color := FFIconBackColor;
      ACanvas.FillRect(IconRect);
    end;


//------------
  end;


  if FMenuItem.Enabled then
    ACanvas.Font.Color := FFont.Color
  else
    ACanvas.Font.Color := FDisabledColor;

  if Selected and FDrawSelect then
  begin
    ACanvas.brush.Style := bsSolid;
    if FTopMenu then
    begin
      DrawTopMenuItem(FMenuItem, ACanvas, ARect, FMenu.IsRightToLeft);
    end
    else
      //------
      if FMenuItem.Enabled then
      begin

        Inc(ARect.Top, 1);
        Dec(ARect.Bottom, 1);
        if FFlatMenu then
          Dec(ARect.Right, 1);
        ACanvas.brush.color := FFSelectColor;
        ACanvas.FillRect(ARect);
        ACanvas.Pen.color := FFSelectBorderColor;
        ACanvas.Brush.Style := bsClear;
        ACanvas.RoundRect(Arect.Left, Arect.top, Arect.Right,
          Arect.Bottom, 0, 0);
        Dec(ARect.Top, 1);
        Inc(ARect.Bottom, 1);
        if FFlatMenu then
          Inc(ARect.Right, 1);
      end;
      //-----

  end;

  DrawCheckedItem(FMenuItem, Selected, HasImgLstBitmap, ACanvas, CheckedRect);

//-----

  if HasImgLstBitmap then
  begin
  {$IFDEF VER5U}
    if FMenuItem.Parent.SubMenuImages <> nil then
    begin
      //FMenuItem.Parent.SubMenuImages.GetBitmap(FMenuItem.ImageIndex, B);
      ImgListHandle := FMenuItem.Parent.SubMenuImages.Handle;
      ImgIndex := FMenuItem.ImageIndex;

      B.Width := FMenuItem.Parent.SubMenuImages.Width;
      B.Height := FMenuItem.Parent.SubMenuImages.Height;
      B.Canvas.Brush.Color := FFIconBackColor;
      B.Canvas.FillRect(Rect(0, 0, B.Width, B.Height));
      ImageList_DrawEx(ImgListHandle, ImgIndex,
        B.Canvas.Handle, 0, 0, 0, 0, clNone, clNone, ILD_Transparent);

    end
    else
  {$ENDIF}
    begin
      //FMenuItem.Parent.GetParentMenu.Images.GetBitmap(FMenuItem.ImageIndex, B);
      ImgListHandle := FMenuItem.Parent.GetParentMenu.Images.Handle;
      ImgIndex := FMenuItem.ImageIndex;

      B.Width := FMenuItem.Parent.GetParentMenu.Images.Width;
      B.Height := FMenuItem.Parent.GetParentMenu.Images.Height;
      B.Canvas.Brush.Color := FFIconBackColor;
      B.Canvas.FillRect(Rect(0, 0, B.Width, B.Height));
      ImageList_DrawEx(ImgListHandle, ImgIndex,
        B.Canvas.Handle, 0, 0, 0, 0, clNone, clNone, ILD_Transparent);

    end;
  end

  else
    if FMenuItem.Bitmap.Width > 0 then
      B.Assign(TBitmap(FMenuItem.Bitmap));


  DrawIcon(FMenuItem, ACanvas, B, IconRect,
    Selected, False, FMenuItem.Enabled, FMenuItem.Checked,
    FTopMenu, FMenu.IsRightToLeft);


//--------
  if not IsLine then
  begin

    if FMenu.IsRightToLeft then
    begin
      TextFormat := DT_RIGHT + DT_RTLREADING;
      Dec(TextRect.Right, 5);
    end
    else
    begin
      TextFormat := 0;
      Inc(TextRect.Left, 5);
    end;

    DrawTheText(txt, ShortCutToText(FMenuItem.ShortCut),
      ACanvas, TextRect,
      Selected, FMenuItem.Enabled, FMenuItem.Default,
      FTopMenu, FMenu.IsRightToLeft, TextFormat);

//-----------

  end


  else
  begin
    if FMenu.IsRightToLeft then
    begin
      X1 := TextRect.Left;
      X2 := TextRect.Right - 7;
    end
    else
    begin
      X1 := TextRect.Left + 7;
      X2 := TextRect.Right;
    end;

    ACanvas.Pen.Color := FFSeparatorColor;
    ACanvas.MoveTo(X1,
      TextRect.Top +
      Round((TextRect.Bottom - TextRect.Top) / 2));
    ACanvas.LineTo(X2,
      TextRect.Top +
      Round((TextRect.Bottom - TextRect.Top) / 2))
  end;

  B.free;

//------

  if not (csDesigning in ComponentState) then
  begin
    if (FFlatMenu) and (not FTopMenu) then
    begin
      hDcM := ACanvas.Handle;
      hWndM := WindowFromDC(hDcM);
      if hWndM <> FForm.Handle then
      begin
        DrawWindowBorder(hWndM, FMenu.IsRightToLeft);
      end;
    end;
  end;

//-----
  ActivateMenuItem(FMenuItem);  // to check for new sub items
end;


procedure TXPMenu.ToolBarDrawButton(Sender: TToolBar;
  Button: TToolButton; State: TCustomDrawState; var DefaultDraw: Boolean);

var
  ACanvas: TCanvas;

  ARect, HoldRect: TRect;
  B: TBitmap;
  HasBitmap: boolean;
  BitmapWidth: integer;
  TextFormat: integer;
  XButton: TToolButton;
  HasBorder: boolean;
  HasBkg: boolean;
  IsTransparent: boolean;
  FBSelectColor: TColor;

  procedure DrawBorder;
  var
    BRect, WRect: TRect;
    procedure DrawRect;
    begin
      ACanvas.Pen.color := FFSelectBorderColor;
      ACanvas.MoveTo(WRect.Left, WRect.Top);
      ACanvas.LineTo(WRect.Right, WRect.Top);
      ACanvas.LineTo(WRect.Right, WRect.Bottom);
      ACanvas.LineTo(WRect.Left, WRect.Bottom);
      ACanvas.LineTo(WRect.Left, WRect.Top);
    end;

  begin
    BRect := HoldRect;
    Dec(BRect.Bottom, 1);
    Inc(BRect.Top, 1);
    Dec(BRect.Right, 1);

    WRect := BRect;
    if Button.Style = tbsDropDown then
    begin
      Dec(WRect.Right, 13);
      DrawRect;

      WRect := BRect;
      Inc(WRect.Left, WRect.Right - WRect.Left - 13);
      DrawRect;
    end
    else
    begin

      DrawRect;
    end;
  end;

begin
  B := nil;

  HasBitmap := (TToolBar(Button.Parent).Images <> nil) and
    (Button.ImageIndex <> -1) and
    (Button.ImageIndex <= TToolBar(Button.Parent).Images.Count - 1);


  IsTransparent := TToolBar(Button.Parent).Transparent;

  ACanvas := Sender.Canvas;
  SetGlobalColor(ACanvas);

  if (Is16Bit) and (not UseSystemColors) then
    FBSelectColor := NewColor(ACanvas, FSelectColor, 68)
  else
    FBSelectColor := FFSelectColor;


  HoldRect := Button.BoundsRect;

  ARect := HoldRect;

  //if FUseSystemColors then
  begin
    if (Button.MenuItem <> nil) then
    begin
      if (TToolBar(Button.Parent).Font.Name <> FFont.Name) or
         (TToolBar(Button.Parent).Font.Size <> FFont.Size) then
      begin
        TToolBar(Button.Parent).Font.Assign(FFont);
        Button.AutoSize := false;
        Button.AutoSize := true;
      end;
    end
  end;

  if Is16Bit then
    ACanvas.brush.color := NewColor(ACanvas, clBtnFace, 16)
  else
    ACanvas.brush.color := clBtnFace;

  if not IsTransparent then
    ACanvas.FillRect(ARect);

  HasBorder := false;
  HasBkg := false;

  if (cdsHot in State) then
  begin
    if (cdsChecked in State) or (Button.Down) or (cdsSelected in State) then
      ACanvas.Brush.Color := FCheckedAreaSelectColor
    else
      ACanvas.brush.color := FBSelectColor;
    HasBorder := true;
    HasBkg := true;
  end;

  if (cdsChecked in State) and not (cdsHot in State) then
  begin
    ACanvas.Brush.Color := FCheckedAreaColor;
    HasBorder := true;
    HasBkg := true;
  end;

  if (cdsIndeterminate in State) and not (cdsHot in State) then
  begin
    ACanvas.Brush.Color := FBSelectColor;
    HasBkg := true;
  end;


  if (Button.MenuItem <> nil) and (State = []) then
  begin
    ACanvas.brush.color := FFMenuBarColor;
    if not IsTransparent then
      HasBkg := true;
  end;


  Inc(ARect.Top, 1);

  if HasBkg then
    ACanvas.FillRect(ARect);

  if HasBorder then
    DrawBorder;


  if (Button.MenuItem <> nil)
    and (cdsSelected in State) then
  begin
    DrawTopMenuItem(Button, ACanvas, ARect, false);
    DefaultDraw := false;
  end;

  ARect := HoldRect;
  DefaultDraw := false;



  if Button.Style = tbsDropDown then
  begin
    ACanvas.Pen.Color := clBlack;
    DrawArrow(ACanvas, (ARect.Right - 14) + ((14 - 5) div 2),
      ARect.Top + ((ARect.Bottom - ARect.Top - 3) div 2) + 1);
  end;

  BitmapWidth := 0;
  if HasBitmap then
  begin

    try
    B := TBitmap.Create;
  //TToolBar(Button.Parent).Images.GetBitmap(Button.ImageIndex, B);

    B.Width := TToolBar(Button.Parent).Images.Width;
    B.Height := TToolBar(Button.Parent).Images.Height;
    B.Canvas.Brush.Color := ACanvas.Brush.Color;
    B.Canvas.FillRect(Rect(0, 0, B.Width, B.Height));
    ImageList_DrawEx(TToolBar(Button.Parent).Images.Handle, Button.ImageIndex,
      B.Canvas.Handle, 0, 0, 0, 0, clNone, clNone, ILD_Transparent);

    ImgLstHandle:= TToolBar(Button.Parent).Images.Handle;
    ImgLstIndex:= Button.ImageIndex;



    BitmapWidth := b.Width;

    if Button.Style = tbsDropDown then
      Dec(ARect.Right, 12);


    if TToolBar(Button.Parent).List then
    begin

      if Button.BiDiMode = bdRightToLeft then
      begin
        Dec(ARect.Right, 3);
        ARect.Left := ARect.Right - BitmapWidth;

      end
      else
      begin
        Inc(ARect.Left, 3);
        ARect.Right := ARect.Left + BitmapWidth
      end


    end
    else
      ARect.Left := Round(ARect.Left + (ARect.Right - ARect.Left - B.Width)/2);

    inc(ARect.Top, 2);
    ARect.Bottom := ARect.Top + B.Height + 6;

    DrawIcon(Button, ACanvas, B, ARect, (cdsHot in State),
     (cdsSelected in State), Button.Enabled, (cdsChecked in State), false,
     false);
    finally
    B.Free;
    end;
    ARect := HoldRect;
    DefaultDraw := false;
  end;
//-----------
  if TToolBar(Button.Parent).ShowCaptions then
  begin

    if Button.Style = tbsDropDown then
      Dec(ARect.Right, 12);


    if not TToolBar(Button.Parent).List then
    begin
      TextFormat := DT_Center;
      ARect.Top := ARect.Bottom - ACanvas.TextHeight(Button.Caption) - 3;
    end
    else
    begin
      TextFormat := DT_VCENTER;
      if Button.BiDiMode = bdRightToLeft then
      begin
        TextFormat := TextFormat + DT_Right;
        Dec(ARect.Right, BitmapWidth + 7);
      end
      else
      begin
        Inc(ARect.Left, BitmapWidth + 6);
      end

    end;

    if (Button.MenuItem <> nil) then
    begin
      TextFormat := DT_Center;

    end;

    if Button.BiDiMode = bdRightToLeft then
      TextFormat := TextFormat + DT_RTLREADING;

    DrawTheText(Button.Caption, '',
      ACanvas, ARect,
      (cdsSelected in State), Button.Enabled, false,
      (Button.MenuItem <> nil),
      (Button.BidiMode = bdRightToLeft), TextFormat);

    ARect := HoldRect;
    DefaultDraw := false;
  end;


  if Button.Index > 0 then
  begin
    XButton := TToolBar(Button.Parent).Buttons[Button.Index - 1];
    if (XButton.Style = tbsDivider) or (XButton.Style = tbsSeparator) then
    begin
      ARect := XButton.BoundsRect;
      if Is16Bit then
        ACanvas.brush.color := NewColor(ACanvas, clBtnFace, 16)
      else
        ACanvas.brush.color := clBtnFace;

      if not IsTransparent then
        ACanvas.FillRect(ARect);
     // if (XButton.Style = tbsDivider) then  // Can't get it.
      if XButton.Tag > 0 then  
      begin
        Inc(ARect.Top, 2);
        Dec(ARect.Bottom, 1);

        ACanvas.Pen.color := FFDisabledColor;
        ARect.Left := ARect.Left + (ARect.Right - ARect.Left) div 2;
        ACanvas.MoveTo(ARect.Left, ARect.Top);
        ACanvas.LineTo(ARect.Left, ARect.Bottom);

      end;
      ARect := Button.BoundsRect;
      DefaultDraw := false;
    end;

  end;

  if Button.MenuItem <> nil then
    ActivateMenuItem(Button.MenuItem);
end;


procedure TXPMenu.SetGlobalColor(ACanvas: TCanvas);
begin
//-----

  if GetDeviceCaps(ACanvas.Handle, BITSPIXEL) < 16 then
    Is16Bit := false
  else
    Is16Bit := true;


  FFColor := FColor;
  FFIconBackColor := FIconBackColor;

  FFSelectColor := FSelectColor;

  if Is16Bit then
  begin
    FCheckedAreaColor := NewColor(ACanvas, FSelectColor, 75);
    FCheckedAreaSelectColor := NewColor(ACanvas, FSelectColor, 50);

    FMenuBorderColor := GetShadeColor(ACanvas, clBtnFace, 90);
    FMenuShadowColor := GetShadeColor(ACanvas, clBtnFace, 76);
  end
  else
  begin
    FFSelectColor := FSelectColor;
    FCheckedAreaColor := clWhite;
    FCheckedAreaSelectColor := clSilver;
    FMenuBorderColor := clBtnShadow;
    FMenuShadowColor := clBtnShadow;
  end;

  FFSelectBorderColor := FSelectBorderColor;
  FFSelectFontColor := FSelectFontColor;
  FFMenuBarColor := FMenuBarColor;
  FFDisabledColor := FDisabledColor;
  FFCheckedColor := FCheckedColor;
  FFSeparatorColor := FSeparatorColor;



  if FUseSystemColors then
  begin
    GetSystemMenuFont(FFont);
    FFSelectFontColor := FFont.Color;
    if not Is16Bit then
    begin
      FFColor := clWhite;
      FFIconBackColor := clBtnFace;
      FFSelectColor := clWhite;
      FFSelectBorderColor := clHighlight;
      FFMenuBarColor := FFIconBackColor;
      FFDisabledColor := clBtnShadow;
      FFCheckedColor := clHighlight;
      FFSeparatorColor := clBtnShadow;
      FCheckedAreaColor := clWhite;
      FCheckedAreaSelectColor := clWhite;

    end
    else
    begin
      FFColor := NewColor(ACanvas, clBtnFace, 86);
      FFIconBackColor := NewColor(ACanvas, clBtnFace, 16);
      FFSelectColor := NewColor(ACanvas, clHighlight, 68);
      FFSelectBorderColor := clHighlight;
      FFMenuBarColor := clMenu;

      FFDisabledColor := NewColor(ACanvas, clBtnShadow, 40);
      FFSeparatorColor := NewColor(ACanvas, clBtnShadow, 25);
      FFCheckedColor := clHighlight;
      FCheckedAreaColor := NewColor(ACanvas, clHighlight, 75);
      FCheckedAreaSelectColor := NewColor(ACanvas, clHighlight, 50);

    end;
  end;

end;

procedure TXPMenu.DrawTopMenuItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; IsRightToLeft: boolean);
var
  X1, X2: integer;
  DefColor, HoldColor: TColor;
begin
  X1 := ARect.Left;
  X2 := ARect.Right;


  ACanvas.brush.Style := bsSolid;
  ACanvas.brush.color := FFIconBackColor;

  ACanvas.FillRect(ARect);
  ACanvas.Pen.Color := FMenuBorderColor;

  if (not IsRightToLeft) and (Is16Bit) and (Sender is TMenuItem) then
  begin
    ACanvas.MoveTo(X1, ARect.Bottom - 1);
    ACanvas.LineTo(X1, ARect.Top);
    ACanvas.LineTo(X2 - 8, ARect.Top);
    ACanvas.LineTo(X2 - 8, ARect.Bottom);

    DefColor := FFMenuBarColor;


    HoldColor := GetShadeColor(ACanvas, DefColor, 10);
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := HoldColor;
    ACanvas.Pen.Color := HoldColor;

    ACanvas.FillRect(Rect(X2 - 7, ARect.Top, X2, ARect.Bottom));

    HoldColor := GetShadeColor(ACanvas, DefColor, 30);
    ACanvas.Brush.Color := HoldColor;
    ACanvas.Pen.Color := HoldColor;
    ACanvas.FillRect(Rect(X2 - 7, ARect.Top + 3, X2 - 2, ARect.Bottom));

    HoldColor := GetShadeColor(ACanvas, DefColor, 40 + 20);
    ACanvas.Brush.Color := HoldColor;
    ACanvas.Pen.Color := HoldColor;
    ACanvas.FillRect(Rect(X2 - 7, ARect.Top + 5, X2 - 3, ARect.Bottom));

    HoldColor := GetShadeColor(ACanvas, DefColor, 60 + 40);
    ACanvas.Brush.Color := HoldColor;
    ACanvas.Pen.Color := HoldColor;
    ACanvas.FillRect(Rect(X2 - 7, ARect.Top + 6, X2 - 5, ARect.Bottom));

    //---

    ACanvas.Pen.Color := DefColor;
    ACanvas.MoveTo(X2 - 5, ARect.Top + 1);
    ACanvas.LineTo(X2 - 1, ARect.Top + 1);
    ACanvas.LineTo(X2 - 1, ARect.Top + 6);

    ACanvas.MoveTo(X2 - 3, ARect.Top + 2);
    ACanvas.LineTo(X2 - 2, ARect.Top + 2);
    ACanvas.LineTo(X2 - 2, ARect.Top + 3);
    ACanvas.LineTo(X2 - 3, ARect.Top + 3);



    ACanvas.Pen.Color := GetShadeColor(ACanvas, DefColor, 10);
    ACanvas.MoveTo(X2 - 6, ARect.Top + 3);
    ACanvas.LineTo(X2 - 3, ARect.Top + 3);
    ACanvas.LineTo(X2 - 3, ARect.Top + 6);
    ACanvas.LineTo(X2 - 4, ARect.Top + 6);
    ACanvas.LineTo(X2 - 4, ARect.Top + 3);

    ACanvas.Pen.Color := GetShadeColor(ACanvas, DefColor, 30);
    ACanvas.MoveTo(X2 - 5, ARect.Top + 5);
    ACanvas.LineTo(X2 - 4, ARect.Top + 5);
    ACanvas.LineTo(X2 - 4, ARect.Top + 9);

    ACanvas.Pen.Color := GetShadeColor(ACanvas, DefColor, 40);
    ACanvas.MoveTo(X2 - 6, ARect.Top + 5);
    ACanvas.LineTo(X2 - 6, ARect.Top + 7);

  end
  else
  begin
    ACanvas.Pen.Color := FMenuBorderColor;
    ACanvas.Brush.Color := FMenuShadowColor;

    ACanvas.MoveTo(X1, ARect.Bottom - 1);
    ACanvas.LineTo(X1, ARect.Top);
    ACanvas.LineTo(X2 - 3, ARect.Top);
    ACanvas.LineTo(X2 - 3, ARect.Bottom);


    ACanvas.Pen.Color := ACanvas.Brush.Color;
    ACanvas.FillRect(Rect(X2 - 2, ARect.Top + 2, X2, ARect.Bottom));
  end;

end;


procedure TXPMenu.DrawCheckedItem(FMenuItem: TMenuItem; Selected,
 HasImgLstBitmap: boolean; ACanvas: TCanvas; CheckedRect: TRect);
var
  X1, X2: integer;
begin
  if FMenuItem.RadioItem then
  begin
    if FMenuItem.Checked then
    begin

      ACanvas.Pen.color := FFSelectBorderColor;
      if selected then
        ACanvas.Brush.Color := FCheckedAreaSelectColor
      else
        ACanvas.Brush.Color := FCheckedAreaColor;
      ACanvas.Brush.Style := bsSolid;
      if HasImgLstBitmap then
      begin
        ACanvas.RoundRect(CheckedRect.Left, CheckedRect.Top,
          CheckedRect.Right, CheckedRect.Bottom,
          6, 6);
      end
      else
      begin
        ACanvas.Ellipse(CheckedRect.Left, CheckedRect.Top,
          CheckedRect.Right, CheckedRect.Bottom);
      end;
    end;
  end
  else
  begin
    if (FMenuItem.Checked) then
      if (not HasImgLstBitmap) then
      begin
        ACanvas.Pen.color := FFCheckedColor;
        if selected then
          ACanvas.Brush.Color := FCheckedAreaSelectColor
        else
          ACanvas.Brush.Color := FCheckedAreaColor; ;
        ACanvas.Brush.Style := bsSolid;
        ACanvas.Rectangle(CheckedRect.Left, CheckedRect.Top,
          CheckedRect.Right, CheckedRect.Bottom);
        ACanvas.Pen.color := clBlack;
        x1 := CheckedRect.Left + 1;
        x2 := CheckedRect.Top + 5;
        ACanvas.MoveTo(x1, x2);

        x1 := CheckedRect.Left + 4;
        x2 := CheckedRect.Bottom - 2;
        ACanvas.LineTo(x1, x2);
           //--
        x1 := CheckedRect.Left + 2;
        x2 := CheckedRect.Top + 5;
        ACanvas.MoveTo(x1, x2);

        x1 := CheckedRect.Left + 4;
        x2 := CheckedRect.Bottom - 3;
        ACanvas.LineTo(x1, x2);
           //--
        x1 := CheckedRect.Left + 2;
        x2 := CheckedRect.Top + 4;
        ACanvas.MoveTo(x1, x2);

        x1 := CheckedRect.Left + 5;
        x2 := CheckedRect.Bottom - 3;
        ACanvas.LineTo(x1, x2);
           //-----------------

        x1 := CheckedRect.Left + 4;
        x2 := CheckedRect.Bottom - 3;
        ACanvas.MoveTo(x1, x2);

        x1 := CheckedRect.Right + 2;
        x2 := CheckedRect.Top - 1;
        ACanvas.LineTo(x1, x2);
           //--
        x1 := CheckedRect.Left + 4;
        x2 := CheckedRect.Bottom - 2;
        ACanvas.MoveTo(x1, x2);

        x1 := CheckedRect.Right - 2;
        x2 := CheckedRect.Top + 3;
        ACanvas.LineTo(x1, x2);

      end
      else
      begin
        ACanvas.Pen.color := FFSelectBorderColor;
        if selected then
          ACanvas.Brush.Color := FCheckedAreaSelectColor
        else
          ACanvas.Brush.Color := FCheckedAreaColor;
        ACanvas.Brush.Style := bsSolid;
        ACanvas.Rectangle(CheckedRect.Left, CheckedRect.Top,
          CheckedRect.Right, CheckedRect.Bottom);
      end;
  end;

end;

procedure TXPMenu.DrawTheText(txt, ShortCuttext: string; ACanvas: TCanvas; TextRect: TRect;
  Selected, Enabled, Default, TopMenu, IsRightToLeft: boolean; TextFormat: integer);
var
  DefColor: TColor;
begin

  DefColor := FFont.Color;

  ACanvas.Font := FFont;


  if Enabled then
    DefColor := FFont.Color;


  if Selected then
    DefColor := FFSelectFontColor;


  if not Enabled then
  begin
    DefColor := FFDisabledColor;
    if Selected then
      if Is16Bit then
        DefColor := NewColor(ACanvas, FFDisabledColor, 30);
  end;

  if (TopMenu and Selected) then
    DefColor := TopMenuFontColor(ACanvas, FFIconBackColor);

  ACanvas.Font.color := DefColor;    // will not affect Buttons


  TextRect.Top := TextRect.Top +
    ((TextRect.Bottom - TextRect.Top) - ACanvas.TextHeight('W')) div 2;

  SetBkMode(ACanvas.Handle, TRANSPARENT);


  if Default and Enabled then
  begin

    Inc(TextRect.Left, 1);
    ACanvas.Font.color := GetShadeColor(ACanvas,
                              ACanvas.Pixels[TextRect.Left, TextRect.Top], 30);
    DrawtextEx(ACanvas.Handle,
      PChar(txt),
      Length(txt),
      TextRect, TextFormat, nil);
    Dec(TextRect.Left, 1);


    Inc(TextRect.Top, 2);
    Inc(TextRect.Left, 1);
    Inc(TextRect.Right, 1);


    ACanvas.Font.color := GetShadeColor(ACanvas,
                              ACanvas.Pixels[TextRect.Left, TextRect.Top], 30);
    DrawtextEx(ACanvas.Handle,
      PChar(txt),
      Length(txt),
      TextRect, TextFormat, nil);


    Dec(TextRect.Top, 1);
    Dec(TextRect.Left, 1);
    Dec(TextRect.Right, 1);

    ACanvas.Font.color := GetShadeColor(ACanvas,
                              ACanvas.Pixels[TextRect.Left, TextRect.Top], 40);
    DrawtextEx(ACanvas.Handle,
      PChar(txt),
      Length(txt),
      TextRect, TextFormat, nil);


    Inc(TextRect.Left, 1);
    Inc(TextRect.Right, 1);

    ACanvas.Font.color := GetShadeColor(ACanvas,
                              ACanvas.Pixels[TextRect.Left, TextRect.Top], 60);
    DrawtextEx(ACanvas.Handle,
      PChar(txt),
      Length(txt),
      TextRect, TextFormat, nil);

    Dec(TextRect.Left, 1);
    Dec(TextRect.Right, 1);
    Dec(TextRect.Top, 1);

    ACanvas.Font.color := DefColor;
  end;



  DrawtextEx(ACanvas.Handle,
    PChar(txt),
    Length(txt),
    TextRect, TextFormat, nil);


  txt := ShortCutText + ' ';

  if not Is16Bit then
    ACanvas.Font.color := DefColor
  else
    ACanvas.Font.color := GetShadeColor(ACanvas, DefColor, -40);



  if IsRightToLeft then
  begin
    Inc(TextRect.Left, 10);
    TextFormat := DT_LEFT
  end
  else
  begin
    Dec(TextRect.Right, 10);
    TextFormat := DT_RIGHT;
  end;

  DrawtextEx(ACanvas.Handle,
    PChar(txt),
    Length(txt),
    TextRect, TextFormat, nil);

end;

procedure TXPMenu.DrawIcon(Sender: TObject; ACanvas: TCanvas; B: TBitmap;
 IconRect: Trect; Hot, Selected, Enabled, Checked, FTopMenu,
 IsRightToLeft: boolean);
var
  DefColor: TColor;
  X1, X2: integer;
begin
  if B <> nil then
  begin
    X1 := IconRect.Left;
    X2 := IconRect.Top + 2;
    if Sender is TMenuItem then
    begin
      inc(X2, 2);
      if FIconWidth >= B.Width then
        X1 := X1 + ((FIconWidth - B.Width) div 2) - 1
      else
      begin
        if IsRightToLeft then
          X1 := IconRect.Right - b.Width - 2
        else
          X1 := IconRect.Left + 2;
      end;
    end;


    if (Hot) and (not FTopMenu) and (Enabled) and (not Checked) then
      if not Selected then
      begin
        dec(X1, 1);
        dec(X2, 1);
      end;

    if (not Hot) and (Enabled) and (not Checked) then
      if Is16Bit then
        DimBitmap(B, 30);

    if (not Hot) and (not Enabled) then
      GrayBitmap(B, 60);

    if (Hot) and (not Enabled) then
      GrayBitmap(B, 80);



    if (Hot) and (Enabled) and (not Checked) then
    begin
      if (Is16Bit) and (not UseSystemColors) and (Sender is TToolButton) then
        DefColor := NewColor(ACanvas, FSelectColor, 68)
      else
        DefColor := FFSelectColor;

      DefColor := GetShadeColor(ACanvas, DefColor, 50);
      DrawBitmapShadow(B, ACanvas, X1 + 2, X2 + 2, DefColor);
    end;

    B.Transparent := true;
    ACanvas.Draw(X1, X2, B);


  end;

end;

procedure TXPMenu.DrawArrow(ACanvas: TCanvas; X, Y: integer);
begin
  ACanvas.MoveTo(X, Y);
  ACanvas.LineTo(X + 4, Y);

  ACanvas.MoveTo(X + 1, Y + 1);
  ACanvas.LineTo(X + 4, Y);

  ACanvas.MoveTo(X + 2, Y + 2);
  ACanvas.LineTo(X + 3, Y);

end;

function TXPMenu.TopMenuFontColor(ACanvas: TCanvas; Color: TColor): TColor;
var
  r, g, b, avg: integer;
begin

  Color := ColorToRGB(Color);
  r := Color and $000000FF;
  g := (Color and $0000FF00) shr 8;
  b := (Color and $00FF0000) shr 16;

  Avg := (r + b) div 2;

  if (Avg > 150) or (g > 200) then
    Result := FFont.Color
  else
    Result := NewColor(ACanvas, Color, 90);
   // Result := FColor;
end;


procedure TXPMenu.SetActive(const Value: boolean);
begin

  FActive := Value;

  if FActive then
  begin
    InitMenueItems(false);
    InitMenueItems(true);
  end
  else
    InitMenueItems(false);

  Windows.DrawMenuBar(FForm.Handle);
end;

procedure TXPMenu.SetForm(const Value: TForm);
var
  Hold: boolean;
begin
  if Value <> FForm then
  begin
    Hold := Active;
    Active := false;
    FForm := Value;
    if Hold then
      Active := True;
  end;
end;

procedure TXPMenu.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  Windows.DrawMenuBar(FForm.Handle);

end;

procedure TXPMenu.SetColor(const Value: TColor);
begin
  FColor := Value;
end;

procedure TXPMenu.SetIconBackColor(const Value: TColor);
begin
  FIconBackColor := Value;
end;

procedure TXPMenu.SetMenuBarColor(const Value: TColor);
begin
  FMenuBarColor := Value;
  Windows.DrawMenuBar(FForm.Handle);
end;

procedure TXPMenu.SetCheckedColor(const Value: TColor);
begin
  FCheckedColor := Value;
end;

procedure TXPMenu.SetSeparatorColor(const Value: TColor);
begin
  FSeparatorColor := Value;
end;

procedure TXPMenu.SetSelectBorderColor(const Value: TColor);
begin
  FSelectBorderColor := Value;
end;

procedure TXPMenu.SetSelectColor(const Value: TColor);
begin
  FSelectColor := Value;
end;

procedure TXPMenu.SetDisabledColor(const Value: TColor);
begin
  FDisabledColor := Value;
end;

procedure TXPMenu.SetSelectFontColor(const Value: TColor);
begin
  FSelectFontColor := Value;
end;

procedure TXPMenu.SetIconWidth(const Value: integer);
begin
  FIconWidth := Value;
end;

procedure TXPMenu.SetDrawSelect(const Value: boolean);
begin
  FDrawSelect := Value;
end;



procedure TXPMenu.SetOverrideOwnerDraw(const Value: boolean);
begin
  FOverrideOwnerDraw := Value;
  if FActive then
    Active := True;
end;


procedure TXPMenu.SetUseSystemColors(const Value: boolean);
begin
  FUseSystemColors := Value;
  Windows.DrawMenuBar(FForm.Handle);
end;

{
procedure TXPMenu.SetRefreshOnChange(const Value: boolean);
begin
  FRefreshOnChange := Value;
  if not (csDesigning in ComponentState) and
   (FActive) then
    Active := True;
end;

procedure TXPMenu.MenuChange(Sender: TObject; Source: TMenuItem;
  Rebuild: Boolean);
begin
  if not (csDesigning in ComponentState) then
    if (Source <> nil) then
      if  ComponentState = [] then
       Active := true ;
end;
}

procedure TXPMenu.SetGradient(const Value: boolean);
begin
  FGradient := Value;
end;

procedure TXPMenu.SetFlatMenu(const Value: boolean);
begin
  FFlatMenu := Value;
end;


procedure GetSystemMenuFont(Font: TFont);
var
  FNonCLientMetrics: TNonCLientMetrics;
begin
  FNonCLientMetrics.cbSize := Sizeof(TNonCLientMetrics);
  if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @FNonCLientMetrics,0) then
  begin
    Font.Handle := CreateFontIndirect(FNonCLientMetrics.lfMenuFont);
    Font.Color := clMenuText;
    if Font.Name = 'MS Sans Serif' then
      Font.Name := 'Tahoma';
  end;
end;


procedure TXPMenu.DrawGradient(ACanvas: TCanvas; ARect: TRect;
 IsRightToLeft: boolean);
var
  i: integer;
  v: integer;
  FRect: TRect;
begin

  fRect := ARect;
  V := 0;
  if IsRightToLeft then
  begin
    fRect.Left := fRect.Right - 1;
    for i := ARect.Right Downto ARect.Left do
    begin
      if (fRect.Left < ARect.Right)
        and (fRect.Left > ARect.Right - FIconWidth + 5) then
        inc(v, 3)
      else
        inc(v, 1);

      if v > 96 then v := 96;
      ACanvas.Brush.Color := NewColor(ACanvas, FFIconBackColor, v);
      ACanvas.FillRect(fRect);

      fRect.Left := fRect.Left - 1;
      fRect.Right := fRect.Left - 1;
    end;
  end
  else
  begin
    fRect.Right := fRect.Left + 1;
    for i := ARect.Left to ARect.Right do
    begin
      if (fRect.Left > ARect.Left)
        and (fRect.Left < ARect.Left + FIconWidth + 5) then
        inc(v, 3)
      else
        inc(v, 1);

      if v > 96 then v := 96;
      ACanvas.Brush.Color := NewColor(ACanvas, FFIconBackColor, v);
      ACanvas.FillRect(fRect);

      fRect.Left := fRect.Left + 1;
      fRect.Right := fRect.Left + 1;
    end;
  end;
end;


procedure TXPMenu.DrawWindowBorder(hWnd: HWND; IsRightToLeft: boolean);
var
  WRect, CRect: TRect;
  dCanvas: TCanvas;
begin

  if hWnd <= 0 then
  begin
   exit;
  end;
  dCanvas := nil;
  try
  dCanvas := TCanvas.Create;
  dCanvas.Handle := GetDc(0);

  GetClientRect(hWnd, CRect);
  GetWindowRect(hWnd, WRect);

  ExcludeClipRect(dCanvas.Handle, CRect.Left, CRect.Top, CRect.Right,
                  CRect.Bottom);

  dCanvas.Brush.Style := bsClear;


  Dec(WRect.Right, 2);
  Dec(WRect.Bottom, 2);

  dCanvas.Pen.Color := FMenuBorderColor;
  dCanvas.Rectangle(WRect.Left, WRect.Top, WRect.Right, WRect.Bottom);




  if IsRightToLeft then
  begin
    dCanvas.Pen.Color := FFColor;
    dCanvas.Rectangle(WRect.Left + 1, WRect.Top + 1, WRect.Right - 2,
                      WRect.Top + 3);

    dCanvas.MoveTo(WRect.Left + 2, WRect.Top + 2);
    dCanvas.LineTo(WRect.Left + 2, WRect.Bottom - 2);


    dCanvas.Pen.Color := FFIconBackColor;
    dCanvas.MoveTo(WRect.Right - 2, WRect.Top + 2);
    dCanvas.LineTo(WRect.Right - 2, WRect.Bottom - 2);

    dCanvas.MoveTo(WRect.Right - 2, WRect.Top + 2);
    dCanvas.LineTo(WRect.Right - 1 - FIconWidth, WRect.Top + 2);
  end
  else
  begin
    if not FGradient then
    begin
      dCanvas.Pen.Color := FFColor;
      dCanvas.Rectangle(WRect.Left + 1, WRect.Top + 1, WRect.Right - 2,
                        WRect.Top + 3);

      dCanvas.Pen.Color := FFIconBackColor;
      dCanvas.MoveTo(WRect.Left + 1, WRect.Top + 2);
      dCanvas.LineTo(WRect.Left + 2 + FIconWidth, WRect.Top + 2);
    end;

    dCanvas.Pen.Color := FFIconBackColor;
    dCanvas.MoveTo(WRect.Left + 1, WRect.Top + 1);
    dCanvas.LineTo(WRect.Left + 1, WRect.Bottom - 2);


  end;

  Inc(WRect.Right, 2);
  Inc(WRect.Bottom, 2);

  dCanvas.Pen.Color := FMenuShadowColor;
  dCanvas.Rectangle(WRect.Left +2, WRect.Bottom, WRect.Right, WRect.Bottom - 2);
  dCanvas.Rectangle(WRect.Right - 2, WRect.Bottom, WRect.Right, WRect.Top + 2);


  dCanvas.Pen.Color := FFIconBackColor;
  dCanvas.Rectangle(WRect.Left, WRect.Bottom - 2, WRect.Left + 2, WRect.Bottom);
  dCanvas.Rectangle(WRect.Right - 2, WRect.Top, WRect.Right, WRect.Top + 2);
  finally
  IntersectClipRect(dCanvas.Handle, WRect.Left, WRect.Top, WRect.Right, WRect.Bottom);
  dCanvas.Free;
  end;


end;



procedure TXPMenu.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opInsert) and
     ((AComponent is TMenuItem) or (AComponent is TToolButton)) then
  begin
   if (csDesigning in ComponentState) then
     Active := true
   else
     //if ComponentState = [] then
        Active := true ;
  end;


end;


function GetShadeColor(ACanvas: TCanvas; clr: TColor; Value: integer): TColor;
var
  r, g, b: integer;

begin
  clr := ColorToRGB(clr);
  r := Clr and $000000FF;
  g := (Clr and $0000FF00) shr 8;
  b := (Clr and $00FF0000) shr 16;

  r := (r - value);
  if r < 0 then r := 0;
  if r > 255 then r := 255;

  g := (g - value) + 2;
  if g < 0 then g := 0;
  if g > 255 then g := 255;

  b := (b - value);
  if b < 0 then b := 0;
  if b > 255 then b := 255;

  Result := Windows.GetNearestColor(ACanvas.Handle, RGB(r, g, b));
end;

function NewColor(ACanvas: TCanvas; clr: TColor; Value: integer): TColor;
var
  r, g, b: integer;

begin
  if Value > 100 then Value := 100;
  clr := ColorToRGB(clr);
  r := Clr and $000000FF;
  g := (Clr and $0000FF00) shr 8;
  b := (Clr and $00FF0000) shr 16;


  r := r + Round((255 - r) * (value / 100));
  g := g + Round((255 - g) * (value / 100));
  b := b + Round((255 - b) * (value / 100));

  Result := Windows.GetNearestColor(ACanvas.Handle, RGB(r, g, b));

end;

function GrayColor(ACanvas: TCanvas; clr: TColor; Value: integer): TColor;
var
  r, g, b, avg: integer;

begin
  if Value > 100 then Value := 100;
  clr := ColorToRGB(clr);
  r := Clr and $000000FF;
  g := (Clr and $0000FF00) shr 8;
  b := (Clr and $00FF0000) shr 16;
  Avg := (r + g + b) div 3;
  Avg := Avg + Value;
  if Avg > 240 then Avg := 240;

  Result := Windows.GetNearestColor (ACanvas.Handle,RGB(Avg, avg, avg));
end;

procedure GrayBitmap(ABitmap: TBitmap; Value: integer);
var
  x, y: integer;
  LastColor1, LastColor2, Color: TColor;
begin
  LastColor1 := 0;
  LastColor2 := 0;

  for y := 0 to ABitmap.Height do
    for x := 0 to ABitmap.Width do
    begin
      Color := ABitmap.Canvas.Pixels[x, y];
      if Color = LastColor1 then
        ABitmap.Canvas.Pixels[x, y] := LastColor2
      else
      begin
        LastColor2 := GrayColor(ABitmap.Canvas , Color, Value);
        ABitmap.Canvas.Pixels[x, y] := LastColor2;
        LastColor1 := Color;
      end;
    end;
end;

procedure DimBitmap(ABitmap: TBitmap; Value: integer);
var
  x, y: integer;
  LastColor1, LastColor2, Color: TColor;
begin
  if Value > 100 then Value := 100;
  LastColor1 := -1;
  LastColor2 := -1;

  for y := 0 to ABitmap.Height - 1 do
    for x := 0 to ABitmap.Width - 1 do
    begin
      Color := ABitmap.Canvas.Pixels[x, y];
      if Color = LastColor1 then
        ABitmap.Canvas.Pixels[x, y] := LastColor2
      else
      begin
        LastColor2 := NewColor(ABitmap.Canvas, Color, Value);
        ABitmap.Canvas.Pixels[x, y] := LastColor2;
        LastColor1 := Color;
      end;
    end;
end;

procedure DrawBitmapShadow(B: TBitmap; ACanvas: TCanvas; X, Y: integer;
  ShadowColor: TColor);
var
  BX, BY: integer;
  TransparentColor: TColor;
begin
  TransparentColor := B.Canvas.Pixels[0, B.Height - 1];
  for BY := 0 to B.Height - 1 do
    for BX := 0 to B.Width - 1 do
    begin
      if B.Canvas.Pixels[BX, BY] <> TransparentColor then
        ACanvas.Pixels[X + BX, Y + BY] := ShadowColor;

    end;
end;

end.

