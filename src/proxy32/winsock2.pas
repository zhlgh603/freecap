//-------------------------------------------------------------
//
//       Borland Delphi Runtime Library
//       <API> interface unit
//
// Portions created by Microsoft are
// Copyright (C) 1995-1999 Microsoft Corporation.
// All Rights Reserved.
//
// The original file is: Winsock2.h from CBuilder5 distribution.
// The original Pascal code is: winsock2.pas, released 04 Mar 2000.
// The initial developer of the Pascal code is Alex Konshin
// (alexk@mtgroup.ru).
//
// Portions created by Alex Konshin are
// Copyright (C) 1998-2000 Alex Konshin
//
// Contributor(s): Alex Konshin
//
//       Obtained through:
//
//       Joint Endeavour of Delphi Innovators (Project JEDI)
//
// You may retrieve the latest version of this file at the Project
// JEDI home page, located at http://delphi-jedi.org
//
// The contents of this file are used with permission, subject to
// the Mozilla Public License Version 1.1 (the "License"); you may
// not use this file except in compliance with the License. You may
// obtain a copy of the License at
// http://www.mozilla.org/MPL/MPL-1.1.html
//
// Software distributed under the License is distributed on an
// "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
// implied. See the License for the specific language governing
// rights and limitations under the License.
//
//-------------------------------------------------------------


{	Winsock2.h -- definitions to be used with the WinSock 2 DLL and WinSock 2 applications.
 	This header file corresponds to version 2.2.x of the WinSock API specification.
 	This file includes parts which are Copyright (c) 1982-1986 Regents
	of the University of California. All rights reserved.
	The Berkeley Software License Agreement specifies the terms and
	conditions for redistribution. }

// converted by Alex Konshin, mailto:alexk@mtgroup.ru
// modified March,4 2000

unit WinSock2;

interface

uses SysUtils, Windows;

{$ALIGN OFF}
{$RANGECHECKS OFF}
{$WRITEABLECONST OFF}

//	Define the current Winsock version. To build an earlier Winsock version
//	application redefine this value prior to including Winsock2.h
const
     WINSOCK_VERSION = $0202;
     WINSOCK2_DLL = 'wsock32.dll';

type
    u_char  = Byte;
    u_short = Word;
    u_int   = DWORD;
    u_long  = DWORD;

//  The new type to be used in all instances which refer to sockets.
    TSocket = u_int;

    WSAEVENT = THandle;
    PWSAEVENT = ^WSAEVENT;
    LPWSAEVENT = PWSAEVENT;
{$IFDEF UNICODE}
    PMBChar = PWideChar;
{$ELSE}
    PMBChar = PChar;
{$ENDIF}

const
    FD_SETSIZE     =   64;

type
    PFDSet = ^TFDSet;
    TFDSet = packed record
       fd_count: u_int;
       fd_array: array[0..FD_SETSIZE-1] of TSocket;
    end;

    PTimeVal = ^TTimeVal;
    TTimeVal = packed record
       tv_sec: Longint;
       tv_usec: Longint;
    end;

const
  IOCPARM_MASK = $7f;
  IOC_VOID     = $20000000;
  IOC_OUT      = $40000000;
  IOC_IN       = $80000000;
  IOC_INOUT    = (IOC_IN or IOC_OUT);

// get # bytes to read
  FIONREAD     = IOC_OUT or (SizeOf(Longint) shl 16) or (Ord('f') shl 8) or 127;
// set/clear non-blocking i/o
  FIONBIO      = IOC_IN  or (SizeOf(Longint) shl 16) or (Ord('f') shl 8) or 126;
// set/clear async i/o
  FIOASYNC     = IOC_IN  or (SizeOf(Longint) shl 16) or (Ord('f') shl 8) or 125;

//	Socket I/O Controls

// set high watermark
  SIOCSHIWAT   = IOC_IN  or (SizeOf(Longint) shl 16) or (Ord('s') shl 8);
// get high watermark
  SIOCGHIWAT   = IOC_OUT or (SizeOf(Longint) shl 16) or (Ord('s') shl 8) or 1;
// set low watermark
  SIOCSLOWAT   = IOC_IN  or (SizeOf(Longint) shl 16) or (Ord('s') shl 8) or 2;
// get low watermark
  SIOCGLOWAT   = IOC_OUT or (SizeOf(Longint) shl 16) or (Ord('s') shl 8) or 3;
// at oob mark?
  SIOCATMARK   = IOC_OUT or (SizeOf(Longint) shl 16) or (Ord('s') shl 8) or 7;


//	Structures returned by network data base library, taken from the
//	BSD file netdb.h.  All addresses are supplied in host order, and
//	returned in network order (suitable for use in system calls).
type
  PHostEnt = ^THostEnt;
  THostEnt = packed record
    h_name: PChar;                 // official name of host
    h_aliases: ^PChar;             // alias list
    h_addrtype: Smallint;          // host address type
    h_length: Smallint;            // length of address
    case Byte of
    	0: (h_addr_list: ^PChar);    // list of addresses
    	1: (h_addr: ^PChar);         // address, for backward compat
  end;

  THostAddr = array[1..4] of byte;
  PHostAddr = ^THostAddr;

  LPINT = ^integer;

//	It is assumed here that a network number
//	fits in 32 bits.
  PNetEnt = ^TNetEnt;
  TNetEnt = packed record
    n_name: PChar;                 // official name of net
    n_aliases: ^PChar;             // alias list
    n_addrtype: Smallint;          // net address type
    n_net: u_long;                 // network #
  end;

  PServEnt = ^TServEnt;
  TServEnt = packed record
    s_name: PChar;                 // official service name
    s_aliases: ^PChar;             // alias list
    s_port: Smallint;              // protocol to use
    s_proto: PChar;                // port #
  end;

  PProtoEnt = ^TProtoEnt;
  TProtoEnt = packed record
    p_name: PChar;                 // official protocol name
    p_aliases: ^Pchar;             // alias list
    p_proto: Smallint;             // protocol #
  end;

  LPWSATHREADID = ^TWSATHREADID;
  TWSATHREADID = packed record
    ThreadHandle: THANDLE;
    Reserved: DWORD;
  end;

// Constants and structures defined by the internet system,
// Per RFC 790, September 1981, taken from the BSD file netinet/in.h.
const

// Protocols
  IPPROTO_IP     =   0;             // dummy for IP
  IPPROTO_ICMP   =   1;             // control message protocol
  IPPROTO_IGMP   =   2;             // group management protocol
  IPPROTO_GGP    =   3;             // gateway^2 (deprecated)
  IPPROTO_TCP    =   6;             // TCP
  IPPROTO_PUP    =  12;             // pup
  IPPROTO_UDP    =  17;             // UDP - user datagram protocol
  IPPROTO_IDP    =  22;             // xns idp
  IPPROTO_ND     =  77;             // UNOFFICIAL net disk proto

  IPPROTO_RAW    = 255;             // raw IP packet
  IPPROTO_MAX    = 256;

// Port/socket numbers: network standard functions
  IPPORT_ECHO        =   7;
  IPPORT_DISCARD     =   9;
  IPPORT_SYSTAT      =  11;
  IPPORT_DAYTIME     =  13;
  IPPORT_NETSTAT     =  15;
  IPPORT_FTP         =  21;
  IPPORT_TELNET      =  23;
  IPPORT_SMTP        =  25;
  IPPORT_TIMESERVER  =  37;
  IPPORT_NAMESERVER  =  42;
  IPPORT_WHOIS       =  43;
  IPPORT_MTP         =  57;

// Port/socket numbers: host specific functions
  IPPORT_TFTP        =  69;
  IPPORT_RJE         =  77;
  IPPORT_FINGER      =  79;
  IPPORT_TTYLINK     =  87;
  IPPORT_SUPDUP      =  95;

// UNIX TCP sockets
  IPPORT_EXECSERVER  = 512;
  IPPORT_LOGINSERVER = 513;
  IPPORT_CMDSERVER   = 514;
  IPPORT_EFSSERVER   = 520;

// UNIX UDP sockets
  IPPORT_BIFFUDP     = 512;
  IPPORT_WHOSERVER   = 513;
  IPPORT_ROUTESERVER = 520;

// Ports < IPPORT_RESERVED are reserved for  privileged processes (e.g. root).
  IPPORT_RESERVED    =1024;

// Link numbers
  IMPLINK_IP         = 155;
  IMPLINK_LOWEXPER   = 156;
  IMPLINK_HIGHEXPER  = 158;

  TF_DISCONNECT      = $01;
  TF_REUSE_SOCKET    = $02;
  TF_WRITE_BEHIND    = $04;

// This is used instead of -1, since the TSocket type is unsigned.
  INVALID_SOCKET		 = TSocket(not(0));
  SOCKET_ERROR			 = -1;

//	The  following  may  be used in place of the address family, socket type, or
//	protocol  in  a  call  to WSASocket to indicate that the corresponding value
//	should  be taken from the supplied WSAPROTOCOL_INFO structure instead of the
//	parameter itself.
	FROM_PROTOCOL_INFO = -1;


// Types
  SOCK_STREAM     = 1;               { stream socket }
  SOCK_DGRAM      = 2;               { datagram socket }
  SOCK_RAW        = 3;               { raw-protocol interface }
  SOCK_RDM        = 4;               { reliably-delivered message }
  SOCK_SEQPACKET  = 5;               { sequenced packet stream }

// Option flags per-socket.
  SO_DEBUG            = $0001;            // turn on debugging info recording
  SO_ACCEPTCONN       = $0002;            // socket has had listen()
  SO_REUSEADDR        = $0004;            // allow local address reuse
  SO_KEEPALIVE        = $0008;            // keep connections alive
  SO_DONTROUTE        = $0010;            // just use interface addresses
  SO_BROADCAST        = $0020;            // permit sending of broadcast msgs
  SO_USELOOPBACK      = $0040;            // bypass hardware when possible
  SO_LINGER           = $0080;            // linger on close if data present
  SO_OOBINLINE        = $0100;            // leave received OOB data in line

  SO_DONTLINGER       = not SO_LINGER;
	SO_EXCLUSIVEADDRUSE = not SO_REUSEADDR; // disallow local address reuse

// Additional options.

  SO_SNDBUF           = $1001;      // send buffer size
  SO_RCVBUF           = $1002;      // receive buffer size
  SO_SNDLOWAT         = $1003;      // send low-water mark
  SO_RCVLOWAT         = $1004;      // receive low-water mark
  SO_SNDTIMEO         = $1005;      // send timeout
  SO_RCVTIMEO         = $1006;      // receive timeout
  SO_ERROR            = $1007;      // get error status and clear
  SO_TYPE             = $1008;      // get socket type

// Options for connect and disconnect data and options.
// Used only by non-TCP/IP transports such as DECNet, OSI TP4, etc.
  SO_CONNDATA         = $7000;
  SO_CONNOPT          = $7001;
  SO_DISCDATA         = $7002;
  SO_DISCOPT          = $7003;
  SO_CONNDATALEN      = $7004;
  SO_CONNOPTLEN       = $7005;
  SO_DISCDATALEN      = $7006;
  SO_DISCOPTLEN       = $7007;

// Option for opening sockets for synchronous access.
  SO_OPENTYPE         = $7008;
  SO_SYNCHRONOUS_ALERT    = $10;
  SO_SYNCHRONOUS_NONALERT = $20;

// Other NT-specific options.
  SO_MAXDG                 = $7009;
  SO_MAXPATHDG             = $700A;
  SO_UPDATE_ACCEPT_CONTEXT = $700B;
  SO_CONNECT_TIME          = $700C;

  SOL_SOCKET               = $FFFF;

// TCP options.
  TCP_NODELAY              = $0001;
  TCP_BSDURGENT            = $7000;

// WinSock 2 extension -- new options
	SO_GROUP_ID              = $2001; // ID of a socket group
	SO_GROUP_PRIORITY        = $2002; // the relative priority within a group
	SO_MAX_MSG_SIZE          = $2003; // maximum message size
	SO_Protocol_InfoA        = $2004; // WSAPROTOCOL_INFOA structure
	SO_Protocol_InfoW        = $2005; // WSAPROTOCOL_INFOW structure
{$IFDEF UNICODE}
	SO_Protocol_Info         = SO_Protocol_InfoW;
{$ELSE}
	SO_Protocol_Info         = SO_Protocol_InfoA;
{$ENDIF}
	PVD_CONFIG               = $3001; // configuration info for service provider
	SO_CONDITIONAL_ACCEPT    = $3002; // enable true conditional accept:
                                    // connection is not ack-ed to the
                                    // other side until conditional
                                    // function returns CF_ACCEPT

// Address families.
  AF_UNSPEC       = 0;               // unspecified
  AF_UNIX         = 1;               // local to host (pipes, portals)
  AF_INET         = 2;               // internetwork: UDP, TCP, etc.
  AF_IMPLINK      = 3;               // arpanet imp addresses
  AF_PUP          = 4;               // pup protocols: e.g. BSP
  AF_CHAOS        = 5;               // mit CHAOS protocols
  AF_IPX          = 6;               // IPX and SPX
  AF_NS           = AF_IPX;          // XEROX NS protocols
  AF_ISO          = 7;               // ISO protocols
  AF_OSI          = AF_ISO;          // OSI is ISO
  AF_ECMA         = 8;               // european computer manufacturers
  AF_DATAKIT      = 9;               // datakit protocols
  AF_CCITT        = 10;              // CCITT protocols, X.25 etc
  AF_SNA          = 11;              // IBM SNA
  AF_DECnet       = 12;              // DECnet
  AF_DLI          = 13;              // Direct data link interface
  AF_LAT          = 14;              // LAT
  AF_HYLINK       = 15;              // NSC Hyperchannel
  AF_APPLETALK    = 16;              // AppleTalk
  AF_NETBIOS      = 17;              // NetBios-style addresses
  AF_VOICEVIEW    = 18;              // VoiceView
  AF_FIREFOX      = 19;              // FireFox
  AF_UNKNOWN1     = 20;              // Somebody is using this!
  AF_BAN          = 21;              // Banyan
  AF_ATM          = 22;              // Native ATM Services
  AF_INET6        = 23;              // Internetwork Version 6
  AF_CLUSTER      = 24;              // Microsoft Wolfpack
  AF_12844        = 25;              // IEEE 1284.4 WG AF
  AF_IRDA         = 26;              // IrDA
  AF_NETDES       = 28;              // Network Designers OSI & gateway enabled protocols

  AF_MAX          = 29;


