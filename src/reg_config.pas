unit reg_config;

interface
uses Windows, Classes, SysUtils, janXMLParser2, misc, registry, abs_config;

const
     PART_MAIN = 0;
     PART_PROGRAMS = 1;
     PART_SOCKSCHAIN = 2;
     PART_DIRECTADDR = 3;
     PART_DIRECTPORT = 4;
     CONFIG_PATH = 'Software\Bert''s Software\FreeCap';
     WIDECAP_CONFIG_PATH = 'Software\Bert''s Software\WideCap';
type
    TRegConfig = class(TAbstractConfig)
    private
      FReg: TRegIniFile;
      FConfigPath: string;

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


      procedure DeleteMainKey(Section, Ident: string);
      procedure DeleteProgramsKey(Section, Ident: string);
      procedure DeleteSocksChainKey(Section, Ident: string);
      procedure EraseMainSection(SecName, Section: string);
      procedure EraseProgramsSection(const Section: string);
      procedure EraseSocksChainSection(const Section: string);

      procedure ReadMainSectionValues(Section: string;
        Strings: TStrings);
      procedure ReadSocksChainSectionValues(Section: string;
        Strings: TStrings);
    public
      constructor Create(AFileName: string = ''); override;
      destructor Destroy; override;


      procedure DeleteKey(Part: integer; const Section, Ident: String); override;
      procedure EraseSection(Part: integer; const Section: string); override;
      procedure ReadSections(Part: integer; Strings: TStrings); override;
      procedure ReadSectionValues(Part: integer; const Section: string; Strings: TStrings); override;

      function ReadString(Part: integer; Section, Ident: string; DefaultValue: string): string; override;
      function ReadInteger(Part: integer; Section, Ident: string; DefaultValue: integer): integer; override;
      function ReadBool(Part: integer; Section, Ident: string; DefaultValue: Boolean): Boolean; override;

      procedure WriteString(Part: integer; Section, Ident, Value: string);override;
      procedure WriteBool(Part: integer; Section, Ident: string; Value: Boolean);override;
      procedure WriteInteger(Part: integer; Section, Ident: string; Value: integer);override;

    end;

    function GetFreeCapConfig(): string;

    function GetFreecapInstallDir(checkRegistryOnly : Boolean = False): string;
    procedure SetFreecapInstallDir(Value: string);
    function CheckFreecapRegistry(): Boolean;
    function CheckWideCapRegistry(): Boolean;

    procedure Importer(xmlFile: string; bImport: Boolean = True);
    procedure ImporterReg(bSrcFreeCap: Boolean);

implementation
uses cfg, loger, xml_config;


function GetFreeCapConfig(): string;
begin
     result := GetFreecapInstallDir() + '\freecap.xml';
end;

function CheckFreecapRegistry(): Boolean;
var
   Reg: TRegIniFIle;
begin
     Reg := TRegIniFIle.Create;
     Reg.RootKey := HKEY_CURRENT_USER;
     result := Reg.KeyExists(CONFIG_PATH + '\Programs');
     Reg.Free;
end;

function CheckWideCapRegistry(): Boolean;
var
   Reg: TRegIniFIle;
begin
     Reg := TRegIniFIle.Create;
     Reg.RootKey := HKEY_CURRENT_USER;
     result := Reg.KeyExists(WIDECAP_CONFIG_PATH + '\Programs');
     Reg.Free;
end;


function GetFreecapInstallDir(checkRegistryOnly : Boolean): string;
var
   Reg: TRegIniFIle;
begin
     Reg := TRegIniFIle.Create;
     Reg.RootKey := HKEY_CURRENT_USER;
     Reg.OpenKey(CONFIG_PATH, True);
     result := Reg.ReadString('', 'FreeCapInstallDir', '');
     Reg.Free;
end;

procedure SetFreecapInstallDir(Value: string);
var
   Reg: TRegIniFIle;
begin
     Reg := TRegIniFIle.Create;
     Reg.RootKey := HKEY_CURRENT_USER;
     Reg.OpenKey(CONFIG_PATH, True);
     Reg.WriteString('', 'FreeCapInstallDir', Value);
     Reg.Free;
end;

procedure Importer(xmlFile: string; bImport: Boolean);
var
   from_cfg: TAbstractConfig;
   to_cfg: TAbstractConfig;
   Sections, Values: TStringList;
   i: integer;
