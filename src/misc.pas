{*
 * File: ...................... Misc.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2003 by Max Artemev, MC NTT (www.ntt.ru)
 * Desc: ...................... Miscleanous functions

 $Id: misc.pas,v 1.5 2005/12/19 06:09:02 bert Exp $

 $Log: misc.pas,v $
 Revision 1.5  2005/12/19 06:09:02  bert
 *** empty log message ***

 Revision 1.4  2005/05/12 04:21:21  bert
 *** empty log message ***

 Revision 1.3  2005/03/08 16:38:50  bert
 *** empty log message ***

 Revision 1.2  2005/02/15 11:21:21  bert
 *** empty log message ***


}
unit Misc;

interface
uses  Windows, Classes, SysUtils, tlhelp32, winsock2, rpcrt;

{$I version.inc}

   procedure DisplayMessage(Msg: string);
   function GetDottedIP(const IP: DWORD): string;
   function GetFullAddr(const addr: TSockAddrIn): string;

   function GetProcessName(pid: DWORD): string;
   function WSocketErrorDesc(error: integer) : string;
   function isWin9x: Boolean;
   function isWinXP: Boolean;
   function GetWinVer(): string;

   function GetSockOpts(sockopt: integer): string;
   function GetPluginsDir(): string;


   function max(val1, val2: DWORD): DWORD;
   function IMAGE_SNAP_BY_ORDINAL(a: integer): Boolean;
   function MakePtr(base: Pointer; offset: DWORD): Pointer;
   function GetAsArray(a: PIMAGESECTIONHEADER; index: DWORD): PIMAGESECTIONHEADER;
   function isDirExists(name: string): Boolean;
   function GetNewGUID(): string;
   function encodeUrl(src: string): string;
   procedure SplitHtml(html: string; var Header, Body: string);
   function GetModuleVersion(Filename: string): string;


type
    _IMAGE_BASE_RELOCATION = packed record
	VirtualAddress: DWORD;
	SizeOfBlock: DWORD;
    end;
    IMAGE_BASE_RELOCATION = _IMAGE_BASE_RELOCATION;
    PIMAGE_BASE_RELOCATION = ^_IMAGE_BASE_RELOCATION;

    tagImportModuleDirectory = packed record
      RVAFunctionNameList,
      dwDummy1,
      dwDummy2,
      RVAModuleName,
      RVAFunctionAddressList: DWORD;
    end;
    IMAGE_IMPORT_MODULE_DIRECTORY = tagImportModuleDirectory;
    PIMAGE_IMPORT_MODULE_DIRECTORY = ^IMAGE_IMPORT_MODULE_DIRECTORY;

    PIMAGE_IMPORT_BY_NAME = ^IMAGE_IMPORT_BY_NAME;
    IMAGE_IMPORT_BY_NAME = packed record
	    Hint: Word;
            Name: Byte;
    end;

    PIMAGE_THUNK_DATA = ^IMAGE_THUNK_DATA;
    IMAGE_THUNK_DATA = packed record
       case Integer of
         0: (ForwarderString: PByte);
         1: (_Function: PDWORD);
         2: (Ordinal: DWORD);
	 3: (AddressOfData: PIMAGE_IMPORT_BY_NAME);
    end;
    TImageThunkData = IMAGE_THUNK_DATA;
    PImageThunkData = ^TImageThunkData;


    PIMAGE_IMPORT_DESCRIPTOR = ^IMAGE_IMPORT_DESCRIPTOR;
    IMAGE_IMPORT_DESCRIPTOR = record
        Characteristics: DWORD;
        TimeDateStamp: DWORD;
        ForwarderChain: DWORD;
        Name: DWORD;
        FirstThunk: PIMAGE_THUNK_DATA;
    end;


  PImageBoundImportDescriptor = ^TImageBoundImportDescriptor;
  _IMAGE_BOUND_IMPORT_DESCRIPTOR = record
    TimeDateStamp: DWORD;
    OffsetModuleName: Word;
    NumberOfModuleForwarderRefs: Word;
    // Array of zero or more IMAGE_BOUND_FORWARDER_REF follows
  end;
  TImageBoundImportDescriptor = _IMAGE_BOUND_IMPORT_DESCRIPTOR;
  IMAGE_BOUND_IMPORT_DESCRIPTOR = _IMAGE_BOUND_IMPORT_DESCRIPTOR;


  PImageBoundForwarderRef = ^TImageBoundForwarderRef;
  _IMAGE_BOUND_FORWARDER_REF = record
    TimeDateStamp: DWORD;
    OffsetModuleName: Word;
    Reserved: Word;
  end;
  TImageBoundForwarderRef = _IMAGE_BOUND_FORWARDER_REF;
  IMAGE_BOUND_FORWARDER_REF = _IMAGE_BOUND_FORWARDER_REF;

  PImgDelayDescr = ^TImgDelayDescr;
  ImgDelayDescr = packed record
    grAttrs: DWORD;                 // attributes
    szName: DWORD;                  // pointer to dll name
    phmod: PDWORD;                  // address of module handle
    pIAT: TImageThunkData;          // address of the IAT
    pINT: TImageThunkData;          // address of the INT
    pBoundIAT: TImageThunkData;     // address of the optional bound IAT
    pUnloadIAT: TImageThunkData;    // address of optional copy of original IAT
    dwTimeStamp: DWORD;             // 0 if not bound,
                                    // O.W. date/time stamp of DLL bound to (Old BIND)
  end;
  TImgDelayDescr = ImgDelayDescr;