// Protocol families, same as address families for now.

  PF_UNSPEC       = AF_UNSPEC;
  PF_UNIX         = AF_UNIX;
  PF_INET         = AF_INET;
  PF_IMPLINK      = AF_IMPLINK;
  PF_PUP          = AF_PUP;
  PF_CHAOS        = AF_CHAOS;
  PF_NS           = AF_NS;
  PF_IPX          = AF_IPX;
  PF_ISO          = AF_ISO;
  PF_OSI          = AF_OSI;
  PF_ECMA         = AF_ECMA;
  PF_DATAKIT      = AF_DATAKIT;
  PF_CCITT        = AF_CCITT;
  PF_SNA          = AF_SNA;
  PF_DECnet       = AF_DECnet;
  PF_DLI          = AF_DLI;
  PF_LAT          = AF_LAT;
  PF_HYLINK       = AF_HYLINK;
  PF_APPLETALK    = AF_APPLETALK;
  PF_VOICEVIEW    = AF_VOICEVIEW;
  PF_FIREFOX      = AF_FIREFOX;
  PF_UNKNOWN1     = AF_UNKNOWN1;
  PF_BAN          = AF_BAN;
	PF_ATM          = AF_ATM;
	PF_INET6        = AF_INET6;

  PF_MAX          = AF_MAX;

type

  SunB = packed record
    s_b1, s_b2, s_b3, s_b4: u_char;
  end;

  SunW = packed record
    s_w1, s_w2: u_short;
  end;

  TInAddr = packed record
    case integer of
      0: (S_un_b: SunB);
      1: (S_un_w: SunW);
      2: (S_addr: u_long);
  end;
	PInAddr = ^TInAddr;

  // Structure used by kernel to store most addresses.

  TSockAddrIn = packed record
    case Integer of
      0: (sin_family : u_short;
          sin_port   : u_short;
          sin_addr   : TInAddr;
          sin_zero   : array[0..7] of Char);
      1: (sa_family  : u_short;
          sa_data    : array[0..13] of Char)
  end;
  PSockAddrIn = ^TSockAddrIn;
  TSockAddr   = TSockAddrIn;
  PSockAddr   = ^TSockAddr;
	SOCKADDR    = TSockAddr;
	SOCKADDR_IN = TSockAddrIn;

  // Structure used by kernel to pass protocol information in raw sockets.
  PSockProto = ^TSockProto;
  TSockProto = packed record
    sp_family   : u_short;
    sp_protocol : u_short;
  end;

// Structure used for manipulating linger option.
  PLinger = ^TLinger;
  TLinger = packed record
    l_onoff: u_short;
    l_linger: u_short;
  end;

const
  INADDR_ANY       = $00000000;
  INADDR_LOOPBACK  = $7F000001;
  INADDR_BROADCAST = $FFFFFFFF;
  INADDR_NONE      = $FFFFFFFF;

	ADDR_ANY         = INADDR_ANY;

	MSG_OOB          = $1;             // process out-of-band data
  MSG_PEEK         = $2;             // peek at incoming message
  MSG_DONTROUTE    = $4;             // send without using routing tables

  MSG_PARTIAL      = $8000;          // partial send or recv for message xport

// WinSock 2 extension -- new flags for WSASend(), WSASendTo(), WSARecv() and WSARecvFrom()
	MSG_INTERRUPT    = $10;    // send/recv in the interrupt context
	MSG_MAXIOVLEN    = 16;


// Define constant based on rfc883, used by gethostbyxxxx() calls.

  MAXGETHOSTSTRUCT = 1024;

// Maximum queue length specifiable by listen.
  SOMAXCONN        = $7fffffff;

// WinSock 2 extension -- bit values and indices for FD_XXX network events
  FD_READ_BIT      = 0;
  FD_WRITE_BIT     = 1;
  FD_OOB_BIT       = 2;
  FD_ACCEPT_BIT    = 3;
  FD_CONNECT_BIT   = 4;
  FD_CLOSE_BIT     = 5;
  FD_QOS_BIT       = 6;
  FD_GROUP_QOS_BIT = 7;

  FD_MAX_EVENTS    = 8;

  FD_READ       = (1 shl FD_READ_BIT);
  FD_WRITE      = (1 shl FD_WRITE_BIT);
  FD_OOB        = (1 shl FD_OOB_BIT);
  FD_ACCEPT     = (1 shl FD_ACCEPT_BIT);
  FD_CONNECT    = (1 shl FD_CONNECT_BIT);
  FD_CLOSE      = (1 shl FD_CLOSE_BIT);
  FD_QOS        = (1 shl FD_QOS_BIT);
  FD_GROUP_QOS  = (1 shl FD_GROUP_QOS_BIT);

  FD_ALL_EVENTS = (1 shl FD_MAX_EVENTS) - 1;

// All Windows Sockets error constants are biased by WSABASEERR from the "normal"

  WSABASEERR              = 10000;

// Windows Sockets definitions of regular Microsoft C error constants

  WSAEINTR                = WSABASEERR+  4;
  WSAEBADF                = WSABASEERR+  9;
  WSAEACCES               = WSABASEERR+ 13;
  WSAEFAULT               = WSABASEERR+ 14;
  WSAEINVAL               = WSABASEERR+ 22;
  WSAEMFILE               = WSABASEERR+ 24;

// Windows Sockets definitions of regular Berkeley error constants

  WSAEWOULDBLOCK          = WSABASEERR+ 35;
  WSAEINPROGRESS          = WSABASEERR+ 36;
  WSAEALREADY             = WSABASEERR+ 37;
  WSAENOTSOCK             = WSABASEERR+ 38;
  WSAEDESTADDRREQ         = WSABASEERR+ 39;
  WSAEMSGSIZE             = WSABASEERR+ 40;
  WSAEPROTOTYPE           = WSABASEERR+ 41;
  WSAENOPROTOOPT          = WSABASEERR+ 42;
  WSAEPROTONOSUPPORT      = WSABASEERR+ 43;
  WSAESOCKTNOSUPPORT      = WSABASEERR+ 44;
  WSAEOPNOTSUPP           = WSABASEERR+ 45;
  WSAEPFNOSUPPORT         = WSABASEERR+ 46;
  WSAEAFNOSUPPORT         = WSABASEERR+ 47;
  WSAEADDRINUSE           = WSABASEERR+ 48;
  WSAEADDRNOTAVAIL        = WSABASEERR+ 49;
  WSAENETDOWN             = WSABASEERR+ 50;
  WSAENETUNREACH          = WSABASEERR+ 51;
  WSAENETRESET            = WSABASEERR+ 52;
  WSAECONNABORTED         = WSABASEERR+ 53;
  WSAECONNRESET           = WSABASEERR+ 54;
  WSAENOBUFS              = WSABASEERR+ 55;
  WSAEISCONN              = WSABASEERR+ 56;
  WSAENOTCONN             = WSABASEERR+ 57;
  WSAESHUTDOWN            = WSABASEERR+ 58;
  WSAETOOMANYREFS         = WSABASEERR+ 59;
  WSAETIMEDOUT            = WSABASEERR+ 60;
  WSAECONNREFUSED         = WSABASEERR+ 61;
  WSAELOOP                = WSABASEERR+ 62;
  WSAENAMETOOLONG         = WSABASEERR+ 63;
  WSAEHOSTDOWN            = WSABASEERR+ 64;
  WSAEHOSTUNREACH         = WSABASEERR+ 65;
  WSAENOTEMPTY            = WSABASEERR+ 66;
  WSAEPROCLIM             = WSABASEERR+ 67;
  WSAEUSERS               = WSABASEERR+ 68;
  WSAEDQUOT               = WSABASEERR+ 69;
  WSAESTALE               = WSABASEERR+ 70;
  WSAEREMOTE              = WSABASEERR+ 71;

// Extended Windows Sockets error constant definitions

  WSASYSNOTREADY          = WSABASEERR+ 91;
  WSAVERNOTSUPPORTED      = WSABASEERR+ 92;
  WSANOTINITIALISED       = WSABASEERR+ 93;
  WSAEDISCON              = WSABASEERR+101;
  WSAENOMORE              = WSABASEERR+102;
  WSAECANCELLED           = WSABASEERR+103;
  WSAEINVALIDPROCTABLE    = WSABASEERR+104;
  WSAEINVALIDPROVIDER     = WSABASEERR+105;
  WSAEPROVIDERFAILEDINIT  = WSABASEERR+106;
  WSASYSCALLFAILURE       = WSABASEERR+107;
  WSASERVICE_NOT_FOUND    = WSABASEERR+108;
  WSATYPE_NOT_FOUND       = WSABASEERR+109;
  WSA_E_NO_MORE           = WSABASEERR+110;
  WSA_E_CANCELLED         = WSABASEERR+111;
  WSAEREFUSED             = WSABASEERR+112;


{ Error return codes from gethostbyname() and gethostbyaddr()
  (when using the resolver). Note that these errors are
  retrieved via WSAGetLastError() and must therefore follow
  the rules for avoiding clashes with error numbers from
  specific implementations or language run-time systems.
  For this reason the codes are based at WSABASEERR+1001.
  Note also that [WSA]NO_ADDRESS is defined only for
  compatibility purposes. }

// Authoritative Answer: Host not found
  WSAHOST_NOT_FOUND        = WSABASEERR+1001;
  HOST_NOT_FOUND           = WSAHOST_NOT_FOUND;

// Non-Authoritative: Host not found, or SERVERFAIL
  WSATRY_AGAIN             = WSABASEERR+1002;
  TRY_AGAIN                = WSATRY_AGAIN;

// Non recoverable errors, FORMERR, REFUSED, NOTIMP
  WSANO_RECOVERY           = WSABASEERR+1003;
  NO_RECOVERY              = WSANO_RECOVERY;

// Valid name, no data record of requested type
  WSANO_DATA               = WSABASEERR+1004;
  NO_DATA                  = WSANO_DATA;

// no address, look for MX record
  WSANO_ADDRESS            = WSANO_DATA;
  NO_ADDRESS               = WSANO_ADDRESS;

// Define QOS related error return codes

  WSA_QOS_RECEIVERS          = WSABASEERR+1005; // at least one Reserve has arrived
  WSA_QOS_SENDERS            = WSABASEERR+1006; // at least one Path has arrived
  WSA_QOS_NO_SENDERS         = WSABASEERR+1007; // there are no senders
  WSA_QOS_NO_RECEIVERS       = WSABASEERR+1008; // there are no receivers
  WSA_QOS_REQUEST_CONFIRMED  = WSABASEERR+1009; // Reserve has been confirmed
  WSA_QOS_ADMISSION_FAILURE  = WSABASEERR+1010; // error due to lack of resources
  WSA_QOS_POLICY_FAILURE     = WSABASEERR+1011; // rejected for administrative reasons - bad credentials
  WSA_QOS_BAD_STYLE          = WSABASEERR+1012; // unknown or conflicting style
  WSA_QOS_BAD_OBJECT         = WSABASEERR+1013; // problem with some part of the filterspec or providerspecific buffer in general
  WSA_QOS_TRAFFIC_CTRL_ERROR = WSABASEERR+1014; // problem with some part of the flowspec
  WSA_QOS_GENERIC_ERROR      = WSABASEERR+1015; // general error
  WSA_QOS_ESERVICETYPE       = WSABASEERR+1016; // invalid service type in flowspec
  WSA_QOS_EFLOWSPEC          = WSABASEERR+1017; // invalid flowspec
  WSA_QOS_EPROVSPECBUF       = WSABASEERR+1018; // invalid provider specific buffer
  WSA_QOS_EFILTERSTYLE       = WSABASEERR+1019; // invalid filter style
  WSA_QOS_EFILTERTYPE        = WSABASEERR+1020; // invalid filter type
  WSA_QOS_EFILTERCOUNT       = WSABASEERR+1021; // incorrect number of filters
  WSA_QOS_EOBJLENGTH         = WSABASEERR+1022; // invalid object length
  WSA_QOS_EFLOWCOUNT         = WSABASEERR+1023; // incorrect number of flows
  WSA_QOS_EUNKOWNPSOBJ       = WSABASEERR+1024; // unknown object in provider specific buffer
  WSA_QOS_EPOLICYOBJ         = WSABASEERR+1025; // invalid policy object in provider specific buffer
  WSA_QOS_EFLOWDESC          = WSABASEERR+1026; // invalid flow descriptor in the list
  WSA_QOS_EPSFLOWSPEC        = WSABASEERR+1027; // inconsistent flow spec in provider specific buffer
  WSA_QOS_EPSFILTERSPEC      = WSABASEERR+1028; // invalid filter spec in provider specific buffer
  WSA_QOS_ESDMODEOBJ         = WSABASEERR+1029; // invalid shape discard mode object in provider specific buffer
  WSA_QOS_ESHAPERATEOBJ      = WSABASEERR+1030; // invalid shaping rate object in provider specific buffer
  WSA_QOS_RESERVED_PETYPE    = WSABASEERR+1031; // reserved policy element in provider specific buffer

{ WinSock 2 extension -- new error codes and type definition }
  WSA_IO_PENDING          = ERROR_IO_PENDING;
  WSA_IO_INCOMPLETE       = ERROR_IO_INCOMPLETE;
  WSA_INVALID_HANDLE      = ERROR_INVALID_HANDLE;
  WSA_INVALID_PARAMETER   = ERROR_INVALID_PARAMETER;
  WSA_NOT_ENOUGH_MEMORY   = ERROR_NOT_ENOUGH_MEMORY;
  WSA_OPERATION_ABORTED   = ERROR_OPERATION_ABORTED;
  WSA_INVALID_EVENT       = WSAEVENT(nil);
  WSA_MAXIMUM_WAIT_EVENTS = MAXIMUM_WAIT_OBJECTS;
  WSA_WAIT_FAILED         = $ffffffff;
  WSA_WAIT_EVENT_0        = WAIT_OBJECT_0;
  WSA_WAIT_IO_COMPLETION  = WAIT_IO_COMPLETION;
  WSA_WAIT_TIMEOUT        = WAIT_TIMEOUT;
  WSA_INFINITE            = INFINITE;