begin
     Sections := TStringList.Create;
     Values := TStringList.Create;

     if bImport then
     begin
          from_cfg := TXMLConfig.Create(xmlFile);
          {$IFDEF WIDECAP}
            to_cfg := TRegConfig.Create('widecap');
          {$ELSE}
            to_cfg := TRegConfig.Create('');
          {$ENDIF}
     end
     else
     begin
          {$IFDEF WIDECAP}
            from_cfg := TRegConfig.Create('widecap');
          {$ELSE}
            from_cfg := TRegConfig.Create('');
          {$ENDIF}
          to_cfg := TXMLConfig.Create(xmlFile);
     end;

     to_cfg.WriteBool(PART_MAIN, 'SOCKS', 'Log', from_cfg.ReadBool(PART_MAIN, 'SOCKS', 'Log', False));
     to_cfg.WriteString(PART_MAIN, 'SOCKS', 'LogFile', from_cfg.ReadString(PART_MAIN, 'SOCKS', 'LogFile', ''));
     to_cfg.WriteBool(PART_MAIN, 'SOCKS', 'LogTraffic', from_cfg.ReadBool(PART_MAIN, 'SOCKS', 'LogTraffic', False));
     to_cfg.WriteInteger(PART_MAIN, 'SOCKS', 'LogLevel', from_cfg.ReadInteger(PART_MAIN, 'SOCKS', 'LogLevel', 0));
     to_cfg.WriteInteger(PART_MAIN, 'Main','LogHeight', from_cfg.ReadInteger(PART_MAIN, 'Main','LogHeight', 100));
     to_cfg.WriteBool(PART_MAIN, 'SOCKS', 'UDPHack', from_cfg.ReadBool(PART_MAIN, 'SOCKS', 'UDPHack', False));

     to_cfg.WriteBool(PART_MAIN, 'Main', 'OneInstance', from_cfg.ReadBool(PART_MAIN, 'Main', 'OneInstance', False));
     to_cfg.WriteBool(PART_MAIN, 'Main', 'SysStartup', from_cfg.ReadBool(PART_MAIN, 'Main', 'SysStartup', False));
     to_cfg.WriteBool(PART_MAIN, 'Main', 'RunTray', from_cfg.ReadBool(PART_MAIN, 'Main', 'RunTray', False));
     to_cfg.WriteBool(PART_MAIN, 'Main', 'MinimizeToTray', from_cfg.ReadBool(PART_MAIN, 'Main', 'MinimizeToTray', False));
     to_cfg.WriteInteger(PART_MAIN, 'Main', 'ViewStyle', from_cfg.ReadInteger(PART_MAIN, 'Main', 'ViewStyle', 0));
     to_cfg.WriteInteger(PART_MAIN, 'Main', 'ResolveDNS', from_cfg.ReadInteger(PART_MAIN, 'Main', 'ResolveDNS', 2));
     to_cfg.WriteBool(PART_MAIN, 'Main', 'AddToCaptionText', from_cfg.ReadBool(PART_MAIN, 'Main', 'AddToCaptionText', True));
     to_cfg.WriteBool(PART_MAIN, 'Main', 'ShowMessages', from_cfg.ReadBool(PART_MAIN, 'Main', 'ShowMessages', True));
     to_cfg.WriteBool(PART_MAIN, 'Main', 'HideOnClose', from_cfg.ReadBool(PART_MAIN, 'Main', 'HideOnClose', True));
     to_cfg.WriteInteger(PART_MAIN, 'Main', 'Language', from_cfg.ReadInteger(PART_MAIN, 'Main', 'Language', 0));
     to_cfg.WriteInteger(PART_MAIN, 'Main','NavTreeWidth', from_cfg.ReadInteger(PART_MAIN, 'Main','NavTreeWidth', 100));

     from_cfg.ReadSections(PART_PROGRAMS, Sections);
     to_cfg.EraseSection(PART_PROGRAMS, '');
     for i:=0 to Sections.Count - 1 do
     begin
          to_cfg.WriteString(PART_PROGRAMS, Sections[i], 'Path', from_cfg.ReadString(PART_PROGRAMS, Sections[i],'Path',''));
          to_cfg.WriteString(PART_PROGRAMS, Sections[i],'WorkDir', from_cfg.ReadString(PART_PROGRAMS, Sections[i],'WorkDir',''));
          to_cfg.WriteString(PART_PROGRAMS, Sections[i],'Params', from_cfg.ReadString(PART_PROGRAMS, Sections[i],'Params', ''));
          to_cfg.WriteBool(PART_PROGRAMS, Sections[i],'Autorun', from_cfg.ReadBool(PART_PROGRAMS, Sections[i],'Autorun',False));
     end;

     from_cfg.ReadSections(PART_SOCKSCHAIN, Sections);
     to_cfg.EraseSection(PART_SOCKSCHAIN, '');
     for i:=0 to Sections.Count - 1 do
     begin
          from_cfg.ReadSectionValues(PART_SOCKSCHAIN, Sections[i], Values);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Server', Values.Values['Server']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Port', Values.Values['Port']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Version', Values.Values['Version']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Login', Values.Values['Login']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Socks4Ident', Values.Values['Socks4Ident']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Password', Values.Values['Password']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'HttpUser', Values.Values['HttpUser']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'HttpPass', Values.Values['HttpPass']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'HttpAuth', Values.Values['HttpAuth']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'InUse', Values.Values['InUse']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Auth', Values.Values['Auth']);
     end;

     from_cfg.ReadSectionValues(PART_DIRECTADDR, 'DirectAddr', Sections);
     to_cfg.EraseSection(PART_DIRECTADDR, 'DirectAddr');
     for i:=0 to Sections.Count - 1 do
        to_cfg.WriteString(PART_DIRECTADDR, 'DirectAddr', Format('n%d',[i]), Sections.Values[Format('n%d',[i])]);

     from_cfg.ReadSectionValues(PART_DIRECTPORT, 'DirectPort', Sections);
     to_cfg.EraseSection(PART_DIRECTPORT, 'DirectPort');
     for i:=0 to Sections.Count - 1 do
        to_cfg.WriteString(PART_DIRECTPORT, 'DirectPort', Format('n%d',[i]), Sections.Values[Format('n%d',[i])]);


     if (to_cfg is TXMLConfig) then
       TXMLConfig(to_cfg).UpdateFile;
     Sections.Free;
     Values.Free;
