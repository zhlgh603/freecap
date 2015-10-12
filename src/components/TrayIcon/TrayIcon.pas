{*
 * Filename  : TrayIcon.pas
 * Desc.     : Компонент трей-иконки
 * Date      : 22.01.2001
 * Time      : 14:10
 *}
unit TrayIcon;

interface

uses
    Windows, Messages, Classes, Graphics, Controls, SysUtils, ShellAPI;

const
     WM_TASKICON = WM_USER+666;

type
  String64 = String[64];
  TStateTaskIcon = (tiEnabled, tiDisabled, tiAnimated);
  TWhereTaskIcon = (tiInFiles, tiInExe);
  TTrayIcon = class(TWinControl)
  private
    {Field variables}
    tnid: TNOTIFYICONDATA;
    fEnabled: boolean;
    fIcon: TIcon;
    fDisabledIcon: TIcon;
    fAniIcon: TIcon;
    fTip: string64;
    fShowTip: boolean;
    fTaskIconID: UINT;
    fState: TStateTaskIcon;
    fIconList: TStrings;
    fInterval: UINT;
    fWhereIcons: TWhereTaskIcon;
    fOnDblClick: TNotifyEvent;
    fOnClick: TNotifyEvent;
    fOnMouseUp: TMouseEvent;
    fOnMouseDown: TMouseEvent;
    fOnAnimate: TNotifyEvent;
    fIconNum: integer;
    fTimerID: UINT;
    fUpdateTimerID: UINT;

    p: PChar;
    FAutoUpdate: Boolean;
    function MakeIcon(Sender: TObject) : boolean;
    function KillIcon(Sender: TObject) : boolean;
    function ChangeIcon(Sender: TObject) : boolean;
    procedure SetIcon(Value: TIcon);
    procedure SetDisabledIcon(Value: TIcon);
    procedure SetTip(Value: String64);
    procedure SetShowTip(Value: boolean);
    procedure SeTTrayIconID(Value: UINT);
    procedure SetState(Value: TStateTaskIcon);
    procedure SetIconList(Value: TStrings);
    procedure SetInterval(Value: UINT);
    procedure WMTASKICON(var msg: TMessage); message WM_TASKICON;
    procedure WMTIMER(var msg: TMessage); message WM_TIMER;
    procedure LoadTaskIcon;
  protected
    procedure SetEnabled(Value: boolean);override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    property AutoUpdate: Boolean read FAutoUpdate write FAutoUpdate;
    property Enabled: boolean read fEnabled write SetEnabled;
    property Icon: TIcon read fIcon write SetIcon;
    property DisabledIcon: TIcon read fDisabledIcon write SetDisabledIcon;
    property Tip: string64 read fTip write SetTip;
    property ShowTip: boolean read fShowTip write SetShowTip;
    property TaskIconID: UINT read fTaskIconID write SeTTrayIconID;
    property State: TStateTaskIcon read fState write SetState;
    property IconList: TStrings read fIconList write SetIconList;
    property Interval: UINT read fInterval write SetInterval;
    property WhereIcons: TWhereTaskIcon read fWhereIcons write fWhereIcons;
    property OnDblClick: TNotifyEvent read fOnDblClick write fOnDblClick;
    property OnClick: TNotifyEvent read fOnClick write fOnClick;
    property OnMouseUp: TMouseEvent  read fOnMouseUp write fOnMouseUp;
    property OnMouseDown: TMouseEvent  read fOnMouseDown write fOnMouseDown;
    property OnAnimate: TNotifyEvent  read fOnAnimate write fOnAnimate;
  end;

procedure Register;

implementation

procedure TTrayIcon.SetEnabled(Value: boolean);
begin
  if value<>fEnabled then
    begin
      if Value then
        begin
          if MakeIcon(self) then fEnabled:=true
        end
      else
        begin
          if KillIcon(self) then fEnabled:=false;
        end;
    end;
end;

procedure TTrayIcon.SetIcon(Value: TIcon);
begin
  if Value<>fIcon then
    begin
      fIcon.Assign(value);
      if fEnabled then ChangeIcon(Self);
    end;
end;

procedure TTrayIcon.SetDisabledIcon(Value: TIcon);
begin
  if Value<>fDisabledIcon then
    begin
      fDisabledIcon.Assign(value);
      if fEnabled then ChangeIcon(Self);
    end;
end;

procedure TTrayIcon.SeTTrayIconID(Value: UINT);
begin
  if Value<>fTaskIconID then
    begin
      fTaskIconID:=value;
      if fEnabled then ChangeIcon(Self);
    end;
end;

procedure TTrayIcon.SetTip(Value: string64);
begin
  if Value<>fTip then
    begin
      fTip:=value;
      if fEnabled then ChangeIcon(Self);
    end;
end;

procedure TTrayIcon.SetShowTip(Value: boolean);
begin
  if Value<>fShowTip then
    begin
      fShowTip:=value;
      if fEnabled then ChangeIcon(Self);
    end;
end;

constructor TTrayIcon.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FIcon:=TIcon.Create;
  FDisabledIcon:=TIcon.Create;
  FAniIcon:=TIcon.Create;
  fIconList:=TStringList.Create;
  fInterval:=1000;
  fTimerID := 147;
  fUpdateTimerID := 148;
  GetMem(p,50);
  FAutoUpdate := True;
end;

destructor TTrayIcon.Destroy;
begin
  if fEnabled then SetEnabled(False);
  FreeMem(p,50);
  fIcon.Free;
  fDisabledIcon.Free;
  fAniIcon.Free;
  fIconList.Destroy;
  inherited Destroy;
end;