var
   Unloaded: Boolean; // Global variable indicates that inject.dll was implicit unloaded
   Win9xPlatform: integer = -1;
   WinXPPlatform: integer = -1;

   TheBatFlag: integer = -1;
const
   IMAGE_ORDINAL_FLAG = $80000000;

implementation
uses cfg, xml_config, loger, common;

const
    lanMasks:  array [0..2] of string = ('10.0.0.0/8', '192.168.0.0/16', '172.16.0.0/12');


function isDirExists(name: string): Boolean;
var
   Code: Integer;
begin
     Code := GetFileAttributes(PChar(name));
     Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;



function GetPluginsDir(): string;
var
   Buf: array[0..MAX_PATH] of Char;
begin
     GetModuleFileName(hInstance, @Buf, SizeOf(Buf));
     result := ExtractFilePath(String(Buf)) + 'plugins\';
{

     if (GetEnvironmentVariable('FreeCapStartupDir', @Buf, SizeOF(Buf))) <> 0 then
     begin
          if isDirExists(Buf + '\plugins') then
            result := Buf + '\plugins\'
     end;

     if (result = '') and (GetEnvironmentVariable('APPDATA', @Buf, SizeOF(Buf)) <> 0) then
     begin
          if isDirExists(Buf + '\FreeCap\plugins') then
            result := Buf + '\FreeCap\plugins\'
     end;
}
end;


procedure DisplayMessage(Msg: string);
begin
//     if prog_show_messages then
       MessageBox(GetDesktopWindow(), PChar(Msg), 'Warning', MB_OK or MB_ICONINFORMATION or MB_APPLMODAL)
//     else
//       Log(LOG_LEVEL_WARN, '%s', [Msg]);
end;

function GetDottedIP(const IP: DWORD): string;
begin

     result := Format('%d.%d.%d.%d',[IP and $FF,
                                     IP shr 8 and $FF,
                                     IP shr 16 and $FF,
                                     IP shr 24]);
end;


function GetFullAddr(const addr: TSockAddrIn): string;
var
   ip: DWORD;
   port: Word;
begin
     ip := addr.sin_addr.S_addr;
     port := ntohs(addr.sin_port);
     result := Format('%d.%d.%d.%d:%d',[IP and $FF,
                                     IP shr 8 and $FF,
                                     IP shr 16 and $FF,
                                     IP shr 24,
                                     port]);
end;

function GetProcessName(pid: DWORD): string;
var
   SnapShot   : THandle;
   ProcessEntry: TProcessEntry32;
begin
    
     SnapShot:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
     ZeroMemory(@ProcessEntry, SizeOf(TProcessEntry32));
     ProcessEntry.dwSize := SizeOf(TProcessEntry32);

     if Process32First(SnapShot, ProcessEntry) then
     begin
          if ProcessEntry.th32ProcessID = pid then
          begin
               result := lowercase(ExtractFileName(ProcessEntry.szExeFile));
               CloseHandle(SnapShot);
               exit;
          end;

          while Process32Next(SnapShot, ProcessEntry) do
          begin
               if ProcessEntry.th32ProcessID = pid then
               begin
                    result := lowercase(ExtractFileName(ProcessEntry.szExeFile));
                    CloseHandle(SnapShot);
                    exit;
               end;
          end;
     end;
