(*******************************************************************************

 XP Utils (c) 2001 Transpear Software

 Coding by Kelvin Westlake

 Contact:  Http://www.transpear.net
          kwestlake@yahoo.com

 Please read enclosed License.txt before continuing any further,  you may also
 find some useful information in the Readme.txt.

 Usage:

 None - these functions are not actually exported, they are used internally by
 the different XP component controls.

*******************************************************************************)

unit XP_Utils;

interface

uses
  Windows, SysUtils, Classes, Graphics, Dialogs, stdctrls;

function CreateRotatedFont(F: TFont; Angle: Integer): hFont;

Procedure HorizGradient(Canvas : TCanvas; ARect : TRect;
                                        StartCol, Endcol : TColor);
Procedure VerticalGradient(Canvas : TCanvas; ARect : TRect;  Width,Height : Integer;
                                        StartCol, Endcol : TColor);

function removechar(str : string; ch : char; var Idx : Integer):string;

function CreateRegionFromBitmap(hBmp: TBitmap; TransColor: TColor): HRGN;

Function DefMessageDlg(const aCaption: String;
                       const Msg: string;
                       DlgType: TMsgDlgType;
                       Buttons: TMsgDlgButtons;
                       DefButton: Integer;
                       HelpCtx: Longint): Integer;



implementation

function CreateRotatedFont(F: TFont; Angle: Integer): hFont;
var
  LF : TLogFont;
