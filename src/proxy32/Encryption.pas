{

  $Id: Encryption.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

  $Log: Encryption.pas,v $
  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***


}
unit Encryption;

interface

uses
  SysUtils, Math;

type
  PMD4Ctx = ^TMD4Ctx;
  TMD4Ctx = record
    state: array[0..3] of LongWord;
    count: array[0..1] of LongWord;
    buffer: array[0..63] of Byte;
  end;

  PByteArray = ^TByteArray;
  TByteArray = array[0..0] of Byte;
  PDWordArray = ^TDWordArray;
  TDWordArray = array[0..0] of LongWord;

  TEncryption = class
  private
    FRoundKeys : Array [1..16, 1..48] of Byte;
    FC: Array [1..28] of Byte;
    FD: Array [1..28] of Byte;
    FInputValue  : Array [1..64] of Byte;
    FOutputValue : Array [1..64] of Byte;
    FL, FR, FfunctionResult : Array [1..32] of Byte;
    FKey: String;
    FSmallBuffer: Array[0..63] of BYTE;

    procedure MD4Transform (var state: array of LongWord; block: Pointer);
    procedure MDEncode(output, input: Pointer; len: LongWord);
    procedure MDDecode(output, input: Pointer; len: LongWord);
    procedure FF(var a: LongWord; b, c, d, x, s: LongWord);
    procedure GG(var a: LongWord; b, c, d, x, s: LongWord);
    procedure HH(var a: LongWord; b, c, d, x, s: LongWord);
    procedure DF( var FK );
    procedure SetBit( var Data; Index, Value: Byte );
    function GetBit( var Data; Index : Byte ): Byte;
    procedure Shift( var SubKeyPart );
    procedure SubKey( Round : Byte; var SubKey );
    procedure SetKeys;
    procedure EncipherBLOCK;
  public
    function StrToBase64( const Buffer: String ): String;
    function Base64ToStr( const Buffer: String ): String;
    procedure MDInit(context: PMD4Ctx);
    procedure MDUpdate(context: PMD4Ctx; input: Pointer; inputLen: LongWord);
    function MDFinal(context: PMD4Ctx): String;
    function DesEcbEncrypt( AKey: String; AData: Array of byte ): String;
  end;

