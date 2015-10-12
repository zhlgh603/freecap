{
  A library of mainly string related procedures and functions.
  Contains also some non-string functions

}
unit janStrings;


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, base64;

const
  dutchmonthnames: array[1..12] of string=('januari','februari','maart','april','mei','juni','juli','augustus','september','oktober','november','decenber');
  dutchdaynames: array[1..7] of string=('zondag','maandag','dinsdag','woensdag','donderdag','vrijdag','zaterdag');

var
  janHashTable: array[#0..#255] of byte;
  janInsensitiveHashTable: array[#0..#255] of Byte;

  {dialogs}
  function confirm(msg:string):boolean;

  {ini style routines}
  procedure ListSections(atext:string;list:TStrings);
  function GetSection(atext,asection:string):string;

  {soundex}
  function Soundex(source : string) : integer;

  {simple r.e. routines}
  // match strFirst*strSecond
  function match2(strSource,strFirst,strSecond:string;startPos:integer; var p1:integer; var p2:integer):boolean;
  // match strFirst*strSecond*strThird
  function match3(strSource,strFirst,strSecond,strThird:string;startPos:integer; var p1:integer; var p2:integer;var p3:integer):boolean;
  // scans for next occurance of strScan
  function scannext(strSource,strScan:string;startPos:integer;var scanPos:integer):boolean;

  {hash routines}
  procedure InitTables;
  function CrcHash(const aString: string): integer;
  function Crc32Hash(const aString:string):integer;
  procedure CalcCRC32 (p:  pointer; ByteCount:  DWORD; VAR CRCvalue:  DWORD);

  {indexer routines}
  procedure getSearchWords(aStr:string;alist:TStringlist);
  procedure getwordlist(aStr:string; list:TStringlist);
  procedure gethtmlwordlist(aStr:string; list:TStringlist);
  procedure gethtmlhashlist(aStr:string; list:TStringlist;hash32:boolean);
  function hithighlight(fn:string;searchwords:tstringlist;myDir:string;abackcolor,aforecolor:string;var hits:integer):string;
  function strHithighlight(aText:string;searchwords:tstringlist;abackcolor, aforecolor:string;var hilites:integer):string;
  function getHTMLTitle(aText:string):string;
  {file filter functions}
  function decodefilter(afilter:string):string;
  function encodefilter(avalue:string):string;

  {xml functions}
  function xmlformatLoadStr(fn:string):string;
  function prettyxml(aText:string):string;

  {date functions}
  function dutchdate(akind:integer;adate:TDateTime):string;
  function logtotime(s:string;var atime:TDateTime):boolean;
  // hh:nn:ss
  function logtodate(s:string;var adate:TDateTime):boolean;
  // yyyy-mm-dd
  function timetohours(aTime:TDateTime):double;
  function Date2Year (const DT: TDateTime): Word;
  function DayOfYear (const DT: TDateTime): Word;
  // --- ISO-8601 Compliant Routines ---

{: Returns Day Of Week According to ISO-8601 which has Monday as 1 and
	Sunday as 7 }
  function ISODayOfWeek (const DT: TDateTime): Integer;
  function StartOfISOWeek (const DT: TDateTime): TDateTime;
  Function EndOfISOWeek(const DT: TDateTime): TDateTime;
  function GetFirstDayofMonth (const DT: TDateTime): TDateTime;
  function GetLastDayofMonth (const DT: TDateTime): TDateTime;
  function DaysInMonth (const DT: TDateTime): Byte;
  function Date2Month (const DT: TDateTime): Word;
  function Date2Day (const DT: TDateTime): Word;
  function StartOfWeek (const DT: TDateTime): TDateTime;
  function DaysApart (const DT1, DT2: TDateTime): LongInt;
  function Date2WeekNo (const DT: TDateTime): Integer;

  function DateIsLeapYear (const DT: TDateTime): Boolean;
  function ThisYear: Word;
  function GetFirstDayOfYear (const Year: Word): TDateTime;
  function GetLastDayOfYear (const Year: Word): TDateTime;

  function DateToSQLString(adate:TDateTime):string;
  function SQLStringToDate(atext:string):TDateTime;

  {test conversions}
  function isInteger(aStr:string):boolean;overload;
  function isfloat(svalue:string;var fvalue:extended):boolean;
  function isinteger(svalue:string;var ivalue:integer):boolean;overload;

  {conversions}
  function floattostrUS(value:double;decimals:integer):string;
  function floattostrNL(value:double;decimals:integer):string;
  function strUStofloat(value:string):double;
  function strNLtofloat(value:string):double;
  {quotes}
  function magic(aStr:string):string;
  function unquote(aStr:string):string;


  {name and value}
  function strName(aStr:string):string;
  function strValue(aStr:string):string;

  {template functions}
  function ReplaceFirst(sourceStr,findStr,replaceStr:string):string;
  function ReplaceLast(sourceStr,findStr,replaceStr:string):string;
  function GetBlock(sourceStr,blockStr:string):string;
  function InsertLastBlock(var sourceStr:string;blockStr:string):boolean;
  function InsertIndexBlock(var sourceStr:string;blockStr:string;index:integer):boolean;
  function removeMasterBlocks(sourceStr:string):string;
  function removeFields(sourceStr:string):string;
  function removeImages(sourceStr:string):string;
  function renumberFields(sourceStr:string):string;
  procedure gettemplatefields(aText:string;aList:TStringList);


  {http functions}
  function URLEncode(Value : String) : String; // Converts String To A URLEncoded String
  function URLDecode(Value : String) : String; // Converts String From A URLEncoded String
  function HTMLEncode(value:string):string;
  {set functions}
  procedure SplitSet(aText:string;aList:TStringList);
  function  JoinSet(aList:TstringList):string;
  function FirstOfSet(aText:string):string;
  function LastOfSet(aText:string):string;
  function CountOfSet(aText:string):integer;
  function SetRotateRight(aText:string):string;
  function SetRotateLeft(aText:string):string;
  function SetPick(aText:string;aIndex:integer):string;
  function SetSort(aText:string):string;
  function SetUnion(set1,set2:string):string;
  function SetIntersect(set1,set2:string):string;
  function SetExclude(set1,set2:string):string;

  {replace any <,> etc by &lt; &gt;}
  function XMLSafe(aText:string):string;

  {simple hash, result can be used in Encrypt}
  function Hash(aText:string):integer;

  { Base64 encode and decode a string }
  function B64Encode(const S: string): string;
  function B64Decode(const S: string): string;

  {Basic encryption from a Borland Example}
  function Encrypt(const InString:string; StartKey,MultKey,AddKey:Integer): string;
  function Decrypt(const InString:string; StartKey,MultKey,AddKey:Integer): string;

  {Using Encrypt and Decrypt in combination with B64Encode and B64Decode}
  function EncryptB64(const InString:string; StartKey,MultKey,AddKey:Integer): string;
  function DecryptB64(const InString:string; StartKey,MultKey,AddKey:Integer): string;


  procedure csv2tags(src,dst:TStringList);
  // converts a csv list to a tagged string list

  procedure tags2csv(src,dst:TStringList);
  // converts a tagged string list to a csv list
  // only fieldnames from the first record are scanned ib the other records

  procedure ListSelect(src,dst:TStringList;aKey,aValue:string);
  {selects akey=avalue from src and returns recordset in dst}

  procedure ListSelectSet(src,dst:TStringList;aKey,aValue:string);
  {selects akey in (avalue) from src and returns recordset in dst}
  {avalue is a comma seperated list of values}

  procedure ListFilter(src:TStringList;aKey,aValue:string);
  {filters src for akey=avalue}

  procedure ListOrderBy(src:TstringList;aKey:string;numeric:boolean);
  {orders a tagged src list by akey}

  procedure Split(asourcestring,asplitstring:string;alist:TStrings);
  {split sourcestring into multiple strings}
  function BeforeString(asource,aseparator:string):string;
  function AfterString(asource,aseparator:string):string;

   function PosStr(const FindString, SourceString: string;
    StartPos: Integer = 1): Integer;
{ PosStr searches the first occurrence of a substring FindString in a string
  given by SourceString with case sensitivity (upper and lower case characters
  are differed). This function returns the index value of the first character
  of a specified substring from which it occurs in a given string starting with
  StartPos character index. If a specified substring is not found Q_PosStr
  returns zero. The author of algorithm is Peter Morris (UK) (FastStrings unit
  from www.torry.ru). }

   function PosstrBefore(const FindString, SourceString:string;startPos:integer):integer;
   function PosStrLast(const FindString, SourceString:string):integer;
   {finds the last occurance}


   function StrRScan(const S: string; Ch: Char; LastPos: Integer = MaxInt): Integer;
   {scans from the right for a char position}


   function Removetags(aText:string):string;
   function PosTextHTML(const FindString,SourceString:string):integer;
   function PosText(const FindString, SourceString: string;
    StartPos: Integer = 1): Integer;
{ PosText searches the first occurrence of a substring FindString in a string
  given by SourceString without case sensitivity (upper and lower case
  characters are not differed). This function returns the index value of the
  first character of a specified substring from which it occurs in a given
  string starting with StartPos character index. If a specified substring is
  not found Q_PosStr returns zero. The author of algorithm is Peter Morris
  (UK) (FastStrings unit from www.torry.ru). }

   function PosTextWild(const FindString, SourceString: string;var count:integer;
    StartPos: Integer = 1): Integer;
   {finds a form ddhdjd*dvkdj and returns the length of the found string in count}

   function PosTextBefore(const FindString, SourceString:string;startPos:integer):integer;
   function PosTextLast(const FindString, SourceString:string):integer;
   {finds the last occurance}

   procedure Q_TinyCopy(Source, Dest: Pointer; L: Cardinal);
   procedure Q_CopyMem(Source, Dest: Pointer; L: Cardinal);
   function  Q_ReplaceStr(const SourceString, FindString, ReplaceString: string): string;
   function  Q_ReplaceText(const SourceString, FindString, ReplaceString: string): string;
   procedure Q_Delete(var S: string; Index, Count: Integer);

   function  NameValuesToXML(aText:string):string;
   procedure LoadResourceFile(aFile:string; ms:TMemoryStream);

   // file functions
   function  getappldir(appl:string):string;
   procedure DirFiles(aDir,amask:string; aFileList:TStringlist);
   procedure DirFilesEx(aDir:string; aFileList:TStringlist);
   procedure RecurseDirFilesReadOnly(myDir:string;setreadonly:boolean);
   procedure RecurseDirFiles(myDir:string; var aFileList:TStringlist);
   procedure FilterFileList(aExtensionSet:string;var aFileList:TStringList);
   procedure RecurseDirProgs(myDir:string; var aFileList:TStringlist);
   function GetLongPathName (const Filename: string): string;
   procedure SaveString(aFile, aText:string);
   function  LoadString(aFile:string):string;
   procedure SaveAppendString(aFile,aText:string);
   // HTML functions
   function  HexToColor(aText:string): Tcolor;
   function  ColorToHex(aColor:Tcolor):String;
   function UppercaseHTMLTags(aText:string):string;
   function LowercaseHTMLTags(aText:string):string;
   function  GetHTMLAnchors(aFile:string):string;
   function  GetHTMLLinks(aFile:string):string;
   function findClosingTag(source,tagname:string;startpos:integer;var foundpos:integer;casesensitive:boolean=false):boolean;
   function findOpeningTag(source,tagname:string;startpos:integer;var foundpos:integer;casesensitive:boolean=false):boolean;
   function GetZIPs(aSource:string):string;
   function UpdateFromZipper(pars,zipper:string):string;
   function newZip(aSource:string):string;
   function  GetAttribute(aName,aTag:string):string;
   function GetHTMLTag(avalue:string):string;
   function relativepath(aSrc,aDst:string):string;
   function  GetToken(var start:integer; SourceText:string):string;
   function PosNonSpace(Start:integer;SourceText:string):integer;
   function PosEscaped(Start:integer;SourceText,FindText:string;escapeChar:char):integer;
   function DeleteEscaped(SourceText:string;escapeChar:char):string;
   function BeginOfAttribute(Start:integer;SourceText:String):integer;
   // parses the beginning of an attribute: space + alpha character
   function  ParseAttribute(var Start:integer;SourceText:String; var aName:string;var aValue:string):boolean;
   // parses a name="value" attribute from Start; returns 0 when not found or else the position behind the attribute
   procedure ParseAttributes(SourceText:string; var Attributes:TStringList);
   // parses all name=value attributes to the attributes TStringlist
   function  HasStrValue(aText,aName:string; var aValue:string):boolean;
   // checks if a name="value" pair exists and returns any value
   function  GetStrValue(aText,aName,aDefault:string):string;
   // retrieves string value from a line like:
   //  name="jan verhoeven" email="jan1.verhoeven@wxs.nl"
   // returns aDefault when not found
   function  GetHTMLColorValue(aText,aName:string;aDefault:Tcolor):TColor;
   // same for a color
   function  GetIntValue(aText,aName:string;aDefault:Integer):integer;
   // same for an integer
   function  GetFloatValue(aText,aName:string;aDefault:extended):extended;
   // same for a float
   function GetBoolValue(aText,aName:string):boolean;
   // same for boolean but without default
   function  GetValue(aText,aName:string):string;
   // retrieves string value from a line like:
   //  name="jan verhoeven" email="jan1.verhoeven@wxs.nl"
   procedure SetValue(var aText:string; aName,aValue:string);
   // sets a string value in a line
   procedure DeleteValue(var aText:string; aName:string);
   // deletes a aName="value" pair from aText

   procedure GetNames(aText:string;aList:TStringList);
   // get a list of names from a string with name="value" pairs
   function  GetHTMLColor(aColor:TColor):string;
   // converts a color value to the HTML hex value
   function BackPosStr(start:integer;FindString, SourceString:string):integer;
   // finds a string backward case sensitive
   function BackPosText(start:integer;FindString, SourceString:string):integer;
   // finds a string backward case insensitive
   function PosRangeStr(Start:integer;HeadString,TailString,SourceString:string; var RangeBegin:integer; var RangeEnd:integer):boolean;
   // finds a text range, e.g. <TD>....</TD> case sensitive
   function PosRangeText(Start:integer;HeadString,TailString,SourceString:string; var RangeBegin:integer; var RangeEnd:integer):boolean;
   // finds a text range, e.g. <TD>....</td> case insensitive
   function BackPosRangeStr(Start:integer;HeadString,TailString,SourceString:string; var RangeBegin:integer; var RangeEnd:integer):boolean;
   // finds a text range backward, e.g. <TD>....</TD> case sensitive
   function BackPosRangeText(Start:integer;HeadString,TailString,SourceString:string; var RangeBegin:integer; var RangeEnd:integer):boolean;
   // finds a text range backward, e.g. <TD>....</td> case insensitive
   function PosTag(Start:integer;SourceString:string; var RangeBegin:integer; var RangeEnd:integer):boolean;
   // finds a HTML or XML tag:  <....>
   function Innertag(Start:integer;HeadString,TailString,SourceString:string; var RangeBegin:integer; var RangeEnd:integer):boolean;
   // finds the innertext between opening and closing tags
   function Easter( nYear: Integer ): TDateTime;
   // returns the easter date of a year.
   function getWeekNumber(today: Tdatetime): string;
  //gets a datecode. Returns year and weeknumber in format: YYWW

implementation


const
  cr = chr(13)+chr(10);
  tab = chr(9);

  B64Table= 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  ValidURLChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$-_@.&+-!*"''(),;/#?:';

  ToUpperChars: array[0..255] of Char =
    (#$00,#$01,#$02,#$03,#$04,#$05,#$06,#$07,#$08,#$09,#$0A,#$0B,#$0C,#$0D,#$0E,#$0F,
     #$10,#$11,#$12,#$13,#$14,#$15,#$16,#$17,#$18,#$19,#$1A,#$1B,#$1C,#$1D,#$1E,#$1F,
     #$20,#$21,#$22,#$23,#$24,#$25,#$26,#$27,#$28,#$29,#$2A,#$2B,#$2C,#$2D,#$2E,#$2F,
     #$30,#$31,#$32,#$33,#$34,#$35,#$36,#$37,#$38,#$39,#$3A,#$3B,#$3C,#$3D,#$3E,#$3F,
     #$40,#$41,#$42,#$43,#$44,#$45,#$46,#$47,#$48,#$49,#$4A,#$4B,#$4C,#$4D,#$4E,#$4F,
     #$50,#$51,#$52,#$53,#$54,#$55,#$56,#$57,#$58,#$59,#$5A,#$5B,#$5C,#$5D,#$5E,#$5F,
     #$60,#$41,#$42,#$43,#$44,#$45,#$46,#$47,#$48,#$49,#$4A,#$4B,#$4C,#$4D,#$4E,#$4F,
     #$50,#$51,#$52,#$53,#$54,#$55,#$56,#$57,#$58,#$59,#$5A,#$7B,#$7C,#$7D,#$7E,#$7F,
     #$80,#$81,#$82,#$81,#$84,#$85,#$86,#$87,#$88,#$89,#$8A,#$8B,#$8C,#$8D,#$8E,#$8F,
     #$80,#$91,#$92,#$93,#$94,#$95,#$96,#$97,#$98,#$99,#$8A,#$9B,#$8C,#$8D,#$8E,#$8F,
     #$A0,#$A1,#$A1,#$A3,#$A4,#$A5,#$A6,#$A7,#$A8,#$A9,#$AA,#$AB,#$AC,#$AD,#$AE,#$AF,
     #$B0,#$B1,#$B2,#$B2,#$A5,#$B5,#$B6,#$B7,#$A8,#$B9,#$AA,#$BB,#$A3,#$BD,#$BD,#$AF,
     #$C0,#$C1,#$C2,#$C3,#$C4,#$C5,#$C6,#$C7,#$C8,#$C9,#$CA,#$CB,#$CC,#$CD,#$CE,#$CF,
     #$D0,#$D1,#$D2,#$D3,#$D4,#$D5,#$D6,#$D7,#$D8,#$D9,#$DA,#$DB,#$DC,#$DD,#$DE,#$DF,
     #$C0,#$C1,#$C2,#$C3,#$C4,#$C5,#$C6,#$C7,#$C8,#$C9,#$CA,#$CB,#$CC,#$CD,#$CE,#$CF,
     #$D0,#$D1,#$D2,#$D3,#$D4,#$D5,#$D6,#$D7,#$D8,#$D9,#$DA,#$DB,#$DC,#$DD,#$DE,#$DF);

  ToLowerChars: array[0..255] of Char =
    (#$00,#$01,#$02,#$03,#$04,#$05,#$06,#$07,#$08,#$09,#$0A,#$0B,#$0C,#$0D,#$0E,#$0F,
     #$10,#$11,#$12,#$13,#$14,#$15,#$16,#$17,#$18,#$19,#$1A,#$1B,#$1C,#$1D,#$1E,#$1F,
     #$20,#$21,#$22,#$23,#$24,#$25,#$26,#$27,#$28,#$29,#$2A,#$2B,#$2C,#$2D,#$2E,#$2F,
     #$30,#$31,#$32,#$33,#$34,#$35,#$36,#$37,#$38,#$39,#$3A,#$3B,#$3C,#$3D,#$3E,#$3F,
     #$40,#$61,#$62,#$63,#$64,#$65,#$66,#$67,#$68,#$69,#$6A,#$6B,#$6C,#$6D,#$6E,#$6F,
     #$70,#$71,#$72,#$73,#$74,#$75,#$76,#$77,#$78,#$79,#$7A,#$5B,#$5C,#$5D,#$5E,#$5F,
     #$60,#$61,#$62,#$63,#$64,#$65,#$66,#$67,#$68,#$69,#$6A,#$6B,#$6C,#$6D,#$6E,#$6F,
     #$70,#$71,#$72,#$73,#$74,#$75,#$76,#$77,#$78,#$79,#$7A,#$7B,#$7C,#$7D,#$7E,#$7F,
     #$90,#$83,#$82,#$83,#$84,#$85,#$86,#$87,#$88,#$89,#$9A,#$8B,#$9C,#$9D,#$9E,#$9F,
     #$90,#$91,#$92,#$93,#$94,#$95,#$96,#$97,#$98,#$99,#$9A,#$9B,#$9C,#$9D,#$9E,#$9F,
     #$A0,#$A2,#$A2,#$BC,#$A4,#$B4,#$A6,#$A7,#$B8,#$A9,#$BA,#$AB,#$AC,#$AD,#$AE,#$BF,
     #$B0,#$B1,#$B3,#$B3,#$B4,#$B5,#$B6,#$B7,#$B8,#$B9,#$BA,#$BB,#$BC,#$BE,#$BE,#$BF,
     #$E0,#$E1,#$E2,#$E3,#$E4,#$E5,#$E6,#$E7,#$E8,#$E9,#$EA,#$EB,#$EC,#$ED,#$EE,#$EF,
     #$F0,#$F1,#$F2,#$F3,#$F4,#$F5,#$F6,#$F7,#$F8,#$F9,#$FA,#$FB,#$FC,#$FD,#$FE,#$FF,
     #$E0,#$E1,#$E2,#$E3,#$E4,#$E5,#$E6,#$E7,#$E8,#$E9,#$EA,#$EB,#$EC,#$ED,#$EE,#$EF,
     #$F0,#$F1,#$F2,#$F3,#$F4,#$F5,#$F6,#$F7,#$F8,#$F9,#$FA,#$FB,#$FC,#$FD,#$FE,#$FF);

  CONST
    crctable:  ARRAY[0..255] OF DWORD =
   ($00000000, $77073096, $EE0E612C, $990951BA,
    $076DC419, $706AF48F, $E963A535, $9E6495A3,
    $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988,
    $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91,
    $1DB71064, $6AB020F2, $F3B97148, $84BE41DE,
    $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
    $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC,
    $14015C4F, $63066CD9, $FA0F3D63, $8D080DF5,
    $3B6E20C8, $4C69105E, $D56041E4, $A2677172,
    $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B,
    $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940,
    $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
    $26D930AC, $51DE003A, $C8D75180, $BFD06116,
    $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F,
    $2802B89E, $5F058808, $C60CD9B2, $B10BE924,
    $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D,

    $76DC4190, $01DB7106, $98D220BC, $EFD5102A,
    $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433,
    $7807C9A2, $0F00F934, $9609A88E, $E10E9818,
    $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01,
    $6B6B51F4, $1C6C6162, $856530D8, $F262004E,
    $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457,
    $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C,
    $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65,
    $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2,
    $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB,
    $4369E96A, $346ED9FC, $AD678846, $DA60B8D0,
    $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9,
    $5005713C, $270241AA, $BE0B1010, $C90C2086,
    $5768B525, $206F85B3, $B966D409, $CE61E49F,
    $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4,
    $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD,

    $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A,
    $EAD54739, $9DD277AF, $04DB2615, $73DC1683,
    $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8,
    $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1,
    $F00F9344, $8708A3D2, $1E01F268, $6906C2FE,
    $F762575D, $806567CB, $196C3671, $6E6B06E7,
    $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC,
    $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5,
    $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252,
    $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
    $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60,
    $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79,
    $CB61B38C, $BC66831A, $256FD2A0, $5268E236,
    $CC0C7795, $BB0B4703, $220216B9, $5505262F,
    $C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04,
    $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,

    $9B64C2B0, $EC63F226, $756AA39C, $026D930A,
    $9C0906A9, $EB0E363F, $72076785, $05005713,
    $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38,
    $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21,
    $86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E,
    $81BE16CD, $F6B9265B, $6FB077E1, $18B74777,
    $88085AE6, $FF0F6A70, $66063BCA, $11010B5C,
    $8F659EFF, $F862AE69, $616BFFD3, $166CCF45,
    $A00AE278, $D70DD2EE, $4E048354, $3903B3C2,
    $A7672661, $D06016F7, $4969474D, $3E6E77DB,
    $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0,
    $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
    $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6,
    $BAD03605, $CDD70693, $54DE5729, $23D967BF,
    $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94,
    $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);

procedure InitTables;
var
  I, K: Char;
  Temp: Byte;
begin
  for I := #0 to #255 do
  begin
    janHashTable[I] := Ord(I);
  end;
  RandSeed := 255;
  for I := #1 to #255 do
  begin
    repeat
      K := Char(Random(255));
    until K <> #0;
    Temp := janHashTable[I];
    janHashTable[I] := janHashTable[K];
    janHashTable[K] := Temp;
  end;
  for I := #0 to #255 do
    janInsensitiveHashTable[I] := janHashTable[AnsiLowerCase(string(I))[1]];
end;


function CrcHash(const aString: string): integer;
var
  I: Integer;
begin
  Result := 0;
  for i := 1 to length(aString) do
  begin
    Result := (Result shr 4) xor (((Result xor janHashTable[aString[I]]) and $F) * $1000);
    Result := (Result shr 4) xor (((Result xor (ord(janHashTable[aString[I]]) shr 4)) and $F) * $1000);
  end;
  if Result = 0 then Result := Length(aString) mod 8 + 1;
end;

  // Use CalcCRC32 as a procedure so CRCValue can be passed in but
  // also returned.  This allows multiple calls to CalcCRC32 for
  // the "same" CRC-32 calculation.
procedure CalcCRC32 (p:  pointer; ByteCount:  DWORD; VAR CRCValue:  DWORD);
    // The following is a little cryptic (but executes very quickly).
    // The algorithm is as follows:
    //  1.  exclusive-or the input byte with the low-order byte of
    //      the CRC register to get an INDEX
    //  2.  shift the CRC register eight bits to the right
    //  3.  exclusive-or the CRC register with the contents of
    //      Table[INDEX]
    //  4.  repeat steps 1 through 3 for all bytes

   VAR
    i:  DWORD;
    q:  ^BYTE;
  BEGIN
    q := p;
    FOR   i := 0 TO ByteCount-1 DO BEGIN
      CRCvalue := (CRCvalue SHR 8)  XOR
                  crcTable[ q^ XOR (CRCvalue AND $000000FF) ];
      INC(q)
    END
  END {CalcCRC32};


function Crc32Hash(const aString:string):integer;
var
 CRC32:  DWORD;
 s:string;
begin
  s:=aString;
  CRC32 := $FFFFFFFF;   // To match PKZIP
  CalcCRC32 (Addr(s[1]), LENGTH(s), CRC32);
  result := NOT CRC32;   // TO match PKZIP
end;

procedure SaveString(aFile, aText:string);
begin
  with TFileStream.Create(aFile, fmCreate) do try
    writeBuffer(aText[1],length(aText));
    finally free; end;
end;

function  LoadString(aFile:string):string;
var s:string;
begin
  with TFileStream.Create(aFile, fmOpenRead) do try
      SetLength(s, Size);
      ReadBuffer(s[1], Size);
    finally free; end;
  result:=s;
end;

procedure SaveAppendString(aFile,aText:string);
begin
  if not fileexists(aFile) then
    SaveString(aFile,'');
  with TFileStream.Create(aFile, fmOpenReadWrite) do try
    Seek(0,soFromEnd);	
    writeBuffer(aText[1],length(aText));
    finally free; end;
end;


procedure DeleteValue(var aText:string; aName:string);
var
   p,p2,L:integer;
begin
   L:=length(aName)+2;
   p:=PosText(aName+'="',aText);
   if p=0 then exit;
   p2:=PosStr('"',aText,p+L);
   if p2=0 then exit;
   if p>1 then dec(p); // include the preceeding space if not the first one
   delete(aText,p,p2-p+1);
end;

function GetValue(aText,aName:string):string;
var
   p,p2,L:integer;
begin
   result:='';
   L:=length(aName)+2;
   p:=PosText(aName+'="',aText);
   if p=0 then exit;
   p2:=PosStr('"',aText,p+L);
   if p2=0 then exit;
   result:=copy(atext,p+L,p2-(p+L));
   result:=stringreplace(result,'~~',cr,[rfreplaceall]);
end;

function HasStrValue(aText,aName:string; var aValue:string):boolean;
var
   p,p2,L: integer;
   s: string;
begin
   result:=false;
   L:=length(aName)+2;
   p:=PosText(aName+'="',aText);
   if p=0 then exit;
   p2:=PosStr('"',aText,p+L);
   if p2=0 then exit;
   s:=copy(atext,p+L,p2-(p+L));
   aValue:=stringreplace(s,'~~',cr,[rfreplaceall]);
end;


function GetStrValue(aText,aName,aDefault:string):string;
var s:string;
begin
  s:='';
  if hasStrValue(aText,aName,s) then
    result:=s
  else
    result:=aDefault;
end;

function GetIntValue(aText,aName:string;aDefault:Integer):integer;
var s:string;
begin
  s:=getValue(aText,aName);
  try
    result:=strtoint(s);
  except
    result:=adefault;
  end;
end;

function  GetFloatValue(aText,aName:string;aDefault:extended):extended;
var s:string;
begin
  s:='';
  if hasStrValue(aText,aName,s) then
    try
      result:=strtofloat(s);
    except
      result:=aDefault;
    end
  else
    result:=aDefault;
end;

function GetHTMLColorValue(aText,aName:string;aDefault:Tcolor):TColor;
var s:string;
begin
  s:='';
  if hasStrValue(aText,aName,s) then begin
    if copy(s,1,1)='#' then begin
      s:='$'+copy(s,6,2)+copy(s,4,2)+copy(s,2,2);
    end
    else
      s:='cl'+s;
    try
      result:=stringtocolor(s);
    except
      result:=aDefault;
    end;
  end
  else
    result:=aDefault;
end;

procedure SetValue(var aText:string; aName,aValue:string);
var
   p,p2,L:integer;
begin
  l:=length(aName)+2;
  if aText='' then
  begin
    aText:=aName+'="'+aValue+'"';
  end
  else begin
    p:=PosText(aName+'="',aText);
    if p=0 then
    begin
      aText:=aText+' '+aName+'="'+aValue+'"';
    end
    else begin
      p2:=PosStr('"',aText,p+L);
      if p2=0 then exit;
      Delete(aText,p+L,p2-(p+L));
      insert(aValue,aText,p+L);
    end;
  end;
end;

function GetHTMLColor(aColor:TColor):string;
begin
  result:=format('%6.6x',[colortorgb(acolor)]);
  result:='="#'+copy(result,5,2)+copy(result,3,2)+copy(result,1,2)+'"';
end;

function BackPosStr(start:integer;FindString, SourceString:string):integer;
var p,L:integer;
begin
  result:=0;
  L:=length(FindString);
  if (L=0) or (SourceString='') or (start<2) then exit;
  Start:=Start-L;
  if Start<1 then exit;
  repeat
    p:=PosStr(FindString,SourceString,Start);
    if p<Start then
    begin
      result:=p;
      exit;
    end;
    Start:=Start-L;
  until Start<1;
end;

function BackPosText(start:integer;FindString, SourceString:string):integer;
var p,L,from:integer;
begin
  result:=0;
  L:=length(FindString);
  if (L=0) or (SourceString='') or (start<2) then exit;
  from:=Start-L;
  if from<1 then exit;
  repeat
    p:=PosText(FindString,SourceString,from);
    if (p>0) and (p<Start) then
    begin
      result:=p;
      exit;
    end;
    from:=from-L;
  until from<1;
end;

function PosRangeStr(Start:integer;HeadString,TailString,SourceString:string; var RangeBegin:integer; var RangeEnd:integer):boolean;
begin
  result:=false;
  RangeBegin:=PosStr(HeadString,SourceString,Start);
  if RangeBegin=0 then exit;
  RangeEnd:=PosStr(TailString,SourceString,RangeBegin+Length(HeadString));
  if RangeEnd=0 then exit;
  RangeEnd:=RangeEnd+length(TailString)-1;
  result:=true;
end;

function PosRangeText(Start:integer;HeadString,TailString,SourceString:string; var RangeBegin:integer; var RangeEnd:integer):boolean;
begin
  result:=false;
  RangeBegin:=PosText(HeadString,SourceString,Start);
  if RangeBegin=0 then exit;
  RangeEnd:=PosText(TailString,SourceString,RangeBegin+Length(HeadString));
  if RangeEnd=0 then exit;
  RangeEnd:=RangeEnd+length(TailString)-1;
  result:=true;
end;

function Innertag(Start:integer;HeadString,TailString,SourceString:string; var RangeBegin:integer; var RangeEnd:integer):boolean;
begin
  result:=false;
  RangeBegin:=PosText(HeadString,SourceString,Start);
  if RangeBegin=0 then exit;
  RangeBegin:=RangeBegin+length(HeadString);
  RangeEnd:=PosText(TailString,SourceString,RangeBegin+Length(HeadString));
  if RangeEnd=0 then exit;
  RangeEnd:=RangeEnd-1;
  result:=true;
end;


function PosTag(Start:integer;SourceString:string; var RangeBegin:integer; var RangeEnd:integer):boolean;
begin
  result:=PosRangeStr(Start,'<','>',SourceString,RangeBegin,RangeEnd);
end;

function BackPosRangeStr(Start:integer;HeadString,TailString,SourceString:string; var RangeBegin:integer; var RangeEnd:integer):boolean;
var
   L:integer;
begin
   // finds a text range backward, e.g. <TD>....</TD> case sensitive
  result:=false;
  L:=length(HeadString);
  if (L=0) or (start<2) then exit;
  Start:=Start-L;
  if Start<1 then exit;
  repeat
    if not PosRangeStr(Start,HeadString,TailString,SourceString,RangeBegin,RangeEnd) then exit;
    if RangeBegin<Start then
    begin
      result:=true;
      exit;
    end;
    Start:=Start-L;
  until Start<1;
end;

function BackPosRangeText(Start:integer;HeadString,TailString,SourceString:string; var RangeBegin:integer; var RangeEnd:integer):boolean;
var
   L:integer;
begin
   // finds a text range backward, e.g. <TD>....</TD> case insensitive
  result:=false;
  L:=length(HeadString);
  if (L=0) or (start<2) then exit;
  Start:=Start-L;
  if Start<1 then exit;
  repeat
    if not PosRangeText(Start,HeadString,TailString,SourceString,RangeBegin,RangeEnd) then exit;
    if RangeBegin<Start then
    begin
      result:=true;
      exit;
    end;
    Start:=Start-L;
  until Start<1;
end;

function PosNonSpace(Start:integer;SourceText:string):integer;
var p,L:integer;
begin
  result:=0;
  L:=length(SourceText);
  p:=Start;
  if L=0 then exit;
  while (p<L) and (SourceText[p]=' ') do inc(p);
  if SourceText[p]<>' ' then result:=p;
end;

function BeginOfAttribute(Start:integer;SourceText:String):integer;
var p,L:integer;
begin
   // parses the beginning of an attribute: space + alpha character
   result:=0;
   L:=length(SourceText);
   if L=0 then exit;
   p:=PosStr(' ',Sourcetext,start);
   if p=0 then exit;
   p:=PosNonSpace(p,SourceText);
   if p=0 then exit;
   if (SourceText[p] in ['a'..'z','A'..'Z']) then
     result:=p;
end;

function  ParseAttribute(var Start:integer;SourceText:String; var aName:string;var aValue:string):boolean;
var pn,pv,p:integer;
begin
  // parses a name="value" attribute from Start; returns 0 when not found or else the position behind the attribute
  result:=false;
  pn:=BeginOfAttribute(Start,SourceText);
  if pn=0 then exit;
  p:=PosStr('="',SourceText,pn);
  if p=0 then exit;
  aName:=trim(copy(SourceText,pn,p-pn));
  pv:=p+2;
  p:=PosStr('"',SourceText,pv);
  if p=0 then exit;
  aValue:=copy(SourceText,pv,p-pv);
  start:=p+1;
  result:=true;
end;

procedure ParseAttributes(SourceText:string; var Attributes:TStringList);
var aName, aValue:string;
    start:integer;
begin
  Attributes.Clear;
  start:=1;
  while ParseAttribute(Start,SourceText,aName,aValue) do
    Attributes.Append(aName+'='+aValue);
end;

function  GetToken(var start:integer; SourceText:string):string;
var p1,p2:integer;
begin
  result:='';
  if start>length(sourceText) then exit;
  p1:=posNonSpace(Start,SourceText);
  if p1=0 then exit;
  if SourceText[p1]='"' then
  begin // quoted token
    p2:=PosStr('"',SourceText,p1+1);
    if p2=0 then exit;
    result:=copy(SourceText,p1+1,p2-p1-1);
    start:=p2+1;
  end
  else begin
    p2:=PosStr(' ',SourceText,p1+1);
    if p2=0 then p2:=length(sourcetext)+1;
    result:=copy(SourceText,p1,p2-p1);
    start:=p2;
  end;
end;

function Easter( nYear: Integer ): TDateTime;
var
   nMonth, nDay, nMoon, nEpact, nSunday, nGold, nCent, nCorx, nCorz: Integer;
 begin

    { The Golden Number of the year in the 19 year Metonic Cycle }
    nGold := ( ( nYear mod 19 ) + 1  );

    { Calculate the Century }
    nCent := ( ( nYear div 100 ) + 1 );

    { No. of Years in which leap year was dropped in order to keep in step
      with the sun }
    nCorx := ( ( 3 * nCent ) div 4 - 12 );

    { Special Correction to Syncronize Easter with the moon's orbit }
    nCorz := ( ( 8 * nCent + 5 ) div 25 - 5 );

    { Find Sunday }
    nSunday := ( ( 5 * nYear ) div 4 - nCorx - 10 );

    { Set Epact (specifies occurance of full moon }
    nEpact := ( ( 11 * nGold + 20 + nCorz - nCorx ) mod 30 );

    if ( nEpact < 0 ) then
       nEpact := nEpact + 30;

    if ( ( nEpact = 25 ) and ( nGold > 11 ) ) or ( nEpact = 24 ) then
       nEpact := nEpact + 1;

    { Find Full Moon }
    nMoon := 44 - nEpact;

    if ( nMoon < 21 ) then
       nMoon := nMoon + 30;

    { Advance to Sunday }
    nMoon := ( nMoon + 7 - ( ( nSunday + nMoon ) mod 7 ) );

    if ( nMoon > 31 ) then
       begin
         nMonth := 4;
         nDay   := ( nMoon - 31 );
       end
    else
       begin
         nMonth := 3;
         nDay   := nMoon;
       end;

    Result := EncodeDate( nYear, nMonth, nDay );

 end;

//gets a datecode. Returns year and weeknumber in format: YYWW
function getWeekNumber(today: Tdatetime): string;

{dayOfWeek function returns integer 1..7 equivalent to Sunday..Saturday.
ISO 8601 weeks start with Monday and the first week of a year is the one which
includes the first Thursday - Fiddle takes care of all this}

const Fiddle : array[1..7] of Byte = (6,7,8,9,10,4,5);

var
	present, startOfYear: Tdatetime;
	firstDayOfYear, weekNumber, numberOfDays: integer;
	year, month, day: word;
	YearNumber: string;

begin
	present:= trunc(today); //truncate to remove hours, mins and secs
	decodeDate(present, year, month, day); //decode to find year
	startOfYear:= encodeDate(year, 1, 1);  //encode 1st Jan of the year

  //find what day of week 1st Jan is, then add days according to rule
	firstDayOfYear:= Fiddle[dayOfWeek(startOfYear)];

	//calc number of days since beginning of year + additional according to rule
	numberOfDays:= trunc(present - startOfYear) + firstDayOfYear;

	//calc number of weeks
	weekNumber:= trunc(numberOfDays / 7);

	//Format year, needed to prevent millenium bug and keep the Fluffy Spangle happy
	YearNumber:= formatDateTime('yyyy',present);

	YearNumber:= YearNumber + 'W';

	if weekNumber < 10 then
    YearNumber:= YearNumber + '0';//add leading zero for week

	//create datecode string
	result:= YearNumber + inttostr(weekNumber);

  if weekNumber = 0 then //recursive call for year begin/end...
    //see if previous year end was week 52 or 53
    result:= getWeekNumber(encodeDate(year - 1, 12, 31))

  else if weekNumber = 53 then
    //if 31st December less than Thursday then must be week 01 of next year
    if dayOfWeek(encodeDate(year, 12, 31)) < 5 then
    begin
      YearNumber:= formatDateTime('yyyy',encodeDate(year + 1, 1, 1));
      result:= YearNumber + 'W01';
    end;

end;

function relativepath(aSrc,aDst:string):string;
var doc,sdoc,pardoc,img,simg,parimg,rel:string;
    pdoc,pimg: integer;
begin
  doc:=aSrc;
  img:=aDst;
  repeat
    pdoc:=pos('\',doc);
    if pdoc>0 then begin
      pardoc:=copy(doc,1,pdoc);
      pardoc[length(pardoc)]:='/';
      sdoc:=sdoc+pardoc;
      delete(doc,1,pdoc);
    end;
    pimg:=pos('\',img);
    if pimg>0 then begin
      parimg:=copy(img,1,pimg);
      parimg[length(parimg)]:='/';
      simg:=simg+parimg;
      delete(img,1,pimg);
    end;
    if (pdoc>0) and (pimg>0) and (sdoc<>simg) then
      rel:='../'+rel+parimg;
    if (pdoc=0) and (pimg<>0) then
    begin
      rel:=rel+parimg+img;
      if pos(':',rel)>0 then rel:='';
      result:=rel;
      exit;
    end;
    if (pdoc>0) and (pimg=0) then
    begin
      rel:='../'+rel;
    end;
  until (pdoc=0) and (pimg=0);
  rel:=rel+extractfilename(img);
  if pos(':',rel)>0 then rel:='';
  result:=rel;
end;

function GetHTMLAnchors(aFile:string):string;
var s,sa,sb:string;
    p1,p2:integer;
begin
  s:=LoadString(aFile);
  result:='';
  p1:=1;
  repeat
    p1:=posText('<a ',s,p1);
    if p1=0 then exit;
    p2:=posText('>',s,p1);
    if p2=0 then exit;
    sa:=copy(s,p1,p2-p1+1);
    sb:=GetAttribute('name',sa);
    if sb<>'' then begin
      if result='' then
        result:=sb
      else
        result:=result+cr+sb;
    end;
    p1:=p2+1;
  until p1=0;
end;

function GetHTMLTag(avalue:string):string;
var
  p1,p2:integer;
  tmp:string;
begin
  result:='';
  p1:=pos('<',avalue);
  if p1=0 then exit;
  p2:=posstr('>',avalue,p1);
  if p2=0 then exit;
  tmp:=copy(avalue,p1+1,p2-p1-1);
  p1:=pos(' ',tmp);
  if p1>0 then
    result:=copy(tmp,1,p1-1)
  else
    result:=tmp;  

end;

function  GetAttribute(aName,aTag:string):string;
var
  p1: integer;
  sa: string;
begin
  result:='';
  p1:=posText(aName,aTag);
  if p1=0 then exit;
  p1:=posStr('=',aTag,p1+length(aName));
  if p1=0 then exit;
  sa:=trim(copy(aTag,p1+1,maxint));
  // test quote
  if sa='' then exit;
  if sa[1]='"' then begin
    delete(sa,1,1);
    p1:=pos('"',sa);
    if p1=0 then exit;
    result:=copy(sa,1,p1-1);
    exit;
  end
  else if sa[1]='''' then begin
    delete(sa,1,1);
    p1:=pos('''',sa);
    if p1=0 then exit;
    result:=copy(sa,1,p1-1);
    exit;
  end
  else begin  // no quotes
    p1:=pos(' ',sa);
    if p1>0 then begin
      result:=copy(sa,1,p1-1);
      exit;
    end;
    if copy(sa,length(sa),1)<>'>' then exit;
    result:=copy(sa,1,length(sa)-1);
  end;
end;

function GetHTMLLinks(aFile:string):string;
var s,sa,sb:string;
    p1,p2:integer;
begin
  s:=LoadString(aFile);
  result:='';
  p1:=1;
  repeat
    p1:=posText('<a ',s,p1);
    if p1=0 then exit;
    p2:=posText('>',s,p1);
    if p2=0 then exit;
    sa:=copy(s,p1,p2-p1+1);
    sb:=GetAttribute('href',sa);
    if sb<>'' then begin
      if result='' then
        result:=sb
      else
        result:=result+cr+sb;
    end;
    p1:=p2+1;
  until p1=0;
end;


function UppercaseHTMLTags(aText:string):string;
var
  p:integer;
  bTag:boolean;
  bMarkup:boolean;
begin
  result:=aText;
  if result='' then exit;
  bTag:=false;
  bMarkup := False;
  for p:=1 to length(result) do begin
    if result[p]='<' then begin
      bTag:=true;
      bMarkup:=true;
    end
    else if result[p]='>' then begin
      bTag:=false;
      bMarkup:=false;
    end
    else if bTag and (result[p]=' ') then
      bMarkup:=false
    else if (bTag and bMarkup) then
      result[p]:=toupperchars[ord(result[p])];
  end;
end;

function LowercaseHTMLTags(aText:string):string;
var
  p:integer;
  bTag:boolean;
  bMarkup:boolean;
begin
  result:=aText;
  if result='' then exit;
  bTag:=false;
  bMarkup := false;

  for p:=1 to length(result) do
  begin
    if result[p]='<' then begin
      bTag:=true;
      bMarkup:=true;
    end
    else if result[p]='>' then begin
      bTag:=false;
      bMarkup:=false;
    end
    else if bTag and (result[p]=' ') then
      bMarkup:=false
    else if (bTag and bMarkup) then
      result[p]:=tolowerchars[ord(result[p])];
  end;
end;

function  HexToColor(aText:string):Tcolor;
begin
  result:=clblack;
  if length(aText)<>7 then exit;
  if aText[1]<>'#' then exit;
  aText:='$'+copy(AText,6,2)+ copy(AText,4,2)+copy(AText,2,2);
  try
    result:=stringtocolor(aText);
  except
    result:=clblack;
  end;

end;

function  ColorToHex(aColor:TColor):String;
begin
  result:=format('%6.6x',[acolor]);
  result:='#'+copy(result,5,2)+copy(result,3,2)+copy(result,1,2);
end;

function PosEscaped(Start:integer;SourceText,FindText:string;escapeChar:char):integer;
begin
  result:=PosText(FindText,SourceText,Start);
  if result=0 then exit;
  if result=1 then exit;
  if SourceText[result-1]<>escapeChar then exit;
  repeat
    result:=PosText(FindText,SourceText,result+1);
    if result=0 then exit;
  until SourceText[result-1]<>escapeChar;
end;

function DeleteEscaped(SourceText:string;escapeChar:char):string;
var i:integer;
begin
  i:=1;
  repeat
    if SourceText[i]=escapeChar then
      delete(SourceText,i,1);
    i:=i+1;
  until i>length(SourceText);
  result:=SourceText;

end;

procedure FilterFileList(aExtensionSet:string;var aFileList:TStringList);
var
  s,e:string;
  i,c:integer;
begin
  c:=aFileList.count;
  if c=0 then exit;
  s:=lowercase(aExtensionSet);
  if s='' then exit;
  s:='['+stringreplace(s,',','][',[rfreplaceall])+']';
  for i:=c-1 downto 0 do begin
    e:=lowercase(extractfileext(afileList[i]));
    e:='['+copy(e,2,maxint)+']';
    if postext(e,s)=0 then
      aFileList.Delete(i);
  end;
end;

procedure RecurseDirFiles(myDir:string; var aFileList:TStringlist);
var
    sr: TSearchRec;
    FileAttrs: Integer;
begin
     FileAttrs := faAnyfile;
     if FindFirst(myDir+'\*.*', FileAttrs, sr) = 0 then
     while FindNext(sr) = 0 do
     begin
       if (sr.Attr and faDirectory)<>0 then
       begin
         if (sr.name<>'.') and (sr.name<>'..') then
           RecurseDirFiles(myDir+'\'+sr.Name,aFileList);
       end
       else if (sr.Attr and faAnyFile)<>0 then
       begin
         aFileList.AddObject(mydir+'\'+sr.name,TObject(sr.size));
//         aFileList.append(myDir+'\'+sr.Name);
       end;
     end;
     FindClose(sr);
end;




procedure RecurseDirProgs(myDir:string; var aFileList:TStringlist);
var
    sr: TSearchRec;
    FileAttrs: Integer;
    e:string;
begin
     FileAttrs := faAnyFile;
     if FindFirst(myDir+'\*.*', FileAttrs, sr) = 0 then
     while FindNext(sr) = 0 do
     begin
       if (sr.Attr and faDirectory)<>0 then
       begin
         if (sr.name<>'.') and (sr.name<>'..') then
           RecurseDirProgs(myDir+'\'+sr.Name,aFileList);
       end
       else if (sr.Attr and faAnyFile)<>0 then
       begin
         e:=lowercase(extractfileext(sr.name));
         if e='.exe' then
           aFileList.append(myDir+'\'+sr.Name);
       end;
     end;
     FindClose(sr);
end;



procedure LoadResourceFile(aFile:string; ms:TMemoryStream);
var
   HResInfo: HRSRC;
   HGlobal: THandle;
   Buffer, GoodType : pchar;
   Ext:string;
begin
  ext:=uppercase(extractfileext(aFile));
  ext:=copy(ext,2,length(ext));
  if ext='HTM' then ext:='HTML';
  if ext='CSS' then ext:='HTML';
  Goodtype:=pchar(ext);
  aFile:=changefileext(afile,'');
  HResInfo := FindResource(HInstance, pchar(aFile), GoodType);
  HGlobal := LoadResource(HInstance, HResInfo);
  if HGlobal = 0 then
     raise EResNotFound.Create('Can''t load resource: '+aFile);
  Buffer := LockResource(HGlobal);
  ms.clear;
  ms.WriteBuffer(Buffer[0], SizeOfResource(HInstance, HResInfo));
  ms.Seek(0,0);
  UnlockResource(HGlobal);
  FreeResource(HGlobal);
end;

procedure GetNames(aText:string;aList:TStringList);
var p:integer;
    s:string;
begin
  alist.clear;
  repeat
    aText:=Trim(aText);
    p:=pos('="',aText);
    if p>0 then begin
      s:=copy(aText,1,p-1);
      alist.append(s);
      delete(aText,1,p+1);
      p:=pos('"',atext);
      if p>0 then begin
        delete(aText,1,p);
      end;
    end;
  until p=0;
end;

function NameValuesToXML(aText:string):string;
var alist:TStringlist;
    i,c:integer;
    iname,ivalue,xml:string;
begin
  result:='';
  if aText='' then exit;
  aList:=tstringlist.create;
  GetNames(aText,aList);
  c:=alist.count;
  if c=0 then begin alist.free; exit end;
  xml:='<accountdata>'+cr;
  for i:=0 to c-1 do begin
    iname:=alist[i];
    ivalue:=getvalue(aText,iname);
    ivalue:=stringreplace(ivalue,'~~',cr,[rfreplaceall]);
    xml:=xml+'<'+iname+'>'+cr;
    xml:=xml+'  '+ivalue+cr;
    xml:=xml+'</'+iname+'>'+cr;
  end;
  xml:=xml+'</accountdata>'+cr;
  alist.free;
  result:=xml;
end;

procedure Split(asourcestring,asplitstring:string;alist:TStrings);
var
  p1,p2,L:integer;
begin
  alist.Clear;
  L:=length(asourcestring);
  if L=0 then exit;
  if asplitstring='' then begin
    alist.Append(asourcestring);
    exit;
  end;
  p2:=1;
  repeat
    p1:=posstr(asplitstring,asourcestring,p2);
    if p1>0 then begin
      alist.append(copy(asourcestring,p2,p1-p2));
      p2:=p1+1;
    end
  until (p1=0) or (p2>L);
  if p2<L-1 then
    alist.append(copy(asourcestring,p2,maxint));
end;

function BeforeString(asource,aseparator:string):string;
var
  p:integer;
begin
  result:='';
  if (asource='') or (aseparator='') then exit;
  p:=posstr(aseparator,asource);
  if p=0 then exit;
  result:=copy(asource,1,p-1);
end;

function AfterString(asource,aseparator:string):string;
var
  p:integer;
begin
  result:='';
  if (asource='') or (aseparator='') then exit;
  p:=posstr(aseparator,asource);
  if p=0 then exit;
  result:=copy(asource,p+1,maxint);
end;

function PosStr(const FindString, SourceString: string; StartPos: Integer): Integer;
asm
        PUSH    ESI
        PUSH    EDI
        PUSH    EBX
        PUSH    EDX
        TEST    EAX,EAX
        JE      @@qt
        TEST    EDX,EDX
        JE      @@qt0
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EAX,[EAX-4]
        MOV     EDX,[EDX-4]
        DEC     EAX
        SUB     EDX,EAX
        DEC     ECX
        SUB     EDX,ECX
        JNG     @@qt0
        MOV     EBX,EAX
        XCHG    EAX,EDX
        NOP
        ADD     EDI,ECX
        MOV     ECX,EAX
        MOV     AL,BYTE PTR [ESI]
@@lp1:  CMP     AL,BYTE PTR [EDI]
        JE      @@uu
@@fr:   INC     EDI
        DEC     ECX
        JNZ     @@lp1
@@qt0:  XOR     EAX,EAX
        JMP     @@qt
@@ms:   MOV     AL,BYTE PTR [ESI]
        MOV     EBX,EDX
        JMP     @@fr
@@uu:   TEST    EDX,EDX
        JE      @@fd
@@lp2:  MOV     AL,BYTE PTR [ESI+EBX]
        XOR     AL,BYTE PTR [EDI+EBX]
        JNE     @@ms
        DEC     EBX
        JNE     @@lp2
@@fd:   LEA     EAX,[EDI+1]
        SUB     EAX,[ESP]
@@qt:   POP     ECX
        POP     EBX
        POP     EDI
        POP     ESI
end;

function Removetags(aText:string):string;
var
  pb,pe:integer;
begin
  result:=aText;
  repeat
    pb:=posstr('<',result);
    if pb>0 then begin
      pe:=posstr('>',result,pb);
      if pe>0 then delete(result,pb,pe-pb+1);
    end;
  until pb=0;
end;

function PosTextHTML(const FindString,SourceString:string):integer;
var
  pb,ptb,pte,L:integer;
begin
  result:=0;
  L:=length(FindString);
  pb:=postext('<body',SourceString);
  if pb=0 then exit;
  repeat
    pb:=postext(Findstring,SourceString,pb);
    if pb=0 then exit;
    ptb:=posstr('<',SourceString,pb);
    pte:=posstr('>',SourceString,pb);
    if ptb>pte then begin
      result:=pb;
      exit;
    end
    else
      pb:=pb+L;
  until pb=0;
end;

function PosText(const FindString, SourceString: string; StartPos: Integer): Integer;
asm
        PUSH    ESI
        PUSH    EDI
        PUSH    EBX
        NOP
        TEST    EAX,EAX
        JE      @@qt
        TEST    EDX,EDX
        JE      @@qt0
        MOV     ESI,EAX
        MOV     EDI,EDX
        PUSH    EDX
        MOV     EAX,[EAX-4]
        MOV     EDX,[EDX-4]
        DEC     EAX
        SUB     EDX,EAX
        DEC     ECX
        PUSH    EAX
        SUB     EDX,ECX
        JNG     @@qtx
        ADD     EDI,ECX
        MOV     ECX,EDX
        MOV     EDX,EAX
        MOVZX   EBX,BYTE PTR [ESI]
        MOV     AL,BYTE PTR [EBX+ToUpperChars]
@@lp1:  MOVZX   EBX,BYTE PTR [EDI]
        CMP     AL,BYTE PTR [EBX+ToUpperChars]
        JE      @@uu
@@fr:   INC     EDI
        DEC     ECX
        JNE     @@lp1
@@qtx:  ADD     ESP,$08
@@qt0:  XOR     EAX,EAX
        JMP     @@qt
@@ms:   MOVZX   EBX,BYTE PTR [ESI]
        MOV     AL,BYTE PTR [EBX+ToUpperChars]
        MOV     EDX,[ESP]
        JMP     @@fr
        NOP
@@uu:   TEST    EDX,EDX
        JE      @@fd
@@lp2:  MOV     BL,BYTE PTR [ESI+EDX]
        MOV     AH,BYTE PTR [EDI+EDX]
        CMP     BL,AH
        JE      @@eq
        MOV     AL,BYTE PTR [EBX+ToUpperChars]
        MOVZX   EBX,AH
        XOR     AL,BYTE PTR [EBX+ToUpperChars]
        JNE     @@ms
@@eq:   DEC     EDX
        JNZ     @@lp2
@@fd:   LEA     EAX,[EDI+1]
        POP     ECX
        SUB     EAX,[ESP]
        POP     ECX
@@qt:   POP     EBX
        POP     EDI
        POP     ESI
end;


function PosTextWild(const FindString, SourceString: string;var count:integer;
    StartPos: Integer = 1): Integer;
var
  p,pb,pe:integer;
  sb,se:string;
begin
  result:=0;
  p:=posstr('*',FindString);
  if p=0 then exit; // must have wild card
  if (p=1) or (p=length(FindString)) then exit; // * may not be first or last character
  sb:=copy(FindString,1,p-1);
  se:=copy(FindString,p+1,length(FindString));
  pb:=postext(sb,SourceString,StartPos);
  if pb=0 then exit;
  pe:=postext(se,SourceString,pb+length(sb));
  if pe=0 then exit;
  count:=pe+length(se)-pb;
  result:=pb;
end;


function GetBoolValue(aText,aName:string):boolean;
begin
  result:=lowercase(GetValue(aText,aName))='yes';
end;


procedure ListSelect(src,dst:TStringList;aKey,aValue:string);
var i,c:integer;
begin
  dst.Clear;
  c:=src.count;
  if c=0 then exit;
  for i:=0 to c-1 do begin
    if getvalue(src[i],aKey)=aValue then
      dst.Append(src[i]);
  end;
end;

procedure ListSelectSet(src,dst:TStringList;aKey,aValue:string);
var i,c:integer;
    tmplis:TStringlist;
begin
  dst.Clear;
  c:=src.count;
  if c=0 then exit;
  if avalue='' then exit;
  tmplis:=tStringlist.create;
  tmplis.CommaText:=avalue;
  for i:=0 to c-1 do begin
    if tmplis.indexof(getvalue(src[i],aKey))<>-1 then
      dst.Append(src[i]);
  end;
  tmplis.free;
end;


procedure ListFilter(src:TStringList;aKey,aValue:string);
var i,c:integer;
    dst:Tstringlist;
begin
  c:=src.count;
  if c=0 then exit;
  dst:=TStringList.create;
  for i:=0 to c-1 do begin
    if getvalue(src[i],aKey)=aValue then
      dst.Append(src[i]);
  end;
  src.Assign(dst);
  dst.free;
end;


procedure ListOrderBy(src:TstringList;aKey:string;numeric:boolean);
var i,c,index:integer;
    lit,dst:TStringlist;
    s:string;
    ivalue:integer;
begin
  c:=src.count;
  if c<2 then exit;  // nothing to sort
  lit:=TStringList.create;
  dst:=TStringList.create;
  for i:=0 to c-1 do begin
    s:=getvalue(src[i],aKey);
    if numeric then
    try
      ivalue:=strtoint(s);
      // format to 5 decimal places for correct string sorting
      // e.g. 5 becomes 00005
      s:=format('%5.5d',[ivalue]);
    except
      // just use the unformatted value
    end;
    lit.AddObject(s,TObject(i));
  end;
  lit.Sort;
  for i:=0 to c-1 do begin
    index:=integer(lit.Objects[i]);
    dst.Append(src[index]);
  end;
  lit.free;
  src.Assign(dst);
  dst.free;
end;

// converts a csv list to a tagged string list
procedure csv2tags(src,dst:TStringList);
var
  i,c,fi,fc:integer;
  names:TstringList;
  rec:TstringList;
  s:string;
begin
  dst.clear;
  c:=src.count;
  if c<2 then exit;

  rec:=TStringList.create;
  names:=TStringList.create;
  try
    names.CommaText:=src[0];
    fc:=names.count;
    if fc>0 then
    for i:=1 to c-1 do begin
      rec.CommaText:=src[i];
      s:='';
      for fi:=0 to fc-1 do
        s:=s+names[fi]+'="'+rec[fi]+'" ';
      dst.Append(s);
    end;
  finally
    rec.free;
    names.free;
  end;
end;

// converts a tagged string list to a csv list
// only fieldnames from the first record are scanned ib the other records
procedure tags2csv(src,dst:TStringList);
var
  i,c,fi,fc:integer;
  names:TstringList;
  rec:TstringList;
  s: string;
begin
  dst.clear;
  c:=src.count;
  if c<1 then exit;
  names:=TStringList.create;
  rec:=TStringList.create;

  try
    GetNames(src[0],names);
    fc:=names.count;
    if fc>0 then begin
      dst.append(names.commatext);
      for i:=0 to c-1 do begin
        s:='';
        rec.clear;
        for fi:=0 to fc-1 do
          rec.append(getvalue(src[i],names[fi]));
        dst.Append(rec.commatext);
      end;
    end;
  finally
    rec.free;
    names.free;
  end;
end;



{*******************************************************
 * Standard Encryption algorithm - Copied from Borland *
 *******************************************************}
function Encrypt(const InString:string; StartKey,MultKey,AddKey:Integer): string;
var
  I : integer;
begin
  Result := '';
  for I := 1 to Length(InString) do
  begin
    Result := Result + CHAR(Byte(InString[I]) xor (StartKey shr 8));
    StartKey := (Byte(Result[I]) + StartKey) * MultKey + AddKey;
  end;
end;
{*******************************************************
 * Standard Decryption algorithm - Copied from Borland *
 *******************************************************}
function Decrypt(const InString:string; StartKey,MultKey,AddKey:Integer): string;
var
  I : integer;
begin
  Result := '';
  for I := 1 to Length(InString) do
  begin
    Result := Result + CHAR(Byte(InString[I]) xor (StartKey shr 8));
    StartKey := (Byte(InString[I]) + StartKey) * MultKey + AddKey;
  end;
end;


function EncryptB64(const InString:string; StartKey,MultKey,AddKey:Integer): string;
begin
  result:=B64Encode(Encrypt(InString,StartKey,MultKey,AddKey));
end;

function DecryptB64(const InString:string; StartKey,MultKey,AddKey:Integer): string;
begin
  result:=Decrypt(B64Decode(Instring),StartKey,MultKey,AddKey);
end;

function Hash(aText:string):integer;
var
  i:integer;
begin
  result:=0;
  if aText='' then exit;
  result:=ord(aText[1]);
  for I := 2 to Length(aText) do
    result:=(result * ord(aText[i])) xor result;
end;

  {replace any <,> etc by &lt; &gt;}
function XMLSafe(aText:string):string;
var i,c:integer;
begin
  c:=length(aText);
  if c=0 then begin
    result:=aText;
    exit;
  end;
  result:='';
  for i:=1 to c do begin
    if aText[i]='<' then result:=result+'&lt;'
    else if aText[i]='>' then result:=result+'&gt;'
    else if aText[i]='&' then result:=result+'&amp;'
    else if (ord(aText[i])>=32) and (ord(aText[i])<128) then result:=result+aText[i]
    else if ord(aText[i])>127 then result:=result+'&#'+inttostr(ord(aText[i]))+';'
    else result:=result+' ';
  end;
end;

function FirstOfSet(aText:string):string;
var
   p:integer;
begin
  result:=Trim(aText);
  if result='' then exit;
  if result[1]='"' then begin
    p:=posStr('"',result,2);
    result:=copy(result,2,p-2);
  end
  else begin
    p:=pos(' ',result);
    result:=copy(result,1,p-1);
  end;
end;

function LastOfSet(aText:string):string;
var
    c:integer;
begin
  result:=Trim(aText);
  c:=length(result);
  if c=0 then exit;
  if result[c]='"' then begin
    while (c>1) and (result[c-1]<>'"') do dec(c);
    result:=copy(result,c,length(result)-c);
  end
  else begin
    while (c>1) and (result[c-1]<>' ') do dec(c);
    result:=copy(result,c,length(result));
  end;
end;



function CountOfSet(aText:string):integer;
var lit:TStringlist;
begin
  lit:=TstringList.create;
  splitset(aText,lit);
  result:=lit.count;
  lit.free;
end;

function SetRotateRight(aText:string):string;
var lit:TStringlist;
    c:integer;
begin
  lit:=TstringList.create;
  splitset(aText,lit);
  c:=lit.count;
  if c>0 then begin
   lit.Move(c-1,0);
   result:=joinSet(lit);
  end
  else
    result:='';
  lit.free;
end;

function SetRotateLeft(aText:string):string;
var
   lit: TStringlist;
   c: integer;
begin
  lit:=TstringList.create;
  splitset(aText,lit);
  c:=lit.count;
  if c>0 then begin
   lit.Move(0,c-1);
   result:=joinSet(lit);
  end
  else
    result:='';
  lit.free;
end;

procedure SplitSet(aText:string;aList:TStringList);
var
   p:integer;
begin
  aList.Clear;
  if aText='' then exit;
  aText:=trim(aText);
  while aText<>'' do begin
    if aText[1]='"' then begin
      delete(aText,1,1);
      p:=pos('"',aText);
      if p<>0 then begin
        aList.append(copy(aText,1,p-1));
        delete(aText,1,p);
      end;
    end
    else begin
      p:=pos(' ',atext);
      if p=0 then begin
        aList.Append(aText);
        atext:='';
      end
      else begin
        aList.append(copy(aText,1,p-1));
        delete(aText,1,p);
      end;
    end;
    aText:=trim(aText);
  end;

end;

function  JoinSet(aList:TstringList):string;
var
  i,c:integer;
begin
  result:='';
  c:=aList.count;
  if c=0 then exit;
  for i:=0 to c-1 do
    result:=result+aList[i]+' ';
  delete(result,length(result),1);
end;

function SetPick(aText:string;aIndex:integer):string;
var
   lit:TStringlist;
   c:integer;
begin
  lit:=TstringList.create;
  splitset(aText,lit);
  c:=lit.count;
  if (c>0) and (aIndex<c) then
   result:=lit[aIndex]
  else
    result:='';
  lit.free;
end;

function SetSort(aText:string):string;
var
   lit: TStringlist;
   c: integer;
begin
  lit:=TstringList.create;
  splitset(aText,lit);
  c:=lit.count;
  if c>0 then begin
   lit.Sort;
   result:=joinSet(lit);
  end
  else
    result:='';
  lit.free;
end;

function SetUnion(set1,set2:string):string;
var
  lit1,lit2,lit3:Tstringlist;
  i,c:integer;
begin
  lit1:=tStringList.create;
  lit2:=tStringList.create;
  lit3:=tStringList.create;
  SplitSet(set1,lit1);
  SplitSet(set2,lit2);
  c:=lit2.count;
  if c<>0 then begin
    lit2.AddStrings(lit1);
    for i:=0 to lit2.count-1 do
      if lit3.IndexOf(lit2[i])=-1 then
        lit3.Append(lit2[i]);
    result:=JoinSet(lit3);
  end
  else begin
    result:=JoinSet(lit1);
  end;
  lit1.free;
  lit2.free;
  lit3.free;
end;

function SetIntersect(set1,set2:string):string;
var
  lit1,lit2,lit3:Tstringlist;
  i,c:integer;
begin
  lit1:=tStringList.create;
  lit2:=tStringList.create;
  lit3:=tStringList.create;
  SplitSet(set1,lit1);
  SplitSet(set2,lit2);
  c:=lit2.count;
  if c<>0 then begin
    for i:=0 to c-1 do
      if lit1.IndexOf(lit2[i])<>-1 then
        lit3.Append(lit2[i]);
    result:=JoinSet(lit3);
  end
  else begin
    result:='';
  end;
  lit1.free;
  lit2.free;
  lit3.free;
end;

function SetExclude(set1,set2:string):string;
var
  lit1,lit2:Tstringlist;
  i,c,index:integer;
begin
  lit1:=tStringList.create;
  lit2:=tStringList.create;
  SplitSet(set1,lit1);
  SplitSet(set2,lit2);
  c:=lit2.count;
  if c<>0 then begin
    for i:=0 to c-1 do begin
      index:= lit1.IndexOf(lit2[i]);
      if index<>-1 then
        lit1.Delete(index);
    end;
    result:=JoinSet(lit1);
  end
  else begin
    result:=JoinSet(lit1);
  end;
  lit1.free;
  lit2.free;
end;


function HTMLEncode(value:string):string;
var
  s:string;
  i,c:integer;
  ch:char;
begin
  result:='';
  if value='' then exit;
  s:=value;
  c:=length(s);
  for i:=1 to c do begin
    ch:=s[i];
    if ch='<' then
      result:=result+'&lt;'
    else if ch='>' then
      result:=result+'&gt;'
    else if ord(ch)>=128 then
      result:=result+'&#'+inttostr(ord(ch))+';'
    else
      result:=result+ch;
  end;
end;

// This function converts a string into a RFC 1630 compliant URL
function URLEncode(Value : String) : String;
Var I : Integer;
Begin
   Result := '';
   For I := 1 To Length(Value) Do
      Begin
         If Pos(UpperCase(Value[I]), ValidURLChars) > 0 Then
            Result := Result + Value[I]
         Else
            Begin
               If Value[I] = ' ' Then
                  Result := Result + '+'
               Else
                  Begin
                     Result := Result + '%';
                     Result := Result + IntToHex(Byte(Value[I]), 2);
                  End;
            End;
      End;
End;

function URLDecode(Value : String) : String;
Const HexChars = '0123456789ABCDEF';
Var I        : Integer;
    Ch,H1,H2 : Char;
Begin
   Result := '';
   I := 1;
   While I <= Length(Value) Do
      Begin
         Ch := Value[I];
         Case Ch Of
            '%' : Begin
                     H1 := Value[I+1];
                     H2 := Value[I+2];
                     Inc(I, 2);
                     Result := Result + Chr(((Pos(H1, HexChars) - 1) * 16) + (Pos(H2, HexChars) - 1));
                  End;
            '+' : Result := Result + ' ';
            '&' : Result := Result + #13+#10;
            Else Result := Result + Ch;
         End;
         Inc(I);
      End;
End;


{template functions}
function ReplaceFirst(sourceStr,findStr,replaceStr:string):string;
var
  p:integer;
begin
  result:=sourceStr;
  p:=posText(findstr,sourcestr,1);
  if p=0 then exit;
  result:=copy(sourcestr,1,p-1)+replacestr+copy(sourceStr,p+length(findStr),length(sourceStr));
end;

function ReplaceLast(sourceStr,findStr,replaceStr:string):string;
var
  p:integer;
begin
  result:=sourceStr;
  p:=posTextLast(findstr,sourcestr);
  if p=0 then exit;
  result:=copy(sourcestr,1,p-1)+replacestr+copy(sourceStr,p+length(findStr),length(sourceStr));
end;

function GetBlock(sourceStr,blockStr:string):string;
var
  pe,pb:integer;
  sbb, sbe:string;
  sbbL, sbeL :integer;
begin
  result:='';
  sbb:= '<!--begin:' + BlockStr;
  sbbL:= Length(sbb);
  sbe:= 'end:' + BlockStr + '-->';
  sbeL:= Length(sbe);
  pb:= posText(sbb,sourceStr,1);
  If pb = 0 Then Exit;
  pe:= postext(sbe,sourceStr,pb);
  If pe = 0 Then Exit;
  pe:= pe + sbeL - 1;
  result:= copy(SourceStr, pb + sbbL, pe - pb - sbbL - sbeL + 1);
end;


// insert a block template
// the last occurance of {block:aBlockname}
// the block template is marked with {begin:aBlockname} and {end:aBlockname}
function InsertLastBlock(var sourceStr:string;blockStr:string):boolean;
var
  // phead:integer;
  pblock,pe,pb:integer;
  sbb, sbe, sb, sbr:string;
  sbbL, sbeL :integer;
begin
  result:=false;
  sb:= '{|block:' + blockstr + '|}';
  sbb:= '<!--begin:' + BlockStr;
  sbbL:= Length(sbb);
  sbe:= 'end:' + BlockStr + '-->';
  sbeL:= Length(sbe);
  pblock:= posTextlast(sb,sourceStr);
  If pblock = 0 Then Exit ;
  pb:= posText(sbb,sourceStr,1);
  If pb = 0 Then Exit;
  pe:= postext(sbe,sourceStr,pb);
  If pe = 0 Then Exit;
  pe:= pe + sbeL - 1;
  // now replace
  sbr:= copy(SourceStr, pb + sbbL, pe - pb - sbbL - sbeL + 1);
  SourceStr:= copy(SourceStr,1, pblock - 1) + sbr + copy(SourceStr, pblock,length(sourceStr));
  result:=true;
end;

// the block template is marked with <!--begin:aBlockname} and end:aBlockname-->}


function InsertIndexBlock(var sourceStr:string;blockStr:string;index:integer):boolean;
var
  // phead:integer;
  pblock,pe,pb:integer;
  sbb, sbe, sb, sbr:string;
  sbbL, sbeL :integer;
begin
  result:=false;
  sb:= '<span class="waf">block:' + blockstr + '</span>';
  sbb:= '<!--begin:' + BlockStr;
  sbbL:= Length(sbb);
  sbe:= 'end:' + BlockStr + '-->';
  sbeL:= Length(sbe);
  pblock:= posTextlast(sb,sourceStr);
  If pblock = 0 Then Exit ;
  pb:= posText(sbb,sourceStr,1);
  If pb = 0 Then Exit;
  pe:= postext(sbe,sourceStr,pb);
  If pe = 0 Then Exit;
  pe:= pe + sbeL - 1;
  // now replace
  sbr:= copy(SourceStr, pb + sbbL, pe - pb - sbbL - sbeL + 1);
  SourceStr:= copy(SourceStr,1, pblock - 1) + sbr + copy(SourceStr, pblock,length(sourceStr));
  result:=true;
end;


// removes all  <!--begin:somefield to end:somefield--> from aSource
function removeMasterBlocks(sourceStr:string):string;
var
  pb:Integer;
  pe:Integer;
  pee:Integer;
begin
  result:=sourceStr;
  repeat
    pb:= postext('<!--begin:',result);
    If pb > 0 Then begin
      pe:= postext('end:',result,pb);
      If pe > 0 Then begin
        pee:= posstr('-->',result,pe);
        If pee > 0 Then begin
           delete(result,pb,pee+3-pb);
        End;
      End;
    End;
  Until pb = 0;
end;

// renumber all field id's in a template
function renumberFields(sourceStr:string):string;
var
  p,p2,id:integer;
  s:string;
begin
  id:=1;
  s:='';
  p:=postext('<body',sourceStr);
  s:=s+copy(sourceStr,1,p-1);
  delete(sourceStr,1,p-1);
  repeat
    p:=postext('<span class="waf"',sourceStr);
    if p>0 then begin
      s:=s+copy(sourceStr,1,p-1);
      delete(sourceStr,1,p-1);
      p2:=posstr('>',sourceStr);
      if p2>0 then begin
        s:=s+'<span class="waf" id="waf'+inttostr(id)+'">';
        delete(sourceStr,1,p2);
        inc(id);
      end
      else
        p:=0;
    end;
  until p=0;
  result:=s+sourceStr;
end;

// removes all {|field|} entries in a template
function removeFields(sourceStr:string):string;
var
  pb,pe,pbod:integer;
begin
  result:=sourceStr;
  pbod:=postext('<body',result);
  if pbod=0 then exit;
  repeat
    pb:= posstr('{|',result,pbod);
    if pb > 0 Then begin
      pe:= posstr('|}',result,pb);
      If pe > 0 Then
        delete(result,pb,pe+2-pb)
      else
        pb:=0;
    End;
  Until pb = 0;
end;

// removes all <img src="{|field|} entries in a template
function removeImages(sourceStr:string):string;
var
  pb,pe,pbod:integer;
begin
  result:=sourceStr;
  pbod:=postext('<body',result);
  if pbod=0 then exit;
  repeat
    pb:= postext('<img src="./images/"',result,pbod);
    if pb > 0 Then begin
      pe:= posstr('>',result,pb);
      If pe > 0 Then
        delete(result,pb,pe+1-pb)
      else
        pb:=0;
    End;
  Until pb = 0;
end;


{return a list of all template fields after the <body> tag}
procedure gettemplatefields(aText:string;aList:TStringList);
var p,p2:integer;
begin
  alist.clear;
  p:=postext('<body',atext,1);
  if p=0 then exit;
  repeat
    p:= posstr('{|',aText,p);
    if p>0 then begin
      p2:=posstr('|}',aText,p);
      if p2>0 then begin
        aList.Append(copy(aText,p+2,p2-p-2));
        p:=p2+1;
      end
      else
        p:=0;
    end;
  until p=0;
end;

{finds the last occurance}
function PosStrLast(const FindString, SourceString:string):integer;
var
   i,L:integer;
begin
  result:=0;
  L:=length(FindString);
  if L=0 then exit;
  i:=length(SourceString);
  if i=0 then exit;
  i:=i-L+1;
  while i>0 do begin
    result:=posStr(FindString,SourceString,i);
    if result>0 then exit;
    i:=i-L;
  end;
end;

function PosStrBefore(const FindString, SourceString:string;startPos:integer):integer;
begin
  result:=posstrlast(findstring,copy(sourcestring,1,startpos-1));
end;


{finds last occurance of a character}
function StrRScan(const S: string; Ch: Char; LastPos: Integer): Integer;
asm
        TEST    EAX,EAX
        JE      @@qt
        PUSH    EBX
        DEC     ECX
        JS      @@m1
        MOV     EBX,[EAX-4]
        PUSH    EDI
        CMP     ECX,EBX
        JA      @@ch
	TEST	ECX,ECX
	JE	@@m2
@@nx:   LEA     EDI,[EAX+ECX-1]
        STD
        XCHG    EAX,EDX
        REPNE   SCASB
        INC     EDI
        CLD
        CMP     AL,BYTE PTR [EDI]
        JNE     @@m2
        SUB     EDI,EDX
        MOV     EAX,EDI
        POP     EDI
        INC     EAX
        POP     EBX
        RET
@@ch:   MOV     ECX,EBX
	TEST	EBX,EBX
        JNE	@@nx
@@m2:   POP     EDI
@@m1:   XOR     EAX,EAX
	POP     EBX
@@qt:
end;

{find the last position before given position}
function PosTextBefore(const FindString, SourceString:string;startPos:integer):integer;
begin
  result:=postextlast(findstring,copy(sourcestring,1,startpos-1));
end;

{finds the last occurance}
function PosTextLast(const FindString, SourceString:string):integer;
var
   i,L:integer;
begin
  result:=0;
  L:=length(FindString);
  if L=0 then exit;
  i:=length(SourceString);
  if i=0 then exit;
  i:=i-L+1;
  while i>0 do begin
    result:=posText(FindString,SourceString,i);
    if result>0 then exit;
    i:=i-L;
  end;
end;

procedure IntCopy16;
asm
        MOV     EAX,[ESI]
        MOV     [EDI],EAX
        MOV     EAX,[ESI+4]
        MOV     [EDI+4],EAX
        MOV     EAX,[ESI+8]
        MOV     [EDI+8],EAX
        MOV     EAX,[ESI+12]
        MOV     [EDI+12],EAX
        MOV     EAX,[ESI+16]
        MOV     [EDI+16],EAX
        MOV     EAX,[ESI+20]
        MOV     [EDI+20],EAX
        MOV     EAX,[ESI+24]
        MOV     [EDI+24],EAX
        MOV     EAX,[ESI+28]
        MOV     [EDI+28],EAX
        MOV     EAX,[ESI+32]
        MOV     [EDI+32],EAX
        MOV     EAX,[ESI+36]
        MOV     [EDI+36],EAX
        MOV     EAX,[ESI+40]
        MOV     [EDI+40],EAX
        MOV     EAX,[ESI+44]
        MOV     [EDI+44],EAX
        MOV     EAX,[ESI+48]
        MOV     [EDI+48],EAX
        MOV     EAX,[ESI+52]
        MOV     [EDI+52],EAX
        MOV     EAX,[ESI+56]
        MOV     [EDI+56],EAX
        MOV     EAX,[ESI+60]
        MOV     [EDI+60],EAX
end;

procedure Q_TinyCopy(Source, Dest: Pointer; L: Cardinal);
asm
        JMP     DWORD PTR @@tV[ECX*4]
@@tV:   DD      @@tu00, @@tu01, @@tu02, @@tu03
        DD      @@tu04, @@tu05, @@tu06, @@tu07
        DD      @@tu08, @@tu09, @@tu10, @@tu11
        DD      @@tu12, @@tu13, @@tu14, @@tu15
        DD      @@tu16, @@tu17, @@tu18, @@tu19
        DD      @@tu20, @@tu21, @@tu22, @@tu23
        DD      @@tu24, @@tu25, @@tu26, @@tu27
        DD      @@tu28, @@tu29, @@tu30, @@tu31
        DD      @@tu32
@@tu00: RET
@@tu01: MOV     CL,BYTE PTR [EAX]
        MOV     BYTE PTR [EDX],CL
        RET
@@tu02: MOV     CX,WORD PTR [EAX]
        MOV     WORD PTR [EDX],CX
        RET
@@tu03: MOV     CX,WORD PTR [EAX]
        MOV     WORD PTR [EDX],CX
        MOV     CL,BYTE PTR [EAX+2]
        MOV     BYTE PTR [EDX+2],CL
        RET
@@tu04: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        RET
@@tu05: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     CL,BYTE PTR [EAX+4]
        MOV     BYTE PTR [EDX+4],CL
        RET
@@tu06: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     CX,WORD PTR [EAX+4]
        MOV     WORD PTR [EDX+4],CX
        RET
@@tu07: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     CX,WORD PTR [EAX+4]
        MOV     WORD PTR [EDX+4],CX
        MOV     CL,BYTE PTR [EAX+6]
        MOV     BYTE PTR [EDX+6],CL
        RET
@@tu08: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        RET
@@tu09: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     CL,BYTE PTR [EAX+8]
        MOV     BYTE PTR [EDX+8],CL
        RET
@@tu10: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     CX,WORD PTR [EAX+8]
        MOV     WORD PTR [EDX+8],CX
        RET
@@tu11: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     CX,WORD PTR [EAX+8]
        MOV     WORD PTR [EDX+8],CX
        MOV     CL,BYTE PTR [EAX+10]
        MOV     BYTE PTR [EDX+10],CL
        RET
@@tu12: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        RET
@@tu13: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     CL,BYTE PTR [EAX+12]
        MOV     BYTE PTR [EDX+12],CL
        RET
@@tu14: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     CX,WORD PTR [EAX+12]
        MOV     WORD PTR [EDX+12],CX
        RET
@@tu15: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     CX,WORD PTR [EAX+12]
        MOV     WORD PTR [EDX+12],CX
        MOV     CL,BYTE PTR [EAX+14]
        MOV     BYTE PTR [EDX+14],CL
        RET
@@tu16: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        RET
@@tu17: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     CL,BYTE PTR [EAX+16]
        MOV     BYTE PTR [EDX+16],CL
        RET
@@tu18: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     CX,WORD PTR [EAX+16]
        MOV     WORD PTR [EDX+16],CX
        RET
@@tu19: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     CX,WORD PTR [EAX+16]
        MOV     WORD PTR [EDX+16],CX
        MOV     CL,BYTE PTR [EAX+18]
        MOV     BYTE PTR [EDX+18],CL
        RET
@@tu20: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        RET
@@tu21: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        MOV     CL,BYTE PTR [EAX+20]
        MOV     BYTE PTR [EDX+20],CL
        RET
@@tu22: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        MOV     CX,WORD PTR [EAX+20]
        MOV     WORD PTR [EDX+20],CX
        RET
@@tu23: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        MOV     CX,WORD PTR [EAX+20]
        MOV     WORD PTR [EDX+20],CX
        MOV     CL,BYTE PTR [EAX+22]
        MOV     BYTE PTR [EDX+22],CL
        RET
@@tu24: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        MOV     ECX,DWORD PTR [EAX+20]
        MOV     DWORD PTR [EDX+20],ECX
        RET
@@tu25: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        MOV     ECX,DWORD PTR [EAX+20]
        MOV     DWORD PTR [EDX+20],ECX
        MOV     CL,BYTE PTR [EAX+24]
        MOV     BYTE PTR [EDX+24],CL
        RET
@@tu26: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        MOV     ECX,DWORD PTR [EAX+20]
        MOV     DWORD PTR [EDX+20],ECX
        MOV     CX,WORD PTR [EAX+24]
        MOV     WORD PTR [EDX+24],CX
        RET
@@tu27: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        MOV     ECX,DWORD PTR [EAX+20]
        MOV     DWORD PTR [EDX+20],ECX
        MOV     CX,WORD PTR [EAX+24]
        MOV     WORD PTR [EDX+24],CX
        MOV     CL,BYTE PTR [EAX+26]
        MOV     BYTE PTR [EDX+26],CL
        RET
@@tu28: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        MOV     ECX,DWORD PTR [EAX+20]
        MOV     DWORD PTR [EDX+20],ECX
        MOV     ECX,DWORD PTR [EAX+24]
        MOV     DWORD PTR [EDX+24],ECX
        RET
@@tu29: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        MOV     ECX,DWORD PTR [EAX+20]
        MOV     DWORD PTR [EDX+20],ECX
        MOV     ECX,DWORD PTR [EAX+24]
        MOV     DWORD PTR [EDX+24],ECX
        MOV     CL,BYTE PTR [EAX+28]
        MOV     BYTE PTR [EDX+28],CL
        RET
@@tu30: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        MOV     ECX,DWORD PTR [EAX+20]
        MOV     DWORD PTR [EDX+20],ECX
        MOV     ECX,DWORD PTR [EAX+24]
        MOV     DWORD PTR [EDX+24],ECX
        MOV     CX,WORD PTR [EAX+28]
        MOV     WORD PTR [EDX+28],CX
        RET
@@tu31: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        MOV     ECX,DWORD PTR [EAX+20]
        MOV     DWORD PTR [EDX+20],ECX
        MOV     ECX,DWORD PTR [EAX+24]
        MOV     DWORD PTR [EDX+24],ECX
        MOV     CX,WORD PTR [EAX+28]
        MOV     WORD PTR [EDX+28],CX
        MOV     CL,BYTE PTR [EAX+30]
        MOV     BYTE PTR [EDX+30],CL
        RET
@@tu32: MOV     ECX,DWORD PTR [EAX]
        MOV     DWORD PTR [EDX],ECX
        MOV     ECX,DWORD PTR [EAX+4]
        MOV     DWORD PTR [EDX+4],ECX
        MOV     ECX,DWORD PTR [EAX+8]
        MOV     DWORD PTR [EDX+8],ECX
        MOV     ECX,DWORD PTR [EAX+12]
        MOV     DWORD PTR [EDX+12],ECX
        MOV     ECX,DWORD PTR [EAX+16]
        MOV     DWORD PTR [EDX+16],ECX
        MOV     ECX,DWORD PTR [EAX+20]
        MOV     DWORD PTR [EDX+20],ECX
        MOV     ECX,DWORD PTR [EAX+24]
        MOV     DWORD PTR [EDX+24],ECX
        MOV     ECX,DWORD PTR [EAX+28]
        MOV     DWORD PTR [EDX+28],ECX
end;


procedure Q_CopyMem(Source, Dest: Pointer; L: Cardinal);
asm
        PUSH    EDI
        PUSH    ESI
        MOV     EDI,EDX
        MOV     EDX,ECX
        MOV     ESI,EAX
        TEST    EDI,3
        JNE     @@cl
        SHR     ECX,2
        AND     EDX,3
        CMP     ECX,16
        JBE     @@cw0
@@lp0:  CALL    IntCopy16
        ADD     ESI,64
        SUB     ECX,16
        ADD     EDI,64
        CMP     ECX,16
        JA      @@lp0
@@cw0:  JMP     DWORD PTR @@wV[ECX*4]
@@cl:   MOV     EAX,EDI
        MOV     EDX,3
        SUB     ECX,4
        JB      @@bc
        AND     EAX,3
        ADD     ECX,EAX
        JMP     DWORD PTR @@lV[EAX*4-4]
@@bc:   JMP     DWORD PTR @@tV[ECX*4+16]
@@lV:   DD      @@l1, @@l2, @@l3
@@l1:   AND     EDX,ECX
        MOV     AL,[ESI]
        MOV     [EDI],AL
        MOV     AL,[ESI+1]
        MOV     [EDI+1],AL
        MOV     AL,[ESI+2]
        SHR     ECX,2
        MOV     [EDI+2],AL
        ADD     ESI,3
        ADD     EDI,3
        CMP     ECX,16
        JBE     @@cw1
@@lp1:  CALL    IntCopy16
        ADD     ESI,64
        SUB     ECX,16
        ADD     EDI,64
        CMP     ECX,16
        JA      @@lp1
@@cw1:  JMP     DWORD PTR @@wV[ECX*4]
@@l2:   AND     EDX,ECX
        MOV     AL,[ESI]
        MOV     [EDI],AL
        MOV     AL,[ESI+1]
        SHR     ECX,2
        MOV     [EDI+1],AL
        ADD     ESI,2
        ADD     EDI,2
        CMP     ECX,16
        JBE     @@cw2
@@lp2:  CALL    IntCopy16
        ADD     ESI,64
        SUB     ECX,16
        ADD     EDI,64
        CMP     ECX,16
        JA      @@lp2
@@cw2:  JMP     DWORD PTR @@wV[ECX*4]
@@l3:   AND     EDX,ECX
        MOV     AL,[ESI]
        MOV     [EDI],AL
        INC     ESI
        SHR     ECX,2
        INC     EDI
        CMP     ECX,16
        JBE     @@cw3
@@lp3:  CALL    IntCopy16
        ADD     ESI,64
        SUB     ECX,16
        ADD     EDI,64
        CMP     ECX,16
        JA      @@lp3
@@cw3:  JMP     DWORD PTR @@wV[ECX*4]
@@wV:   DD      @@w0, @@w1, @@w2, @@w3
        DD      @@w4, @@w5, @@w6, @@w7
        DD      @@w8, @@w9, @@w10, @@w11
        DD      @@w12, @@w13, @@w14, @@w15
        DD      @@w16
@@w16:  MOV     EAX,[ESI+ECX*4-64]
        MOV     [EDI+ECX*4-64],EAX
@@w15:  MOV     EAX,[ESI+ECX*4-60]
        MOV     [EDI+ECX*4-60],EAX
@@w14:  MOV     EAX,[ESI+ECX*4-56]
        MOV     [EDI+ECX*4-56],EAX
@@w13:  MOV     EAX,[ESI+ECX*4-52]
        MOV     [EDI+ECX*4-52],EAX
@@w12:  MOV     EAX,[ESI+ECX*4-48]
        MOV     [EDI+ECX*4-48],EAX
@@w11:  MOV     EAX,[ESI+ECX*4-44]
        MOV     [EDI+ECX*4-44],EAX
@@w10:  MOV     EAX,[ESI+ECX*4-40]
        MOV     [EDI+ECX*4-40],EAX
@@w9:   MOV     EAX,[ESI+ECX*4-36]
        MOV     [EDI+ECX*4-36],EAX
@@w8:   MOV     EAX,[ESI+ECX*4-32]
        MOV     [EDI+ECX*4-32],EAX
@@w7:   MOV     EAX,[ESI+ECX*4-28]
        MOV     [EDI+ECX*4-28],EAX
@@w6:   MOV     EAX,[ESI+ECX*4-24]
        MOV     [EDI+ECX*4-24],EAX
@@w5:   MOV     EAX,[ESI+ECX*4-20]
        MOV     [EDI+ECX*4-20],EAX
@@w4:   MOV     EAX,[ESI+ECX*4-16]
        MOV     [EDI+ECX*4-16],EAX
@@w3:   MOV     EAX,[ESI+ECX*4-12]
        MOV     [EDI+ECX*4-12],EAX
@@w2:   MOV     EAX,[ESI+ECX*4-8]
        MOV     [EDI+ECX*4-8],EAX
@@w1:   MOV     EAX,[ESI+ECX*4-4]
        MOV     [EDI+ECX*4-4],EAX
        SHL     ECX,2
        ADD     ESI,ECX
        ADD     EDI,ECX
@@w0:   JMP     DWORD PTR @@tV[EDX*4]
@@tV:   DD      @@t0, @@t1, @@t2, @@t3
@@t3:   MOV     AL,[ESI+2]
        MOV     [EDI+2],AL
@@t2:   MOV     AL,[ESI+1]
        MOV     [EDI+1],AL
@@t1:   MOV     AL,[ESI]
        MOV     [EDI],AL
@@t0:   POP     ESI
        POP     EDI
end;


procedure Q_Delete(var S: string; Index, Count: Integer);
asm
        PUSH    EBX
        PUSH    ESI
        XOR     EBX,EBX
        CMP     ECX,EBX
        JLE     @@qt
        MOV     EBX,[EAX]
        TEST    EBX,EBX
        JE      @@qt
        MOV     ESI,[EBX-4]
        DEC     EDX
        JS      @@qt
        SUB     ESI,EDX
        JNG     @@qt
        SUB     ESI,ECX
        JLE     @@zq
        PUSH    ECX
        MOV     EBX,EDX
        CALL    UniqueString
        POP     ECX
        PUSH    EAX
        MOV     EDX,ESI
        ADD     EAX,EBX
        SHR     ESI,2
        JE      @@nx
@@lp:   MOV     BL,[EAX+ECX]
        MOV     [EAX],BL
        MOV     BL,[EAX+ECX+1]
        MOV     [EAX+1],BL
        MOV     BL,[EAX+ECX+2]
        MOV     [EAX+2],BL
        MOV     BL,[EAX+ECX+3]
        MOV     [EAX+3],BL
        ADD     EAX,4
        DEC     ESI
        JNE     @@lp
@@nx:   AND     EDX,3
        JMP     DWORD PTR @@tV[EDX*4]
@@zq:   CALL    System.@LStrClr
@@qt:   POP     ESI
        POP     EBX
        RET
@@tV:   DD      @@t0,@@t1,@@t2,@@t3
@@t1:   MOV     BL,[EAX+ECX]
        MOV     [EAX],BL
        INC     EAX
        JMP     @@t0
@@t2:   MOV     BL,[EAX+ECX]
        MOV     [EAX],BL
        MOV     BL,[EAX+ECX+1]
        MOV     [EAX+1],BL
        ADD     EAX,2
        JMP     @@t0
@@t3:   MOV     BL,[EAX+ECX]
        MOV     [EAX],BL
        MOV     BL,[EAX+ECX+1]
        MOV     [EAX+1],BL
        MOV     BL,[EAX+ECX+2]
        MOV     [EAX+2],BL
        ADD     EAX,3
@@t0:   POP     EDX
        MOV     BYTE PTR [EAX],0
        SUB     EAX,EDX
        MOV     [EDX-4],EAX
        POP     ESI
        POP     EBX
end;

function Q_ReplaceStr(const SourceString, FindString, ReplaceString: string): string;
var
  P,PS: PChar;
  L,L1,L2,Cnt: Integer;
  I,J,K,M: Integer;
begin
  L1 := Length(FindString);
  Cnt := 0;
  I := PosStr(FindString,SourceString,1);
  while I <> 0 do
  begin
    Inc(I,L1);
    asm
      PUSH    I
    end;
    Inc(Cnt);
    I := PosStr(FindString,SourceString,I);
  end;
  if Cnt <> 0 then
  begin
    L := Length(SourceString);
    L2 := Length(ReplaceString);
    J := L+1;
    Inc(L,(L2-L1)*Cnt);
    if L <> 0 then
    begin
      SetString(Result,nil,L);
      P := Pointer(Result);
      Inc(P, L);
      PS := Pointer(LongWord(SourceString)-1);
      if L2 <= 32 then
        for I := 0 to Cnt-1 do
        begin
          asm
            POP     K
          end;
          M := J-K;
          if M > 0 then
          begin
            Dec(P,M);
            Q_CopyMem(@PS[K],P,M);
          end;
          Dec(P,L2);
          Q_TinyCopy(Pointer(ReplaceString),P,L2);
          J := K-L1;
        end
      else
        for I := 0 to Cnt-1 do
        begin
          asm
            POP     K
          end;
          M := J-K;
          if M > 0 then
          begin
            Dec(P,M);
            Q_CopyMem(@PS[K],P,M);
          end;
          Dec(P,L2);
          Q_CopyMem(Pointer(ReplaceString),P,L2);
          J := K-L1;
        end;
      Dec(J);
      if J > 0 then
        Q_CopyMem(Pointer(SourceString),Pointer(Result),J);
    end else
      Result := '';
  end else
    Result := SourceString;
end;

function Q_ReplaceText(const SourceString, FindString, ReplaceString: string): string;
var
  P,PS: PChar;
  L,L1,L2,Cnt: Integer;
  I,J,K,M: Integer;
begin
  L1 := Length(FindString);
  Cnt := 0;
  I := PosText(FindString,SourceString,1);
  while I <> 0 do
  begin
    Inc(I,L1);
    asm
      PUSH    I
    end;
    Inc(Cnt);
    I := PosText(FindString,SourceString,I);
  end;
  if Cnt <> 0 then
  begin
    L := Length(SourceString);
    L2 := Length(ReplaceString);
    J := L+1;
    Inc(L,(L2-L1)*Cnt);
    if L <> 0 then
    begin
      SetString(Result,nil,L);
      P := Pointer(Result);
      Inc(P, L);
      PS := Pointer(LongWord(SourceString)-1);
      if L2 <= 32 then
        for I := 0 to Cnt-1 do
        begin
          asm
            POP     K
          end;
          M := J-K;
          if M > 0 then
          begin
            Dec(P,M);
            Q_CopyMem(@PS[K],P,M);
          end;
          Dec(P,L2);
          Q_TinyCopy(Pointer(ReplaceString),P,L2);
          J := K-L1;
        end
      else
        for I := 0 to Cnt-1 do
        begin
          asm
            POP     K
          end;
          M := J-K;
          if M > 0 then
          begin
            Dec(P,M);
            Q_CopyMem(@PS[K],P,M);
          end;
          Dec(P,L2);
          Q_CopyMem(Pointer(ReplaceString),P,L2);
          J := K-L1;
        end;
      Dec(J);
      if J > 0 then
        Q_CopyMem(Pointer(SourceString),Pointer(Result),J);
    end else
      Result := '';
  end else
    Result := SourceString;
end;

procedure DirFiles(aDir,amask:string; aFileList:TStringlist);
var
  sr: TSearchRec;
  FileAttrs: Integer;
begin
  FileAttrs := faArchive+faDirectory;
  if FindFirst(aDir+amask, FileAttrs, sr) = 0 then
  while FindNext(sr) = 0 do
    if (sr.Attr and faArchive)<>0 then
      aFileList.addobject(aDir+sr.Name,TObject(sr.size));
  FindClose(sr);
end;

procedure DirFilesEx(aDir:string; aFileList:TStringlist);
var
  sr: TSearchRec;
  FileAttrs: Integer;
begin
  FileAttrs := faArchive+faDirectory;
  if FindFirst(aDir+'\*.*', FileAttrs, sr) = 0 then
  while FindNext(sr) = 0 do
    if (sr.Attr and faArchive)<>0 then
      aFileList.addobject(sr.Name,TObject(sr.size))
    else if (sr.Attr and faDirectory)<>0 then
      aFileList.addobject('['+sr.Name+']',TObject(sr.size));
  FindClose(sr);
end;



{name and value}
function strName(aStr:string):string;
var p:integer;
begin
  p:=pos('=',aStr);
  if p>0 then
    result:=copy(aStr,1,p-1)
  else
    result:=aStr;
end;

function strValue(aStr:string):string;
var p:integer;
begin
  p:=pos('=',aStr);
  if p>0 then
    result:=copy(aStr,p+1,length(aStr))
  else
    result:=aStr;
end;

function magic(aStr:string):string;
begin
  result:=stringreplace(astr,'"','''',[rfreplaceall]);
end;

function unquote(aStr:string):string;
var
  c:integer;
begin
  result:=trim(aStr);
  if result='' then exit;
  if (result[1]='"') or (result[1]='''') then
    delete(result,1,1);
  c:=length(result);
  if c=0 then exit;
  if (result[c]='"') or (result[c]='''') then
    delete(result,c,1);
end;

  {test conversions}
function isInteger(aStr:string):boolean; overload;
var
   i: integer;
begin
     result := false;
     if (aStr = '') then
        exit;

     for i:=1 to length(aStr) do
       if not (aStr[i] in ['0'..'9', '-', '+']) then
          exit;
     result := true;
end;


function isfloat(svalue:string;var fvalue:extended):boolean;
begin
  try
    fvalue:=strtofloat(svalue);
    result:=true;
  except
    result:=false;
  end;
end;

function isinteger(svalue:string;var ivalue:integer):boolean;overload;
begin
  try
    ivalue:=strtoint(svalue);
    result:=true;
  except
    result:=false;
  end;
end;

function floattostrUS(value:double;decimals:integer):string;
var
  oldseperator:char;
begin
  oldseperator:=DecimalSeparator;
  DecimalSeparator:='.';
  result:=FloatToStrF(value,ffFixed,3,decimals);
  DecimalSeparator:=oldseperator;
end;

function strUStofloat(value:string):double;
var
  oldseperator:char;
begin
  result:=0;
  oldseperator:=DecimalSeparator;
  DecimalSeparator:='.';
  try
    result:=strtofloat(value);
  except
    //
  end;
  DecimalSeparator:=oldseperator;
end;

function strNLtofloat(value:string):double;
var
  oldseperator:char;
begin
  result:=0;
  oldseperator:=DecimalSeparator;
  DecimalSeparator:=',';
  try
    result:=strtofloat(value);
  except
  //
  end;
  DecimalSeparator:=oldseperator;
end;

function floattostrNL(value:double;decimals:integer):string;
var
  oldseperator:char;
begin
  oldseperator:=DecimalSeparator;
  DecimalSeparator:=',';
  result:=FloatToStrF(value,ffFixed,3,decimals);
  DecimalSeparator:=oldseperator;
end;

{xml functions}
function xmlformatLoadStr(fn:string):string;
var
  si,so:string;
  i,level:integer;
begin
  si:=loadstring(fn);
  so:='';
  level:=0;
  for i:=1 to length(si) do begin
    if si[i]='<' then begin
      if si[i+1]='/' then begin
        so:=so+cr+stringofChar(' ',level)+'<';
        dec(level,2);
      end
      else begin
        inc(level,2);
        so:=so+cr+stringofChar(' ',level)+'<';
      end;
    end
    else
      so:=so+si[i];
  end;
  result:=so;
end;

function prettyxml(aText:string):string;
var
  s:string;
  pb,pe,peold:integer;
  level:integer;
begin
  s:='';
  pe:=1;
  peold:=1;
  level:=1;
  repeat
    pb:=posstr('<',aText,pe);
    if pb>0 then begin
      pe:=posstr('>',aText,pb);
      if pe>0 then begin
        if aText[pb+1]='/' then begin // close tag
          if pb>(peold+1) then
            s:=s+stringofChar(' ',level*2)+copy(aText,peold+1,pb-peold-1)+cr;
          if level>1 then dec(level);
          s:=s+stringofChar(' ',level*2)+copy(aText,pb,pe-pb+1)+cr;
        end
        else begin
          if aText[pe-1]<>'/' then begin
            if pb>(peold+1) then
              s:=s+stringofChar(' ',level*2)+copy(aText,peold+1,pb-peold-1)+cr;
            s:=s+stringofChar(' ',level*2)+copy(aText,pb,pe-pb+1)+cr;
            inc(level);
          end
          else begin  // xml shortcut
            if pb>(peold+1) then
              s:=s+stringofChar(' ',level*2)+copy(aText,peold+1,pb-peold-1)+cr;
            s:=s+stringofChar(' ',level*2)+copy(aText,pb,pe-pb+1)+cr;
            if level>1 then dec(level);
          end;
        end;
        peold:=pe;
      end;
    end;
  until (pb=0) or (pe=0);
  if length(aText)>pe then
    s:=s+copy(aText,peold,maxint);
  result:=s;
end;

{file filter functions}
function decodefilter(afilter:string):string;
var
  b:boolean;
  p:integer;
begin
  result:=afilter;
  b:=true;
  repeat
    p:=pos('|',result);
    if p>0 then begin
      if b then begin
        delete(result,p,1);
        insert('=',result,p);
      end
      else begin
        delete(result,p,1);
        insert(cr,result,p);
      end;
      b:=not b;
    end;
  until p=0;
end;

function encodefilter(avalue:string):string;
begin
  result:=avalue;
  result:=stringreplace(result,cr,'|',[rfreplaceall]);
  result:=stringreplace(result,'=','|',[rfreplaceall]);
end;

procedure getSearchWords(aStr:string;alist:TStringlist);
var
  p:integer;
  s:string;
begin
  alist.clear;
  s:=aStr;
  if aStr='' then exit;
  repeat
    s:=trim(s);
    p:=postext(' ',s);
    if p>0 then begin
      aList.append(copy(s,1,p-1));
      delete(s,1,p);
    end;
  until p=0;
  if s<>'' then
    alist.append(s);
end;

{indexer routines  8 march 2001}
procedure getwordlist(aStr:string; list:TStringlist);
const charset=['a'..'z','A'..'Z','_'];
var
  i,c,index:integer;
  ch:char;
  word:string;
  haveword:boolean;
begin
  list.clear;
  c:=length(aStr);
  if c=0 then exit;
  haveword:=false;
  for i:=1 to c do begin
    ch:=aStr[i];
    if ch in charset then begin
      if not haveword then begin
        word:='';
        haveword:=true;
      end;
      word:=word+ch;
    end
    else begin
      if haveword then begin
        index:=list.indexof(word);
        if index=-1 then list.Append(word);
        haveword:=false;
      end;
    end;
  end;
end;

procedure gethtmlwordlist(aStr:string; list:TStringlist);
const
     charset=['a'..'z','A'..'Z','_'];
var
   i, c:integer;
   ch: char;
   word: string;
   haveword, isTag: boolean;
begin
  list.clear;
  list.Sorted:=true;
  list.Duplicates:=dupIgnore;
  c:=length(aStr);
  if c=0 then exit;
  haveword:=false;
  isTag:=false;
  for i:=1 to c do begin
    ch:=aStr[i];
    if ch='<' then isTag:=true;
    if ch='>' then isTag:=false;
    if (ch in charset) and (not istag) then begin
      if not haveword then begin
        word:='';
        haveword:=true;
      end;
      word:=word+ch;
    end
    else begin
      if haveword then begin
        word:=lowercase(word);
//        index:=list.indexof(word);
//        if index=-1 then list.Append(word);
        word:=copy(word,1,255);
        list.Add(word);
        haveword:=false;
      end;
    end;
  end;
end;

procedure gethtmlhashlist(aStr:string; list:TStringlist;hash32:boolean);
const charset=['a'..'z','A'..'Z','_'];
var
  i,c:integer;
  ch:char;
  word:string;
  haveword,isTag:boolean;
begin
  list.clear;
  list.Sorted:=true;
  list.Duplicates:=dupIgnore;
  c:=length(aStr);
  if c=0 then exit;
  haveword:=false;
  isTag:=false;
  for i:=1 to c do begin
    ch:=aStr[i];
    if ch='<' then isTag:=true;
    if ch='>' then isTag:=false;
    if (ch in charset) and (not istag) then begin
      if not haveword then begin
        word:='';
        haveword:=true;
      end;
      word:=word+ch;
    end
    else begin
      if haveword then begin
        word:=lowercase(word);
        word:=copy(word,1,255);
        if hash32 then
          word:=inttostr(crc32hash(word))
        else
          word:=inttostr(crchash(word));
        list.Add(word);
        haveword:=false;
      end;
    end;
  end;
end;


// hithighlighting
function hithighlight(fn:string;searchwords:tstringlist;myDir:string; abackcolor, aforecolor:string;var hits:integer):string;
var
  sword,page, href, thedir:string;
  i,c,pb,ptb,pte:integer;
  strHL:string;HL:integer;
  hilites:integer;
begin
  result:='';
  strHL:='<b style="background-color:'+abackcolor+';color='+aforecolor+';">';
  HL:=length(strHL);
  if not fileexists(fn) then exit;
  thedir:=extractfilepath(fn);
  thedir:=stringreplace(thedir,'\','/',[rfreplaceall]);
  page:=loadstring(fn);
  hilites:=0;
  c:=searchwords.count;
  if c=0 then begin
    result:=page;
    exit;
  end;
  for i:=0 to c-1 do begin
    sword:=searchwords[i];
    pb:=1;
    repeat
      pb:=postext(sword,page,pb);
      if pb>0 then begin // check of not in tag
        ptb:=posstr('<',page,pb);
        pte:=posstr('>',page,pb);
        if ptb<pte then begin // not in tag
          insert('</b>',page,pb+length(sword));
          insert('<a name="bshh'+inttostr(hilites)+'"></a>'+strHL,page,pb);
          inc(hilites);
          pb:=pb+HL+length(sword);
        end
        else
          pb:=pb+length(sword);
      end;
    until pb=0;
  //  page:=stringreplace(page,searchwords[i],'<b style="background-color:yellow;">'+searchwords[i]+'</b>',[rfreplaceall,rfignorecase]);
  end;
  // adjust links
  pb:=1;
  repeat
    pb:=postext('href=',page,pb);
    if pb>0 then begin
      href:=copy(page,pb,15);
      if (postext('http://',href)=0) and (copy(href,pb+6,1)<>'#') then begin //must adjust
         insert(thedir,page,pb+6);
      end;
      pb:=pb+15;
    end;
  until pb=0;
  // adjust img src
  pb:=1;
  repeat
    pb:=postext(' src=',page,pb);
    if pb>0 then begin
      href:=copy(page,pb,15);
      if postext('http://',href)=0 then begin //must adjust
         insert(thedir,page,pb+6);
      end;
      pb:=pb+15;
    end;
  until pb=0;
  // adjust img in script
  pb:=1;
  repeat
    pb:=posstr('''../',page,pb);
    if pb>0 then begin
      insert(thedir,page,pb+1);
      pb:=pb+length(thedir)+10;
    end;

  until pb=0;
  // adjust background img src
  pb:=1;
  repeat
    pb:=postext(' background=',page,pb);
    if pb>0 then begin
      href:=copy(page,pb,25);
      if postext('http://',href)=0 then begin //must adjust
         insert(thedir,page,pb+13);
      end;
      pb:=pb+15;
    end;
  until pb=0;
  result:=page;
end;

function getHTMLTitle(aText:string):string;
var
  pb,pe:integer;
begin
  result:='untitled';
  pb:=postext('<title>',atext);
  if pb=0 then exit;
  pe:=postext('</title>',atext,pb+7);
  if pe=0 then exit;
  result:=copy(atext,pb+7,pe-(pb+7));
end;


function strHithighlight(aText:string;searchwords:tstringlist;abackcolor, aforecolor:string;var hilites:integer):string;
var
  sword,page,si:string;
  i,c,ptb,pte:integer;
  strHL:string;L:integer;
  mpos:array of integer;
  bDone:boolean;
begin
  result:='';
  strHL:='<b style="background-color:'+abackcolor+';color='+aforecolor+';">';
  page:=aText;
  hilites:=0;
  c:=searchwords.count;
  if c=0 then begin
    result:=page;
    exit;
  end;
  setlength(mpos,c);
  for i:=0 to c-1 do mpos[i]:=1;
  repeat
    bDone:=true;
    for i:=0 to c-1 do begin
      sword:=searchwords[i];
      if mpos[i]<>0 then begin
        bDone:=false;
        mpos[i]:=postext(sword,page,mpos[i]);
        if mpos[i]>0 then begin // check of not in tag
          ptb:=posstr('<',page,mpos[i]);
          pte:=posstr('>',page,mpos[i]);
          if ptb<pte then begin // not in tag
            insert('</b>',page,mpos[i]+length(sword));
            si:='<a name="bshh'+inttostr(hilites)+'"></a>'+strHL;
            L:=length(si);
            insert(si,page,mpos[i]);
            inc(hilites);
            mpos[i]:=mpos[i]+L+length(sword);
          end
          else
            mpos[i]:=mpos[i]+length(sword);
        end;
      end;
    end;
  until bDone;

  result:=page;
end;


{simple r.e. routines}
function match2(strSource,strFirst,strSecond:string; startPos:integer; var p1:integer; var p2:integer):boolean;
begin
  result:=false;
  p1:=postext(strFirst,strSource,startPos);
  if p1=0 then exit;
  p2:=postext(strSecond,strSource,p1+length(strFirst));
  result:=p2<>0;
end;

function match3(strSource,strFirst,strSecond,strThird:string;startPos:integer; var p1:integer; var p2:integer;var p3:integer):boolean;
begin
  result:=false;
  p1:=postext(strFirst,strSource,startPos);
  if p1=0 then exit;
  p2:=postext(strSecond,strSource,p1+length(strFirst));
  if p2=0 then exit;
  p3:=postext(strThird,strSource,p2+length(strSecond));
  result:=p3<>0;
end;

function scannext(strSource,strScan:string;startPos:integer;var scanPos:integer):boolean;
begin
  scanPos:=postext(strScan,strSource,startPos);
  result:=scanPos>0;
end;

procedure RecurseDirFilesReadOnly(myDir:string;setreadonly:boolean);
var
    sr: TSearchRec;
    FileAttrs: Integer;
    fn:string;
begin
     //FileAttrs := faArchive+faDirectory;
     FileAttrs := faAnyFile;
     if FindFirst(myDir+'\*.*', FileAttrs, sr) = 0 then
     while FindNext(sr) = 0 do
     begin
       if (sr.Attr and faDirectory)<>0 then
       begin
         if (sr.name<>'.') and (sr.name<>'..') then
           RecurseDirFilesReadOnly(myDir+'\'+sr.Name,setreadonly);
       end
       else if (sr.Attr and faArchive)<>0 then
       begin
        fn:=myDir+'\'+sr.Name;
        // tree.items.AddChild(FilesNode,'Source: "'+relDir+'\'+sr.Name+'"; DestDir: "{app}\'+relDir+'"');
         if setreadonly then
          // FileSetAttr(sr.name,sr.attr or faReadonly)
           FileSetAttr(fn,FileGetattr(fn) or faReadOnly	)
         else
           FileSetAttr(fn,FileGetattr(fn) and (not faReadOnly));
       end;
     end;
     FindClose(sr);
end;

function GetLongPathName (const Filename: string): string;
var
	SR: TSearchRec;
	ShortName: string;
begin
	Result := '';
	if not FileExists (FileName) then
	    Exit;

	ShortName := FileName;
	while FindFirst (ShortName, faAnyFile, SR) = 0 do
	begin
		Result := '\' + SR.Name + Result;
		SysUtils.FindClose (SR);
		ShortName := ExtractFileDir (ShortName);
		if Length (ShortName) <= 2 then // Then just the Drive specification
			Break;
	end;
	Result := ExtractFileDrive (ShortName) + Result;
end;

// update pars with <zipnn> from zipper
function UpdateFromZipper(pars,zipper:string):string;
var
  zip,zipend,part:string;
  pb1,pb2,pe,pdb,pde:integer;
begin
  result:=pars;
  pe:=1;
  repeat
    pb1:=postext('<zip',zipper,pe);
    if pb1=0 then exit;
    pb2:=posstr('>',zipper,pb1);
    if pb2=0 then exit;
    zip:=copy(zipper,pb1,pb2-pb1+1);
    zipend:='</'+copy(zip,2,maxint);
    pe:=postext(zipend,zipper,pb2);
    if pe=0 then exit;
    part:=copy(zipper,pb2+1,pe-(pb2+1));
    pdb:=postext(zip,result);
    if pdb>0 then begin
      pde:=postext(zipend,result);
      if pde>0 then begin
         result:=copy(result,1,pdb+length(zip)-1)+part+copy(result,pde,maxint);
      end;
    end;
  until pe=0;
end;

// returns extracted <zipnnn>... </zipnnn> sections
function GetZIPs(aSource:string):string;
var
  s,zip,zipend:string;
  pb1,pb2,pe:integer;
begin
  s:=aSource;
  result:='';
  pe:=1;
  repeat
    pb1:=postext('<zip',s,pe);
    if pb1=0 then exit;
    pb2:=posstr('>',s,pb1);
    if pb2=0 then exit;
    zip:=copy(s,pb1,pb2-pb1+1);
    zipend:='</'+copy(zip,2,maxint);
    pe:=postext(zipend,s,pb2);
    if pe=0 then exit;
    result:=result+copy(s,pb1,pe+length(zipend)-pb1)+cr;
  until pe=0;
end;

function newZip(aSource:string):string;
var
  s,zip:string;
  pb1,pb2:integer;
  zipnum,newnum:integer;
begin
  s:=aSource;
  pb2:=1;
  zipnum:=1;
  result:='<zip1>';
  repeat
    pb1:=postext('<zip',s,pb2);
    if pb1=0 then exit;
    pb2:=posstr('>',s,pb1);
    if pb2=0 then exit;
    zip:=copy(s,pb1,pb2-pb1+1);
    newnum:=strtointdef(copy(zip,5,length(zip)-5),1);
    if newnum>=zipnum then begin
      zipnum:=newnum;
      result:='<zip'+inttostr(zipnum+1)+'>';
    end;
  until pb1=0;
end;

function ISODayOfWeek (const DT: TDateTime): Integer;
begin
  Result := DayOfWeek (DT);
  Dec (Result);
  if Result = 0 then
    Result := 7;
end;

function StartOfISOWeek (const DT: TDateTime): TDateTime;
begin
  Result := DT - ISODayOfWeek (DT) + 1;
End;

function EndOfISOWeek (const DT: TDateTime): TDateTime;
begin
   Result := DT - ISODayOfWeek (DT) + 7;
End;

function GetFirstDayofMonth (const DT: TDateTime): TDateTime;
var
   D, M, Y: Word;
begin
   DecodeDate (DT, Y, M, D);
   Result := EncodeDate (Y, M, 1) + Frac (DT);
End;

function Date2Month (const DT: TDateTime): Word;
var
   D, Y : Word;
begin
   DecodeDate (DT, Y, Result, D);
End;

function ThisYear: Word;
begin
   Result := Date2Year (Date);
End;

function GetFirstDayOfYear (const Year: Word): TDateTime;
begin
   Result := EncodeDate (Year, 1, 1);
End;

function GetLastDayOfYear (const Year: Word): TDateTime;
begin
   Result := EncodeDate (Year, 12, 31);
End;

function DateIsLeapYear (const DT: TDateTime): Boolean;
begin
   Result := IsLeapYear (Date2Year (DT));
End;

function DaysInMonth (const DT: TDateTime): Byte;
begin
   case Date2Month (DT) of
      2: if DateIsLeapYear (DT) then
         Result := 29
         else
         Result := 28;
      4, 6, 9, 11: Result := 30;
      else
         Result := 31;
   end;
End;

function GetLastDayofMonth (const DT: TDateTime): TDateTime;
var
   D, M, Y: Word;
begin
   DecodeDate (DT, Y, M, D);
   case M of
      2:
      begin
         if IsLeapYear (Y) then
            D := 29
         else
            D := 28;
      end;
      4, 6, 9, 11: D := 30
      else
         D := 31;
   end;
   Result := EncodeDate (Y, M, D) + Frac (DT);
End;

function DateToSQLString(adate:TDateTime):string;
var
  ayear,amonth,aday:word;
begin
  decodedate(adate,ayear,amonth,aday);
  result:=format('%.4d',[ayear])+'-'+format('%.2d',[amonth])+'-'+format('%.2d',[aday]);
end;

function SQLStringToDate(atext:string):TDateTime;
begin
  result:=0;
  try
    result:=encodedate(strtoint(copy(atext,1,4)),strtoint(copy(atext,6,2)),strtoint(copy(atext,9,2)));
  except
  end;
end;

function dutchdate(akind:integer;adate:TDateTime):string;
var
  year,month,day:word;
begin
  decodedate(adate,year,month,day);
  case akind of
   2: result:= dutchdaynames[dayofweek(now)]+' '+inttostr(day)+' '+dutchmonthnames[month]+' '+inttostr(year);
   1: result:= inttostr(day)+' '+dutchmonthnames[month]+' '+inttostr(year);
  else
   result:= inttostr(day)+' '+inttostr(month)+' '+inttostr(year);
  end;
end;


function logtodate(s:string;var adate:TDateTime):boolean;
var
  year,month,day:word;
begin
  result:=false;
  try
    year:=strtoint(copy(s,1,4));
    month:=strtoint(copy(s,6,2));
    day:=strtoint(copy(s,9,2));
    adate:=encodedate(year,month,day);
    result:=true;
  except
  end;
end;

function logtotime(s:string;var atime:TDateTime):boolean;
var
  hour,min,sec,msec:word;
begin
  result:=false;
  try
    msec:=0;
    hour:=strtoint(copy(s,1,2));
    min:=strtoint(copy(s,4,2));
    sec:=strtoint(copy(s,7,2));
    atime:=encodetime(hour,min,sec,msec);
    result:=true;
  except
  end;
end;

function timetohours(aTime:TDateTime):double;
begin
  result:=frac(aTime)*24;
end;

function Date2Year (const DT: TDateTime): Word;
var
  D, M: Word;
begin
  DecodeDate (DT, Result, M, D);
End;

function Date2Day (const DT: TDateTime): Word;
var
  Y, M: Word;
begin
  DecodeDate (DT, Y, M, result);
end;

function StartOfWeek (const DT: TDateTime): TDateTime;
begin
  Result := DT - DayOfWeek (DT) + 1;
end;

function DaysApart (const DT1, DT2: TDateTime): LongInt;
begin
  Result := Trunc (DT2) - Trunc (DT1);
end;

function Date2WeekNo (const DT: TDateTime): Integer;
var
  Year: Word;
  FirstSunday, StartYear: TDateTime;
  WeekOfs: Byte;
begin
  Year := Date2Year (DT);
  StartYear := GetFirstDayOfYear (Year);
  if DayOfWeek (StartYear) = 0 then
  begin
    FirstSunday := StartYear;
    WeekOfs := 1;
  end
  else
  begin
    FirstSunday := StartOfWeek (StartYear) + 7;
    WeekOfs := 2;
    if DT < FirstSunday then
    begin
      Result := 1;
      Exit;
    end;
  end;
  Result := DaysApart (FirstSunday, StartofWeek (DT)) div 7 + WeekOfs;
end;


function DayOfYear (const DT: TDateTime): Word;
begin
  Result := Trunc (DT) - Trunc (EncodeDate (Date2Year (DT), 1, 1)) + 1;
End;

procedure ListSections(atext:string;list:TStrings);
var
  p1,p2:integer;
begin
  list.clear;
  p1:=1;
  repeat
    p1:=posstr('[',atext,p1);
    if p1>0 then begin
      p2:=posstr(']',atext,p1);
      if p2=0 then
        p1:=0
      else begin
        list.append(copy(atext,p1+1,p2-(p1+1)));
        p1:=p2;
      end;
    end;
  until p1=0;
end;

function GetSection(atext,asection:string):string;
var
  p1,p2:integer;
begin
  result:='';
  p1:=postext('['+asection+']',atext);
  if p1=0 then exit;
  p1:=p1+length('['+asection+']');
  p2:=posstr('[',atext,p1);
  if p2=0 then
    result:=trim(copy(atext,p1,maxint))
  else
    result:=trim(copy(atext,p1,p2-p1));
end;

function Soundex(source:string) : integer;
Const
{This table gives the SoundEX SCORE for all characters Upper and Lower Case
hence no need to convert. This is faster than doing an UpCase on the whole input string
The 5 NON Chars in middle are just given 0}

SoundExTable : Array[65..122] Of Byte
//A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ / ] ^ _ '
=(0,1,2,3,0,1,2,0,0,2,2,4,5,5,0,1,2,6,2,3,0,1,0,2,0,2,0,0,0,0,0,0,
//a b c d e f g h i j k l m n o p q r s t u v w x y z
  0,1,2,3,0,1,2,0,0,2,2,4,5,5,0,1,2,6,2,3,0,1,0,2,0,2);

Var
  i, l, s, SO, x : Byte;
  Multiple : Word;
  Name : PChar;
begin
  If source<>''                           //do nothing if nothing is passed
  then begin
    name:=pchar(source);
    Result := Ord(UpCase(Name[0]));       //initialise to first character
    SO := 0;                              //initialise last char as 0
    Multiple := 26;                       //initialise to 26 char of alphabet
    l := Pred(StrLen(Name));              //get into var to save repeating function
    For i := 1 to l do                    //for each char of input str
    begin
      s := Ord(name[i]);                  //*
      If (s > 64) and (s < 123)           //see notes * below
      then begin
        x := SoundExTable[s];             //get soundex value
        If (x > 0)                        //it is a scoring char
        AND (x <> SO)                     //is different from previous char
        then begin
          Result := Result + (x * Multiple); //avoid use of POW as it needs maths unit
          If (Multiple = 26 * 6 * 6)      //we have done enough (NB compiles to a const
           then break;                    //We have done, so leave loop
          Multiple := Multiple * 6;
          SO := x;                        //save for next round
        end;                              // of if a scoring char
      end;                                //of if in range of SoundEx table
    end;                                  //of for loop
  end else result := 0;
end;                                      //of function SoundBts

function confirm(msg:string):boolean;
begin
     result := false;
//  result:=messagedlg(msg,mtconfirmation,[mbyes,mbno],0)=mryes;
end;


function findClosingTag(source,tagname:string;startpos:integer;var foundpos:integer;casesensitive:boolean=false):boolean;
var
  src,atag:string;
  delim:string;
  p,p1,p1f,L:integer;
  hits:integer;
begin
  result:=false;
  atag:=tagname;
  if atag='' then exit;
  p1:=startpos;
  src:=source;
  L:=length(src);
  p:=p1+length(atag);
  hits:=1;
  while p<=L do begin
    if casesensitive then
      p:=posstr(atag,src,p)
    else
      p:=postext(atag,src,p);
    if p=0 then exit; // nothing found
    // check for closing tag
    if copy(src,p-2,2)='</' then begin // closing tag
      p1f:=p;
      if copy(src,p+length(atag),1)='>' then begin
        dec(hits);
        if hits=0 then begin
          foundpos:=p1f;
          result:=true;
          exit;
        end;
        if hits<0 then exit;
        p:=p+length(atag)+1;
      end
      else p:=p+length(atag)
    end
    else if copy(src,p-1,1)='<' then begin  // opening tag
       // find closing >
       p1f:=p;
       p:=posstr('>',src,p);
       if p=0 then exit;
       if copy(src,p-1,1)='/' then begin  // shortcut
         inc(p);
       end
       else begin
         // check tag
         delim:=copy(src,p1f+length(atag),1);
         if (delim=' ') or (delim='>') then begin
           inc(hits);
         end;
         inc(p);
       end;
    end
    else begin // skip
       p:=p+length(atag);
    end;
  end;
end;

function findOpeningTag(source,tagname:string;startpos:integer;var foundpos:integer;casesensitive:boolean=false):boolean;
var
  src,atag: string;
  delim: string;
  p,p1f: integer;
  hits: integer;
begin
  result:=false;
  atag:=tagname;
  if atag='' then exit;
  src:=source;
  p:=startpos-1;
  hits:=1;
  while p>=1 do begin
    if casesensitive then
      p:=posstrbefore(atag,src,p)
    else
      p:=postextbefore(atag,src,p);
    if p=0 then exit; // nothing found
    // check for closing tag
    if copy(src,p-2,2)='</' then begin // closing tag
      if copy(src,p+length(atag),1)='>' then begin
        inc(hits);
        if hits<0 then exit;
        dec(p)
      end
      else dec(p)
    end
    else if copy(src,p-1,1)='<' then begin  // opening tag
       // find closing >
       p1f:=p;
       p:=posstr('>',src,p);
       if p=0 then exit;
       if copy(src,p-1,1)='/' then begin  // shortcut
         p:=p1f-1;
       end
       else begin
         // check tag
         delim:=copy(src,p1f+length(atag),1);
         if (delim=' ') or (delim='>') then begin
           dec(hits);
           if hits=0 then begin
             foundpos:=p1f;
             result:=true;
             exit;
           end;
         end;
         p:=p1f-1;
       end;
    end
    else begin // skip
       dec(p);
    end;
  end;
end;

function getappldir(appl:string):string;
begin
  result:=extractfilepath(ExpandUNCFileName(appl));
end;


function B64Encode(const S: string): string;
begin
     result := MimeEncodeString(S);
end;


function B64Decode(const S: string): string;
begin
     result := MimeDecodeString(S);
end;


initialization
  InitTables;

end.