begin
  FillChar(LF, SizeOf(LF), #0);
  with LF do
  begin
    lfHeight := F.Height;
    lfWidth := 0;
    lfEscapement := Angle*10;
    lfOrientation := 0;
    if fsBold in F.Style then
      lfWeight := FW_BOLD
    else
      lfWeight := FW_NORMAL;
    lfItalic := Byte(fsItalic in F.Style);
    lfUnderline := Byte(fsUnderline in F.Style);
    lfStrikeOut := Byte(fsStrikeOut in F.Style);
    lfCharSet := DEFAULT_CHARSET;
    StrPCopy(lfFaceName, F.Name);
    lfQuality := DEFAULT_QUALITY;
    lfOutPrecision := OUT_DEFAULT_PRECIS;
    lfClipPrecision := CLIP_DEFAULT_PRECIS;
    case F.Pitch of
      fpVariable: lfPitchAndFamily := VARIABLE_PITCH;
      fpFixed: lfPitchAndFamily := FIXED_PITCH;
    else
      lfPitchAndFamily := DEFAULT_PITCH;
    end;
  end;
  Result := CreateFontIndirect(LF);
end;

Procedure HorizGradient(Canvas : TCanvas; ARect : TRect;
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
      for i := 0 to (Arect.Right-arect.left) do  // Draw gradient to Length
      begin
        canvas.Brush.Color := RGB(
          (rc1 + (((rc2 - rc1) * (ARect.left + i)) div arect.right-arect.left)),
          (gc1 + (((gc2 - gc1) * (ARect.left + i)) div arect.right-arect.left)),
          (bc1 + (((bc2 - bc1) * (ARect.left + i)) div arect.right-arect.left)));
          canvas.FillRect(Rect(Arect.Left+i, Arect.Top,
                          (Arect.Right-Arect.Left)+i, Arect.Bottom));
      end;
    end;
End;

Procedure VerticalGradient(Canvas : TCanvas; ARect : TRect;  Width,Height : Integer;
                                        StartCol, Endcol : TColor);
Var rc1, rc2, gc1, gc2, bc1, bc2: Byte;
    ColorStart, ColorEnd: Longint;
    i : Integer;
Begin
      ColorStart := ColorToRGB(StartCol);
      ColorEnd := ColorToRGB(EndCol);
      rc1 := GetRValue(ColorStart);
      gc1 := GetGValue(ColorStart);
      bc1 := GetBValue(ColorStart);
      rc2 := GetRValue(ColorEnd);
      gc2 := GetGValue(ColorEnd);
      bc2 := GetBValue(ColorEnd);
      for i := 0 to (ARect.Bottom - ARect.Top) do
       if Height>0 then
      begin
        Canvas.Brush.Color := RGB(
          (rc1 + (((rc2 - rc1) * (ARect.Top + i)) div Height)),
          (gc1 + (((gc2 - gc1) * (ARect.Top + i)) div Height)),
          (bc1 + (((bc2 - bc1) * (ARect.Top + i)) div Height)));
//        Canvas.FillRect(Rect(0, ARect.Top + i, Width - 2, ARect.Top + i + 1));
        Canvas.FillRect(Rect(0, ARect.Top + i, Width - 2, ARect.Top + i + 1));
      end;
    end;


function removechar(str : string; ch : char; var Idx : Integer):string;
var c,c1,c2 : Integer;
begin
c2:=0;
Idx:=-1;
 For c:=0 To Length(Str) Do
 Begin
  IF str[c]='&' Then
  Begin
   If Idx=-1 Then Idx:=c;
   For c1:=c To Length(Str)-1 Do
   Begin
     Str[c1]:=Str[c1+1];
    End;
     inc(c2);
   End;
  End;
  SetLength(str,Length(str)-c2);
  result:=str;
end;

function CreateRegionFromBitmap(hBmp: TBitmap; TransColor: TColor): HRGN;
const
  ALLOC_UNIT = 100;
  Tolerance = 0;
var
  MemDC, DC: HDC;
  BitmapInfo: TBitmapInfo;
  hbm32, holdBmp, holdMemBmp: HBitmap;
  pbits32 : Pointer;
  bm32 : BITMAP;
  maxRects: DWORD;
  hData: HGLOBAL;
  pData: PRgnData;
  b, LR, LG, LB, HR, HG, HB: Byte;
  p32: pByte;
  x, x0, y: integer;
  p: pLongInt;
  pr: PRect;
  h: HRGN;

     function MinByte(B1, B2: byte): byte;
     begin
      if B1 < B2 then
        Result := B1
      else
        Result := B2;
      end;


begin
  Result := 0;
  if hBmp <> nil then
  begin
    { Create a memory DC inside which we will scan the bitmap contents }
    MemDC := CreateCompatibleDC(0);
    if MemDC <> 0 then
    begin
     { Create a 32 bits depth bitmap and select it into the memory DC }
      with BitmapInfo.bmiHeader do
      begin
        biSize          := sizeof(TBitmapInfoHeader);
        biWidth         := hBmp.Width;
        biHeight        := hBmp.Height;
        biPlanes        := 1;
        biBitCount      := 32;
        biCompression   := BI_RGB; { (0) uncompressed format }
        biSizeImage     := 0;
        biXPelsPerMeter := 0;
        biYPelsPerMeter := 0;
        biClrUsed       := 0;
        biClrImportant  := 0;
      end;
      hbm32 := CreateDIBSection(MemDC, BitmapInfo, DIB_RGB_COLORS, pbits32,0, 0);
      if hbm32 <> 0 then
      begin
        holdMemBmp := SelectObject(MemDC, hbm32);
        {
          Get how many bytes per row we have for the bitmap bits
          (rounded up to 32 bits)
        }
        GetObject(hbm32, SizeOf(bm32), @bm32);
        while (bm32.bmWidthBytes mod 4) > 0 do
          inc(bm32.bmWidthBytes);
        DC := CreateCompatibleDC(MemDC);
        { Copy the bitmap into the memory DC }
        holdBmp := SelectObject(DC, hBmp.Handle);
        BitBlt(MemDC, 0, 0, hBmp.Width, hBmp.Height, DC, 0, 0, SRCCOPY);
        {
          For better performances, we will use the ExtCreateRegion() function
          to create the region. This function take a RGNDATA structure on
          entry. We will add rectangles by
          amount of ALLOC_UNIT number in this structure
        }
        maxRects := ALLOC_UNIT;
        hData := GlobalAlloc(GMEM_MOVEABLE, sizeof(TRgnDataHeader) +
           SizeOf(TRect) * maxRects);
        pData := GlobalLock(hData);
        pData^.rdh.dwSize := SizeOf(TRgnDataHeader);
        pData^.rdh.iType := RDH_RECTANGLES;
        pData^.rdh.nCount := 0;
        pData^.rdh.nRgnSize := 0;
        SetRect(pData^.rdh.rcBound, MaxInt, MaxInt, 0, 0);
        { Keep on hand highest and lowest values for the "transparent" pixel }
        LR := GetRValue(ColorToRGB(TransColor));
        LG := GetGValue(ColorToRGB(TransColor));
        LB := GetBValue(ColorToRGB(TransColor));
        { Add the value of the tolerance to the "transparent" pixel value }
        HR := MinByte($FF, LR + GetRValue(ColorToRGB(Tolerance)));
        HG := MinByte($FF, LG + GetGValue(ColorToRGB(Tolerance)));
        HB := MinByte($FF, LB + GetBValue(ColorToRGB(Tolerance)));
        {
          Scan each bitmap row from bottom to top,
          the bitmap is inverted vertically
        }
        p32 := bm32.bmBits;
        inc(PChar(p32), (bm32.bmHeight - 1) * bm32.bmWidthBytes);
        for y := 0 to hBmp.Height-1 do
        begin
          { Scan each bitmap pixel from left to right }
          x := -1;
          while x+1 < hBmp.Width do
          begin
            inc(x);
            { Search for a continuous range of "non transparent pixels" }
            x0 := x;
            p := PLongInt(p32);
            inc(PChar(p), x * SizeOf(LongInt));
            while x < hBmp.Width do
            begin
              b := GetBValue(p^);                 // Changed from GetRValue(p^)
              if (b >= LR) and (b <= HR) then
              begin
                b := GetGValue(p^);               // Left alone
                if (b >= LG) and (b <= HG) then
                begin
                  b := GetRValue(p^);             // Changed from GetBValue(p^)
                  if (b >= LB) and (b <= hb) then
                    { This pixel is "transparent" }
                    break;
                end;
              end;
              inc(PChar(p), SizeOf(LongInt));
              inc(x);
            end;
            if x > x0 then
            begin
              {
                Add the pixels (x0, y) to (x, y+1) as a new rectangle in
                the region
              }
              if pData^.rdh.nCount >= maxRects then
              begin
                GlobalUnlock(hData);
                inc(maxRects, ALLOC_UNIT);
                hData := GlobalReAlloc(hData, SizeOf(TRgnDataHeader) +
                   SizeOf(TRect) * maxRects, GMEM_MOVEABLE);
                pData := GlobalLock(hData);
                Assert(pData <> NIL);
              end;
              pr := @pData^.Buffer[pData^.rdh.nCount * SizeOf(TRect)];
              SetRect(pr^, x0, y, x, y+1);
              if x0 < pData^.rdh.rcBound.Left then
                pData^.rdh.rcBound.Left := x0;
              if y < pData^.rdh.rcBound.Top then
                pData^.rdh.rcBound.Top := y;
              if x > pData^.rdh.rcBound.Right then
                pData^.rdh.rcBound.Left := x;
              if y+1 > pData^.rdh.rcBound.Bottom then
                pData^.rdh.rcBound.Bottom := y+1;
              inc(pData^.rdh.nCount);
              {
               On Windows98, ExtCreateRegion() may fail if the number of
               rectangles is too large (ie: > 4000). Therefore, we have to
               create the region by multiple steps
              }
              if pData^.rdh.nCount = 2000 then
              begin
                h := ExtCreateRegion(NIL, SizeOf(TRgnDataHeader) +
                   (SizeOf(TRect) * maxRects), pData^);
                Assert(h <> 0);
                if Result <> 0 then
                begin
                  CombineRgn(Result, Result, h, RGN_OR);
                  DeleteObject(h);
                end else
                  Result := h;
                pData^.rdh.nCount := 0;
                SetRect(pData^.rdh.rcBound, MaxInt, MaxInt, 0, 0);
              end;
            end;
          end;
          {
            Go to next row (remember, the bitmap is inverted vertically)
            that is why we use DEC!
          }
          Dec(PChar(p32), bm32.bmWidthBytes);
        end;
        { Create or extend the region with the remaining rectangle }
        h := ExtCreateRegion(NIL, SizeOf(TRgnDataHeader) +
           (SizeOf(TRect) * maxRects), pData^);
        Assert(h <> 0);
        if Result <> 0 then
        begin
          CombineRgn(Result, Result, h, RGN_OR);
          DeleteObject(h);
        end else
          Result := h;
        { Clean up }
        GlobalFree(hData);
        SelectObject(DC, holdBmp);
        DeleteDC(DC);
        DeleteObject(SelectObject(MemDC, holdMemBmp));
      end;
    end;
    DeleteDC(MemDC);
  end;
end;


Function DefMessageDlg(const aCaption: String;      // Thank you Peter Below ;)
                       const Msg: string;
                       DlgType: TMsgDlgType;
                       Buttons: TMsgDlgButtons;
                       DefButton: Integer;
                       HelpCtx: Longint): Integer;
Var
  i: Integer;
  btn: TButton;
Begin
  With CreateMessageDialog(Msg, DlgType, Buttons) Do
  try
    Caption := aCaption;
    HelpContext := HelpCtx;
    For i := 0 To ComponentCount-1 Do Begin
      If Components[i] Is TButton Then Begin
        btn := TButton(Components[i]);
        btn.Default:= btn.ModalResult = DefButton;
        If btn.Default Then
          ActiveControl := Btn;
      End;
    End; { For }
    Result := ShowModal;
  finally
    Free;
  end;
End;



end.
