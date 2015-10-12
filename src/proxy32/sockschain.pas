{*
 * File: ...................... sockschain.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... SOCKS chains support.

 $Id: sockschain.pas,v 1.6 2005/07/19 03:52:26 bert Exp $

 $Log: sockschain.pas,v $
 Revision 1.6  2005/07/19 03:52:26  bert
 *** empty log message ***

 Revision 1.5  2005/05/12 04:21:22  bert
 *** empty log message ***

 Revision 1.4  2005/04/18 04:49:55  bert
 *** empty log message ***

 Revision 1.3  2005/04/06 04:58:56  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit sockschain;

interface
uses Windows, Sysutils, Classes, abs_config, reg_config, xml_config, inifiles, base64, syncobjs;

type
    TSocksChainItem = class
    private
      FAuth: Boolean;
      FinUse: Boolean;
      FHTTP_Auth: Boolean;
      FPort: integer;
      FVersion: integer;
      FHTTP_Pass: string;
      Fident: string;
      FServer: string;
      FHTTP_User: string;
      FPassword: string;
      FLogin: string;
      FLockcount: Integer;
      FCritSection: TCriticalSection;
      function GetLock: Boolean;
    public
      constructor Create; virtual;
      destructor Destroy; override;
      procedure Assign(Source: TObject);

      procedure Lock;
      procedure Unlock;

      property Server: string read FServer write FServer;
      property Port: integer read FPort write FPort;
      property Version: integer read FVersion write FVersion;
      property Auth: Boolean read FAuth write FAuth;
      property Login: string read FLogin write FLogin;
      property Password: string read FPassword write FPassword;
      property ident: string read Fident write Fident;
      property HTTP_User: string read FHTTP_User write FHTTP_User;
      property HTTP_Pass: string read FHTTP_Pass write FHTTP_Pass;
      property HTTP_Auth: Boolean read FHTTP_Auth write FHTTP_Auth;
      property inUse: Boolean read FinUse write FinUse;
      property Locked: Boolean read GetLock;
    end;

    TSocksChain = class
    private
      FChainList: TList;
      FDeletionQueue: TList;
      FChainIniFile: string;
      function GetItem(index: integer): TSocksChainItem;
      procedure Clear;
      function GetCount: integer;
      procedure FreeQueued;
    public
      constructor Create(ChainIniFile : string = ''); virtual;
      destructor Destroy; override;

      function GetFirstIndex(): integer;
      function GetNextIndex(FromIndex: integer): integer;
      function GetLastIndex(): integer;

      function AddSocks(serv: string; port: integer; version: integer; login, pass, ident: string; Auth: Boolean; http_user, http_pass: string; http_auth: boolean): TSocksChainItem;
      procedure DelSocks(index: integer);
      procedure LoadFromIni;
      procedure Reload;
      function GetLastSOCKS5(): TSocksChainItem;


      property Items[index: integer]: TSocksChainItem read GetItem; default;
      property Count: integer read GetCount;

    end;

    procedure Init;
    procedure Fini;

var
   SocksChains: TSocksChain;

implementation
uses cfg, loger, misc;

{ TSocksChain }

function TSocksChain.AddSocks(serv: string; port: integer; version: integer; login, pass, ident: string; Auth: Boolean; http_user, http_pass: string; http_auth: boolean): TSocksChainItem;
var
   Item: TSocksChainItem;
begin
     Item := TSocksChainItem.Create();
     Item.Server := serv;
     Item.Port := port;
     Item.Version := version;
     Item.Login := login;
     Item.Password := pass;
     Item.Auth := auth;
     Item.ident := ident;
     Item.HTTP_User := http_user;
     Item.HTTP_Pass := http_pass;
     Item.HTTP_Auth := http_auth;

     FChainList.Add(Item);
     result := Item;
end;

constructor TSocksChain.Create(ChainIniFile : string { = '' });
begin
     FChainList := TList.Create;
     FDeletionQueue := TList.Create;
     FChainIniFile := ChainIniFile;
     LoadFromIni;
end;

procedure TSocksChain.Clear;
var
   i: integer;
   Item: TSocksChainItem;
begin
     for i := FChainList.Count - 1 downto 0 do
     begin
          Item := TSocksChainItem(FChainList[i]);
          if not Item.Locked then
            Item.Free
          else
            FDeletionQueue.Add(Item);

     end;
     FChainList.CLear;
end;

function TSocksChain.GetCount: integer;
begin
     result := FChainList.Count;
end;


procedure TSocksChain.DelSocks(index: integer);
var
   Item: TSocksChainItem;
begin
     Item := TSocksChainItem(FChainList[index]);

     if not Item.Locked then
       Item.Free
     else
       FDeletionQueue.Add(Item);


     FChainList.Delete(index);
end;


destructor TSocksChain.Destroy;
begin
     Clear();
     FChainList.Free;
     FChainList := nil;
     inherited Destroy;
end;


function TSocksChain.GetItem(index: integer): TSocksChainItem;
begin
     result := nil;
     if (index >= 0) and (index < FChainList.Count) then
        result := TSocksChainItem(FChainList[index]);
end;



procedure TSocksChain.LoadFromIni;
var
   ini: TAbstractConfig;
   Sections, Values: TStringList;
   i: integer;
   Item: TSocksChainItem;
begin
     Clear;
     Sections := TStringList.Create;
     Values   := TStringList.Create;

     if FChainIniFile = '' then
        Ini := TRegConfig.Create()
     else
        Ini := TXMLConfig.Create(FChainIniFile);

     Ini.ReadSections(PART_SOCKSCHAIN, Sections);


     for i:=0 to Sections.Count - 1 do
     begin
          Values.Clear;
          Ini.ReadSectionValues(PART_SOCKSCHAIN, Sections[i], Values);
          Item := TSocksChainItem.Create();
          Item.Server := Sections[i];

          if Values.Values['Server'] <> '' then
            Item.Server := Values.Values['Server'];


          Item.Port := StrToIntDef(Values.Values['Port'], 1080);
          Item.Version := StrToIntDef(Values.Values['Version'], PROXY_VER_SOCKS5);
          Item.Login := Values.Values['Login'];
          Item.ident := Values.Values['Socks4Ident'];
          Item.Password := Values.Values['Password'];

          Item.HTTP_User := Values.Values['HttpUser'];
          Item.HTTP_Pass := Values.Values['HttpPass'];
          Item.HTTP_Auth := Boolean(StrToIntDef(Values.Values['HttpAuth'], 0));
          Item.inUse := Boolean(StrToIntDef(Values.Values['InUse'], 1));


          Item.Auth := Boolean(StrToIntDef(Values.Values['Auth'], 0));
          FChainList.Add(Item);
     end;
     Values.Free;
     Sections.Free;
     ini.Free;
end;


function TSocksChain.GetFirstIndex(): integer;
var
   i: integer;
begin
     result := -1;
     if Count = 0 then exit;

     i := 0;
     while (i < Count) and (not SocksChains[i].inUse) do
     begin
          inc(i);
     end;


     if (i <> Count) then
        result := i;
end;


function TSocksChain.GetNextIndex(FromIndex: integer): integer;
begin
     repeat
          inc(FromIndex);
     until (FromIndex = Count) or (SocksChains[FromIndex].inUse);
     result := FromIndex;
end;

function TSocksChain.GetLastIndex: integer;
begin
     result := Count - 1;
     if result = 0 then
     begin
          if not SocksChains[result].inUse then
            result := -1;
     end
     else
     begin
          while (result >= 0) and (not SocksChains[result].inUse) do
            dec(result);
     end;
end;


function TSocksChain.GetLastSOCKS5: TSocksChainItem;
var
   i: integer;
begin
     result := nil;
     i := Count - 1;

     if (i = 0) then
     begin
          if (SocksChains[i].inUse) and (SocksChains[i].Version = 5) then
            result := SocksChains[i];
     end
     else
     begin
          while (i >= 0) and ((not SocksChains[i].inUse) or (SocksChains[i].Version <> 5)) do
            dec(i);
          if i = -1 then
          begin
               Log(LOG_LEVEL_WARN, 'GetLastSOCKS5 = nil', []);
               exit;
          end;
          result := SocksChains[i];
     end;
end;

procedure TSocksChain.FreeQueued;
var
   i: integer;
   Item: TSocksChainItem;
begin
     for i := FDeletionQueue.Count - 1 downto 0 do
     begin
          Log(LOG_LEVEL_WARN, 'Removing proxy item from deletion queue', []);
          Item := TSocksChainItem(FDeletionQueue[i]);
          Item.Free;
     end;
     FDeletionQueue.CLear;
end;

procedure TSocksChain.Reload;
begin
     Clear;
     LoadFromIni;
end;

{ TSocksChainItem }



procedure TSocksChainItem.Assign(Source: TObject);
var
   Src: TSocksChainItem;
begin
     if Source is TSocksChainItem then
     begin
          Src := (Source as TSocksChainItem);
          FServer := Src.Server;
          FPort :=  Src.Port;
          FVersion := Src.Version;
          FAuth := Src.Auth;
          FLogin := Src.Login;
          FPassword := Src.Password;
          Fident := Src.ident;
          FHTTP_User := Src.HTTP_User;
          FHTTP_Pass := Src.HTTP_Pass;
          FHTTP_Auth := Src.HTTP_Auth;
          FinUse := Src.inUse;
     end;
end;


procedure Init;
var
   Buf: array[0..MAX_PATH] of Char;
begin
     ZeroMemory(@Buf, SizeOf(Buf));
     if GetEnvironmentVariable('FreeCAPConfigFile', @Buf, SizeOf(Buf)) <> 0 then
     begin
          Log(LOG_LEVEL_DEBUG, 'Buf = %s', [Buf]);
          SocksChains := TSocksChain.Create(Buf)
     end
     else
       SocksChains := TSocksChain.Create;
end;


procedure Fini;
begin
     SocksChains.Clear();
     SocksChains.Free;
end;


constructor TSocksChainItem.Create;
begin
     FCritSection := TCriticalSection.Create;
end;

destructor TSocksChainItem.Destroy;
begin
     FCritSection.Free;
     inherited Destroy;
end;

function TSocksChainItem.GetLock: Boolean;
begin
     result := FLockcount > 0;
end;

procedure TSocksChainItem.Lock;
begin
     FCritSection.Enter;
     inc(FLockcount);
     FCritSection.Leave;
end;

procedure TSocksChainItem.Unlock;
begin
     FCritSection.Enter;
     dec(FLockcount);
     if (FLockcount <= 0) then
     begin
          FLockcount := 0;
          SocksChains.FreeQueued;
     end;
     FCritSection.Leave;
end;

end.
