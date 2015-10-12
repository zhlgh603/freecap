{*
 * File: ...................... xml_config.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev,
 * Desc: ...................... XML configuration support

 $Id: xml_config.pas,v 1.6 2005/04/26 04:52:19 bert Exp $

 $Log: xml_config.pas,v $
 Revision 1.6  2005/04/26 04:52:19  bert
 *** empty log message ***

 Revision 1.5  2005/04/06 04:58:56  bert
 *** empty log message ***

 Revision 1.4  2005/03/08 16:38:50  bert
 *** empty log message ***

 Revision 1.3  2005/03/03 23:09:27  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit xml_config;

interface
uses Windows, Classes, SysUtils, janXMLParser2, misc, registry, abs_config;

const
     PART_MAIN = 0;
     PART_PROGRAMS = 1;
     PART_SOCKSCHAIN = 2;
     PART_DIRECTADDR = 3;
     PART_DIRECTPORT = 4;

type
    TXMLConfig = class(TAbstractConfig)
    private
      FFileName: string;
      FXMLDOM: TjanXMLParser2;
      function GetSection(Section: String): TjanXMLNode2;
      function ReadMainString(Section, Ident: string): string;

      // in old format 'Section' equals to program name
      function ReadProgramsString(Section, Ident: string): string;

      // in old format 'Section' equals to hostname
      function ReadSocksChainString(Section, Ident: string): string;

      procedure WriteMainString(Section, Ident, Value: string);

      procedure WriteProgramsString(Section, Ident, Value: string);
      procedure WriteSocksChainString(Section, Ident, Value: string);

      procedure ReadMainSections(Section: string; Strings: TStrings);

      procedure ReadNamedSections(Section: string; Strings: TStrings);

      procedure ReadMainSectionValues(Section: string; Strings: TStrings);
      procedure ReadProgramsSectionValues(Section: string;
        Strings: TStrings);
      procedure ReadSocksChainSectionValues(Section: string;
        Strings: TStrings);

      procedure DeleteMainKey(Section, Ident: string);
      procedure DeleteProgramsKey(Section, Ident: string);
      procedure DeleteSocksChainKey(Section, Ident: string);
      procedure EraseMainSection(SecName, Section: string);
      procedure EraseProgramsSection(const Section: string);
      procedure EraseSocksChainSection(const Section: string);
    public
      constructor Create(AFileName: string);override;
      destructor Destroy; override;

      procedure Clear;

      procedure DeleteKey(Part: integer; const Section, Ident: String);override;
      procedure EraseSection(Part: integer; const Section: string);override;
      procedure ReadSections(Part: integer; Strings: TStrings);override;
      procedure ReadSectionValues(Part: integer; const Section: string; Strings: TStrings); override;

      procedure UpdateFile;

      function ReadString(Part: integer; Section, Ident: string; DefaultValue: string): string;override;
      function ReadInteger(Part: integer; Section, Ident: string; DefaultValue: integer): integer;override;
      function ReadBool(Part: integer; Section, Ident: string; DefaultValue: Boolean): Boolean;override;

      procedure WriteString(Part: integer; Section, Ident, Value: string);override;
      procedure WriteBool(Part: integer; Section, Ident: string; Value: Boolean);override;
      procedure WriteInteger(Part: integer; Section, Ident: string; Value: integer);override;

    end;

    function GetFreecapInstallDir(checkRegistryOnly : Boolean = False): string;
    procedure SetFreecapInstallDir(Value: string);
    function GetFreeCapConfig(): string;


implementation

// TXMLConfig


function GetFreecapInstallDir(checkRegistryOnly : Boolean): string;
var
   Buf: array[1..MAX_PATH] of Char;
   buff: string;
   res: integer;
begin
     ZeroMemory(@Buf, SizeOF(Buf));
     res := GetEnvironmentVariable('FreeCAPConfigFile', @Buf, SizeOF(Buf));

     if (res <> 0) and (res <= SizeOF(Buf)) then
     begin
          buff := String(Buf);
          result := ExtractFilePath(buff);
          while pos('\\', result) > 0 do
            Delete(result, pos('\\', result), 1);
     end
     else
       result := ExtractFilePath(paramstr(0));
end;

function GetFreeCapConfig(): string;
begin
     result := GetFreecapInstallDir() + '\freecap.xml';
end;

procedure SetFreecapInstallDir(Value: string);
var
   Reg: TRegIniFIle;
begin
     Reg := TRegIniFIle.Create;
     Reg.RootKey := HKEY_CURRENT_USER;
     Reg.OpenKey('Software\Bert''s Software\FreeCap', True);
     Reg.WriteString('', 'FreeCapInstallDir', Value);
     Reg.Free;
end;


constructor TXMLConfig.Create(AFileName: string);
var
   bOldUsed: Boolean;
begin
     bOldUsed := False;
     if ExtractFilePath(AFileName) = '' then
       AFileName := GetFreeCapConfig();

     FFileName := AFileName;

     FXMLDOM := TjanXMLParser2.Create();
     FXMLDOM.name := 'freecap';

     if FileExists(FFileName) then
       FXMLDOM.LoadXML(FFileName)
     else
       FXMLDOM.xml := '<?xml version="1.0" encoding="UTF-8"?><freecap></freecap>';


     if bOldUsed then
       FFileName := GetFreeCapConfig();
end;

destructor TXMLConfig.Destroy;
begin
     if not IsLibrary then
        UpdateFile;

     FXMLDOM.Free;
     inherited;
end;


function TXMLConfig.ReadMainString(Section, Ident: string): string;
var
   Sect, Item: TjanXMLNode2;
   i         : integer;
begin
     Sect := GetSection(Section);
     if Sect = nil then
        exit;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          if item.attribute['name'] = Ident then
          begin
               result := item.attribute['value'];
               exit;
          end;
     end;
end;


function TXMLConfig.ReadProgramsString(Section, Ident: string): string;
var
   Sect: TjanXMLNode2;
   Item: TjanXMLNode2;
   i   : integer;
begin
     Sect := GetSection('programs');
     if Sect = nil then
        exit;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          if item.attribute['name'] = Section then
          begin
               result := item.attribute[Ident];
               exit;
          end;
     end;
end;


function TXMLConfig.ReadSocksChainString(Section, Ident: string): string;
var
   Sect: TjanXMLNode2;
   Item, Subitem: TjanXMLNode2;
   i,j : integer;
begin
     Sect := GetSection('sockschain');
     if Sect = nil then
        exit;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          if item.attribute['name'] = Section then
          begin
               for j := 0 to item.nodes.Count - 1 do
               begin
                    SubItem := TjanXMLNode2(item.nodes.Items[j]);
                    if SubItem.attribute['name'] = Ident then
                    begin
                         result := Subitem.attribute['value'];
                         exit;
                    end;
               end
          end;
     end;
end;


procedure TXMLConfig.WriteMainString(Section, Ident, Value: string);
var
   Sect: TjanXMLNode2;
   Item: TjanXMLNode2;
   i   : integer;
begin
     Sect := GetSection(Section);
     if Sect = nil then
     begin
          Sect := TjanXMLNode2.Create;
          Sect.name := Section;
          FXMLDOM.addNode(Sect);
     end;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          if item.attribute['name'] = Ident then
          begin
               item.attribute['value'] := Value;
               exit;
          end;
     end;

     Item := TjanXMLNode2.Create();
     Sect.addNode(Item);
     Item.text := '';
     Item.name := 'param';
     Item.attribute['name'] := Ident;
     Item.attribute['value'] := Value;
end;

procedure TXMLConfig.WriteProgramsString(Section, Ident, Value: string);
var
   Sect: TjanXMLNode2;
   Item: TjanXMLNode2;
   i   : integer;
begin
     Sect := GetSection('programs');
     if Sect = nil then
     begin
          Sect := TjanXMLNode2.Create;
          Sect.name := 'programs';
          FXMLDOM.addNode(Sect);
     end;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          if item.attribute['name'] = Section then
          begin
               item.attribute[Ident] := Value;
               exit;
          end;
     end;
     Item := TjanXMLNode2.Create();
     Sect.addNode(Item);
     Item.text := '';
     Item.name := 'entry';
     Item.attribute['name'] := Section;
     Item.attribute[Ident] := Value;
end;

procedure TXMLConfig.WriteSocksChainString(Section, Ident, Value: string);
var
   Sect: TjanXMLNode2;
   Item, Subitem: TjanXMLNode2;
   i,j : integer;
begin
     Sect := GetSection('sockschain');
     if Sect = nil then
     begin
          Sect := TjanXMLNode2.Create;
          Sect.name := 'sockschain';
          FXMLDOM.addNode(Sect);
     end;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);

          if item.attribute['name'] = Section then
          begin
               for j := 0 to item.nodes.Count - 1 do
               begin
                    SubItem := TjanXMLNode2(item.nodes.Items[j]);
                    if SubItem.attribute['name'] = Ident then
                    begin
                         Subitem.attribute['value'] := Value;
                         exit;
                    end;
               end;
               SubItem := TjanXMLNode2.Create();
               Item.addNode(SubItem);
               SubItem.name := 'param';
               SubItem.attribute['name'] := Ident;
               SubItem.attribute['value'] := Value;
               exit;
          end;
     end;

     Item := TjanXMLNode2.Create();
     Sect.addNode(Item);
     Item.text := '';
     Item.name := 'server';
     Item.attribute['name'] := Section;
     SubItem := TjanXMLNode2.Create();
     Item.addNode(SubItem);
     SubItem.name := 'param';
     SubItem.attribute['name'] := Ident;
     SubItem.attribute['value'] := Value;