implementation
const
  IP : Array [1..64] of Byte =( 58,50,42,34,26,18,10,2,
                                60,52,44,36,28,20,12,4,
                                62,54,46,38,30,22,14,6,
                                64,56,48,40,32,24,16,8,
                                57,49,41,33,25,17, 9,1,
                                59,51,43,35,27,19,11,3,
                                61,53,45,37,29,21,13,5,
                                63,55,47,39,31,23,15,7);
  InvIP : Array [1..64] of Byte =( 40, 8,48,16,56,24,64,32,
                                   39, 7,47,15,55,23,63,31,
                                   38, 6,46,14,54,22,62,30,
                                   37, 5,45,13,53,21,61,29,
                                   36, 4,44,12,52,20,60,28,
                                   35, 3,43,11,51,19,59,27,
                                   34, 2,42,10,50,18,58,26,
                                   33, 1,41, 9,49,17,57,25);
  E : Array [1..48] of Byte =( 32, 1, 2, 3, 4, 5,
                                4, 5, 6, 7, 8, 9,
                                8, 9,10,11,12,13,
                               12,13,14,15,16,17,
                               16,17,18,19,20,21,
                               20,21,22,23,24,25,
                               24,25,26,27,28,29,
                               28,29,30,31,32, 1);
  P : Array [1..32] of Byte =( 16, 7,20,21,
                               29,12,28,17,
                                1,15,23,26,
                                5,18,31,10,
                                2, 8,24,14,
                               32,27, 3, 9,
                               19,13,30, 6,
                               22,11, 4,25);
  SBoxes : Array [1..8,0..3,0..15] of Byte =
          ( ((14, 4,13, 1, 2,15,11, 8, 3,10, 6,12, 5, 9, 0, 7),
            (  0,15, 7, 4,14, 2,13, 1,10, 6,12,11, 9, 5, 3, 8),
            (  4, 1,14, 8,13, 6, 2,11,15,12, 9, 7, 3,10, 5, 0),
            ( 15,12, 8, 2, 4, 9, 1, 7, 5,11, 3,14,10, 0, 6,13)),

            ((15, 1, 8,14, 6,11, 3, 4, 9, 7, 2,13,12, 0, 5,10),
            (  3,13, 4, 7,15, 2, 8,14,12, 0, 1,10, 6, 9,11, 5),
            (  0,14, 7,11,10, 4,13, 1, 5, 8,12, 6, 9, 3, 2,15),
            ( 13, 8,10, 1, 3,15, 4, 2,11, 6, 7,12, 0, 5,14, 9)),

            ((10, 0, 9,14, 6, 3,15, 5, 1,13,12, 7,11, 4, 2, 8),
            ( 13, 7, 0, 9, 3, 4, 6,10, 2, 8, 5,14,12,11,15, 1),
            ( 13, 6, 4, 9, 8,15, 3, 0,11, 1, 2,12, 5,10,14, 7),
            (  1,10,13, 0, 6, 9, 8, 7, 4,15,14, 3,11, 5, 2,12)),

            (( 7,13,14, 3, 0, 6, 9,10, 1, 2, 8, 5,11,12, 4,15),
            ( 13, 8,11, 5, 6,15, 0, 3, 4, 7, 2,12, 1,10,14, 9),
            ( 10, 6, 9, 0,12,11, 7,13,15, 1, 3,14, 5, 2, 8, 4),
            (  3,15, 0, 6,10, 1,13, 8, 9, 4, 5,11,12, 7, 2,14)),

            (( 2,12, 4, 1, 7,10,11, 6, 8, 5, 3,15,13, 0,14, 9),
            ( 14,11, 2,12, 4, 7,13, 1, 5, 0,15,10, 3, 9, 8, 6),
            (  4, 2, 1,11,10,13, 7, 8,15, 9,12, 5, 6, 3, 0,14),
            ( 11, 8,12, 7, 1,14, 2,13, 6,15, 0, 9,10, 4, 5, 3)),

            ((12, 1,10,15, 9, 2, 6, 8, 0,13, 3, 4,14, 7, 5,11),
            ( 10,15, 4, 2, 7,12, 9, 5, 6, 1,13,14, 0,11, 3, 8),
            (  9,14,15, 5, 2, 8,12, 3, 7, 0, 4,10, 1,13,11, 6),
            (  4, 3, 2,12, 9, 5,15,10,11,14, 1, 7, 6, 0, 8,13)),

            (( 4,11, 2,14,15, 0, 8,13, 3,12, 9, 7, 5,10, 6, 1),
            ( 13, 0,11, 7, 4, 9, 1,10,14, 3, 5,12, 2,15, 8, 6),
            (  1, 4,11,13,12, 3, 7,14,10,15, 6, 8, 0, 5, 9, 2),
            (  6,11,13, 8, 1, 4,10, 7, 9, 5, 0,15,14, 2, 3,12)),

            ((13, 2, 8, 4, 6,15,11, 1,10, 9, 3,14, 5, 0,12, 7),
            (  1,15,13, 8,10, 3, 7, 4,12, 5, 6,11, 0,14, 9, 2),
            (  7,11, 4, 1, 9,12,14, 2, 0, 6,10,13,15, 3, 5, 8),
            (  2, 1,14, 7, 4,10, 8,13,15,12, 9, 0, 3, 5, 6,11)));

  PC_1 : Array [1..56] of Byte =( 57,49,41,33,25,17, 9,
                                   1,58,50,42,34,26,18,
                                  10, 2,59,51,43,35,27,
                                  19,11, 3,60,52,44,36,
                                  63,55,47,39,31,23,15,
                                   7,62,54,46,38,30,22,
                                  14, 6,61,53,45,37,29,
                                  21,13, 5,28,20,12, 4);

  PC_2 : Array [1..48] of Byte =( 14,17,11,24, 1, 5,
                                   3,28,15, 6,21,10,
                                  23,19,12, 4,26, 8,
                                  16, 7,27,20,13, 2,
                                  41,52,31,37,47,55,
                                  30,40,51,45,33,48,
                                  44,49,39,56,34,53,
                                  46,42,50,36,29,32);

  ShiftTable : Array [1..16] of Byte =( 1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1);

  PI_SUBST: array[0..255] of Byte = (
    41, 46, 67, 201, 162, 216, 124, 1, 61, 54, 84, 161, 236, 240, 6,
    19, 98, 167, 5, 243, 192, 199, 115, 140, 152, 147, 43, 217, 188,
    76, 130, 202, 30, 155, 87, 60, 253, 212, 224, 22, 103, 66, 111, 24,
    138, 23, 229, 18, 190, 78, 196, 214, 218, 158, 222, 73, 160, 251,
    245, 142, 187, 47, 238, 122, 169, 104, 121, 145, 21, 178, 7, 63,
    148, 194, 16, 137, 11, 34, 95, 33, 128, 127, 93, 154, 90, 144, 50,
    39, 53, 62, 204, 231, 191, 247, 151, 3, 255, 25, 48, 179, 72, 165,
    181, 209, 215, 94, 146, 42, 172, 86, 170, 198, 79, 184, 56, 210,
    150, 164, 125, 182, 118, 252, 107, 226, 156, 116, 4, 241, 69, 157,
    112, 89, 100, 113, 135, 32, 134, 91, 207, 101, 230, 45, 168, 2, 27,
    96, 37, 173, 174, 176, 185, 246, 28, 70, 97, 105, 52, 64, 126, 15,
    85, 71, 163, 35, 221, 81, 175, 58, 195, 92, 249, 206, 186, 197,
    234, 38, 44, 83, 13, 110, 133, 40, 132, 9, 211, 223, 205, 244, 65,
    129, 77, 82, 106, 220, 55, 200, 108, 193, 171, 250, 36, 225, 123,
    8, 12, 189, 177, 74, 120, 136, 149, 139, 227, 99, 232, 109, 233,
    203, 213, 254, 59, 0, 29, 57, 242, 239, 183, 14, 102, 88, 208, 228,
    166, 119, 114, 248, 235, 117, 75, 10, 49, 68, 80, 180, 143, 237,
    31, 26, 219, 153, 141, 51, 159, 17, 131, 20
  );

