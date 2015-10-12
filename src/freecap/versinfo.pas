{
  $Id: versinfo.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

  $Log: versinfo.pas,v $
  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}
unit VersInfo;


interface

uses
  Windows, SysUtils, Classes;

type
  TVersionInfo = class
  private
    { Private declarations }
    FFilename: TFilename;
    FVersionInfoSize: cardinal;
    FFileVersion: string;
    FFileDescription: string;
    FInternalName: string;
    FOriginalFilename: string;
    FCompanyName: string;
    FProductVersion: string;
    FProductName: string;
    FLegalCopyright: string;
    FLanguageInfo: string;
    FComments: string;
    procedure SetFilename(const Value: TFilename);
  protected
    { Protected declarations }
    property VersionInfoSize: cardinal read FVersionInfoSize;
    procedure LoadFromFile;
    procedure ClearAll;
  public
    { Public declarations }
  published
    { Published declarations }
    function GetBuildOnly: string;
    property Filename: TFilename read FFilename write SetFilename;
    property LanguageInfo: string read FLanguageInfo;
    property CompanyName: string read FCompanyName;
    property FileDescription: string read FFileDescription;
    property FileVersion: string read FFileVersion;
    property InternalName: string read FInternalName;
    property LegalCopyright: string read FLegalCopyright;
    property OriginalFilename: string read FOriginalFilename;
    property ProductName: string read FProductName;
    property ProductVersion: string read FProductVersion;
    property Comments: string read FComments;
  end;


implementation

{ TVersionInfo }

procedure TVersionInfo.ClearAll;
begin
  FVersionInfoSize := 0;
  FCompanyName := '';
  FFileDescription := '';
  FFileVersion := '';
  FInternalName := '';
  FLegalCopyright := '';
  FOriginalFilename := '';
  FProductName := '';
  FProductVersion := '';
  FComments := '';
end;

function TVersionInfo.GetBuildOnly: string;
var p: integer;
    s: string;
begin
  s := FileVersion;
  p := LastDelimiter('.',s);
  Result := copy(s,p+1,length(s)-p);
end;

procedure TVersionInfo.LoadFromFile;
var VISize:   cardinal;
    VIBuff:   pointer;
    trans:    pointer;
    buffsize: cardinal;
    temp: integer;
    str: pchar;
    LangCharSet: string;

  function GetStringValue(const From: string): string;
  begin
    VerQueryValue(VIBuff,pchar('\StringFileInfo\'+LanguageInfo+'\'+From), pointer(str),
                  buffsize);
    if buffsize > 0 then Result := str else Result := '';
  end;

begin
  ClearAll;
  VIBuff := nil;
  if not fileexists(Filename) then exit;
  VISize := GetFileVersionInfoSize(pchar(Filename),buffsize);
  FVersionInfoSize := VISize;
  if VISize < 1 then
     exit;
  VIBuff := AllocMem(VISize);
  GetFileVersionInfo(pchar(Filename),cardinal(0),VISize,VIBuff);

  VerQueryValue(VIBuff,'\VarFileInfo\Translation',Trans,buffsize);
  if buffsize >= 4 then
  begin
       temp:=0;
       StrLCopy(@temp, pchar(Trans), 2);
       LangCharSet:=IntToHex(temp, 4);
       StrLCopy(@temp, pchar(Trans)+2, 2);
       FLanguageInfo := LangCharSet+IntToHex(temp, 4);
  end;

  FCompanyName := GetStringValue('CompanyName');
  FFileDescription := GetStringValue('FileDescription');
  FFileVersion := GetStringValue('FileVersion');
  FInternalName := GetStringValue('InternalName');
  FLegalCopyright := GetStringValue('LegalCopyright');
  FOriginalFilename := GetStringValue('OriginalFilename');
  FProductName := GetStringValue('ProductName');
  FProductVersion := GetStringValue('ProductVersion');
  FComments := GetStringValue('Comments');

  FreeMem(VIBuff,VISize);
end;

procedure TVersionInfo.SetFilename(const Value: TFilename);
begin
  FFilename := Value;
  LoadFromFile;
end;

end.

