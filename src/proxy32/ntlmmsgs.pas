{
  $Id: ntlmmsgs.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

  $Log: ntlmmsgs.pas,v $
  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}
unit NtlmMsgs;

interface

uses
  SysUtils, Encryption;

type
  TNTLM_Message1 = record
    Protocol: array [0..7] of Byte;
    MsgType: Char;
    Zero1: array [0..2] of Byte;
    Flags: Word;
    Zero2: array [0..1] of Byte;
    LenDomain1: Word;
    LenDomain2: Word;
    OffSetDomain: Word;
    Zero3: array [0..1] of Byte;
    LenHost1: Word;
    LenHost2: Word;
    OffSetHost: Word;
    Zero4: array [0..1] of Byte;
  end;

  TNTLM_Message2 = record
    Protocol: array [0..7] of Byte;
    MsgType: Char;
    Zero1: array [0..6] of Byte;
    LenMessage: Word;
    Zero2: array [0..1] of Byte;
    Flags: Word;
    Zero3: array [0..1] of Byte;
    Nonce: array [0..7] of Byte;
    Zero4: array [0..7] of Byte;
  end;

  TNTLM_Message3 = record
    Protocol: array [0..7] of Byte;
    MsgType: Char;
    Zero1: array [0..2] of Byte;
    Len_LM_Resp1: Word;  Len_LM_Resp2: Word;  OffSet_LM_Resp: Word;
    Zero2: array [0..1] of Byte;
    Len_NT_Resp1: Word; Len_NT_Resp2: Word; OffSet_NT_Resp: Word;
    Zero3: array [0..1] of Byte;
    LenDomain1: Word; LenDomain2: Word; OffSetDomain: Word;
    Zero4: array [0..1] of Byte;
    LenUser1: Word; LenUser2: Word; OffSetUser: Word;
    Zero5: array [0..1] of Byte;
    LenHost1: Word; LenHost2: Word; OffSetHost: Word;
    Zero6: array [0..5] of Byte;
    LenMessage: Word;
    Zero7: array [0..1] of Byte;
    Flags: Word;
    Zero8: array [0..1] of Byte;
  end;

type
  TNTLM = class
    private
      { Public declarations }
      function GetLMHash( APassword: WideString; ANonce: Array of Byte ): WideString;
      function GetNTHash( APassword: WideString; ANonce: Array of Byte ): WideString;
      function Unicode( AData: WideString ): WideString;
    public
      { Public declarations }
      function GetMessage1( AHost, ADomain: WideString ): WideString;
      function GetMessage2( AServerReply: WideString ): TNTLM_Message2;
      function GetMessage3( ADomain, AHost, AUser, APassword: WideString; ANonce: Array of Byte ): WideString;
  end;

implementation

{ TNTLM }
function TNTLM.GetMessage1(AHost, ADomain: WideString): WideString;
var
  Msg: TNTLM_Message1;
  MessageAux: WideString;
  Encryption: TEncryption;