end;


function WSocketErrorDesc(error: integer) : string;
begin
    case error of
    0:  result := 'No Error';
    WSAEINTR:
      result := 'Interrupted system call';
    WSAEBADF:
      result := 'Bad file number';
    WSAEACCES:
      result := 'Permission denied';
    WSAEFAULT:
      result := 'Bad address';
    WSAEINVAL:
      result := 'Invalid argument';
    WSAEMFILE:
      result := 'Too many open files';
    WSAEWOULDBLOCK:
      result := 'Operation would block';
    WSAEINPROGRESS:
      result := 'Operation now in progress';
    WSAEALREADY:
      result := 'Operation already in progress';
    WSAENOTSOCK:
      result := 'Socket operation on non-socket';
    WSAEDESTADDRREQ:
      result := 'Destination address required';
    WSAEMSGSIZE:
      result := 'Message too long';
    WSAEPROTOTYPE:
      result := 'Protocol wrong type for socket';
    WSAENOPROTOOPT:
      result := 'Protocol not available';
    WSAEPROTONOSUPPORT:
      result := 'Protocol not supported';
    WSAESOCKTNOSUPPORT:
      result := 'Socket type not supported';
    WSAEOPNOTSUPP:
      result := 'Operation not supported on socket';
    WSAEPFNOSUPPORT:
      result := 'Protocol family not supported';
    WSAEAFNOSUPPORT:
      result := 'Address family not supported by protocol family';
    WSAEADDRINUSE:
      result := 'Address already in use';
    WSAEADDRNOTAVAIL:
      result := 'Address not available';
    WSAENETDOWN:
      result := 'Network is down';
    WSAENETUNREACH:
      result := 'Network is unreachable';
    WSAENETRESET:
      result := 'Network dropped connection on reset';
    WSAECONNABORTED:
      result := 'Connection aborted';
    WSAECONNRESET:
      result := 'Connection reset by peer';
    WSAENOBUFS:
      result := 'No buffer space available';
    WSAEISCONN:
      result := 'Socket is already connected';
    WSAENOTCONN:
      result := 'Socket is not connected';
    WSAESHUTDOWN:
      result := 'Can''t send after socket shutdown';
    WSAETOOMANYREFS:
      result := 'Too many references: can''t splice';
    WSAETIMEDOUT:
      result := 'Connection timed out';
    WSAECONNREFUSED:
      result := 'Connection refused';
    WSAELOOP:
      result := 'Too many levels of symbolic links';
    WSAENAMETOOLONG:
      result := 'File name too long';
    WSAEHOSTDOWN:
      result := 'Host is down';
    WSAEHOSTUNREACH:
      result := 'No route to host';
    WSAENOTEMPTY:
      result := 'Directory not empty';
    WSAEPROCLIM:
      result := 'Too many processes';
    WSAEUSERS:
      result := 'Too many users';
    WSAEDQUOT:
      result := 'Disc quota exceeded';
    WSAESTALE:
      result := 'Stale NFS file handle';
    WSAEREMOTE:
      result := 'Too many levels of remote in path';
    WSASYSNOTREADY:
      result := 'Network sub-system is unusable';
    WSAVERNOTSUPPORTED:
      result := 'WinSock DLL cannot support this application';
    WSANOTINITIALISED:
      result := 'WinSock not initialized';
    WSAHOST_NOT_FOUND:
      result := 'Host not found';
    WSATRY_AGAIN:
      result := 'Non-authoritative host not found';
    WSANO_RECOVERY:
      result := 'Non-recoverable error';
    WSANO_DATA:
      result := 'No Data';
    else

      result := 'Not a WinSock error (' + GetErrorDesc(error) + ')';
    end;
end;

function isWin9x: Boolean;
var
   osvi        : OSVERSIONINFO;
