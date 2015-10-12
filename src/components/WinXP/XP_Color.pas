(*******************************************************************************

 XP Color Class (c) 2001 Transpear Software

 Coding by Kelvin Westlake

 Contact:  Http://www.transpear.net
          kwestlake@yahoo.com

 Please read enclosed License.txt before continuing any further,  you may also
 find some useful information in the Readme.txt.

 Usage:

 Non - this class is only instantiated by some of the different Transpear
 XP Controls to give a persistance feel of color attributes.

*******************************************************************************)



unit XP_Color;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls,Extctrls;

Type
  TtfXPColor = Class(TPersistent)
  Private
    FOnChange: TNotifyEvent;
    FBorderColor : TColor;
    FInnerColor  : TColor;
    FBackColor   : TColor;
    FShadowColor : TColor;
    Procedure SetBorderCol(const Col : TColor);
    Procedure SetInnerCol(const Col : TColor);
    Procedure SetBackCol(const Col : TColor);
    Procedure SetShadowCol(const Col : TColor);
  Protected
  Public
    Constructor create(AOwner : TComponent);
  Published
     property OnChange:TNotifyEvent read FOnChange write FOnChange;
     property BorderColor:TColor read FBorderColor write SetBorderCol default $006B2408; //$009C7173;
     property BackColor:TColor   read FBackColor   write SetBackCol   default clBtnFace;
     property BackHiColor:TColor read FInnerColor  write SetInnerCol  default $00D6BEB5; //$00E7D3CE;
     property ShadowColor:TColor read FShadowColor  write SetShadowCol  default $00848284;// clGray;
  End;

implementation



Constructor TtfXPColor.create(AOwner : TComponent);
Begin
  FBorderColor:=$006B2408;//$009C7173;
  FInnerColor:=$00D6BEB5;;//$00E7D3CE;
  FBackColor:=clBtnFace;
  fShadowColor:=$00848284;//clGray;
End;

Procedure TtfXPColor.SetBorderCol(const Col : TColor);
Begin
  FBorderColor:=Col;
  if Assigned(FOnChange) then
    FOnChange(self);
end;

Procedure TtfXPColor.SetInnerCol(const Col : TColor);
Begin
  FInnerColor:=Col;
  if Assigned(FOnChange) then
    FOnChange(self);
end;

Procedure TtfXPColor.SetBackCol(const Col : TColor);
Begin
 FBackColor:=Col;
  if Assigned(FOnChange) then
    FOnChange(self);
end;

Procedure TtfXPColor.SetShadowCol(const Col : TColor);
Begin
  FShadowColor:=Col;
  if Assigned(FOnChange) then
    FOnChange(self);
end;

end.
 