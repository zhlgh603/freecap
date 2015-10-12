{*
 * File: ...................... SharedDispatch.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Shared memory dispatcher (win9x only)

 $Id: SharedDispatch.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

 $Log: SharedDispatch.pas,v $
 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit SharedDispatch;

interface
uses Windows, Classes, SysUtils, loger, misc, cfg;

type
    PFuncItem = ^TFuncItem;
    TFuncItem = packed record
      fnDest,          // Destination address (in IAT)
      fnOrig,          // Original function entry point
      fnNew : Pointer; // New entry point
    end;

    TFuncList = class
    private
      FList: TList;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Add(fnDest, fnOrig, fnNew: Pointer);
      function Exists(fnOrig: Pointer): Boolean;
      function GetAssociatedAddress(fnOrig: Pointer): Pointer;
      function GetNewAddr(pOrig: Pointer): Pointer;
      procedure Restore();
    end;

implementation
uses hook, hook_func, win9x;

{ TFuncList }

procedure TFuncList.Add(fnDest, fnOrig, fnNew: Pointer);
var
   FuncItem: PFuncItem;
begin
     if not Exists(fnOrig) then
     begin
          GetMem(FuncItem, SizeOf(TFuncItem));
          FuncItem^.fnDest := fnDest;
          FuncItem^.fnOrig := fnOrig;
          FuncItem^.fnNew := fnNew;
          FList.Add(FuncItem);
     end;
end;

constructor TFuncList.Create;
begin
     FList := TList.Create;
end;

destructor TFuncList.Destroy;
var
   i: integer;
   FuncItem : PFuncItem;
begin
     Restore();
     for i := FList.Count - 1 downto 0 do
     begin
          FuncItem := FList[i];
          FreeMem(FuncItem);
          FList.Delete(i);
     end;
     FList.Free;
     inherited;
end;

function TFuncList.Exists(fnOrig: Pointer): Boolean;
var
   i: integer;
   FuncItem: PFuncItem;
begin
     result := False;
     for i := 0 to FList.Count - 1 do
     begin
          FuncItem := FList[i];
          if FuncItem^.fnOrig = fnOrig then
          begin
               result := True;
               exit;
          end;
     end;
end;

function TFuncList.GetAssociatedAddress(fnOrig: Pointer): Pointer;
var
   i: integer;
   FuncItem: PFuncItem;
begin
     result := nil;
     for i := 0 to FList.Count - 1 do
     begin
          FuncItem := FList[i];
          if FuncItem^.fnOrig = fnOrig then
          begin
               result := FuncItem^.fnNew;
               exit;
          end;
     end;
end;

function TFuncList.GetNewAddr(pOrig: Pointer): Pointer;
var
   i: integer;
   FuncItem: PFuncItem;
begin
     result := nil;
     for i := 0 to FList.Count - 1 do
     begin
          FuncItem := FList[i];
          if FuncItem.fnOrig = pOrig then
          begin
               result := FuncItem.fnNew;
               exit;
          end;
     end;
end;

procedure TFuncList.Restore;
var
   i: integer;
begin
     if win9x.bDoNotRestore or (not isWin9x()) then exit;

     for i:=0 to High(MandatoryFunctions) do
     begin
          with MandatoryFunctions[i] do
          begin
               Log(LOG_LEVEL_INJ, '* Restore original entry point of function "%s"', [GetFuncByAddr(fnOrig)]);
               ReplaceIATEntryInAllMods(fnModule, GetNewAddr(fnOrig), fnOrig, False);
          end;
     end;

end;

end.