{ Windows Sockets errors redefined as regular Berkeley error constants.
  These are commented out in Windows NT to avoid conflicts with errno.h.
  Use the WSA constants instead. }

  EWOULDBLOCK        =  WSAEWOULDBLOCK;
  EINPROGRESS        =  WSAEINPROGRESS;
  EALREADY           =  WSAEALREADY;
  ENOTSOCK           =  WSAENOTSOCK;
  EDESTADDRREQ       =  WSAEDESTADDRREQ;
  EMSGSIZE           =  WSAEMSGSIZE;
  EPROTOTYPE         =  WSAEPROTOTYPE;
  ENOPROTOOPT        =  WSAENOPROTOOPT;
  EPROTONOSUPPORT    =  WSAEPROTONOSUPPORT;
  ESOCKTNOSUPPORT    =  WSAESOCKTNOSUPPORT;
  EOPNOTSUPP         =  WSAEOPNOTSUPP;
  EPFNOSUPPORT       =  WSAEPFNOSUPPORT;
  EAFNOSUPPORT       =  WSAEAFNOSUPPORT;
  EADDRINUSE         =  WSAEADDRINUSE;
  EADDRNOTAVAIL      =  WSAEADDRNOTAVAIL;
  ENETDOWN           =  WSAENETDOWN;
  ENETUNREACH        =  WSAENETUNREACH;
  ENETRESET          =  WSAENETRESET;
  ECONNABORTED       =  WSAECONNABORTED;
  ECONNRESET         =  WSAECONNRESET;
  ENOBUFS            =  WSAENOBUFS;
  EISCONN            =  WSAEISCONN;
  ENOTCONN           =  WSAENOTCONN;
  ESHUTDOWN          =  WSAESHUTDOWN;
  ETOOMANYREFS       =  WSAETOOMANYREFS;
  ETIMEDOUT          =  WSAETIMEDOUT;
  ECONNREFUSED       =  WSAECONNREFUSED;
  ELOOP              =  WSAELOOP;
  ENAMETOOLONG       =  WSAENAMETOOLONG;
  EHOSTDOWN          =  WSAEHOSTDOWN;
  EHOSTUNREACH       =  WSAEHOSTUNREACH;
  ENOTEMPTY          =  WSAENOTEMPTY;
  EPROCLIM           =  WSAEPROCLIM;
  EUSERS             =  WSAEUSERS;
  EDQUOT             =  WSAEDQUOT;
  ESTALE             =  WSAESTALE;
  EREMOTE            =  WSAEREMOTE;


  WSADESCRIPTION_LEN     =   256;
  WSASYS_STATUS_LEN      =   128;

type
  PWSAData = ^TWSAData;
  TWSAData = packed record
    wVersion       : Word;
    wHighVersion   : Word;
    szDescription  : Array[0..WSADESCRIPTION_LEN] of Char;
    szSystemStatus : Array[0..WSASYS_STATUS_LEN] of Char;
    iMaxSockets    : Word;
    iMaxUdpDg      : Word;
    lpVendorInfo   : PChar;
  end;

{	WSAOVERLAPPED = Record
		Internal: LongInt;
		InternalHigh: LongInt;
		Offset: LongInt;
		OffsetHigh: LongInt;
		hEvent: WSAEVENT;
	end;}
  WSAOVERLAPPED   = TOverlapped;
  TWSAOverlapped  = WSAOverlapped;
  PWSAOverlapped  = ^WSAOverlapped;
  LPWSAOVERLAPPED = PWSAOverlapped;

{	WinSock 2 extension -- WSABUF and QOS struct, include qos.h }
{ to pull in FLOWSPEC and related definitions }


  WSABUF = packed record
  	len: U_LONG;	{ the length of the buffer }
  	buf: PChar;	{ the pointer to the buffer }
  end {WSABUF};
  PWSABUF = ^WSABUF;
  LPWSABUF = array [0..0] of PWSABUF;

  TServiceType = LongInt;

  TFlowSpec = packed record
  	TokenRate,               // In Bytes/sec
  	TokenBucketSize,         // In Bytes
  	PeakBandwidth,           // In Bytes/sec
  	Latency,                 // In microseconds
  	DelayVariation : LongInt;// In microseconds
  	ServiceType : TServiceType;
  	MaxSduSize,	MinimumPolicedSize : LongInt;// In Bytes
  end;
  PFlowSpec = ^PFLOWSPEC;

  QOS = packed record
  	SendingFlowspec: TFlowSpec;	{ the flow spec for data sending }
  	ReceivingFlowspec: TFlowSpec;	{ the flow spec for data receiving }
  	ProviderSpecific: WSABUF; { additional provider specific stuff }
  end;
  TQualityOfService = QOS;
  PQOS = ^QOS;
  LPQOS = PQOS;

const
  SERVICETYPE_NOTRAFFIC             =  $00000000;  // No data in this direction
  SERVICETYPE_BESTEFFORT            =  $00000001;  // Best Effort
  SERVICETYPE_CONTROLLEDLOAD        =  $00000002;  // Controlled Load
  SERVICETYPE_GUARANTEED            =  $00000003;  // Guaranteed
  SERVICETYPE_NETWORK_UNAVAILABLE   =  $00000004;  // Used to notify change to user
  SERVICETYPE_GENERAL_INFORMATION   =  $00000005;  // corresponds to "General Parameters" defined by IntServ
  SERVICETYPE_NOCHANGE              =  $00000006;  // used to indicate that the flow spec contains no change from any previous one
// to turn on immediate traffic control, OR this flag with the ServiceType field in teh FLOWSPEC
  SERVICE_IMMEDIATE_TRAFFIC_CONTROL =  $80000000;

//	WinSock 2 extension -- manifest constants for return values of the condition function
  CF_ACCEPT = $0000;
  CF_REJECT = $0001;
  CF_DEFER  = $0002;

//	WinSock 2 extension -- manifest constants for shutdown()
  SD_RECEIVE = $00;
  SD_SEND    = $01;
  SD_BOTH    = $02;

// WinSock 2 extension -- data type and manifest constants for socket groups
  SG_UNCONSTRAINED_GROUP = $01;
  SG_CONSTRAINED_GROUP   = $02;

type
  GROUP = DWORD;

// WinSock 2 extension -- data type for WSAEnumNetworkEvents()
   TWSANetworkEvents = record
   	lNetworkEvents: LongInt;
   	iErrorCode: Array[0..FD_MAX_EVENTS-1] of Integer;
   end;
   PWSANetworkEvents = ^TWSANetworkEvents;
   LPWSANetworkEvents = PWSANetworkEvents;

// WinSock 2 extension -- WSAPROTOCOL_INFO structure

{$ifndef ver130}
   TGUID = packed record
   	D1: LongInt;
   	D2: Word;
   	D3: Word;
   	D4: Array[0..7] of Byte;
   end;
   PGUID = ^TGUID;
{$endif}
   LPGUID = PGUID;

//	WinSock 2 extension -- WSAPROTOCOL_INFO manifest constants
const
   MAX_PROTOCOL_CHAIN = 7;
   BASE_PROTOCOL      = 1;
   LAYERED_PROTOCOL   = 0;
   WSAPROTOCOL_LEN    = 255;

type
   TWSAProtocolChain = record
   	ChainLen: Integer;	// the length of the chain,
   	// length = 0 means layered protocol,
   	// length = 1 means base protocol,
   	// length > 1 means protocol chain
   	ChainEntries: Array[0..MAX_PROTOCOL_CHAIN-1] of LongInt; // a list of dwCatalogEntryIds
   end;

type
   TWSAProtocol_InfoA = record
   	dwServiceFlags1: LongInt;
   	dwServiceFlags2: LongInt;
   	dwServiceFlags3: LongInt;
   	dwServiceFlags4: LongInt;
   	dwProviderFlags: LongInt;
   	ProviderId: TGUID;
   	dwCatalogEntryId: LongInt;
   	ProtocolChain: TWSAProtocolChain;
   	iVersion: Integer;
   	iAddressFamily: Integer;
   	iMaxSockAddr: Integer;
   	iMinSockAddr: Integer;
   	iSocketType: Integer;
   	iProtocol: Integer;
   	iProtocolMaxOffset: Integer;
   	iNetworkByteOrder: Integer;
   	iSecurityScheme: Integer;
   	dwMessageSize: LongInt;
   	dwProviderReserved: LongInt;
   	szProtocol: Array[0..WSAPROTOCOL_LEN+1-1] of Char;
   end {TWSAProtocol_InfoA};
   PWSAProtocol_InfoA = ^TWSAProtocol_InfoA;
   LPWSAProtocol_InfoA = PWSAProtocol_InfoA;

   TWSAProtocol_InfoW = record
   	dwServiceFlags1: LongInt;
   	dwServiceFlags2: LongInt;
   	dwServiceFlags3: LongInt;
   	dwServiceFlags4: LongInt;
   	dwProviderFlags: LongInt;
   	ProviderId: TGUID;
   	dwCatalogEntryId: LongInt;
   	ProtocolChain: TWSAProtocolChain;
   	iVersion: Integer;
   	iAddressFamily: Integer;
   	iMaxSockAddr: Integer;
   	iMinSockAddr: Integer;
   	iSocketType: Integer;
   	iProtocol: Integer;
   	iProtocolMaxOffset: Integer;
   	iNetworkByteOrder: Integer;
   	iSecurityScheme: Integer;
   	dwMessageSize: LongInt;
   	dwProviderReserved: LongInt;
   	szProtocol: Array[0..WSAPROTOCOL_LEN+1-1] of WideChar;
   end {TWSAProtocol_InfoW};
   PWSAProtocol_InfoW = ^TWSAProtocol_InfoW;
   LPWSAProtocol_InfoW = PWSAProtocol_InfoW;

{$IFDEF UNICODE}
   WSAProtocol_Info = TWSAProtocol_InfoW;
   TWSAProtocol_Info = TWSAProtocol_InfoW;
   PWSAProtocol_Info = PWSAProtocol_InfoW;
   LPWSAProtocol_Info = PWSAProtocol_InfoW;
{$ELSE}
   WSAProtocol_Info = TWSAProtocol_InfoA;
   TWSAProtocol_Info = TWSAProtocol_InfoA;
   PWSAProtocol_Info = PWSAProtocol_InfoA;
   LPWSAProtocol_Info = PWSAProtocol_InfoA;
{$ENDIF}

const
//	Flag bit definitions for dwProviderFlags
   PFL_MULTIPLE_PROTO_ENTRIES   = $00000001;
   PFL_RECOMMENDED_PROTO_ENTRY  = $00000002;
   PFL_HIDDEN                   = $00000004;
   PFL_MATCHES_PROTOCOL_ZERO    = $00000008;

//	Flag bit definitions for dwServiceFlags1
   XP1_CONNECTIONLESS           = $00000001;
   XP1_GUARANTEED_DELIVERY      = $00000002;
   XP1_GUARANTEED_ORDER         = $00000004;
   XP1_MESSAGE_ORIENTED         = $00000008;
   XP1_PSEUDO_STREAM            = $00000010;
   XP1_GRACEFUL_CLOSE           = $00000020;
   XP1_EXPEDITED_DATA           = $00000040;
   XP1_CONNECT_DATA             = $00000080;
   XP1_DISCONNECT_DATA          = $00000100;
   XP1_SUPPORT_BROADCAST        = $00000200;
   XP1_SUPPORT_MULTIPOINT       = $00000400;
   XP1_MULTIPOINT_CONTROL_PLANE = $00000800;
   XP1_MULTIPOINT_DATA_PLANE    = $00001000;
   XP1_QOS_SUPPORTED            = $00002000;
   XP1_INTERRUPT                = $00004000;
   XP1_UNI_SEND                 = $00008000;
   XP1_UNI_RECV                 = $00010000;
   XP1_IFS_HANDLES              = $00020000;
   XP1_PARTIAL_MESSAGE          = $00040000;

   BIGENDIAN    = $0000;
   LITTLEENDIAN = $0001;

   SECURITY_PROTOCOL_NONE = $0000;

// WinSock 2 extension -- manifest constants for WSAJoinLeaf()
   JL_SENDER_ONLY   = $01;
   JL_RECEIVER_ONLY = $02;
   JL_BOTH          = $04;
// WinSock 2 extension -- manifest constants for WSASocket()
   WSA_FLAG_OVERLAPPED        = $01;
   WSA_FLAG_MULTIPOINT_C_ROOT = $02;
   WSA_FLAG_MULTIPOINT_C_LEAF = $04;
   WSA_FLAG_MULTIPOINT_D_ROOT = $08;
   WSA_FLAG_MULTIPOINT_D_LEAF = $10;

//	WinSock 2 extension -- manifest constants for WSAIoctl()
   IOC_UNIX      = $00000000;
   IOC_WS2       = $08000000;
   IOC_PROTOCOL  = $10000000;
   IOC_VENDOR    = $18000000;

   SIO_ASSOCIATE_HANDLE                =  1 or IOC_WS2 or IOC_IN;
   SIO_ENABLE_CIRCULAR_QUEUEING        =  2 or IOC_WS2;
   SIO_FIND_ROUTE                      =  3 or IOC_WS2 or IOC_OUT;
   SIO_FLUSH                           =  4 or IOC_WS2;
   SIO_GET_BROADCAST_ADDRESS           =  5 or IOC_WS2 or IOC_OUT;
   SIO_GET_EXTENSION_FUNCTION_POINTER  =  6 or IOC_WS2 or IOC_INOUT;
   SIO_GET_QOS                         =  7 or IOC_WS2 or IOC_INOUT;
   SIO_GET_GROUP_QOS                   =  8 or IOC_WS2 or IOC_INOUT;
   SIO_MULTIPOINT_LOOPBACK             =  9 or IOC_WS2 or IOC_IN;
   SIO_MULTICAST_SCOPE                 = 10 or IOC_WS2 or IOC_IN;
   SIO_SET_QOS                         = 11 or IOC_WS2 or IOC_IN;
   SIO_SET_GROUP_QOS                   = 12 or IOC_WS2 or IOC_IN;
   SIO_TRANSLATE_HANDLE                = 13 or IOC_WS2 or IOC_INOUT;
   SIO_ROUTING_INTERFACE_QUERY         = 20 or IOC_WS2 or IOC_INOUT;
   SIO_ROUTING_INTERFACE_CHANGE        = 21 or IOC_WS2 or IOC_IN;
   SIO_ADDRESS_LIST_QUERY              = 22 or IOC_WS2 or IOC_OUT; // see below SOCKET_ADDRESS_LIST
   SIO_ADDRESS_LIST_CHANGE             = 23 or IOC_WS2;
   SIO_QUERY_TARGET_PNP_HANDLE         = 24 or IOC_WS2 or IOC_OUT;

