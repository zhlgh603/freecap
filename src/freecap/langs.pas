{
  $Id: langs.pas,v 1.3 2005/02/15 11:21:21 bert Exp $

  $Log: langs.pas,v $
  Revision 1.3  2005/02/15 11:21:21  bert
  *** empty log message ***

}
unit langs;

interface
uses Windows, Classes, SysUtils, Controls, StdCtrls, ComCtrls, ExtCtrls, Menus,
     Forms, inifiles, textlangs;

type
    TLangs = class(TCustomLangs)
    public
      function GetLangRec(LangID, SublangId: DWORD): TSupLang; override;
      procedure ChangeLang(frm: TForm; LangID, SublangId: DWORD);
      procedure SwitchAllFormsTo(LangID, SublangID: DWORD);
    end;

    procedure SaveText(frm: TForm; LangID, SublangId: DWORD);
    procedure Init;
    procedure Fini;

var
   SupportedLangs: TLangs;

implementation

type
    TCustControl = class(TControl)
    public
      property Caption;
      property Hint;
    end;

var
   Languages: TLanguages;


procedure SaveText(frm: TForm; LangID, SublangId: DWORD);
var
   i, j, k: integer;
   IniFile: TIniFile;
   Comp: TComponent;
   Buffer: array[0..255] of Char;

   procedure PutValue(ident, value: string);
   var
      val : string;
   begin
          IniFile.WriteString(frm.Name, Ident, Value);
   end;
begin
     IniFile := TIniFile.Create('C:\freecap.lng');
     IniFile.WriteString('Common', 'Language', Format('$%x', [ MAKELANGID(LangId, SublangId) ] ));


     IniFile.WriteInteger('Common', 'LangId', LangId);
     IniFile.WriteInteger('Common', 'SublangId', SublangId);

     PutValue(frm.Name + '.Caption', frm.Caption);

     for i := 0 to frm.ComponentCount - 1 do
     begin
          Comp := frm.Components[i];
          if (Comp is TMenuItem) then
          begin
               with TMenuItem(Comp) do
               begin
                    if Name = '' then
                       continue;
                    if (Caption <> '') and (Caption <> '-')  then
                      PutValue(Name + '.Caption', Caption);
                    if (Hint <> '') and (Hint <> '-') then
                      PutValue(Name + '.Hint', Hint);
               end;
          end
          else if (Comp is TControl) then
          begin
               with TCustControl(Comp) do
               begin
                    if (Caption <> '') then
                      PutValue(Name + '.Caption', Caption);
                    if (Hint <> '') then
                      PutValue(Name + '.Hint', Hint);
               end;

               if (Comp is TListView) then
               begin
                    for j := 0 to TListView(Comp).Columns.Count - 1 do
                    begin
                         PutValue(Format('%s.Item[%d]', [Comp.Name, j]), TListView(Comp).Columns[j].Caption);
                    end;
               end
               else if (Comp is TTreeView) then
               begin
                    for j := 0 to TTreeView(Comp).Items.Count - 1 do
                    begin
                         PutValue(Format('%s.Item[%d]', [Comp.Name, j]), TTreeView(Comp).Items[j].Text);
                    end;
               end
               else if (Comp is TRadioGroup) then
               begin
                    for j := 0 to TRadioGroup(Comp).Items.Count - 1 do
                    begin
                         PutValue(Format('%s.Item[%d]', [Comp.Name, j]), TRadioGroup(Comp).Items[j]);
                    end;
               end
               else if (Comp is TListBox) then
               begin
                    for j := 0 to TListBox(Comp).Items.Count - 1 do
                    begin
                         PutValue(Format('%s.Item[%d]', [Comp.Name, j]), TListBox(Comp).Items[j]);
                    end;
               end;
          end;
     end;
     IniFile.Free;
end;





procedure TLangs.ChangeLang(frm: TForm; LangID, SublangId: DWORD);
var
   i, j, k: integer;
   IniFile: TIniFile;
   Comp: TComponent;
   LangRec: TSupLang;
begin
     LangRec := GetLangRec(LangID, SublangId);
     IniFile := TIniFile.Create(LangRec.LangFileName);
     frm.Caption := IniFile.ReadString(frm.Name, frm.Name + '.Caption', frm.Caption);

     for i := 0 to frm.ComponentCount - 1 do
     begin
          Comp := frm.Components[i];
          if (Comp is TMenuItem) then
          begin
               with TMenuItem(Comp) do
               begin
                    Caption := IniFile.ReadString(frm.Name, Name + '.Caption', Caption);
                    Hint := IniFile.ReadString(frm.Name, Name + '.Hint', Hint);
               end;
          end
          else if (Comp is TControl) then
          begin
               with TCustControl(Comp) do
               begin
                    Caption := IniFile.ReadString(frm.Name, Name + '.Caption', Caption);
                    Hint := IniFile.ReadString(frm.Name, Name + '.Hint', Hint);
               end;

               if (Comp is TListView) then
               begin
                    for j := 0 to TListView(Comp).Columns.Count - 1 do
                    begin
                         TListView(Comp).Columns[j].Caption := IniFile.ReadString(frm.Name, Format('%s.Item[%d]', [Comp.Name, j]), TListView(Comp).Columns[j].Caption);
//                         for k := 0 to TListView(Comp).Items[j].SubItems.Count - 1 do
//                            TListView(Comp).Items[j].SubItems[k] := IniFile.ReadString(frm.Name, Format('%s.Item[%d].SubItem[%d]', [Comp.Name, j, k]), TListView(Comp).Items[j].SubItems[k]);
                    end;
               end
               else if (Comp is TTreeView) then
               begin
                    for j := 0 to TTreeView(Comp).Items.Count - 1 do
                    begin
                         TTreeView(Comp).Items[j].Text := IniFile.ReadString(frm.Name, Format('%s.Item[%d]', [Comp.Name, j]), TTreeView(Comp).Items[j].Text);
                    end;
               end
               else if (Comp is TRadioGroup) then
               begin
                    for j := 0 to TRadioGroup(Comp).Items.Count - 1 do
                       TRadioGroup(Comp).Items[j] := IniFile.ReadString(frm.Name, Format('%s.Item[%d]', [Comp.Name, j]), TRadioGroup(Comp).Items[j]);
               end
               else if (Comp is TListBox) then
               begin
                    for j := 0 to TListBox(Comp).Items.Count - 1 do
                    begin
                         TListBox(Comp).Items[j] := IniFile.ReadString(frm.Name, Format('%s.Item[%d]', [Comp.Name, j]), TListBox(Comp).Items[j]);
                    end;
               end;

          end;
     end;

     frm.Repaint;
     IniFile.Free;
end;



function TLangs.GetLangRec(LangID, SublangId: DWORD): TSupLang;
begin
     result := inherited GetLangRec(LangID, SublangId);
end;

procedure TLangs.SwitchAllFormsTo(LangID, SublangID: DWORD);
var
   i: integer;
begin
     for i:=0 to Screen.FormCount - 1 do
       if Screen.Forms[i].Tag = 0 then
          ChangeLang(Screen.Forms[i], LangID, SublangID);
end;


procedure Init;
begin
  SupportedLangs := TLangs.Create(GetLangsDir());
end;


procedure Fini;
begin
  SupportedLangs.Free;
end;

end.
