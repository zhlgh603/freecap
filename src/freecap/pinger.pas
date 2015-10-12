{
  $Id: pinger.pas,v 1.2 2005/02/15 11:21:21 bert Exp $

  $Log: pinger.pas,v $
  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}

unit Pinger;

interface
uses
  Windows, icmp, winsock2;

  function Ping(const host: string; PingTimeout: Integer = 500): DWORD;
  function PingStatusToStr (StatusCode: integer): string;

implementation

function ResolveIP(host: string): DWORD;
var
   HostEntry: PHostEnt;
   ph: PHostAddr;
begin
     result := inet_addr(PChar(host));
     if result <> INADDR_NONE then
        exit;

     result := 0;
     HostEntry := gethostbyname(PChar(host));
     if HostEntry = nil then
       exit;
     ph := PHostAddr(HostEntry^.h_addr_list^);
     if ph <> nil then
       result := Cardinal(ph^);
end;


function Ping(const host: string; PingTimeout: Integer = 500): DWORD;
var
  ICMPPort: THandle;
  PingReply: Ticmp_echo_reply;
  IPAddress: DWORD;
begin
     result := 9999;

     IPAddress := ResolveIP(host);
     if (IPAddress = 0) then
        exit;

     ICMPPort := IcmpCreateFile ();
     if (ICMPPort = INVALID_HANDLE_VALUE) then
       exit;

     IcmpSendEcho(ICMPPort, IPAddress,
          nil, 0, nil,
          @PingReply, SizeOf (PingReply), PingTimeout);


     if PingReply.Status = IP_SUCCESS then
       result := PingReply.RoundTripTime;
     IcmpCloseHandle (ICMPPort);
end;

function PingStatusToStr (StatusCode: integer): string;
begin
  case (StatusCode) of
    IP_SUCCESS: Result := 'IP_SUCCESS';
    IP_BUF_TOO_SMALL: Result := 'IP_BUF_TOO_SMALL';
    IP_DEST_NET_UNREACHABLE: Result := 'IP_DEST_NET_UNREACHABLE';
    IP_DEST_HOST_UNREACHABLE: Result := 'IP_DEST_HOST_UNREACHABLE';
    IP_DEST_PROT_UNREACHABLE: Result := 'IP_DEST_PROT_UNREACHABLE';
    IP_DEST_PORT_UNREACHABLE: Result := 'IP_DEST_PORT_UNREACHABLE';
    IP_NO_RESOURCES: Result := 'IP_NO_RESOURCES';
    IP_BAD_OPTION: Result := 'IP_BAD_OPTION';
    IP_HW_ERROR: Result := 'IP_HW_ERROR';
    IP_PACKET_TOO_BIG: Result := 'IP_PACKET_TOO_BIG';
    IP_REQ_TIMED_OUT: Result := 'IP_REQ_TIMED_OUT';
    IP_BAD_REQ: Result := 'IP_BAD_REQ';
    IP_BAD_ROUTE: Result := 'IP_BAD_ROUTE';
    IP_TTL_EXPIRED_TRANSIT: Result := 'IP_TTL_EXPIRED_TRANSIT';
    IP_TTL_EXPIRED_REASSEM: Result := 'IP_TTL_EXPIRED_REASSEM';
    IP_PARAM_PROBLEM: Result := 'IP_PARAM_PROBLEM';
    IP_SOURCE_QUENCH: Result := 'IP_SOURCE_QUENCH';
    IP_OPTION_TOO_BIG: Result := 'IP_OPTION_TOO_BIG';
    IP_BAD_DESTINATION: Result := 'IP_BAD_DESTINATION';
    IP_ADDR_DELETED: Result := 'IP_ADDR_DELETED';
    IP_SPEC_MTU_CHANGE: Result := 'IP_SPEC_MTU_CHANGE';
    IP_MTU_CHANGE: Result := 'IP_MTU_CHANGE';
    IP_UNLOAD: Result := 'IP_UNLOAD';
    IP_GENERAL_FAILURE: Result := 'IP_GENERAL_FAILURE';
  else
    Result := '';
  end;
end;


end.

