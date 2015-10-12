unit updater;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Gauges, sockschain, janXMLParser2;

type
  TCheckerThread = class(TThread)
  private
    FProxyItem: TSocksChainItem;
    FSize,
    FProgress: integer;
    FFileName: string;
    FUpdateProgressTotal,
    FUpdateProgress: integer;

    procedure UpdateProgressGauge;
    procedure UpdateDownloadGauge;
  protected
    procedure Execute; override;
  public
    constructor Create(const AProxyItem: TSocksChainItem); virtual;

  end;

  TfrmUpdates = class(TForm)
    Gauge1: TGauge;
    Gauge2: TGauge;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure CheckFreeCapedPrograms();

  end;

var
  frmUpdates: TfrmUpdates;

implementation
uses Misc;

{$R *.DFM}

{ TfrmUpdates }

procedure TfrmUpdates.CheckFreeCapedPrograms;
begin

end;

{ TCheckerThread }

constructor TCheckerThread.Create(const AProxyItem: TSocksChainItem);
begin
     inherited Create(True);
     FProxyItem := TSocksChainItem.CreateIt();
     FProxyItem.Assign(AProxyItem);
     FreeOnTerminate := False;
     frmUpdates.Show();
end;

procedure TCheckerThread.Execute;
var
   Request, Response, LastErr, ParamsStr: string;
   header, body, BasePath: string;
   XMLDOM: TjanXMLParser2;
   Nodes: TjanXMLNode2;
   Item: TjanXMLNode2;
   i, cnt: integer;
begin

     Request := 'POST /informer.php?a=update HTTP/1.0' + #13#10
               + 'Host: freecap.ru' + #13#10
               + 'User-agent: FreeCap builtin checker' + #13#10
               + 'Content-length: %d' + #13#10
               + 'Content-Type: %s' + #13#10
               + #13#10
               + '%s';

     BasePath := ExtractFilePath(Application.Exename);
     ParamsStr := 'freecap.exe=' + GetModuleVersion(BasePath + '\freecap.exe')
                + '&inject.dll=' + GetModuleVersion(BasePath + '\inject.dll')
                + '&proxy32.dll=' + GetModuleVersion(BasePath + '\proxy32.dll')
                + '&freecapCon.exe=' + GetModuleVersion(BasePath + '\freecapCon.exe')
                + '&freecapConW.exe=' + GetModuleVersion(BasePath + '\freecapConW.exe');

     Request := Format(Request, [Length(ParamsStr), 'application/x-www-form-urlencoded', ParamsStr]);

     if FProxyItem.Connect() = 0 then
     begin
          if FProxyItem.TryToRetrieve('freecap.ru', Request, Response, LastErr) <> 0 then
          begin
               DisplayMessage('Unable to get update!' + LastErr);
               exit;
          end;
          SplitHtml(Response, header, body);

          XMLDOM := TjanXMLParser2.Create();
          XMLDOM.name := 'freecap';
          XMLDOM.xml := Body;

          Nodes := XMLDOM.getChildByName('modules');

          if Nodes <> nil then
          begin
               cnt := StrToIntDef(Nodes.attribute['count'], 0);

               FUpdateProgressTotal := cnt;

               for i := 0 to cnt - 1 do
               begin
                    FUpdateProgress := i;
                    Synchronize(UpdateProgressGauge);

                    Item := TjanXMLNode2(Nodes.nodes.Items[i]);
                    if Item <> nil then
                    begin
                         FSize := StrToIntDef(Item.attribute['size'], 0);
                         FProgress := 0;
                         FFileName := Item.attribute['name'];
                         Synchronize(UpdateDownloadGauge);

                    end;
               end;
          end;
          XMLDOM.Free;
     end
     else
         DisplayMessage('Unable to connect to ' + FProxyItem.Server + ' proxy server!');
end;

procedure TCheckerThread.UpdateDownloadGauge;
begin
     frmUpdates.Gauge2.MaxValue := FSize;
     frmUpdates.Gauge2.Progress := FProgress;
     frmUpdates.Label2.Caption := Format('Downloading %s (%d of %d completed)', [FFileName, frmUpdates.Gauge2.Progress, frmUpdates.Gauge2.MaxValue]);

end;

procedure TCheckerThread.UpdateProgressGauge;
begin
     frmUpdates.Gauge1.MaxValue := FUpdateProgressTotal;
     frmUpdates.Gauge1.Progress := FUpdateProgress;
end;

end.