begin
     if Win9xPlatform = -1 then
     begin
          osvi.dwOSVersionInfoSize := SizeOf(OSVERSIONINFO);
          GetVersionEx(osvi);
          Win9xPlatform := Integer(osvi.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS);
     end;
     result := Win9xPlatform = 1;
end;

function isWinXP: Boolean;
var
   osvi        : OSVERSIONINFO;
begin
     if WinXPPlatform = -1 then
     begin
          osvi.dwOSVersionInfoSize := SizeOf(OSVERSIONINFO);
          GetVersionEx(osvi);
          WinXPPlatform := Integer((osvi.dwPlatformId = VER_PLATFORM_WIN32_NT) and (osvi.dwMajorVersion >= 5) and (osvi.dwMinorVersion >= 1));
     end;
     result := WinXPPlatform = 1;
end;


function GetSockOpts(sockopt: integer): string;
const
     SockOpts  : array [0..18] of integer = (
               SO_BROADCAST, SO_DEBUG, SO_DONTLINGER, SO_DONTROUTE, SO_GROUP_PRIORITY, SO_KEEPALIVE,
               SO_LINGER, SO_OOBINLINE, SO_RCVBUF, SO_REUSEADDR, SO_SNDBUF, PVD_CONFIG, TCP_NODELAY,
               SO_ACCEPTCONN, SO_RCVLOWAT, SO_RCVTIMEO, SO_SNDLOWAT, SO_SNDTIMEO, SO_TYPE);
     SockOptsS : array [0..18] of string = (
               'SO_BROADCAST', 'SO_DEBUG', 'SO_DONTLINGER', 'SO_DONTROUTE', 'SO_GROUP_PRIORITY', 'SO_KEEPALIVE',
               'SO_LINGER', 'SO_OOBINLINE', 'SO_RCVBUF', 'SO_REUSEADDR', 'SO_SNDBUF', 'PVD_CONFIG', 'TCP_NODELAY',
               'SO_ACCEPTCONN', 'SO_RCVLOWAT', 'SO_RCVTIMEO', 'SO_SNDLOWAT', 'SO_SNDTIMEO', 'SO_TYPE');
var
   i: integer;
begin
     result := '';
     for i:=0 to High(SockOpts) do
         if (SockOpts[i] = sockopt) then
         begin
              if result = '' then
                result := SockOptsS[i]
              else
                result := result + ' + ' + SockOptsS[i];
         end;
     if result = '' then
        result := '<no value>';
end;

function max(val1, val2: DWORD): DWORD;
begin
     result := val2;
     if val1 > val2 then
        result := val1;
end;

function IMAGE_SNAP_BY_ORDINAL(a: integer): Boolean;
begin
     result := ((a and IMAGE_ORDINAL_FLAG) <> 0);
end;

function MakePtr(base: Pointer; offset: DWORD): Pointer;
begin
     result := Pointer(DWORD(base) + DWORD(offset));
end;

{* Fucked ObjectPascal syntax that doesn't allow to access pointer as array, so
 * this function will help us.
 *}
function GetAsArray(a: PIMAGESECTIONHEADER; index: DWORD): PIMAGESECTIONHEADER;
begin
     result := PIMAGESECTIONHEADER(DWORD(a) + index * sizeof(TIMAGESECTIONHEADER));
end;


function GetWinVer(): string;
var
  PlatformId, VersionNumber: string;
  CSDVersion: String;
begin
  CSDVersion := '';

  // Detect platform
  case Win32Platform of
    // Test for the Windows 95 product family
    VER_PLATFORM_WIN32_WINDOWS:
    begin
      if Win32MajorVersion = 4 then
        case Win32MinorVersion of
          0:  if (Length(Win32CSDVersion) > 0) and
                 (Win32CSDVersion[1] in ['B', 'C']) then
                PlatformId := '95 OSR2'
              else
                PlatformId := '95';
          10: if (Length(Win32CSDVersion) > 0) and
                 (Win32CSDVersion[1] = 'A') then
                PlatformId := '98 SE'
              else
                PlatformId := '98';
          90: PlatformId := 'ME';
        end
      else
        PlatformId := '9x version (unknown)';
    end;
    // Test for the Windows NT product family
    VER_PLATFORM_WIN32_NT:
    begin
      if Length(Win32CSDVersion) > 0 then CSDVersion := Win32CSDVersion;
      if Win32MajorVersion <= 4 then
        PlatformId := 'NT'
      else
        if Win32MajorVersion = 5 then
          case Win32MinorVersion of
            0: PlatformId := '2000';
            1: PlatformId := 'XP';
            2: PlatformId := 'Server 2003';
          else
            PlatformId := 'Future Windows version (unknown)';
          end
        else
          PlatformId := 'Future Windows version (unknown)';
    end;
  end;
  VersionNumber := Format(' Version %d.%d Build %d %s', [Win32MajorVersion,
                                                        Win32MinorVersion,
                                                        Win32BuildNumber,
                                                        CSDVersion]);
  Result := 'Windows ' + PlatformId + VersionNumber;