begin
  Encryption := TEncryption.Create;
  AHost := UpperCase( AHost );
  ADomain := UpperCase( ADomain );
  with Msg do
  begin
    FillChar( Msg, sizeof( Msg ), #0 );
    Move( 'NTLMSSP' + #0, Protocol, 8 );
    MsgType := #1;
    Flags := 45571;
    LenHost1 := Length( AHost );
    LenHost2 := LenHost1;
    OffSetHost := $20;
    LenDomain1 := Length( ADomain );
    LenDomain2 := LenDomain1;
    OffSetDomain := OffSetHost + LenHost1;
  end;
  SetLength( MessageAux, sizeof( Msg ) );
  Move( Msg, MessageAux[1], sizeof( Msg ) );
  MessageAux := MessageAux + AHost + ADomain;

  Result := Encryption.StrToBase64( MessageAux );
end;

function TNTLM.GetMessage2(AServerReply: WideString): TNTLM_Message2;
var
  Msg: TNTLM_Message2;
  NTLMReply: WideString;
  Encryption: TEncryption;
begin
  Encryption := TEncryption.Create;
  NTLMReply := Encryption.Base64toStr( AServerReply );
  Move( NTLMReply[1], Msg, sizeof( Msg ) );
  Result := Msg;
end;

function TNTLM.GetMessage3(ADomain, AHost, AUser,
  APassword: WideString; ANonce: Array of Byte): WideString;
var
  Msg: TNTLM_Message3;
  MessageAux: WideString;
  LM_Resp, NT_Resp: WideString;
  Encryption: TEncryption;
begin
  Encryption := TEncryption.Create;
  ADomain := Unicode( UpperCase( ADomain ) );
  AHost := Unicode( UpperCase( AHost ) );
  AUser := Unicode( AUser );

  FillChar( Msg, Sizeof( Msg ), #0 );
  with Msg do
  begin
    Move( 'NTLMSSP' + #0, Protocol, 8 );
    MsgType := #3;
    LenDomain1 := Length( ADomain );
    LenDomain2 := LenDomain1;
    OffSetDomain := $40;
    LenUser1 := Length( AUser );
    LenUser2 := LenUser1;
    OffSetUser := OffSetDomain + LenDomain1;
    LenHost1 := Length( AHost );
    LenHost2 := LenHost1;
    OffSetHost := OffsetUser + LenUser1;
    Len_LM_Resp1 := $18;
    Len_LM_Resp2 := Len_LM_Resp1;
    OffSet_LM_Resp := OffsetHost + LenHost1;
    Len_NT_Resp1 := $18;
    Len_NT_Resp2 := Len_NT_Resp1;
    OffSet_NT_Resp := OffSet_LM_Resp + Len_LM_Resp1;
    LenMessage := Offset_NT_Resp + Len_NT_Resp1;
    Flags := 33281;
  end;
  LM_Resp := GetLMHash( APassword, ANonce );
  NT_Resp := GetNTHash( APassword, ANonce );
  SetLength( MessageAux, sizeof( Msg ) );
  Move( Msg, MessageAux[1], sizeof( Msg ) );
  MessageAux := MessageAux + ADomain + AUser + AHost + LM_Resp + NT_Resp;
  Result := Encryption.StrToBase64( MessageAux );
end;

function TNTLM.GetLMHash(APassword: WideString; ANonce: Array of Byte): WideString;
const
  magic: array [0..7] of Byte = ($4B, $47, $53, $21, $40, $23, $24, $25 );
var
  i: Integer;
  Encryption: TEncryption;
  PassHash: WideString;
begin
  Encryption := TEncryption.Create;
  APassword := UpperCase( APassword );
  if Length( APassword ) >= 14 then
    SetLength( APassword, 14 )
  else
    for i := Length( APassword ) to 14 do
      APassword := APassword + #0;

  PassHash := '';
  PassHash := Encryption.DesEcbEncrypt( Copy( APassword, 1, 7 ), magic );
  PassHash := PassHash + Encryption.DesEcbEncrypt( Copy( APassword, 8, 7 ), magic );
  PassHash := PassHash + #0#0#0#0#0;

  Result := Encryption.DesEcbEncrypt( Copy( PassHash, 1, 7 ), ANonce );
  Result := Result + Encryption.DesEcbEncrypt( Copy( PassHash, 8, 7 ), ANonce );
  Result := Result + Encryption.DesEcbEncrypt( Copy( PassHash, 15, 7 ), ANonce );
end;

function TNTLM.GetNTHash(APassword: WideString; ANonce: Array of byte): WideString;
var
  Pass: WideString;
  PassHash: WideString;
  Context: PMD4Ctx;
  Encryption: TEncryption;
begin
  Encryption := TEncryption.Create;

  Pass := Unicode( APassword );
  with Encryption do
  begin
    GetMem( Context, SizeOf( TMD4Ctx ) );
    MDInit( Context );
    MDUpdate( Context, PChar(Pass), Length( Pass ) );
    PassHash := MDFinal( Context );
    PassHash := PassHash + #0#0#0#0#0;
    FreeMem(Context, SizeOf(TMD4Ctx));

    Result := Encryption.DesEcbEncrypt( Copy( PassHash, 1, 7 ), ANonce );
    Result := Result + Encryption.DesEcbEncrypt( Copy( PassHash, 8, 7 ), ANonce );
    Result := Result + Encryption.DesEcbEncrypt( Copy( PassHash, 15, 7 ), ANonce );
  end;
end;

function TNTLM.Unicode(AData: WideString): WideString;
begin
     result := StringToOleStr(AData);
end;

end.