const
  MD_PADDING: array[0..63] of Byte = (
    $80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  );

  S11 = 3;
  S12 = 7;
  S13 = 11;
  S14 = 19;
  S21 = 3;
  S22 = 5;
  S23 = 9;
  S24 = 13;
  S31 = 3;
  S32 = 9;
  S33 = 11;
  S34 = 15;

function rol(x: LongWord; y: Byte): LongWord; assembler;
asm
  mov   cl,dl
  rol   eax,cl
end;

function F(x, y, z: LongWord): LongWord; assembler;
asm
  and   edx,eax
  not   eax
  and   eax,ecx
  or    eax,edx
end;

function G(x, y, z: LongWord): LongWord; assembler;
asm
  push  ecx
  and   ecx,eax
  and   eax,edx
  or    eax,ecx
  pop   ecx
  and   edx,ecx
  or    eax,edx
end;

function H(x, y, z: LongWord): LongWord; assembler;
asm
  xor eax,edx
  xor eax,ecx
end;

function TEncryption.StrToBase64(const Buffer: String): String;
const
	Codes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var
	iRest, iLen, iQuad: Integer;
	Byte3: array[0..2] of Byte;
	sBuffer: String;
begin
	Result := '';
	SetLength( sBuffer, 4 * ( ( Length( Buffer ) + 2 ) div 3 ) );
	FillChar( sBuffer[1], Length( sBuffer ), 0 );

	iQuad := 0;
	iLen := Length(Buffer);
	iRest := iLen;

	while iRest > 0 do
	begin
		Move(Buffer[iLen - iRest + 1], Byte3, Trunc(Min(3, iRest)));
		sBuffer[iQuad + 1] := Codes[(Byte3[0] div 4) + 1];

		if iRest > 1 then
		begin
			sBuffer[iQuad + 2] := Codes[(Byte3[0] mod 4) * 16 + (Byte3[1] div 16) + 1];
			if iRest > 2 then
			begin
				sBuffer[iQuad + 3] := Codes[(Byte3[1] mod 16) * 4 + (Byte3[2] div 64) + 1];
				sBuffer[iQuad + 4] := Codes[Byte3[2] mod 64 + 1];
			end else
			begin
				sBuffer[iQuad + 3] := Codes[(Byte3[1] mod 16) * 4 + 1];
				sBuffer[iQuad + 4] := '=';
			end;
		end else
		begin
			sBuffer[iQuad + 2] := Codes[(Byte3[0] mod 4) * 16 + 1];
			sBuffer[iQuad + 3] := '=';
			sBuffer[iQuad + 4] := '=';
		end;

		Inc(iQuad, 4);
		Dec(iRest, 3);
	end;

	Result := Trim(sBuffer);