end;



procedure ImporterReg(bSrcFreeCap: Boolean);
var
   from_cfg: TAbstractConfig;
   to_cfg: TAbstractConfig;
   Sections, Values: TStringList;
   i: integer;
begin
     Sections := TStringList.Create;
     Values := TStringList.Create;

     if bSrcFreeCap then
     begin
          from_cfg := TRegConfig.Create('');
          to_cfg := TRegConfig.Create('widecap');
     end
     else
     begin
         from_cfg := TRegConfig.Create('widecap');
         to_cfg := TRegConfig.Create('');
     end;

     to_cfg.WriteBool(PART_MAIN, 'SOCKS', 'Log', from_cfg.ReadBool(PART_MAIN, 'SOCKS', 'Log', False));
     to_cfg.WriteString(PART_MAIN, 'SOCKS', 'LogFile', from_cfg.ReadString(PART_MAIN, 'SOCKS', 'LogFile', ''));
     to_cfg.WriteBool(PART_MAIN, 'SOCKS', 'LogTraffic', from_cfg.ReadBool(PART_MAIN, 'SOCKS', 'LogTraffic', False));
     to_cfg.WriteInteger(PART_MAIN, 'SOCKS', 'LogLevel', from_cfg.ReadInteger(PART_MAIN, 'SOCKS', 'LogLevel', 0));
     to_cfg.WriteInteger(PART_MAIN, 'Main','LogHeight', from_cfg.ReadInteger(PART_MAIN, 'Main','LogHeight', 100));
     to_cfg.WriteBool(PART_MAIN, 'SOCKS', 'UDPHack', from_cfg.ReadBool(PART_MAIN, 'SOCKS', 'UDPHack', False));

     to_cfg.WriteBool(PART_MAIN, 'Main', 'OneInstance', from_cfg.ReadBool(PART_MAIN, 'Main', 'OneInstance', False));
     to_cfg.WriteBool(PART_MAIN, 'Main', 'SysStartup', from_cfg.ReadBool(PART_MAIN, 'Main', 'SysStartup', False));
     to_cfg.WriteBool(PART_MAIN, 'Main', 'RunTray', from_cfg.ReadBool(PART_MAIN, 'Main', 'RunTray', False));
     to_cfg.WriteBool(PART_MAIN, 'Main', 'MinimizeToTray', from_cfg.ReadBool(PART_MAIN, 'Main', 'MinimizeToTray', False));
     to_cfg.WriteInteger(PART_MAIN, 'Main', 'ViewStyle', from_cfg.ReadInteger(PART_MAIN, 'Main', 'ViewStyle', 0));
     to_cfg.WriteInteger(PART_MAIN, 'Main', 'ResolveDNS', from_cfg.ReadInteger(PART_MAIN, 'Main', 'ResolveDNS', 2));
     to_cfg.WriteBool(PART_MAIN, 'Main', 'AddToCaptionText', from_cfg.ReadBool(PART_MAIN, 'Main', 'AddToCaptionText', True));
     to_cfg.WriteBool(PART_MAIN, 'Main', 'ShowMessages', from_cfg.ReadBool(PART_MAIN, 'Main', 'ShowMessages', True));
     to_cfg.WriteBool(PART_MAIN, 'Main', 'HideOnClose', from_cfg.ReadBool(PART_MAIN, 'Main', 'HideOnClose', True));
     to_cfg.WriteInteger(PART_MAIN, 'Main', 'Language', from_cfg.ReadInteger(PART_MAIN, 'Main', 'Language', 0));
     to_cfg.WriteInteger(PART_MAIN, 'Main','NavTreeWidth', from_cfg.ReadInteger(PART_MAIN, 'Main','NavTreeWidth', 100));

     from_cfg.ReadSections(PART_PROGRAMS, Sections);
     to_cfg.EraseSection(PART_PROGRAMS, '');
     for i:=0 to Sections.Count - 1 do
     begin
          to_cfg.WriteString(PART_PROGRAMS, Sections[i], 'Path', from_cfg.ReadString(PART_PROGRAMS, Sections[i],'Path',''));
          to_cfg.WriteString(PART_PROGRAMS, Sections[i], 'WorkDir', from_cfg.ReadString(PART_PROGRAMS, Sections[i],'WorkDir',''));
          to_cfg.WriteString(PART_PROGRAMS, Sections[i], 'Params', from_cfg.ReadString(PART_PROGRAMS, Sections[i],'Params', ''));
          to_cfg.WriteBool(PART_PROGRAMS, Sections[i], 'Autorun', from_cfg.ReadBool(PART_PROGRAMS, Sections[i],'Autorun',False));
          to_cfg.WriteString(PART_PROGRAMS, Sections[i], 'name', from_cfg.ReadString(PART_PROGRAMS, Sections[i],'name', ''));
     end;

     from_cfg.ReadSections(PART_SOCKSCHAIN, Sections);
     to_cfg.EraseSection(PART_SOCKSCHAIN, '');
     for i:=0 to Sections.Count - 1 do
     begin
          from_cfg.ReadSectionValues(PART_SOCKSCHAIN, Sections[i], Values);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Server', Values.Values['Server']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Port', Values.Values['Port']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Version', Values.Values['Version']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Login', Values.Values['Login']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Socks4Ident', Values.Values['Socks4Ident']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Password', Values.Values['Password']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'HttpUser', Values.Values['HttpUser']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'HttpPass', Values.Values['HttpPass']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'HttpAuth', Values.Values['HttpAuth']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'InUse', Values.Values['InUse']);
          to_cfg.WriteString(PART_SOCKSCHAIN, Sections[i], 'Auth', Values.Values['Auth']);
     end;

     from_cfg.ReadSectionValues(PART_DIRECTADDR, 'DirectAddr', Sections);
     to_cfg.EraseSection(PART_DIRECTADDR, 'DirectAddr');
     for i:=0 to Sections.Count - 1 do
        to_cfg.WriteString(PART_DIRECTADDR, 'DirectAddr', Format('n%d',[i]), Sections.Values[Format('n%d',[i])]);

     from_cfg.ReadSectionValues(PART_DIRECTPORT, 'DirectPort', Sections);
     to_cfg.EraseSection(PART_DIRECTPORT, 'DirectPort');
     for i:=0 to Sections.Count - 1 do
        to_cfg.WriteString(PART_DIRECTPORT, 'DirectPort', Format('n%d',[i]), Sections.Values[Format('n%d',[i])]);


     if (to_cfg is TXMLConfig) then
       TXMLConfig(to_cfg).UpdateFile;
     Sections.Free;
     Values.Free;
