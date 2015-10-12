{ 
  $Id: base64.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

  $Log: base64.pas,v $
  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***


  The contents of this file are subject to the Mozilla Public License
  Version 1.1 (the "License"); you may not use this file except in
  compliance with the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS"
  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
  License for the specific language governing rights and limitations
  under the License.

  The Original Code is DIMime.pas.

  The Initial Developer of the Original Code is Ralf Junker <delphi@zeitungsjunge.de>.

  All Rights Reserved. }

{$A+,B-,H+,J-,T+,X+}

unit base64;

interface

{ @abstract(Mime-encodes an AnsiString.)
  @Name takes an AnsiString, encodes it, and returns the result as an AnsiString.
  To decode the result string, use @link(MimeDecodeString). }
function MimeEncodeString(const S: AnsiString): AnsiString;

{ @abstract(Mime-encodes an AnsiString.)
  @Name is just like @link(MimeEncodeString), but does <B>not</B> insert line breaks. }
function MimeEncodeStringNoCRLF(const S: AnsiString): AnsiString;

{ @abstract(Mime-decodes an AnsiString.)
  @Name takes a a string, decodes it, and returns the result as a string.
  Use @Name to decode a string previously encoded with link(MimeEncodeString). }
function MimeDecodeString(const S: AnsiString): AnsiString;

{ @abstract(Calculates Mime-encoding output size.)
  Calculates the output size of i MimeEncoded bytes, i.e. the memory required
  for all decoded data plus the line breaks. Use for @link(MimeEncode) only. }
function MimeEncodedSize(const InputSize: Cardinal): Cardinal;

{ @abstract(Calculates Mime-encoding output size.)
  Calculates the output size of i MimeEncodedNoCRLF bytes, i.e. the memory
  required for all decoded data. Use for @link(MimeEncodedNoCRLF) only. }
function MimeEncodedSizeNoCRLF(const InputSize: Cardinal): Cardinal;

{ @abstract(Calculates Mime-decoding output size.)
  Calculates the maximum output size of i MimeDecoded bytes.
  You may use it for @link(MimeDecode) to calculate the maximum amount of memory
  required for decoding in one single pass. }
function MimeDecodedSize(const InputSize: Cardinal): Cardinal;

{ @abstract(Decodes UserID and Password for HTTP Basic Authentication.)
  Decodes the UserID and Password for HTTP Basic Authentication. Pass the
  contents of the Authorization Header as BasicCredentials and DecodeHttpBasicAuthentication
  will return the unencoded UserID and Password. If either of the two can not be
  decoded or found, they will result in an empty string (''). This procedure is
  inspired by Shiv.
  <P>The following quote from "Request for Comments (RFC) 1945: Hypertext Transfer
  Protocol -- HTTP/1.0" has the details:
  <UL>
  <P>11.1  Basic Authentication Scheme
  <P>The "basic" authentication scheme is based on the model that the user
  agent must authenticate itself with a user-ID and a password for each
  realm. The realm value should be considered an opaque string which
  can only be compared for equality with other realms on that server.
  The server will authorize the request only if it can validate the
  user-ID and password for the protection space of the Request-URI.
  There are no optional authentication parameters.
  <P>Upon receipt of an unauthorized request for a URI within the
  protection space, the server should respond with a challenge like the
  following:
  <P>@code(WWW-Authenticate: Basic realm="WallyWorld")
  <P>where "WallyWorld" is the string assigned by the server to identify
  the protection space of the Request-URI.
  <P>To receive authorization, the client sends the user-ID and password,
  separated by a single colon (":") character, within a base64 [5]
  encoded string in the credentials.
  <P>@code(basic-credentials = "Basic" SP basic-cookie)
  <P>@code(basic-cookie) = @<base64 [5] encoding of userid-password, except not limited to 76 char/line@>
  <BR>@code(userid-password) = [ token ] ":" *TEXT
  <P>If the user agent wishes to send the user-ID "Aladdin" and password
  "open sesame", it would use the following header field:
  <P>@code(Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==)
  <P>The basic authentication scheme is a non-secure method of filtering
  unauthorized access to resources on an HTTP server. It is based on
  the assumption that the connection between the client and the server
  can be regarded as a trusted carrier. As this is not generally true
  on an open network, the basic authentication scheme should be used
  accordingly. In spite of this, clients should implement the scheme in
  order to communicate with servers that use it.
  </UL>}