end;

function TEncryption.Base64ToStr(const Buffer: String): String;
var
	i, iCount, iIdx, iLen, iBuild: Integer;
  EndReached: Boolean;
  Ptr: PChar;
begin
	Result := '';

  SetLength( Result, 3 * ( Length( Buffer ) + 3 ) div 4 );
	iIdx := 0;
  iLen := 0;
  iBuild := 0;
  iCount := 3;
  EndReached := false;
  Ptr := @Result[ 1 ];

	for i := 1 to Length(Buffer) do
	begin
		Inc(iIdx);

		case Buffer[i] of
			'A'..'Z': iBuild := ( iBuild shl 6 ) + Ord(Buffer[i]) - 65;
			'a'..'z': iBuild := ( iBuild shl 6 ) + Ord(Buffer[i]) - 71;
			'0'..'9': iBuild := ( iBuild shl 6 ) + Ord(Buffer[i]) + 4;
			'+': 			iBuild := ( iBuild shl 6 ) + 62;
			'/': 			iBuild := ( iBuild shl 6 ) + 63;
			'=':
        begin
          if not EndReached then
            case iIdx of
            1: iCount := 0;
            2: iCount := 0;
            3: iCount := 1;
            4: iCount := 2;
            end;
          EndReached := true;
        end;
		end;

		if iIdx = 4 then
		begin
      Ptr[ 0 ] := Char( iBuild shr 16 );
      Ptr[ 1 ] := Char( ( iBuild shr 8 ) and $FF );
      Ptr[ 2 ] := Char( iBuild and $FF );
      Inc( Ptr, 3 );

      Inc( iLen, iCount );
      iCount := 3;
      iBuild := 0;
			iIdx := 0;
      EndReached := false;
		end;
	end;

  if ( iLen <> Length(Result) ) then
    SetLength(Result, iLen);
end;

procedure TEncryption.FF(var a: LongWord; b, c, d, x, s: LongWord);
begin
  a := a + (F(b, c, d) + x);
  a := rol(a, s);
end;

procedure TEncryption.GG(var a: LongWord; b, c, d, x, s: LongWord);
begin
  a := a + G(b, c, d) + x + $5a827999;
  a := rol(a, s);
end;

procedure TEncryption.HH(var a: LongWord; b, c, d, x, s: LongWord);
begin
  a := a + H(b, c, d) + x + $6ed9eba1;
  a := rol(a, s);
end;

procedure TEncryption.MDInit(context: PMD4Ctx);
begin
  context^.count[0] := 0;
  context^.count[1] := 0;
  context^.state[0] := $67452301;
  context^.state[1] := $efcdab89;
  context^.state[2] := $98badcfe;
  context^.state[3] := $10325476;
