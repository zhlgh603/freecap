unit abs_config;

interface
uses Classes;
type
    TAbstractConfig = class
    public
      constructor Create(AFileName: string = ''); virtual;
      destructor Destroy; override;
      procedure DeleteKey(Part: integer; const Section, Ident: String); virtual; abstract;
      procedure EraseSection(Part: integer; const Section: string); virtual; abstract;
      procedure ReadSections(Part: integer; Strings: TStrings); virtual; abstract;
      procedure ReadSectionValues(Part: integer; const Section: string; Strings: TStrings); virtual; abstract;
      function ReadString(Part: integer; Section, Ident: string; DefaultValue: string): string; virtual; abstract;
      function ReadInteger(Part: integer; Section, Ident: string; DefaultValue: integer): integer; virtual; abstract;
      function ReadBool(Part: integer; Section, Ident: string; DefaultValue: Boolean): Boolean; virtual; abstract;
      procedure WriteString(Part: integer; Section, Ident, Value: string); virtual; abstract;
      procedure WriteBool(Part: integer; Section, Ident: string; Value: Boolean); virtual; abstract;
      procedure WriteInteger(Part: integer; Section, Ident: string; Value: integer); virtual; abstract;
    end;


implementation

{ TAbstractConfig }

constructor TAbstractConfig.Create(AFileName: string);
begin

end;

destructor TAbstractConfig.Destroy;
begin
  inherited;
end;

end.
 