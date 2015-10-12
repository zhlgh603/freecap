{*
 * Memory leak detector for Virtual Pascal and Delphi.
 *
 * (c) 1998 Joerg Pleumann <pleumann@uni-duisburg.de>
 *
 * Last changed 30-May-98, comments appreciated.
 *
 * Added location info 15-Jan-98,
 * Antony T Curtis <antony.curtis@olcs.net>
 * 1999.01.15 * Veit Kannegieser * more portable
 * 1998.01.15 * Veit Kannegieser * get caller of GetMem/ReAllocMem
 * 2002.01.25 * Veit Kannegieser * do not display garbage for no location info
 *
 * This unit implements and installs a new memory manager
 * that calls the GetMem / FreeMem / ReallocMem functions
 * of the original one (see TMemoryManager in System unit),
 * but performs some additional heap checking: All memory
 * allocations are stored in a list and removed when a
 * corresponding deallocation occurs. If, at program exit,
 * this list is non-empty, the program does two things:
 *
 * (1) It produces three beeps to inform the user or
 *     the developer about memory leaks.
 *
 * (2) It writes a dump of all leaks and their contents
 *     to a file "MemLeaks.dmp" in the current directory.
 *     The contents of a memory leak usually give you a
 *     good hint where to look for the leak. The unit
 *     also tries to categorize each memory leak by
 *     looking at its contents. Normally, AnsiStrings
 *     and class instances (new object model) are
 *     detected properly.
 *
 * Leak detection is only active when ExitCode (see System
 * unit) is zero, which indicates normal program termination.
 * A non-zero ExitCode usually means abnormal termination due
 * to an error. It makes no sense to dump the heap in that
 * case, since the application usually doesn't get any chance
 * to clean up the heap if a run-time error occurs.
 *
 * How to use the unit? Quite easy: Simply add it to the
 * "uses" list of your main executable, preferably as last
 * entry. That's it. Note that your program will run a
 * little slower with leak detection included, so you might
 * want to use this unit only while developing / debugging.
 *
 * Have fun!

 $Id: memleaks.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

 $Log: memleaks.pas,v $
 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}

unit MemLeaks;

{$X+} (* uses "Result" keyword *)

interface

uses
  SysUtils, Classes{$IFDEF DEBUG}, JclDebug{$ENDIF};

  procedure Init();
  function GetMemAllocated(): Integer;

implementation
uses
    Windows, loger, cfg;

(**
 * Forwards for the three functions implementing
 * the new memory manager.
 *)

function NewGetMem(Size: LongInt): Pointer; forward;
function NewFreeMem(P: Pointer): LongInt; forward;
function NewReallocMem(P: Pointer; Size: LongInt): Pointer; forward;


const

  (**
   * Growth of memory block list.
   *)

  MemBlockDelta = 1024;

  (**
   * The new memory manager. The three functions
   * variables point to the new memory management
   * functions.
   *)

  NewMemoryManager: TMemoryManager =
  ( GetMem:     NewGetMem;
    FreeMem:    NewFreeMem;
    ReAllocMem: NewReAllocMem );