end;

procedure TEncryption.MDEncode(output, input: Pointer; len: LongWord);
var
  i, j: LongWord;
begin
  i := 0; j := 0;
  while j < len do
  begin
    PByteArray(output)^[j] := (PDWordArray(input)^[i] and $ff);
    PByteArray(output)^[j + 1] := ((PDWordArray(input)^[i] shr 8) and $ff);
    PByteArray(output)^[j + 2] := ((PDWordArray(input)^[i] shr 16) and $ff);
    PByteArray(output)^[j + 3] := ((PDWordArray(input)^[i] shr 24) and $ff);
    Inc(i); Inc(j, 4);
  end;
end;

procedure TEncryption.MDDecode(output, input: Pointer; len: LongWord);
var
  i, j: LongWord;
begin
  i := 0; j := 0;
  while j < len do
  begin
    PDWordArray(output)^[i] := PByteArray(input)^[j] or (PByteArray(input)^[j + 1] shl 8) or (PByteArray(input)^[j + 2] shl 16) or (PByteArray(input)^[j + 3] shl 24);
    Inc(i); Inc(j, 4);
  end;
end;

procedure TEncryption.MD4Transform (var state: array of LongWord; block: Pointer);
var
  a, b, c, d: LongWord;
  x: array[0..15] of LongWord;
begin
  a := state[0]; b := state[1]; c := state[2]; d := state[3];
  MDDecode(@x, block, 64);

  FF (a, b, c, d, x[ 0], S11);
  FF (d, a, b, c, x[ 1], S12);
  FF (c, d, a, b, x[ 2], S13);
  FF (b, c, d, a, x[ 3], S14);
  FF (a, b, c, d, x[ 4], S11);
  FF (d, a, b, c, x[ 5], S12);
  FF (c, d, a, b, x[ 6], S13);
  FF (b, c, d, a, x[ 7], S14);
  FF (a, b, c, d, x[ 8], S11);
  FF (d, a, b, c, x[ 9], S12);
  FF (c, d, a, b, x[10], S13);
  FF (b, c, d, a, x[11], S14);
  FF (a, b, c, d, x[12], S11);
  FF (d, a, b, c, x[13], S12);
  FF (c, d, a, b, x[14], S13);
  FF (b, c, d, a, x[15], S14);

  GG (a, b, c, d, x[ 0], S21);
  GG (d, a, b, c, x[ 4], S22);
  GG (c, d, a, b, x[ 8], S23);
  GG (b, c, d, a, x[12], S24);
  GG (a, b, c, d, x[ 1], S21);
  GG (d, a, b, c, x[ 5], S22);
  GG (c, d, a, b, x[ 9], S23);
  GG (b, c, d, a, x[13], S24);
  GG (a, b, c, d, x[ 2], S21);
  GG (d, a, b, c, x[ 6], S22);
  GG (c, d, a, b, x[10], S23);
  GG (b, c, d, a, x[14], S24);
  GG (a, b, c, d, x[ 3], S21);
  GG (d, a, b, c, x[ 7], S22);
  GG (c, d, a, b, x[11], S23);
  GG (b, c, d, a, x[15], S24);

  HH (a, b, c, d, x[ 0], S31);
  HH (d, a, b, c, x[ 8], S32);
  HH (c, d, a, b, x[ 4], S33);
  HH (b, c, d, a, x[12], S34);
  HH (a, b, c, d, x[ 2], S31);
  HH (d, a, b, c, x[10], S32);
  HH (c, d, a, b, x[ 6], S33);
  HH (b, c, d, a, x[14], S34);
  HH (a, b, c, d, x[ 1], S31);
  HH (d, a, b, c, x[ 9], S32);
  HH (c, d, a, b, x[ 5], S33);
  HH (b, c, d, a, x[13], S34);
  HH (a, b, c, d, x[ 3], S31);
  HH (d, a, b, c, x[11], S32);
  HH (c, d, a, b, x[ 7], S33);
  HH (b, c, d, a, x[15], S34);

  state[0] := state[0] + a;
  state[1] := state[1] + b;
  state[2] := state[2] + c;
  state[3] := state[3] + d;