end;

// *****************************************************************************

function TXMLConfig.ReadString(Part: integer; Section, Ident: string; DefaultValue: string): string;
begin
     case Part of
       PART_MAIN: result := ReadMainString('Main', Ident);
       PART_PROGRAMS: result := ReadProgramsString(Section, Ident);
       PART_SOCKSCHAIN: result := ReadSocksChainString(Section, Ident);
       PART_DIRECTADDR: result := ReadMainString('DirectAddr', Ident);
       PART_DIRECTPORT: result := ReadMainString('DirectPort', Ident);
     end;
     if result = '' then
        result := DefaultValue;
end;

procedure TXMLConfig.WriteString(Part: integer; Section, Ident, Value: string);
begin
     case Part of
       PART_MAIN: WriteMainString('Main', Ident, Value);
       PART_PROGRAMS: WriteProgramsString(Section, Ident, Value);
       PART_SOCKSCHAIN: WriteSocksChainString(Section, Ident, Value);
       PART_DIRECTADDR: WriteMainString('DirectAddr', Ident, Value);
       PART_DIRECTPORT: WriteMainString('DirectPort', Ident, Value);
     end;
end;


function TXMLConfig.ReadInteger(Part: integer; Section, Ident: string; DefaultValue: integer): integer;
begin
     result := StrToIntDef(ReadString(Part, Section, Ident, ''), DefaultValue);
