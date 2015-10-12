unit xml_helper;

interface
uses Windows;

procedure HandleError(ErrStr, ErrCaption: string);

implementation

procedure HandleError(ErrStr, ErrCaption: string);
begin
     MessageBox(GetDesktopWindow, PChar(ErrStr), PChar(ErrCaption), MB_OK);
     ExitProcess(0);
end;

end.
 