end;

procedure TEncryption.MDUpdate(context: PMD4Ctx; input: Pointer; inputLen: LongWord);
var
  i, index, partLen: LongWord;
begin
  index := (context^.count[0] shr 3) and $3F;

  context^.count[0] := context^.count[0] + inputLen shl 3;
  if (context^.count[0] < (inputLen shl 3)) then
    Inc(context^.count[1]);

  context^.count[1] := context^.count[1] + inputLen shr 29;
  partLen := 64 - index;

  if (inputLen >= partLen) then
  begin
    Move(input^, context^.buffer[index], partLen);
    MD4Transform(context^.state, @context^.buffer);
    i := partLen;
    while i + 63 < inputLen do
    begin
      MD4Transform(context^.state, Addr(PByteArray(input)^[i]));
      Inc(i, 64);
    end;
    index := 0;
  end
  else
    i := 0;
  Move(PByteArray(input)^[i], context^.buffer[index], inputLen - i);
end;

function TEncryption.MDFinal(context: PMD4Ctx): String;
var
  digest: array[0..15] of Char;
  bits: array[0..7] of Char;
  index, padLen: LongWord;
begin
  MDEncode(@bits, @context^.count, 8);

  index := (context^.count[0] shr 3) and $3f;
  if (index < 56) then
    padLen := 56 - index
  else
    padLen := 120 - index;

  MDUpdate(context, @MD_PADDING, padLen);

  MDUpdate(context, @bits, 8);
  MDEncode(@digest, @context^.state, 16);

  FillChar(context^, 0, SizeOf(TMD4Ctx));

  Result := Digest;
end;

function TEncryption.GetBit(var Data; Index: Byte): Byte;
var
  Bits: Array [0..7] of Byte absolute Data;
begin
  Dec( Index );
  if Bits[Index div 8] and ( 128 shr( Index mod 8 ) ) > 0 then
    GetBit := 1
  else
    GetBit := 0;
end;

procedure TEncryption.SetBit( var Data; Index, Value : Byte );
var
  Bits: Array [0..7] Of Byte absolute Data;
  Bit: Byte;
begin
  Dec( Index );
  Bit := 128 shr( Index mod 8 );
  case Value of
    0: Bits[Index div 8] := Bits[Index div 8] and ( not Bit );
    1: Bits[Index div 8] := Bits[Index div 8] or Bit;
  end;
end;

procedure TEncryption.DF( var FK );
var
  K : Array [1..48] Of Byte absolute FK;
  Temp1 : Array [1..48] Of Byte;
  Temp2 : Array [1..32] Of Byte;
  n, h, i, j, Row, Column : Integer;
begin
  for n:=1 to 48 do
    Temp1[n]:=FR[E[n]] xor K[n];
  for n:=1 to 8 do
  begin
    i := ( n - 1 ) * 6;
    j := ( n -1 ) * 4;
    Row := Temp1[i+1] * 2 + Temp1[i+6];
    Column := Temp1[i+2] * 8 + Temp1[i+3] * 4 + Temp1[i+4] * 2 + Temp1[i+5];
    for h := 1 to 4 Do
    begin
      case h of
        1: Temp2[j+h] := ( SBoxes[n,Row,Column] and 8 ) div 8;
        2: Temp2[j+h] := ( SBoxes[n,Row,Column] and 4 ) div 4;
        3: Temp2[j+h] := ( SBoxes[n,Row,Column] and 2 ) div 2;
        4: Temp2[j+h] := ( SBoxes[n,Row,Column] and 1 );
      end;
    end;
  end;
  for n := 1 to 32 do
    FfunctionResult[n] := Temp2[P[n]];