// WinSock 2 extension -- manifest constants for SIO_TRANSLATE_HANDLE ioctl
   TH_NETDEV = $00000001;
   TH_TAPI   = $00000002;

type

// Manifest constants and type definitions related to name resolution and
// registration (RNR) API
   TBLOB = packed record
   	cbSize : U_LONG;
   	pBlobData : PBYTE;
   end;
   PBLOB = ^TBLOB;

// Service Install Flags

const
   SERVICE_MULTIPLE = $00000001;

// & Name Spaces
   NS_ALL         =  0;

   NS_SAP         =  1;
   NS_NDS         =  2;
   NS_PEER_BROWSE =  3;

   NS_TCPIP_LOCAL = 10;
   NS_TCPIP_HOSTS = 11;
   NS_DNS         = 12;
   NS_NETBT       = 13;
   NS_WINS        = 14;

   NS_NBP         = 20;

   NS_MS          = 30;
   NS_STDA        = 31;
   NS_NTDS        = 32;

   NS_X500        = 40;
   NS_NIS         = 41;
   NS_NISPLUS     = 42;

   NS_WRQ         = 50;

   NS_NETDES      = 60;

{ Resolution flags for WSAGetAddressByName().
  Note these are also used by the 1.1 API GetAddressByName, so leave them around.
}
  RES_UNUSED_1    = $00000001;
  RES_FLUSH_CACHE = $00000002;
  RES_SERVICE     = $00000004;

{ Well known value names for Service Types }
  SERVICE_TYPE_VALUE_IPXPORTA              = 'IpxSocket';
  SERVICE_TYPE_VALUE_IPXPORTW : PWideChar  = 'IpxSocket';
  SERVICE_TYPE_VALUE_SAPIDA                = 'SapId';
  SERVICE_TYPE_VALUE_SAPIDW : PWideChar    = 'SapId';

  SERVICE_TYPE_VALUE_TCPPORTA              = 'TcpPort';
  SERVICE_TYPE_VALUE_TCPPORTW : PWideChar  = 'TcpPort';

  SERVICE_TYPE_VALUE_UDPPORTA              = 'UdpPort';
  SERVICE_TYPE_VALUE_UDPPORTW : PWideChar  = 'UdpPort';

  SERVICE_TYPE_VALUE_OBJECTIDA             = 'ObjectId';
  SERVICE_TYPE_VALUE_OBJECTIDW : PWideChar = 'ObjectId';

{$IFDEF UNICODE}
  SERVICE_TYPE_VALUE_SAPID    = SERVICE_TYPE_VALUE_SAPIDW;
  SERVICE_TYPE_VALUE_TCPPORT  = SERVICE_TYPE_VALUE_TCPPORTW;
  SERVICE_TYPE_VALUE_UDPPORT  = SERVICE_TYPE_VALUE_UDPPORTW;
  SERVICE_TYPE_VALUE_OBJECTID = SERVICE_TYPE_VALUE_OBJECTIDW;
{$ELSE}
  SERVICE_TYPE_VALUE_SAPID    = SERVICE_TYPE_VALUE_SAPIDA;
  SERVICE_TYPE_VALUE_TCPPORT  = SERVICE_TYPE_VALUE_TCPPORTA;
  SERVICE_TYPE_VALUE_UDPPORT  = SERVICE_TYPE_VALUE_UDPPORTA;
  SERVICE_TYPE_VALUE_OBJECTID = SERVICE_TYPE_VALUE_OBJECTIDA;
{$ENDIF}

// SockAddr Information
type
  SOCKET_ADDRESS = packed record
  	lpSockaddr : PSockAddr;
  	iSockaddrLength : Integer;
  end;
  PSOCKET_ADDRESS = ^SOCKET_ADDRESS;

// CSAddr Information
  CSADDR_INFO = packed record
  	LocalAddr, RemoteAddr  : SOCKET_ADDRESS;
  	iSocketType, iProtocol : LongInt;
  end;
  PCSADDR_INFO = ^CSADDR_INFO;
  LPCSADDR_INFO = ^CSADDR_INFO;

// Address list returned via WSAIoctl( SIO_ADDRESS_LIST_QUERY )
  SOCKET_ADDRESS_LIST = packed record
  	iAddressCount : Integer;
  	Address       : Array [0..0] of SOCKET_ADDRESS;
  end;
  LPSOCKET_ADDRESS_LIST = ^SOCKET_ADDRESS_LIST;

// Address Family/Protocol Tuples
  AFProtocols = record
        iAddressFamily : Integer;
        iProtocol      : Integer;
  end;
  TAFProtocols = AFProtocols;
  PAFProtocols = ^TAFProtocols;

// Client Query API Typedefs

// The comparators
  TWSAEComparator = (COMP_EQUAL {= 0}, COMP_NOTLESS );

  TWSAVersion = record
        dwVersion : DWORD;
        ecHow     : TWSAEComparator;
  end;
  PWSAVersion = ^TWSAVersion;

  TWSAQuerySetA = packed record
  	dwSize                  : DWORD;
  	lpszServiceInstanceName : PChar;
  	lpServiceClassId        : PGUID;
  	lpVersion               : PWSAVERSION;
  	lpszComment             : PChar;
  	dwNameSpace             : DWORD;
  	lpNSProviderId          : PGUID;
  	lpszContext             : PChar;
  	dwNumberOfProtocols     : DWORD;
  	lpafpProtocols          : PAFProtocols;
  	lpszQueryString         : PChar;
  	dwNumberOfCsAddrs       : DWORD;
  	lpcsaBuffer             : PCSADDR_INFO;
  	dwOutputFlags           : DWORD;
  	lpBlob                  : PBLOB;
  end;
  PWSAQuerySetA = ^TWSAQuerySetA;
  LPWSAQuerySetA = PWSAQuerySetA;

  TWSAQuerySetW = packed record
  	dwSize                  : DWORD;
  	lpszServiceInstanceName : PWideChar;
  	lpServiceClassId        : PGUID;
  	lpVersion               : PWSAVERSION;
  	lpszComment             : PWideChar;
  	dwNameSpace             : DWORD;
  	lpNSProviderId          : PGUID;
  	lpszContext             : PWideChar;
  	dwNumberOfProtocols     : DWORD;
  	lpafpProtocols          : PAFProtocols;
  	lpszQueryString         : PWideChar;
  	dwNumberOfCsAddrs       : DWORD;
  	lpcsaBuffer             : PCSADDR_INFO;
  	dwOutputFlags           : DWORD;
  	lpBlob                  : PBLOB;
  end;
  PWSAQuerySetW = ^TWSAQuerySetW;
  LPWSAQuerySetW = PWSAQuerySetW;

{$IFDEF UNICODE}
  TWSAQuerySet  = TWSAQuerySetA;
  PWSAQuerySet  = PWSAQuerySetW;
  LPWSAQuerySet = PWSAQuerySetW;
{$ELSE}
  TWSAQuerySet  = TWSAQuerySetA;
  PWSAQuerySet  = PWSAQuerySetA;
  LPWSAQuerySet = PWSAQuerySetA;
{$ENDIF}


  PTransmitFileBuffers = ^TTransmitFileBuffers;
  {$EXTERNALSYM _TRANSMIT_FILE_BUFFERS}
  _TRANSMIT_FILE_BUFFERS = record
      Head: Pointer;
      HeadLength: DWORD;
      Tail: Pointer;
      TailLength: DWORD;
  end;
  TTransmitFileBuffers = _TRANSMIT_FILE_BUFFERS;
  {$EXTERNALSYM TRANSMIT_FILE_BUFFERS}
  TRANSMIT_FILE_BUFFERS = _TRANSMIT_FILE_BUFFERS;


const
  LUP_DEEP                = $0001;
  LUP_CONTAINERS          = $0002;
  LUP_NOCONTAINERS        = $0004;
  LUP_NEAREST             = $0008;
  LUP_RETURN_NAME         = $0010;
  LUP_RETURN_TYPE         = $0020;
  LUP_RETURN_VERSION      = $0040;
  LUP_RETURN_COMMENT      = $0080;
  LUP_RETURN_ADDR         = $0100;
  LUP_RETURN_BLOB         = $0200;
  LUP_RETURN_ALIASES      = $0400;
  LUP_RETURN_QUERY_STRING = $0800;
  LUP_RETURN_ALL          = $0FF0;
  LUP_RES_SERVICE         = $8000;

  LUP_FLUSHCACHE          = $1000;
  LUP_FLUSHPREVIOUS       = $2000;

// Return flags
  RESULT_IS_ALIAS = $0001;

type
// Service Address Registration and Deregistration Data Types.
  TWSAeSetServiceOp = ( RNRSERVICE_REGISTER{=0}, RNRSERVICE_DEREGISTER, RNRSERVICE_DELETE );

{ Service Installation/Removal Data Types. }
  TWSANSClassInfoA = packed record
  	lpszName    : PChar;
  	dwNameSpace : DWORD;
  	dwValueType : DWORD;
  	dwValueSize : DWORD;
  	lpValue     : Pointer;
  end;
  PWSANSClassInfoA = ^TWSANSClassInfoA;

  TWSANSClassInfoW = packed record
  	lpszName    : PWideChar;
  	dwNameSpace : DWORD;
  	dwValueType : DWORD;
  	dwValueSize : DWORD;
  	lpValue     : Pointer;
  end {TWSANSClassInfoW};
  PWSANSClassInfoW = ^TWSANSClassInfoW;