function TTrayIcon.MakeIcon(Sender: TObject): boolean;
begin
  fIconNum := 0;
  LoadTaskIcon;
  if fState=tiAnimated then SetTimer(Handle,fTimerID,fInterval,nil);

  SetTimer(Handle, fUpdateTimerID, 1000, nil);

  with tnid do
    begin
      cbSize:=sizeof(TNOTIFYICONDATA);
      wnd:=Handle;
      uID:=fTaskIconID;
      uFlags:=NIF_MESSAGE+NIF_ICON+NIF_TIP;
      case fState of
        tiEnabled : hIcon:=fIcon.Handle;
        tiDisabled: hIcon:=fDisabledIcon.Handle;
        tiAnimated: hIcon:=fAniIcon.Handle;
      end;
      if fShowTip then StrPCopy(szTip,fTip) else StrPCopy(szTip,'');
      uCallbackMessage:=WM_TASKICON;
      result:=Shell_NotifyIcon(NIM_ADD,@tnid);
    end;
end;

function TTrayIcon.KillIcon(Sender: Tobject): boolean;
begin
{  try
    if fState=tiAnimated then KillTimer(Handle,fTimerID);
  except on EInvalidOperation do ;
  end; }
  result:=Shell_NotifyIcon(NIM_DELETE,@tnid);
end;

function TTrayIcon.ChangeIcon(Sender: TObject): boolean;
var tnid: TNOTIFYICONDATA;
begin
  with tnid do
    begin
      cbSize:=sizeof(TNOTIFYICONDATA);
      wnd:=Handle;
      uID:=fTaskIconID;
      uFlags:=NIF_MESSAGE+NIF_ICON+NIF_TIP;
      case fState of
        tiEnabled : hIcon:=fIcon.Handle;
        tiDisabled: hIcon:=fDisabledIcon.Handle;
        tiAnimated: hIcon:=fAniIcon.Handle;
      end;
      if fShowTip then StrPCopy(szTip,fTip) else StrPCopy(szTip,'');
      uCallbackMessage:=WM_TASKICON;
      result:=Shell_NotifyIcon(NIM_MODIFY,@tnid);
    end;
end;

procedure TTrayIcon.SetState(Value: TStateTaskIcon);
begin
  if Value<>fState then
    begin
      fState:=Value;
      if fState=tiAnimated then
        begin
          fIconNum:=0;
          LoadTaskIcon;
          if fEnabled then SetTimer(Handle,fTimerID,fInterval,nil);
        end
      else if fEnabled then KillTimer(Handle,fTimerID);
      if fEnabled then ChangeIcon(Self);
    end;
end;

procedure TTrayIcon.SetIconList(Value: TStrings);
begin
  fIconList.Assign(Value);
end;

procedure TTrayIcon.SetInterval(Value: UINT);
begin
  if Value<>fInterval then
    begin
      fInterval:=value;
      if fEnabled then
        begin
          KillTimer(Handle,fTimerID);
          SetTimer(Handle,fTimerID,fInterval,nil);
          fIconNum:=0;
          LoadTaskIcon;
        end;
    end;
end;

procedure TTrayIcon.WMTASKICON(var msg: TMessage);
var MouseCo: Tpoint;
begin
  if msg.wParam=LongInt(fTaskIconID) then
    case msg.lParam of
      WM_LBUTTONDBLCLK : if assigned(fOnDblClick) then fOnDblClick(self);
      WM_RBUTTONUP     : if assigned(fOnMouseUp)then
                           begin
                             GetCursorPos(MouseCo);
                             fOnMouseUp(self,mbRight,[],MouseCo.x,MouseCo.y);
                           end else
                           if assigned(fOnClick) then fOnClick(self);
      WM_LBUTTONUP     : if assigned(fOnMouseUp)then
                           begin
                             GetCursorPos(MouseCo);
                             fOnMouseUp(self,mbLeft,[],MouseCo.x,MouseCo.y);
                           end  else
                           if assigned(fOnClick) then fOnClick(self);
      WM_RBUTTONDOWn     : if assigned(fOnMouseDown)then
                           begin
                             GetCursorPos(MouseCo);
                             fOnMouseDown(self,mbRight,[],MouseCo.x,MouseCo.y);
                           end;
      WM_LBUTTONDOWN     : if assigned(fOnMouseDown)then
                           begin
                             GetCursorPos(MouseCo);
                             fOnMouseDown(self,mbLeft,[],MouseCo.x,MouseCo.y);
                           end;
    end;
end;

procedure TTrayIcon.WMTIMER(var msg: TMessage);
begin
  if (msg.wParam=LongInt(fTimerID)) and (fIconList.Count>0) then
    begin
      inc(fIconNum);
      if fIconNum>=fIconList.Count then fIconNum:=0;
      LoadTaskIcon;
      if fEnabled=true then ChangeIcon(Self);
      if (State=tiAnimated) and assigned(fOnAnimate) and fEnabled then fOnAnimate(self);
    end;

  if (msg.wParam=LongInt(fUpdateTimerID)) and (FAutoUpdate) then
  begin
      if fEnabled=true then
      begin
         if not ChangeIcon(Self) then
            MakeIcon(Self);
      end;
  end;

end;

procedure TTrayIcon.LoadTaskIcon;
begin
  if fIconList.Count>0 then
    begin
      StrPCopy(p,UpperCase(fIconList.Strings[fIconNum]));
      if WhereIcons=tiInFiles then
        fAniIcon.LoadFromFile(UpperCase(fIconList.Strings[fIconNum]))
      else fAniIcon.Handle:=LoadIcon(hInstance,p);
    end;
end;

procedure Register;
begin
  RegisterComponents('Samples',[TTrayIcon]);
end;

end.