end;

procedure TEncryption.Shift( var SubKeyPart );
var
  SKP: Array [1..28] Of Byte absolute SubKeyPart;
  n, b: Byte;
begin
  b := SKP[1];
  for n := 1 to 27 do
    SKP[n] := SKP[n+1];
  SKP[28] := b;
end;

procedure TEncryption.SubKey( Round: Byte; var SubKey );
var
  SK : Array [1..48] of Byte absolute SubKey;
  n, b : Byte;
begin
  for n := 1 to ShiftTable[Round] do
  begin
    Shift( FC );
    Shift( FD );
  end;
  for n := 1 to 48 do
  begin
    b := PC_2[n];
    if b <= 28 then
      SK[n] := FC[b]
    else
      SK[n] := FD[b-28];
  end;
end;

procedure TEncryption.SetKeys;
var
 n: Byte;
 Key: Array [0..7] of Byte;
begin
  move( FKey[1], Key, 8 );
  for n := 1 to 28 do
  begin
    FC[n] := GetBit( Key, PC_1[n] );
    FD[n] := GetBit( Key, PC_1[n+28] );
  end;
  for n := 1 to 16 do
    SubKey( n,FRoundKeys[n] );
end;

procedure TEncryption.EncipherBlock;
var
  n, b, Round : Byte;
begin
  for n := 1 to 64 do
    FInputValue[n]:=GetBit( FSmallBuffer, n );
  for n := 1 to 64 do
    if n <= 32 then
      FL[n] := FInputValue[IP[n]]
    else
      FR[n-32] := FInputValue[IP[n]];
  for Round := 1 to 16 do
  begin
    DF( FRoundKeys[Round] );
    For n := 1 to 32 do
      FfunctionResult[n] := FfunctionResult[n] xor FL[n];
    FL := FR;
    FR := FfunctionResult;
  end;
  for n := 1 to 64 do
  begin
    b := InvIP[n];
    if b <= 32 then
      FOutputValue[n] := FR[b]
    else
      FOutputValue[n] := FL[b-32];
  end;
  for n := 1 to 64 do
    SetBit( FSmallBuffer, n, FOutputValue[n] );
end;

function TEncryption.DesEcbEncrypt(AKey: String; AData: Array of byte): String;
var
  i, j, t, bit: Integer;
begin
  SetLength( FKey, 8 );
  FKey[1] := AKey[1];
  FKey[2] := char( ( ( Byte( AKey[1] ) shl 7 ) and $FF ) or ( Byte( AKey[2] ) shr 1 ) );
  FKey[3] := char( ( ( Byte( AKey[2] ) shl 6 ) and $FF ) or ( Byte( AKey[3] ) shr 2 ) );
  FKey[4] := char( ( ( Byte( AKey[3] ) shl 5 ) and $FF ) or ( Byte( AKey[4] ) shr 3 ) );
  FKey[5] := char( ( ( Byte( AKey[4] ) shl 4 ) and $FF ) or ( Byte( AKey[5] ) shr 4 ) );
  FKey[6] := char( ( ( Byte( AKey[5] ) shl 3 ) and $FF ) or ( Byte( AKey[6] ) shr 5 ) );
  FKey[7] := char( ( ( Byte( AKey[6] ) shl 2 ) and $FF ) or ( Byte( AKey[7] ) shr 6 ) );
  FKey[8] := char( ( ( Byte( AKey[7] ) shl 1 ) and $FF ) );

  for i := 1 to 8 do
  begin
    for j := 1 to 7 do
    begin
      bit := 0;
      t := Byte( Fkey[i] ) shl j;
      bit :=( t xor bit) and $1;
    end;
    Fkey[i] := char( ( Byte( Fkey[i] ) and $FE ) or bit );
  end;
  SetKeys;

  SetLength( Result, 8 );
  move( AData, FSmallBuffer, 8 );
  EncipherBlock;
  move( FSmallBuffer, Result[1], 8 );
end;

end.