{$IFDEF UNICODE}
  WSANSClassInfo   = TWSANSClassInfoW;
  TWSANSClassInfo  = TWSANSClassInfoW;
  PWSANSClassInfo  = PWSANSClassInfoW;
  LPWSANSClassInfo = PWSANSClassInfoW;
{$ELSE}
  WSANSClassInfo   = TWSANSClassInfoA;
  TWSANSClassInfo  = TWSANSClassInfoA;
  PWSANSClassInfo  = PWSANSClassInfoA;
  LPWSANSClassInfo = PWSANSClassInfoA;
{$ENDIF // UNICODE}

  TWSAServiceClassInfoA = packed record
        lpServiceClassId     : PGUID;
  	lpszServiceClassName : PChar;
  	dwCount              : DWORD;
  	lpClassInfos         : PWSANSClassInfoA;
  end;
  PWSAServiceClassInfoA  = ^TWSAServiceClassInfoA;
  LPWSAServiceClassInfoA = PWSAServiceClassInfoA;

  TWSAServiceClassInfoW = packed record
  	lpServiceClassId     : PGUID;
  	lpszServiceClassName : PWideChar;
  	dwCount              : DWORD;
  	lpClassInfos         : PWSANSClassInfoW;
  end;
  PWSAServiceClassInfoW  = ^TWSAServiceClassInfoW;
  LPWSAServiceClassInfoW = PWSAServiceClassInfoW;

{$IFDEF UNICODE}
  WSAServiceClassInfo   = TWSAServiceClassInfoW;
  TWSAServiceClassInfo  = TWSAServiceClassInfoW;
  PWSAServiceClassInfo  = PWSAServiceClassInfoW;
  LPWSAServiceClassInfo = PWSAServiceClassInfoW;
{$ELSE}
  WSAServiceClassInfo   = TWSAServiceClassInfoA;
  TWSAServiceClassInfo  = TWSAServiceClassInfoA;
  PWSAServiceClassInfo  = PWSAServiceClassInfoA;
  LPWSAServiceClassInfo = PWSAServiceClassInfoA;
{$ENDIF}

  TWSANameSpace_InfoA = packed record
  	NSProviderId   : TGUID;
  	dwNameSpace    : DWORD;
  	fActive        : DWORD{Bool};
  	dwVersion      : DWORD;
  	lpszIdentifier : PChar;
  end;
  PWSANameSpace_InfoA = ^TWSANameSpace_InfoA;
  LPWSANameSpace_InfoA = PWSANameSpace_InfoA;

  TWSANameSpace_InfoW = packed record
  	NSProviderId   : TGUID;
  	dwNameSpace    : DWORD;
  	fActive        : DWORD{Bool};
  	dwVersion      : DWORD;
  	lpszIdentifier : PWideChar;
  end {TWSANameSpace_InfoW};
  PWSANameSpace_InfoW = ^TWSANameSpace_InfoW;
  LPWSANameSpace_InfoW = PWSANameSpace_InfoW;

{$IFDEF UNICODE}
  WSANameSpace_Info   = TWSANameSpace_InfoW;
  TWSANameSpace_Info  = TWSANameSpace_InfoW;
  PWSANameSpace_Info  = PWSANameSpace_InfoW;
  LPWSANameSpace_Info = PWSANameSpace_InfoW;
{$ELSE}
  WSANameSpace_Info   = TWSANameSpace_InfoA;
  TWSANameSpace_Info  = TWSANameSpace_InfoA;
  PWSANameSpace_Info  = PWSANameSpace_InfoA;
  LPWSANameSpace_Info = PWSANameSpace_InfoA;
{$ENDIF}

{ WinSock 2 extensions -- data types for the condition function in }
{ WSAAccept() and overlapped I/O completion routine. }
type
  LPCONDITIONPROC = function (lpCallerId: LPWSABUF; lpCallerData : LPWSABUF; lpSQOS,lpGQOS : LPQOS; lpCalleeId,lpCalleeData : LPWSABUF;
  	g : GROUP; dwCallbackData : DWORD ) : Integer; stdcall;
  LPWSAOVERLAPPED_COMPLETION_ROUTINE = procedure ( const dwError, cbTransferred : DWORD; const lpOverlapped : LPWSAOVERLAPPED; const dwFlags : DWORD ); stdcall;

  Taccept = function ( const s: TSocket; var addr: TSockAddr; var addrlen: Integer ): TSocket; stdcall;
  Tbind = function ( const s: TSocket; const addr: PSockAddr; const namelen: Integer ): Integer; stdcall;
  Tclosesocket = function ( const s: TSocket ): Integer; stdcall;
  Tconnect = function ( const s: TSocket; const name: PSockAddr; namelen: Integer): Integer; stdcall;
  Tioctlsocket = function ( const s: TSocket; const cmd: DWORD; var arg: u_long ): Integer; stdcall;
  Tgetpeername = function ( const s: TSocket; var name: TSockAddr; var namelen: Integer ): Integer; stdcall;
  Tgetsockname = function ( const s: TSocket; var name: TSockAddr; var namelen: Integer ): Integer; stdcall;
  Tgetsockopt = function ( const s: TSocket; const level, optname: Integer; optval: PChar; var optlen: Integer ): Integer; stdcall;
  Thtonl = function (hostlong: u_long): u_long; stdcall;
  Thtons = function(hostshort: u_short): u_short; stdcall;
  Tinet_addr = function(cp: PChar): u_long; stdcall;
  Tinet_ntoa = function(inaddr: TInAddr): PChar; stdcall;
  Tlisten = function(s: TSocket; backlog: Integer): Integer; stdcall;
  Tntohl = function(netlong: u_long): u_long; stdcall;
  Tntohs = function(netshort: u_short): u_short; stdcall;
  Trecv = function(s: TSocket; Buf: Pointer; len, flags: Integer): Integer; stdcall;
  Trecvfrom = function(s: TSocket; Buf: Pointer; len, flags: Integer; var from: TSockAddr; var fromlen: Integer): Integer; stdcall;
  Tselect = function(nfds: Integer; readfds, writefds, exceptfds: PFDSet; timeout: PTimeVal): Integer; stdcall;
  Tsend = function(s: TSocket; Buf: Pointer; len, flags: Integer): Integer; stdcall;
  Tsendto = function(s: TSocket; Buf: Pointer; len, flags: Integer; var addrto: TSockAddr; tolen: Integer): Integer; stdcall;
  Tsetsockopt = function(s: TSocket; level, optname: Integer; optval: PChar; optlen: Integer): Integer; stdcall;
  Tshutdown = function(s: TSocket; how: Integer): Integer; stdcall;
  TTsocket = function( const af, struct, protocol: Integer ): TSocket; stdcall;
  Tgethostbyaddr = function(addr: Pointer; len, struct: Integer): PHostEnt; stdcall;
  Tgethostbyname = function(name: PChar): PHostEnt; stdcall;
  Tgethostname = function(name: PChar; len: Integer): Integer; stdcall;
  Tgetservbyport = function(port: Integer; proto: PChar): PServEnt; stdcall;
  Tgetservbyname = function(const name, proto: PChar): PServEnt; stdcall;
  Tgetprotobynumber = function(const proto: Integer): PProtoEnt; stdcall;
  Tgetprotobyname = function(const name: PChar): PProtoEnt; stdcall;
  TWSAStartup = function(wVersionRequired: word; var WSData: TWSAData): Integer; stdcall;
  TWSACleanup = function: Integer; stdcall;
  TWSASetLastError = procedure (iError: Integer); stdcall;
  TWSAGetLastError = function: Integer; stdcall;
  TWSAIsBlocking = function: BOOL; stdcall;
  TWSAUnhookBlockingHook = function: Integer; stdcall;
  TWSASetBlockingHook = function(lpBlockFunc: TFarProc): TFarProc; stdcall;
  TWSACancelBlockingCall = function: Integer; stdcall;
  TWSAAsyncGetServByName = function(HWindow: HWND; wMsg: u_int; name, proto, buf: PChar; buflen: Integer): THandle; stdcall;
  TWSAAsyncGetServByPort = function( HWindow: HWND; wMsg, port: u_int; proto, buf: PChar; buflen: Integer): THandle; stdcall;
  TWSAAsyncGetProtoByName = function(HWindow: HWND; wMsg: u_int; name, buf: PChar; buflen: Integer): THandle; stdcall;
  TWSAAsyncGetProtoByNumber = function(HWindow: HWND; wMsg: u_int; number: Integer; buf: PChar; buflen: Integer): THandle; stdcall;
  TWSAAsyncGetHostByName = function(HWindow: HWND; wMsg: u_int; name: PChar; buf: PHostEnt; buflen: Integer): THandle; stdcall;
  TWSAAsyncGetHostByAddr = function(HWindow: HWND; wMsg: u_int; addr: PChar; len, struct: Integer; buf: PChar; buflen: Integer): THandle; stdcall;
  TWSACancelAsyncRequest = function(hAsyncTaskHandle: THandle): Integer; stdcall;
  TWSAAsyncSelect = function(s: TSocket; HWindow: HWND; wMsg: u_int; lEvent: Longint): Integer; stdcall;
  T__WSAFDIsSet = function(s: TSOcket; var FDSet: TFDSet): Bool; stdcall;
{
function TransmitFile(hSocket: TSocket; hFile: THandle; nNumberOfBytesToWrite: DWORD;
         nNumberOfBytesPerSend: DWORD; lpOverlapped: POverlapped;
         lpTransmitBuffers: PTransmitFileBuffers; dwReserved: DWORD): BOOL; stdcall;

function AcceptEx(sListenSocket, sAcceptSocket: TSocket;
         lpOutputBuffer: Pointer; dwReceiveDataLength, dwLocalAddressLength,
         dwRemoteAddressLength: DWORD; var lpdwBytesReceived: DWORD;
         lpOverlapped: POverlapped): BOOL; stdcall;

procedure GetAcceptExSockaddrs(lpOutputBuffer: Pointer;
         dwReceiveDataLength, dwLocalAddressLength, dwRemoteAddressLength: DWORD;
         var LocalSockaddr: TSockAddr; var LocalSockaddrLength: Integer;
         var RemoteSockaddr: TSockAddr; var RemoteSockaddrLength: Integer); stdcall;
}

{	WinSock 2 API new function prototypes }
TWSAAccept = function( s : TSocket; addr : TSockAddr; addrlen : PInteger; lpfnCondition : LPCONDITIONPROC; dwCallbackData : DWORD ): TSocket; stdcall;
TWSACloseEvent = function( hEvent : WSAEVENT) : WordBool; stdcall;
TWSAConnect = function( s : TSocket; const name : PSockAddr; namelen : Integer; lpCallerData,lpCalleeData : LPWSABUF; lpSQOS,lpGQOS : LPQOS ) : Integer; stdcall;
TWSACreateEvent = function : WSAEVENT; stdcall;

TWSADuplicateSocketA = function( s : TSocket; dwProcessId : DWORD; lpProtocolInfo : LPWSAProtocol_InfoA ) : Integer; stdcall;
TWSADuplicateSocketW = function( s : TSocket; dwProcessId : DWORD; lpProtocolInfo : LPWSAProtocol_InfoW ) : Integer; stdcall;
TWSADuplicateSocket = function( s : TSocket; dwProcessId : DWORD; lpProtocolInfo : LPWSAProtocol_Info ) : Integer; stdcall;

TWSAEnumNetworkEvents = function( const s : TSocket; const hEventObject : WSAEVENT; lpNetworkEvents : LPWSANETWORKEVENTS ) :Integer; stdcall;
TWSAEnumProtocolsA = function( lpiProtocols : PInteger; lpProtocolBuffer : LPWSAProtocol_InfoA; var lpdwBufferLength : DWORD ) : Integer; stdcall;
TWSAEnumProtocolsW = function( lpiProtocols : PInteger; lpProtocolBuffer : LPWSAProtocol_InfoW; var lpdwBufferLength : DWORD ) : Integer; stdcall;
TWSAEnumProtocols = function( lpiProtocols : PInteger; lpProtocolBuffer : LPWSAProtocol_Info; var lpdwBufferLength : DWORD ) : Integer; stdcall;

TWSAEventSelect = function( s : TSocket; hEventObject : WSAEVENT; lNetworkEvents : LongInt ): Integer; stdcall;

TWSAGetOverlappedResult = function( s : TSocket; lpOverlapped : LPWSAOVERLAPPED; lpcbTransfer : LPDWORD; fWait : BOOL; var lpdwFlags : DWORD ) : WordBool; stdcall;

TWSAGetQosByName = function( s : TSocket; lpQOSName : LPWSABUF; lpQOS : LPQOS ): WordBool; stdcall;

TWSAhtonl = function( s : TSocket; hostlong : u_long; var lpnetlong : DWORD ): Integer; stdcall;

TWSAhtons = function( s : TSocket; hostshort : u_short; var lpnetshort : WORD ): Integer; stdcall;

TWSAIoctl = function( s : TSocket; dwIoControlCode : DWORD; lpvInBuffer : Pointer; cbInBuffer : DWORD; lpvOutBuffer : Pointer; cbOutBuffer : DWORD;
	lpcbBytesReturned : LPDWORD; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ) : Integer; stdcall;

TWSAJoinLeaf = function( s : TSocket; name : PSockAddr; namelen : Integer; lpCallerData,lpCalleeData : LPWSABUF;
	lpSQOS,lpGQOS : LPQOS; dwFlags : DWORD ) : TSocket; stdcall;

TWSANtohl = function( s : TSocket; netlong : u_long; var lphostlong : DWORD ): Integer; stdcall;
TWSANtohs = function( s : TSocket; netshort : u_short; var lphostshort : WORD ): Integer; stdcall;

TWSARecv = function( s : TSocket; lpBuffers : LPWSABUF; dwBufferCount : DWORD; var lpNumberOfBytesRecvd : DWORD; var lpFlags : DWORD;
	lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ): Integer; stdcall;

TWSARecvDisconnect = function( s : TSocket; lpInboundDisconnectData : LPWSABUF ): Integer; stdcall;
TWSARecvFrom = function( s : TSocket; lpBuffers : LPWSABUF; dwBufferCount : DWORD; var lpNumberOfBytesRecvd : DWORD; var lpFlags : DWORD;
	lpFrom : PSockAddr; lpFromlen : PInteger; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ): Integer; stdcall;

TWSAResetEvent = function( hEvent : WSAEVENT ): WordBool; stdcall;

TWSASend = function( s : TSocket; lpBuffers : LPWSABUF; dwBufferCount : DWORD; var lpNumberOfBytesSent : DWORD; dwFlags : DWORD;
	lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ): Integer; stdcall;
TWSASendDisconnect = function( s : TSocket; lpOutboundDisconnectData : LPWSABUF ): Integer; stdcall;
TWSASendTo = function( s : TSocket; lpBuffers : LPWSABUF; dwBufferCount : DWORD; var lpNumberOfBytesSent : DWORD; dwFlags : DWORD;
	lpTo : PSockAddr; iTolen : Integer; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ): Integer; stdcall;

TWSASetEvent = function( hEvent : WSAEVENT ): WordBool; stdcall;

TWSASocketA = function( af, iType, protocol : Integer; lpProtocolInfo : LPWSAProtocol_InfoA; g : GROUP; dwFlags : DWORD ): TSocket; stdcall;
TWSASocketW = function( af, iType, protocol : Integer; lpProtocolInfo : LPWSAProtocol_InfoW; g : GROUP; dwFlags : DWORD ): TSocket; stdcall;
TWSASocket = function( af, iType, protocol : Integer; lpProtocolInfo : LPWSAProtocol_Info; g : GROUP; dwFlags : DWORD ): TSocket; stdcall;

TWSAWaitForMultipleEvents = function( cEvents : DWORD; lphEvents : PWSAEVENT; fWaitAll : LongBool;
	dwTimeout : DWORD; fAlertable : LongBool ): DWORD; stdcall;

TWSAAddressToStringA = function( lpsaAddress : PSockAddr; const dwAddressLength : DWORD; const lpProtocolInfo : LPWSAProtocol_InfoA;
	const lpszAddressString : PChar; var lpdwAddressStringLength : DWORD ): Integer; stdcall;
TWSAAddressToStringW = function( lpsaAddress : PSockAddr; const dwAddressLength : DWORD; const lpProtocolInfo : LPWSAProtocol_InfoW;
	const lpszAddressString : PWideChar; var lpdwAddressStringLength : DWORD ): Integer; stdcall;
TWSAAddressToString = function( lpsaAddress : PSockAddr; const dwAddressLength : DWORD; const lpProtocolInfo : LPWSAProtocol_Info;
	const lpszAddressString : PMBChar; var lpdwAddressStringLength : DWORD ): Integer; stdcall;

TWSAStringToAddressA = function( const AddressString : PChar; const AddressFamily: Integer; const lpProtocolInfo : LPWSAProtocol_InfoA;
	var lpAddress : TSockAddr; var lpAddressLength : Integer ): Integer; stdcall;
TWSAStringToAddressW = function( const AddressString : PWideChar; const AddressFamily: Integer; const lpProtocolInfo : LPWSAProtocol_InfoA;
	var lpAddress : TSockAddr; var lpAddressLength : Integer ): Integer; stdcall;
TWSAStringToAddress = function( const AddressString : PMBChar; const AddressFamily: Integer; const lpProtocolInfo : LPWSAProtocol_Info;
	var lpAddress : TSockAddr; var lpAddressLength : Integer ): Integer; stdcall;

{	Registration and Name Resolution API functions }
TWSALookupServiceBeginA = function( var qsRestrictions : TWSAQuerySetA; const dwControlFlags : DWORD; var hLookup : THANDLE ): Integer; stdcall;
TWSALookupServiceBeginW = function( var qsRestrictions : TWSAQuerySetW; const dwControlFlags : DWORD; var hLookup : THANDLE ): Integer; stdcall;
TWSALookupServiceBegin = function( var qsRestrictions : TWSAQuerySet; const dwControlFlags : DWORD; var hLookup : THANDLE ): Integer; stdcall;

TWSALookupServiceNextA = function( const hLookup : THandle; const dwControlFlags : DWORD; var dwBufferLength : DWORD; lpqsResults : PWSAQuerySetA ): Integer; stdcall;
TWSALookupServiceNextW = function( const hLookup : THandle; const dwControlFlags : DWORD; var dwBufferLength : DWORD; lpqsResults : PWSAQuerySetW ): Integer; stdcall;
TWSALookupServiceNext = function( const hLookup : THandle; const dwControlFlags : DWORD; var dwBufferLength : DWORD; lpqsResults : PWSAQuerySet ): Integer; stdcall;

TWSALookupServiceEnd = function( const hLookup : THandle ): Integer; stdcall;

TWSAInstallServiceClassA = function( const lpServiceClassInfo : LPWSAServiceClassInfoA ) : Integer; stdcall;
TWSAInstallServiceClassW = function( const lpServiceClassInfo : LPWSAServiceClassInfoW ) : Integer; stdcall;
TWSAInstallServiceClass = function( const lpServiceClassInfo : LPWSAServiceClassInfo ) : Integer; stdcall;

TWSARemoveServiceClass = function( const lpServiceClassId : PGUID ) : Integer; stdcall;

TWSAGetServiceClassInfoA = function( const lpProviderId : PGUID; const lpServiceClassId : PGUID; var lpdwBufSize : DWORD;
	lpServiceClassInfo : LPWSAServiceClassInfoA ): Integer; stdcall;
TWSAGetServiceClassInfoW = function( const lpProviderId : PGUID; const lpServiceClassId : PGUID; var lpdwBufSize : DWORD;
	lpServiceClassInfo : LPWSAServiceClassInfoW ): Integer; stdcall;
TWSAGetServiceClassInfo = function( const lpProviderId : PGUID; const lpServiceClassId : PGUID; var lpdwBufSize : DWORD;
	lpServiceClassInfo : LPWSAServiceClassInfo ): Integer; stdcall;

TWSAEnumNameSpaceProvidersA = function( var lpdwBufferLength: DWORD; const lpnspBuffer: LPWSANameSpace_InfoA ): Integer; stdcall;
TWSAEnumNameSpaceProvidersW = function( var lpdwBufferLength: DWORD; const lpnspBuffer: LPWSANameSpace_InfoW ): Integer; stdcall;
TWSAEnumNameSpaceProviders = function( var lpdwBufferLength: DWORD; const lpnspBuffer: LPWSANameSpace_Info ): Integer; stdcall;

TWSAGetServiceClassNameByClassIdA = function( const lpServiceClassId: PGUID; lpszServiceClassName: PChar;
	var lpdwBufferLength: DWORD ): Integer; stdcall;
TWSAGetServiceClassNameByClassIdW = function( const lpServiceClassId: PGUID; lpszServiceClassName: PWideChar;
	var lpdwBufferLength: DWORD ): Integer; stdcall;
TWSAGetServiceClassNameByClassId = function( const lpServiceClassId: PGUID; lpszServiceClassName: PMBChar;
	var lpdwBufferLength: DWORD ): Integer; stdcall;

TWSASetServiceA = function( const lpqsRegInfo: LPWSAQuerySetA; const essoperation: TWSAeSetServiceOp;
	const dwControlFlags: DWORD ): Integer; stdcall;
TWSASetServiceW = function( const lpqsRegInfo: LPWSAQuerySetW; const essoperation: TWSAeSetServiceOp;
	const dwControlFlags: DWORD ): Integer; stdcall;
TWSASetService = function( const lpqsRegInfo: LPWSAQuerySet; const essoperation: TWSAeSetServiceOp;
	const dwControlFlags: DWORD ): Integer; stdcall;

TWSAProviderConfigChange = function( var lpNotificationHandle : THandle; lpOverlapped : LPWSAOVERLAPPED; lpCompletionRoutine : LPWSAOVERLAPPED_COMPLETION_ROUTINE ) : Integer; stdcall;


{ Macros }
function WSAMakeSyncReply(Buflen, Error: Word): Longint;
function WSAMakeSelectReply(Event, Error: Word): Longint;
function WSAGetAsyncBuflen(Param: Longint): Word;
function WSAGetAsyncError(Param: Longint): Word;
function WSAGetSelectEvent(Param: Longint): Word;
function WSAGetSelectError(Param: Longint): Word;

procedure FD_CLR(Socket: TSocket; var FDSet: TFDSet);
function FD_ISSET (Socket: TSocket; var FDSet: TFDSet): Boolean;
procedure FD_SET(Socket: TSocket; var FDSet: TFDSet);
procedure FD_ZERO(var FDSet: TFDSet);

{
	WS2TCPIP.H - WinSock2 Extension for TCP/IP protocols

	This file contains TCP/IP specific information for use
	by WinSock2 compatible applications.

	Copyright (c) 1995-1999  Microsoft Corporation

	To provide the backward compatibility, all the TCP/IP
	specific definitions that were included in the WINSOCK.H
	file are now included in WINSOCK2.H file. WS2TCPIP.H
	file includes only the definitions  introduced in the
	"WinSock 2 Protocol-Specific Annex" document.

	Rev 0.3	Nov 13, 1995
	Rev 0.4	Dec 15, 1996
}

// Argument structure for IP_ADD_MEMBERSHIP and IP_DROP_MEMBERSHIP
type
	ip_mreq = packed record
		imr_multiaddr : TInAddr; // IP multicast address of group
		imr_interface : TInAddr; // local IP address of interface
  end;

// TCP/IP specific Ioctl codes
const

	SIO_GET_INTERFACE_LIST    = IOC_OUT or (SizeOf(Longint) shl 16) or (Ord('t') shl 8) or 127;
// New IOCTL with address size independent address array
	SIO_GET_INTERFACE_LIST_EX = IOC_OUT or (SizeOf(Longint) shl 16) or (Ord('t') shl 8) or 126;

// Options for use with [gs]etsockopt at the IP level.
	IP_OPTIONS         =  1; // set/get IP options
	IP_HDRINCL         =  2; // header is included with data
	IP_TOS             =  3; // IP type of service and preced
	IP_TTL             =  4; // IP time to live
	IP_MULTICAST_IF    =  9; // set/get IP multicast i/f
	IP_MULTICAST_TTL   = 10; // set/get IP multicast ttl
	IP_MULTICAST_LOOP  = 11; // set/get IP multicast loopback
	IP_ADD_MEMBERSHIP  = 12; // add an IP group membership
	IP_DROP_MEMBERSHIP = 13; // drop an IP group membership
	IP_DONTFRAGMENT    = 14; // don't fragment IP datagrams

  IP_DEFAULT_MULTICAST_TTL   = 1;    // normally limit m'casts to 1 hop
  IP_DEFAULT_MULTICAST_LOOP  = 1;    // normally hear sends if a member
  IP_MAX_MEMBERSHIPS         = 20;   // per socket; must fit in one mbuf

// Option to use with [gs]etsockopt at the IPPROTO_UDP level
	UDP_NOCHECKSUM     = 1;

// Option to use with [gs]etsockopt at the IPPROTO_TCP level
  TCP_EXPEDITED_1122 = $0002;


// IPv6 definitions
type
	IN_ADDR6 = packed record
		s6_addr : array[0..15] of u_char; // IPv6 address
	end;
  TIn6Addr   = IN_ADDR6;
  PIn6Addr   = ^IN_ADDR6;
  IN6_ADDR   = IN_ADDR6;
  PIN6_ADDR  = ^IN_ADDR6;
  LPIN6_ADDR = ^IN_ADDR6;

// Old IPv6 socket address structure (retained for sockaddr_gen definition below)
	SOCKADDR_IN6_OLD = packed record
		sin6_family   : Smallint;         // AF_INET6
		sin6_port     : u_short;          // Transport level port number
		sin6_flowinfo : u_long;           // IPv6 flow information
		sin6_addr     : IN_ADDR6;         // IPv6 address
	end;

// IPv6 socket address structure, RFC 2553
	SOCKADDR_IN6 = packed record
		sin6_family   : Smallint;         // AF_INET6
		sin6_port     : u_short;          // Transport level port number
		sin6_flowinfo : u_long;           // IPv6 flow information
		sin6_addr     : IN_ADDR6;         // IPv6 address
		sin6_scope_id : u_long;           // set of interfaces for a scope
	end;
  TSockAddrIn6   = SOCKADDR_IN6;
  PSockAddrIn6   = ^SOCKADDR_IN6;
  PSOCKADDR_IN6  = ^SOCKADDR_IN6;
  LPSOCKADDR_IN6 = ^SOCKADDR_IN6;

	sockaddr_gen = packed record
		case Integer of
		1 : ( Address : SOCKADDR; );
		2 : ( AddressIn : SOCKADDR_IN; );
		3 : ( AddressIn6 : SOCKADDR_IN6_OLD; );
	end;

// Structure to keep interface specific information
	INTERFACE_INFO = packed record
		iiFlags            : u_long;       // Interface flags
		iiAddress          : sockaddr_gen; // Interface address
		iiBroadcastAddress : sockaddr_gen; // Broadcast address
		iiNetmask          : sockaddr_gen; // Network mask
	end;
	TINTERFACE_INFO  = INTERFACE_INFO;
	LPINTERFACE_INFO = ^INTERFACE_INFO;

// New structure that does not have dependency on the address size
	INTERFACE_INFO_EX = packed record
		iiFlags            : u_long;         // Interface flags
		iiAddress          : SOCKET_ADDRESS; // Interface address
		iiBroadcastAddress : SOCKET_ADDRESS; // Broadcast address
		iiNetmask : SOCKET_ADDRESS;          // Network mask
	end;
	TINTERFACE_INFO_EX  = INTERFACE_INFO_EX;
	LPINTERFACE_INFO_EX = ^INTERFACE_INFO_EX;

// Possible flags for the  iiFlags - bitmask

const
	IFF_UP           = $00000001;  // Interface is up
	IFF_BROADCAST    = $00000002;  // Broadcast is  supported
	IFF_LOOPBACK     = $00000004;  // this is loopback interface
	IFF_POINTTOPOINT = $00000008;  // this is point-to-point interface
	IFF_MULTICAST    = $00000010;  // multicast is supported


{
	wsipx.h

	Microsoft Windows
	Copyright (C) Microsoft Corporation, 1992-1999.

	Windows Sockets include file for IPX/SPX.  This file contains all
	standardized IPX/SPX information.  Include this header file after
	winsock.h.

	To open an IPX socket, call socket() with an address family of
	AF_IPX, a socket type of SOCK_DGRAM, and protocol NSPROTO_IPX.
	Note that the protocol value must be specified, it cannot be 0.
	All IPX packets are sent with the packet type field of the IPX
	header set to 0.

	To open an SPX or SPXII socket, call socket() with an address
	family of AF_IPX, socket type of SOCK_SEQPACKET or SOCK_STREAM,
	and protocol of NSPROTO_SPX or NSPROTO_SPXII.  If SOCK_SEQPACKET
	is specified, then the end of message bit is respected, and
	recv() calls are not completed until a packet is received with
	the end of message bit set.  If SOCK_STREAM is specified, then
	the end of message bit is not respected, and recv() completes
	as soon as any data is received, regardless of the setting of the
	end of message bit.  Send coalescing is never performed, and sends
	smaller than a single packet are always sent with the end of
	message bit set.  Sends larger than a single packet are packetized
	with the end of message bit set on only the last packet of the
	send.
}

// This is the structure of the SOCKADDR structure for IPX and SPX.

type
    SOCKADDR_IPX = packed record
    	sa_family : u_short;
    	sa_netnum : Array [0..3] of Char;
    	sa_nodenum : Array [0..5] of Char;
    	sa_socket : u_short;
    end;
    TSOCKADDR_IPX = SOCKADDR_IPX;
    PSOCKADDR_IPX = ^SOCKADDR_IPX;
    LPSOCKADDR_IPX = ^SOCKADDR_IPX;

//  Protocol families used in the "protocol" parameter of the socket() API.

const
    NSPROTO_IPX   = 1000;
    NSPROTO_SPX   = 1256;
    NSPROTO_SPXII = 1257;

{      wsnwlink.h

	Microsoft Windows
	Copyright (C) Microsoft Corporation, 1992-1999.
		Microsoft-specific extensions to the Windows NT IPX/SPX Windows
		Sockets interface.  These extensions are provided for use as
		necessary for compatibility with existing applications.  They are
		otherwise not recommended for use, as they are only guaranteed to
		work     over the Microsoft IPX/SPX stack.  An application which
		uses these     extensions may not work over other IPX/SPX
		implementations.  Include this header file after winsock.h and
		wsipx.h.

		To open an IPX socket where a particular packet type is sent in
		the IPX header, specify NSPROTO_IPX + n as the protocol parameter
		of the socket() API.  For example, to open an IPX socket that
		sets the packet type to 34, use the following socket() call:

    		s = socket(AF_IPX, SOCK_DGRAM, NSPROTO_IPX + 34);
}

//    Below are socket option that may be set or retrieved by specifying
//    the appropriate manifest in the "optname" parameter of getsockopt()
//    or setsockopt().  Use NSPROTO_IPX as the "level" argument for the
//    call.
const

//    Set/get the IPX packet type.  The value specified in the
//    optval argument will be set as the packet type on every IPX
//    packet sent from this socket.  The optval parameter of
//    getsockopt()/setsockopt() points to an int.
      IPX_PTYPE = $4000;

//    Set/get the receive filter packet type.  Only IPX packets with
//    a packet type equal to the value specified in the optval
//    argument will be returned; packets with a packet type that
//    does not match are discarded.  optval points to an int.
      IPX_FILTERPTYPE = $4001;

//    Stop filtering on packet type set with IPX_FILTERPTYPE.
      IPX_STOPFILTERPTYPE = $4003;

//    Set/get the value of the datastream field in the SPX header on
//    every packet sent.  optval points to an int.
      IPX_DSTYPE = $4002;

//    Enable extended addressing.  On sends, adds the element
//    "unsigned char sa_ptype" to the SOCKADDR_IPX structure,
//    making the total length 15 bytes.  On receives, add both
//    the sa_ptype and "unsigned char sa_flags" to the SOCKADDR_IPX
//    structure, making the total length 16 bytes.  The current
//    bits defined in sa_flags are:
//    	0x01 - the received frame was sent as a broadcast
//    	0x02 - the received frame was sent from this machine
//    optval points to a BOOL.
      IPX_EXTENDED_ADDRESS = $4004;

//    Send protocol header up on all receive packets.  optval points
//    to a BOOL.
      IPX_RECVHDR = $4005;

//    Get the maximum data size that can be sent.  Not valid with
//    setsockopt().  optval points to an int where the value is
//    returned.
      IPX_MAXSIZE = $4006;

//    Query information about a specific adapter that IPX is bound
//    to.  In a system with n adapters they are numbered 0 through n-1.
//    Callers can issue the IPX_MAX_ADAPTER_NUM getsockopt() to find
//    out the number of adapters present, or call IPX_ADDRESS with
//    increasing values of adapternum until it fails.  Not valid
//    with setsockopt().  optval points to an instance of the
//    IPX_ADDRESS_DATA structure with the adapternum filled in.
      IPX_ADDRESS = $4007;
type
    IPX_ADDRESS_DATA = packed record
      	adapternum : Integer;                 // input: 0-based adapter number
      	netnum     : Array [0..3] of Byte;    // output: IPX network number
      	nodenum    : Array [0..5] of Byte;    // output: IPX node address
      	wan        : Boolean;                 // output: TRUE = adapter is on a wan link
      	status     : Boolean;                 // output: TRUE = wan link is up (or adapter is not wan)
      	maxpkt     : Integer;                 // output: max packet size, not including IPX header
      	linkspeed  : ULONG;                   // output: link speed in 100 bytes/sec (i.e. 96 == 9600 bps)
    end;
    PIPX_ADDRESS_DATA = ^IPX_ADDRESS_DATA;

const
//   Query information about a specific IPX network number.  If the
//   network is in IPX's cache it will return the information directly,
//   otherwise it will issue RIP requests to find it.  Not valid with
//   setsockopt().  optval points to an instance of the IPX_NETNUM_DATA
//   structure with the netnum filled in.
     IPX_GETNETINFO = $4008;

type
     IPX_NETNUM_DATA = packed record
     	netnum   : Array [0..3] of Byte;  // input: IPX network number
     	hopcount : Word;                  // output: hop count to this network, in machine order
     	netdelay : Word;                  // output: tick count to this network, in machine order
     	cardnum  : Integer;               // output: 0-based adapter number used to route to this net;
     	                                  // can be used as adapternum input to IPX_ADDRESS
     	router   : Array [0..5] of Byte;  // output: MAC address of the next hop router, zeroed if
                                          // the network is directly attached
     end;
     PIPX_NETNUM_DATA = ^IPX_NETNUM_DATA;

const
//   Like IPX_GETNETINFO except it  does not  issue RIP requests. If the
//   network is in IPX's cache it will return the information, otherwise
//   it will fail (see also IPX_RERIPNETNUMBER which  always  forces a
//   re-RIP). Not valid with setsockopt().  optval points to an instance of
//   the IPX_NETNUM_DATA structure with the netnum filled in.
     IPX_GETNETINFO_NORIP = $4009;

//   Get information on a connected SPX socket.  optval points
//   to an instance of the IPX_SPXCONNSTATUS_DATA structure.
//   *** All numbers are in Novell (high-low) order. ***
     IPX_SPXGETCONNECTIONSTATUS = $400B;
type
     IPX_SPXCONNSTATUS_DATA = packed record
     	ConnectionState         : Byte;
     	WatchDogActive          : Byte;
     	LocalConnectionId       : Word;
     	RemoteConnectionId      : Word;
     	LocalSequenceNumber     : Word;
     	LocalAckNumber          : Word;
     	LocalAllocNumber        : Word;
     	RemoteAckNumber         : Word;
     	RemoteAllocNumber       : Word;
     	LocalSocket             : Word;
     	ImmediateAddress        : Array [0..5] of Byte;
     	RemoteNetwork           : Array [0..3] of Byte;
     	RemoteNode              : Array [0..5] of Byte;
     	RemoteSocket            : Word;
     	RetransmissionCount     : Word;
     	EstimatedRoundTripDelay : Word;                 // In milliseconds
     	RetransmittedPackets    : Word;
     	SuppressedPacket        : Word;
     end;
     PIPX_SPXCONNSTATUS_DATA = ^IPX_SPXCONNSTATUS_DATA;

const
//   Get notification when the status of an adapter that IPX is
//   bound to changes.  Typically this will happen when a wan line
//   goes up or down.  Not valid with setsockopt().  optval points
//   to a buffer which contains an IPX_ADDRESS_DATA structure
//   followed immediately by a HANDLE to an unsignaled event.
//
//   When the getsockopt() query is submitted, it will complete
//   successfully.  However, the IPX_ADDRESS_DATA pointed to by
//   optval will not be updated at that point.  Instead the
//   request is queued internally inside the transport.
//
//   When the status of an adapter changes, IPX will locate a
//   queued getsockopt() query and fill in all the fields in the
//   IPX_ADDRESS_DATA structure.  It will then signal the event
//   pointed to by the HANDLE in the optval buffer.  This handle
//   should be obtained before calling getsockopt() by calling
//   CreateEvent().  If multiple getsockopts() are submitted at
//   once, different events must be used.
//
//   The event is used because the call needs to be asynchronous
//   but currently getsockopt() does not support this.
//
//   WARNING: In the current implementation, the transport will
//   only signal one queued query for each status change.  Therefore
//   only one service which uses this query should be running at
//   once.
     IPX_ADDRESS_NOTIFY = $400C;

//   Get the maximum number of adapters present.  If this call returns
//   n then the adapters are numbered 0 through n-1.  Not valid
//   with setsockopt().  optval points to an int where the value
//   is returned.
     IPX_MAX_ADAPTER_NUM = $400D;

//   Like IPX_GETNETINFO except it forces IPX to re-RIP even if the
//   network is in its cache (but not if it is directly attached to).
//   Not valid with setsockopt().  optval points to an instance of
//   the IPX_NETNUM_DATA structure with the netnum filled in.
     IPX_RERIPNETNUMBER = $400E;

//   A hint that broadcast packets may be received.  The default is
//   TRUE.  Applications that do not need to receive broadcast packets
//   should set this sockopt to FALSE which may cause better system
//   performance (note that it does not necessarily cause broadcasts
//   to be filtered for the application).  Not valid with getsockopt().
//   optval points to a BOOL.
     IPX_RECEIVE_BROADCAST = $400F;

//   On SPX connections, don't delay before sending ack.  Applications
//   that do not tend to have back-and-forth traffic over SPX should
//   set this; it will increase the number of acks sent but will remove
//   delays in sending acks.  optval points to a BOOL.
     IPX_IMMEDIATESPXACK = $4010;

//   wsnetbs.h
//   Copyright (c) 1994-1999, Microsoft Corp. All rights reserved.
//
//   Windows Sockets include file for NETBIOS.  This file contains all
//   standardized NETBIOS information.  Include this header file after
//   winsock.h.

//   To open a NetBIOS socket, call the socket() Tas = function follows:
//
//   	s = socket( AF_NETBIOS, {SOCK_SEQPACKET|SOCK_DGRAM}, -Lana );
//
//   where Lana is the NetBIOS Lana number of interest.  For example, to
//   open a socket for Lana 2, specify -2 as the "protocol" parameter
//   to the socket() function.


//   This is the structure of the SOCKADDR structure for NETBIOS.

const
     NETBIOS_NAME_LENGTH = 16;

type
     SOCKADDR_NB = packed record
     	snb_family : Smallint;
     	snb_type   : u_short;
     	snb_name   : array[0..NETBIOS_NAME_LENGTH-1] of Char;
     end;

     TSockAddr_NB  = SOCKADDR_NB;
     PSOCKADDR_NB  = ^SOCKADDR_NB;
     LPSOCKADDR_NB = ^PSOCKADDR_NB;

//   Bit values for the snb_type field of SOCKADDR_NB.
const
     NETBIOS_UNIQUE_NAME       = $0000;
     NETBIOS_GROUP_NAME        = $0001;
     NETBIOS_TYPE_QUICK_UNIQUE = $0002;
     NETBIOS_TYPE_QUICK_GROUP  = $0003;

//   A macro convenient for setting up NETBIOS SOCKADDRs.
procedure SET_NETBIOS_SOCKADDR( snb : PSOCKADDR_NB; const SnbType : Word; const Name : PChar; const Port : Char );


const
     {* getaddrinfo constants *}
     AI_PASSIVE	= 1;
     AI_CANONNAME = 2;
     AI_NUMERICHOST = 4;

     {* getaddrinfo error codes *}
     EAI_AGAIN      = WSATRY_AGAIN;
     EAI_BADFLAGS   = WSAEINVAL;
     EAI_FAIL       = WSANO_RECOVERY;
     EAI_FAMILY     = WSAEAFNOSUPPORT;
     EAI_MEMORY     = WSA_NOT_ENOUGH_MEMORY;
     EAI_NODATA     = WSANO_DATA;
     EAI_NONAME     = WSAHOST_NOT_FOUND;
     EAI_SERVICE    = WSATYPE_NOT_FOUND;
     EAI_SOCKTYPE   = WSAESOCKTNOSUPPORT;

type
    Paddrinfo = ^Taddrinfo;
    PPaddrinfo = ^Paddrinfo;
    Taddrinfo = packed record
      ai_flags: integer;
	    ai_family: integer;
	    ai_socktype: integer;
	    ai_protocol: integer;
	    ai_addrlen: integer;
	    ai_canonname: PChar;
	    ai_addr: Psockaddr;
	    ai_next: Paddrinfo;
   end;
   Tfreeaddrinfo = procedure (addrinfo: Paddrinfo); stdcall;
   Tgetaddrinfo = function (nodename, servname: PChar; hints: PAddrInfo;
		        res: PPAddrInfo): integer; stdcall;
var
    accept: Taccept;
    bind: Tbind;
    closesocket: Tclosesocket;
    connect: Tconnect;
    ioctlsocket: Tioctlsocket;
    getpeername: Tgetpeername;
    getsockname: Tgetsockname;
    getsockopt: Tgetsockopt;
    htonl: Thtonl;
    htons: Thtons;
    inet_addr: Tinet_addr;
    inet_ntoa: Tinet_ntoa;
    listen: Tlisten;
    ntohl: Tntohl;
    ntohs: Tntohs;
    recv: Trecv;
    recvfrom: Trecvfrom;
    select: Tselect;
    send: Tsend;
    sendto: Tsendto;
    setsockopt: Tsetsockopt;
    shutdown: Tshutdown;
    socket: TTsocket;
    gethostbyaddr: Tgethostbyaddr;
    gethostbyname: Tgethostbyname;
    gethostname: Tgethostname;
    getservbyport: Tgetservbyport;
    getservbyname: Tgetservbyname;
    getprotobynumber: Tgetprotobynumber;
    getprotobyname: Tgetprotobyname;
    WSAStartup: TWSAStartup;
    WSACleanup: TWSACleanup;
    WSASetLastError: TWSASetLastError;
    WSAGetLastError: TWSAGetLastError;
    WSAIsBlocking: TWSAIsBlocking;
    WSAUnhookBlockingHook: TWSAUnhookBlockingHook;
    WSASetBlockingHook: TWSASetBlockingHook;
    WSACancelBlockingCall: TWSACancelBlockingCall;
    WSAAsyncGetServByName: TWSAAsyncGetServByName;
    WSAAsyncGetServByPort: TWSAAsyncGetServByPort;
    WSAAsyncGetProtoByName: TWSAAsyncGetProtoByName;
    WSAAsyncGetProtoByNumber: TWSAAsyncGetProtoByNumber;
    WSAAsyncGetHostByName: TWSAAsyncGetHostByName;
    WSAAsyncGetHostByAddr: TWSAAsyncGetHostByAddr;
    WSACancelAsyncRequest: TWSACancelAsyncRequest;
    WSAAsyncSelect: TWSAAsyncSelect;
    __WSAFDIsSet: T__WSAFDIsSet;
    WSAAccept: TWSAAccept;
    WSACloseEvent: TWSACloseEvent;
    WSAConnect: TWSAConnect;
    WSACreateEvent: TWSACreateEvent;
    WSADuplicateSocketA: TWSADuplicateSocketA;
    WSADuplicateSocketW: TWSADuplicateSocketW;
    WSADuplicateSocket: TWSADuplicateSocket;
    WSAEnumNetworkEvents: TWSAEnumNetworkEvents;
    WSAEnumProtocolsA: TWSAEnumProtocolsA;
    WSAEnumProtocolsW: TWSAEnumProtocolsW;
    WSAEnumProtocols: TWSAEnumProtocols;
    WSAEventSelect: TWSAEventSelect;
    WSAGetOverlappedResult: TWSAGetOverlappedResult;
    WSAGetQosByName: TWSAGetQosByName;
    WSAhtonl: TWSAhtonl;
    WSAhtons: TWSAhtons;
    WSAIoctl: TWSAIoctl;
    WSAJoinLeaf: TWSAJoinLeaf;
    WSANtohl: TWSANtohl;
    WSANtohs: TWSANtohs;
    WSARecv: TWSARecv;
    WSARecvDisconnect: TWSARecvDisconnect;
    WSARecvFrom: TWSARecvFrom;
    WSAResetEvent: TWSAResetEvent;
    WSASend: TWSASend;
    WSASendDisconnect: TWSASendDisconnect;
    WSASendTo: TWSASendTo;
    WSASetEvent: TWSASetEvent;
    WSASocketA: TWSASocketA;
    WSASocketW: TWSASocketW;
    WSASocket: TWSASocket;
    WSAWaitForMultipleEvents: TWSAWaitForMultipleEvents;
    WSAAddressToStringA: TWSAAddressToStringA;
    WSAAddressToStringW: TWSAAddressToStringW;
    WSAAddressToString: TWSAAddressToString;
    WSAStringToAddressA: TWSAStringToAddressA;
    WSAStringToAddressW: TWSAStringToAddressW;
    WSAStringToAddress: TWSAStringToAddress;
    WSALookupServiceBeginA: TWSALookupServiceBeginA;
    WSALookupServiceBeginW: TWSALookupServiceBeginW;
    WSALookupServiceBegin: TWSALookupServiceBegin;
    WSALookupServiceNextA: TWSALookupServiceNextA;
    WSALookupServiceNextW: TWSALookupServiceNextW;
    WSALookupServiceNext: TWSALookupServiceNext;
    WSALookupServiceEnd: TWSALookupServiceEnd;
    WSAInstallServiceClassA: TWSAInstallServiceClassA;
    WSAInstallServiceClassW: TWSAInstallServiceClassW;
    WSAInstallServiceClass: TWSAInstallServiceClass;
    WSARemoveServiceClass: TWSARemoveServiceClass;
    WSAGetServiceClassInfoA: TWSAGetServiceClassInfoA;
    WSAGetServiceClassInfoW: TWSAGetServiceClassInfoW;
    WSAGetServiceClassInfo: TWSAGetServiceClassInfo;
    WSAEnumNameSpaceProvidersA: TWSAEnumNameSpaceProvidersA;
    WSAEnumNameSpaceProvidersW: TWSAEnumNameSpaceProvidersW;
    WSAEnumNameSpaceProviders: TWSAEnumNameSpaceProviders;
    WSAGetServiceClassNameByClassIdA: TWSAGetServiceClassNameByClassIdA;
    WSAGetServiceClassNameByClassIdW: TWSAGetServiceClassNameByClassIdW;
    WSAGetServiceClassNameByClassId: TWSAGetServiceClassNameByClassId;
    WSASetServiceA: TWSASetServiceA;
    WSASetServiceW: TWSASetServiceW;
    WSASetService: TWSASetService;
    WSAProviderConfigChange: TWSAProviderConfigChange;
    freeaddrinfo: Tfreeaddrinfo;
    getaddrinfo: Tgetaddrinfo;

    procedure Init;
    procedure Fini;

//=============================================================
implementation
//=============================================================

function WSAMakeSyncReply;
begin
  WSAMakeSyncReply:= MakeLong(Buflen, Error);
end;

function WSAMakeSelectReply;
begin
  WSAMakeSelectReply:= MakeLong(Event, Error);
end;

function WSAGetAsyncBuflen;
begin
  WSAGetAsyncBuflen:= LOWORD(Param);
end;

function WSAGetAsyncError;
begin
  WSAGetAsyncError:= HIWORD(Param);
end;

function WSAGetSelectEvent;
begin
  WSAGetSelectEvent:= LOWORD(Param);
end;

function WSAGetSelectError;
begin
  WSAGetSelectError:= HIWORD(Param);
end;

procedure FD_CLR(Socket: TSocket; var FDSet: TFDSet);
var	i: DWORD;
begin
  i := 0;
  while i < FDSet.fd_count do
  begin
    if FDSet.fd_array[i] = Socket then
    begin
      while i < FDSet.fd_count - 1 do
      begin
        FDSet.fd_array[i] := FDSet.fd_array[i+1];
        Inc(i);
      end;
      Dec(FDSet.fd_count);
      Break;
    end;
    Inc(i);
  end;
end;

function FD_ISSET(Socket: TSocket; var FDSet: TFDSet): Boolean;
begin
  Result := __WSAFDIsSet(Socket, FDSet);
end;

procedure FD_SET(Socket: TSocket; var FDSet: TFDSet);
begin
  if FDSet.fd_count < FD_SETSIZE then
  begin
    FDSet.fd_array[FDSet.fd_count] := Socket;
    Inc(FDSet.fd_count);
  end;
end;

procedure FD_ZERO(var FDSet: TFDSet);
begin
  FDSet.fd_count := 0;
end;

//	A macro convenient for setting up NETBIOS SOCKADDRs.
procedure SET_NETBIOS_SOCKADDR( snb : PSOCKADDR_NB; const SnbType : Word; const Name : PChar; const Port : Char );
var len : Integer;
begin
     if snb<>nil then with snb^ do
     begin
     	snb_family := AF_NETBIOS;
	snb_type := SnbType;
	len := StrLen(Name);
	if len>=NETBIOS_NAME_LENGTH-1 then
           System.Move(Name^,snb_name,NETBIOS_NAME_LENGTH-1)
	else
	begin
             if len>0 then System.Move(Name^,snb_name,len);
	     	FillChar( (PChar(@snb_name)+len)^, NETBIOS_NAME_LENGTH-1-len, ' ' );
        end;
	snb_name[NETBIOS_NAME_LENGTH-1] := Port;
     end;
end;

var
   Win9xPlatform: integer = -1;

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


procedure Init;
var
   hWSock: HMODULE;
begin
     if isWin9x() then
     begin
          hWSock := GetModuleHandle('wsock32.dll');
          if hWSock = 0 then
            hWSock := LoadLibrary('wsock32.dll');
     end
     else
     begin
          hWSock := GetModuleHandle('ws2_32.dll');
          if hWSock = 0 then
            hWSock := LoadLibrary('ws2_32.dll');
     end;

     @accept := GetProcAddress(hWSock, 'accept');
     @bind := GetProcAddress(hWSock, 'bind');
     @closesocket := GetProcAddress(hWSock, 'closesocket');
     @connect := GetProcAddress(hWSock, 'connect');
     @ioctlsocket := GetProcAddress(hWSock, 'ioctlsocket');
     @getpeername := GetProcAddress(hWSock, 'getpeername');
     @getsockname := GetProcAddress(hWSock, 'getsockname');
     @getsockopt := GetProcAddress(hWSock, 'getsockopt');
     @htonl := GetProcAddress(hWSock, 'htonl');
     @htons := GetProcAddress(hWSock, 'htons');
     @inet_addr := GetProcAddress(hWSock, 'inet_addr');
     @inet_ntoa := GetProcAddress(hWSock, 'inet_ntoa');
     @listen := GetProcAddress(hWSock, 'listen');
     @ntohl := GetProcAddress(hWSock, 'ntohl');
     @ntohs := GetProcAddress(hWSock, 'ntohs');
     @recv := GetProcAddress(hWSock, 'recv');
     @recvfrom := GetProcAddress(hWSock, 'recvfrom');
     @select := GetProcAddress(hWSock, 'select');
     @send := GetProcAddress(hWSock, 'send');
     @sendto := GetProcAddress(hWSock, 'sendto');
     @setsockopt := GetProcAddress(hWSock, 'setsockopt');
     @shutdown := GetProcAddress(hWSock, 'shutdown');
     @socket := GetProcAddress(hWSock, 'socket');
     @gethostbyaddr := GetProcAddress(hWSock, 'gethostbyaddr');
     @gethostbyname := GetProcAddress(hWSock, 'gethostbyname');
     @gethostname := GetProcAddress(hWSock, 'gethostname');
     @getservbyport := GetProcAddress(hWSock, 'getservbyport');
     @getservbyname := GetProcAddress(hWSock, 'getservbyname');
     @getprotobynumber := GetProcAddress(hWSock, 'getprotobynumber');
     @getprotobyname := GetProcAddress(hWSock, 'getprotobyname');
     @WSAStartup := GetProcAddress(hWSock, 'WSAStartup');
     @WSACleanup := GetProcAddress(hWSock, 'WSACleanup');
     @WSASetLastError := GetProcAddress(hWSock, 'WSASetLastError');
     @WSAGetLastError := GetProcAddress(hWSock, 'WSAGetLastError');

     @WSAIsBlocking := GetProcAddress(hWSock, 'WSAIsBlocking');
     @WSAUnhookBlockingHook := GetProcAddress(hWSock, 'WSAUnhookBlockingHook');
     @WSASetBlockingHook := GetProcAddress(hWSock, 'WSASetBlockingHook');
     @WSACancelBlockingCall := GetProcAddress(hWSock, 'WSACancelBlockingCall');
     @WSAAsyncGetServByName := GetProcAddress(hWSock, 'WSAAsyncGetServByName');
     @WSAAsyncGetServByPort := GetProcAddress(hWSock, 'WSAAsyncGetServByPort');
     @WSAAsyncGetProtoByName := GetProcAddress(hWSock, 'WSAAsyncGetProtoByName');
     @WSAAsyncGetProtoByNumber := GetProcAddress(hWSock, 'WSAAsyncGetProtoByNumber');
     @WSAAsyncGetHostByName := GetProcAddress(hWSock, 'WSAAsyncGetHostByName');
     @WSAAsyncGetHostByAddr := GetProcAddress(hWSock, 'WSAAsyncGetHostByAddr');
     @WSACancelAsyncRequest := GetProcAddress(hWSock, 'WSACancelAsyncRequest');
     @WSAAsyncSelect := GetProcAddress(hWSock, 'WSAAsyncSelect');
     @__WSAFDIsSet := GetProcAddress(hWSock, '__WSAFDIsSet');
     @WSAAccept := GetProcAddress(hWSock, 'WSAAccept');
     @WSACloseEvent := GetProcAddress(hWSock, 'WSACloseEvent');
     @WSAConnect := GetProcAddress(hWSock, 'WSAConnect');
     @WSACreateEvent := GetProcAddress(hWSock, 'WSACreateEvent');
     @WSAEnumNetworkEvents := GetProcAddress(hWSock, 'WSAEnumNetworkEvents');
     @WSAEventSelect := GetProcAddress(hWSock, 'WSAEventSelect');
     @WSAGetOverlappedResult := GetProcAddress(hWSock, 'WSAGetOverlappedResult');
     @WSAGetQosByName := GetProcAddress(hWSock, 'WSAGetQosByName');
     @WSAhtonl := GetProcAddress(hWSock, 'WSAhtonl');
     @WSAhtons := GetProcAddress(hWSock, 'WSAhtons');
     @WSAIoctl := GetProcAddress(hWSock, 'WSAIoctl');
     @WSAJoinLeaf := GetProcAddress(hWSock, 'WSAJoinLeaf');
     @WSANtohl := GetProcAddress(hWSock, 'WSANtohl');
     @WSANtohs := GetProcAddress(hWSock, 'WSANtohs');
     @WSARecv := GetProcAddress(hWSock, 'WSARecv');
     @WSARecvDisconnect := GetProcAddress(hWSock, 'WSARecvDisconnect');
     @WSARecvFrom := GetProcAddress(hWSock, 'WSARecvFrom');
     @WSAResetEvent := GetProcAddress(hWSock, 'WSAResetEvent');
     @WSASend := GetProcAddress(hWSock, 'WSASend');
     @WSASendDisconnect := GetProcAddress(hWSock, 'WSASendDisconnect');
     @WSASendTo := GetProcAddress(hWSock, 'WSASendTo');
     @WSASetEvent := GetProcAddress(hWSock, 'WSASetEvent');
     @WSAWaitForMultipleEvents := GetProcAddress(hWSock, 'WSAWaitForMultipleEvents');
     @WSALookupServiceEnd := GetProcAddress(hWSock, 'WSALookupServiceEnd');
     @WSARemoveServiceClass := GetProcAddress(hWSock, 'WSARemoveServiceClass');
     @WSAProviderConfigChange := GetProcAddress(hWSock, 'WSAProviderConfigChange');

     @WSADuplicateSocketA := GetProcAddress(hWSock, 'WSADuplicateSocketA');
     @WSADuplicateSocketW := GetProcAddress(hWSock, 'WSADuplicateSocketW');
     @WSAEnumProtocolsA := GetProcAddress(hWSock, 'WSAEnumProtocolsA');
     @WSAEnumProtocolsW := GetProcAddress(hWSock, 'WSAEnumProtocolsW');
     @WSASocketA := GetProcAddress(hWSock, 'WSASocketA');
     @WSASocketW := GetProcAddress(hWSock, 'WSASocketW');
     @WSAAddressToStringA := GetProcAddress(hWSock, 'WSAAddressToStringA');
     @WSAAddressToStringW := GetProcAddress(hWSock, 'WSAAddressToStringW');
     @WSAStringToAddressA := GetProcAddress(hWSock, 'WSAStringToAddressA');
     @WSAStringToAddressW := GetProcAddress(hWSock, 'WSAStringToAddressW');
     @WSALookupServiceBeginA := GetProcAddress(hWSock, 'WSALookupServiceBeginA');
     @WSALookupServiceBeginW := GetProcAddress(hWSock, 'WSALookupServiceBeginW');
     @WSALookupServiceNextA := GetProcAddress(hWSock, 'WSALookupServiceNextA');
     @WSALookupServiceNextW := GetProcAddress(hWSock, 'WSALookupServiceNextW');
     @WSAInstallServiceClassA := GetProcAddress(hWSock, 'WSAInstallServiceClassA');
     @WSAInstallServiceClassW := GetProcAddress(hWSock, 'WSAInstallServiceClassW');
     @WSAGetServiceClassInfoA := GetProcAddress(hWSock, 'WSAGetServiceClassInfoA');
     @WSAGetServiceClassInfoW := GetProcAddress(hWSock, 'WSAGetServiceClassInfoW');
     @WSAEnumNameSpaceProvidersA := GetProcAddress(hWSock, 'WSAEnumNameSpaceProvidersA');
     @WSAEnumNameSpaceProvidersW := GetProcAddress(hWSock, 'WSAEnumNameSpaceProvidersW');
     @WSAGetServiceClassNameByClassIdA := GetProcAddress(hWSock, 'WSAGetServiceClassNameByClassIdA');
     @WSAGetServiceClassNameByClassIdW := GetProcAddress(hWSock, 'WSAGetServiceClassNameByClassIdW');
     @WSASetServiceA := GetProcAddress(hWSock, 'WSASetServiceA');
     @WSASetServiceW := GetProcAddress(hWSock, 'WSASetServiceW');

{$IFDEF UNICODE}
     @WSADuplicateSocket := @WSADuplicateSocketW;
     @WSAEnumProtocols := @WSAEnumProtocolsW;
     @WSASocket := @WSASocketW;
     @WSAAddressToString := @WSAAddressToStringW;
     @WSAStringToAddress := @WSAStringToAddressW;
     @WSALookupServiceBegin := @WSALookupServiceBeginW;
     @WSALookupServiceNext := @WSALookupServiceNextW;
     @WSAInstallServiceClass := @WSAInstallServiceClassW;
     @WSAGetServiceClassInfo := @WSAGetServiceClassInfoW;
     @WSAEnumNameSpaceProviders := @WSAEnumNameSpaceProvidersW;
     @WSAGetServiceClassNameByClassId := @WSAGetServiceClassNameByClassIdW;
     @WSASetService := @WSASetServiceW;

{$ELSE}
     @WSADuplicateSocket := @WSADuplicateSocketA;
     @WSAEnumProtocols := @WSAEnumProtocolsA;
     @WSASocket := @WSASocketA;
     @WSAAddressToString := @WSAAddressToStringA;
     @WSAStringToAddress := @WSAStringToAddressA;
     @WSALookupServiceBegin := @WSALookupServiceBeginA;
     @WSALookupServiceNext := @WSALookupServiceNextA;
     @WSAInstallServiceClass := @WSAInstallServiceClassA;
     @WSAGetServiceClassInfo := @WSAGetServiceClassInfoA;
     @WSAEnumNameSpaceProviders := @WSAEnumNameSpaceProvidersA;
     @WSAGetServiceClassNameByClassId := @WSAGetServiceClassNameByClassIdA;
     @WSASetService := @WSASetServiceA;

{$ENDIF}

     @freeaddrinfo := GetProcAddress(GetModuleHandle('ws2_32.dll'), 'freeaddrinfo');
     @getaddrinfo := GetProcAddress(GetModuleHandle('ws2_32.dll'), 'getaddrinfo');
end;

procedure Fini;
begin

end;

end.
