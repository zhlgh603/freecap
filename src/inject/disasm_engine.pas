unit disasm_engine;

interface
uses Windows, SysUtils;

const
     BYTES_TO_DECODE = 16;

type
    TDecoded = record
      Assembly: array[0..255] of Byte;                      // Menemonics
      Remarks: array[0..255] of Byte; // Menemonic addons
      Opcode: array[0..29] of BYTE; // Opcode Byte forms
      Address: DWORD;     // Current address of decoded instruction
      OpcodeSize: BYTE;   // Opcode Size
      PrefixSize: BYTE;   // Size of all prefixes used
    end;
    PDecoded = ^TDecoded;

    TDisasmFunction = procedure (disassembly: PDecoded; Lineral: Pointer; var ByteFlowIndex: DWORD); cdecl;

    procedure Init;

    procedure GetCodeSizeInfo(StartPtr: Pointer; NeedCodeSize: Integer; var CodeSize, NopAlign: Integer);
    procedure RealignCallOffsets(StartPtr: Pointer; NeedCodeSize: Integer; NewAddress: Pointer);

implementation
uses cfg, loger;

var
   Decode: TDisasmFunction = nil;
   hMod: THandle = 0;


function GetStartupDir(): string;
var
   Buf: array[0..MAX_PATH] of Char;
   res: integer;
begin
     ZeroMemory(@Buf, SizeOF(Buf));
     res := GetEnvironmentVariable('FreeCAPStartupDir', @Buf, SizeOF(Buf));
     if (res <> 0) and (res <= SizeOF(Buf)) then
        result := String(Buf);
end;

/////////////////////////////////////////////////////////////////////////
//							  FUNCTIONS                                 //
//////////////////////////////////////////////////////////////////////////

procedure Init;
var
   startupdir: string;
begin
     startupdir := GetStartupDir() + 'disasm_engine.dll';

     if (hMod <> 0) then
       exit;

     if (hMod = 0) then
       hMod := LoadLibrary(PChar(startupdir));

     if hMod = 0 then exit;

     Decode := GetProcAddress(hMod, 'Disassemble');

     if (@Decode = nil) then // no pointer
     begin
          FreeLibrary(hMod);
          exit;
     end;
end;

procedure FlushDecoded(var Disasm: TDecoded);
begin
     // Clear all information of an decoded
     // Instruction
     ZeroMemory(@Disasm.Assembly, SIzeOf(Disasm.Assembly));
     ZeroMemory(@Disasm.Remarks, SIzeOf(Disasm.Remarks));
     ZeroMemory(@Disasm.Opcode, SIzeOf(Disasm.Opcode));
     Disasm.OpcodeSize := 1;
     Disasm.PrefixSize := 0;
end;


procedure GetCodeSizeInfo(StartPtr: Pointer; NeedCodeSize: Integer; var CodeSize, NopAlign: Integer);
var
   DisasmData: TDecoded;
   Index: DWORD;
   needee: integer;
begin
     if (@Decode = nil) then exit;
     DisasmData.Address := DWORD(StartPtr); // intial address
     FlushDecoded(DisasmData);     // clear the struct

     index := 0;
     needee := 0;

     while (index < BYTES_TO_DECODE) do
     begin
	  // Decode Instruction(s)
          Decode(@DisasmData, StartPtr, index);
	  // Calculate total Size of an instruction + Prefixes, and
	  // Fix the address of eIP
          inc(DisasmData.Address, DisasmData.OpcodeSize + DisasmData.PrefixSize);
          inc(needee, DisasmData.OpcodeSize + DisasmData.PrefixSize);



          if (needee >= NeedCodeSize) then
            break;
	  // Clear all information
          FlushDecoded(DisasmData);
          inc(index);
      end;

      CodeSize := needee;
      NopAlign := needee - NeedCodeSize;
end;

procedure RealignCallOffsets(StartPtr: Pointer; NeedCodeSize: Integer; NewAddress: Pointer);
var
   DisasmData: TDecoded;
   Index: DWORD;
   needee, new_offs, offs: integer;
begin
     if (@Decode = nil) then exit;
     DisasmData.Address := DWORD(StartPtr); // intial address
     FlushDecoded(DisasmData);     // clear the struct

     index := 0;
     needee := 0;

     while (index < BYTES_TO_DECODE) do
     begin
	  // Decode Instruction(s)
          Decode(@DisasmData, StartPtr, index);


          case PByte(DisasmData.Address)^ of
            $E8,
            $E9: begin
                      offs := Integer(DisasmData.Address) + PInteger(DisasmData.Address + 1)^ + 5;
                      new_offs := offs - (Integer(NewAddress) + (Integer(DisasmData.Address) - Integer(StartPtr)) + 5);
                      PInteger(DisasmData.Address + 1)^ := new_offs;
                      Log(LOG_LEVEL_DEBUG, 'HookEngine: Old offset = %X; New offset = %X', [offs, new_offs]);
                 end;
          end;

	  // Calculate total Size of an instruction + Prefixes, and
	  // Fix the address of eIP
          inc(DisasmData.Address, DisasmData.OpcodeSize + DisasmData.PrefixSize);
          inc(needee, DisasmData.OpcodeSize + DisasmData.PrefixSize);

          if (needee >= NeedCodeSize) then
            break;
	  // Clear all information
          FlushDecoded(DisasmData);
          inc(index);
      end;
end;


end.
