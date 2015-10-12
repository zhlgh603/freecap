{*
 * File: ...................... plugin.pas
 * Autor: ..................... Maxim Artemev aka Bert Raccoon
 * Copyright: ................. (c) 2004 by Max Artemev
 * Desc: ...................... Plugins declarations

  $Id: plugin.pas,v 1.3 2005/12/19 06:09:02 bert Exp $

  $Log: plugin.pas,v $
  Revision 1.3  2005/12/19 06:09:02  bert
  *** empty log message ***

  Revision 1.2  2005/02/15 11:21:21  bert
  *** empty log message ***

}
unit plugin;

interface
uses Windows, SysUtils {$IFNDEF PLUGIN}, winsock2 {$ENDIF};

const
     MAX_ARRAY_VALUES = 32;

type
{$IFDEF PLUGIN}
    u_char  = Byte;
    u_short = Word;
    u_int   = DWORD;
    u_long  = DWORD;

//  The new type to be used in all instances which refer to sockets.
    TSocket = u_int;

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
{$ENDIF}

    TProcedure = procedure; stdcall;
    TBuffer = array[0..65535] of Char;
    TLog = procedure (fmt: PChar; args: array of const); stdcall;


    TNameBuf = array[0..511] of Char;

    {*
     * This structure passes to OnSendRecv handler
     *}
    TSendRecvInfo = packed record
       App : PChar; // Application who initiates trasmiting/recieving
       DstAddr : PSockAddrIn;
       Port: Word;  // Port that used
    end;

    TConnectInfo = packed record
       App : PChar; // Application who initiates trasmiting/recieving
       DestAddr: TNameBuf;
    end;

    // Function return 0 - if connect allowed, or -1 if it should be 'refused'
    // in the DestinationAddr an place the new
    // destination address
    TOnConnect = function (var DestinationAddr: TConnectInfo): integer; stdcall;

    // This function *MUST* return size of result buffer, even if its haven't changed them
    TOnSendRecv = function (SendRecvInfo: TSendRecvInfo; Buffer: Pointer; Size: DWORD): DWORD; stdcall;

    TPluginHooks = packed record
      Init: TProcedure;    // Calls when plugin is loaded. May be nil
      Fini: TProcedure;    // Calls before plugin's unloading. May be nil
      OnSend: TOnSendRecv; // Calls before 'main program' will send data. May be nil
      OnRecv: TOnSendRecv; // Calls before 'main program' will recieve data. May be nil
      OnConnect: TOnConnect;
    end;

    PPluginInfo = ^TPluginInfo;
    TPluginInfo = packed record
      Ports : array[0..MAX_ARRAY_VALUES - 1] of Word;  // list of ports for plugin bindings, last item should be zero
      Addrs : array[0..MAX_ARRAY_VALUES - 1] of PChar; // list of addresses for plugin bindings, last item should be nil
      Apps  : array[0..MAX_ARRAY_VALUES - 1] of PChar; // list of applications for plugin bindings, last item should be nil
      Name  : PChar;
      Author: PChar;
      Description: PChar;
      Hooks: TPluginHooks; // Pointer to plugin hooks structure
      InvokeConfigWnd: TProcedure; // procedure for showing 'Config Window' of plugin
    end;

    TFreeCapMain = packed record
       Log: TLog;
    end;


implementation
end.