end;


function IsLANAddr(IP: DWORD): Boolean;
var
   cidr_ip, cidr_mask, first_ip, last_ip : DWORD;
   s: string;
   i: integer;
begin
     for i := 0 to High(lanMasks) do
     begin
          s := lanMasks[i];
          if pos('/', s) <> 0 then
          begin
               cidr_ip := inet_addr(PChar(copy(s, 1, pos('/', s) - 1)));
               cidr_mask := StrToIntDef(copy(s, pos('/', s) + 1, MaxInt), 0);
               cidr_mask := DWORD((1 shl cidr_mask) - 1);
               first_ip := cidr_ip;
               last_ip := cidr_ip or (not cidr_mask);
               result := (ntohl(ip) >= ntohl(first_ip)) and (ntohl(ip) <= ntohl(last_ip));
          end
          else
              result := (ntohl(ip) = ntohl(inet_addr(PChar(s))));

          if result then exit;
     end;
end;

function GetNewGUID(): string;
var
   guid: TGUID;
   res_string: PChar;
begin
     UuidCreate(@guid);
     UuidToString(@guid, @res_string);
     result := res_string;
     RpcStringFree(@res_string);
end;

function encodeUrl(src: string): string;
var
   i: integer;
begin
     result := '';
     for i := 1 to Length(Src) do
        if (Src[i] in ['a'..'z','A'..'Z', '0'..'9']) then
          result := result + Src[i]
        else
          result := result + Format('%%%02x', [ord(Src[i])]);
end;


procedure SplitHtml(html: string; var Header, Body: string);
var
   HtmlDoc, Hdr, Bdy: TStringList;
   bisHeader: Boolean;
   i: integer;
begin
     HtmlDoc := TStringList.Create;
     Hdr := TStringList.Create;
     Bdy := TStringList.Create;

     HtmlDoc.Text := html;

     bisHeader := True;

     for i:=0 to HtmlDoc.Count - 1 do
     begin
          if (bisHeader) and (HtmlDoc[i] <> '') then
            Hdr.Add(HtmlDoc[i])
          else if (bisHeader) and (HtmlDoc[i] = '') then
              bisHeader := False
          else if (not bisHeader) and (HtmlDoc[i] <> '') then
              Bdy.Add(HtmlDoc[i]);
     end;

     Header := Hdr.Text;
     Body := Bdy.Text;

     HtmlDoc.Free;
     Hdr.Free;
     Bdy.Free;
end;


function GetModuleVersion(Filename: string): string;
var
   P: Pointer;
   sz: cardinal;
   DW: DWORD;
   PVerBuf: Pointer;
   buf: array[0..MAX_PATH * 2] of char;
   b: Boolean;
begin
     result:='';
     ZeroMemory(@Buf,SizeOf(Buf));
     lstrcat(@buf,PChar(UPPERCASE(FileName)));
     sz:=GetFileVersionInfoSize(@Buf,DW);
     if sz<>0 then
     begin
          GetMem(P,sz);
          if GetFileVersionInfo(@Buf,0,sz,P) then
          begin
               b:=VerQueryValue(P,'\\StringFileInfo\\040904e4\\FileVersion',PVerBuf,sz);
               if not b then
                  b:=VerQueryValue(P,'\\StringFileInfo\\041904e3\\FileVersion',PVerBuf,sz);
               if b then
               begin
                    ZeroMemory(@Buf,SizeOf(Buf));
                    lstrcat(@buf,PVerBuf);
               end;
               result:=String(Buf);
          end;
          FreeMem(P,sz);
     end;
end;



end.
