{*
 * File: ...................... common.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev
 * Desc: ...................... Miscleanous functions.

 $Id: common.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

 $Log: common.pas,v $
 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit common;

interface
uses Windows, SysUtils, winsock;

type
   TVirtualAllocEx = function (hProcess: THandle; lpAddress: Pointer; dwSize, flAllocationType: DWORD; flProtect: DWORD): Pointer; stdcall;
var
   fnVirtualAllocEx : TVirtualAllocEx;

   function CheckSOCKServer(host: string; port: integer): Boolean;
   function IsCorrectIP(IP: string): Boolean;
   function IsCorrectPort(Port: string): Boolean;

   function OEM(const St: string): string;
   function GetErrorDesc(dwError: DWORD): String;

implementation

const
     sCopy = 'FreeCap (c) Copyright 2004 by Max Artemev. All rights reserved.';


function CheckSOCKServer(host: string; port: integer): Boolean;
type
  THostAddr = array[1..4] of byte;
  PHostAddr = ^THostAddr;
var
   s: TSocket;
   Name   : TSockAddr;
   WSData : WSAData;
   HostEnt: PHostEnt;
   ph     : PHostAddr;
   res    : integer;
begin
     result := False;

     if WSAStartup($102, WSData) = 0 then
     begin
          s := socket(AF_INET, SOCK_STREAM, 0);
          Name.sin_family := AF_INET;

          HostEnt := gethostbyname(PChar(host));
          if HostEnt <> nil then
          begin
               ph := PHostAddr(HostEnt^.h_addr_list^);
               if (ph = nil) then
               begin
                    closesocket(s);
                    WSACleanup;
                    exit;
               end;
               name.sin_addr.S_addr := Cardinal(ph^);
               name.sin_port := ntohs(port);
               res := connect(s, Name, SizeOf(TSockAddr));

//               res := WSAGetLastError();
               if res = 0 then
               begin
                    result := True;
               end;
          end;
          closesocket(s);
          WSACleanup;
     end;
end;


function CalcNetMask(bits: DWORD): DWORD;
begin
     result := DWORD((1 shl bits) - 1);
end;



function GetDottedIP(const IP: DWORD): string;
begin

     result := Format('%d.%d.%d.%d',[IP and $FF,
                                     IP shr 8 and $FF,
                                     IP shr 16 and $FF,
                                     IP shr 24]);
end;


function IsDirectAddr(IP: DWORD; direct_ip, direct_netmask: DWORD): Boolean;
var
   first_ip : DWORD;
   last_ip  : DWORD;
begin
     first_ip := direct_ip;
     last_ip := direct_ip or (not direct_netmask);
     result := (ntohl(ip) >= ntohl(first_ip)) and (ntohl(ip) <= ntohl(last_ip));
end;


function IsCorrectIP(IP: string): Boolean;
var
   i: integer;
begin
     result := False;
     if IP = '' then
        exit;
     for i := 1 to Length(IP) do
     begin
          if not (IP[i] in ['0'..'9','.','/']) then
            exit;
     end;
     result := True;
end;

function IsCorrectPort(Port: string): Boolean;
var
   i: integer;
begin
     result := False;
     if Port = '' then
        exit;
     for i := 1 to Length(Port) do
     begin
          if not (Port[i] in ['0'..'9']) then
            exit;
     end;
     result := True;
end;

function MAKELANGID(p, s: WORD): DWORD;
begin
     result := (s shl 10) or p;
end;


function OEM(const St: string): string;
var
  Len: Integer;
begin
  Len := Length(St);
  if Len > 0 then
  begin
    SetLength(Result, Len);
    CharToOemBuff(PChar(St), PChar(Result), Len);
  end;
end;


function GetErrorDesc(dwError: DWORD): String;
var
   Buf: PChar;
begin
     Buf := AllocMem(4096);
     FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,  nil, dwError, 0, Buf,  4096,  nil);
     result := String(Buf);
     FreeMem(Buf);
end;



initialization
// Win9x doesn't have this function in the kernel32.dll, so program can crash about missed component
  fnVirtualAllocEx := GetProcAddress(GetModuleHandle('KERNEL32.DLL'),'VirtualAllocEx');
end.