end;

// TRegConfig

constructor TRegConfig.Create(AFileName: string);
begin
     FReg := TRegIniFIle.Create;
     FReg.RootKey := HKEY_CURRENT_USER;
     if (AFileName <> 'widecap') or (not UseWideCapCfg) then
       FConfigPath := CONFIG_PATH
     else
       FConfigPath := WIDECAP_CONFIG_PATH;
end;

destructor TRegConfig.Destroy;
begin
     FReg.Free;
     inherited;
end;


function TRegConfig.ReadMainString(Section, Ident: string): string;
begin
     FReg.OpenKey(FConfigPath, True);
     result := FReg.ReadString(Section, Ident, '');
     FReg.CloseKey();
end;


function TRegConfig.ReadProgramsString(Section, Ident: string): string;
begin
     FReg.OpenKey(FConfigPath + '\Programs', True);
     result := FReg.ReadString(Section, Ident, '');
     FReg.CloseKey();
end;


function TRegConfig.ReadSocksChainString(Section, Ident: string): string;
begin
     FReg.OpenKey(FConfigPath, True);
     result := FReg.ReadString(Section, Ident, '');
     FReg.CloseKey();
end;


procedure TRegConfig.WriteMainString(Section, Ident, Value: string);
begin
     FReg.OpenKey(FConfigPath, True);
     FReg.WriteString(Section, Ident, Value);
     FReg.CloseKey();