end;


function TXMLConfig.ReadBool(Part: integer; Section, Ident: string; DefaultValue: Boolean): Boolean;
var
   val: integer;
begin
     val := ReadInteger(Part, Section, Ident, -1);
     if val <> -1 then
       result := val <> 0
     else
       result := DefaultValue;
end;


procedure TXMLConfig.WriteInteger(Part: integer; Section, Ident: string; Value: integer);
begin
     WriteString(Part, Section, Ident, IntToStr(Value));
end;

procedure TXMLConfig.WriteBool(Part: integer; Section, Ident: string; Value: Boolean);
begin
     WriteInteger(Part, Section, Ident, Integer(Value));
end;



function TXMLConfig.GetSection(Section: String): TjanXMLNode2;
var
   Node: TjanXMLNode2;
   i: integer;
   lData: string;
begin
    result := nil;
    for i := 0 to FXMLDOM.nodes.Count - 1 do
    begin
       Node := TjanXMLNode2(FXMLDOM.nodes.Items[i]);
       lData := Node.name;
       if (AnsiCompareText(lData, Section) = 0) then
       begin
            result :=  Node;
            break;
       end;
    end;
end;

procedure TXMLConfig.Clear;
begin
     FXMLDOM.xml := '';
end;


procedure TXMLConfig.DeleteKey(Part: integer; const Section, Ident: String);
begin
     case Part of
       PART_MAIN: DeleteMainKey('Main', Ident);
       PART_PROGRAMS: DeleteProgramsKey(Section, Ident);
       PART_SOCKSCHAIN: DeleteSocksChainKey(Section, Ident);
       PART_DIRECTADDR: DeleteMainKey('DirectAddr', Ident);
       PART_DIRECTPORT: DeleteMainKey('DirectPort', Ident);
     end;
