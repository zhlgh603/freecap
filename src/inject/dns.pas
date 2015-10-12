{*
 * File: ...................... dns.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Hook DNS queries for mapping via SOCKS server.

 $Id: dns.pas,v 1.5 2005/12/19 06:09:02 bert Exp $

 $Log: dns.pas,v $
 Revision 1.5  2005/12/19 06:09:02  bert
 *** empty log message ***

 Revision 1.4  2005/08/11 05:20:36  bert
 *** empty log message ***

 Revision 1.3  2005/03/03 23:09:27  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit dns;

interface

uses Windows, Classes, SysUtils, winsock2, syncobjs, misc, cfg, loger;

  {* Real resolving *}
  function ResolveIP(host: string): DWORD;

  {* Pseudo resolving *}
  function my_gethostbyname(host: PChar): PHostEnt;
  function my_getaddrinfo(nodename, servname: PChar; hints: PAddrInfo; {var} res: PPAddrInfo): integer;


  function resolve(host: string): DWORD;
//  procedure findhost(ip: dword; var result: string);

  function IsPseudoAddr(ip: dword): Boolean;
  function IsIPAddr(nodename: PChar): Boolean;

//  procedure drophost(ip: dword);
  function GetAddrString(ip: DWORD): string;
  procedure my_freeaddrinfo(ai: PAddrInfo);

  function GetLocalAddr(): DWORD;

  procedure stub_Findhost (IP: DWORD; buf: PChar; bufsize: integer); stdcall;

  procedure init();
  procedure Fini();

implementation
type
    TAddressInfo = packed record
      strHost: PChar;
      dwHost: DWORD;
    end;
    PAddressInfo = ^TAddressInfo;

    TAllocatedHosts = class
    private
      FItems: TList;
      FAIList: TList;
      FLocalHost: string;
      procedure Cleanup;
      procedure DeallocAI(ai: PAddrInfo);
    public
      constructor Create(); virtual;
      destructor Destroy; override;
      procedure AddHost(host: string; addr: DWORD);
      function findhost(ip: dword): string;

      // Allocate a pseudo-IP (0.0.0.x) for mapping
      function ResolveHost(host: string): DWORD;
      // Map pseudo-ip back to hostname
      function BackResolve(IP: DWORD): string;

      function GetIndex(host: string): integer; overload;
      function GetIndex(addr: DWORD): integer; overload;

      procedure AddAI(ai: PAddrInfo);
      procedure DropAI(ai: PAddrInfo);

    end;


var
//   IPlist: TStringList;
   CritSection: TCriticalSection;
   HostEnt: PHostEnt = nil;
   LocalAddr: DWORD = $FFFFFFFF;
   AllocatedHosts: TAllocatedHosts;

function ResolveIP(host: string): DWORD;
var
   HostEntry: PHostEnt;
   ph: PHostAddr;
begin
     result := 0;
     HostEntry := gethostbyname(PChar(host));
     if HostEntry = nil then
       exit;
     ph := PHostAddr(HostEntry^.h_addr_list^);
     if ph <> nil then
       result := Cardinal(ph^);
end;

{
function GetIndex(host: string): integer; overload;
var
   i: integer;
begin
     result := -1;
     for i := 0 to IPlist.Count - 1 do
     begin
          if IPlist.Names[i] = host then
          begin
               result := i;
               exit;
          end;
     end;
end;

function GetIndex(ip: DWORD): integer; overload;
var
   i: integer;
begin
     result := -1;

     for i := 0 to IPlist.Count - 1 do
     begin
          if IPlist.Values[IPlist.Names[i]] = Format('%u', [ip]) then
          begin
               result := i;
               exit;
          end;
     end;
end;

function resolve2(host: string): DWORD;
var
   i: integer;
begin
     CritSection.Enter;
     i := GetIndex(host);
     if i = -1 then
     begin
          IPlist.Values[host] := Format('%u', [htonl(255 shl 24 or (IPlist.Count + 1))]);
     end;
     result := StrToInt64(IPlist.Values[host]);

     Log(LOG_LEVEL_WARN, 'Added to list %s = %d', [host, result]);

     CritSection.Leave;
end;
}
function resolve(host: string): DWORD;
begin
     if IsIPAddr(PChar(host)) then
     begin
          result := inet_addr(PChar(host));
          exit;
     end;

     if (prog_resolve_dns = 0) then
     begin
          result := ResolveIP(host);
     end
     else if prog_resolve_dns = 1 then
     begin
          result := ResolveIP(host);
          if result = 0 then
             result := AllocatedHosts.ResolveHost(host);
     end
     else
     begin
          result := AllocatedHosts.ResolveHost(host);
     end;
end;
{
procedure findhost(ip: dword; var result: string);
var
   i: integer;
begin
     CritSection.Enter;
     i := GetIndex(ip);
     if i = -1 then
       result := ''
     else
       result := IPlist.Names[i];

     CritSection.Leave;
end;

procedure drophost(ip: dword);
var
   i: integer;
begin
     CritSection.Enter;
     i := GetIndex(ip);
     if i <> -1 then
       IPlist.Delete(i);
     CritSection.Leave;
end;
}

function my_gethostbyname2(host: PChar): PHostEnt;
type
    PDWORDArray = ^TDWORDArray;
    TDWORDArray = array[0..1] of PDWORD;
var
   ph :PHostAddr;
   pdw1: PDWORDArray;
begin
     if HostEnt = nil then
     begin
          GetMem(HostEnt, SizeOf(THostEnt));
          ZeroMemory(HostEnt, SizeOf(THostEnt));
          GetMem(HostEnt^.h_addr_list, SizeOf(DWORD) * 2);

          pdw1 := PDWORDArray(HostEnt^.h_addr_list);
          pdw1^[1] := nil;

          GetMem(HostEnt^.h_addr_list^, SizeOf(DWORD));
          ZeroMemory(HostEnt^.h_addr_list^, SizeOf(DWORD));
          pdw1^[0] := PDWORD(HostEnt^.h_addr_list^);

          HostEnt^.h_addrtype := AF_INET;
          GetMem(HostEnt^.h_aliases, SizeOf(DWORD));
          HostEnt^.h_aliases^ := nil;
          HostEnt^.h_length := SizeOf(Integer);
          HostEnt^.h_name := host;
     end;

     ph := PHostAddr(HostEnt^.h_addr_list^);
     DWORD(ph^) := resolve(host);

     result := HostEnt;
end;

function IsIPAddr(nodename: PChar): Boolean;
begin
     result := False;
     if nodename = nil then
        exit;

     result := True;
     while nodename^ <> #0 do
     begin
          result := result and (nodename^ in ['0'..'9','.']);
          inc(nodename);
     end;
end;


function my_gethostbyname(host: PChar): PHostEnt;
begin
     if host = nil then
     begin
          result := nil;
          exit;
     end;

     if (prog_resolve_dns = 0) then
     begin
          result := gethostbyname(host);
     end
     else if prog_resolve_dns = 1 then
     begin
          result := gethostbyname(host);
          if result = nil then
             result := my_gethostbyname2(host);
     end
     else
     begin
          result := my_gethostbyname2(host);
     end;
end;

{* return allocated memory to OS
 *}
procedure Dealloc_ai(var ai: PAddrInfo);
begin
     if (ai <> nil) then
     begin
          FreeMem(ai^.ai_addr);
          if (ai^.ai_canonname <> nil) then
            FreeMem(ai^.ai_canonname);
          FreeMem(ai);
     end;
end;

procedure DeallocHostEnt();
begin
     if (HostEnt <> nil) then
     begin
          FreeMem(HostEnt^.h_aliases);
          FreeMem(HostEnt^.h_addr_list^);
          FreeMem(HostEnt^.h_addr_list);
          FreeMem(HostEnt);
     end;
end;


function my_getaddrinfo(nodename, servname: PChar; hints: PAddrInfo; {var} res: PPAddrInfo): integer;
var
   ai: PAddrInfo;
   se: PServEnt;
   canonhost: string;
begin
     if (prog_resolve_dns = 0) then
     begin
          result := getaddrinfo(nodename, servname, hints, res);
          exit;
     end
     else if prog_resolve_dns = 1 then
     begin
          result := getaddrinfo(nodename, servname, hints, res);
          if (nodename <> nil) and (result <> 0) then
          begin
               result := 0;

               GetMem(ai, SizeOf(TAddrInfo));
               ZeroMemory(ai, SizeOF(TAddrInfo));

               with ai^ do
               begin
                    ai_family := AF_INET;
                    ai_socktype := SOCK_STREAM;
                    ai_protocol := IPPROTO_IP;
                    ai_addrlen := SizeOf(TSockAddr);

                    GetMem(ai_addr, SizeOf(TSockAddr));
                    if (ai_addr = nil) then
                      Log(LOG_LEVEL_WARN, 'ERROR! Unable to allocate ai^.ai_addr', []);
                    ai_addr^.sin_family := AF_INET;
                    ai_next := nil;

                    if not IsIPAddr(nodename) then
                    begin
                         GetMem(ai_canonname, strlen(nodename) + 1);
                         strcopy(ai_canonname, nodename);
                         ai_addr^.sin_addr.S_addr := AllocatedHosts.ResolveHost(nodename);
                    end
                    else
                    begin
                         canonhost := AllocatedHosts.findhost(inet_addr(nodename));
                         if canonhost = '' then
                         begin
                              result := WSAHOST_NOT_FOUND;
                              Dealloc_ai(ai);
                              res^ := nil;
                              exit;
                         end
                         else
                         begin
                              GetMem(ai_canonname, Length(canonhost) + 1);
                              strPcopy(ai_canonname, canonhost);
                              ai_addr^.sin_addr.S_addr := inet_addr(nodename);
                         end;
                    end;
               end;

               if servname <> nil then
               begin
                    se := getservbyname(servname, 'tcp');
                    if (se <> nil) then
                      ai^.ai_addr^.sin_port := htons(se^.s_port)
                    else
                      ai^.ai_addr^.sin_port := htons(StrToIntDef(string(servname), 0));
               end;
               res^ := ai;
               AllocatedHosts.AddAI(ai);
          end;
     end
     else
     begin
          result := -1;
          if res = nil then
            exit;

          if (nodename <> nil) then
          begin
               result := 0;

               GetMem(ai, SizeOf(TAddrInfo));
               ZeroMemory(ai, SizeOF(TAddrInfo));

               with ai^ do
               begin
                    ai_family := AF_INET;
                    ai_socktype := SOCK_STREAM;
                    ai_protocol := IPPROTO_IP;
                    ai_addrlen := SizeOf(TSockAddr);

                    GetMem(ai_addr, SizeOf(TSockAddr));
                    if (ai_addr = nil) then
                      Log(LOG_LEVEL_WARN, 'ERROR! Unable to allocate ai^.ai_addr', []);
                    ai_addr^.sin_family := AF_INET;
                    ai_next := nil;

                    if not IsIPAddr(nodename) then
                    begin
                         GetMem(ai_canonname, strlen(nodename) + 1);
                         strcopy(ai_canonname, nodename);
                         ai_addr^.sin_addr.S_addr := AllocatedHosts.ResolveHost(nodename);
                    end
                    else
                    begin
                         canonhost := AllocatedHosts.BackResolve(inet_addr(nodename));
                         if canonhost = '' then
                         begin
                              result := WSAHOST_NOT_FOUND;
                              Dealloc_ai(ai);
                              res^ := nil;
                              exit;
                         end
                         else
                         begin
                              GetMem(ai_canonname, Length(canonhost) + 1);
                              strPcopy(ai_canonname, canonhost);
                              ai_addr^.sin_addr.S_addr := inet_addr(nodename);
                         end;
                    end;
               end;

               if servname <> nil then
               begin
                    se := getservbyname(servname, 'tcp');
                    if (se <> nil) then
                      ai^.ai_addr^.sin_port := htons(se^.s_port)
                    else
                      ai^.ai_addr^.sin_port := htons(StrToIntDef(string(servname), 0));
               end;
               res^ := ai;
               AllocatedHosts.AddAI(ai);
          end;
     end;
end;

procedure my_freeaddrinfo(ai: PAddrInfo);
begin
     AllocatedHosts.DropAI(ai);
end;


procedure init();
begin
//    IPlist := TStringList.Create;
    CritSection := TCriticalSection.Create;
    AllocatedHosts := TAllocatedHosts.Create;
end;


procedure Fini();
begin
//     IPlist.Clear();
//     IPlist.Free;
     AllocatedHosts.Free;
     CritSection.Free;
     DeallocHostEnt();
end;


function IsPseudoAddr(ip: dword): Boolean;
begin
     result := (ip and $FFFF) = 0;
end;

function GetAddrString(ip: DWORD): string;
begin
     if IsPseudoAddr(ip) then
        result := AllocatedHosts.findhost(IP)
     else
        result := GetDottedIP(ip);
end;


function GetLocalAddr(): DWORD;
var
   buf: array[0..MAX_PATH] of Char;
begin
     if LocalAddr = $FFFFFFFF then
     begin
          ZeroMemory(@buf, SizeOf(buf));
          gethostname(@buf, SizeOf(Buf));
          LocalAddr := ResolveIP(buf);
     end;
     result := LocalAddr;
end;



{ TAllocatedHosts }

procedure TAllocatedHosts.AddHost(host: string; addr: DWORD);
var
   Item : PAddressInfo;
begin
     GetMem(Item, SizeOf(TAddressInfo));
     with Item^ do
     begin
          if host <> '' then
          begin
               GetMem(strHost, Length(host) + 1);
               strPCopy(strHost, host);
          end
          else
              strHost := nil;
          dwHost := addr;
     end;
     FItems.Add(Item);
end;

procedure TAllocatedHosts.Cleanup;
var
   i: integer;
   Item : PAddressInfo;
begin
     for i := 0 to FItems.Count - 1 do
     begin
          Item := PAddressInfo(FItems[i]);
          if (Item^.strHost <> nil) then
             FreeMem(Item^.strHost);
          FreeMem(Item);
     end;
end;

constructor TAllocatedHosts.Create;
var
   buf: array[0..255] of char;
begin
     FItems := TList.Create;
     FAIList := TList.Create;

     gethostname(@Buf[0], SizeOf(Buf));
     FLocalHost := string (Buf);
end;

procedure TAllocatedHosts.DeallocAI(ai: PAddrInfo);
begin
     if (ai <> nil) then
     begin
          FreeMem(ai^.ai_addr);
          if (ai^.ai_canonname <> nil) then
            FreeMem(ai^.ai_canonname);
          FreeMem(ai);
     end;
end;

destructor TAllocatedHosts.Destroy;
begin
     Cleanup;
     FItems.Free;
     FAIList.Free;
     inherited Destroy;
end;

function TAllocatedHosts.GetIndex(host: string): integer;
var
   i: integer;
begin
     result := -1;
     if host = '' then exit;
     for i := 0 to FItems.Count - 1 do
     begin
          if (PAddressInfo(FItems[i])^.strHost <> nil) and (strIcomp(PAddressInfo(FItems[i])^.strHost, PChar(host)) = 0) then
          begin
               result := i;
               exit;
          end;
     end;
end;

function TAllocatedHosts.findhost(ip: dword): string;
var
   i: integer;
begin
     CritSection.Enter;

     try
        if ((ip and $FF) = $7F) then
        begin
             result := FLocalHost;
             exit;
        end;

        i := GetIndex(ip);
        if i = -1 then
          result := ''
        else
          result := PAddressInfo(FItems[i])^.strHost;
     finally
       CritSection.Leave;
     end;
end;

function TAllocatedHosts.GetIndex(addr: DWORD): integer;
var
   i: integer;
begin
     result := -1;
     for i := 0 to FItems.Count - 1 do
     begin
          if PAddressInfo(FItems[i])^.dwHost = addr then
          begin
               result := i;
               exit;
          end;
     end;
end;


function TAllocatedHosts.ResolveHost(host: string): DWORD;
var
   i: integer;
   idx, ip: DWORD;
begin
     CritSection.Enter;

     try
        if (host = FLocalHost) then
        begin
             result := inet_addr('127.0.0.1');
             exit;
        end;

        i := GetIndex(host);
        if i = -1 then
        begin
             idx := FItems.Count + 1;
             ip := (((idx shr 8) and $FF) shl 8) or (idx and $FF);
             AddHost(host, htonl(ip));
             i := GetIndex(host);
        end;
        result := PAddressInfo(FItems[i])^.dwHost;
     finally
       CritSection.Leave;
     end;
end;

function TAllocatedHosts.BackResolve(IP: DWORD): string;
begin
     result := findhost(IP);
end;


procedure TAllocatedHosts.AddAI(ai: PAddrInfo);
begin
     FAIList.Add(ai);
end;

procedure TAllocatedHosts.DropAI(ai: PAddrInfo);
var
   i: integer;
begin
     CritSection.Enter;
     try
        i := FAIList.IndexOf(ai);
        if i <> -1 then
        begin
             DeallocAI(ai);
             FAIList.Delete(i);
        end;
     finally
       CritSection.Leave;
     end;
end;



procedure stub_Findhost (IP: DWORD; buf: PChar; bufsize: integer); stdcall;
var
   res: string;
begin
     res := AllocatedHosts.Findhost(ip);
     strPCopy(Buf, res);
end;



end.