procedure DecodeHttpBasicAuthentication(const BasicCredentials: AnsiString; out UserId, PassWord: AnsiString);

{ @abstract(Primary Mime encoding routine.)
  @Name is the primary Mime encoding routine. Line breaks will be inserted
  after each full line.
  <P><B>Caution</B>: OutputBuffer must have enough memory allocated to take all
  encoded output. @link(MimeEncodedSize)(InputBytesCount) calculates this amount
  in bytes. @Name will then fill the entire OutputBuffer, so there is no
  OutputBytesCount result for this procedure. Preallocating all memory at once
  (as required by @Name) avoids the time-cosuming process of reallocation.
  <P>If not all data fits into memory at once, you can <B>not</B> use @Name
  multiple times. Instead, use a combintion of @link(MimeEncodeFullLines) and
  @link(MimeEncodeNoCRLF). }
procedure MimeEncode(const InputBuffer; const InputByteCount: Cardinal; out OutputBuffer);

{ @abstract(Primary Mime encoding routine.)
  @Name is just like @link(MimeEncode), but does <B>not</B> insert line breaks.
  <P>Unlike @link(MimeEncode), you can use @NAme multiple times if not all data
  fits into memory at once. But you must be very careful about the size
  of the InputBuffer. See comments on @link(BUFFER_SIZE) for details
  and @link(MimeEncodeStreamNoCRLF) for an example. }
procedure MimeEncodeNoCRLF(const InputBuffer; const InputByteCount: Cardinal; out OutputBuffer);

{ @abstract(Internal Mime encoding helper routine.)
  @Name will decode full lines of @link(MIME_ENCODED_LINE_BREAK) length.
  A line break (CRLF) will be inserted after each line including the last one.
  Any remaining input which would not result in a full line will not be encoded.
  To encode the remaining partial line, use @link(MimeEncodeNoCRLF) with the
  appropriate parameters. @Name requires an OutputBuffer large enough for all
  encoded output. The required size of the OutputBuffer can be calculated with
  <P>@code((InputByteCount + 2) div 3 * 4 + InputByteCount div MIME_DECODED_LINE_BREAK * 2)
  <P>@Name will fill the entire OutputBuffer of that size. }
procedure MimeEncodeFullLines(const InputBuffer; const InputByteCount: Cardinal; out OutputBuffer);

{ @abstract(Primary Mime decoding routine.)
  The primary Mime decoding routines. @Name works with all MimeEncoded data,
  no matter if it was encoded with or without line breaks. Line breaks characters
  which are outside of the base64 alphabet and will be ignored.
  <P><B>Caution</B>: OutputBuffer must have enough memory allocated to take all output.
  @link(MimeDecodedSize)(InputBytesCount) calculates this amount in bytes. There is
  no guarantee that all output will be filled after decoding. All decoding
  functions therefore return the acutal number of bytes written to OutputBuffer.
  Preallocating all memory at once (as is required by MimeDecode)
  avoids the time-cosuming process of reallocation. After calling
  @Name, simply cut the allocated memory down to OutputBytesCount,
  i.e. calling @code(SetLength (OutString, OutputBytesCount)) for strings.
  <P>If not all data fits into memory at once, you may <B>not</B> use @Name multiple
  times. Instead, you must use a combination of @link(MimeDecodePartial) and
  @link(MimeDecodePartialEnd) functions. See @link(MimeDecodeStream) for an example. }
function MimeDecode(const InputBuffer; const InputBytesCount: Cardinal; out OutputBuffer): Cardinal;

{ @abstract(Internal Mime decoding helper routine.)
  The @Name function is mostly for internal use. It serves the purpose of
  decoding very large data in multiple parts of smaller chunks, as in
  @link(MimeDecodeStream).
  <P>Used in conjunction with @link(MimeDecodePartialEnd). }