end;

procedure TRegConfig.WriteProgramsString(Section, Ident, Value: string);
var
   i, SectNum: integer;
   Sections : TStringList;
begin
     Sections := TStringList.Create;
     FReg.OpenKey(FConfigPath + '\Programs', True);
     FReg.ReadSections(Sections);

     SectNum := 0;
     for i := 0 to Sections.Count - 1 do
     begin
          SectNum := StrToIntDef(trim(Sections[i]), 0);
          if (Freg.ReadString(Sections[i], 'name', '') = Section) then
          begin
               FReg.WriteString(Sections[i], Ident, Value);
               FReg.CloseKey();
               exit;
          end;
     end;

     inc(SectNum);
     FReg.WriteString(Format('%.8d',[SectNum]), 'name', Section);
     FReg.WriteString(Format('%.8d',[SectNum]), Ident, Value);
     FReg.CloseKey();
end;

procedure TRegConfig.WriteSocksChainString(Section, Ident, Value: string);
var
   i, SectNum: integer;
   Sections : TStringList;
begin
     Sections := TStringList.Create;
     FReg.OpenKey(FConfigPath + '\SocksChain', True);
     FReg.ReadSections(Sections);

     SectNum := 0;
     for i := 0 to Sections.Count - 1 do
     begin
          SectNum := StrToIntDef(trim(Sections[i]), 0);
          if (Freg.ReadString(Sections[i], 'name', '') = Section) then
          begin
               FReg.WriteString(Sections[i], Ident, Value);
               FReg.CloseKey();
               exit;
          end;
     end;

     inc(SectNum);
     FReg.WriteString(Format('%.8d',[SectNum]), 'name', Section);
     FReg.WriteString(Format('%.8d',[SectNum]), Ident, Value);
     FReg.CloseKey();
end;

// *****************************************************************************

function TRegConfig.ReadString(Part: integer; Section, Ident: string; DefaultValue: string): string;
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

procedure TRegConfig.WriteString(Part: integer; Section, Ident, Value: string);
begin
     case Part of
       PART_MAIN: WriteMainString('Main', Ident, Value);
       PART_PROGRAMS: WriteProgramsString(Section, Ident, Value);
       PART_SOCKSCHAIN: WriteSocksChainString(Section, Ident, Value);
       PART_DIRECTADDR: WriteMainString('DirectAddr', Ident, Value);
       PART_DIRECTPORT: WriteMainString('DirectPort', Ident, Value);
     end;
end;


function TRegConfig.ReadInteger(Part: integer; Section, Ident: string; DefaultValue: integer): integer;
begin
     result := StrToIntDef(ReadString(Part, Section, Ident, ''), DefaultValue);
end;


function TRegConfig.ReadBool(Part: integer; Section, Ident: string; DefaultValue: Boolean): Boolean;
var
   val: integer;
begin
     val := ReadInteger(Part, Section, Ident, -1);
     if val <> -1 then
       result := val <> 0
     else
       result := DefaultValue;
end;


procedure TRegConfig.WriteInteger(Part: integer; Section, Ident: string; Value: integer);
begin
     WriteString(Part, Section, Ident, IntToStr(Value));
end;

procedure TRegConfig.WriteBool(Part: integer; Section, Ident: string; Value: Boolean);
begin
     WriteInteger(Part, Section, Ident, Integer(Value));
end;




procedure TRegConfig.DeleteKey(Part: integer; const Section, Ident: String);
begin
     case Part of
       PART_MAIN: DeleteMainKey('Main', Ident);
       PART_PROGRAMS: DeleteProgramsKey(Section, Ident);
       PART_SOCKSCHAIN: DeleteSocksChainKey(Section, Ident);
       PART_DIRECTADDR: DeleteMainKey('DirectAddr', Ident);
       PART_DIRECTPORT: DeleteMainKey('DirectPort', Ident);
     end;
