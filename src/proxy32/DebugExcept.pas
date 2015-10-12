{

 $Id: DebugExcept.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

 $Log: DebugExcept.pas,v $
 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}

{$DEFINE HOOK_DLL_EXCEPTIONS}
unit DebugExcept;

interface
uses Windows, SysUtils, JclDebug, JclHookExcept, TypInfo;

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
  TmpS := Format('<exception class="%s">', [ExceptObj.ClassName]);
  Log(LOG_LEVEL_WARN, TmpS, []);

  if ExceptObj is Exception then
  begin
       TmpS := '    <message>' + Exception(ExceptObj).Message + '</message>';
       Log(LOG_LEVEL_WARN, TmpS, []);
  end;

  if IsOS then
  begin
       TmpS := '    <isos>(OS Exception)</isos>';
       Log(LOG_LEVEL_WARN, TmpS, []);
  end;


  ModInfo := GetLocationInfo(ExceptAddr);
  Log(LOG_LEVEL_WARN, '    <location address="%p" module="%s" procedure="%s" unit="%s" line="%d"/>',
    [ModInfo.Address,
     ModInfo.UnitName,
     ModInfo.ProcedureName,
     ModInfo.SourceName,
     ModInfo.LineNumber]);

  if stExceptFrame in JclStackTrackingOptions then
  begin
       Log(LOG_LEVEL_WARN, '    <stack>', []);
       I := 0;
       while (I < JclLastExceptFrameList.Count) do
       begin
            ExceptFrame := JclLastExceptFrameList.Items[I];
            ExceptionHandled := ExceptFrame.HandlerInfo(ExceptObj, HandlerLocation);
            if (ExceptFrame.FrameKind = efkFinally) or (ExceptFrame.FrameKind = efkUnknown) or
                 not ExceptionHandled then
              HandlerLocation := ExceptFrame.CodeLocation;
            ModInfo := GetLocationInfo(HandlerLocation);
            TmpS := Format('frame_address="%p" type="%s"', [ExceptFrame.ExcFrame,
               GetEnumName(TypeInfo(TExceptFrameKind),
               Ord(ExceptFrame.FrameKind))]);

            if ExceptionHandled then
              TmpS := TmpS + ' handler="yes"'
            else
              TmpS := TmpS + ' handler="no"';

            Log(LOG_LEVEL_WARN, '      <location address="%p" %s module="%s" procedure="%s" unit="%s" line="%d"/>',
              [HandlerLocation, TmpS, ModInfo.UnitName, ModInfo.ProcedureName, ModInfo.SourceName, ModInfo.LineNumber]);
          Inc(I);
       end;
  Log(LOG_LEVEL_WARN, '   </stack>', []);
  end;
  Log(LOG_LEVEL_WARN, '</exception>', []);
end;


procedure StartTracking;
begin
     JclStackTrackingOptions := JclStackTrackingOptions + [stExceptFrame, stStack];
     JclStartExceptionTracking;

     JclAddExceptNotifier(LogException);
end;


end.
