{

 $Id: DebugExcept.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

 $Log: DebugExcept.pas,v $
 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***

}
unit DebugExcept;

interface
uses Windows, SysUtils, {$IFDEF DEBUG}JclDebug, JclHookExcept, {$ENDIF} TypInfo;

procedure StartTracking;

implementation
uses loger, cfg;

procedure LogException(ExceptObj: TObject; ExceptAddr: Pointer; IsOS: Boolean);
var
  TmpS: string;
  ModInfo: TJclLocationInfo;
  I: Integer;
  ExceptionHandled: Boolean;
  HandlerLocation: Pointer;
  ExceptFrame: TJclExceptFrame;

begin
  TmpS := 'Exception ' + ExceptObj.ClassName;
  if ExceptObj is Exception then
    TmpS := TmpS + ': ' + Exception(ExceptObj).Message;
  if IsOS then
    TmpS := TmpS + ' (OS Exception)';
  Log(LOG_LEVEL_WARN, TmpS, []);
  ModInfo := GetLocationInfo(ExceptAddr);
  Log(LOG_LEVEL_WARN, '  Exception occured at $%p (Module "%s", Procedure "%s", Unit "%s", Line %d)',
    [ModInfo.Address,
     ModInfo.UnitName,
     ModInfo.ProcedureName,
     ModInfo.SourceName,
     ModInfo.LineNumber]);

  if stExceptFrame in JclStackTrackingOptions then
  begin
       Log(LOG_LEVEL_WARN, '  Except frame-dump:', []);
    I := 0;
    while {(chkShowAllFrames.Checked or (not ExceptionHandled) and}
      (I < JclLastExceptFrameList.Count) do
    begin
      ExceptFrame := JclLastExceptFrameList.Items[I];
      ExceptionHandled := ExceptFrame.HandlerInfo(ExceptObj, HandlerLocation);
      if (ExceptFrame.FrameKind = efkFinally) or
          (ExceptFrame.FrameKind = efkUnknown) or
          not ExceptionHandled then
        HandlerLocation := ExceptFrame.CodeLocation;
      ModInfo := GetLocationInfo(HandlerLocation);
      TmpS := Format(
        '    Frame at $%p (type: %s',
        [ExceptFrame.ExcFrame,
         GetEnumName(TypeInfo(TExceptFrameKind), Ord(ExceptFrame.FrameKind))]);
      if ExceptionHandled then
        TmpS := TmpS + ', handles exception)'
      else
        TmpS := TmpS + ')';
      Log(LOG_LEVEL_WARN, TmpS, []);
      if ExceptionHandled then
        Log(LOG_LEVEL_WARN, '      Handler at $%p', [HandlerLocation])
      else
        Log(LOG_LEVEL_WARN, '      Code at $%p', [HandlerLocation]);
      Log(LOG_LEVEL_WARN, '      Module "%s", Procedure "%s", Unit "%s", Line %d',
        [ModInfo.UnitName,
         ModInfo.ProcedureName,
         ModInfo.SourceName,
         ModInfo.LineNumber]);
      Inc(I);
    end;
  end;
  Log(LOG_LEVEL_WARN, ' ------------------------- ', []);
end;


procedure StartTracking;
begin
     JclStackTrackingOptions := JclStackTrackingOptions + [stExceptFrame, stStack];
     JclStartExceptionTracking;
     JclAddExceptNotifier(LogException);
end;


end.