end;

procedure TXMLConfig.EraseMainSection(SecName, Section: string);
var
   Sect: TjanXMLNode2;
begin
     Sect := GetSection(SecName);
     if Sect = nil then
        exit;
     FXMLDOM.deleteNode(Sect);
end;

procedure TXMLConfig.EraseProgramsSection(const Section: string);
var
   Sect, Item: TjanXMLNode2;
   i: integer;
begin
     Sect := GetSection('programs');
     if Sect = nil then
        exit;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          if item.attribute['name'] = Section then
          begin
               Sect.deleteNode(Item);
               exit;
          end;
     end;
end;

procedure TXMLConfig.EraseSocksChainSection(const Section: string);
var
   Sect, Item: TjanXMLNode2;
   i: integer;
begin
     Sect := GetSection('sockschain');
     if Sect = nil then
        exit;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          if item.attribute['name'] = Section then
          begin
               Sect.deleteNode(Item);
               exit;
          end;
     end;
end;


procedure TXMLConfig.EraseSection(Part: integer; const Section: string);
begin
     case Part of
       PART_MAIN: EraseMainSection('Main', Section);
       PART_PROGRAMS: EraseProgramsSection(Section);
       PART_SOCKSCHAIN: EraseSocksChainSection(Section);
       PART_DIRECTADDR: EraseMainSection('DirectAddr', Section);
       PART_DIRECTPORT: EraseMainSection('DirectPort', Section);
     end;
end;

procedure TXMLConfig.ReadMainSections(Section: string; Strings: TStrings);
begin
     Strings.Add(Section);
end;

procedure TXMLConfig.ReadNamedSections(Section: string; Strings: TStrings);
var
   Sect: TjanXMLNode2;
   Item: TjanXMLNode2;
   i   : integer;
begin
     Sect := GetSection(Section);
     if Sect = nil then
        exit;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          Strings.Add(item.attribute['name']);
     end;
end;


procedure TXMLConfig.ReadSections(Part: integer; Strings: TStrings);
begin
     Strings.Clear;
     case Part of
       PART_MAIN: ReadMainSections('Main', Strings);
       PART_PROGRAMS: ReadNamedSections('programs', Strings);
       PART_SOCKSCHAIN: ReadNamedSections('sockschain', Strings);
       PART_DIRECTADDR: ReadMainSections('DirectAddr', Strings);
       PART_DIRECTPORT: ReadMainSections('DirectPort', Strings);
     end;
end;

