(*******************************************************************************

 XP Tree View v1.0 (c) 2001 Transpear Software

 Coding by Kelvin Westlake

 Contact:  Http://www.transpear.net
          kwestlake@yahoo.com

 Please read enclosed License.txt before continuing any further,  you may also
 find some useful information in the Readme.txt.

  Usage:

  Drop it on a form,  set the colors and use it.

  This tree can also accept OLE drag input from the shell,  if you wish to use
  this feature simple set a handler for the OnFileDrop event, this event
  will return a StringList containing the files name and the XY coordinates so
  that you may find the node located at that position.

  PLEASE NOTE:

  Only BorderColor and BackHiColor are used.

  Known Problems:

  The border flickers when the box is resized.

*******************************************************************************)





unit XP_Tree;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls,shellAPI,XP_Color,Extctrls;

Type TOnDropFile = Procedure (Sender : TObject; Files : TStringList; X,Y : Integer)of object;

Type TtfXPTreeView = Class (TTreeView)
private
  FOnFileDrop : TOnDropFile;
  FColors : TtfXPColor;
  Procedure DrawBorder;
  Procedure Paint(VAR Message : TMessage); message WM_PAINT;
  Procedure ColorChange(sender : TObject);
  Procedure SetBorderColor(newCol : TColor);
  Function GetBorderColor: TColor;
  procedure WMDropFiles ( var Msg : TMessage ) ; message WM_DropFiles;
Protected
  procedure Resize; override;
public
  FileList : TStringList;
  constructor Create(AOwner : TComponent); override;
Published
  property OnFileDrop:TOnDropFile read FOnFileDrop write FOnFileDrop;
  property BorderColor:TColor read GetBorderColor write SetBorderColor default $006B2408;
end;

procedure Register;

implementation

constructor TtfXPTreeView.Create(AOwner : TComponent);
begin
 FColors:=ttfXPColor.create(self);
 inherited Create(AOwner);
 Parent:=TWinControl(AOwner);
 DragAcceptFiles(Handle,True);
 fColors.BackHiColor:=clWindow;
 BorderColor:=$006B2408;
 fColors.OnChange:=ColorChange;
End;

Procedure TtfXPTreeView.SetBorderColor(newCol : TColor);
Begin
  FColors.BorderColor:=newCol;
End;

Function TtfXPTreeView.GetBorderColor: TColor;
Begin
  Result:=  FColors.BorderColor;
End;



procedure TtfXPTreeView.WMDropFiles ( var Msg : TMessage ) ;
var
   hDrop : THandle ;
   fName : array [0..Max_Path] of char;
   FileCount : integer;
   i : integer;
   p : TPoint;
   Backup : TTVChangedEvent;
begin
   // The onchange Event gets called by this message,  so we must
   // disable it while the File Drop is seen to -
   BackUp := OnChange; OnChange:=nil;  //  this ensures no unpleasant suprises
   FileList.free;
   FileList:=TStringList.Create;
   hDrop := Msg.WParam ;
   FileCount := DragQueryFile(hDrop,$FFFFFFFF,nil,254);
   for i := 0 to FileCount-1 do
   begin
      DragQueryFile(hDrop,i,fName,254);
      FileList.Add(String(fName));
   end;
   DragQueryPoint(hDrop,p);
   Selected:=GetNodeAt(p.x,p.y);
   DragFinish ( hDrop);
   If Assigned(FonFileDrop) Then FOnFileDrop(self,FileList,p.x,p.y);
   OnChange:=BackUp;    // Restore the Onchange .. Quick'n'dirty but it works ..
end;

Procedure TtfXPTreeView.ColorChange(sender : TObject);
Begin
 repaint;
End;

PROCEDURE TtfXPTreeView.DrawBorder;
VAR DC : HDC;
    R : TRect;
    t : TCanvas;
BEGIN
 t:=tcanvas.Create;
 DC := GetWindowDC(Handle);
 t.handle:=dc;
 TRY
  GetWindowRect(Handle, R);
  OffsetRect(R, -R.Left, -R.Top);
  color:=fColors.BackHiColor;
  Frame3D(t,r,fColors.BorderColor,fColors.BorderColor,1);
   Frame3D(t,r,Color,Color,1);
  FINALLY
    ReleaseDC (Handle, DC);
    t.handle:=0;
  END;
END;

Procedure TtfXPTreeView.Paint(var Message : TMessage);
Begin
 Inherited;
 DrawBorder;
End;

Procedure TtfXPTreeView.Resize;
Var ARect : Trect;
Begin
  inherited resize;
  Arect:=self.ClientRect;
InvalidateRect(handle,@Arect,False);
End;

procedure Register;
begin
  RegisterComponents('Transpear XP', [TtfXPTreeView]);
end;

end.