end;

procedure TRegConfig.EraseMainSection(SecName, Section: string);
begin
     FReg.OpenKey(FConfigPath + '\' + SecName, True);
     FReg.EraseSection(Section);
     FReg.CloseKey();
end;

procedure TRegConfig.EraseProgramsSection(const Section: string);
begin
     FReg.OpenKey(FConfigPath + '\Programs', True);
     FReg.EraseSection(Section);
     FReg.CloseKey();
end;

procedure TRegConfig.EraseSocksChainSection(const Section: string);
begin
     FReg.OpenKey(FConfigPath + '\SocksChain', True);
     FReg.EraseSection(Section);
     FReg.CloseKey();
end;


procedure TRegConfig.EraseSection(Part: integer; const Section: string);
begin
     case Part of
       PART_MAIN: EraseMainSection('Main', Section);
       PART_PROGRAMS: EraseProgramsSection(Section);
       PART_SOCKSCHAIN: EraseSocksChainSection(Section);
       PART_DIRECTADDR: EraseMainSection('', Section);
       PART_DIRECTPORT: EraseMainSection('', Section);
     end;
end;

procedure TRegConfig.ReadMainSections(Section: string; Strings: TStrings);
begin
     Strings.Add(Section);
end;

procedure TRegConfig.ReadNamedSections(Section: string; Strings: TStrings);
begin
     FReg.OpenKey(FConfigPath + '\' + Section, True);
     FReg.ReadSections(Strings);
     FReg.CloseKey();
end;


procedure TRegConfig.ReadSections(Part: integer; Strings: TStrings);
begin
     Strings.Clear;
     case Part of
       PART_MAIN: ReadMainSections('Main', Strings);
       PART_PROGRAMS: ReadNamedSections('Programs', Strings);
       PART_SOCKSCHAIN: ReadNamedSections('SocksChain', Strings);
       PART_DIRECTADDR: ReadMainSections('DirectAddr', Strings);
       PART_DIRECTPORT: ReadMainSections('DirectPort', Strings);
     end;
end;

procedure TRegConfig.ReadSectionValues(Part: integer; const Section: string; Strings: TStrings);
begin
     Strings.Clear;
     case Part of
//       PART_MAIN: ReadMainSectionValues('Main', Strings);
//       PART_PROGRAMS: ReadProgramsSectionValues(Section, Strings);
       PART_SOCKSCHAIN: ReadSocksChainSectionValues(Section, Strings);
       PART_DIRECTADDR: ReadMainSectionValues('DirectAddr', Strings);
       PART_DIRECTPORT: ReadMainSectionValues('DirectPort', Strings);
     end;
end;



procedure TRegConfig.DeleteMainKey(Section, Ident: string);
begin
     FReg.OpenKey(FConfigPath, True);
     FReg.DeleteKey(Section, Ident);
     FReg.CloseKey;
end;

procedure TRegConfig.DeleteProgramsKey(Section, Ident: string);
begin
     FReg.OpenKey(FConfigPath + '\Programs', True);
     FReg.DeleteKey(Section, Ident);
     FReg.CloseKey;
end;

procedure TRegConfig.DeleteSocksChainKey(Section, Ident: string);
begin
     FReg.OpenKey(FConfigPath + '\SocksChain', True);
     FReg.DeleteKey(Section, Ident);
     FReg.CloseKey;
end;


procedure TRegConfig.ReadSocksChainSectionValues(Section: string;
  Strings: TStrings);
var
   i: integer;
   Sections : TStringList;
begin
     Strings.Clear;
     Sections := TStringList.Create;
     FReg.OpenKey(FConfigPath + '\SocksChain', True);
     FReg.ReadSections(Sections);

     for i := 0 to Sections.Count - 1 do
     begin
          if (Sections[i] = Section) then
          begin
               FReg.ReadSectionValues(Sections[i], Strings);
               FReg.CloseKey();
               exit;
          end;
     end;
     FReg.CloseKey();
end;

procedure TRegConfig.ReadMainSectionValues(Section: string;
  Strings: TStrings);
begin
     Strings.Clear;
     FReg.OpenKey(FConfigPath {+ '\' + Section}, True);
     FReg.ReadSectionValues(Section, Strings);
     FReg.CloseKey();
end;

end.


