{

 $Id: textlangs.pas,v 1.3 2005/02/15 11:21:21 bert Exp $

 $Log: textlangs.pas,v $
 Revision 1.3  2005/02/15 11:21:21  bert
 *** empty log message ***

}
unit textlangs;

interface
uses Windows, Classes, SysUtils, inifiles, misc, cfg;

type
    TSupLang = packed record
      LangID: DWORD;
      SublangID: DWORD;
      LangName: string[255];
      LangFileName: string[255];
    end;
    PSupLang = ^TSupLang;

    TCustomLangs = class
    private
      FList: TList;
      FLangPath: string;
      FCurrLangItem : TSupLang;
      function GetCount: integer;
      procedure AddItem(FileName: string);
      function GetSuppLang(index: integer): TSupLang;
    protected
      function GetLangRec(LangID, SublangId: DWORD): TSupLang; virtual;
    public
      constructor Create(ALangPath: string); virtual;
      destructor Destroy; override;
      function Translate(OrigText: string): string;
      property SupportLangs[index: integer]: TSupLang read GetSuppLang; default;
      property Count: integer read GetCount;
    end;

    function MAKELANGID(usPrimaryLanguage, usSubLanguage: Word): WORD;
    function GetLangsDir(): string;

    procedure Init;
    procedure Fini;

var
   TextLang: TCustomLangs;

implementation
uses xml_config;

function GetLangsDir(): string;
var
   Buf: array[0..MAX_PATH] of Char;
begin
     if (GetEnvironmentVariable('FreeCapStartupDir', @Buf, SizeOF(Buf))) <> 0 then
     begin
          if isDirExists(Buf + '\languages\') then
            result := Buf + '\languages\'
     end;

     if (result = '') then
       result := GetFreeCapInstallDir() + '\languages\';

//     if result = '' then
//       result := 'C:\Program Files\Borland\Delphi5\Projects\FreeCap\languages\';
end;


{ TCustomLangs }

function MAKELCID(
    wLanguageID,	// language identifier
    wSortID: WORD	// sorting identifier
   ): DWORD;
begin
     result := (wSortID shl 16) or wLanguageID;
end;

function MAKELANGID(
    usPrimaryLanguage,	// primary language identifier
    usSubLanguage: Word	// sublanguage identifier
   ): WORD;
begin
     result := (usSubLanguage shl 10) or usPrimaryLanguage;
end;

procedure TCustomLangs.AddItem(FileName: string);
var
   SupLangItem: PSupLang;
   IniFile: TIniFile;
   Buf: array[0..255] of Char;
   Lang_: LongInt;
begin
     GetMem(SupLangItem, SizeOf(TSupLang));

     IniFile := TIniFile.Create(FLangPath + '\' + FileName);

     with SupLangItem^ do
     begin
          Lang_ := IniFile.ReadInteger('Common', 'Language', 0);

          LangID := Lang_ and $3FF;
          SublangID := Lang_ shr 10;

          LangFileName := FLangPath + '\' + FileName;
          if (GetLocaleInfo(MAKELCID(MAKELANGID(LangID, SublangID), SORT_DEFAULT), LOCALE_SLANGUAGE, @Buf[0], SizeOf(Buf))) <> 0 then
            LangName := string(Buf);

          if prog_lang = MAKELANGID(LangID, SublangID) then
            FCurrLangItem := SupLangItem^;
     end;
     IniFile.Free;
     FList.Add(SupLangItem);
end;

constructor TCustomLangs.Create(ALangPath: string);
var
   SR: TSearchRec;
begin
     FList := TList.Create;
     FLangPath := ALangPath;
     if FindFirst(ALangPath + '\*.lng', $3F, SR) = 0 then
     begin
          AddItem(SR.Name);
          while FindNext(SR) = 0 do
            AddItem(SR.Name);
     end;
     FindClose(SR);
end;

destructor TCustomLangs.Destroy;
var
   i: integer;
begin
     for i := 0 to FList.Count - 1 do
       FreeMem(FList[i]);
     FList.Free;
     inherited;
end;

function TCustomLangs.GetCount: integer;
begin
     result := FList.Count;
end;

function TCustomLangs.GetLangRec(LangID, SublangId: DWORD): TSupLang;
var
   i: integer;
begin
     for i := 0 to Count - 1 do
     begin
          if (Self[i].LangID = LangID) and (Self[i].SublangId = SublangId) then
          begin
               result := Self[i];
               exit;
          end;
     end;
//     raise Exception.CreateFmt('Requested language (LangID: %d, SublangId: %d) isn''t supported!', [LangID, SublangId]);
end;

function TCustomLangs.GetSuppLang(index: integer): TSupLang;
begin
     result := PSupLang(FList[index])^;
end;


function TCustomLangs.Translate(OrigText: string): string;
var
   IniFile: TIniFile;
begin
     IniFile := TIniFile.Create(FCurrLangItem.LangFileName);
     result := IniFile.ReadString('RESOURCE', OrigText, OrigText);
     if result = OrigText then
       IniFile.WriteString('RESOURCE', OrigText, OrigText);

     IniFile.Free;
end;

procedure Init;
begin
   TextLang := TCustomLangs.Create(GetLangsDir());
end;

procedure Fini;
begin
   TextLang.Free;
end;

end.