function MimeDecodePartial(const InputBuffer; const InputBytesCount: Cardinal; out OutputBuffer; var ByteBuffer: Cardinal; var ByteBufferSpace: Cardinal): Cardinal;

{ @abstract(Internal Mime decoding helper routine.)
  The @Name function is mostly for internal use. It serves the purpose of
  decoding very large data in multiple parts of smaller chunks, as in
  @link(MimeDecodeStream).
  <P>Used in conjunction with @link(MimeDecodePartial). }
function MimeDecodePartialEnd(out OutputBuffer; const ByteBuffer: Cardinal; const ByteBufferSpace: Cardinal): Cardinal;

const
  { According to RFC 2045, @Name defaults to 76.
    If you ever need to change it, make sure it is a positive multiple of 4. }
  MIME_ENCODED_LINE_BREAK = 76;

  { Do not change this, even if you change @link(MIME_ENCODED_LINE_BREAK).
    @Name will always be a multiple of 3. }
  MIME_DECODED_LINE_BREAK = MIME_ENCODED_LINE_BREAK div 4 * 3;


implementation

const
  { The mime encoding table. Do not alter. }
  MIME_ENCODE_TABLE: array[0..63] of Byte = (
    065, 066, 067, 068, 069, 070, 071, 072, //  00 - 07
    073, 074, 075, 076, 077, 078, 079, 080, //  08 - 15
    081, 082, 083, 084, 085, 086, 087, 088, //  16 - 23
    089, 090, 097, 098, 099, 100, 101, 102, //  24 - 31
    103, 104, 105, 106, 107, 108, 109, 110, //  32 - 39
    111, 112, 113, 114, 115, 116, 117, 118, //  40 - 47
    119, 120, 121, 122, 048, 049, 050, 051, //  48 - 55
    052, 053, 054, 055, 056, 057, 043, 047); // 56 - 63

  MIME_PAD_CHAR = Byte('=');

  MIME_DECODE_TABLE: array[Byte] of Cardinal = (
    255, 255, 255, 255, 255, 255, 255, 255, //   0 -   7
    255, 255, 255, 255, 255, 255, 255, 255, //   8 -  15
    255, 255, 255, 255, 255, 255, 255, 255, //  16 -  23
    255, 255, 255, 255, 255, 255, 255, 255, //  24 -  31
    255, 255, 255, 255, 255, 255, 255, 255, //  32 -  39
    255, 255, 255, 062, 255, 255, 255, 063, //  40 -  47
    052, 053, 054, 055, 056, 057, 058, 059, //  48 -  55
    060, 061, 255, 255, 255, 255, 255, 255, //  56 -  63
    255, 000, 001, 002, 003, 004, 005, 006, //  64 -  71
    007, 008, 009, 010, 011, 012, 013, 014, //  72 -  79
    015, 016, 017, 018, 019, 020, 021, 022, //  80 -  87
    023, 024, 025, 255, 255, 255, 255, 255, //  88 -  95
    255, 026, 027, 028, 029, 030, 031, 032, //  96 - 103
    033, 034, 035, 036, 037, 038, 039, 040, // 104 - 111
    041, 042, 043, 044, 045, 046, 047, 048, // 112 - 119
    049, 050, 051, 255, 255, 255, 255, 255, // 120 - 127
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255);