procedure TXMLConfig.ReadSectionValues(Part: integer; const Section: string; Strings: TStrings);
begin
     Strings.Clear;
     case Part of
       PART_MAIN: ReadMainSectionValues('Main', Strings);
       PART_PROGRAMS: ReadProgramsSectionValues(Section, Strings);
       PART_SOCKSCHAIN: ReadSocksChainSectionValues(Section, Strings);
       PART_DIRECTADDR: ReadMainSectionValues('DirectAddr', Strings);
       PART_DIRECTPORT: ReadMainSectionValues('DirectPort', Strings);
     end;
end;

procedure TXMLConfig.UpdateFile;
begin
     if (FXMLDOM.nodes.Count <> 0) then
       FXMLDOM.SaveXML(FFileName);
end;

procedure TXMLConfig.ReadMainSectionValues(Section: string; Strings: TStrings);
var
   Sect: TjanXMLNode2;
   Item: TjanXMLNode2;
   i   : integer;
begin
     Sect := GetSection(Section);
     if Sect = nil then
        exit;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          Strings.Add(item.attribute['name'] + '=' + item.attribute['value']);
     end;
end;


procedure TXMLConfig.ReadProgramsSectionValues(Section: string; Strings: TStrings);
var
   Sect: TjanXMLNode2;
   Item: TjanXMLNode2;
   i   : integer;
begin
     Sect := GetSection('programs');
     if Sect = nil then
        exit;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          if (item.attribute['name'] = Section) then
          begin
               if item.attribute['path'] <> '' then
                  Strings.Add('path=' + item.attribute['path']);
               if item.attribute['workpath'] <> '' then
                  Strings.Add('workpath=' + item.attribute['workpath']);
               exit;
          end;
     end;
end;


procedure TXMLConfig.ReadSocksChainSectionValues(Section: string; Strings: TStrings);
var
   Sect: TjanXMLNode2;
   Item, SubItem: TjanXMLNode2;
   i,j : integer;
begin
     Sect := GetSection('sockschain');
     if Sect = nil then
        exit;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          if (item.attribute['name'] = Section) then
          begin
               for j := 0 to item.nodes.Count - 1 do
               begin
                    SubItem := TjanXMLNode2(item.nodes.Items[j]);
                    Strings.Add(SubItem.attribute['name'] + '=' + SubItem.attribute['value']);
               end;
          end;
     end;
end;


procedure TXMLConfig.DeleteMainKey(Section, Ident: string);
var
   Sect, Item: TjanXMLNode2;
   i: integer;
begin
     Sect := GetSection(Section);
     if Sect = nil then
        exit;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          if item.attribute['name'] = Ident then
          begin
               Sect.deleteNode(item);
               exit;
          end;
     end;
end;

procedure TXMLConfig.DeleteProgramsKey(Section, Ident: string);
var
   Sect: TjanXMLNode2;
   Item: TjanXMLNode2;
   i,j : integer;
begin
     Sect := GetSection('programs');
     if Sect = nil then
        exit;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          if item.attribute['name'] = Section then
          begin
               j := item.indexOfAttribute(Ident);
               if j <> -1 then
               begin
                    Item.deleteAttribute(TjanXMLAttribute2(Item.attributes[j]));
               end;
               exit;
          end;
     end;
end;

procedure TXMLConfig.DeleteSocksChainKey(Section, Ident: string);
var
   Sect: TjanXMLNode2;
   Item, Subitem: TjanXMLNode2;
   i,j : integer;
begin
     Sect := GetSection('sockschain');
     if Sect = nil then
        exit;

     for i:=0 to Sect.nodes.Count - 1 do
     begin
          item := TjanXMLNode2(Sect.nodes.Items[i]);
          if item.attribute['name'] = Section then
          begin
               for j := 0 to item.nodes.Count - 1 do
               begin
                    SubItem := TjanXMLNode2(item.nodes.Items[j]);
                    if SubItem.attribute['name'] = Ident then
                    begin
                         item.deleteNode(SubItem);
                         exit;
                    end;
               end
          end;
     end;
end;


end.