type

  (**
   * An entry of the memory block list.
   *)

  PMemBlock = ^TMemBlock;
  TMemBlock = record
    FAddress: Pointer;
    FSize:    LongInt;
    FCaller:  Pointer;  (* ATC -- Stores the caller's address *)
    FThread:  LongInt;  (* ATC -- Stores the caller's thread  *)
    StackTrace: array[0..255] of DWORD;
  end;

  (*
   * The list of memory blocks.
   *)

  PMemBlockList = ^TMemBlockList;
  TMemBlockList = array[0..MaxInt div SizeOf(TMemBlock) - 1] of TMemBlock;

var

  (**
   * Points to the list of currently
   * allocated memory blocks. *)

  MemBlockList:  PMemBlockList = nil;

  (**
   * Holds the number of currently
   * allocated memory blocks.
   *)

  MemBlockCount: LongInt = 0;

  (**
   * Holds the current size of the
   * memory block list.
   *)

  MemBlockLimit: LongInt = 0;

  (**
   * Holds the total amount of memory
   * allocated by the program, not
   * counting the overhead needed for
   * heap management.
   *)

  MemBlockTotal: LongInt = 0;

  (**
   * Holds the memory manager that was
   * active before the memory leak
   * detector.
   *)

  OldMemoryManager: TMemoryManager;

(**
 * ATC -- Finds out the address of the caller
 * with a quick walk through the stack
 *)

function CallerAddr2org(): Pointer; assembler;
asm
   mov    EAX, [EBP]
   mov    EAX, [EAX + 4]
   sub    EAX, 5
end;

function CallerAddr2:Pointer;
asm
   mov   EAX,[EBP + 4]
   SUB   EAX, 5
end;

(**
 * Adds a block to the list of currrently
 * allocated memory blocks.
 *)
function GetStackLine(Addr: Pointer): string;
var
   Info: TJclLocationInfo;
begin
     if GetLocationInfo(Addr, Info) then
        Result := Format(#9'%s::%s at line %d'#13#10,[Info.UnitName, Info.ProcedureName, Info.LineNumber])
     else
        Result := Format(#9'%p'#13#10,[Addr]);

end;

procedure DumpStack(stack: PDWORDArray; var s: string);
var
   i: integer;
begin
     s := '';
     i := 0;
     while stack^[i] <> $FFFFFFFF do
     begin
          s := s + GetStackLine(Pointer(stack^[i]));
          inc(i);
     end;
end;



procedure AddBlock(Address: Pointer; Size: LongInt; Caller: Pointer);
begin
  if Address <> nil then
  begin
    if MemBlockCount = MemBlockLimit then
    begin
      MemBlockList := OldMemoryManager.ReAllocMem(MemBlockList,
        (MemBlockLimit + MemBlockDelta) * SizeOf(TMemBlock));

      Inc(MemBlockLimit, MemBlockDelta);
    end;

    SetMemoryManager(OldMemoryManager);

    with MemBlockList^[MemBlockCount] do
    begin
      FAddress := Address;
      FSize := Size;
      FCaller := Caller;
      FThread := GetCurrentThreadID;

      with TJclStackInfoList.Create(False, 0, nil) do
      begin
         try
            GetStackTrace(@StackTrace, False, True, True);
         finally
            Free;
         end;
      end;
{      s := #13#10;
      DumpStack(@StackTrace, s);
      Log(LOG_LEVEL_MEM, '[%d] alloc: ', [MemBlockCount]);
}
    end;
    SetMemoryManager(NewMemoryManager);

    Inc(MemBlockCount);
    Inc(MemBlockTotal, Size);
  end;
end;

(**
 * Deletes a block from the list of currrently
 * allocated memory blocks.
 *)

procedure DeleteBlock(Address: Pointer);
var
  I: LongInt;
begin
  if Address <> nil then
  begin
    I := MemBlockCount - 1;

    while (I <> -1) and (MemBlockList^[I].FAddress <> Address) do
      Dec(I);

    if I <> - 1 then
    begin
      Dec(MemBlockCount);
      Dec(MemBlockTotal, MemBlockList^[I].FSize);

      Move(MemBlockList^[I + 1], MemBlockList^[I],
        (MemBlockCount - I) * SizeOf(TMemBlock));
      {
      SetMemoryManager(OldMemoryManager);
      with MemBlockList^[I] do
      begin
           Log(LOG_LEVEL_MEM, '[%d] free', [MemBlockCount]);
      end;
      SetMemoryManager(NewMemoryManager);
      }
    end;
  end;
end;

(**
 * Tries to classify the memory block. This is more or
 * less a guess, but works most of the time. :-) The
 * function is able to detect AnsiStrings and object
 * instances (new object model only). Everything else
 * is returned as 'Unknown'.
 *)

function MemClassify(Address: Pointer; Size: LongInt): string;
type
  TStrRec = record
    RefCnt: LongInt;
    Length: LongInt;
    Data:   array[0 .. 0] of Char;
  end;
var
  AString: ^TStrRec absolute Address;
  AObject: TObject absolute Address;
begin
  if Size > 8 then
    with AString^ do
    begin
      if (Length + 9 = Size) and (Data[Length] = #0) then
      begin
        Result := 'AnsiString (Length=' + IntToStr(Length)
                + ', RefCnt=' + IntToStr(RefCnt) + ')';
        Exit;
      end;
    end;

  try
    if AObject.InstanceSize = Size then
    begin
      Result := TObject(Address).ClassName;
      Exit;
    end;
  except
  end;

  Result := 'Unknown';
end;

(**
 * Dumps a given block of memory to a string.
 *)

function MemToHexAsc(Address: PChar; Length: Integer): string;
var
  I: Integer;
begin
  Result := '';

  for I := 0 to Length - 1 do
    Result := Result + IntToHex(Byte(Address[I]), 2) + ' ';

  for I := Length to 15 do
    Result := Result + '   ';

  Result := Result + '   ';

  for I := 0 to Length - 1 do
  begin
    if Address[I] >= ' ' then
      Result := Result + Address[I]
    else
      Result := Result + '.';
  end;
end;

function CallerInfo(Caller: Pointer; Thread:LongInt): string;
var
   Info: TJclLocationInfo;
begin
     if GetLocationInfo(Caller, Info) then
        Result := Format('(%s) %s line %d (thread %d)',[Info.UnitName, Info.ProcedureName, Info.LineNumber, Thread])
     else
        Result := Format('unknown: %p (thread %d)',[Caller, Thread]);

end;

(**
 * Produces a HEX- / ASCII dump of the memory block
 * list into a file called "MemLeaks.dmp".
 *)


procedure DumpHeap;
var
  F: File of byte;
  I, L: LongInt;
  P: PChar;
  s: string;

  procedure PutStr(s: string);
  begin
       s := s + #13#10;
       BlockWrite(F, s[1], Length(s));
  end;

begin
  AssignFile(F, 'C:\MemLeaks.dmp');
  Rewrite(F);

  PutStr('; Dump of memory leak detector.');
  PutStr(';');
  PutStr('; Executable file  : ' + ParamStr(0));
  PutStr('; Date and time    : ' + FormatDateTime('yyyy"/"mm"/"dd hh":"nn":"ss', Now));
  PutStr('; Number of leaks  : ' + IntToStr(MemBlockCount));
  PutStr('; Total memory loss: ' + IntToStr(MemBlockTotal) + ' bytes (without overhead)');
  PutStr(';');
  PutStr('; Leaks are listed in order of allocation.');
  PutStr('');

  for I := 0 to MemBlockCount - 1 do
  begin
    with MemBlockList^[I] do
    begin
      P := FAddress;
      L := FSize;
      PutStr('==================================================================');
      PutStr('Address : ' + IntToHex(LongInt(P), 8));
      PutStr('Size    : ' + IntToHex(L, 8) + ' (' + IntToStr(L) + ' bytes)');
      PutStr('Caller  : ' + CallerInfo(FCaller, FThread));
      PutStr('Type    : ' + MemClassify(FAddress, FSize));
      PutStr('Stack trace: ');
      PutStr('----------------------------------------');

      DumpStack(@StackTrace, s);
      PutStr(s);
      PutStr('----------------------------------------');

      PutStr ('Contents: ');

      while L > 16 do
      begin
        PutStr(MemToHexAsc(P, 16));
        PutStr('          ');
        Inc(P, 16);
        Dec(L, 16);
      end;

      PutStr(MemToHexAsc(P, L));
      PutStr('==================================================================');
      PutStr('');
    end;
  end;

  PutStr('; End of file.');

  CloseFile(F);
end;

(**
 * Implements the GetMem function of the new memory
 * manager. Simply calls the original memory manager
 * and then then adds the new block to the list.
 *)

function NewGetMem(Size: LongInt): Pointer;
begin
  Result := OldMemoryManager.GetMem(Size);
  AddBlock(Result, Size, CallerAddr2);
end;

(**
 * Implements the FreeMem function of the new memory
 * manager. Simply removes the block from the list
 * and then calls the original memory manager.
 *)

function NewFreeMem(P: Pointer): Longint;
begin
  DeleteBlock(P);
  Result := OldMemoryManager.FreeMem(P);
end;

(**
 * Implements the ReallocMem function of the new memory
 * manager. Removes the old block from the list, calls
 * the original memory manager and adds the new block to
 * the list.
 *)

function NewReallocMem(P: Pointer; Size: LongInt): Pointer;
begin
  DeleteBlock(P);
  Result := OldMemoryManager.ReAllocMem(P, Size);
  AddBlock(Result, Size, CallerAddr2);
end;

(**
 * The initialization part reserves some initial space for
 * the memory block list and installs the new memory
 * manager.
 *)


procedure Init();
begin
  GetMem(MemBlockList, MemBlockDelta * SizeOf(TMemBlock));

  GetMemoryManager(OldMemoryManager);
  SetMemoryManager(NewMemoryManager);

end;

function GetMemAllocated(): Integer;
begin
     result := MemBlockTotal;
end;


initialization

finalization
begin
  SetMemoryManager(OldMemoryManager);

  if (ExitCode = 0) and (MemBlockCount <> 0) then
  begin
    MessageBeep($FFFFFFFF);
    MessageBeep($FFFFFFFF);
    MessageBeep($FFFFFFFF);
    DumpHeap;
  end;

  FreeMem(MemBlockList);
end;



end.

