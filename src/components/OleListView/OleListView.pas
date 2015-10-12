{*
 * File: ......................... OleListView.pas
 * Autor: ........................ Max Artemev (Bert Raccoon),
 * Copyright: .................... (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc:
 *   TListView with OLE drag'n'drop capability. (Drops to anything controls that from M$ ;))
 *}
unit OleListView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComObj, ComCtrls, OleCtnrs, ShlObj,  ActiveX;

const
     // Drop effects as Delphi style constants
     deNone   = DROPEFFECT_NONE;
     deMove   = DROPEFFECT_MOVE;
     deCopy   = DROPEFFECT_COPY;
     deLink   = DROPEFFECT_LINK;
     deScroll = DROPEFFECT_SCROLL;

     DVASPECT_LINK = 4;
type
  TOnDragEvent = procedure (Sender : TObject; DataObject : IDataObject; State : TShiftState; MousePt : TPoint; var Effect, Result : integer) of Object;
  TOnDragLeaveEvent = procedure (Sender : TObject; var Result : integer) of Object;
  TOnShellLinkCreateEvent = procedure (Sender : TObject; var DestFileName, WorkDir, Args, IconFile, Desc: string) of object;

  PFormatList = ^TFormatList;
  TFormatList = array[0..1] of TFormatEtc;

  // IEnumFormatEtc -- realization of IEnumFormatEtc interface
  TEnumFormatEtc = class (TInterfacedObject, IEnumFormatEtc)
  private
    FFormatList: PFormatList;
    FFormatCount: Integer;
    FIndex: Integer;
  public
    constructor Create(FormatList: PFormatList; FormatCount, Index: Integer);
    function Next (celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Skip (celt: Longint) : HResult; stdcall;
    function Reset : HResult; stdcall;
    function Clone (out enum : IEnumFormatEtc): HResult; stdcall;
  end;

  // TFileDropSource -- realization of IDropSource interface for objects
  // that will be dragged to another place 
  TFileDropSource = class (TInterfacedObject, IDropSource)
  public
    constructor Create; virtual;
    function QueryContinueDrag (fEscapePressed: BOOL; grfKeyState: Longint): HResult; stdcall;
    function GiveFeedback(dwEffect: Longint): HResult; stdcall;
  end;

  TDragDropInfo = class (TObject)
  private
    FInClientArea : Boolean;
    FDropPoint : TPoint;
    FFileList : TStringList;
  public
    constructor Create (ADropPoint : TPoint; AInClient : Boolean);
    destructor Destroy; override;
    procedure Add (const s : String);
    function CreateHDrop: HGlobal;
    property InClientArea : Boolean read FInClientArea;
    property DropPoint : TPoint read FDropPoint;
    property Files : TStringList read FFileList;
  end;


  { THDropDataObject - realization if IDataObject for our ListView }
  THDropDataObject = class(TInterfacedObject, IDataObject)
  private
    FDropInfo : TDragDropInfo;
  public
    constructor Create(ADropPoint : TPoint; AInClient : Boolean);
    destructor Destroy; override;
    procedure Add (const s : String);
    { из IDataObject }
    function GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium): HResult; stdcall;
    function GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium): HResult; stdcall;
    function QueryGetData(const formatetc: TFormatEtc): HResult; stdcall;
    function GetCanonicalFormatEtc(const formatetc: TFormatEtc; out formatetcOut: TFormatEtc): HResult; stdcall;
    function SetData(const formatetc: TFormatEtc; var medium: TStgMedium; fRelease: BOOL): HResult; stdcall;
    function EnumFormatEtc(dwDirection: Longint; out enumFormatEtc: IEnumFormatEtc): HResult; stdcall;
    function DAdvise(const formatetc: TFormatEtc; advf: Longint; const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
    function DUnadvise(dwConnection: Longint): HResult; stdcall;
    function EnumDAdvise(out enumAdvise: IEnumStatData): HResult; stdcall;
  end;


  TOLEListView = class(TListView, IDropSource, IDropTarget)
    {Realization of IDropSource}
    function QueryContinueDrag(fEscapePressed: BOOL;
      grfKeyState: Longint): HResult; stdcall;
    function GiveFeedback(dwEffect: Longint): HResult; stdcall;

    {Realization of IDropTarget}
    function DragEnter (const DataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function DragOver (grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function DragLeave : HResult; stdcall;
    function Drop (const DataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;

  private
    FOnDragEnter : TOnDragEvent;
    FOnDragOver : TOnDragEvent;
    FOnDragLeave : TOnDragLeaveEvent;
    FOnDrop : TOnDragEvent;
    FDataObject: IDataObject;
    FOnShellLinkCreate: TOnShellLinkCreateEvent;
    function StandardEffect (Keys : TShiftState) : integer;
  protected
    procedure CreateWnd; override;

    procedure DoDragEnter (DataObject : IDataObject; State : TShiftState; Pt : TPoint; var Effect, Result : integer); virtual;
    procedure DoDragOver (DataObject : IDataObject; State : TShiftState; Pt : TPoint; var Effect, Result : integer); virtual;
    procedure DoDragLeave (var Result : integer); virtual;
    procedure DoDrop (DataObject : IDataObject; State : TShiftState; Pt : TPoint; var Effect, Result : integer); virtual;

    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    function CreateShellDataObject(DestFileName, WorkDir, Args, IconFile, Desc: string): string;

  published
    property OnDragEnter : TOnDragEvent read FOnDragEnter write FOnDragEnter;
    property OnDragOver : TOnDragEvent read FOnDragOver write FOnDragOver;
    property OnDragLeave : TOnDragLeaveEvent read FOnDragLeave write FOnDragLeave;
    property OnDrop : TOnDragEvent read FOnDrop write FOnDrop;
    property OnShellLinkCreate: TOnShellLinkCreateEvent read FOnShellLinkCreate write FOnShellLinkCreate;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TOLEListView]);
end;


procedure TOLEListView.CreateWnd;
begin
     inherited CreateWnd;
     RegisterDragDrop(Handle, Self);
end;


procedure TOLEListView.DoDragEnter(DataObject: IDataObject;
  State: TShiftState; Pt: TPoint; var Effect, Result: integer);
begin
  Effect := StandardEffect (State);
  if Assigned (FOnDragEnter) then
    FOnDragEnter (Self, DataObject, State, Pt, Effect, Result)
end;

procedure TOLEListView.DoDragLeave(var Result: integer);
begin
  if Assigned (FOnDragLeave) then
    FOnDragLeave (Self, Result)
end;

procedure TOLEListView.DoDragOver(DataObject: IDataObject;
  State: TShiftState; Pt: TPoint; var Effect, Result: integer);
begin
     Effect := StandardEffect (State);
     if Assigned (FOnDragOver) then
       FOnDragOver (Self, DataObject, State, Pt, Effect, Result)

end;


procedure TOLEListView.DoDrop(DataObject: IDataObject; State: TShiftState;
  Pt: TPoint; var Effect, Result: integer);
begin
     Effect := StandardEffect (State);
     if Assigned (FOnDrop) then
       FOnDrop (Self, DataObject, State, Pt, Effect, Result);
end;



function TOLEListView.DragEnter(const DataObj: IDataObject;
  grfKeyState: Integer; pt: TPoint; var dwEffect: Integer): HResult;
begin
     dwEffect := DROPEFFECT_NONE;
     Result := NOERROR;
     FDataObject := DataObj;
     DoDragEnter (DataObj, KeysToShiftState (grfKeyState), Pt, dwEffect, integer(Result))
end;

function TOLEListView.DragLeave: HResult;
begin
     Result := NOERROR;
     DoDragLeave (integer(Result))
end;

function TOLEListView.DragOver(grfKeyState: Integer; pt: TPoint;
  var dwEffect: Integer): HResult;
begin
     dwEffect := DROPEFFECT_NONE;
     Result := NOERROR;
     DoDragOver (FDataObject, KeysToShiftState (grfKeyState), Pt, dwEffect, integer(Result))
end;

function TOLEListView.Drop(const DataObj: IDataObject;
  grfKeyState: Integer; pt: TPoint; var dwEffect: Integer): HResult;
begin
  dwEffect := DROPEFFECT_NONE;
  Result := NOERROR;
  DoDrop (DataObj, KeysToShiftState (grfKeyState), Pt, dwEffect, integer(Result))
end;



function TOLEListView.GiveFeedback(dwEffect: Integer): HResult;
begin
  Result := NOERROR;
end;


function TOLEListView.QueryContinueDrag(fEscapePressed: BOOL;
  grfKeyState: Integer): HResult;
begin
  Result := NOERROR;
end;



function TOLEListView.StandardEffect (Keys : TShiftState) : integer;
begin
  Result := deMove;
  if ssCtrl in Keys then
  begin
    Result := deCopy;
    if ssShift in Keys then
      Result := deLink
  end
end;



{ TDragDropInfo }

constructor TDragDropInfo.Create(ADropPoint : TPoint; AInClient : Boolean);
begin
     inherited Create;
     FFileList := TStringList.Create;
     FDropPoint := ADropPoint;
     FInClientArea := AInClient;
end;

destructor TDragDropInfo.Destroy;
begin
     FFileList.Free;
     inherited Destroy;
end;

procedure TDragDropInfo.Add(const s : String);
begin
     Files.Add (s);
end;


function TDragDropInfo.CreateHDrop : HGlobal;
var
  RequiredSize : Integer;
  i : Integer;
  hGlobalDropInfo : HGlobal;
  DropFiles : PDropFiles;
  c : PChar;
begin
     // We need to allocate TDropFiles structure in the shared mem,
     // because it should be available to other processes

     RequiredSize := sizeof (TDropFiles);
     for i := 0 to Self.Files.Count-1 do
     begin
          // Length of each string + 1 byte (C-string)
          RequiredSize := RequiredSize + Length (Self.Files[i]) + 1;
     end;
     // and plus 1 byte for final terminator
     inc (RequiredSize);

     // Allocate piece of shared memory
     hGlobalDropInfo := GlobalAlloc ((GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT), RequiredSize);
     if (hGlobalDropInfo <> 0) then
     begin
          // Lock memory, so we can access
          DropFiles := GlobalLock (hGlobalDropInfo);

          // Fill fields
          DropFiles.pFiles := sizeof (TDropFiles); // offset to first byte of the filenames array in the TDropFiles struct
          DropFiles.pt := Self.FDropPoint;
          DropFiles.fNC := Self.InClientArea;
          DropFiles.fWide := False;

          // Copy filenames to buffer. Buffer is allocated at bottom of the TDropFiles struct
          c := PChar (DropFiles);
          c := c + DropFiles.pFiles;
          for i := 0 to Self.Files.Count-1 do
          begin
               StrCopy (c, PChar (Self.Files[i]));
               c := c + Length (Self.Files[i]);
          end;

          // ..and unlock it
          GlobalUnlock (hGlobalDropInfo);
     end;

     // Result is pointer to our block.
     // Caller should take care about freeing that block.
     Result := hGlobalDropInfo;
end;


{ TEnumFormatEtc }

constructor TEnumFormatEtc.Create(FormatList: PFormatList; FormatCount, Index : Integer);
begin
     inherited Create;
     FFormatList := FormatList;
     FFormatCount := FormatCount;
     FIndex := Index;
end;

function TEnumFormatEtc.Next(celt: Longint; out elt; pceltFetched: PLongint): HResult;
var
   i : Integer;
   eltout: TFormatList absolute elt;
begin
     i := 0;

     while (i < celt) and (FIndex < FFormatCount) do
     begin
          eltout[i] := FFormatList[FIndex];
          Inc (FIndex);
          Inc (i);
     end;

     if (pceltFetched <> nil) then
       pceltFetched^ := i;

     if (I = celt) then
       Result := S_OK
     else
       Result := S_FALSE;
end;

{*  Skip() skips "celt" list elements and sets current position to (CurrentPointer + celt)
 *  or to list tail
 *}
function TEnumFormatEtc.Skip(celt: Longint): HResult;
begin
     if (celt <= FFormatCount - FIndex) then
     begin
          FIndex := FIndex + celt;
          Result := S_OK;
     end
     else
     begin
          FIndex := FFormatCount;
          Result := S_FALSE;
     end;
end;

// Reset() sets current pointer to head of list
function TEnumFormatEtc.Reset: HResult;
begin
     FIndex := 0;
     Result := S_OK;
end;

// Clone() just copy list of structs
function TEnumFormatEtc.Clone (out enum: IEnumFormatEtc): HResult;
begin
     enum := TEnumFormatEtc.Create (FFormatList, FFormatCount, FIndex);
     Result := S_OK;
end;


{ TFileDropSource }
constructor TFileDropSource.Create;
begin
     inherited Create;
     _AddRef;
end;


//  QueryContinueDrag is defining nessesary actions for object that dragged from our ListView
function TFileDropSource.QueryContinueDrag (fEscapePressed: BOOL; grfKeyState: Longint): HResult;
begin
     if (fEscapePressed) then
     begin
          Result := DRAGDROP_S_CANCEL;
     end
     else if ((grfKeyState and MK_LBUTTON) = 0) then
     begin
          Result := DRAGDROP_S_DROP;
     end
     else
     begin
          Result := S_OK;
     end;
end;

function TFileDropSource.GiveFeedback (dwEffect: LongInt): HResult;
begin
     Result := DRAGDROP_S_USEDEFAULTCURSORS;
end;


{ THDropDataObject }
constructor THDropDataObject.Create (ADropPoint : TPoint; AInClient : Boolean);
begin
     inherited Create;
     FDropInfo := TDragDropInfo.Create (ADropPoint, AInClient);
end;

destructor THDropDataObject.Destroy;
begin
     if (FDropInfo <> nil) then
       FDropInfo.Free;
     inherited Destroy;
end;

procedure THDropDataObject.Add (const s : String);
begin
     FDropInfo.Add (s);
end;

function THDropDataObject.GetData (const formatetcIn: TFormatEtc;
  out medium: TStgMedium): HResult;
begin
     Result := DV_E_FORMATETC;
     ZeroMemory(@medium, SizeOf(medium));

     { If format is supported -- create object and return}
     if (QueryGetData (formatetcIn) = S_OK) then
     begin
          if (FDropInfo <> nil) then
          begin
               medium.tymed := TYMED_HGLOBAL;
               medium.hGlobal := FDropInfo.CreateHDrop;
               Result := S_OK;
          end;
     end;
end;

function THDropDataObject.GetDataHere (const formatetc: TFormatEtc;
  out medium: TStgMedium): HResult;
begin
     Result := DV_E_FORMATETC;
end;

function THDropDataObject.QueryGetData(const formatetc: TFormatEtc): HResult;
begin
     Result := DV_E_FORMATETC;
     with formatetc do
       if dwAspect = DVASPECT_CONTENT then
         if (cfFormat = CF_HDROP) and (tymed = TYMED_HGLOBAL) then
         begin
              Result := S_OK;
         end;
end;

function THDropDataObject.GetCanonicalFormatEtc (const formatetc: TFormatEtc;
  out formatetcOut: TFormatEtc): HResult;
begin
     formatetcOut.ptd := nil;
     Result := E_NOTIMPL;
end;

function THDropDataObject.SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
    fRelease: BOOL): HResult;
begin
     Result := E_NOTIMPL;
end;

{ EnumFormatEtc returns list of supported formats }
function THDropDataObject.EnumFormatEtc(dwDirection: Longint;
  out enumFormatEtc: IEnumFormatEtc): HResult;
const
  DataFormats: array [0..0] of TFormatEtc = (
    (cfFormat: CF_HDROP; ptd: nil; dwAspect: DVASPECT_CONTENT; lindex: -1; tymed: TYMED_HGLOBAL)
  );
  DataFormatCount = 1;
begin
  if dwDirection = DATADIR_GET then
  begin
    enumFormatEtc := TEnumFormatEtc.Create(@DataFormats, DataFormatCount, 0);
    Result := S_OK;
  end
  else
  begin
       enumFormatEtc := nil;
       Result := E_NOTIMPL;
  end;
end;

function THDropDataObject.DAdvise (const formatetc: TFormatEtc; advf: Longint;
   const advSink: IAdviseSink; out dwConnection: Longint): HResult;
begin
     Result := OLE_E_ADVISENOTSUPPORTED;
end;

function THDropDataObject.DUnadvise(dwConnection: Longint): HResult;
begin
     Result := OLE_E_ADVISENOTSUPPORTED;
end;

function THDropDataObject.EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
begin
     Result := OLE_E_ADVISENOTSUPPORTED;
end;


function TOLEListView.CreateShellDataObject(DestFileName, WorkDir, Args, IconFile, Desc: string): string;
var
  IObject    : IUnknown;
  ISLink     : IShellLink;
  IPFile     : IPersistFile;
  InFolder   : array[0..MAX_PATH] of Char;
  destName   : WideString;
  DN         : string;
begin
  IObject := CreateComObject(CLSID_ShellLink);
  ISLink := IObject as IShellLink;
  IPFile  := IObject as IPersistFile;

  with ISLink do
  begin
       SetPath(pChar(DestFileName));
       SetWorkingDirectory (pChar(WorkDir));
       SetArguments(PChar(Args));
       SetIconLocation(PChar(IconFile), 0);
       SetDescription(PChar(Desc));
  end;

  if ExpandEnvironmentStrings('%TEMP%', @InFolder[0], SizeOf(InFolder)) <> 0 then
  begin
       if Desc <> '' then
         destName := WideString(string(InFolder) + '\' + Desc + '.lnk')
       else
         destName := WideString(string(InFolder) + '\' + ExtractFileName(DestFileName) + '.lnk');

       IPFile.Save(PWideChar(destName), False);
  end;
  result := AnsiString(destName);
end;

procedure TOLEListView.WMLButtonDown(var Message: TWMLButtonDown);
var
   dwEffect : integer;
   rslt: HRESULT;
   DropSource: TFileDropSource;
   DataObject: THDropDataObject;
   pt: TPoint;
   DestFileName, WorkDir, Args, IconFile, Desc, destLnk: string;
begin
     inherited;
     if (Selected = nil) or not Assigned(FOnShellLinkCreate) then exit;
     FOnShellLinkCreate(Self, DestFileName, WorkDir, Args, IconFile, Desc);
     if DestFileName = '' then exit;

     DropSource := TFileDropSource.Create();

     pt.x := 0;
     pt.y := 0;

     destLnk := CreateShellDataObject(DestFileName, WorkDir, Args, IconFile, Desc);
     DataObject := THDropDataObject.Create(pt, True);
     DataObject.Add(destLnk);


     rslt := DoDragDrop(DataObject, DropSource, DROPEFFECT_COPY, dwEffect);
     if (rslt = DRAGDROP_S_CANCEL) or (rslt = DRAGDROP_S_DROP) then
       DeleteFile(destLnk);

     DropSource := nil;
     DataObject := nil;
end;

end.