type
  PByte4 = ^TByte4;
  TByte4 = packed record
    b1: Byte;
    b2: Byte;
    b3: Byte;
    b4: Byte;
  end;

  PByte3 = ^TByte3;
  TByte3 = packed record
    b1: Byte;
    b2: Byte;
    b3: Byte;
  end;

  PCardinal = ^Cardinal;

  { ---------------------------------------------------------------------------- }
  { String Encoding & Decoding
  { ---------------------------------------------------------------------------- }

function MimeEncodeString(const S: AnsiString): AnsiString;
var
  L: Cardinal;
begin
  if Pointer(S) <> nil then
    begin
      L := PCardinal(Cardinal(S) - 4)^;
      SetLength(Result, MimeEncodedSize(L));
      MimeEncode(Pointer(S)^, L, Pointer(Result)^);
    end
  else
    Result := '';
end;

{ ---------- }

function MimeEncodeStringNoCRLF(const S: AnsiString): AnsiString;
var
  L: Cardinal;
begin
  if Pointer(S) <> nil then
    begin
      L := PCardinal(Cardinal(S) - 4)^;
      SetLength(Result, MimeEncodedSizeNoCRLF(L));
      MimeEncodeNoCRLF(Pointer(S)^, L, Pointer(Result)^);
    end
  else
    Result := '';
end;

{ ---------- }

function MimeDecodeString(const S: AnsiString): AnsiString;
var
  ByteBuffer, ByteBufferSpace: Cardinal;
  L: Cardinal;
begin
  if Pointer(S) <> nil then
    begin
      L := PCardinal(Cardinal(S) - 4)^;
      SetLength(Result, MimeDecodedSize(L));
      ByteBuffer := 0;
      ByteBufferSpace := 4;
      L := MimeDecodePartial(Pointer(S)^, L, Pointer(Result)^, ByteBuffer, ByteBufferSpace);
      Inc(L, MimeDecodePartialEnd(Pointer(Cardinal(Result) + L)^, ByteBuffer, ByteBufferSpace));
      SetLength(Result, L);
    end
  else
    Result := '';
end;

{ ---------- }

procedure DecodeHttpBasicAuthentication(const BasicCredentials: AnsiString; out UserId, PassWord: AnsiString);
label
  Fail;
const
  LBasic = 6; { Length ('Basic ') }
var
  DecodedPtr, P: PAnsiChar;
  I, L: Cardinal;
begin
  P := Pointer(BasicCredentials);
  if P = nil then goto Fail;

  L := Cardinal(Pointer(P - 4)^);
  if L <= LBasic then goto Fail;

  Dec(L, LBasic);
  Inc(P, LBasic);

  GetMem(DecodedPtr, MimeDecodedSize(L));
  L := MimeDecode(P^, L, DecodedPtr^);

  { Look for colon (':'). }
  I := 0;
  P := DecodedPtr;
  while (L > 0) and (P[I] <> ':') do
    begin
      Inc(I);
      Dec(L);
    end;

  { Store UserId and Password. }
  SetString(UserId, DecodedPtr, I);
  if L > 1 then
    SetString(PassWord, DecodedPtr + I + 1, L - 1)
  else
    PassWord := '';

  FreeMem(DecodedPtr);
  Exit;

  Fail:
  UserId := '';
  PassWord := '';
end;

{ ---------------------------------------------------------------------------- }
{ Size Functions
{ ---------------------------------------------------------------------------- }

function MimeEncodedSize(const InputSize: Cardinal): Cardinal;
begin
  if InputSize > 0 then
    Result := (InputSize + 2) div 3 * 4 + (InputSize - 1) div MIME_DECODED_LINE_BREAK * 2
  else
    Result := InputSize;
end;

{ ---------- }

function MimeEncodedSizeNoCRLF(const InputSize: Cardinal): Cardinal;
begin
  Result := (InputSize + 2) div 3 * 4;
end;

{ ---------- }

function MimeDecodedSize(const InputSize: Cardinal): Cardinal;
begin
  Result := (InputSize + 3) div 4 * 3;
end;

{ ---------------------------------------------------------------------------- }
{ Encoding Core
{ ---------------------------------------------------------------------------- }

procedure MimeEncode(const InputBuffer; const InputByteCount: Cardinal; out OutputBuffer);
var
  IDelta, ODelta: Cardinal;
begin
  MimeEncodeFullLines(InputBuffer, InputByteCount, OutputBuffer);
  IDelta := InputByteCount div MIME_DECODED_LINE_BREAK; // Number of lines processed so far.
  ODelta := IDelta * (MIME_ENCODED_LINE_BREAK + 2);
  IDelta := IDelta * MIME_DECODED_LINE_BREAK;
  MimeEncodeNoCRLF(Pointer(Cardinal(@InputBuffer) + IDelta)^, InputByteCount - IDelta, Pointer(Cardinal(@OutputBuffer) + ODelta)^);
end;

{ ---------- }

procedure MimeEncodeFullLines(const InputBuffer; const InputByteCount: Cardinal; out OutputBuffer);
var
  B, InnerLimit, OuterLimit: Cardinal;
  InPtr: PByte3;
  OutPtr: PByte4;
begin
  { Do we have enough input to encode a full line? }
  if InputByteCount < MIME_DECODED_LINE_BREAK then Exit;

  InPtr := @InputBuffer;
  OutPtr := @OutputBuffer;

  InnerLimit := Cardinal(InPtr);
  Inc(InnerLimit, MIME_DECODED_LINE_BREAK);

  OuterLimit := Cardinal(InPtr);
  Inc(OuterLimit, InputByteCount);

  { Multiple line loop. }
  repeat

    { Single line loop. }
    repeat
      { Read 3 bytes from InputBuffer. }
      B := InPtr^.b1;
      B := B shl 8;
      B := B or InPtr^.b2;
      B := B shl 8;
      B := B or InPtr^.b3;
      Inc(InPtr);
      { Write 4 bytes to OutputBuffer (in reverse order). }
      OutPtr^.b4 := MIME_ENCODE_TABLE[B and $3F];
      B := B shr 6;
      OutPtr^.b3 := MIME_ENCODE_TABLE[B and $3F];
      B := B shr 6;
      OutPtr^.b2 := MIME_ENCODE_TABLE[B and $3F];
      B := B shr 6;
      OutPtr^.b1 := MIME_ENCODE_TABLE[B];
      Inc(OutPtr);
    until Cardinal(InPtr) >= InnerLimit;

    { Write line break (CRLF). }
    OutPtr^.b1 := 13;
    OutPtr^.b2 := 10;
    Inc(Cardinal(OutPtr), 2);

    Inc(InnerLimit, MIME_DECODED_LINE_BREAK);
  until InnerLimit > OuterLimit;
end;

{ ---------- }

procedure MimeEncodeNoCRLF(const InputBuffer; const InputByteCount: Cardinal; out OutputBuffer);
var
  B, InnerLimit, OuterLimit: Cardinal;
  InPtr: PByte3;
  OutPtr: PByte4;
begin
  if InputByteCount = 0 then Exit;

  InPtr := @InputBuffer;
  OutPtr := @OutputBuffer;

  OuterLimit := InputByteCount div 3 * 3;

  InnerLimit := Cardinal(InPtr);
  Inc(InnerLimit, OuterLimit);

  { Last line loop. }
  while Cardinal(InPtr) < InnerLimit do
    begin
      { Read 3 bytes from InputBuffer. }
      B := InPtr^.b1;
      B := B shl 8;
      B := B or InPtr^.b2;
      B := B shl 8;
      B := B or InPtr^.b3;
      Inc(InPtr);
      { Write 4 bytes to OutputBuffer (in reverse order). }
      OutPtr^.b4 := MIME_ENCODE_TABLE[B and $3F];
      B := B shr 6;
      OutPtr^.b3 := MIME_ENCODE_TABLE[B and $3F];
      B := B shr 6;
      OutPtr^.b2 := MIME_ENCODE_TABLE[B and $3F];
      B := B shr 6;
      OutPtr^.b1 := MIME_ENCODE_TABLE[B];
      Inc(OutPtr);
    end;

  { End of data & padding. }
  case InputByteCount - OuterLimit of
    1:
      begin
        B := InPtr^.b1;
        B := B shl 4;
        OutPtr.b2 := MIME_ENCODE_TABLE[B and $3F];
        B := B shr 6;
        OutPtr.b1 := MIME_ENCODE_TABLE[B];
        OutPtr.b3 := MIME_PAD_CHAR; { Pad remaining 2 bytes. }
        OutPtr.b4 := MIME_PAD_CHAR;
      end;
    2:
      begin
        B := InPtr^.b1;
        B := B shl 8;
        B := B or InPtr^.b2;
        B := B shl 2;
        OutPtr.b3 := MIME_ENCODE_TABLE[B and $3F];
        B := B shr 6;
        OutPtr.b2 := MIME_ENCODE_TABLE[B and $3F];
        B := B shr 6;
        OutPtr.b1 := MIME_ENCODE_TABLE[B];
        OutPtr.b4 := MIME_PAD_CHAR; { Pad remaining byte. }
      end;
  end;
end;

{ ---------------------------------------------------------------------------- }
{ Decoding Core
{ ---------------------------------------------------------------------------- }

function MimeDecode(const InputBuffer; const InputBytesCount: Cardinal; out OutputBuffer): Cardinal;
var
  ByteBuffer, ByteBufferSpace: Cardinal;
begin
  ByteBuffer := 0;
  ByteBufferSpace := 4;
  Result := MimeDecodePartial(InputBuffer, InputBytesCount, OutputBuffer, ByteBuffer, ByteBufferSpace);
  Inc(Result, MimeDecodePartialEnd(Pointer(Cardinal(@OutputBuffer) + Result)^, ByteBuffer, ByteBufferSpace));
end;

{ ---------- }

function MimeDecodePartial(const InputBuffer; const InputBytesCount: Cardinal; out OutputBuffer; var ByteBuffer: Cardinal; var ByteBufferSpace: Cardinal): Cardinal;
var
  lByteBuffer, lByteBufferSpace, C: Cardinal;
  InPtr, OuterLimit: ^Byte;
  OutPtr: PByte3;
begin
  if InputBytesCount > 0 then
    begin
      InPtr := @InputBuffer;
      Cardinal(OuterLimit) := Cardinal(InPtr) + InputBytesCount;
      OutPtr := @OutputBuffer;
      lByteBuffer := ByteBuffer;
      lByteBufferSpace := ByteBufferSpace;
      while InPtr <> OuterLimit do
        begin
          { Read from InputBuffer. }
          C := MIME_DECODE_TABLE[InPtr^];
          Inc(InPtr);
          if C = $FF then Continue;
          lByteBuffer := lByteBuffer shl 6;
          lByteBuffer := lByteBuffer or C;
          Dec(lByteBufferSpace);
          { Have we read 4 bytes from InputBuffer? }
          if lByteBufferSpace <> 0 then Continue;

          { Write 3 bytes to OutputBuffer (in reverse order). }
          OutPtr^.b3 := Byte(lByteBuffer);
          lByteBuffer := lByteBuffer shr 8;
          OutPtr^.b2 := Byte(lByteBuffer);
          lByteBuffer := lByteBuffer shr 8;
          OutPtr^.b1 := Byte(lByteBuffer);
          lByteBuffer := 0;
          Inc(OutPtr);
          lByteBufferSpace := 4;
        end;
      ByteBuffer := lByteBuffer;
      ByteBufferSpace := lByteBufferSpace;
      Result := Cardinal(OutPtr) - Cardinal(@OutputBuffer);
    end
  else
    Result := 0;
end;

{ ---------- }

function MimeDecodePartialEnd(out OutputBuffer; const ByteBuffer: Cardinal; const ByteBufferSpace: Cardinal): Cardinal;
var
  lByteBuffer: Cardinal;
begin
  case ByteBufferSpace of
    1:
      begin
        lByteBuffer := ByteBuffer shr 2;
        PByte3(@OutputBuffer)^.b2 := Byte(lByteBuffer);
        lByteBuffer := lByteBuffer shr 8;
        PByte3(@OutputBuffer)^.b1 := Byte(lByteBuffer);
        Result := 2;
      end;
    2:
      begin
        lByteBuffer := ByteBuffer shr 4;
        PByte3(@OutputBuffer)^.b1 := Byte(lByteBuffer);
        Result := 1;
      end;
  else
    Result := 0;
  end;
end;

end.


