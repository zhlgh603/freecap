{*
 * File: ...................... direct_addr.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Support class for direct addresses

 $Id: direct_addr.pas,v 1.7 2005/12/19 06:09:02 bert Exp $

 $Log: direct_addr.pas,v $
 Revision 1.7  2005/12/19 06:09:02  bert
 *** empty log message ***

 Revision 1.6  2005/05/24 04:28:52  bert
 *** empty log message ***

 Revision 1.5  2005/05/23 13:01:11  bert
 *** empty log message ***

 Revision 1.4  2005/05/12 04:21:22  bert
 *** empty log message ***

 Revision 1.3  2005/02/23 10:31:37  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit direct_addr;

interface
uses Windows, Classes, SysUtils, reg_config, winsock;

type
    TDirectAddr = class
    private
      FAddr: TStringList;
      FPorts: TStringList;

      function CalcNetMask(bits: DWORD): DWORD;
      function GetAddrCount: integer;
      function GetPortCount: integer;
      function GetAddrItem(index: integer): string;
      function GetPortItem(index: integer): string;
    public
      constructor Create(); virtual;
      destructor Destroy; override;
      procedure Load;
      procedure Save;
      procedure Add(ip: string);  overload;
      procedure Add(port: Word); overload;

      procedure Del(ip: string); overload;
      procedure Del(port: Word); overload;

      function IsAddrDirect(IP: DWORD): Boolean;
      function IsPortDirect(Port: WORD): Boolean;

      property AddrCount: integer read GetAddrCount;
      property PortCount: integer read GetPortCount;

      property Addr[index: integer]: string read GetAddrItem;
      property Port[index: integer]: string read GetPortItem;
    end;

    procedure Init;
    procedure Fini;

var
   DirectAddr: TDirectAddr;

implementation
uses cfg, loger, misc;


{ TDirectAddr }

procedure TDirectAddr.Add(ip: string);
begin
     FAddr.Add(ip);
end;


procedure TDirectAddr.Add(port: Word);
begin
     FPorts.Add(IntToStr(port));
end;


constructor TDirectAddr.Create();
begin
     FAddr := TStringList.Create;
     FPorts := TStringList.Create;
     Load;
end;

procedure TDirectAddr.Del(ip: string);
var
   i: integer;
begin
     i := FAddr.IndexOf(ip);
     if i >= 0 then
        FAddr.Delete(i);
end;

procedure TDirectAddr.Del(port: Word);
var
   i: integer;
   port_s: string;
begin
     port_s := IntToStr(port);
     i := FPorts.IndexOf(port_s);
     if i >= 0 then
        FPorts.Delete(i);
end;

destructor TDirectAddr.Destroy;
begin
     if not isLibrary then
        Save;
     FAddr.Free;
     FPorts.Free;
     inherited;
end;


function TDirectAddr.CalcNetMask(bits: DWORD): DWORD;
begin
     result := DWORD((1 shl bits) - 1);
end;


function TDirectAddr.IsAddrDirect(IP: DWORD): Boolean;
var
   direct_ip, direct_netmask, first_ip, last_ip : DWORD;
   s: string;
   i: integer;
begin
     result := False;

     Log(LOG_LEVEL_CONN, '(IP = 0) = %d (ntohl(ip) shr 24 = $7F) = %d (%x, %x)',[Integer(IP = 0), Integer(ntohl(ip) shr 24 = $7F), ntohl(ip) shr 24, ip]);

     if (IP = 0) or (ntohl(ip) shr 24 = $7F) then
     begin
          result := True;
          exit;
     end;


     for i := 0 to FAddr.Count - 1 do
     begin
          s := FAddr[i];

          if pos('/', s) <> 0 then
          begin
               direct_ip := inet_addr(PChar(copy(s, 1, pos('/', s) - 1)));
               direct_netmask := StrToIntDef(copy(s, pos('/', s) + 1, MaxInt), 0);
               direct_netmask := CalcNetMask(direct_netmask);

               first_ip := direct_ip;
               last_ip := direct_ip or (not direct_netmask);
               result := (ntohl(ip) >= ntohl(first_ip)) and (ntohl(ip) <= ntohl(last_ip));
          end
          else
              result := (ntohl(ip) = ntohl(inet_addr(PChar(s))));

          if result then exit;
     end;
end;

procedure TDirectAddr.Load;
var
   s: string;
   i: integer;
   FIni: TRegConfig;
begin
     FIni := TRegConfig.Create();
     Fini.ReadSectionValues(PART_DIRECTADDR, 'DirectAddr', FAddr);

     for i := 0 to FAddr.Count - 1 do
     begin
          s := FAddr[i];
          Delete(s, 1, pos('=', s));
          FAddr[i] := s;
     end;

     Fini.ReadSectionValues(PART_DIRECTPORT, 'DirectPort', FPorts);
     for i := 0 to FPorts.Count - 1 do
     begin
          s := FPorts[i];
          Delete(s, 1, pos('=', s));
          FPorts[i] := s;
     end;
     FIni.Free;
end;

procedure TDirectAddr.Save;
var
   i: integer;
   FIni: TRegConfig;
begin
     FIni := TRegConfig.Create();
     Fini.EraseSection(PART_DIRECTADDR, 'DirectAddr');
     for i := 0 to FAddr.Count - 1 do
       Fini.WriteString(PART_DIRECTADDR, 'DirectAddr', Format('n%d',[i]), FAddr[i]);

     Fini.EraseSection(PART_DIRECTPORT, 'DirectPort');
     for i := 0 to FPorts.Count - 1 do
       Fini.WriteString(PART_DIRECTPORT, 'DirectPort', Format('n%d',[i]), FPorts[i]);
     FIni.Free;
end;


procedure Init;
begin
     DirectAddr := TDirectAddr.Create();
end;

procedure Fini;
begin
     DirectAddr.Free;
end;


function TDirectAddr.IsPortDirect(Port: WORD): Boolean;
var
   Port_s: string;
   i: integer;
begin
     Port_s := IntToStr(ntohs(Port));
     result := False;

     for i := 0 to FPorts.Count - 1 do
     begin
          result := FPorts[i] = Port_s;
          if result then
             break;
     end;
end;

function TDirectAddr.GetAddrCount: integer;
begin
     result := FAddr.Count;
end;

function TDirectAddr.GetPortCount: integer;
begin
     result := FPorts.Count;
end;

function TDirectAddr.GetAddrItem(index: integer): string;
begin
     result := FAddr[index];
end;

function TDirectAddr.GetPortItem(index: integer): string;
begin
     result := FPorts[index];
end;

end.


