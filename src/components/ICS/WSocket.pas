{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  TWSocket class encapsulate the Windows Socket paradigm
Creation:     April 1996
Version:      5.15
EMail:        francois.piette@overbyte.be  http://www.overbyte.be
              francois.piette@rtfm.be      http://www.rtfm.be/fpiette
                                           francois.piette@pophost.eunet.be
Support:      Use the mailing list twsocket@elists.org
              Follow "support" link at http://www.overbyte.be for subscription.
Legal issues: Copyright (C) 1996-2004 by François PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
              <francois.piette@overbyte.be>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

              4. You must register this software by sending a picture postcard
                 to the author. Use a nice stamp and mention your name, street
                 address, EMail address and any comment you like to say.

History:
Jul 18, 1996  Move all low level socket to winsock to be Delphi 2.x compatible
Sep 18, 1996  Use structured exception for handling errors
Sep 19, 1996  Check csDestroying before invoking event handler
Nov 04, 1996  Better error handling
Jan 31, 1997  Changed property assignation for Addr, Port and Proto
              Added notification handler
Feb 14, 1997  Corrected bug in property assignation for Addr, Port and Proto
Mar 26, 1997  Make UDP protocol work correctly
              Enable UDP broadcasting by using addr 255.255.255.255
Apr 1, 1997   Added class function when independent of any open socket
              Moved InitData as global
              Added ReceivedFrom function
              Added ResolveHost function
Jul 22, 1997  Adapted to Delphi 3 which has a modified winsock.accept
Aug 13, 1997  'sin' member made public
Aug 24, 1997  Create the only help
              Makes writing HSocket the same as calling Dup.
Sep 5, 1997   Version 2.01, added WinsockInfo function
Sep 21, 1997  Version 2.02, make it really thread safe
                            created global WSocketVersion
Sep 25, 1997  Version 2.04, port to C++Builder
Sep 27, 1997  Version 2.05. All class methods converted to global
              procedure or function because C++Builder do not like
              class method very much.
              Old class method              New global function
              ----------------              -------------------
              WinsockInfo                   WinsockInfo
              SocketErrorDesc               WSocketErrorDesc
              GetHostByAddr                 WSocketGetHostByAddr
              GetHostByName                 WSocketGetHostByName
              ResolveHost                   WSocketResolveHost
              HostName                      LocalHostName
Oct 02, 1997  V2.06 Added a check in destructor to avoid calling WSACleanup at
              design time which crashes the excellent Eagle Software CDK.
Oct 16, 1997  V2.07 Added PortNum property with numeric value for Port.
              Added RcvdCount property to return the number of
              characters received in the buffer but not read yet. Do not
              confuse with ReadCount which returns the number of chars
              already received.
              Added a check for FWait assignation in front of ReadLine
              Prefixed each TSocketState value by 'ws' to avoid name conflict.
              Moved FHSocket member to private section because the property
              HSocket does the right job.
              Added a check for state closed when changing Port, Proto and Addr.
Oct 22, 1997  V2.08 Added Flush method (asked by john@nexnix.co.uk) and
              FlushTimeout property (default to 60 seconds).
Oct 22, 1997  V2.09 Added SendFlags property to enable sending in or out of
              band data (normal or urgent, see RFC-1122)
Oct 28, 1997  V2.10 Added an OnLineTooLong event and code to handle the case
              where ReadLine has been called and the buffer overflowed (line
              long)
Oct 29, 1997  V2.11 Added DnsLookup functionnality (DnsLookup method, DnsResult
              property and DnsLookupDone event).
              Calling the connect method with a hostname work well except that
              it could block for a long period (ie: 2 minutes) if DNS do not
              respond. Calling the connect method with a numeric IP address will
              never block. So you can call DnsLookup to start hostname
              resolution in the background, after some time you evenutually
              receive the OnDnsLookupDone event. The copy the DnsResult property
              to the Addr property and call connect.
Oct 30, 1997  V2.12 added a check in DnsLookup to handel numeric IP which do
              not require any lookup. The numeric IP is treated immediately
              and immediately trigger the DnsLookupDone event.
              I modified the code to be compatible with Delphi 1.
Oct 31, 1997  V2.13 added CancelDnsLookup procedure.
Nov 09, 1997  V2.14 add LocalIPList function to get the list of local IP
              addresses (you have two IP addresses when connected to a LAN
              and an ISP).
Nov 11, 1997  V2.15 Made TCustomWSocket with virtual functions. This will
              allow to easily descend a new component from TCustomWSocket.
              Make ReadLine stop when the connection is broken.
Nov 12, 1997  V2.16 Corrected bug (Justin Yunke <yunke@productivity.org>)
              in LocalIPList: phe should be checked for nil.
Nov 18, 1997  Added ReceiveStr function (Suggested by FLDKNHA@danisco.com)
Nov 30, 1997  V2.18 Added a call to OnDnsLookupDone when canceling.
Dec 04, 1997  V2.19 Added LocalPort property and SessionConnected event
              for UDP socket.
              V2.20 Modified MessageLoop and ProcessMessages to process not
              only the socket messages, but all messages (necessary if the
              thread has several TWSocket for example).
Dec 09, 1997  V2.21 Corrected a minor bug in ReceiveStr. Detected by
              david@e.co.za (David Butler).
Dec 10, 1997  V2.22 Corrected a minor bug in Send which now correctly
              returns the number of bytes sent. Detected by
              james.huggins@blockbuster.com
Dec 16, 1997  V2.23 Corrected a bug which prevented the receiving of datagram
              from a UDP socket.
              Thank to Mark Melvin (melvin@misrg.ml.org) for pointing it.
Dec 20, 1997  V2.24 Added the PeekData function as suggested by Matt Rose
              mcrose@avproinc.com
Dec 26, 1997  V2.25 Added the Text property as suggested by Daniel P. Stasinski
              <dse@pacific.net>. Made GetXPort work even when listening as
              suggested by is81024@cis.nctu.edu.tw.
Jan 10, 1998  V2.26 Check for null hostname in DNSLookup
              Added DnsResultList with all IP addresses returned form DNS
Jan 13, 1998  V2.27 a Added MultiThreaaded property to tell the component that
              it is working in a thread and should take care of it (call
              internal ProcessMessages in place of Application.ProcessMessages,
              and do not use the WaitCtrl object).
Jan 15, 1998  V2.28 WMAsyncSelect revisited to work properly with NT winsock 2.
Feb 10, 1998  V2.29 Added an OnError event. If not assigned, then the component
              raise an exception when the error occurs.
Feb 14, 1998  V2.30 Published Text property
Feb 16, 1998  V2.31 Added virtual methods to trigger events
              Renamed all event handler variable to begin with FOn
Feb 26, 1998  V2.32 Added procedure PutDataInSendBuffer and PutStringInSendBuffer
              Using PutDataInSendBuffer you can place data in the send buffer
              without actualy trying to send it. This allows to place several
              (probably small) data chunk before the component attempt to send
              it. This prevent small packet to be sent. You can call
              Send(nil, 0) to force the component to begin to send data.
              If the buffer was not empty, PutDataInSendBuffer will just queue
              data to the buffer. This data will be sent in sequence.
Mar 02, 1998  V2.33 Changed the error check with WSAstartup as pointed out by
              Donald Strenczewilk (dstrenz@servtech.com)
Mar 06, 1998  V2.34 Added a runtime property to change the buffer size.
Mar 27, 1998  V2.35 Adapted for C++Builder 3
Apr 08, 1998  V2.36 Made SetDefaultValue virtual
Apr 13, 1998  V2.37 Reset FDnsLookupHandle to 0 after a failed call to
              WSACancelAsyncRequest
Apr 22, 1998  V2.38 Published AllSent property to let outside know if our
              buffer has some data unsent.
Apr 28, 1998  V2.39 Added LingerOnOff and LingerTimeout. Default values are
              wsLingerOn and timeout = 0 to behave by default as before.
              This value is setup just before Connect. Call SetLingerOption to
              set the linger option on the fly (the connection must be
              established to set the option). See winsock.closesocket on line
              help (winsock.hlp or win32.hlp) for a dsicussion of this option
              usage.
May 06, 1998  V2.40 Added a workaround for Trumpet winsock inet_addr bug.
              Thanks to Andrej Cuckov <andrej@cuckov.com> for his code.
May 18, 1998  V2.41 Jan Tomasek <xtomasej@feld.cvut.cz> found that Trumpet
              Winsock (Win 3.11) has some bugs and suggested a workaround in
              TryToSend procedure. This workaround makes TWSocket blocking in
              some cases. A new property enables the workaround. See code.
Jun 01, 1998  V2.42 In finalization section, check for not assigned IPList.
Jun 15, 1998  V2.43 Added code to finalization section to unload winsock if
              still loaded at that point (this happend if no socket where
              created but WinsockInfo called). Suggested by Daniel Fazekas
              <fdsoft@dns.gyor-ph.hu>
Jun 27, 1998  V2.44 Added checks for valid arguments in SetPort, SetProto
              and SetAddr. Deferred address resolution until Connect or Listen.
Jul 08, 1998  V2.45 Adadpted for Delphi 4
Jul 20, 1998  V2.46 Added SetWindowLong(FWindowHandle, 0, 0) in the destructor
              and a check for TWSocket class in XSocketWindowProc.
              Added virtual method RealSend.
Jul 23, 1998  V2.47 Added a TriggerSessionClosed from TryToSend in case of
              send error. This was called before, but with a nul error argument.
              Now it correctly gives the error number.
              Added a trashcan to receive data if no OnDataAvailable event
              handler is installed. Just receive the data and throw it away.
              Added reverse dns lookup asynchronous code (IP -> HostName).
              Thanks to Daniel Fazekas <fdsoft@dns.gyor-ph.hu> for his code.
Jul 30, 1998  V2.48 Changed local variable "error" by FLastError in SocketError
              to make it available from the OnError handler. Thanks to
              dana@medical-info.com for finding this bug.
              In Abort procedure, deleted all buffered data because it was send
              the next time the socket is opened !
              Added CancelDnsLookup in Abort procedure.
Aug 28, 1998  V2.49 Made InternalClose and ReceiveStr virtual
Sep 01, 1998  V2.50 Ignore CancelDnsLookup exception during destroy
Sep 29, 1998  V2.51 In InternalClose, protect AssignDefaultValue with
              try/except because SessionClosed event handler may have destroyed
              the component.
Oct 11, 1998  V2.52 Changed Shutdown(2) to Shutdown(1) in Internal Close to
              prevent data lost on send. You may have to call Shutdown(2) in
              your own code before calling Close to have the same behaviour as
              before.
              Changed argument type for ASyncReceive and passed 0 from FD_CLOSE
              message handler.
Oct 28, 1998  V2.53 Made WSocketLoadWinsock and WSocketUnloadWinsock public.
Nov 11, 1998  V2.54 Added OnDisplay event for debugging purpose
Nov 16, 1998  V2.55 Ignore WSANOTINITIALIZED error calling CloseSocket. This
              occurs when using TWSocket from a DLL and the finalization
              section is called before destroying TWSocket components (this is
              a program logic error).
              Made some properties and methods protected instead of private.
              Made some methods virtual.
              Added an Error argument to InternalClose.
              Added DoRecv virtual function.
              Added WSocketResolvePort
              Added WSocketResolveProto
              Deferred port and protocol resolution until really needed
              Transformed Listen to procedure (in case of failure Listen
              always calls SocketError which triggers an exception or the
              OnError event).
Nov 22, 1998  V3.00 Skipped from V2.55 to V3.00. Socks support is major update!
              Added SOCKS5 (RFC-1928) support for TCP connection and
              simple usercode passwword authentication.
              Consider the socks code as beta !
              New properties: SocksServer, SocksPort, SocksUsercode,
              SocksPassword, FSocksAuthentication. New events: OnSocksError,
              OnSocksConnected, OnSocksAuthState.
              I used WinGate 2.1d to test my code. Unfortunately WinGate do
              not correctly handle user authentication, so the code here is
              just untested...
Dec 05, 1998  V3.10 Removed ReadLine feature using TWait component.
              Added new TCustomLineWSocket and TCustomSyncWSocket.
              Those modifications implies that the ReadLine functionnality is
              slightly changed. Notably, the end of line marker is now
              configurable and remains in the received line unless a timeout
              occurs or the buffer is too small.
Dec 10, 1998  V3.11 Added missing code to resolve port in the Listen method.
Dec 12, 1998  V3.12 Added write method for LocalPort property. Thanks to
              Jan Tomasek <xtomasej@feld.cvut.cz> for his code.
              Added background exception handling.
              Fixed a bug in TCustomLineWSocket.TriggerDataAvailable which was
              not calling the inherited function when it actually should.
              Added a check on multithreaded in WaitForClose to call the
              correct ProcessMessages procedure.
              Added SOCKS4 support (only tcp connect is supported).
Dec 28, 1998  V3.13 Changed WSocketResolveHost to check for invalid numeric
              IP addresses whitout trying to use them as hostnames.
Dec 30, 1998  V3.14 Changed SetPort to SetRemotePort to solve the SetPort
              syndrome with BCB. Also chnaged GetPort to be consistant.
Jan 12, 1999  V3.15 Introduced DoRecvFrom virtual function. This correct a bug
              introduced in V3.14 related to UDP and RecvFrom.
Jan 23, 1999  V3.16 Changed FRcvdFlag computation in DoRecv and DoRecvFrom
              because it caused problems with HTTP component and large blocks.
              Removed modification by Jan Tomasek in TriggerDataAvailable
Jan 30, 1999  V3.17 Added WSocketResolveIp function.
              Checked for tcp protocol before setting linger off in abort.
              Moved a lot of variables from private to protected sections.
              Removed check for Assigned(FOnDataSent) in WMASyncSelect.
Feb 03, 1999  V3.18 Removed useless units in the uses clause.
Feb 14, 1999  V4.00 Jump to next major version number because lots of
              fundamental changes have been done. See below.

              Use runtime dynamic link with winsock. All winsock functions
              used by TWSocket are linked at runtime instead of loadtime. This
              allows programs to run without winsock installed, provided program
              doesn't try to use TWSocket or winsock function without first
              checking for winsock installation.
              Removed WSocketLoadWinsock and all use to DllStarted because it
              is no longer necessary because winsock is automatically loaded
              and initialized with the first call to a winsock function.

              Added MessagePump to centralize call to the message pump.
              It is a virtual procedure so that you can override it to
              cutomize your message pump. Also changed slightly ProcessMessages
              to closely match what is done in the forms unit.

              Removed old stuff related to WaitCtrl (was already excluded from
              compilation using a conditional directive).

              Added NOFORMS conditional compilation to exclude the Forms unit
              from wsocket. This will reduce exe or dll size by 100 to 150KB.
              To use this feature, you have to add NOFORMS in your project
              options in the "defines" edit box in the "directory/conditional"
              tab. Then you must add a message pump to your application and
              call it from TWSocket.OnMessagePump event handler. TWSocket really
              need a message pump in order to receive messages from winsock.
              Depending on how your application is built, you can use either
              TWSocket.MessageLoop or TWSocket.ProcessMessages to quickly build
              a working message pump. Or you may build your own custom message
              pump taylored to your needs. Your message pump must set
              TWSocket.Terminated property to TRUE when your application
              terminates or you may experience long delays when closing your
              application.
              You may use NOFORMS setting even if you use the forms unit (GUI
              application). Simply call Application.ProcessMessages in the
              OnMessagePump event handler.
              OnMessagePump event is not visible in the object inspector. You
              must assign it at run-time before using the component and after
              having created it (in a GUI application you can do that in the
              FormCreate event, in a console application, you can do it right
              after TWSocket.Create call).
Feb 17, 1999  V4.01 Added LineEcho and LineEdit features.
Feb 27, 1999  V4.02 Added TCustomLineWSocket.GetRcvdCount to make RcvdCount
              property and ReceiveStr work in line mode.
Mar 01, 1999  V4.03 Added conditional compile for BCB4. Thanks to James
              Legg <jlegg@iname.com>.
Mar 14, 1999  V4.04 Corrected a bug: wsocket hangup when there was no
              OnDataAvailable handler and line mode was on.
Apr 21, 1999  V4.05 Added H+ (long strings) and X+ (extended syntax)
              compilation options
May 07, 1999  V4.06 Added WSAECONNABORTED to valid error codes in TryToSend.
Jul 21, 1999  V4.07 Added GetPeerPort method, PeerPort and PeerAddr propertied
              as suggested by J. Punter <JPunter@login-bv.com>.
Aug 20, 1999  V4.05 Changed conditional compilation so that default is same
              as latest compiler (currently Delphi 4, Bcb 4). Should be ok for
              Delphi 5.
              Added LocalAddr property as suggested by Rod Pickering
              <fuzzylogic123@yahoo.com>. LocalAddr default to '0.0.0.0' and is
              intended to be used by a client when connecting to a server, to
              select a local interface for multihomed computer. Note that to
              select an interface for a server, use Addr property before
              listening.
              LocalAddr has to be an IP address in dotted form. Valid values are
              '0.0.0.0' for any interface, '127.0.0.1' for localhost or any
              value returned by LocalIPList.
              Replaced loadtime import for ntohs and getpeername by runtime
              load.
              Revised check for dotted numeric IP address in WSocketResolveHost
              to allow correct handling of hostnames beginning by a digit.
              Added OnSendData event. Triggered each time data has been sent
              to winsock. Do not confuse with OnDataSent which is triggered
              when TWSocket internal buffer is emptyed. This event has been
              suggested by Paul Gertzen" <pgertzen@livetechnology.com> to
              easyly implement progress bar.
              Corrected WSocketGetHostByAddr to make it dynamically link to
              winsock.
Sep 5, 1999   V4.09 Added CloseDelayed method.
              Make sure that TriggerSessionClosed is called from WMASyncSelect
              and InternalClose, even if there is no OnSessionClosed event
              handler assigned. This is required to make derived components
              work correctly.
              Created message WM_TRIGGER_EXCEPTION to help checking background
              exception handling (OnBgException event).
              Corrected bug for Delphi 1 and ReallocMem.
Oct 02, 1999  V4.10 Added Release method.
Oct 16, 1999  V4.11 Corrected a bug in TCustomLineWSocket.DoRecv: need to move
              data in front of buffer instead of changing buffer pointer which
              will crash the whole thing at free time.
Oct 23, 1999  V4.12 Made WSocketIsDottedIP a public function
Nov 12, 1999  V4.13 removed 3 calls to TriggerSocksAuthState because it was
                    called twice. By A. Burlakov <alex@helexis.com>.
Jan 24, 1999  V4.14 Call Receive instead of DoRecv from ReceiveStr to be sure
              to set LastError correctly. Thanks to Farkas Balazs
              <megasys@www.iridium.hu>
              Suppressed FDllName and used winsocket constant directly. I had
              troubles with some DLL code and string handling at program
              termination.
Apr 09, 2000 V4.15 Added error number when resolving proto and port
Apr 29, 2000 V4.16 Added WSocketForceLoadWinsock and
             WSocketCancelForceLoadWinsock. Thanks to Steve Williams.
             Created variable FSelectEvent to store current async event mask.
             Added ComponentOptions property with currently only one options
             wsoNoReceiveLoop which disable a receive loop in AsyncReceive.
             This loop breaking was suggested by Davie <smatters@smatters.com>
             to lower resource usage with really fast LAN and large transfers.
             By default, this option is disabled so there is no change needed
             in current code.
May 20, 2000 V4.17 Made TSocket = u_int (same def as in winsock.pas)
             Moved bind after setting options.
             Thanks to Primoz Gabrijelcic <fab@siol.net>
Jul 15, 2000 V4.18 Alon Gingold <gingold@hiker.org.il> changed
             TCustomSocksWSocket calls to inherited triggers of
             TriggerSessionConnected and TriggerDataAvailable.
             Now, it calls the trigger directly. This solves the problem
             of descendent classes with overriden triggers, not being
             called when a REAL connection was established, and when real
             data starts coming in. Special care MUST be taken in such
             overridden triggers to ONLY call the inherited trigger AND
             IMMEDIATELY EXIT when FSocksState <> socksData to avoid loopback
Jul 22, 2000 V4.19 John Goodwin <john@jjgoodwin.com> found a failure in the
             logic for DnsLookup. He also implemented a workaround.
             See DnsLookup comments for explanation.
Aug 09, 2000 V4.20 Alon Gingold <gingold2@mrm-multicat.com> found a bug in
             SOCKS4 implementation where a nul byte was incorrectly added
             (it should be added only with SOCKS4A version, not straith
             SOCKS4).
Sep 17, 2000 V4.21 Eugene Mayevski <Mayevski@eldos.org> added TWndMethod for
             NOFORMS applications in other components.
Oct 15, 2000 V4.22 Added method GetXAddr which returns local IP address to
             which a socket has been bound. There was already a GetXPort.
             Thanks to Wilfried Mestdagh <wilfried_sonal@compuserve.com>
             and Steve Williams <stevewilliams@kromestudios.com>.
Nov 08, 2000 V4.23 Moved FSelectEvent from private to protected section.
Nov 11, 2000 V4.24 Added LineLimit property and OnLineLimitExceeded event.
             When using line mode, line length is checked as each data block is
             comming. If the length is greater than the limit, then the event
             is triggered. You have the opportunity to close the socket or
             change the limit to a higher value. Thus you can prevent a hacker
             from locking your system by sending unlimited line which otherwise
             would eat up all system resources.
             Changed line handling variables to LongInt
             Checked all length involved in StrPCopy calls.
Nov 26, 2000 V4.25 Do not trust GetRcvdCount. Always call Receive to check for
             incomming data (sometime NT4 will hang if we don't do that).
Jan 24, 2001 V4.26 Blaine R Southam <bsoutham@iname.com> fixed out of bound
             error in TCustomLineWSocket.TriggerDataAvailable
Feb 17, 2001 V4.27 Davie <smatters@smatters.com> fixed a bug causing byte lost
             when closing (related to wsoNoReceiveLoop option).
May 04, 2001 V4.28 Fixed W2K bug (winsock message ordering)
Jun 18, 2001 V4.29 Added AllocateHWnd and DeallocateHWnd from Forms unit to
             avoid warning from Delphi 6 in all other components.
Jul 08, 2001 V4.30 Fixed small bug related to NOFOMRS and V4.29
Jul 26, 2001 V4.31 Checked csDesigning in GetRcvdCount so that Delphi 6 does'nt
             crash when object inspector wants to display RcvdCount value.
             Added multicast capability and UDP ReuseAddr. Thanks to Mark
             G. Lewis <Lewis@erg.sri.com> for his code.
             Added TriggerSessionClosed to SocketError as suggested by Wilfried
             Mestdagh <wilfried_sonal@compuserve.com>
Jul 28, 2001 V4.32 New option wsoTcpNoDelay implemented. Code by Arnaldo Braun
             <abraun@th.com.br>
Jul 30, 2001 V4.33 Corrected at few glitches with Delphi 1
Sep 08, 2001 V4.34 Added ThreadAttach and related functions
Nov 27, 2001 V4.35 Added type definition for in_addr and Delphi 2 (Yes there are
             still some peoples who wants to use it. Don't ask me why !).
Dec 02, 2001 V4.36 david.brock2@btinternet.com found a bug in SOCKS4 where
             error check incorrectly checked "FRcvBuf[1] = #$90" instead of
             "FRcvBuf[1] <> #90". He also found a bug when receiving domain name
             where length of name was incorrectly copyed to the buffer.
Dec 23, 2001 V4.37 Removed bWrite, nMoreCnt, bMoreFlag and nMoreMax which where
             not more really used. Thanks to Al Kirk <akirk@pacific.net> for
             showing that.
Feb 24, 2002 V4.38 Wilfried Mestdagh <wilfried@mestdagh.biz> added ThreadDetach
             and a property editor for LineEnd. XSocketDeallocateHWnd made a
             function.
             I created a new unit WSocketE.pas to put Wilfried's property
             editor so that it works correctly with Delphi 6.
Apr 24, 2002 V4.39 Removed OnLineTooLong event which was not used anywhere.
             Use OnLineLimitExceeded event if you used this event.
             Thanks to Alex Kook <cookis@mail.ru> for finding this one.
Apr 27, 2002 V4.40 Added procedure WSocketUnregisterClass to be able to
             unregister hidden window. This is necessary when TWSocket is
             used within a DLL which is unloaded and reloaded by applications,
             specially when running with Windows-XP. Thanks to Jean-Michel Aliu
             <jmaliu@jmasoftware.com> who provided a test case.
Jun 02, 2002 V4.41 allow SOCK_RAW in Connect method for any protocol which is
             not TCP or UDP. Thanks to Holger Lembke <holger@hlembke.de>.
Jun 04, 2002 V4.42 Do not call Listen for SOCK_RAW.
             Thanks to Holger Lembke <holger@hlembke.de>.
Jun 08, 2002 V4.43 Add a dummy Register procedure for BCB1.
             Thanks to Marc-Alexander Prowe <listen@mohajer.de>.
Jul 07, 2002 V4.44 Added code in Connect method to check if socket still opened
             after OnChangeState event. If not, trigger an error WSAINVAL.
Sep 16, 2002 V4.45 Exposed RcvdPtr and RcvdCnt readonly properties.
Sep 17, 2002 V4.46 Used InterlockedIncrement/InterlockedDecrement to Inc/Dec
             socket count safely when TWSocket is used within a thread. This
             was proposed by Matthew Meadows <matthew.meadows@inquisite.com>
Sep 28, 2002 V4.47 Changed DnsLookup so that a hostname is checked for dotted
             IP addresse and resolve it numerically. Thanks to Bogdan Calin
             <soul4blade@yahoo.com> who found this bug. Alos loaded the result
             list with the address to be consistant with real lookup result.
Nov 17, 2002 V4.48 Roland Klabunde <roland.klabunde@gmx.net> found a bug in
             multicast code: listening on a specific interface was ignored.
             He fixed Listen and Connect.
Nov 27, 2002 V4.49 Added ListenBacklog property, default to 5.
Dec 17, 2002 V4.50 Moved code to virtual function to permit SSL implementation.
Jan 19, 2003 V5.00 First pre-release for ICS-SSL. New major version number
             V5.01 Gabi Slonto <buffne01@gmx.net> found a bug in DnsLookup
             when hostname was actulally a dotted IP address.
Mar 18, 2003 V5.02 Fixed WSocketIsDottedIP: reordering of boolean expressions
             involaving a string. Thanks to Ian Baker <ibaker@codecutters.org>
Apr 30, 2003 V5.03 Replaced all calls to setsockopt by calls to
             WSocket_setsockopt to avoid statically linked winsock DLL.
             Thanks to Piotr Dalek <enigmatical@interia.pl>.
             Also replaced inet_addr by WSocket_iniet_addr.
Aug 27, 2003 V5.04 Marco van de Voort <marcov@stack.nl> added FreePascal (FPC)
             conditional compilation. Please contact him for any FPC support
             question.
Aug 28, 2003 V5.05 Fixed a multithreading issue related to windows class
             registration. Now using a critical section around the code.
             Thanks to Bogdan Ureche <bureche@omnivex.com> for his precious help.
Aug 31, 2003 V5.06 Added warning about deprecated procedures Synchronize,
             WaitUntilReady and ReadLine. Do not use them in new applications.
Sep 03, 2003 V5.07 Bogdan Ureche <bureche@omnivex.com> added a critical section
             to avoid problem when winsock.dll is unloaded by a thread while
             another thread is still using some TWSocket.
Sep 15, 2003 V5.08 Fixed finalization section to no free critical section if
             a TWSocket is still existing. This happend for example when a
             TWSocket is on a form and Halt is called from FormCreate event.
             Changed SendStr argument to const.
Nov 09, 2003 V5.09 Added manifest constants for Shutdown
             Added TCustomLineWSocket.SendLine method.
Jan 16, 2004 V5.10 Added "const" in front of all method using strings.
Jan 17, 2004 V5.11 Modified TriggerDataAvailable so that when in LineMode, we
             check if a line is still in the buffer of already received data.
             Also updated WMTriggerDataAvailable to avoid infinite loops.
             Introduced FLineFound to flag when a line has been found.
             See "OLD_20040117" to find this code.
Jan 21, 2004 V5.12 Checked null string in PutStringInSendBuffer and null
             pointer in PutDataInSendBuffer.
Jan 26, 2004 V5.13 Conditional compilation for BCB for constants for Shutdown.
             Reordered uses clause for FPC compatibility.
             Fixed TCustomLineWSocket.TriggerDataAvailable to deliver data
             already received while in line mode but after component user
             turned line mode off in the middle of the way. This could occur
             for example in a HTTP application where line mode is used to
             receive HTTP header line and turned off when last header line is
             found. At that point, if posted data (HTTP document) was completely
             in the same packet as the last header line, that data was not
             delivered until the next packet comes, which could never occur !
Mar 20, 2004 V5.14 Added partial support for RAW socket.
             To use RAW sockets, set Proto to 'raw_ip', 'raw_icmp', ...
             Set Port to '0' or whatever value is useful for the protocol.
             When using IP protocol, you can add option wsoSIO_RCVALL so that
             your program receive ALL datagrams when you listen on a given
             interface (You can't use 0.0.0.0).
             Do not use Connect with RAW socket. Always use Listen and then
             use SendTo to send datagrams use the socket.
             Added ReqVerHigh and ReqVerLow properties to be able to select
             which winsock version you want to load. Default to 1.1 but need
             2.2 for RAW sockets to be used.
Mar 24, 2004 V5.15 Changed WSocket_Synchronized_ResolveProto to hard code
             protocol number for tcp, udp and raw.
Jun 20, 2004 V 5.16 John Mulvey <john@mulvey.eurobell.co.uk> fixed error message
             in GetPeerAddr which incorrectly reported an error about
             GetPeerName.


About multithreading and event-driven:
    TWSocket is a pure asynchronous component. It is non-blocking and
    event-driven. It means that when you request an operation such as connect,
    the component start the operation your requested and give control back
    immediately while performing the operation in the background automatically.
    When the operation is done, an event is triggered (such as
    OnSessionConnected if you called Connect).

    This asynchronous non-blocking behaviour is very high performance but a
    little bit difficult to start with. For example, you can't call Connect and
    immediately call SendStr the line below. If you try, you'll have an
    exception triggered saying you are not connected. Calling connect will start
    connection process but will return long before connection is established.
    Calling SendStr at the next line will not work because the socket is not
    connected yet. To make it works the right way, you have to put your SendStr
    in the OnSessionConnected event.

    The asynchronous operation allows you to do several TCP/IP I/O
    simultaneously. Just use as many component as you need. Each one will
    operate independently of the other without blocking each other ! So you
    basically don't need multi-threading with TWSocket, unless YOUR processing
    is lengthy and blocking.

    If you have to use multithreading, you have two possibilities:
    1) Create your TWSocket from your thread's Execute method
    2) Attach a TWSocket to a given thread using ThreadAttach.
    In both cases, you must set MultiThreaded property to TRUE.
    If you don't use one of those methods, you'll end up with a false
    multithreaded program: all events will be processed by the main tread !
    For both methods to work, you MUST have a message loop withing your thread.
    Delphi create a message loop automatically for the main thread (it's in
    the Forms unit), but does NOT create one in a thread ! For your convenience,
    TWSocket has his own MessageLoop procedure. You can use it from your thread.

    Sample program MtSrv uses first method while ThrdSrv uses second method.
    Sample program TcpSrv is much the same as ThrdSrv but doesn't use any
    thread. You'll see that it is able to server a lot of simultaneous clients
    as well and it is much simpler.


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit WSocket;

{$B-}              { Enable partial boolean evaluation   }
{$T-}              { Untyped pointers                    }
{$X+}              { Enable extended syntax              }
{$I ICSDEFS.INC}
{$IFDEF DELPHI6_UP}
    {$WARN SYMBOL_PLATFORM   OFF}
    {$WARN SYMBOL_LIBRARY    OFF}
    {$WARN SYMBOL_DEPRECATED OFF}
{$ENDIF}
{$IFDEF COMPILER2_UP}{ Not for Delphi 1                    }
    {$H+}            { Use long strings                    }
    {$J+}            { Allow typed constant to be modified }
{$ENDIF}
{$IFDEF BCB3_UP}
    {$ObjExportAll On}
{$ENDIF}

{ If NO_ADV_MT is defined, then there is less multithread code compiled.    }
{$IFDEF DELPHI1}
    {$DEFINE NO_ADV_MT}
{$ENDIF}

interface

uses

  Messages,
{$IFDEF USEWINDOWS}
  Windows,
{$ELSE}
  WinTypes, WinProcs,
{$ENDIF}
  Classes, SysUtils,
{$IFNDEF NOFORMS} { See comments in history at 14/02/99 }
  Forms,
{$ENDIF}
{ You must define USE_SSL so that SSL code is included in the component.    }
{ To be able to compile the component, you must have the SSL related files  }
{ which are _NOT_ freeware. See http://www.overbyte.be for details.         }
{$IFDEF USE_SSL}
  IcsSSLEAY, IcsLIBEAY,
{$ENDIF}
  WSockBuf, WinSock;

{var
  LogStream : TFileStream;}

const
  WSocketVersion            = 516;
  CopyRight    : String     = ' TWSocket (c) 1996-2004 Francois Piette V5.16 ';
  WM_ASYNCSELECT            = WM_USER + 1;
  WM_ASYNCGETHOSTBYNAME     = WM_USER + 2;
  WM_ASYNCGETHOSTBYADDR     = WM_USER + 3;
  WM_CLOSE_DELAYED          = WM_USER + 4;
  WM_WSOCKET_RELEASE        = WM_USER + 5;
  WM_TRIGGER_EXCEPTION      = WM_USER + 6;
  WM_TRIGGER_DATA_AVAILABLE = WM_USER + 20;
  WSA_WSOCKET_TIMEOUT       = 12001;
{$IFNDEF BCB}
  { Manifest constants for Shutdown }
  SD_RECEIVE                = 0;
  SD_SEND                   = 1;  { Use this one for graceful close }
  SD_BOTH                   = 2;
{$ENDIF}
{$IFDEF WIN32}
  winsocket  = 'wsock32.dll';      { 32 bits TCP/IP system DLL }
  winsocket2 = 'ws2_32.dll';       { 32 bits TCP/IP system DLL version 2}
{$ELSE}
  winsocket = 'winsock.dll';      { 16 bits TCP/IP system DLL }
{$ENDIF}

type

  TWndMethod         = procedure(var Message: TMessage) of object;
  ESocketException   = class(Exception);
  TBgExceptionEvent  = procedure (Sender : TObject;
                                  E : Exception;
                                  var CanClose : Boolean) of object;

  TSocketState       = (wsInvalidState,
                        wsOpened,     wsBound,
                        wsConnecting, wsSocksConnected, wsConnected,
                        wsAccepting,  wsListening,
                        wsClosed);
  TSocketSendFlags   = (wsSendNormal, wsSendUrgent);
  TSocketLingerOnOff = (wsLingerOff, wsLingerOn, wsLingerNoSet);
  TSockAddr          = Winsock.TSockAddr;

  TDataAvailable     = procedure (Sender: TObject; ErrCode: Word) of object;
  TDataSent          = procedure (Sender: TObject; ErrCode: Word) of object;
  TSendData          = procedure (Sender: TObject; BytesSent: Integer) of object;
  TSessionClosed     = procedure (Sender: TObject; ErrCode: Word) of object;
  TSessionAvailable  = procedure (Sender: TObject; ErrCode: Word) of object;
  TSessionConnected  = procedure (Sender: TObject; ErrCode: Word) of object;
  TDnsLookupDone     = procedure (Sender: TObject; ErrCode: Word) of object;
  TChangeState       = procedure (Sender: TObject;
                                 OldState, NewState : TSocketState) of object;
  TDebugDisplay      = procedure (Sender: TObject; var Msg : String) of object;
  TWSocketSyncNextProc = procedure of object;
  TWSocketOption       = (wsoNoReceiveLoop, wsoTcpNoDelay, wsoSIO_RCVALL);
  TWSocketOptions      = set of TWSocketOption;
{$IFDEF DELPHI4_UP}
  { TSocket type definition has been removed starting from Delphi 4 }
  TSocket = u_int;
{$ENDIF}

  TCustomWSocket = class(TComponent)
  private
    FDnsResult          : String;
    FDnsResultList      : TStrings;
    FSendFlags          : Integer;
    FLastError          : Integer;
    FWindowHandle       : HWND;
    FDnsLookupBuffer    : array [0..MAXGETHOSTSTRUCT] of char;
    FDnsLookupCheckMsg  : Boolean;
    FDnsLookupTempMsg   : TMessage;
  {$IFDEF DELPHI1}
    FTrumpetCompability : Boolean;
  {$ENDIF}
  protected
    FHSocket            : TSocket;
    FASocket            : TSocket;               { Accepted socket }
    FAddrStr            : String;
    FAddrResolved       : Boolean;
    FAddrFormat         : Integer;
    FAddrAssigned       : Boolean;
    FProto              : integer;
    FProtoAssigned      : Boolean;
    FProtoResolved      : Boolean;
    FLocalPortResolved  : Boolean;
    FProtoStr           : String;
    FPortStr            : String;
    FPortAssigned       : Boolean;
    FPortResolved       : Boolean;
    FPortNum            : Integer;
    FLocalPortStr       : String;
    FLocalPortNum       : Integer;
    FLocalAddr          : String;     { IP address for local interface to use }
    FType               : Integer;
    FBufList            : TList;
    FBufSize            : Integer;
    FLingerOnOff        : TSocketLingerOnOff;
    FLingerTimeout      : Integer;              { In seconds, 0 = disabled }
    FListenBacklog      : Integer;
    ReadLineCount       : Integer;
    bAllSent            : Boolean;
    FReadCount          : LongInt;
    FPaused             : Boolean;
    FCloseInvoked       : Boolean;
    FFlushTimeout       : Integer;
    FMultiThreaded      : Boolean;
    FDnsLookupHandle    : THandle;
    { More info about multicast can be found at:                              }
    {    http://ntrg.cs.tcd.ie/undergrad/4ba2/multicast/antony/               }
    {    http://www.tldp.org/HOWTO/Multicast-HOWTO-6.html                     }
    FMultiCast          : Boolean;
    { Multicast addresses consists of a range of addresses from 224.0.0.0 to  }
    { 239.255.255.255. However, the multicast addresses from 224.0.0.0 to     }
    { 224.0.0.255 are reserved for multicast routing information; Application }
    { programs should use multicast addresses outside this range.             }
    FMultiCastAddrStr   : String;
    FMultiCastIpTTL     : Integer;
    FReuseAddr          : Boolean;
    FComponentOptions   : TWSocketOptions;
    FState              : TSocketState;
    FRcvdFlag           : Boolean;
    FTerminated         : Boolean;
    FSelectEvent        : LongInt;
    FSelectMessage      : WORD;
    FOnSessionAvailable : TSessionAvailable;
    FOnSessionConnected : TSessionConnected;
    FOnSessionClosed    : TSessionClosed;
    FOnChangeState      : TChangeState;
    FOnDataAvailable    : TDataAvailable;
    FOnDataSent         : TDataSent;
    FOnSendData         : TSendData;
    { FOnLineTooLong      : TNotifyEvent; }
    FOnDnsLookupDone    : TDnsLookupDone;
    FOnError            : TNotifyEvent;
    FOnBgException      : TBgExceptionEvent;
    FOnDisplay          : TDebugDisplay;
    FOnMessagePump      : TNotifyEvent;
    FThreadId           : THandle;
    procedure   WndProc(var MsgRec: TMessage); virtual;
    procedure   AllocateSocketHWnd; virtual;
    procedure   DeallocateSocketHWnd; virtual;
    procedure   SocketError(sockfunc: string);
    procedure   WMASyncSelect(var msg: TMessage); message WM_ASYNCSELECT;
    procedure   WMAsyncGetHostByName(var msg: TMessage); message WM_ASYNCGETHOSTBYNAME;
    procedure   WMAsyncGetHostByAddr(var msg: TMessage); message WM_ASYNCGETHOSTBYADDR;
    procedure   WMCloseDelayed(var msg: TMessage); message WM_CLOSE_DELAYED;
    procedure   WMRelease(var msg: TMessage); message WM_WSOCKET_RELEASE;
    procedure   ChangeState(NewState : TSocketState);
    procedure   TryToSend; virtual;
    procedure   ASyncReceive(Error : Word; MySocketOptions : TWSocketOptions);
    procedure   AssignDefaultValue; virtual;
    procedure   InternalClose(bShut : Boolean; Error : Word); virtual;
    procedure   InternalAbort(ErrCode : Word); virtual;
    procedure   Notification(AComponent: TComponent; operation: TOperation); override;
    procedure   SetSendFlags(newValue : TSocketSendFlags);
    function    GetSendFlags : TSocketSendFlags;
    procedure   SetAddr(InAddr : String);
    function    GetAddr : String;
    procedure   SetRemotePort(sPort : String); virtual;
    function    GetRemotePort : String;
    procedure   SetLocalAddr(sLocalAddr : String);
    procedure   SetLocalPort(sLocalPort : String);
    procedure   SetProto(sProto : String); virtual;
    function    GetProto : String;
    function    GetRcvdCount : LongInt; virtual;
    procedure   BindSocket; virtual;
    procedure   SendText(Str : String);
    function    RealSend(Data : Pointer; Len : Integer) : Integer; virtual;
    procedure   RaiseExceptionFmt(const Fmt : String; args : array of const); virtual;
    procedure   RaiseException(const Msg : String); virtual;
    procedure   HandleBackGroundException(E: Exception); virtual;
    function    GetReqVerLow: BYTE;
    procedure   SetReqVerLow(const Value: BYTE);
    function    GetReqVerHigh: BYTE;
    procedure   SetReqVerHigh(const Value: BYTE);
    procedure   TriggerDisplay(Msg : String);
    procedure   TriggerSendData(BytesSent : Integer);
    function    TriggerDataAvailable(Error : Word) : Boolean; virtual;
    procedure   TriggerSessionAvailable(Error : Word); virtual;
    procedure   TriggerSessionConnectedSpecial(Error : Word); virtual;
    procedure   TriggerSessionConnected(Error : Word); virtual;
    procedure   TriggerSessionClosed(Error : Word); virtual;
    procedure   TriggerDataSent(Error : Word); virtual;
    procedure   TriggerChangeState(OldState, NewState : TSocketState); virtual;
    procedure   TriggerDNSLookupDone(Error : Word); virtual;
    procedure   TriggerError; virtual;
    function    DoRecv(var Buffer;
                       BufferSize : Integer;
                       Flags      : Integer) : Integer; virtual;
    function    DoRecvFrom(FHSocket    : TSocket;
                           var Buffer;
                           BufferSize  : Integer;
                           Flags       : Integer;
                           var From    : TSockAddr;
                           var FromLen : Integer) : Integer; virtual;
    procedure Do_FD_CONNECT(var msg: TMessage); virtual;
    procedure Do_FD_READ(var msg: TMessage); virtual;
    procedure Do_FD_WRITE(var msg: TMessage); virtual;
    procedure Do_FD_ACCEPT(var msg: TMessage); virtual;
    procedure Do_FD_CLOSE(var msg: TMessage); virtual;
    procedure DupConnected; virtual;
  public
    sin         : TSockAddrIn;
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   Connect; virtual;
    procedure   Close; virtual;
    procedure   CloseDelayed; virtual;
    procedure   Release; virtual;
    procedure   Abort; virtual;
    procedure   Flush; virtual;
    procedure   WaitForClose; virtual;
    procedure   Listen; virtual;
    function    Accept: TSocket; virtual;
    function    Receive(Buffer : Pointer; BufferSize: integer) : integer; virtual;
    function    ReceiveStr : string; virtual;
    function    ReceiveFrom(Buffer      : Pointer;
                            BufferSize  : Integer;
                            var From    : TSockAddr;
                            var FromLen : Integer) : integer; virtual;
    function    PeekData(Buffer : Pointer; BufferSize: integer) : integer;
    function    Send(Data : Pointer; Len : Integer) : integer; virtual;
    function    SendTo(Dest    : TSockAddr;
                       DestLen : Integer;
                       Data    : Pointer;
                       Len     : Integer) : integer; virtual;
    function    SendStr(const Str : String) : Integer; virtual;
    procedure   DnsLookup(const AHostName : String); virtual;
    procedure   ReverseDnsLookup(const HostAddr: String); virtual;
    procedure   CancelDnsLookup; virtual;
    function    GetPeerAddr: string; virtual;
    function    GetPeerPort: string; virtual;
    function    GetPeerName(var Name : TSockAddrIn; NameLen : Integer) : integer; virtual;
    function    GetXPort: string; virtual;
    function    GetXAddr: string; virtual;
    function    TimerIsSet(var tvp : TTimeVal) : Boolean; virtual;
    procedure   TimerClear(var tvp : TTimeVal); virtual;
    function    TimerCmp(var tvp : TTimeVal; var uvp : TTimeVal; IsEqual : Boolean) : Boolean; virtual;
    function    GetSockName(var saddr : TSockAddrIn; var saddrlen : Integer) : integer; virtual;
    procedure   SetLingerOption;
    procedure   Dup(NewHSocket : TSocket); virtual;
    procedure   Shutdown(How : Integer); virtual;
    procedure   Pause; virtual;
    procedure   Resume; virtual;
    procedure   PutDataInSendBuffer(Data : Pointer; Len : Integer);
    procedure   PutStringInSendBuffer(const Str : String);
    procedure   DeleteBufferedData;
    procedure   MessagePump; virtual;
{$IFDEF COMPILER2_UP}
    procedure   ThreadAttach;
    procedure   ThreadDetach;
    procedure   MessageLoop;
    function    ProcessMessage : Boolean;
    procedure   ProcessMessages;
{$ENDIF}
{$IFDEF NOFORMS}
    property    Terminated         : Boolean        read  FTerminated
                                                    write FTerminated;
    property    OnMessagePump      : TNotifyEvent   read  FOnMessagePump
                                                    write FOnMessagePump;
{$ENDIF}
  protected
    property PortNum : Integer                      read  FPortNum;
    property Handle : HWND                          read  FWindowHandle;
    property HSocket : TSocket                      read  FHSocket
                                                    write Dup;

    property Addr : string                          read  GetAddr
                                                    write SetAddr;
    property Port : string                          read  GetRemotePort
                                                    write SetRemotePort;
    property LocalPort : String                     read  FLocalPortStr
                                                    write SetLocalPort;
    property LocalAddr : String                     read  FLocalAddr
                                                    write SetLocalAddr;
    property Proto : String                         read  GetProto
                                                    write SetProto;
    property MultiThreaded   : Boolean              read  FMultiThreaded
                                                    write FMultiThreaded;
    property MultiCast       : Boolean              read  FMultiCast
                                                    write FMultiCast;
    property MultiCastAddrStr: String               read  FMultiCastAddrStr
                                                    write FMultiCastAddrStr;
    property MultiCastIpTTL  : Integer              read  FMultiCastIpTTL
                                                    write FMultiCastIpTTL;
    property ReuseAddr       : Boolean              read  FReuseAddr
                                                    write FReuseAddr;
    property PeerAddr : String                      read  GetPeerAddr;
    property PeerPort : String                      read  GetPeerPort;
    property DnsResult : String                     read  FDnsResult;
    property DnsResultList : TStrings               read  FDnsResultList;
    property State : TSocketState                   read  FState;
    property AllSent   : Boolean                    read  bAllSent;
    property ReadCount : LongInt                    read  FReadCount;
    property RcvdCount : LongInt                    read  GetRcvdCount;
    property LastError : Integer                    read  FLastError;
    property ComponentOptions : TWSocketOptions     read  FComponentOptions
                                                    write FComponentOptions;
    property BufSize   : Integer                    read  FBufSize
                                                    write FBufSize;
    property ListenBacklog : Integer                read  FListenBacklog
                                                    write FListenBacklog;
    property ReqVerLow       : BYTE                 read  GetReqVerLow
                                                    write SetReqVerLow;
    property ReqVerHigh      : BYTE                 read  GetReqVerHigh
                                                    write SetReqVerHigh;
    property OnDataAvailable : TDataAvailable       read  FOnDataAvailable
                                                    write FOnDataAvailable;
    property OnDataSent      : TDataSent            read  FOnDataSent
                                                    write FOnDataSent;
    property OnSendData      : TSendData            read  FOnSendData
                                                    write FOnSendData;
    property OnSessionClosed : TSessionClosed       read  FOnSessionClosed
                                                    write FOnSessionClosed;
    property OnSessionAvailable : TSessionAvailable read  FOnSessionAvailable
                                                    write FOnSessionAvailable;
    property OnSessionConnected : TSessionConnected read  FOnSessionConnected
                                                    write FOnSessionConnected;
    property OnChangeState      : TChangeState      read  FOnChangeState
                                                    write FOnChangeState;
    { property OnLineTooLong      : TNotifyEvent      read  FOnLineTooLong
                                                    write FOnLineTooLong; }
    property OnDnsLookupDone    : TDnsLookupDone    read  FOnDnsLookupDone
                                                    write FOnDnsLookupDone;
    property OnError            : TNotifyEvent      read  FOnError
                                                    write FOnError;
    property OnBgException      : TBgExceptionEvent read  FOnBgException
                                                    write FOnBgException;

    property FlushTimeout : Integer                 read  FFlushTimeOut
                                                    write FFlushTimeout;
    property SendFlags : TSocketSendFlags           read  GetSendFlags
                                                    write SetSendFlags;
    property Text: String                           read  ReceiveStr
                                                    write SendText;
    property LingerOnOff   : TSocketLingerOnOff     read  FLingerOnOff
                                                    write FLingerOnOff;
    property LingerTimeout : Integer                read  FLingerTimeout
                                                    write FLingerTimeout;
{$IFDEF DELPHI1}
    property TrumpetCompability : Boolean           read  FTrumpetCompability
                                                    write FTrumpetCompability;
{$ENDIF}
    property OnDisplay : TDebugDisplay              read  FOnDisplay
                                                    write FOnDisplay;
  end;

  TSocksState          = (socksData, socksNegociateMethods, socksAuthenticate, socksConnect);
  TSocksAuthentication = (socksNoAuthentication, socksAuthenticateUsercode);
  TSocksAuthState      = (socksAuthStart, socksAuthSuccess, socksAuthFailure, socksAuthNotRequired);
  TSocksAuthStateEvent = procedure(Sender : TObject; AuthState : TSocksAuthState) of object;
  TSocksErrorEvent     = procedure(Sender : TObject; Error : Integer; Msg : String) of Object;

  TCustomSocksWSocket = class(TCustomWSocket)
  protected
      FSocksState          : TSocksState;
      FSocksServer         : String;
      FSocksLevel          : String;
      FSocksPort           : String;
      FSocksPortAssigned   : Boolean;
      FSocksServerAssigned : Boolean;
      FSocksUsercode       : String;
      FSocksPassword       : String;
      FSocksAuthentication : TSocksAuthentication;
      FSocksAuthNumber     : char;
      FBoundAddr           : String;
      FBoundPort           : String;
      FRcvBuf              : array [0..127] of char;
      FRcvCnt              : Integer;
      FSocksRcvdCnt        : Integer;
      FSocksRcvdPtr        : PChar;
      FOnSocksError        : TSocksErrorEvent;
      FOnSocksConnected    : TSessionConnected;
      FOnSocksAuthState    : TSocksAuthStateEvent;
      procedure   AssignDefaultValue; override;
      procedure   TriggerSessionConnectedSpecial(Error : Word); override;
      procedure   TriggerSocksConnected(Error : Word); virtual;
      procedure   TriggerSessionClosed(Error : Word); override;
      function    TriggerDataAvailable(Error : Word) : Boolean; override;
      procedure   SetSocksPort(sPort : String); virtual;
      procedure   SetSocksServer(sServer : String); virtual;
      procedure   TriggerSocksError(Error : Integer; Msg : String); virtual;
      procedure   TriggerSocksAuthState(AuthState : TSocksAuthState);
      function    GetRcvdCount : LongInt; override;
      procedure   SetSocksLevel(newValue : String);
      function    DoRecv(var Buffer;
                         BufferSize : Integer;
                         Flags      : Integer) : Integer; override;
      procedure   SocksDoConnect;
      procedure   SocksDoAuthenticate;
      procedure   DataAvailableError(ErrCode : Integer; Msg : String);
  public
      procedure   Connect; override;
      procedure   Listen; override;
  protected
      property SocksServer   : String               read  FSocksServer
                                                    write SetSocksServer;
      property SocksLevel    : String               read  FSocksLevel
                                                    write SetSocksLevel;
      property SocksPort     : String               read  FSocksPort
                                                    write SetSocksPort;
      property SocksUsercode : String               read  FSocksUsercode
                                                    write FSocksUsercode;
      property SocksPassword : String               read  FSocksPassword
                                                    write FSocksPassword;
      property SocksAuthentication : TSocksAuthentication
                                                    read  FSocksAuthentication
                                                    write FSocksAuthentication;
      property OnSocksError  : TSocksErrorEvent     read  FOnSocksError
                                                    write FOnSocksError;
      property OnSocksConnected : TSessionConnected read  FOnSocksConnected
                                                    write FOnSocksConnected;
      property OnSocksAuthState : TSocksAuthStateEvent
                                                    read  FOnSocksAuthState
                                                    write FOnSocksAuthState;
  end;

{ You must define USE_SSL so that SSL code is included in the component.    }
{ To be able to compile the component, you must have the SSL related files  }
{ which are _NOT_ freeware. See http://www.overbyte.be for details.         }
{$IFDEF USE_SSL}
    {$I WSocketIntfSsl.inc}
{$ENDIF}

  TLineLimitEvent = procedure (Sender        : TObject;
                               RcvdLength    : LongInt;
                               var ClearData : Boolean) of object;
                               
{ You must define USE_SSL so that SSL code is included in the component.    }
{ To be able to compile the component, you must have the SSL related files  }
{ which are _NOT_ freeware. See http://www.overbyte.be for details.         }
{$IFDEF USE_SSL}
  TCustomLineWSocket = class (TCustomSslWSocket)
{$ELSE}
  TCustomLineWSocket = class (TCustomSocksWSocket)
{$ENDIF}
  protected
      FRcvdPtr             : PChar;
      FRcvBufSize          : LongInt;
      FRcvdCnt             : LongInt;
      FLineEnd             : String;
      FLineMode            : Boolean;
      FLineLength          : Integer;    { When a line is available  }
      FLineLimit           : LongInt;    { Max line length we accept }
      FLineReceivedFlag    : Boolean;
      FLineFound           : Boolean;
      FLineClearData       : Boolean;
      FLineEcho            : Boolean;    { Echo received data    }
      FLineEdit            : Boolean;    { Edit received data    }
      FTimeout             : LongInt;    { Given in milliseconds }
      FTimeStop            : LongInt;    { Milliseconds          }
      FOnLineLimitExceeded : TLineLimitEvent;
      procedure   WndProc(var MsgRec: TMessage); override;
      procedure   WMTriggerDataAvailable(var msg: TMessage); message WM_TRIGGER_DATA_AVAILABLE;
      function    TriggerDataAvailable(Error : Word) : Boolean; override;
      procedure   TriggerSessionClosed(Error : Word); override;
      procedure   TriggerLineLimitExceeded(Cnt: Integer;
                                           var ClearData : Boolean); virtual;
      procedure   SetLineMode(newValue : Boolean); virtual;
      procedure   EditLine(var Len : Integer); virtual;
      function    GetRcvdCount : LongInt; override;
      function    DoRecv(var Buffer;
                         BufferSize : Integer;
                         Flags      : Integer) : Integer; override;
  public
      constructor Create(AOwner: TComponent); override;
      destructor  Destroy; override;
      function    SendLine(const Str : String) : Integer; virtual;
      property    LineLength : Integer     read  FLineLength;
      property    RcvdPtr    : PChar       read  FRcvdPtr;
      property    RcvdCnt    : LongInt     read  FRcvdCnt;
  published
      property LineMode : Boolean          read  FLineMode
                                           write SetLineMode;
      property LineLimit : LongInt         read  FLineLimit
                                           write FLineLimit;
      property LineEnd  : String           read  FLineEnd
                                           write FLineEnd;
      property LineEcho : Boolean          read  FLineEcho
                                           write FLineEcho;
      property LineEdit : Boolean          read  FLineEdit
                                           write FLineEdit;
      property OnLineLimitExceeded : TLineLimitEvent
                                           read  FOnLineLimitExceeded
                                           write FOnLineLimitExceeded;
  end;

  { DEPRECATED: DO NOT USE Synchronize, WaitUntilReady, ReadLine procedure }
  { for a new application.                                                 }
  TCustomSyncWSocket = class(TCustomLineWSocket)
  protected
      FLinePointer : ^String;
      function    Synchronize(Proc         : TWSocketSyncNextProc;
                              var DoneFlag : Boolean) : Integer; virtual;
      function    WaitUntilReady(var DoneFlag : Boolean) : Integer; virtual;
      procedure   InternalDataAvailable(Sender: TObject; Error: Word);
  public
      procedure   ReadLine(Timeout : integer; var Buffer : String);
  end;

  TWSocket = class(TCustomSyncWSocket)
  public
    property PortNum;
    property Handle;
    property HSocket;
    property BufSize;
    property Text;
    property AllSent;
  {$IFDEF DELPHI1}
    property TrumpetCompability;
  {$ENDIF}
    property OnDisplay;
  published
    property Addr;
    property Port;
    property Proto;
    property LocalAddr;
    property LocalPort;
    property PeerPort;
    property PeerAddr;
    property DnsResult;
    property DnsResultList;
    property State;
    property ReadCount;
    property RcvdCount;
    property LastError;
    property MultiThreaded;
    property MultiCast;
    property MultiCastAddrStr;
    property MultiCastIpTTL;
    property ReuseAddr;
    property ComponentOptions;
    property ListenBacklog;
    property ReqVerLow;
    property ReqVerHigh;
    property OnDataAvailable;
    property OnDataSent;
    property OnSendData;
    property OnSessionClosed;
    property OnSessionAvailable;
    property OnSessionConnected;
    property OnSocksConnected;
    property OnChangeState;
    { property OnLineTooLong; }
    property OnDnsLookupDone;
    property OnError;
    property OnBgException;
    property FlushTimeout;
    property SendFlags;
    property LingerOnOff;
    property LingerTimeout;
    property SocksLevel;
    property SocksServer;
    property SocksPort;
    property SocksUsercode;
    property SocksPassword;
    property SocksAuthentication;
    property OnSocksError;
    property OnSocksAuthState;
  end;

  TSocksWSocket = class(TWSocket)
  end;

{ You must define USE_SSL so that SSL code is included in the component.    }
{ To be able to compile the component, you must have the SSL related files  }
{ which are _NOT_ freeware. See http://www.overbyte.be for details.         }
{$IFDEF USE_SSL}
  TSslWSocket = class(TWSocket)
  public
      property  SslVersion;    {<- A.G.}
      property  SslCipher;     {<- A.G.}
      property  SslTotalBits;  {<- A.G.}
      property  SslSecretBits; {<- A.G.}
  published
      property  SslEnable;
      property  SslCertFile;
      property  SslPassPhrase;
      property  SslPrivKeyFile;
      property  SslCAFile;
      property  SslCAPath;
      property  SslVerifyPeer;
      property  SslVerifyPeerMode;
      property  SslVerifyDepth;
      property  SslOptions;
      property  SslVersionMethod;
      property  SslCipherList;
      property  SslAcceptableHosts;
      property  OnSslVerifyPeer;
      property  OnSslHandshakeDone;
      property  OnSslPostConnectionCheckFailed;
      property  OnSslConnectError; {<- A.G.}
  end;
{$ENDIF}

function  WinsockInfo : TWSADATA;
function  WSocketErrorDesc(error: integer) : string;
function  WSocketGetHostByAddr(Addr : String) : PHostEnt;
function  WSocketGetHostByName(Name : String) : PHostEnt;
function  LocalHostName : String;
function  LocalIPList : TStrings;
function  WSocketResolveIp(IpAddr : String) : String;
function  WSocketResolveHost(InAddr : String) : TInAddr;
function  WSocketResolvePort(Port : String; Proto : String) : Word;
function  WSocketResolveProto(sProto : String) : integer;
procedure WSocketForceLoadWinsock;
procedure WSocketCancelForceLoadWinsock;
procedure WSocketUnloadWinsock;
function  WSocketIsDottedIP(const S : String) : Boolean;
{ function  WSocketLoadWinsock : Boolean; 14/02/99 }
{$IFDEF COMPILER2_UP}
procedure WSocketUnregisterClass;
{$ENDIF}

type
{$IFDEF DELPHI1}
    DWORD = LongInt;
    TWSAStartup            = function (wVersionRequired: word;
                                       var WSData: TWSAData): Integer;
    TWSACleanup            = function : Integer;
    TWSASetLastError       = procedure (iError: Integer);
    TWSAGetLastError       = function : Integer;
    TWSACancelAsyncRequest = function (hAsyncTaskHandle: THandle): Integer;
    TWSAAsyncGetHostByName = function (HWindow: HWND;
                                       wMsg: u_int;
                                       name, buf: PChar;
                                       buflen: Integer): THandle;
    TWSAAsyncGetHostByAddr = function (HWindow: HWND;
                                       wMsg: u_int; addr: PChar;
                                       len, Struct: Integer;
                                       buf: PChar;
                                       buflen: Integer): THandle;
    TWSAAsyncSelect        = function (s: TSocket;
                                      HWindow: HWND;
                                      wMsg: u_int;
                                      lEvent: Longint): Integer;
    TGetServByName         = function (name, proto: PChar): PServEnt;
    TGetProtoByName        = function (name: PChar): PProtoEnt;
    TGetHostByName         = function (name: PChar): PHostEnt;
    TGetHostByAddr         = function (addr: Pointer; len, Struct: Integer): PHostEnt;
    TGetHostName           = function (name: PChar; len: Integer): Integer;
    TOpenSocket            = function (af, Struct, protocol: Integer): TSocket;
    TShutdown              = function (s: TSocket; how: Integer): Integer;
    TSetSockOpt            = function (s: TSocket; level, optname: Integer;
                                       optval: PChar;
                                       optlen: Integer): Integer; 
    TGetSockOpt            = function (s: TSocket; level, optname: Integer; optval: PChar; var optlen: Integer): Integer; 
    TSendTo                = function (s: TSocket; var Buf;
                                       len, flags: Integer;
                                       var addrto: TSockAddr;
                                       tolen: Integer): Integer; 
    TSend                  = function (s: TSocket; var Buf;
                                       len, flags: Integer): Integer;
    TRecv                  = function (s: TSocket;
                                       var Buf;
                                       len, flags: Integer): Integer; 
    TRecvFrom              = function (s: TSocket;
                                       var Buf; len, flags: Integer;
                                       var from: TSockAddr;
                                       var fromlen: Integer): Integer; 
    Tntohs                 = function (netshort: u_short): u_short;
    Tntohl                 = function (netlong: u_long): u_long;
    TListen                = function (s: TSocket; backlog: Integer): Integer;
    TIoctlSocket           = function (s: TSocket; cmd: DWORD;
                                       var arg: u_long): Integer;
    TInet_ntoa             = function (inaddr: TInAddr): PChar;
    TInet_addr             = function (cp: PChar): u_long;
    Thtons                 = function (hostshort: u_short): u_short;
    Thtonl                 = function (hostlong: u_long): u_long;
    TGetSockName           = function (s: TSocket; var name: TSockAddr;
                                       var namelen: Integer): Integer;
    TGetPeerName           = function (s: TSocket; var name: TSockAddr;
                                       var namelen: Integer): Integer;
    TConnect               = function (s: TSocket; var name: TSockAddr;
                                       namelen: Integer): Integer;
    TCloseSocket           = function (s: TSocket): Integer;
    TBind                  = function (s: TSocket; var addr: TSockAddr;
                                       namelen: Integer): Integer;
    TAccept                = function (s: TSocket; var addr: TSockAddr;
                                       var addrlen: Integer): TSocket;
{$ELSE}
    TWSAStartup            = function (wVersionRequired: word;
                                       var WSData: TWSAData): Integer; stdcall;
    TWSACleanup            = function : Integer; stdcall;
    TWSASetLastError       = procedure (iError: Integer); stdcall;
    TWSAGetLastError       = function : Integer; stdcall;
    TWSACancelAsyncRequest = function (hAsyncTaskHandle: THandle): Integer; stdcall;
    TWSAAsyncGetHostByName = function (HWindow: HWND;
                                       wMsg: u_int;
                                       name, buf: PChar;
                                       buflen: Integer): THandle; stdcall;
    TWSAAsyncGetHostByAddr = function (HWindow: HWND;
                                       wMsg: u_int; addr: PChar;
                                       len, Struct: Integer;
                                       buf: PChar;
                                       buflen: Integer): THandle; stdcall;
    TWSAAsyncSelect        = function (s: TSocket;
                                       HWindow: HWND;
                                       wMsg: u_int;
                                       lEvent: Longint): Integer; stdcall;
    TGetServByName         = function (name, proto: PChar): PServEnt; stdcall;
    TGetProtoByName        = function (name: PChar): PProtoEnt; stdcall;
    TGetHostByName         = function (name: PChar): PHostEnt; stdcall;
    TGetHostByAddr         = function (addr: Pointer; len, Struct: Integer): PHostEnt; stdcall;
    TGetHostName           = function (name: PChar; len: Integer): Integer; stdcall;
    TOpenSocket            = function (af, Struct, protocol: Integer): TSocket; stdcall;
    TShutdown              = function (s: TSocket; how: Integer): Integer; stdcall;
    TSetSockOpt            = function (s: TSocket; level, optname: Integer;
                                       optval: PChar;
                                       optlen: Integer): Integer; stdcall;
    TGetSockOpt            = function (s: TSocket; level, optname: Integer;
                                       optval: PChar;
                                       var optlen: Integer): Integer; stdcall;
    TSendTo                = function (s: TSocket; var Buf;
                                       len, flags: Integer;
                                       var addrto: TSockAddr;
                                       tolen: Integer): Integer; stdcall;
    TSend                  = function (s: TSocket; var Buf;
                                       len, flags: Integer): Integer; stdcall;
    TRecv                  = function (s: TSocket;
                                       var Buf;
                                       len, flags: Integer): Integer; stdcall;
    TRecvFrom              = function (s: TSocket;
                                       var Buf; len, flags: Integer;
                                       var from: TSockAddr;
                                       var fromlen: Integer): Integer; stdcall;
    Tntohs                 = function (netshort: u_short): u_short; stdcall;
    Tntohl                 = function (netlong: u_long): u_long; stdcall;
    TListen                = function (s: TSocket;
                                       backlog: Integer): Integer; stdcall;
    TIoctlSocket           = function (s: TSocket; cmd: DWORD;
                                       var arg: u_long): Integer; stdcall;
    TWSAIoctl              = function (s                 : TSocket;
                                       IoControlCode     : DWORD;
                                       InBuffer          : Pointer;
                                       InBufferSize      : DWORD;
                                       OutBuffer         : Pointer;
                                       OutBufferSize     : DWORD;
                                       var BytesReturned : DWORD;
                                       Overlapped        : POverlapped;
                                       CompletionRoutine : FARPROC): Integer; stdcall;
    TInet_ntoa             = function (inaddr: TInAddr): PChar; stdcall;
    TInet_addr             = function (cp: PChar): u_long; stdcall;
    Thtons                 = function (hostshort: u_short): u_short; stdcall;
    Thtonl                 = function (hostlong: u_long): u_long; stdcall;
    TGetSockName           = function (s: TSocket; var name: TSockAddr;
                                       var namelen: Integer): Integer; stdcall;
    TGetPeerName           = function (s: TSocket; var name: TSockAddr;
                                       var namelen: Integer): Integer; stdcall;
    TConnect               = function (s: TSocket; var name: TSockAddr;
                                       namelen: Integer): Integer; stdcall;
    TCloseSocket           = function (s: TSocket): Integer; stdcall;
    TBind                  = function (s: TSocket; var addr: TSockAddr;
                                       namelen: Integer): Integer; stdcall;
{$IFDEF VER90} { Delphi 2 has a special definition}
    TAccept                = function (s: TSocket; var addr: TSockAddr;
                                       var addrlen: Integer): TSocket; stdcall;
{$ELSE}
    TAccept                = function (s: TSocket; addr: PSockAddr;
                                       addrlen: PInteger): TSocket; stdcall;
{$ENDIF}
{$ENDIF}

var
   FWSAStartup            : TWSAStartup;
   FWSACleanup            : TWSACleanup;
   FWSASetLastError       : TWSASetLastError;
   FWSAGetLastError       : TWSAGetLastError;
   FWSACancelAsyncRequest : TWSACancelAsyncRequest;
   FWSAAsyncGetHostByName : TWSAAsyncGetHostByName;
   FWSAAsyncGetHostByAddr : TWSAAsyncGetHostByAddr;
   FWSAAsyncSelect        : TWSAAsyncSelect;
   FGetServByName         : TGetServByName;
   FGetProtoByName        : TGetProtoByName;
   FGetHostByName         : TGetHostByName;
   FGetHostByAddr         : TGetHostByAddr;
   FGetHostName           : TGetHostName;
   FOpenSocket            : TOpenSocket;
   FShutdown              : TShutdown;
   FSetSockOpt            : TSetSockOpt;
   FGetSockOpt            : TGetSockOpt;
   FSendTo                : TSendTo;
   FSend                  : TSend;
   FRecv                  : TRecv;
   FRecvFrom              : TRecvFrom;
   Fntohs                 : Tntohs;
   Fntohl                 : Tntohl;
   FListen                : TListen;
   FIoctlSocket           : TIoctlSocket;
{$IFDEF COMPILER2_UP}
   FWSAIoctl              : TWSAIoctl;
{$ENDIF}
   FInet_ntoa             : TInet_ntoa;
   FInet_addr             : TInet_addr;
   Fhtons                 : Thtons;
   Fhtonl                 : Thtonl;
   FGetSockName           : TGetSockName;
   FGetPeerName           : TGetPeerName;
   FConnect               : TConnect;
   FCloseSocket           : TCloseSocket;
   FBind                  : TBind;
   FAccept                : TAccept;

function WSocketGetProc(const ProcName : String) : Pointer;
{$IFDEF COMPILER2_UP}
function WSocket2GetProc(const ProcName : String) : Pointer;
{$ENDIF}
function WSocket_WSAStartup(wVersionRequired: word;
                           var WSData: TWSAData): Integer;
function WSocket_WSACleanup : Integer;
procedure WSocket_WSASetLastError(iError: Integer);
function WSocket_WSAGetLastError: Integer;
function WSocket_WSACancelAsyncRequest(hAsyncTaskHandle: THandle): Integer;
function WSocket_WSAAsyncGetHostByName(HWindow: HWND; wMsg: u_int;
                                      name, buf: PChar;
                                      buflen: Integer): THandle;
function WSocket_WSAAsyncGetHostByAddr(HWindow: HWND;
                                      wMsg: u_int; addr: PChar;
                                      len, Struct: Integer;
                                      buf: PChar;
                                      buflen: Integer): THandle;
function WSocket_WSAAsyncSelect(s: TSocket; HWindow: HWND; wMsg: u_int; lEvent: Longint): Integer;
function WSocket_recv(s: TSocket;
                     var Buf; len, flags: Integer): Integer;
function WSocket_recvfrom(s: TSocket;
                         var Buf; len, flags: Integer;
                         var from: TSockAddr;
                         var fromlen: Integer): Integer;
function WSocket_getservbyname(name, proto: PChar): PServEnt;
function WSocket_getprotobyname(name: PChar): PProtoEnt;
function WSocket_gethostbyname(name: PChar): PHostEnt;
function WSocket_gethostbyaddr(addr: Pointer; len, Struct: Integer): PHostEnt;
function WSocket_gethostname(name: PChar; len: Integer): Integer;
function WSocket_socket(af, Struct, protocol: Integer): TSocket;
function WSocket_shutdown(s: TSocket; how: Integer): Integer;
function WSocket_setsockopt(s: TSocket; level, optname: Integer; optval: PChar;
                            optlen: Integer): Integer;
function WSocket_getsockopt(s: TSocket; level, optname: Integer; optval: PChar;
                            var optlen: Integer): Integer;
function WSocket_sendto(s: TSocket; var Buf; len, flags: Integer;
                        var addrto: TSockAddr;
                        tolen: Integer): Integer;
function WSocket_send(s: TSocket; var Buf; len, flags: Integer): Integer;
function WSocket_ntohs(netshort: u_short): u_short;
function WSocket_ntohl(netlong: u_long): u_long;
function WSocket_listen(s: TSocket; backlog: Integer): Integer;
function WSocket_ioctlsocket(s: TSocket; cmd: DWORD; var arg: u_long): Integer;
{$IFDEF COMPILER2_UP}
function WSocket_WSAIoctl(s                 : TSocket; IoControlCode : DWORD;
                          InBuffer          : Pointer; InBufferSize  : DWORD;
                          OutBuffer         : Pointer; OutBufferSize : DWORD;
                          var BytesReturned : DWORD; Overlapped      : POverlapped;
                          CompletionRoutine : FARPROC): Integer;
{$ENDIF}
function WSocket_inet_ntoa(inaddr: TInAddr): PChar;
function WSocket_inet_addr(cp: PChar): u_long;
function WSocket_htons(hostshort: u_short): u_short;
function WSocket_htonl(hostlong: u_long): u_long;
function WSocket_getsockname(s: TSocket; var name: TSockAddr;
                             var namelen: Integer): Integer;
function WSocket_getpeername(s: TSocket; var name: TSockAddr;
                             var namelen: Integer): Integer;
function WSocket_connect(s: TSocket; var name: TSockAddr;
                         namelen: Integer): Integer;
function WSocket_closesocket(s: TSocket): Integer;
function WSocket_bind(s: TSocket; var addr: TSockAddr; namelen: Integer): Integer;
{$IFDEF DELPHI1}
function WSocket_accept(s: TSocket; var addr: TSockAddr; var addrlen: Integer): TSocket;
{$ELSE}
{$IFDEF VER90}
function WSocket_accept(s: TSocket; var addr: TSockAddr; var addrlen: Integer): TSocket;
{$ELSE}
function WSocket_accept(s: TSocket; addr: PSockAddr; addrlen: PInteger): TSocket;
{$ENDIF}
{$ENDIF}
{$IFDEF COMPILER2_UP}
function XSocketAllocateHWnd(Obj : TObject): HWND;
function XSocketDeallocateHWnd(Wnd: HWND): boolean;
{$ENDIF}
{ AllocateHWnd and DeallocateHWnd are functions from Forms unit. We just }
{ provide a warper here to avoid Delphi 6 warning everywhere.            }
{$IFNDEF NOFORMS}
function  AllocateHWnd(Method: TWndMethod): HWND;
procedure DeallocateHWnd(Wnd: HWND);
{$ENDIF}

const
    WSocketGCount   : Integer = 0;
    WSocketGForced  : boolean = FALSE;
    GReqVerLow      : BYTE    = 1;
    GReqVerHigh     : BYTE    = 1;
    SIO_RCVALL = $98000001;

{$IFDEF DELPHI1}
{ Delphi 1 doesn't like missing register procedure in a unit }
procedure Register;
{$ENDIF}
{$IFDEF VER90}
{ Delphi 2 doesn't like missing register procedure in a unit }
procedure Register;
{$ENDIF}
{$IFDEF VER93}
{ BCB 1 doesn't like missing register procedure in a unit }
procedure Register;
{$ENDIF}

implementation

const
    FDllHandle     : THandle  = 0;
    FDll2Handle    : THandle  = 0;
    socksNoError              = 20000;
    socksProtocolError        = 20001;
    socksVersionError         = 20002;
    socksAuthMethodError      = 20003;
    socksGeneralFailure       = 20004;
    socksConnectionNotAllowed = 20005;
    socksNetworkUnreachable   = 20006;
    socksHostUnreachable      = 20007;
    socksConnectionRefused    = 20008;
    socksTtlExpired           = 20009;
    socksUnknownCommand       = 20010;
    socksUnknownAddressType   = 20011;
    socksUnassignedError      = 20012;
    socksInternalError        = 20013;
    socksDataReceiveError     = 20014;
    socksAuthenticationFailed = 20015;
    socksRejectedOrFailed     = 20016;
    socksHostResolutionFailed = 20017;

{$IFDEF DELPHI1}
    IP_DEFAULT_MULTICAST_TTL  = 1;
    IP_MULTICAST_IF           = 2;
    IP_MULTICAST_TTL          = 3;
    IP_MULTICAST_LOOP         = 4;
    IP_ADD_MEMBERSHIP         = 5;
    IP_DROP_MEMBERSHIP        = 6;
type
    in_addr = TInAddr;
{$ENDIF}
{$IFNDEF COMPILER4_UP}
type
    in_addr = TInAddr;
{$ENDIF}

var
    GInitData      : TWSADATA;
    IPList         : TStrings;
{$IFDEF COMPILER2_UP}
    GClassCritSect : TRTLCriticalSection;
    GWSockCritSect : TRTLCriticalSection;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF DELPHI1}
{ Delphi 1 miss the SetLength procedure. So we rewrite it. }
procedure SetLength(var S: string; NewLength: Integer);
begin
    S[0] := chr(NewLength);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF DELPHI1}
{ Delphi 1 doesn't like missing register procedure in a unit so we provide  }
{ an empty procedure                                                        }
procedure Register;
begin
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF VER90}
{ Delphi 2 doesn't like missing register procedure in a unit so we provide  }
{ an empty procedure                                                        }
procedure Register;
begin
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF VER93}
{ BCB 1 doesn't like missing register procedure in a unit so we provide     }
{ an empty procedure                                                        }
procedure Register;
begin
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function atoi(value : string) : Integer;
var
    i : Integer;
begin
    Result := 0;
    i := 1;
    while (i <= Length(Value)) and (Value[i] = ' ') do
        i := i + 1;
    while (i <= Length(Value)) and (Value[i] >= '0') and (Value[i] <= '9')do begin
        Result := Result * 10 + ord(Value[i]) - ord('0');
        i := i + 1;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function IsDigit(Ch : Char) : Boolean;
begin
    Result := (ch >= '0') and (ch <= '9');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Check for a valid numeric dotted IP address such as 192.161.65.25         }
{ Accept leading and trailing spaces.                                       }
function WSocketIsDottedIP(const S : String) : Boolean;
var
    I          : Integer;
    DotCount   : Integer;
    NumVal     : Integer;
begin
    Result     := FALSE;
    DotCount   := 0;
    NumVal     := 0;
    I          := 1;
    { Skip leading spaces }
    while (I <= Length(S)) and (S[I] = ' ') do
        Inc(I);
    { Can't begin with a dot }
    if (I <= Length(S)) and (S[I] = '.') then
        Exit;
    { Scan full string }
    while I <= Length(S) do begin
        if S[I] = '.' then begin
            Inc(DotCount);
            if (DotCount > 3) or (NumVal > 255) then
                Exit;
            NumVal := 0;
            { A dot must be followed by a digit }
            if (I >= Length(S)) or (not (S[I + 1] in ['0'..'9'])) then
                Exit;
        end
        else if S[I] in ['0'..'9'] then
            NumVal := NumVal * 10 + Ord(S[I]) - Ord('0')
        else begin
            { Not a digit nor a dot. Accept spaces until end of string }
            while (I <= Length(S)) and (S[I] = ' ') do
                Inc(I);
            if I <= Length(S) then
                Exit;  { Not a space, do not accept }
            break;     { Only spaces, accept        }
        end;
        Inc(I);
    end;
    { We must have exactly 3 dots }
    if (DotCount <> 3) or (NumVal > 255) then
        Exit;
    Result := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF DELPHI1}
function TrimRight(Str : String) : String;
var
    i : Integer;
begin
    i := Length(Str);
    while (i > 0) and (Str[i] in [' ', #9]) do
        i := i - 1;
    Result := Copy(Str, 1, i);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TrimLeft(Str : String) : String;
var
    i : Integer;
begin
    if Str[1] <> ' ' then
        Result := Str
    else begin
        i := 1;
        while (i <= Length(Str)) and (Str[i] = ' ') do
            i := i + 1;
        Result := Copy(Str, i, Length(Str) - i + 1);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function Trim(Str : String) : String;
begin
    Result := TrimLeft(TrimRight(Str));
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.RaiseException(const Msg : String);
begin
    if Assigned(FOnError) then
        TriggerError
    else
        raise ESocketException.Create(Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.RaiseExceptionFmt(const Fmt : String; args : array of const);
begin
    if Assigned(FOnError) then
        TriggerError
    else
        raise ESocketException.CreateFmt(Fmt, args);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF NEVER}       { 14/02/99 }
function LoadWinsock(FileName : PChar) : Boolean;
var
    LastError : LongInt;
begin
    if not DllStarted then begin
        LastError := WSocket_WSAStartup(MAKEWORD(GReqVerLow, GReqVerHigh) { $202 $101}, GInitData);
        if LastError <> 0 then begin
            raise ESocketException.CreateFmt('%s: WSAStartup error #%d',
                                             [FileName, LastError]);
        end;
        DllStarted := TRUE;
    end;
    Result := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocketLoadWinsock : Boolean;
begin
    Result := LoadWinsock(winsocket);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_WSAStartup(
    wVersionRequired: word;
    var WSData: TWSAData): Integer;
begin
    if @FWSAStartup = nil then
        @FWSAStartup := WSocketGetProc('WSAStartup');
    Result := FWSAStartup(wVersionRequired, WSData);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_WSACleanup : Integer;
begin
    if @FWSACleanup = nil then
        @FWSACleanup := WSocketGetProc('WSACleanup');
    Result := FWSACleanup;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure WSocket_Synchronized_WSASetLastError(iError: Integer);
begin
    if @FWSASetLastError = nil then
        @FWSASetLastError := WSocketGetProc('WSASetLastError');
    FWSASetLastError(iError);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_WSAGetLastError: Integer;
begin
    if @FWSAGetLastError = nil then
        @FWSAGetLastError := WSocketGetProc('WSAGetLastError');
    Result := FWSAGetLastError;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_WSACancelAsyncRequest(hAsyncTaskHandle: THandle): Integer;
begin
    if @FWSACancelAsyncRequest = nil then
        @FWSACancelAsyncRequest := WSocketGetProc('WSACancelAsyncRequest');
    Result := FWSACancelAsyncRequest(hAsyncTaskHandle);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_WSAAsyncGetHostByName(
    HWindow: HWND; wMsg: u_int;
    name, buf: PChar;
    buflen: Integer): THandle;
begin
    if @FWSAAsyncGetHostByName = nil then
        @FWSAAsyncGetHostByName := WSocketGetProc('WSAAsyncGetHostByName');
    Result := FWSAAsyncGetHostByName(HWindow, wMsg, name, buf, buflen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_WSAAsyncGetHostByAddr(
    HWindow: HWND;
    wMsg: u_int; addr: PChar;
    len, Struct: Integer;
    buf: PChar;
    buflen: Integer): THandle;
begin
    if @FWSAAsyncGetHostByAddr = nil then
        @FWSAAsyncGetHostByAddr := WSocketGetProc('WSAAsyncGetHostByAddr');
    Result := FWSAAsyncGetHostByAddr(HWindow, wMsg, addr, len, struct, buf, buflen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_WSAAsyncSelect(
    s: TSocket;
    HWindow: HWND;
    wMsg: u_int;
    lEvent: Longint): Integer;
begin
    if @FWSAAsyncSelect = nil then
        @FWSAAsyncSelect := WSocketGetProc('WSAAsyncSelect');
    Result := FWSAAsyncSelect(s, HWindow, wMsg, lEvent);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_getservbyname(name, proto: PChar): PServEnt;
begin
    if @Fgetservbyname = nil then
        @Fgetservbyname := WSocketGetProc('getservbyname');
    Result := Fgetservbyname(name, proto);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_getprotobyname(name: PChar): PProtoEnt;
begin
    if @Fgetprotobyname = nil then
        @Fgetprotobyname := WSocketGetProc('getprotobyname');
    Result := Fgetprotobyname(name);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_gethostbyname(name: PChar): PHostEnt;
begin
    if @Fgethostbyname = nil then
        @Fgethostbyname := WSocketGetProc('gethostbyname');
    Result := Fgethostbyname(name);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_gethostbyaddr(addr: Pointer; len, Struct: Integer): PHostEnt;
begin
    if @Fgethostbyaddr = nil then
        @Fgethostbyaddr := WSocketGetProc('gethostbyaddr');
    Result := Fgethostbyaddr(addr, len, Struct);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_gethostname(name: PChar; len: Integer): Integer;
begin
    if @Fgethostname = nil then
        @Fgethostname := WSocketGetProc('gethostname');
    Result := Fgethostname(name, len);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_socket(af, Struct, protocol: Integer): TSocket;
begin
    if @FOpenSocket= nil then
        @FOpenSocket := WSocketGetProc('socket');
    Result := FOpenSocket(af, Struct, protocol);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_shutdown(s: TSocket; how: Integer): Integer;
begin
    if @FShutdown = nil then
        @FShutdown := WSocketGetProc('shutdown');
    Result := FShutdown(s, how);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_setsockopt(s: TSocket; level, optname: Integer; optval: PChar;
                            optlen: Integer): Integer;
begin
    if @FSetSockOpt = nil then
        @FSetSockOpt := WSocketGetProc('setsockopt');
    Result := FSetSockOpt(s, level, optname, optval, optlen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_getsockopt(
    s: TSocket; level, optname: Integer;
    optval: PChar; var optlen: Integer): Integer;
begin
    if @FGetSockOpt = nil then
        @FGetSockOpt := WSocketGetProc('getsockopt');
    Result := FGetSockOpt(s, level, optname, optval, optlen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_sendto(
    s          : TSocket;
    var Buf;
    len, flags : Integer;
    var addrto : TSockAddr;
    tolen      : Integer): Integer;
begin
    if @FSendTo = nil then
        @FSendTo := WSocketGetProc('sendto');
    Result := FSendTo(s, Buf, len, flags, addrto, tolen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_send(s: TSocket; var Buf; len, flags: Integer): Integer;
begin
    if @FSend = nil then
        @FSend := WSocketGetProc('send');
    Result := FSend(s, Buf, len, flags);
{   if Assigned(LogStream) then
        LogStream.Write(Buf, Len); }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_ntohs(netshort: u_short): u_short;
begin
    if @Fntohs = nil then
        @Fntohs := WSocketGetProc('ntohs');
    Result := Fntohs(netshort);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_ntohl(netlong: u_long): u_long;
begin
    if @Fntohl = nil then
        @Fntohl := WSocketGetProc('ntohl');
    Result := Fntohl(netlong);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_listen(s: TSocket; backlog: Integer): Integer;
begin
    if @FListen = nil then
        @FListen := WSocketGetProc('listen');
    Result := FListen(s, backlog);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_ioctlsocket(s: TSocket; cmd: DWORD; var arg: u_long): Integer;
begin
    if @FIoctlSocket = nil then
        @FIoctlSocket := WSocketGetProc('ioctlsocket');
    Result := FIoctlSocket(s, cmd, arg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF COMPILER2_UP}
function WSocket_Synchronized_WSAIoctl(
    s                 : TSocket; IoControlCode : DWORD;
    InBuffer          : Pointer; InBufferSize  : DWORD;
    OutBuffer         : Pointer; OutBufferSize : DWORD;
    var BytesReturned : DWORD; Overlapped      : POverlapped;
    CompletionRoutine : FARPROC): Integer;
begin
    if @FWSAIoctl = nil then
        @FWSAIoctl := WSocket2GetProc('WSAIoctl');
    Result := FWSAIoctl(s, IoControlCode, InBuffer, InBufferSize, OutBuffer,
                        OutBufferSize, BytesReturned, Overlapped, CompletionRoutine);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_inet_ntoa(inaddr: TInAddr): PChar;
begin
    if @FInet_ntoa = nil then
        @FInet_ntoa := WSocketGetProc('inet_ntoa');
    Result := FInet_ntoa(inaddr);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_inet_addr(cp: PChar): u_long;
begin
    if @FInet_addr = nil then
        @FInet_addr := WSocketGetProc('inet_addr');
    Result := FInet_addr(cp);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_htons(hostshort: u_short): u_short;
begin
    if @Fhtons = nil then
        @Fhtons := WSocketGetProc('htons');
    Result := Fhtons(hostshort);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_htonl(hostlong: u_long): u_long;
begin
    if @Fhtonl = nil then
        @Fhtonl := WSocketGetProc('htonl');
    Result := Fhtonl(hostlong);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_getsockname(
    s           : TSocket;
    var name    : TSockAddr;
    var namelen : Integer): Integer;
begin
    if @FGetSockName = nil then
        @FGetSockName := WSocketGetProc('getsockname');
    Result := FGetSockName(s, name, namelen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_getpeername(
    s           : TSocket;
    var name    : TSockAddr;
    var namelen : Integer): Integer;
begin
    if @FGetPeerName = nil then
        @FGetPeerName := WSocketGetProc('getpeername');
    Result := FGetPeerName(s, name, namelen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_connect(
    s        : TSocket;
    var name : TSockAddr;
    namelen  : Integer): Integer;
begin
    if @FConnect= nil then
        @FConnect := WSocketGetProc('connect');
    Result := FConnect(s, name, namelen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_closesocket(s: TSocket): Integer;
begin
    if @FCloseSocket = nil then
        @FCloseSocket := WSocketGetProc('closesocket');
    Result := FCloseSocket(s);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_bind(
    s: TSocket;
    var addr: TSockAddr;
    namelen: Integer): Integer;
begin
    if @FBind = nil then
        @FBind := WSocketGetProc('bind');
    Result := FBind(s, addr, namelen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_accept(
    s: TSocket;
{$IFDEF DELPHI1} { Delphi 1 }
    var addr: TSockAddr;
    var addrlen: Integer): TSocket;
{$ELSE}
{$IFDEF VER90} { Delphi 2 }
    var addr: TSockAddr;
    var addrlen: Integer): TSocket;
{$ELSE}{ Delphi 3/4/5, Bcb 1/3/4 }
    addr: PSockAddr;
    addrlen: PInteger): TSocket;
{$ENDIF}
{$ENDIF}
begin
    if @FAccept = nil then
        @FAccept := WSocketGetProc('accept');
    Result := FAccept(s, addr, addrlen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_recv(s: TSocket; var Buf; len, flags: Integer): Integer;
begin
    if @FRecv= nil then
        @FRecv := WSocketGetProc('recv');
    Result := FRecv(s, Buf, len, flags);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_recvfrom(
    s: TSocket;
    var Buf; len, flags: Integer;
    var from: TSockAddr;
    var fromlen: Integer): Integer;
begin
    if @FRecvFrom = nil then
        @FRecvFrom := WSocketGetProc('recvfrom');
    Result := FRecvFrom(s, Buf, len, flags, from, fromlen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Winsock is dynamically loaded and unloaded when needed. In some cases     }
{ you may find winsock being loaded and unloaded very often in your app     }
{ This happend for example when you dynamically create a TWSocket and       }
{ destroy a TWSocket when there is no "permanant" TWSocket (that is a       }
{ TWSocket dropped on a persitant form). It is the very inefficiant.        }
{ Calling WSocketForceLoadWinsock will increament the reference count so    }
{ that winsock will not be unloaded when the last TWSocket is destroyed.    }
procedure WSocketForceLoadWinsock;
begin
{$IFDEF COMPILER2_UP}
    EnterCriticalSection(GWSockCritSect);
    try
{$ENDIF}
        if not WSocketGForced then begin
            WSocketGForced := TRUE;
            Inc(WSocketGCount);
            WSocketGetProc('');
        end;
{$IFDEF COMPILER2_UP}
    finally
        LeaveCriticalSection(GWSockCritSect);
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Cancel the operation done with WSocketForceLoadWinsock.                   }
procedure WSocketCancelForceLoadWinsock;
begin
{$IFDEF COMPILER2_UP}
    EnterCriticalSection(GWSockCritSect);
    try
{$ENDIF}
        if WSocketGForced then begin
            WSocketGForced := FALSE;
            Dec(WSocketGCount);
            if WSocketGCount <= 0 then
                WSocketUnloadWinsock;
        end;
{$IFDEF COMPILER2_UP}
    finally
        LeaveCriticalSection(GWSockCritSect);
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure WSocketUnloadWinsock;
begin
{$IFDEF NEVER}   { 14/02/99 }
    if DllStarted then begin
        DllStarted := FALSE;
        WSocket_WSACleanup;
    end;
{$ENDIF}
{$IFDEF COMPILER2_UP}
    EnterCriticalSection(GWSockCritSect);
    try
{$ENDIF}
        if (FDllHandle <> 0) and (WSocketGCount = 0) then begin
            WSocket_Synchronized_WSACleanup;
{$IFDEF COMPILER2_UP}
            if FDll2Handle <> 0 then begin
                FreeLibrary(FDll2Handle);
                FDll2Handle        := 0;
                FWSAIoctl          := nil;
            end;
{$ENDIF}
            FreeLibrary(FDllHandle);
            FDllHandle             := 0;
            FWSAStartup            := nil;
            FWSACleanup            := nil;
            FWSASetLastError       := nil;
            FWSAGetLastError       := nil;
            FWSACancelAsyncRequest := nil;
            FWSAAsyncGetHostByName := nil;
            FWSAAsyncGetHostByAddr := nil;
            FWSAAsyncSelect        := nil;
            FGetServByName         := nil;
            FGetProtoByName        := nil;
            FGetHostByName         := nil;
            FGetHostByAddr         := nil;
            FGetHostName           := nil;
            FOpenSocket            := nil;
            FShutdown              := nil;
            FSetSockOpt            := nil;
            FGetSockOpt            := nil;
            FSendTo                := nil;
            FSend                  := nil;
            FRecv                  := nil;
            FRecvFrom              := nil;
            Fntohs                 := nil;
            Fntohl                 := nil;
            FListen                := nil;
            FIoctlSocket           := nil;
{$IFDEF COMPILER2_UP}
            FWSAIoctl              := nil;
{$ENDIF}
            FInet_ntoa             := nil;
            FInet_addr             := nil;
            Fhtons                 := nil;
            Fhtonl                 := nil;
            FGetSockName           := nil;
            FGetPeerName           := nil;
            FConnect               := nil;
            FCloseSocket           := nil;
            FBind                  := nil;
            FAccept                := nil;
        end;
        WSocketGForced := FALSE;
{$IFDEF COMPILER2_UP}
    finally
        LeaveCriticalSection(GWSockCritSect);
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocketGetProc(const ProcName : String) : Pointer;
{$IFDEF DELPHI1}
var
    Error     : THandle;
    Buf       : String;
    LastError : LongInt;
begin
    if FDllHandle = 0 then begin
       { Delphi 1 strings are not nul terminated }
        Buf := winsocket + #0;
        FDllHandle := LoadLibrary(@Buf[1]);
        if FDllHandle < HINSTANCE_ERROR then begin
            Error      := FDllHandle;
            FDllHandle := 0;
            raise ESocketException.Create('Unable to load ' + winsocket +
                                          ' Error #' + IntToStr(Error));
        end;
{$IFDEF DELPHI1}
        { Delphi 1 support only Winsock 1.01 }
        LastError := WSocket_WSAStartup($101, GInitData);
{$ELSE}
        LastError := WSocket_WSAStartup(MAKEWORD(GReqVerLow, GReqVerHigh) { $202 $101}, GInitData);
{$ENDIF}
        if LastError <> 0 then begin
            raise ESocketException.CreateFmt('%s: WSAStartup error #%d',
                                             [winsocket, LastError]);
        end;
    end;
    if Length(ProcName) = 0 then
        Result := nil
    else begin
        { Delphi 1 strings are not nul terminated }
        Buf := ProcName + #0;
        Result := GetProcAddress(FDllHandle, @Buf[1]);
        if Result = nil then
            raise ESocketException.Create('Procedure ' + ProcName +
                                          ' not found in ' + winsocket);
    end;
end;
{$ELSE}
var
    LastError : LongInt;
begin
    { Prevents compiler warning "Return value might be undefined"  }
    Result := nil;

    EnterCriticalSection(GWSockCritSect);
    try
        if FDllHandle = 0 then begin
            FDllHandle := LoadLibrary(@winsocket[1]);
            if FDllHandle = 0 then
                raise ESocketException.Create('Unable to load ' + winsocket +
                                              ' Error #' + IntToStr(GetLastError));
            LastError := WSocket_Synchronized_WSAStartup(MAKEWORD(GReqVerLow, GReqVerHigh) { $202 $101}, GInitData);
            if LastError <> 0 then begin
                raise ESocketException.CreateFmt('%s: WSAStartup error #%d',
                                                 [winsocket, LastError]);
            end;
        end;
        if Length(ProcName) = 0 then
            Result := nil
        else begin
            Result := GetProcAddress(FDllHandle, @ProcName[1]);
            if Result = nil then
                raise ESocketException.Create('Procedure ' + ProcName +
                                              ' not found in ' + winsocket +
                                              ' Error #' + IntToStr(GetLastError));
        end;
    finally
        LeaveCriticalSection(GWSockCritSect);
    end;
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF COMPILER2_UP}
function WSocket2GetProc(const ProcName : String) : Pointer;
begin
    { Prevents compiler warning "Return value might be undefined"  }
    Result := nil;

    EnterCriticalSection(GWSockCritSect);
    try
        if FDll2Handle = 0 then begin
            { Be sure to have main winsock.dll loaded }
            if FDllHandle = 0 then
                WSocketGetProc('');
            FDll2Handle := LoadLibrary(@winsocket2[1]);
            if FDll2Handle = 0 then
                raise ESocketException.Create('Unable to load ' + winsocket2 +
                                              ' Error #' + IntToStr(GetLastError));
        end;
        if Length(ProcName) = 0 then
            Result := nil
        else begin
            Result := GetProcAddress(FDll2Handle, @ProcName[1]);
            if Result = nil then
                raise ESocketException.Create('Procedure ' + ProcName +
                                              ' not found in ' + winsocket2 +
                                              ' Error #' + IntToStr(GetLastError));
        end;
    finally
        LeaveCriticalSection(GWSockCritSect);
    end;
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WinsockInfo : TWSADATA;
begin
{    LoadWinsock(winsocket); 14/02/99 }
    { Load winsock and initialize it as needed }
{$IFDEF COMPILER2_UP}
    EnterCriticalSection(GWSockCritSect);
    try
{$ENDIF}
        WSocketGetProc('');
        Result := GInitData;
        { If no socket created, then unload winsock immediately }
        if WSocketGCount <= 0 then
            WSocketUnloadWinsock;
{$IFDEF COMPILER2_UP}
    finally
        LeaveCriticalSection(GWSockCritSect);
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFNDEF NO_ADV_MT}
procedure SafeIncrementCount;
begin
    EnterCriticalSection(GWSockCritSect);
    Inc(WSocketGCount);
    LeaveCriticalSection(GWSockCritSect);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure SafeDecrementCount;
begin
    EnterCriticalSection(GWSockCritSect);
    Dec(WSocketGCount);
    LeaveCriticalSection(GWSockCritSect);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_WSAStartup(
    wVersionRequired : WORD;
    var WSData       : TWSAData): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_WSAStartup(wVersionRequired, WSData);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_WSACleanup : Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_WSACleanup;
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure WSocket_WSASetLastError(iError: Integer);
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        WSocket_Synchronized_WSASetLastError(iError);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_WSAGetLastError: Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_WSAGetLastError;
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_WSACancelAsyncRequest(hAsyncTaskHandle: THandle): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_WSACancelAsyncRequest(hAsyncTaskHandle);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_WSAAsyncGetHostByName(
    HWindow: HWND; wMsg: u_int;
    name, buf: PChar;
    buflen: Integer): THandle;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_WSAAsyncGetHostByName(
                      HWindow, wMsg, name, buf, buflen);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_WSAAsyncGetHostByAddr(
    HWindow: HWND;
    wMsg: u_int; addr: PChar;
    len, Struct: Integer;
    buf: PChar;
    buflen: Integer): THandle;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_WSAAsyncGetHostByAddr(
                       HWindow, wMsg, addr, len, struct, buf, buflen);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_WSAAsyncSelect(
    s: TSocket;
    HWindow: HWND;
    wMsg: u_int;
    lEvent: Longint): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_WSAAsyncSelect(
                      s, HWindow, wMsg, lEvent);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_getservbyname(name, proto: PChar): PServEnt;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_getservbyname(name, proto);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_getprotobyname(name: PChar): PProtoEnt;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_getprotobyname(name);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_gethostbyname(name: PChar): PHostEnt;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_gethostbyname(name);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_gethostbyaddr(addr: Pointer; len, Struct: Integer): PHostEnt;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_gethostbyaddr(addr, len, Struct);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_gethostname(name: PChar; len: Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_gethostname(name, len);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_socket(af, Struct, protocol: Integer): TSocket;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_socket(af, Struct, protocol);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_shutdown(s: TSocket; how: Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_Shutdown(s, how);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_setsockopt(s: TSocket; level, optname: Integer; optval: PChar;
                            optlen: Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_setsockopt(s, level, optname, optval, optlen);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_getsockopt(
    s: TSocket; level, optname: Integer;
    optval: PChar; var optlen: Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_getsockopt(s, level, optname, optval, optlen);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_sendto(
    s          : TSocket;
    var Buf;
    len, flags : Integer;
    var addrto : TSockAddr;
    tolen      : Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_sendto(s, Buf, len, flags, addrto, tolen);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_send(s: TSocket; var Buf; len, flags: Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_send(s, Buf, len, flags);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_ntohs(netshort: u_short): u_short;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_ntohs(netshort);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_ntohl(netlong: u_long): u_long;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_ntohl(netlong);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_listen(s: TSocket; backlog: Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_listen(s, backlog);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_ioctlsocket(s: TSocket; cmd: DWORD; var arg: u_long): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_ioctlsocket(s, cmd, arg);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF COMPILER2_UP}
function WSocket_WSAIoctl(
    s                 : TSocket; IoControlCode : DWORD;
    InBuffer          : Pointer; InBufferSize  : DWORD;
    OutBuffer         : Pointer; OutBufferSize : DWORD;
    var BytesReturned : DWORD; Overlapped      : POverlapped;
    CompletionRoutine : FARPROC): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_WSAIoctl(
                      s, IoControlCode, InBuffer, InBufferSize, OutBuffer,
                      OutBufferSize, BytesReturned, Overlapped, CompletionRoutine);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_inet_ntoa(inaddr: TInAddr): PChar;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_inet_ntoa(inaddr);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_inet_addr(cp: PChar): u_long;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_inet_addr(cp);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_htons(hostshort: u_short): u_short;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_htons(hostshort);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_htonl(hostlong: u_long): u_long;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_htonl(hostlong);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_getsockname(
    s           : TSocket;
    var name    : TSockAddr;
    var namelen : Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_getsockname(s, name, namelen);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_getpeername(
    s           : TSocket;
    var name    : TSockAddr;
    var namelen : Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_getpeername(s, name, namelen);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_connect(
    s        : TSocket;
    var name : TSockAddr;
    namelen  : Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_connect(s, name, namelen);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_closesocket(s: TSocket): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_closesocket(s);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_bind(
    s: TSocket;
    var addr: TSockAddr;
    namelen: Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_bind(s, addr, namelen);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_accept(
    s: TSocket;
{$IFDEF DELPHI1} { Delphi 1 }
    var addr: TSockAddr;
    var addrlen: Integer): TSocket;
{$ELSE}
{$IFDEF VER90} { Delphi 2 }
    var addr: TSockAddr;
    var addrlen: Integer): TSocket;
{$ELSE}{ Delphi 3/4/5, Bcb 1/3/4 }
    addr: PSockAddr;
    addrlen: PInteger): TSocket;
{$ENDIF}
{$ENDIF}
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_accept(s, addr, addrlen);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_recv(s: TSocket; var Buf; len, flags: Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_recv(s, Buf, len, flags);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_recvfrom(
    s: TSocket;
    var Buf; len, flags: Integer;
    var from: TSockAddr;
    var fromlen: Integer): Integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_recvfrom(s, Buf, len, flags, from, fromlen);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}


procedure TCustomWSocket.Notification(AComponent: TComponent; operation: TOperation);
begin
    inherited Notification(AComponent, operation);
    if operation = opRemove then begin
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.AssignDefaultValue;
begin
    FillChar(sin, Sizeof(sin), 0);
    sin.sin_family     := AF_INET;
    FAddrFormat        := PF_INET;

    FPortAssigned      := FALSE;
    FAddrAssigned      := FALSE;
    FAddrResolved      := FALSE;
    FPortResolved      := FALSE;
    FProtoResolved     := FALSE;
    FLocalPortResolved := FALSE;

    FProtoAssigned     := TRUE;
    FProto             := IPPROTO_TCP;
    FProtoStr          := 'tcp';
    FType              := SOCK_STREAM;
    FLocalPortStr      := '0';
    FLocalAddr         := '0.0.0.0';

    FLingerOnOff       := wsLingerOn;
    FLingerTimeout     := 0;
    FHSocket           := INVALID_SOCKET;
    FSelectEvent       := 0;
    FState             := wsClosed;
    bAllSent           := TRUE;
    FPaused            := FALSE;
    FReadCount         := 0;
    FCloseInvoked      := FALSE;
    FFlushTimeout      := 60;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ All exceptions *MUST* be handled. If an exception is not handled, the     }
{ application will be shut down !                                           }
procedure TCustomWSocket.HandleBackGroundException(E: Exception);
var
    CanAbort : Boolean;
begin
    CanAbort := TRUE;
    { First call the error event handler, if any }
    if Assigned(FOnBgException) then begin
        try
            FOnBgException(Self, E, CanAbort);
        except
        end;
    end;
    { Then abort the socket }
    if CanAbort then begin
        try
            Abort;
        except
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This procedure handle all messages for TWSocket. All exceptions must be   }
{ handled or the application will be shutted down !                         }
{ If WndProc is overriden in descendent components, then the same exception }
{ handling *MUST* be setup because descendent component code is executed    }
{ before the base class code.                                               }
procedure TCustomWSocket.WndProc(var MsgRec: TMessage);
begin
    try
        with MsgRec do begin
            if Msg = WM_ASYNCSELECT then
                WMASyncSelect(MsgRec)
            else if Msg = WM_ASYNCGETHOSTBYNAME then
                WMAsyncGetHostByName(MsgRec)
            else if Msg = WM_ASYNCGETHOSTBYADDR then
                WMAsyncGetHostByAddr(MsgRec)
            else if Msg = WM_CLOSE_DELAYED then
                WMCloseDelayed(MsgRec)
            else if Msg = WM_WSOCKET_RELEASE then
                WMRelease(MsgRec)
            else if Msg = WM_TRIGGER_EXCEPTION then
                { This is useful to check for background exceptions            }
                { In your application, use following code to test your handler }
                { PostMessage(WSocket1.Handle, WM_TRIGGER_EXCEPTION, 0, 0);    }
                raise ESocketException.Create('Test exception in WSocket')
            else
                Result := DefWindowProc(Handle, Msg, wParam, LParam);
        end;
    except
        on E:Exception do
            HandleBackGroundException(E);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF COMPILER2_UP}
{ This function is a callback function. It means that it is called by       }
{ windows. This is the very low level message handler procedure setup to    }
{ handle the message sent by windows (winsock) to handle messages.          }
function XSocketWindowProc(
    ahWnd   : HWND;
    auMsg   : Integer;
    awParam : WPARAM;
    alParam : LPARAM): Integer; stdcall;
var
    Obj    : TObject;
    MsgRec : TMessage;
begin
    { At window creation asked windows to store a pointer to our object     }
    Obj := TObject(GetWindowLong(ahWnd, 0));

    { If the pointer doesn't represent a TWSocket, just call the default procedure}
    if not (Obj is TCustomWSocket) then
        Result := DefWindowProc(ahWnd, auMsg, awParam, alParam)
    else begin
        { Delphi use a TMessage type to pass parameter to his own kind of   }
        { windows procedure. So we are doing the same...                    }
        MsgRec.Msg    := auMsg;
        MsgRec.WParam := awParam;
        MsgRec.LParam := alParam;
        { May be a try/except around next line is needed. Not sure ! }
        TWSocket(Obj).WndProc(MsgRec);
        Result := MsgRec.Result;
    end;
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.MessagePump;
begin
{$IFDEF NOFORMS}
    { The Forms unit (TApplication object) has not been included.           }
    { We used either an external message pump or our internal message pump. }
    { External message pump has to set Terminated property to TRUE when the }
    { application is terminated.                                            }
    if Assigned(FOnMessagePump) then
        FOnMessagePump(Self)
    else
        Self.ProcessMessages;  
{$ELSE}
{$IFDEF COMPILER2_UP}
    { Delphi 1 doesn't support multithreading }
    if FMultiThreaded then
        Self.ProcessMessages
    else
{$ENDIF}
        Application.ProcessMessages;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This function is very similar to TApplication.ProcessMessage              }
{ You can also use it if your application has no TApplication object (Forms }
{ unit not referenced at all).                                              }
{$IFDEF COMPILER2_UP}
function TCustomWSocket.ProcessMessage : Boolean;
var
    Msg : TMsg;
begin
    Result := FALSE;
    if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then begin
        Result := TRUE;
        if Msg.Message = WM_QUIT then
            FTerminated := TRUE
        else begin
            TranslateMessage(Msg);
            DispatchMessage(Msg);
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Loop thru message processing until all messages are processed.            }
{ This function is very similar to TApplication.ProcessMessage              }
{ This is intended for multithreaded application using TWSocket.            }
{ You can also use it if your application has no TApplication object (Forms }
{ unit not referenced at all).                                              }
procedure TCustomWSocket.ProcessMessages;
begin
    while Self.ProcessMessage do { loop };
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Loop thru message processing until the WM_QUIT message is received        }
{ This is intended for multithreaded application using TWSocket.            }
{ MessageLoop is different from ProcessMessages because it actually block   }
{ if no message is available. The loop is broken when WM_QUIT is retrieved. }
procedure TCustomWSocket.MessageLoop;
var
    MsgRec : TMsg;
begin
    { If GetMessage retrieves the WM_QUIT, the return value is FALSE and    }
    { the message loop is broken.                                           }
    while GetMessage(MsgRec, 0, 0, 0) do begin
        TranslateMessage(MsgRec);
        DispatchMessage(MsgRec)
    end;
    FTerminated := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This global variable is used to store the windows class characteristic    }
{ and is needed to register the window class used by TWSocket               }
var
    XSocketWindowClass: TWndClass = (
        style         : 0;
        lpfnWndProc   : @XSocketWindowProc;
        cbClsExtra    : 0;
        cbWndExtra    : SizeOf(Pointer);
        hInstance     : 0;
        hIcon         : 0;
        hCursor       : 0;
        hbrBackground : 0;
        lpszMenuName  : nil;
        lpszClassName : 'XSocketWindowClass');


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Unregister the window class use by the component. This is necessary to do }
{ so from a DLL when the DLL is unloaded (that is when DllEntryPoint is     }
{ called with dwReason equal to DLL_PROCESS_DETACH.                         }
procedure WSocketUnregisterClass;
begin
  EnterCriticalSection(GClassCritSect);
  try
{$IFDEF USEWINDOWS}
    Windows.UnregisterClass(XSocketWindowClass.lpszClassName, HInstance);
{$ELSE}
    Winprocs.UnregisterClass(XSocketWindowClass.lpszClassName, HInstance);
{$ENDIF}
  finally
      LeaveCriticalSection(GClassCritSect);
  end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Allocate a window handle. This means registering a window class the first }
{ time we are called, and creating a new window each time we are called.    }
function XSocketAllocateHWnd(Obj : TObject): HWND;
var
    TempClass       : TWndClass;
    ClassRegistered : Boolean;
begin
{$IFDEF DELPHI7}
    Result := 0;  { Just to remove Delphi update 1 warning }
{$ENDIF}
    EnterCriticalSection(GClassCritSect);
    try
        { Check if the window class is already registered                   }
        XSocketWindowClass.hInstance := HInstance;
        ClassRegistered := GetClassInfo(HInstance,
                                        XSocketWindowClass.lpszClassName,
                                        TempClass);
        if not ClassRegistered then begin
           { Not yet registered, do it right now                            }
{$IFDEF USEWINDOWS}
           Result := Windows.RegisterClass(XSocketWindowClass);
{$ELSE}
           Result := WinProcs.RegisterClass(XSocketWindowClass);
{$ENDIF}
           if Result = 0 then
               Exit;
        end;
    finally
        LeaveCriticalSection(GClassCritSect);
    end;

    { Now create a new window                                               }
    Result := CreateWindowEx(WS_EX_TOOLWINDOW,
                             XSocketWindowClass.lpszClassName,
                             '',        { Window name   }
                             WS_POPUP,  { Window Style  }
                             0, 0,      { X, Y          }
                             0, 0,      { Width, Height }
                             0,         { hWndParent    }
                             0,         { hMenu         }
                             HInstance, { hInstance     }
                             nil);      { CreateParam   }

    { if successfull, the ask windows to store the object reference         }
    { into the reserved byte (see RegisterClass)                            }
    if (Result <> 0) and Assigned(Obj) then
        SetWindowLong(Result, 0, Integer(Obj));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Free the window handle                                                    }
function XSocketDeallocateHWnd(Wnd: HWND): boolean;
begin
    Result := DestroyWindow(Wnd);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.AllocateSocketHWnd;
begin
{$IFDEF DELPHI1}
    { Delphi 16 bits has no thread, we can use the VCL                      }
    FWindowHandle := AllocateHWnd(WndProc);
{$ELSE}
    { Delphi 32 bits has threads and VCL is not thread safe.                }
    { We need to do our own way to be thread safe.                          }
    FWindowHandle := XSocketAllocateHWnd(Self);
    FThreadId     := GetCurrentThreadId;
{$ENDIF}
    if FWindowHandle = 0 then
        RaiseException('Cannot create a hidden window for TWSocket');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.DeallocateSocketHWnd;
begin
{$IFDEF DELPHI1}
    DeallocateHWnd(FWindowHandle);
{$ELSE}
    { Wilfried added check for existing window }
    if FWindowHandle = 0 then
        Exit;

    { Remove the object reference from the window }
    SetWindowLong(FWindowHandle, 0, 0);
    { Wilfried                                                              }
    { if Destructor call's here and it is wrong thread it will not harm     }
    { so no need to check Thread Id here, it is done in the ThreadDetach    }
    { method XSocketDeallocateHWnd(FWindowHandle);                          }
    if XSocketDeallocateHWnd(FWindowHandle) then
        FWindowHandle := 0;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF COMPILER2_UP}
procedure TCustomWSocket.ThreadAttach;
begin
    if FWindowHandle <> 0 then
        RaiseException('Cannot attach when not detached');

    AllocateSocketHwnd;
    if FHSocket <> INVALID_SOCKET then
        WSocket_Synchronized_WSAASyncSelect(FHSocket, Handle, WM_ASYNCSELECT, FSelectEvent);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.ThreadDetach;
begin
    if GetCurrentThreadID <> FThreadID then
        RaiseException('Cannot detach from other thread');

    if FHSocket <> INVALID_SOCKET then
        WSocket_Synchronized_WSAASyncSelect(FHSocket, Handle, 0, 0);
    DeallocateSocketHWnd;
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFNDEF NOFORMS}
function AllocateHWnd(Method: TWndMethod): HWND;
begin
    Result := Forms.AllocateHWnd(Method);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure DeallocateHWnd(Wnd: HWND);
begin
    Forms.DeallocateHWnd(Wnd);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TCustomWSocket.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);

    AllocateSocketHWnd;
    FBufList        := TList.Create;
    FBufSize        := 1460; {1514;}             { Default buffer size }
    FDnsResultList  := TStringList.Create;
    FMultiCastIpTTL := IP_DEFAULT_MULTICAST_TTL;
    ListenBacklog   := 5;

    AssignDefaultValue;

{$IFDEF COMPILER2_UP}
    EnterCriticalSection(GWSockCritSect);
    try
{$ENDIF}
        Inc(WSocketGCount);
{$IFDEF COMPILER2_UP}
    finally
        LeaveCriticalSection(GWSockCritSect);
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TCustomWSocket.Destroy;
begin
    try
        CancelDnsLookup;             { Cancel any pending dns lookup      }
    except
        { Ignore any exception here }
    end;

    if FState <> wsClosed then       { Close the socket if not yet closed }
        Close;

{$IFDEF COMPILER2_UP}
    EnterCriticalSection(GWSockCritSect);
    try
{$ENDIF}
        Dec(WSocketGCount);
        if WSocketGCount <= 0 then begin
            WSocketUnloadWinsock;
{           WSocketGCount := 0;  // it is set to 0 in WSocketUnloadWinsock }
        end;
{$IFDEF COMPILER2_UP}
    finally
        LeaveCriticalSection(GWSockCritSect);
    end;
{$ENDIF}

    DeleteBufferedData;
    if Assigned(FBufList) then begin
        FBufList.Free;
        FBufList := nil;
    end;
    if Assigned(FDnsResultList) then begin
        FDnsResultList.Free;
        FDnsResultList := nil;
    end;

    DeallocateSocketHWnd;

{$IFDEF COMPILER2_UP}
    EnterCriticalSection(GWSockCritSect);
    try
        if WSocketGCount <= 0 then
            WSocketUnregisterClass;
    finally
        LeaveCriticalSection(GWSockCritSect);
    end;
{$ENDIF}

    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.GetReqVerLow: BYTE;
begin
    Result := GReqVerLow;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.SetReqVerLow(const Value: BYTE);
begin
    if GReqVerLow <> Value then begin
        if FDllHandle <> 0 then
            SocketError('SetReqVerLow: WinSock version can''t be changed now')
        else
            GReqVerLow := Value;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.GetReqVerHigh: BYTE;
begin
    Result := GReqVerHigh;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.SetReqVerHigh(const Value: BYTE);
begin
    if GReqVerHigh <> Value then begin
        if FDllHandle <> 0 then
            SocketError('SetReqVerHigh: WinSock version can''t be changed now')
        else
            GReqVerHigh := Value;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Dup(NewHSocket : TSocket);
var
    iStatus : Integer;
begin
    if (NewHSocket = 0) or (NewHSocket = INVALID_SOCKET) then begin
        WSocket_Synchronized_WSASetLastError(WSAEINVAL);
        SocketError('Dup');
        Exit;
    end;

    if FState <> wsClosed then begin
        iStatus := WSocket_Synchronized_closesocket(FHSocket);
        FHSocket := INVALID_SOCKET;
        if iStatus <> 0 then begin
            SocketError('Dup (closesocket)');
            Exit;
        end;

        ChangeState(wsClosed);
    end;
    FHsocket := NewHSocket;
    SetLingerOption;

    FSelectEvent := FD_READ or FD_WRITE or FD_CLOSE or FD_CONNECT;
    iStatus      := WSocket_Synchronized_WSAASyncSelect(FHSocket, Handle,
                                                        WM_ASYNCSELECT, FSelectEvent);
    if iStatus <> 0 then begin
        SocketError('WSAAsyncSelect');
        Exit;
    end;
    DupConnected;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.DupConnected;
begin
    ChangeState(wsConnected);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Get the number of char received and waiting to be read                    }
function TCustomWSocket.GetRcvdCount : LongInt;
var
    Temp : u_long;
begin
    if csDesigning in ComponentState then begin
        Result := -1;
        Exit;
    end;
    if WSocket_Synchronized_ioctlsocket(FHSocket, FIONREAD, Temp) = SOCKET_ERROR then begin
        Result := -1;
        SocketError('ioctlSocket');
        Exit;
    end;
    Result := LongInt(Temp);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.ChangeState(NewState : TSocketState);
var
    OldState : TSocketState;
begin
    OldState := FState;
    FState   := NewState;
    if OldState <> NewState then       { 20030226 }
        TriggerChangeState(OldState, NewState);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ DoRecv is a simple wrapper around winsock recv function to make it        }
{ a virtual function.                                                       }
function TCustomWSocket.DoRecv(
    var Buffer;
    BufferSize : Integer;
    Flags      : Integer) : Integer;
begin
{ MoulinCnt := (MoulinCnt + 1) and 3; }
{ Write('R', Moulin[MoulinCnt], #13); }
    Result := WSocket_Synchronized_recv(FHSocket, Buffer, BufferSize, Flags);
{   FRcvdFlag := (Result > 0);}
    { If we received the requested size, we may need to receive more }
    FRcvdFlag := (Result >= BufferSize);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ The socket is non-blocking, so this routine will only receive as much     }
{ data as it is available.                                                  }
function TCustomWSocket.Receive(Buffer : Pointer; BufferSize: integer) : integer;
begin
    Result := DoRecv(Buffer^, BufferSize, 0);
    if Result < 0 then
        FLastError := WSocket_Synchronized_WSAGetLastError
    else
        { Here we should check for overflows ! It is well possible to }
        { receive more than 2GB during a single session.              }
        { Or we could use an Int64 variable...                        }
        FReadCount := FReadCount + Result;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Receive as much data as possible into a string                            }
{ You should avoid this function and use Receive. Using string will be      }
{ much slower because data will be copied several times.                    }
{ ReceiveStr will *NOT* wait for a line to be received. It just read        }
{ already received characters and return them as a string.                  }
function TCustomWSocket.ReceiveStr : string;
var
    lCount : LongInt;
begin
    lCount := GetRcvdCount;

    if LCount < 0 then begin  { GetRcvdCount returned an error }
        SetLength(Result, 0);
        Exit;
    end;

    if lCount = 0 then        { GetRcvdCount say nothing, will try anyway }
        LCount := 255;        { some reasonable arbitrary value           }

{$IFDEF DELPHI1}
    { Delphi 1 strings are limited }
    if lCount > High(Result) then
        lCount := High(Result);
{$ENDIF}

    SetLength(Result, lCount);
    lCount := Receive(@Result[1], lCount);
    if lCount > 0 then
        SetLength(Result, lCount)
    else
        SetLength(Result, 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.DoRecvFrom(
    FHSocket    : TSocket;
    var Buffer;
    BufferSize  : Integer;
    Flags       : Integer;
    var From    : TSockAddr;
    var FromLen : Integer) : Integer;
begin
    Result := WSocket_Synchronized_recvfrom(FHSocket, Buffer, BufferSize,
                                            Flags, From, FromLen);
{   FRcvdFlag := (Result > 0); }
    FRcvdFlag := (Result >= BufferSize);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.ReceiveFrom(
    Buffer      : Pointer;
    BufferSize  : Integer;
    var From    : TSockAddr;
    var FromLen : Integer) : integer;
begin
    Result := DoRecvFrom(FHSocket, Buffer^, BufferSize, 0, From, FromLen);
    if Result < 0 then
        FLastError := WSocket_Synchronized_WSAGetLastError
    else
        FReadCount := FReadCount + Result;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.PeekData(Buffer : Pointer; BufferSize: integer) : integer;
begin
    Result := DoRecv(Buffer^, BufferSize, MSG_PEEK);
    if Result < 0 then
        FLastError := WSocket_Synchronized_WSAGetLastError;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{
function SearchChar(Data : PChar; Len : Integer; Ch : Char) : PChar;
begin
    while Len > 0 do begin
        Len := Len - 1;
        if Data^ = Ch then begin
            Result := Data;
            exit;
        end;
        Data := Data + 1;
    end;
    Result := nil;
end;
}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This function should be used with UDP only. Use Send for TCP.             }
function TCustomWSocket.SendTo(
    Dest    : TSockAddr;
    DestLen : Integer;
    Data    : Pointer;
    Len     : Integer) : integer;
begin
    Result := WSocket_Synchronized_SendTo(FHSocket, Data^, Len, FSendFlags,
                                          TSockAddr(Dest), DestLen);
    if Result > 0 then begin
        TriggerSendData(Result);
        { Post FD_WRITE message to have OnDataSent event triggered }
        if bAllSent and (FType = SOCK_DGRAM) then
            PostMessage(Handle,
                        WM_ASYNCSELECT,
                        FHSocket,
                        MakeLong(FD_WRITE, 0));
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.RealSend(Data : Pointer; Len : Integer) : Integer;
begin
{ MoulinCnt := (MoulinCnt + 1) and 3; }
{ Write('S', Moulin[MoulinCnt], #13); }
    if FType = SOCK_DGRAM then
        Result := WSocket_Synchronized_SendTo(FHSocket, Data^, Len, FSendFlags,
                                              TSockAddr(sin), SizeOf(sin))
    else
        Result := WSocket_Synchronized_Send(FHSocket, Data^, Len, FSendFlags);
    if Result > 0 then
        TriggerSendData(Result);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.TryToSend;
var
    oBuffer   : TBuffer;
    Len       : Integer;
    Count     : Integer;
    Data      : Pointer;
    LastError : Integer;
    { p         : PChar;23/12/01}
    bMore     : Boolean;
begin
    if (FHSocket = INVALID_SOCKET) or                { No more socket      }
       (FBufList.Count = 0)                          { Nothing to send     }
       {or (bMoreFlag and (nMoreCnt >= nMoreMax))23/12/01} { Waiting more signal }
       then
        exit;

    bMore := TRUE;
    while bMore do begin
        oBuffer := FBufList.First;
        Data    := oBuffer.Peek(Len);
        if Len <= 0 then begin
            { Buffer is empty }
            if FBufList.Count <= 1 then begin
                { Every thing has been sent }
                bAllSent := TRUE;
                bMore    := FALSE;
            end
            else begin
                oBuffer.Free;
                FBufList.Delete(0);
                FBufList.Pack;
            end;
        end
        else begin
            Count := RealSend(Data, Len);

            if Count = 0 then
                bMore := FALSE  { Closed by remote }
            else if count = SOCKET_ERROR then begin
                LastError := WSocket_Synchronized_WSAGetLastError;
                if (LastError = WSAECONNRESET) or (LastError = WSAENOTSOCK) or
                   (LastError = WSAENOTCONN)   or (LastError = WSAEINVAL)   or
                   (LastError = WSAECONNABORTED)     { 07/05/99 }
                then begin
                    FCloseInvoked := TRUE;           { 23/07/98 }
                    Close;
                    TriggerSessionClosed(LastError); { 23/07/98 }
                end
                else if LastError <> WSAEWOULDBLOCK then begin
                    SocketError('TryToSend failed');
                    Exit;
                end;
                bMore := FALSE;
            end
            else begin
                oBuffer.Remove(Count);
                if Count < Len then begin
                    { Could not write as much as we wanted. Stop sending }
{$IFDEF DELPHI1}
                    { A bug in some Trumpet Winsock implementation break the  }
                    { background sending. Jan Tomasek <xtomasej@feld.cvut.cz> }
                    if not TrumpetCompability then begin
                        {bWrite := FALSE;23/12/01}
                        bMore  := FALSE;
                    end;
{$ELSE}
                    {bWrite := FALSE;23/12/01}
                    bMore  := FALSE;
{$ENDIF}
                end;
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.PutStringInSendBuffer(const Str : String);
begin
    if Str <> '' then
        PutDataInSendBuffer(@Str[1], Length(Str));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.PutDataInSendBuffer(Data : Pointer; Len : Integer);
var
    oBuffer  : TBuffer;
    cWritten : Integer;
    bMore    : Boolean;
begin
    if (Len <= 0) or (Data = nil) then
        exit;

    if FBufList.Count = 0 then begin
        oBuffer := TBuffer.Create(FBufSize);
        FBufList.Add(oBuffer);
    end
    else
        oBuffer := FBufList.Last;

    bMore := TRUE;
    while bMore do begin
        cWritten := oBuffer.Write(Data, Len);
        if cWritten >= Len then
            bMore := FALSE
        else begin
            Len  := Len - cWritten;
            Data := PChar(Data) + cWritten;
            if Len < 0 then
                bMore := FALSE
            else begin
                oBuffer := TBuffer.Create(FBufSize);
                FBufList.Add(oBuffer);
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Return -1 if error, else return number of byte written                    }
function TCustomWSocket.Send(Data : Pointer; Len : Integer) : integer;
begin
    if (FState <> wsConnected) and (FState <> wsSocksConnected) then begin
        WSocket_Synchronized_WSASetLastError(WSAENOTCONN);
        SocketError('Send');
        Result := -1;
        Exit;
    end;

    bAllSent := FALSE;
    if Len <= 0 then
        Result := 0
    else begin
        Result   := Len;
        PutDataInSendBuffer(Data, Len);
    end;

    if bAllSent then
        Exit;

    TryToSend;

    if bAllSent then begin
        { We post a message to fire the FD_WRITE message wich in turn will }
        { fire the OnDataSent event. We cannot fire the event ourself      }
        { because the event handler will eventually call send again.       }
        { Sending the message prevent recursive call and stack overflow.   }
        { The PostMessage function posts (places) a message in a window's  }
        { message queue and then returns without waiting for the           }
        { corresponding window to process the message. The message will be }
        { seen and routed by Delphi a litle later, when we will be out of  }
        { the send function.                                               }
        PostMessage(Handle,
                    WM_ASYNCSELECT,
                    FHSocket,
                    MakeLong(FD_WRITE, 0));
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Return -1 if error, else return number of byte written                    }
function TCustomWSocket.SendStr(const Str : String) : Integer;
begin
    if Length(Str) > 0 then
        Result := Send(@Str[1], Length(Str))
    else
        Result := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.SendText(Str : String);
begin
    SendStr(Str);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.ASyncReceive(
    Error           : Word;
    MySocketOptions : TWSocketOptions);
var
    bMore    : Boolean;
    lCount   : {$IFDEF FPC} LongWord; {$ELSE} LongInt; {$ENDIF}
    TrashCan : array [0..1023] of char;
begin
    bMore := TRUE;
    while bMore do begin
        FLastError := 0;

        try
            if not TriggerDataAvailable(Error) then begin
                { Nothing wants to receive, we will receive and throw away  23/07/98 }
                if DoRecv(TrashCan, SizeOf(TrashCan), 0) = SOCKET_ERROR then begin
                    FLastError := WSocket_Synchronized_WSAGetLastError;
                    if FLastError = WSAEWOULDBLOCK then begin
                        FLastError := 0;
                        break;
                    end;
                end;
            end;

            { DLR Honor the socket options being passed as parameters }
            if wsoNoReceiveLoop in MySocketOptions then
                break;

            if FLastError <> 0 then begin
                bMore := FALSE;
                { -1 value is not a true error but is used to break the loop }
                if FLastError = -1 then
                    FLastError := 0;
            end
            { Check if we have something new arrived, if yes, process it }
            else if WSocket_Synchronized_ioctlsocket(FHSocket, FIONREAD,
                                                     lCount) = SOCKET_ERROR then begin
                FLastError := WSocket_Synchronized_WSAGetLastError;
                bMore      := FALSE;
            end
            else if lCount = 0 then
                bMore := FALSE;
        except
            bMore := FALSE;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Do_FD_CONNECT(var msg: TMessage);
begin
    if FState <> wsConnected then begin
        ChangeState(wsConnected);
        TriggerSessionConnectedSpecial(msg.LParamHi);
        if (msg.LParamHi <> 0) and (FState <> wsClosed) then
            Close;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Do_FD_READ(var msg: TMessage);
begin
    if FState <> wsConnected then begin
      ChangeState(wsConnected);
      TriggerSessionConnectedSpecial(msg.LParamHi);
    end;
    ASyncReceive(msg.LParamHi, FComponentOptions);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Do_FD_WRITE(var msg: TMessage);
begin
    TryToSend;
{ If you wants to test background exception, uncomment the next 2 lines. }
{   if bAllSent then                                                }
{       raise Exception.Create('Test TWSocket exception');          }
    if bAllSent then
        TriggerDataSent(msg.LParamHi);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Do_FD_CLOSE(var msg: TMessage);
begin
    { In some strange situations I found that we receive a FD_CLOSE  }
    { during the connection phase, breaking the connection early !   }
    { This occurs for example after a failed FTP transfert Probably  }
    { something related to bugged winsock. Doesn't hurt with good    }
    { winsock. So let the code there !                               }
    if FState <> wsConnecting then begin
        { Check if we have something arrived, if yes, process it     }
        { DLR, since we are closing MAKE SURE WE LOOP in the receive }
        { function to get ALL remaining data                         }
        ASyncReceive(0, FComponentOptions - [wsoNoReceiveLoop]);

        if not FCloseInvoked then begin
            FCloseInvoked := TRUE;
            TriggerSessionClosed(msg.LParamHi);
        end;

        if FState <> wsClosed then
            Close;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Do_FD_ACCEPT(var msg: TMessage);
begin
    TriggerSessionAvailable(msg.LParamHi);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.WMASyncSelect(var msg: TMessage);
var
    Check  : Word;
const
    TTTCount : Integer = 0;
begin
{TriggerDisplay('AsyncSelect ' + IntToStr(msg.wParam) + ', ' + IntToStr(msg.LParamLo));}
    { Verify that the socket handle is ours handle }

    if msg.wParam <> FHSocket then
        Exit;

    if FPaused then
        exit;

    Check := msg.lParamLo and FD_CONNECT;
    if Check <> 0 then begin
        FSelectMessage := FD_CONNECT;
        Do_FD_CONNECT(msg);
    end;

    Check := msg.lParamLo and FD_READ;
    if Check <> 0 then begin
        FSelectMessage := FD_READ;
        Do_FD_READ(msg);
    end;

    Check := msg.lParamLo and FD_WRITE;
    if Check <> 0 then begin
        FSelectMessage := FD_WRITE;
        Do_FD_WRITE(msg);
    end;

    Check := msg.lParamLo and FD_ACCEPT;
    if Check <> 0 then begin
        FSelectMessage := FD_ACCEPT;
        Do_FD_ACCEPT(msg);
    end;

    Check := msg.lParamLo and FD_CLOSE;
    if Check <> 0 then begin
        FSelectMessage := FD_CLOSE;
        {WriteLn('FD_CLOSE ', FHSocket);}
        Do_FD_CLOSE(msg);
    end;
    FSelectMessage := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure GetIPList(phe  : PHostEnt; ToList : TStrings);
type
    TaPInAddr = array [0..255] of PInAddr;
    PaPInAddr = ^TaPInAddr;
var
    pptr : PaPInAddr;
    I    : Integer;
begin
    pptr := PaPInAddr(Phe^.h_addr_list);

    I := 0;
    while pptr^[I] <> nil do begin
        ToList.Add(StrPas(WSocket_inet_ntoa(pptr^[I]^)));
        Inc(I);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.WMAsyncGetHostByName(var msg: TMessage);
var
    Phe     : Phostent;
    Error   : Word;
begin
    if FDnsLookupHandle = 0 then begin
        { We are still executing WSAAsyncGetHostByName and FDnsLookupHandle }
        { has not been assigned yet ! We should proceed later.              }
        FDnsLookupTempMsg  := msg;
        FDnsLookupCheckMsg := TRUE;
        Exit;
    end
    else if msg.wParam <> LongInt(FDnsLookupHandle) then
        Exit;

    FDnsLookupHandle := 0;
    Error := Msg.LParamHi;
    if Error = 0 then begin
        Phe := PHostent(@FDnsLookupBuffer);
        if phe <> nil then begin
            GetIpList(Phe, FDnsResultList);
            FDnsResult := FDnsResultList.Strings[0];
        end;
    end;
    TriggerDnsLookupDone(Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.WMAsyncGetHostByAddr(var msg: TMessage);
var
    Phe   : Phostent;
    Error : Word;
begin
    if msg.wParam <> LongInt(FDnsLookupHandle) then
        Exit;
    FDnsLookupHandle := 0;
    Error            := Msg.LParamHi;
    if Error = 0 then begin
        Phe := PHostent(@FDnsLookupBuffer);
        if phe <> nil then begin
            SetLength(FDnsResult, StrLen(Phe^.h_name));
            StrCopy(@FDnsResult[1], Phe^.h_name);
            FDnsResultList.Clear;
            FDnsResultList.Add(FDnsResult);
        end;
    end;
    TriggerDnsLookupDone(Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.SetProto(sProto : String);
begin
    if FProtoAssigned and (sProto = FProtoStr) then
        Exit;

    if FState <> wsClosed then begin
        RaiseException('Cannot change Proto if not closed');
        Exit;
    end;

    FProtoStr := Trim(sProto);
    if Length(FProtoStr) = 0 then begin
        FProtoAssigned := FALSE;
        Exit;
    end;

    FProtoResolved := FALSE;
    FProtoAssigned := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.GetProto : String;
begin
    Result := FProtoStr;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.SetRemotePort(sPort : String);
begin
    if FPortAssigned and (FPortStr = sPort) then
        Exit;

    if FState <> wsClosed then begin
        RaiseException('Cannot change Port if not closed');
        Exit;
    end;

    FPortStr := Trim(sPort);
    if Length(FPortStr) = 0 then begin
        FPortAssigned := FALSE;
        Exit;
    end;

    FPortResolved := FALSE;
    FPortAssigned := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.GetRemotePort : String;
begin
    Result := FPortStr;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.SetLocalPort(sLocalPort : String);
begin
    if FState <> wsClosed then begin
        RaiseException('Cannot change LocalPort if not closed');
        Exit;
    end;

    FLocalPortStr      := sLocalPort;
    FLocalPortResolved := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.SetLocalAddr(sLocalAddr : String);
{var
    IPAddr  : TInAddr;}
begin
    if FState <> wsClosed then begin
        RaiseException('Cannot change LocalAddr if not closed');
        Exit;
    end;

    if Length(sLocalAddr) = 0 then
        sLocalAddr := '0.0.0.0';
{$IFDEF NEVER}
{$IFDEF DELPHI1}
    sLocalAddr := sLocalAddr + #0;
{$ENDIF}
    IPAddr.S_addr := WSocket_Synchronized_inet_addr(@sLocalAddr[1]);
    if IPAddr.S_addr = u_long(INADDR_NONE) then
        RaiseException('SetLocalAddr(): Invalid IP address');
    FLocalAddr := StrPas(WSocket_Synchronized_inet_ntoa(IPAddr));
{$ELSE}
    FLocalAddr := sLocalAddr;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.GetXPort: string;
var
    saddr    : TSockAddrIn;
    saddrlen : integer;
    port     : integer;
begin
    Result := 'error';
    if FState in [wsConnected, wsBound, wsListening] then begin
        saddrlen := sizeof(saddr);
        if WSocket_Synchronized_GetSockName(FHSocket, TSockAddr(saddr), saddrlen) = 0 then begin
            port     := WSocket_Synchronized_ntohs(saddr.sin_port);
            Result   := Format('%d',[port]);
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.GetXAddr: string;
var
    saddr    : TSockAddrIn;
    saddrlen : integer;
begin
    Result := 'error';
    if FState in [wsConnected, wsBound, wsListening] then begin
        saddrlen := sizeof(saddr);
        if WSocket_Synchronized_GetSockName(FHSocket, TSockAddr(saddr), saddrlen) = 0 then
            Result := StrPas(WSocket_Synchronized_inet_ntoa(saddr.sin_addr));
     end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.SetAddr(InAddr : String);
begin
    if FAddrAssigned and (FAddrStr = InAddr) then
        Exit;

    if FState <> wsClosed then begin
        RaiseException('Cannot change Addr if not closed');
        Exit;
    end;

    FAddrStr := Trim(InAddr);
    if Length(FAddrStr) = 0 then begin
        FAddrAssigned := FALSE;
        Exit;
    end;

    FAddrResolved       := FALSE;
    FAddrAssigned       := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_ResolveHost(InAddr : String) : TInAddr;
var
    szData  : array [0..256] of char;
    Phe     : Phostent;
    IPAddr  : u_long;
begin
    if (Length(InAddr) = 0) or (Length(InAddr) >= SizeOf(szData)) then
        raise ESocketException.Create('WSocketResolveHost: ''' + InAddr + ''' Invalid Hostname.');

    StrPCopy(szData, Trim(InAddr)); { Length already checked above }
    if WSocketIsDottedIP(InAddr) then begin
        { Address is a dotted numeric address like 192.161.124.32 }
        IPAddr := WSocket_Synchronized_inet_addr(szData);
{$IFDEF DELPHI1}
        { With Trumpet Winsock 2B and 30D (win 3.11), inet_addr returns faulty }
        { results for 0.0.0.0                                                  }
        if (IPAddr = INADDR_NONE) and (StrComp(szData, '0.0.0.0') = 0) then begin
            Result.s_addr := 0;
            Exit;
        end;
{$ENDIF}
        if IPAddr = u_long(INADDR_NONE) then begin
            if StrComp(szData, '255.255.255.255') = 0 then begin
                Result.s_addr := u_long(INADDR_BROADCAST);
                Exit;
            end;
            raise ESocketException.Create('WSocketResolveHost: ''' + InAddr + ''' Invalid IP address.');
        end;
        Result.s_addr := IPAddr;
        Exit;
    end;

    { Address is a hostname }
    Phe := WSocket_Synchronized_GetHostByName(szData);
    if Phe = nil then
        raise ESocketException.CreateFmt(
                 'WSocketResolveHost: Cannot convert host address ''%s'', Error #%d',
                 [InAddr, WSocket_Synchronized_WSAGetLastError]);
    Result.s_addr := PInAddr(Phe^.h_addr_list^)^.s_addr;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocketResolveHost(InAddr : String) : TInAddr;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_ResolveHost(InAddr);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Convert port name or number to number in host order (ftp -> 21)           }
function WSocket_Synchronized_ResolvePort(Port : String; Proto : String) : Word;
var
    szPort   : array [0..31] of char;
    szProto  : array [0..31] of char;
    Pse      : Pservent;
begin
    if (Length(Port) = 0) or (Length(Port) >= SizeOf(szPort)) then
        raise ESocketException.Create('WSocketResolvePort: Invalid Port.');

    if (Length(Proto) = 0) or (Length(Proto) >= SizeOf(szProto)) then
        raise ESocketException.Create('WSocketResolvePort: Invalid Proto.');

    if IsDigit(Port[1]) then
        Result := atoi(Port)
    else begin
        StrPCopy(szPort, Trim(Port));   { Length already checked above }
        StrPCopy(szProto, Trim(Proto)); { Length already checked above }
{        if not DllStarted then
            LoadWinsock(WINSOCKET); 14/02/99 }
        if szProto[0] = #0 then
            Pse := WSocket_Synchronized_GetServByName(szPort, nil)
        else
            Pse := WSocket_Synchronized_GetServByName(szPort, szProto);
        if Pse = nil then
            raise ESocketException.CreateFmt(
                     'WSocketResolvePort: Cannot convert port ''%s'', Error #%d',
                     [Port, WSocket_Synchronized_WSAGetLastError]);
        Result := WSocket_Synchronized_ntohs(Pse^.s_port);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Convert port name or number to number in host order (ftp -> 21)           }
function WSocketResolvePort(Port : String; Proto : String) : Word;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_ResolvePort(Port, Proto);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocket_Synchronized_ResolveProto(sProto : String) : integer;
var
    szProto : array [0..31] of char;
    Ppe     : Pprotoent;
begin
    if (Length(sProto) = 0) or (Length(sProto) >= SizeOf(szProto)) then
        raise ESocketException.Create('WSocketResolveProto: Invalid Protocol.');

    if IsDigit(sProto[1]) then
        Result := atoi(sProto)
    else begin
        sProto := LowerCase(Trim(sProto));
        if sProto = 'tcp' then
            Result := IPPROTO_TCP
        else if sProto = 'udp' then
            Result := IPPROTO_UDP
        else if sProto = 'raw' then
            Result := IPPROTO_RAW
        else begin
            StrPCopy(szProto, sProto);  { Length already checked above }
            ppe := WSocket_Synchronized_getprotobyname(szProto);
            if Ppe = nil then
                raise ESocketException.CreateFmt(
                          'WSocketResolveProto: Cannot convert protocol ''%s'', Error #%d',
                          [sProto, WSocket_Synchronized_WSAGetLastError]);
            Result := ppe^.p_proto;
        end;
    end;
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocketResolveProto(sProto : String) : integer;
begin
{$IFNDEF NO_ADV_MT}
    SafeIncrementCount;
    try
{$ENDIF}
        Result := WSocket_Synchronized_ResolveProto(sProto);
{$IFNDEF NO_ADV_MT}
    finally
        SafeDecrementCount;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.GetAddr : String;
begin
    Result := FAddrStr;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.GetSockName(var saddr : TSockAddrIn; var saddrlen : Integer) : integer;
begin
    Result := WSocket_Synchronized_GetSockName(FHSocket, TSockAddr(saddr), saddrlen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.GetPeerAddr: string;
var
    saddr    : TSockAddrIn;
    saddrlen : integer;
    szAddr   : PChar;
begin
    Result := 'error';
    if FState = wsConnected then begin
        saddrlen := sizeof(saddr);
        if WSocket_Synchronized_GetPeerName(FHSocket, TSockAddr(saddr), saddrlen) = 0 then begin
            szAddr := WSocket_Synchronized_inet_ntoa(saddr.sin_addr);
            Result := StrPas(szAddr);
        end
        else begin
            SocketError('GetPeerAddr');
            Exit;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.GetPeerPort: string;
var
    saddr    : TSockAddrIn;
    saddrlen : integer;
begin
    Result := 'error';
    if FState = wsConnected then begin
        saddrlen := sizeof(saddr);
        if WSocket_Synchronized_GetPeerName(FHSocket, TSockAddr(saddr), saddrlen) = 0 then
            Result := IntToStr(WSocket_Synchronized_ntohs(saddr.sin_port))
        else begin
            SocketError('GetPeerPort');
            Exit;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.GetPeerName(var Name : TSockAddrIn; NameLen : Integer) : integer;
begin
    if FState = wsConnected then
        Result := WSocket_Synchronized_GetPeerName(FHSocket, TSockAddr(Name), NameLen)
    else
        Result := SOCKET_ERROR;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.CancelDnsLookup;
begin
    if FDnsLookupHandle = 0 then
        Exit;
    if WSocket_Synchronized_WSACancelAsyncRequest(FDnsLookupHandle) <> 0 then begin
        FDnsLookupHandle := 0;
        SocketError('WSACancelAsyncRequest');
        Exit;
    end;
    FDnsLookupHandle := 0;

    if not (csDestroying in ComponentState) then
        TriggerDnsLookupDone(WSAEINTR);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.DnsLookup(const AHostName : String);
var
    IPAddr   : TInAddr;
    HostName : String;
begin
    if AHostName = '' then begin
        RaiseException('DNS lookup: invalid host name.');
        TriggerDnsLookupDone(WSAEINVAL);
        Exit;
    end;

    { Cancel any pending lookup }
    if FDnsLookupHandle <> 0 then begin
        WSocket_Synchronized_WSACancelAsyncRequest(FDnsLookupHandle);
        FDnsLookupHandle := 0;
    end;

    FDnsResult := '';
    FDnsResultList.Clear;

{$IFDEF DELPHI1}
    { Delphi 1 do not automatically add a terminating nul char }
    HostName := AHostName + #0;
{$ELSE}
    HostName := AHostName;
{$ENDIF}
    if WSocketIsDottedIP(Hostname) then begin   { 28/09/2002 }
        IPAddr.S_addr := WSocket_Synchronized_inet_addr(@HostName[1]);
        if IPAddr.S_addr <> u_long(INADDR_NONE) then begin
            FDnsResult := StrPas(WSocket_Synchronized_inet_ntoa(IPAddr));
            FDnsResultList.Add(FDnsResult);     { 28/09/2002 }{ 12/02/2003 }
            TriggerDnsLookupDone(0);
            Exit;
        end;
    end;

    if FWindowHandle = 0 then
        RaiseException('DnsLookup: Window not assigned');

    { John Goodwin found a case where winsock dispatch WM_ASYNCGETHOSTBYNAME }
    { message before returning from WSAAsyncGetHostByName call. Because of   }
    { that, FDnsLookupHandle is not yet assigned when execution comes in     }
    { WMAsyncGetHostByName. John use a flag to check this situation.         }
    FDnsLookupCheckMsg := FALSE;
    FDnsLookupHandle   := WSocket_Synchronized_WSAAsyncGetHostByName(
                              FWindowHandle,
                              WM_ASYNCGETHOSTBYNAME,
                              @HostName[1],
                              @FDnsLookupBuffer,
                              SizeOf(FDnsLookupBuffer));
    if FDnsLookupHandle = 0 then begin
        RaiseExceptionFmt(
                  '%s: can''t start DNS lookup, error #%d',
                  [HostName, WSocket_Synchronized_WSAGetLastError]);
        Exit;
    end;
    if FDnsLookupCheckMsg then begin
        FDnsLookupCheckMsg := FALSE;
        WMAsyncGetHostByName(FDnsLookupTempMsg);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.ReverseDnsLookup(const HostAddr: String);
var
    szAddr : array [0..256] of Char;
    lAddr  : u_long;
begin
    if (Length(HostAddr) = 0) or (Length(HostAddr) >= SizeOf(szAddr)) then begin
        RaiseException('ReverseDnsLookup: Invalid host name.');
        TriggerDnsLookupDone(WSAEINVAL);
        Exit;
    end;
    { Cancel any pending lookup }
    if FDnsLookupHandle <> 0 then
        WSocket_Synchronized_WSACancelAsyncRequest(FDnsLookupHandle);

    FDnsResult := '';
    FDnsResultList.Clear;

    StrPCopy(szAddr, HostAddr); { Length already checked above }
    lAddr := WSocket_Synchronized_inet_addr(szAddr);

    if FWindowHandle = 0 then
        RaiseException('ReverseDnsLookup: Window not assigned');

    FDnsLookupHandle := WSocket_Synchronized_WSAAsyncGetHostByAddr(
                            FWindowHandle,
                            WM_ASYNCGETHOSTBYADDR,
                            PChar(@lAddr), 4, PF_INET,
                            @FDnsLookupBuffer,
                            SizeOf(FDnsLookupBuffer));
    if FDnsLookupHandle = 0 then
        RaiseExceptionFmt('%s: can''t start DNS lookup, error #%d',
                          [HostAddr, WSocket_Synchronized_WSAGetLastError]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.BindSocket;
var
    SockName      : TSockAddr;
    SockNamelen   : Integer;
    LocalSockName : TSockAddrIn;
begin
    FillChar(LocalSockName, Sizeof(LocalSockName), 0);
    SockNamelen                   := sizeof(LocalSockName);
    LocalSockName.sin_family      := AF_INET;
    LocalSockName.sin_port        := WSocket_Synchronized_htons(FLocalPortNum);
    LocalSockName.sin_addr.s_addr := WSocket_Synchronized_ResolveHost(FLocalAddr).s_addr;

    if WSocket_Synchronized_bind(HSocket, LocalSockName, SockNamelen) <> 0 then begin
        RaiseExceptionFmt('winsock.bind failed, error #%d', [WSocket_Synchronized_WSAGetLastError]);
        Exit;
    end;
    SockNamelen := sizeof(SockName);
    if WSocket_Synchronized_getsockname(FHSocket, SockName, SockNamelen) <> 0 then begin
        RaiseExceptionFmt('winsock.getsockname failed, error #%d',
                          [WSocket_Synchronized_WSAGetLastError]);
        Exit;
    end;
    FLocalPortNum := WSocket_Synchronized_ntohs(SockName.sin_port);
    FLocalPortStr := IntToStr(FLocalPortNum);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.SetLingerOption;
var
    iStatus : integer;
    li      : TLinger;
begin
    if FLingerOnOff = wsLingerNoSet then
        Exit;                            { Option set is disabled, ignore }

    if FHSocket = INVALID_SOCKET then begin
        RaiseException('Cannot set linger option at this time');
        Exit;
    end;

    li.l_onoff  := Ord(FLingerOnOff);    { 0/1 = disable/enable linger }
    li.l_linger := FLingerTimeout;       { timeout in seconds          }
    iStatus     := WSocket_Synchronized_setsockopt(FHSocket, SOL_SOCKET,
                                      SO_LINGER, @li, SizeOf(li));

    if iStatus <> 0 then begin
        SocketError('setsockopt(SO_LINGER)');
        Exit;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Connect;
var
    iStatus : integer;
    optval  : integer;
    lAddr   : TInAddr;
begin
    if (FHSocket <> INVALID_SOCKET) and (FState <> wsClosed) then begin
        RaiseException('Connect: Socket already in use');
        Exit;
    end;

    if  not FPortAssigned then begin
        RaiseException('Connect: No Port Specified');
        Exit;
    end;

    if not FAddrAssigned then begin
        RaiseException('Connect: No IP Address Specified');
        Exit;
    end;

    if not FProtoAssigned then begin
        RaiseException('Connect: No Protocol Specified');
        Exit;
    end;

    try
        if not FProtoResolved then begin
            { The next line will trigger an exception in case of failure }
            FProto := WSocket_Synchronized_ResolveProto(FProtoStr);
            case FProto of
            IPPROTO_UDP: FType := SOCK_DGRAM;
            IPPROTO_TCP: FType := SOCK_STREAM;
            IPPROTO_RAW: FType := SOCK_RAW;
            else
                         FType := SOCK_RAW;
            end;
            FProtoResolved := TRUE;
        end;

        if not FPortResolved then begin
            { The next line will trigger an exception in case of failure }
            FPortNum      := WSocket_Synchronized_ResolvePort(FPortStr, GetProto);
            sin.sin_port  := WSocket_Synchronized_htons(FPortNum);
            FPortResolved := TRUE;
        end;

        if not FLocalPortResolved then begin
            { The next line will trigger an exception in case of failure }
            FLocalPortNum      := WSocket_Synchronized_ResolvePort(FLocalPortStr, GetProto);
            FLocalPortResolved := TRUE;
        end;

        if not FAddrResolved then begin
            { The next line will trigger an exception in case of failure }
            sin.sin_addr.s_addr := WSocket_Synchronized_ResolveHost(FAddrStr).s_addr;
            FAddrResolved := TRUE;
        end;
    except
        on E:Exception do begin
            RaiseException('connect: ' + E.Message);
            Exit;
        end;
    end;

    { Remove any data from the internal output buffer }
    { (should already be empty !)                     }
    DeleteBufferedData;

    FHSocket := WSocket_Synchronized_socket(FAddrFormat, FType, FProto);
    if FHSocket = INVALID_SOCKET then begin
        SocketError('Connect (socket)');
        Exit;
    end;
    ChangeState(wsOpened);

    if FState <> wsOpened then begin  { 07/07/02 }
        { Socket has been closed in the OnChangeState event ! }
        WSocket_Synchronized_WSASetLastError(WSAEINVAL);
        SocketError('Connect (Invalid operation in OnChangeState)');
        Exit;
    end;

    if FType = SOCK_DGRAM then begin
        BindSocket;
        if FMultiCast then begin
            if FMultiCastIpTTL <> IP_DEFAULT_MULTICAST_TTL then begin
                optval := FMultiCastIpTTL; { set time-to-live for multicast }
                iStatus := WSocket_Synchronized_SetSockOpt(FHSocket, IPPROTO_IP,
                                                           IP_MULTICAST_TTL,
                                                           @optval,
                                                           SizeOf(optval));
                if iStatus <> 0 then begin
                        SocketError('setsockopt(IP_MULTICAST_TTL)');
                        Exit;
                end;
            end;
            if FLocalAddr <> '0.0.0.0' then begin                      { RK }
                laddr.s_addr := WSocket_Synchronized_ResolveHost(FLocalAddr).s_addr;
                iStatus      := WSocket_Synchronized_SetSockOpt(FHSocket, IPPROTO_IP,
                                                                IP_MULTICAST_IF,
                                                                PChar(@laddr),
                                                                SizeOf(laddr));
                if iStatus <> 0 then begin
                    SocketError('setsockopt(IP_MULTICAST_IF)');
                    Exit;
                end;
            end;                                                       { /RK }
        end;

        if sin.sin_addr.S_addr = u_long(INADDR_BROADCAST) then begin
            OptVal  := 1;
            iStatus := WSocket_Synchronized_setsockopt(FHSocket, SOL_SOCKET, SO_BROADCAST,
                                                       PChar(@OptVal), SizeOf(OptVal));
            if iStatus <> 0 then begin
                SocketError('setsockopt(SO_BROADCAST)');
                Exit;
            end;
        end;
    end
    else begin
        { Socket type is SOCK_STREAM }
        optval  := -1;
        iStatus := WSocket_Synchronized_setsockopt(FHSocket, SOL_SOCKET,
                                                   SO_REUSEADDR, @optval, SizeOf(optval));

        if iStatus <> 0 then begin
            SocketError('setsockopt(SO_REUSEADDR)');
            Exit;
        end;

        if wsoTcpNoDelay in FComponentOptions then begin
            optval := -1; { true, 0=false }
            iStatus := WSocket_Synchronized_setsockopt(FHsocket, IPPROTO_TCP,
                                                       TCP_NODELAY, @optval, SizeOf(optval));
            if iStatus <> 0 then begin
                SocketError('setsockopt(IPPROTO_TCP, TCP_NODELAY)');
                Exit;
            end;
        end;

        SetLingerOption;

        optval  := -1;
        iStatus := WSocket_Synchronized_setsockopt(FHSocket, SOL_SOCKET,
                                                   SO_KEEPALIVE, @optval, SizeOf(optval));

        if iStatus <> 0 then begin
            SocketError('setsockopt(SO_KEEPALIVE)');
            Exit;
        end;

        if (FLocalPortNum <> 0) or (FLocalAddr <> '0.0.0.0') then
            BindSocket;
    end;

    FSelectEvent := FD_READ   or FD_WRITE or FD_CLOSE or
                    FD_ACCEPT or FD_CONNECT;
    iStatus       := WSocket_Synchronized_WSAASyncSelect(FHSocket, Handle,
                                                         WM_ASYNCSELECT, FSelectEvent);
    if iStatus <> 0 then begin
        SocketError('WSAAsyncSelect');
        Exit;
    end;

    if FType = SOCK_DGRAM then begin
        ChangeState(wsConnected);
        TriggerSessionConnectedSpecial(0);
    end
    else begin
        iStatus := WSocket_Synchronized_connect(FHSocket, TSockAddr(sin), sizeof(sin));
        if iStatus = 0 then
            ChangeState(wsConnecting)
        else begin
            iStatus := WSocket_Synchronized_WSAGetLastError;
            if iStatus = WSAEWOULDBLOCK then
                ChangeState(wsConnecting)
            else begin
                FLastError := WSocket_Synchronized_WSAGetLastError;
                SocketError('Connect');
                Exit;
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Listen;
type
    ip_mreq = record
        imr_multiaddr : in_addr;
        imr_interface : in_addr;
    end;
var
    iStatus        : Integer;
    optval         : Integer;
    mreq           : ip_mreq;
    szAddr         : array [0..256] of char;
    dwBufferInLen  : DWORD;
    dwBufferOutLen : DWORD;
    dwDummy        : DWORD;
begin
    if not FPortAssigned then begin
        WSocket_Synchronized_WSASetLastError(WSAEINVAL);
        SocketError('listen: port not assigned');
        Exit;
    end;

    if not FProtoAssigned then begin
        WSocket_Synchronized_WSASetLastError(WSAEINVAL);
        SocketError('listen: protocol not assigned');
        Exit;
    end;

    if not FAddrAssigned then begin
        WSocket_Synchronized_WSASetLastError(WSAEINVAL);
        SocketError('listen: address not assigned');
        Exit;
    end;

    try
        if not FProtoResolved then begin
            { The next line will trigger an exception in case of failure }
            if CompareText(Copy(FProtoStr, 1, 4), 'raw_') = 0 then begin
                FType  := SOCK_RAW;
                FProto := WSocket_Synchronized_ResolveProto(Copy(FProtoStr, 5, 10));
            end
            else begin
                FProto := WSocket_Synchronized_ResolveProto(FProtoStr);
                if FProto = IPPROTO_UDP then
                    FType := SOCK_DGRAM
                else
                    FType := SOCK_STREAM;
            end;
            FProtoResolved := TRUE;
        end;

        if not FPortResolved then begin
            { The next line will trigger an exception in case of failure }
            FPortNum      := WSocket_Synchronized_ResolvePort(FPortStr, GetProto);
            sin.sin_port  := WSocket_Synchronized_htons(FPortNum);
            FPortResolved := TRUE;
        end;

        if not FAddrResolved then begin
            { The next line will trigger an exception in case of failure }
            sin.sin_addr.s_addr := WSocket_Synchronized_ResolveHost(FAddrStr).s_addr;
            FAddrResolved       := TRUE;
        end;
    except
        on E:Exception do begin
            RaiseException('listen: ' + E.Message);
            Exit;
        end;
    end;

    { Remove any data from the internal output buffer }
    { (should already be empty !)                     }
    DeleteBufferedData;

    FHSocket := WSocket_Synchronized_socket(FAddrFormat, FType, FProto);

    if FHSocket = INVALID_SOCKET then begin
        SocketError('socket');
        exit;
    end;

    if FType = SOCK_DGRAM then begin
        if FReuseAddr then begin
        { Enable multiple tasks to listen on duplicate address and port }
            optval  := -1;
            iStatus := WSocket_Synchronized_SetSockOpt(FHSocket, SOL_SOCKET,
                                                       SO_REUSEADDR,
                                                       @optval, SizeOf(optval));

            if iStatus <> 0 then begin
                SocketError('setsockopt(SO_REUSEADDR)');
                Close;
                Exit;
            end;
        end;
    end;

    iStatus := WSocket_Synchronized_bind(FHSocket, TSockAddr(sin), sizeof(sin));
    if iStatus = 0 then
        ChangeState(wsBound)
    else begin
        SocketError('Bind');
        Close;
        Exit;
    end;

    case FType of
{$IFDEF COMPILER2_UP}
    SOCK_RAW :
        begin
            if wsoSIO_RCVALL in FComponentOptions then begin
                dwBufferInLen  := 1;
                dwBufferOutLen := 0;
                iStatus := WSocket_Synchronized_WSAIoctl(FHSocket, SIO_RCVALL,
                    @dwBufferInLen,  SizeOf(dwBufferInLen),
                    @dwBufferOutLen, SizeOf(dwBufferOutLen),
                    dwDummy, nil, nil);

                if iStatus = SOCKET_ERROR then begin
                    SocketError('WSAIoctl(SIO_RCVALL)');
                    Close;
                    Exit;
                end;
            end;
            ChangeState(wsListening);
            ChangeState(wsConnected);
            TriggerSessionConnectedSpecial(0);
        end;
{$ENDIF}
    SOCK_DGRAM :
        begin
            if FMultiCast then begin
                 { Use setsockopt() to join a multicast group }
                 { mreq.imr_multiaddr.s_addr := WSocket_inet_addr('225.0.0.37');}
                 { mreq.imr_multiaddr.s_addr := sin.sin_addr.s_addr;}
                 { mreq.imr_multiaddr.s_addr := WSocket_inet_addr(FAddrStr);}
                 StrPCopy(szAddr, FMultiCastAddrStr);
                 mreq.imr_multiaddr.s_addr := WSocket_Synchronized_inet_addr(szAddr);
                 { mreq.imr_interface.s_addr := htonl(INADDR_ANY);} { RK}
                 mreq.imr_interface.s_addr := WSocket_Synchronized_ResolveHost(FAddrStr).s_addr;
                 iStatus := WSocket_Synchronized_SetSockOpt(FHSocket, IPPROTO_IP,
                                                            IP_ADD_MEMBERSHIP,
                                                            @mreq, SizeOf(mreq));

                 if iStatus <> 0 then begin
                    SocketError('setsockopt(IP_ADD_MEMBERSHIP)');
                    Exit;
                 end;
            end;
            ChangeState(wsListening);
            ChangeState(wsConnected);
            TriggerSessionConnectedSpecial(0);
        end;
    SOCK_STREAM :
        begin
            iStatus := WSocket_Synchronized_listen(FHSocket, FListenBacklog);
            if iStatus = 0 then
                ChangeState(wsListening)
            else begin
                SocketError('Listen');
                Exit;
            end;
        end;
    else
        SocketError('Listen: unexpected protocol.');
        Exit;
    end;


    FSelectEvent := FD_READ   or FD_WRITE or
                    FD_ACCEPT or FD_CLOSE;
    iStatus      := WSocket_Synchronized_WSAASyncSelect(FHSocket, Handle,
                                                        WM_ASYNCSELECT, FSelectEvent);
    if iStatus <> 0 then begin
        SocketError('WSAASyncSelect');
        exit;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.Accept: TSocket;
var
   len     : integer;
begin
    if FState <> wsListening then begin
        WSocket_Synchronized_WSASetLastError(WSAEINVAL);
        SocketError('not a listening socket');
        Result := INVALID_SOCKET;
        Exit;
    end;

    len := sizeof(sin);
{$IFDEF DELPHI1} { Delphi 1 }
    FASocket := WSocket_Synchronized_accept(FHSocket, TSockAddr(sin), len);
{$ELSE}
{$IFDEF VER90} { Delphi 2}
    FASocket := WSocket_Synchronized_accept(FHSocket, TSockAddr(sin), len);
{$ELSE}
    { Delphi 3/4, Bcb 1/3/4 use pointers instead of var parameters }
    FASocket := WSocket_Synchronized_accept(FHSocket, @sin, @len);
{$ENDIF}
{$ENDIF}

    if FASocket = INVALID_SOCKET then begin
        SocketError('Accept');
        Result := INVALID_SOCKET;
        Exit;
    end
    else
        Result := FASocket;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Pause;
begin
    FPaused := TRUE;
    WSocket_Synchronized_WSAASyncSelect(FHSocket, Handle, 0, 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Resume;
begin
    FPaused := FALSE;
    WSocket_Synchronized_WSAASyncSelect(FHSocket, Handle, WM_ASYNCSELECT, FSelectEvent);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Shutdown(How : Integer);
begin
    if FHSocket <> INVALID_SOCKET then
        WSocket_Synchronized_shutdown(FHSocket, How);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.DeleteBufferedData;
var
    nItem : Integer;
begin
    { Delete all data buffer }
    for nItem := 0 to FBufList.Count - 1 do
        TBuffer(FBufList.Items[nItem]).Free;
    FBufList.Clear;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Abort;
begin
    InternalAbort(0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.InternalAbort(ErrCode : Word);
begin
    CancelDnsLookup;
    DeleteBufferedData;
    { Be sure to close as fast as possible (abortive close) }
    if (State = wsConnected) and (FProto = IPPROTO_TCP) then begin
        LingerOnOff := wsLingerOff;
        SetLingerOption;
    end;
    InternalClose(FALSE, ErrCode);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Close;
begin
    InternalClose(TRUE, 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.CloseDelayed;
begin
    PostMessage(Handle, WM_CLOSE_DELAYED, 0, 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Release;
begin
    PostMessage(Handle, WM_WSOCKET_RELEASE, 0, 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.WMCloseDelayed(var msg: TMessage);
begin
    Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.WMRelease(var msg: TMessage);
begin
    Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.Flush;
begin
    while (FHSocket <> INVALID_SOCKET) and     { No more socket   }
          (not bAllSent) do begin              { Nothing to send  }
            { Break; }
        TryToSend;
        MessagePump;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.InternalClose(bShut : Boolean; Error : Word);
var
    iStatus : integer;
{    Buffer  : array [0..127] of Char; }
begin
    if FHSocket = INVALID_SOCKET then begin
        if FState <> wsClosed then begin
            ChangeState(wsClosed);
            AssignDefaultValue;
        end;
        Exit;
    end;

    if FState = wsClosed then
        Exit;

{ 11/10/98 called shutdown(1) instead of shutdonw(2). This disable only     }
{ reception. Disabling data send produced data lost is some cases. For      }
{ example when a client open the connection, send some data fast then close }
{ the connection immediately, even using the linger option.                 }
    if bShut then
        ShutDown(1);

    if FHSocket <> INVALID_SOCKET then begin
        repeat
            { Close the socket }
{WriteLn('CloseSocket(' + IntToStr(FHSocket) + ')');}
            iStatus := WSocket_Synchronized_closesocket(FHSocket);
            if iStatus <> 0 then begin
                FLastError := WSocket_Synchronized_WSAGetLastError;
                if FLastError <> WSAEWOULDBLOCK then begin
                    FHSocket := INVALID_SOCKET;
                    { Ignore the error occuring when winsock DLL not      }
                    { initialized (occurs when using TWSocket from a DLL) }
                    if FLastError = WSANOTINITIALISED then
                        break;
                    SocketError('Disconnect (closesocket)');
                    Exit;
                end;
                MessagePump;
            end;
        until iStatus = 0;
        FHSocket := INVALID_SOCKET;
    end;

    ChangeState(wsClosed);
    if (not (csDestroying in ComponentState)) and
       (not FCloseInvoked) {and Assigned(FOnSessionClosed)} then begin
        FCloseInvoked := TRUE;
        TriggerSessionClosed(Error);
    end;
    { 29/09/98 Protect AssignDefaultValue because SessionClosed event handler }
    { may have destroyed the component.                                       }
    try
        AssignDefaultValue;
    except
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.WaitForClose;
var
    lCount    : {$IFDEF FPC} LongWord; {$ELSE} LongInt; {$ENDIF}
    Status    : Integer;
    Ch        : Char;
begin
    while (FHSocket <> INVALID_SOCKET) and (FState <> wsClosed) do begin
        MessagePump;

        if WSocket_Synchronized_ioctlsocket(FHSocket, FIONREAD, lCount) = SOCKET_ERROR then
            break;
        if lCount > 0 then
            TriggerDataAvailable(0);

        Status := DoRecv(Ch, 0, 0);
        if Status <= 0 then begin
            FLastError := WSocket_Synchronized_WSAGetLastError;
            if FLastError <> WSAEWOULDBLOCK then
                break;
        end;
        MessagePump;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocketGetHostByAddr(Addr : String) : PHostEnt;
var
    szAddr : array[0..256] of char;
    lAddr  : u_long;
begin
    if (Length(Addr) = 0) or (Length(Addr) >= SizeOf(szAddr)) then
        raise ESocketException.Create('WSocketGetHostByAddr: Invalid address.');

    StrPCopy(szAddr, Addr); { Length already checked above }
    lAddr  := WSocket_inet_addr(szAddr);
    Result := WSocket_gethostbyaddr(PChar(@lAddr), 4, PF_INET);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocketResolveIp(IpAddr : String) : String;
var
    Phe : PHostEnt;
begin
    phe := WSocketGetHostByAddr(IpAddr);
    if Phe = nil then
        Result := ''
    else begin
        SetLength(Result, StrLen(Phe^.h_name));
        StrCopy(@Result[1], Phe^.h_name);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocketGetHostByName(Name : String) : PHostEnt;
var
    szName : array[0..256] of char;
begin
    if (Length(Name) = 0) or (Length(Name) >= SizeOf(szName)) then
        raise ESocketException.Create('WSocketGetHostByName: Invalid Hostname.');

    StrPCopy(szName, Name);
    Result := WSocket_gethostbyname(szName);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function LocalIPList : TStrings;
var
    phe  : PHostEnt;
begin
    IPList.Clear;
    Result := IPList;

    phe  := WSocketGetHostByName(LocalHostName);
    if phe <> nil then
        GetIpList(Phe, IPList);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function LocalHostName : String;
var
    Buffer     : array [0..63] of char;
begin
{    if not DllStarted then
        LoadWinsock(WINSOCKET); 14/02/99 }
    if WSocket_gethostname(Buffer, SizeOf(Buffer)) <> 0 then
        raise ESocketException.Create('Winsock.GetHostName failed');
    Result := StrPas(Buffer);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.TimerIsSet(var tvp : TTimeVal) : Boolean;
begin
    Result := (tvp.tv_sec <> 0) or (tvp.tv_usec <> 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.TimerCmp(var tvp : TTimeVal; var uvp : TTimeVal; IsEqual : Boolean) : Boolean;
begin
    Result := (tvp.tv_sec = uvp.tv_sec) and (tvp.tv_usec = uvp.tv_usec);
    if not IsEqual then
        Result := not Result;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.TimerClear(var tvp : TTimeVal);
begin
   tvp.tv_sec  := 0;
   tvp.tv_usec := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.SetSendFlags(newValue : TSocketSendFlags);
begin
    case newValue of
    wsSendNormal: FSendFlags := 0;
    wsSendUrgent: FSendFlags := MSG_OOB;
    else
        RaiseException('Invalid SendFlags');
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.GetSendFlags : TSocketSendFlags;
begin
    case FSendFlags of
    0       : Result := wsSendNormal;
    MSG_OOB : Result := wsSendUrgent;
    else
        RaiseException('Invalid internal SendFlags');
        Result := wsSendNormal;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.TriggerDisplay(Msg : String);
begin
    if Assigned(FOnDisplay) then
        FOnDisplay(Self, Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.TriggerSendData(BytesSent : Integer);
begin
    if Assigned(FOnSendData) then
        FOnSendData(Self, BytesSent);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.TriggerSessionAvailable(Error : Word);
begin
    if Assigned(FOnSessionAvailable) then
        FOnSessionAvailable(Self, Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.TriggerSessionConnectedSpecial(Error : Word);
begin
    TriggerSessionConnected(Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.TriggerSessionConnected(Error : Word);
begin
    if Assigned(FOnSessionConnected) then
        FOnSessionConnected(Self, Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.TriggerSessionClosed(Error : Word);
begin
    if Assigned(FOnSessionClosed) then
        FOnSessionClosed(Self, Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomWSocket.TriggerDataAvailable(Error : Word) : Boolean;
begin
    Result := Assigned(FOnDataAvailable);
    if not Result then
        Exit;
{$IFDEF TOMASEK}                    { 23/01/99 }
    { Do not allow FD_READ messages, this will prevent reentering the }
    { OnDataAvailable event handler.                                  }
    FSelectEvent := FD_WRITE or FD_CLOSE or FD_CONNECT;
    WSocket_Synchronized_WSAASyncSelect(FHSocket, Handle, WM_ASYNCSELECT, FSelectEvent);
    try
        FRcvdFlag := TRUE;
        while Result and FRcvdFlag do begin
            { Trigger user code. This will normally call DoRecv which will }
            { update FRcvdFlag.                                            }
            { If user code is wrong, we'll loop forever !                  }
            FOnDataAvailable(Self, Error);
            Result := Assigned(FOnDataAvailable);
        end;
    finally
        { Allow all events now }
        FSelectEvent := FD_READ or FD_WRITE or FD_CLOSE or FD_CONNECT;
        WSocket_Synchronized_WSAASyncSelect(FHSocket, Handle, WM_ASYNCSELECT, FSelectEvent);
    end;
{$ELSE}                             { 23/01/99 }
    FOnDataAvailable(Self, Error);  { 23/01/99 }
{$ENDIF}                            { 23/01/99 }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.TriggerDataSent(Error : Word);
begin
    if Assigned(FOnDataSent) then
        FOnDataSent(Self, Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.TriggerError;
begin
    if Assigned(FOnError) then
        FOnError(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.TriggerDNSLookupDone(Error : Word);
begin
    if Assigned(FOnDNSLookupDone) then
        FOnDNSLookupDone(Self, Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.TriggerChangeState(OldState, NewState : TSocketState);
begin
    if Assigned(FOnChangeState) then
        FOnChangeState(Self, OldState, NewState);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomWSocket.SocketError(sockfunc: string);
var
    Error  : integer;
    Line   : string;
begin
    Error := WSocket_Synchronized_WSAGetLastError;
    Line  := 'Error '+ IntToStr(Error) + ' in function ' + sockfunc +
             #13#10 + WSocketErrorDesc(Error);

    if (Error = WSAECONNRESET) or
       (Error = WSAENOTCONN)   then begin
        WSocket_Synchronized_closesocket(FHSocket);
        FHSocket := INVALID_SOCKET;
        if FState <> wsClosed then
           TriggerSessionClosed(Error);
        ChangeState(wsClosed);
    end;

    FLastError := Error;
    RaiseException(Line);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function WSocketErrorDesc(error: integer) : string;
begin
    case error of
    0:
      WSocketErrorDesc := 'No Error';
    WSAEINTR:
      WSocketErrorDesc := 'Interrupted system call';
    WSAEBADF:
      WSocketErrorDesc := 'Bad file number';
    WSAEACCES:
      WSocketErrorDesc := 'Permission denied';
    WSAEFAULT:
      WSocketErrorDesc := 'Bad address';
    WSAEINVAL:
      WSocketErrorDesc := 'Invalid argument';
    WSAEMFILE:
      WSocketErrorDesc := 'Too many open files';
    WSAEWOULDBLOCK:
      WSocketErrorDesc := 'Operation would block';
    WSAEINPROGRESS:
      WSocketErrorDesc := 'Operation now in progress';
    WSAEALREADY:
      WSocketErrorDesc := 'Operation already in progress';
    WSAENOTSOCK:
      WSocketErrorDesc := 'Socket operation on non-socket';
    WSAEDESTADDRREQ:
      WSocketErrorDesc := 'Destination address required';
    WSAEMSGSIZE:
      WSocketErrorDesc := 'Message too long';
    WSAEPROTOTYPE:
      WSocketErrorDesc := 'Protocol wrong type for socket';
    WSAENOPROTOOPT:
      WSocketErrorDesc := 'Protocol not available';
    WSAEPROTONOSUPPORT:
      WSocketErrorDesc := 'Protocol not supported';
    WSAESOCKTNOSUPPORT:
      WSocketErrorDesc := 'Socket type not supported';
    WSAEOPNOTSUPP:
      WSocketErrorDesc := 'Operation not supported on socket';
    WSAEPFNOSUPPORT:
      WSocketErrorDesc := 'Protocol family not supported';
    WSAEAFNOSUPPORT:
      WSocketErrorDesc := 'Address family not supported by protocol family';
    WSAEADDRINUSE:
      WSocketErrorDesc := 'Address already in use';
    WSAEADDRNOTAVAIL:
      WSocketErrorDesc := 'Address not available';
    WSAENETDOWN:
      WSocketErrorDesc := 'Network is down';
    WSAENETUNREACH:
      WSocketErrorDesc := 'Network is unreachable';
    WSAENETRESET:
      WSocketErrorDesc := 'Network dropped connection on reset';
    WSAECONNABORTED:
      WSocketErrorDesc := 'Connection aborted';
    WSAECONNRESET:
      WSocketErrorDesc := 'Connection reset by peer';
    WSAENOBUFS:
      WSocketErrorDesc := 'No buffer space available';
    WSAEISCONN:
      WSocketErrorDesc := 'Socket is already connected';
    WSAENOTCONN:
      WSocketErrorDesc := 'Socket is not connected';
    WSAESHUTDOWN:
      WSocketErrorDesc := 'Can''t send after socket shutdown';
    WSAETOOMANYREFS:
      WSocketErrorDesc := 'Too many references: can''t splice';
    WSAETIMEDOUT:
      WSocketErrorDesc := 'Connection timed out';
    WSAECONNREFUSED:
      WSocketErrorDesc := 'Connection refused';
    WSAELOOP:
      WSocketErrorDesc := 'Too many levels of symbolic links';
    WSAENAMETOOLONG:
      WSocketErrorDesc := 'File name too long';
    WSAEHOSTDOWN:
      WSocketErrorDesc := 'Host is down';
    WSAEHOSTUNREACH:
      WSocketErrorDesc := 'No route to host';
    WSAENOTEMPTY:
      WSocketErrorDesc := 'Directory not empty';
    WSAEPROCLIM:
      WSocketErrorDesc := 'Too many processes';
    WSAEUSERS:
      WSocketErrorDesc := 'Too many users';
    WSAEDQUOT:
      WSocketErrorDesc := 'Disc quota exceeded';
    WSAESTALE:
      WSocketErrorDesc := 'Stale NFS file handle';
    WSAEREMOTE:
      WSocketErrorDesc := 'Too many levels of remote in path';
    WSASYSNOTREADY:
      WSocketErrorDesc := 'Network sub-system is unusable';
    WSAVERNOTSUPPORTED:
      WSocketErrorDesc := 'WinSock DLL cannot support this application';
    WSANOTINITIALISED:
      WSocketErrorDesc := 'WinSock not initialized';
    WSAHOST_NOT_FOUND:
      WSocketErrorDesc := 'Host not found';
    WSATRY_AGAIN:
      WSocketErrorDesc := 'Non-authoritative host not found';
    WSANO_RECOVERY:
      WSocketErrorDesc := 'Non-recoverable error';
    WSANO_DATA:
      WSocketErrorDesc := 'No Data';
    else
      WSocketErrorDesc := 'Not a WinSock error';
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

         X X        X X        X X       X      X      X X      X X X X
       X     X    X     X    X     X     X     X     X     X    X
       X          X     X    X           X   X       X          X
         X X      X     X    X           X X           X X        X X
             X    X     X    X           X   X             X          X
       X     X    X     X    X     X     X     X     X     X    X     X
         X X        X X        X X       X      X      X  X       X X

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.AssignDefaultValue;
begin
    inherited AssignDefaultValue;
    FSocksState          := socksData;
    FSocksServer         := '';
    FSocksPort           := '';
    FSocksLevel          := '5';
    FSocksRcvdCnt        := 0;
    FSocksPortAssigned   := FALSE;
    FSocksServerAssigned := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.SetSocksLevel(newValue : String);
begin
    if State <> wsClosed then begin
        RaiseException('Can''t change socks level if not closed');
        Exit;
    end;
    if (newValue <> '4')  and (newValue <> '5') and
       (newValue <> '4A') and (newValue <> '4a') then begin
        RaiseException('Invalid socks level. Must be 4, 4A or 5.');
        Exit;
    end;
    FSocksLevel := UpperCase(newValue);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.SetSocksPort(sPort : String);
begin
    if State <> wsClosed then begin
        RaiseException('Can''t change socks port if not closed');
        Exit;
    end;
    FSocksPort := Trim(sPort);
    if Length(FSocksPort) = 0 then begin
        FSocksPortAssigned := FALSE;
        Exit;
    end;
    FSocksPortAssigned := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.SetSocksServer(sServer : String);
begin
    if State <> wsClosed then begin
        RaiseException('Can''t change socks server if not closed');
        Exit;
    end;
    FSocksServer := Trim(sServer);
    if Length(FSocksServer) = 0 then begin
        FSocksServerAssigned := FALSE;
        Exit;
    end;
    FSocksServerAssigned := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.Listen;
begin
    { Check if we really wants to use socks server }
    if not FSocksServerAssigned then begin
        { No socks server assigned, Listen as usual }
        inherited Listen;
        Exit;
    end;
    RaiseException('Listening is not supported thru socks server');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.Connect;
begin
    { Check if we really wants to use socks server }
    if not FSocksServerAssigned then begin
        { No socks server assigned, connect as usual }
        inherited Connect;
        Exit;
    end;

    if LowerCase(FProtoStr) <> 'tcp' then begin
        RaiseException('tcp is the only protocol supported thru socks server');
        Exit;
    end;

    try
        if not FPortResolved then begin
            { The next line will trigger an exception in case of failure }
            sin.sin_port  := WSocket_Synchronized_htons(WSocket_Synchronized_ResolvePort(FSocksPort, FProtoStr));
            FPortResolved := TRUE;
        end;

        if not FAddrResolved then begin
            { The next line will trigger an exception in case of failure }
            sin.sin_addr.s_addr := WSocket_Synchronized_ResolveHost(FSocksServer).s_addr;
            FAddrResolved       := TRUE;
        end;
        { The next line will trigger an exception in case of failure }
        FPortNum := WSocket_Synchronized_ResolvePort(FPortStr, FProtoStr);
    except
        on E:Exception do begin
            RaiseException('connect: ' + E.Message);
            Exit;
        end;
    end;

    FSocksState := socksNegociateMethods;
    FRcvCnt     := 0;
    inherited Connect;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{function BufToStr(Buf : PChar; Cnt : Integer) : String;
begin
    Result := '';
    while Cnt > 0 do begin
        if Buf^ in [#32..#126] then
            Result := Result + Buf^
        else
            Result := Result + '#' + Format('%2.2d', [ord(Buf^)]);
        Inc(Buf);
        Dec(Cnt);
    end;
end;}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.TriggerSessionConnectedSpecial(Error : Word);
var
    Buf : array [0..2] of char;
begin
    if FSocksState = socksNegociateMethods then begin
        {ChangeState(wsSocksConnected);}
        TriggerSocksConnected(Error);
        if Error <> 0 then begin
            inherited TriggerSessionConnectedSpecial(Error);
            Exit;
        end;
        if FSocksLevel[1] = '4' then
            SocksDoConnect
        else begin
            if FSocksAuthentication = socksNoAuthentication then
                FSocksAuthNumber := #$00   { No authentification }
            else
                FSocksAuthNumber := #$02;  { Usercode/Password   }

            Buf[0] := #$05;                { Version number      }
            Buf[1] := #$01;                { Number of methods   }
            Buf[2] := FSocksAuthNumber;    { Method identifier   }
{TriggerDisplay('Send = ''' + BufToStr(Buf, 3) + '''');}
            Send(@Buf, 3);
        end;
    end
    else
        inherited TriggerSessionConnectedSpecial(Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.TriggerSessionClosed(Error : Word);
begin
    if FSocksState = socksAuthenticate then
        TriggerSocksAuthState(socksAuthFailure);
    inherited TriggerSessionClosed(Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.TriggerSocksConnected(Error : Word);
begin
    if Assigned(FOnSocksConnected) then
        FOnSocksConnected(Self, Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.TriggerSocksError(Error : Integer; Msg : String);
begin
    if Assigned(FOnSocksError) then
        FOnSocksError(Self, Error, Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.TriggerSocksAuthState(AuthState : TSocksAuthState);
begin
    if Assigned(FOnSocksAuthState) then
        FOnSocksAuthState(Self, AuthState);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.SocksDoAuthenticate;
var
    Buf     : array [0..127] of char;
    I       : Integer;
begin
    FSocksState := socksAuthenticate;
    TriggerSocksAuthState(socksAuthStart);
    Buf[0] := #$01; {06/03/99}           { Socks version }
    I      := 1;
    Buf[I] := chr(Length(FSocksUsercode));
    Move(FSocksUsercode[1], Buf[I + 1], Length(FSocksUsercode));
    I := I + 1 + Length(FSocksUsercode);
    Buf[I] := chr(Length(FSocksPassword));
    Move(FSocksPassword[1], Buf[I + 1], Length(FSocksPassword));
    I := I + 1 + Length(FSocksPassword);
    try
{TriggerDisplay('Send = ''' + BufToStr(Buf, I) + '''');}
        Send(@Buf, I);
    except
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.SocksDoConnect;
type
    pu_long = ^u_long;
var
    Buf     : array [0..127] of char;
    I       : Integer;
    ErrCode : Integer;
begin
    FSocksState := socksConnect;
    if FSocksLevel[1] = '4' then begin
        Buf[0] := #4;                                 { Version number  }
        Buf[1] := #1;                                 { Connect command }
        PWORD(@Buf[2])^  := WSocket_Synchronized_ntohs(FPortNum);  { Dest port       }
        if FSocksLevel = '4A' then
            { Conventional IP saying we can't convert the destination   }
            { host's domain name to find its IP address                 }
            { The destination must then follow the user ID              }
            pu_long(@Buf[4])^ := WSocket_Synchronized_inet_addr('0.0.0.1')
        else begin
            { With original SOCKS4, we have to supply the dest address  }
            try
                pu_long(@Buf[4])^ := WSocket_Synchronized_ResolveHost(FAddrStr).s_addr;
            except
                on E:Exception do begin
                     ErrCode := socksHostResolutionFailed;
                     TriggerSocksError(ErrCode, E.ClassName + ' ' + E.Message);
                     InternalClose(TRUE, ErrCode);
                     Exit;
                end;
            end;
        end;
        I := 8;
        if Length(FSocksUsercode) > 0 then begin
            { I'm not sure it has to be like that ! Should I also use the }
            { password or not ?                                           }
            Move(FSocksUsercode[1], Buf[I], Length(FSocksUsercode));
            I := I + Length(FSocksUsercode);
        end;
        Buf[I] := #0;
        Inc(I);
        if FSocksLevel = '4A' then begin
            { We have to supply the destintaion host name                 }
            Move(FAddrStr[1], Buf[I], Length(FAddrStr));
            I := I + Length(FAddrStr);
            Buf[I] := #0;  { Alon Gingold }
            Inc(I);        { Alon Gingold }
        end;
        { Buf[I] := #0;      Alon Gingold }
        { Inc(I);            Alon Gingold }
    end
    else begin
        Buf[0] := #$05;            { Socks version }
        Buf[1] := #$01;            { Connect command }
        Buf[2] := #$00;            { Reserved, must be $00 }
        Buf[3] := #$03;            { Address type is domain name }
        Buf[4] := chr(Length(FAddrStr));
        { Should check buffer overflow }
        Move(FAddrStr[1], Buf[5], Length(FAddrStr));
        I := 5 + Length(FAddrStr);
        PWord(@Buf[I])^ := WSocket_Synchronized_htons(FPortNum);
        I := I + 2;
    end;

    try
{TriggerDisplay('Send = ''' + BufToStr(Buf, I + 2) + '''');}
        Send(@Buf, I);
    except
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSocksWSocket.DataAvailableError(
    ErrCode : Integer;
    Msg     : String);
begin
{   TriggerSocksError(ErrCode, Msg); }
{   inherited TriggerSessionConnectedSpecial(ErrCode); }
{   InternalClose(TRUE, ErrCode); }
    TriggerSocksError(ErrCode, Msg);
    FSocksState := socksData;
    {**ALON** Added, so TriggerSessionConnectedSpecial will only call inherited}
    {inherited} TriggerSessionConnectedSpecial(ErrCode);
    {**ALON** removed 'inherited' now calls top level}
    InternalClose(TRUE, ErrCode);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomSocksWSocket.TriggerDataAvailable(Error : Word) : Boolean;
var
    Len     : Integer;
    I       : Integer;
    ErrCode : Word;
    ErrMsg  : String;
    InAddr  : TInAddr;
    AnsLen  : Integer;
begin
    if FSocksState = socksData then begin
        Result := inherited TriggerDataAvailable(Error);
        Exit;
    end;

    if Error <> 0 then begin
        DataAvailableError(Error, 'data receive error');
        Result := FALSE;
        Exit;
    end;

    if FSocksState = socksNegociateMethods then begin
        Result := TRUE;
        Len := Receive(@FRcvBuf[FRcvCnt], Sizeof(FRcvBuf) - FRcvCnt - 1);
        if Len < 0 then
            Exit;
        FRcvCnt := FRcvCnt + Len;
{TriggerDisplay('socksNegociateMethods FrcvBuf = ''' + BufToStr(FRcvBuf, FRcvCnt) + '''');}
        if FSocksLevel[1] = '4' then begin
            { We should never comes here }
            DataAvailableError(socksProtocolError, 'TWSocket logic error');
            Exit;
        end
        else begin  { SOCKS5 }
            { We are waiting only two bytes }
            if FRcvCnt < 2 then
                Exit;
{            if FRcvCnt <> 2 then begin  06/03/99}
{                DataAvailableError(socksProtocolError, 'too much data availaible');}
{                Exit;                                                              }
{            end;                                                                   }
            FRcvCnt := 0; { Clear receive counter }
            if FRcvBuf[0] <> #$05 then begin
                DataAvailableError(socksVersionError, 'socks version error');
                Exit;
            end;
            if FRcvBuf[1] = #$00 then begin
                { No authentication required }
                if FSocksAuthNumber <> #$00 then
                    { We asked for authentification, so complains... }
                    TriggerSocksAuthState(socksAuthNotRequired);
            end
            else if FRcvBuf[1] = #$02 then begin
                { Usercode/Password authentication required }
                SocksDoAuthenticate;
                Exit;
            end
            else begin
                DataAvailableError(socksAuthMethodError, 'authentification method not acceptable');
                Exit;
            end;
            SocksDoConnect;
        end;
    end
    else if FSocksState = socksConnect then begin
        Result := TRUE;
{TriggerDisplay('socksConnect FrcvBuf = ''' + BufToStr(FRcvBuf, FRcvCnt) + '''');}
        if FSocksLevel[1] = '4' then begin
            { We wants at most 8 characters }
            Len := Receive(@FRcvBuf[FRcvCnt], 8 - FRcvCnt);
            if Len < 0 then
                Exit;
            FRcvCnt := FRcvCnt + Len;
            { We are waiting for 8 bytes }
            if FRcvCnt < 8 then
                Exit;
            FRcvCnt := 0; { Clear receive counter }
            if FRcvBuf[0] <> #0 then begin
                DataAvailableError(socksVersionError, 'socks version error');
                Exit;
            end;
            if FRcvBuf[1] <> #90 then begin  { david.brock }
                case FRcvBuf[1] of
                #91: ErrCode := socksRejectedOrFailed;
                #92: ErrCode := socksConnectionRefused;
                #93: ErrCode := socksAuthenticationFailed;
                else
                   ErrCode := socksUnassignedError;
                end;
                case ErrCode of
                socksRejectedOrFailed :
                    ErrMsg := 'request rejected or failed';
                socksConnectionRefused :
                    ErrMsg := 'connection refused';
                socksAuthenticationFailed :
                    ErrMsg := 'authentification failed';
                else
                    ErrMsg := 'unassigned error #' + IntToStr(Ord(FRcvBuf[1]));
                end;
                DataAvailableError(ErrCode, ErrMsg);
                Exit;
            end;
            FSocksState := socksData;
{           inherited TriggerSessionConnectedSpecial(0); }
{           Result := inherited TriggerDataAvailable(0); }
            {inherited} TriggerSessionConnectedSpecial(0);
            {**ALON** removed 'inherited' now calls top level}
            Result := {inherited} TriggerDataAvailable(0);
            {**ALON** removed 'inherited' now calls top level}
        end
        else begin { SOCKS5 }
            Len := Receive(@FRcvBuf[FRcvCnt], Sizeof(FRcvBuf) - FRcvCnt - 1);
            if Len < 0 then
                Exit;
            FRcvCnt := FRcvCnt + Len;
            if FRcvCnt >= 1 then begin
                { First byte is version, we expect version 5 }
                if FRcvBuf[0] <> #$05 then begin
                    DataAvailableError(socksVersionError, 'socks version error');
                    Exit;
                end;
            end;
            if FRcvCnt >= 2 then begin
                if FRcvBuf[1] <> #$00 then begin
                    case FRcvBuf[1] of
                    #1: ErrCode := socksGeneralFailure;
                    #2: ErrCode := socksConnectionNotAllowed;
                    #3: ErrCode := socksNetworkUnreachable;
                    #4: ErrCode := socksHostUnreachable;
                    #5: ErrCode := socksConnectionRefused;
                    #6: ErrCode := socksTtlExpired;
                    #7: ErrCode := socksUnknownCommand;
                    #8: ErrCode := socksUnknownAddressType;
                    else
                       ErrCode := socksUnassignedError;
                    end;
                    case ErrCode of
                    socksGeneralFailure :
                        ErrMsg := 'general SOCKS server failure';
                    socksConnectionNotAllowed :
                        ErrMsg := 'connection not allowed by ruleset';
                    socksNetworkUnreachable :
                        ErrMsg := 'network unreachable';
                    socksHostUnreachable :
                        ErrMsg := 'host unreachable';
                    socksConnectionRefused :
                        ErrMsg := 'connection refused';
                    socksTtlExpired :
                        ErrMsg := 'time to live expired';
                    socksUnknownCommand :
                        ErrMsg := 'command not supported';
                    socksUnknownAddressType :
                        ErrMsg := 'address type not supported';
                    else
                        ErrMsg := 'unassigned error #' + IntToStr(Ord(FRcvBuf[1]));
                    end;
                    DataAvailableError(ErrCode, ErrMsg);
                    Exit;
                end;
            end;
            if FRcvCnt < 5 then
                Exit;

            { We have enough data to learn the answer length }
            if FRcvBuf[3] = #$01 then
                AnsLen := 10                     { IP V4 address }
            else if FRcvBuf[3] = #$03 then
                AnsLen := 7 + Ord(FRcvBuf[4])    { Domain name   }
            else
                AnsLen := 5;                     { Other unsupported }

            if FRcvCnt < AnsLen then
                Exit;

            if FRcvBuf[3] = #$01 then begin
                { IP V4 address }
                Move(FRcvBuf[4], InAddr, 4);
                FBoundAddr := StrPas(WSocket_Synchronized_inet_ntoa(InAddr));
                I := 4 + 4;
            end
            else if FRcvBuf[3] = #$03 then begin
                { Domain name }
                SetLength(FBoundAddr, Ord(FRcvBuf[4]));
                Move(FRcvBuf[5], FBoundAddr[1], Length(FBoundAddr)); { david.brock }
                I := 4 + Ord(FRcvBuf[4]) + 1;
            end
            else begin
                { Unsupported address type }
                DataAvailableError(socksUnknownAddressType, 'address type not supported');
                Exit;
            end;

            FBoundPort  := format('%d', [WSocket_Synchronized_ntohs(PWord(@FRcvBuf[I])^)]);
            I           := I + 2;
            FSocksState := socksData;
{           inherited TriggerSessionConnectedSpecial(0); }
{ if IsConsole then WriteLn('SOCKS5 NEGOCIATION OK');}
            {inherited} TriggerSessionConnectedSpecial(0);
            {**ALON** removed 'inherited' now calls top level}
            FSocksRcvdCnt := FRcvCnt - I;
            if FSocksRcvdCnt < 0 then
                FSocksRcvdCnt := 0
            else
                FSocksRcvdPtr := @FRcvBuf[I];
{           Result := inherited TriggerDataAvailable(0);}
            Result := {inherited} TriggerDataAvailable(0);
            {**ALON** removed 'inherited' now calls top level}
        end;
    end
    else if FSocksState = socksAuthenticate then begin
        Result := TRUE;
        Len := Receive(@FRcvBuf[FRcvCnt], Sizeof(FRcvBuf) - FRcvCnt - 1);
        if Len < 0 then
            Exit;
        FRcvCnt := FRcvCnt + Len;
{TriggerDisplay('socksAuthenticate FrcvBuf = ''' + BufToStr(FRcvBuf, FRcvCnt) + '''');}
        if FRcvCnt >= 1 then begin
            { First byte is version, we expect version 5 }
            if FRcvBuf[0] <> #$01 then begin { 06/03/99 }
{                TriggerSocksAuthState(socksAuthFailure); Burlakov 12/11/99 }
                DataAvailableError(socksVersionError, 'socks version error');
                Exit;
            end;
        end;
        if FRcvCnt = 2 then begin
            { Second byte is status }
            if FRcvBuf[1] <> #$00 then begin
{                TriggerSocksAuthState(socksAuthFailure); Burlakov 12/11/99 }
                DataAvailableError(socksAuthenticationFailed, 'socks authentication failed');
                Exit;
            end;
        end
        else if FRcvCnt > 2 then begin
{            TriggerSocksAuthState(socksAuthFailure); Burlakov 12/11/99 }
            DataAvailableError(socksProtocolError, 'too much data availaible');
            Exit;
        end;
        FRcvCnt := 0; { 06/03/99 }
        TriggerSocksAuthState(socksAuthSuccess);
        SocksDoConnect;
    end
    else begin
        { We should never comes here ! }
        DataAvailableError(socksInternalError, 'internal error');
        Result := FALSE;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomSocksWSocket.GetRcvdCount : LongInt;
begin
    if FSocksRcvdCnt <= 0 then
        Result := inherited GetRcvdCount
    else
        Result := FSocksRcvdCnt;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomSocksWSocket.DoRecv(
    var Buffer;
    BufferSize : Integer;
    Flags      : Integer) : Integer;
begin
    if FSocksRcvdCnt <= 0 then begin
        Result := inherited DoRecv(Buffer, BufferSize, Flags);
        Exit;
    end;
    { We already have received data into our internal buffer }
    if FSocksRcvdCnt <= BufferSize then begin
        { User buffer is greater than received data, copy all and clear }
        Move(FSocksRcvdPtr^, Buffer, FSocksRcvdCnt);
        Result        := FSocksRcvdCnt;
        FSocksRcvdCnt := 0;
        Exit;
    end;
    { User buffer is smaller, copy as much as possible }
    Move(FSocksRcvdPtr^, Buffer, BufferSize);
    Result        := BufferSize;
    FSocksRcvdPtr := FSocksRcvdPtr + BufferSize;
    FSocksRcvdCnt := FSocksRcvdCnt - BufferSize;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

              X          X     X       X      X X X X
              X          X     X X     X      X
              X          X     X   X   X      X
              X          X     X     X X      X X X
              X          X     X       X      X
              X          X     X       X      X
              X X X X    X     X       X      X X X X

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TCustomLineWSocket.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FLineEnd   := #13#10;
    FLineMode  := FALSE;
    FLineLimit := 65536;  { Arbitrary line limit }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TCustomLineWSocket.Destroy;
begin
    if FRcvdPtr <> nil then begin
        FreeMem(FRcvdPtr, FRcvBufSize);
        FRcvdPtr     := nil;
        FRcvBufSize := 0;
    end;
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomLineWSocket.WndProc(var MsgRec: TMessage);
begin
    with MsgRec do begin
        if Msg = WM_TRIGGER_DATA_AVAILABLE then begin
            { We *MUST* handle all exception to avoid application shutdown }
            try
                WMTriggerDataAvailable(MsgRec)
            except
                on E:Exception do
                    HandleBackGroundException(E);
            end;
        end
        else
            inherited WndProc(MsgRec);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomLineWSocket.WMTriggerDataAvailable(var msg: TMessage);
var
    Count : Integer;
begin
{$IFDEF OLD_20040117}
    while FRcvdCnt > 0 do
        TriggerDataAvailable(0);
{$ELSE}
    Count := 0;
    while FRcvdCnt > 0 do begin
        Inc(Count);
        FLineFound := FALSE;
        TriggerDataAvailable(0);
        if (FRcvdCnt <= 0) or
           (FLineMode and (Count > 3) and (not FLineFound)) then
            Break;
    end;
{$ENDIF}
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomLineWSocket.SetLineMode(newValue : Boolean);
begin
    if FLineMode = newValue then
        Exit;
    FLineMode := newValue;
    if (FRcvdCnt > 0) or (FLineLength > 0) then
        PostMessage(Handle, WM_TRIGGER_DATA_AVAILABLE, 0, 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Return -1 if error, else return number of byte written                    }
function TCustomLineWSocket.SendLine(const Str : String) : Integer;
begin
    Result := Length(Str);
    if Result > 0 then begin
        PutDataInSendBuffer(@Str[1], Result);
        SendStr(LineEnd);
        Inc(Result, 2);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomLineWSocket.GetRcvdCount : LongInt;
begin
    if not FLineMode then
        Result := inherited GetRcvdCount
    else
        Result := FLineLength;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomLineWSocket.DoRecv(
    var Buffer;
    BufferSize : Integer;
    Flags      : Integer) : Integer;
begin
    if FLineMode and (FLineLength > 0) then begin
        { We are in line mode an a line is received }
        if FLineLength <= BufferSize then begin
            { User buffer is greater than received data, copy all and clear }
            Move(FRcvdPtr^, Buffer, FLineLength);
            Result      := FLineLength;
            FLineLength := 0;
            Exit;
        end;
        { User buffer is smaller, copy as much as possible }
        Move(FRcvdPtr^, Buffer, BufferSize);
        Result   := BufferSize;
        { Move the end of line to beginning of buffer to be read the next time }
        Move(FRcvdPtr[BufferSize], FRcvdPtr^, FLineLength - BufferSize);
        FLineLength := FLineLength - BufferSize;
        Exit;
    end;

    if FLineMode or (FRcvdCnt <= 0) then begin
        { There is nothing in our internal buffer }
        Result := inherited DoRecv(Buffer, BufferSize, Flags);
        Exit;
    end;

    { We already have received data into our internal buffer }
    if FRcvdCnt <= BufferSize then begin
        { User buffer is greater than received data, copy all and clear }
        Move(FRcvdPtr^, Buffer, FRcvdCnt);
        Result   := FRcvdCnt;
        FRcvdCnt := 0;
        Exit;
    end;
    { User buffer is smaller, copy as much as possible }
    Move(FRcvdPtr^, Buffer, BufferSize);
    Result   := BufferSize;
    { Then move remaining data to front og buffer  16/10/99 }
    Move(FRcvdPtr[BufferSize], FRcvdPtr^, FRcvdCnt - BufferSize + 1);
    FRcvdCnt := FRcvdCnt - BufferSize;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Edit received data. Handle TAB and BACKSPACE characters.                  }
{ A data packet has been received into FRcvPtr buffer, starting from        }
{ FRcvdCnt offset. Packet size if passed as the Len argument.               }
procedure TCustomLineWSocket.EditLine(var Len : Integer);
var
    Buf     : PChar;
    BufSize : LongInt;
    I       : LongInt;
    J       : LongInt;
    Edited  : Boolean;
    NewCnt  : LongInt;
    NewSize : LongInt;
const
    BackString : String = #8 + ' ' + #8;
begin
    BufSize := 0;
    try
        Edited := FALSE;
        I      := FRcvdCnt;
        J      := FRcvdCnt;
        NewCnt := FRcvdCnt;
        { Loop to process all received char }
        while I < (FRcvdCnt + Len) do begin
            if FRcvdPtr[I] = #8 then begin   { BACKSPACE character }
                if FLineEcho and (J > 0) then
                    SendStr(BackString);
                if not Edited then begin
                    { Not edited yet, so we allocate a buffer to store }
                    { edited data and we remember we edited data.      }
                    Edited := TRUE;
                    { Computer buffer size as a multiple of 256 bytes  }
                    BufSize := ((FRcvdCnt + Len + 256) shr 8) shl 8;
                    GetMem(Buf, BufSize);
                    { Copy data already processed }
                    Move(FRcvdPtr^, Buf^, I);
                end;
                if J > 0 then begin
                    Dec(J);
                    if J < NewCnt then
                        NewCnt := J;
                end;
                Inc(I);
            end
            else if FRcvdPtr[I] = #9 then begin  { TAB character }
                if not Edited then begin
                    { Not edited yet, so we allocate a buffer to store }
                    { edited data and we remember we edited data.      }
                    Edited := TRUE;
                    { Computer buffer size as a multiple of 256 bytes  }
                    BufSize := ((FRcvdCnt + Len + 256) shr 8) shl 8;
                    GetMem(Buf, BufSize);
                    { Copy data already processed }
                    Move(FRcvdPtr^, Buf^, I);
                end;
                repeat
                    if FLineEcho then
                        SendStr(' ');
                    Buf[J] := ' ';
                    Inc(J);
                until (J and 7) = 0;
                Inc(I);
            end
            else begin
                if FLineEcho then
                    Send(@FRcvdPtr[I], 1);
                if Edited then begin
                    if J >= BufSize then begin
                        { Need to allocate more buffer space }
                        NewSize := BufSize + 256;
                        {$IFDEF DELPHI1}
                        Buf := ReallocMem(Buf, BufSize, NewSize);
                        {$ELSE}
                        ReallocMem(Buf, NewSize);
                        {$ENDIF}
                        BufSize := NewSize;
                    end;
                    Buf[J] := FRcvdPtr[I];
                end;
                Inc(I);
                Inc(J);
            end;
        end;
        if Edited then begin
            if J >= FRcvBufSize then begin
                { Current buffer is too small, allocate larger }
                NewSize := J + 1;
                {$IFDEF DELPHI1}
                FRcvdPtr := ReallocMem(FRcvdPtr, FRcvBufSize, NewSize);
                {$ELSE}
                ReallocMem(FRcvdPtr, NewSize);
                {$ENDIF}
                FRcvBufSize := NewSize;
            end;
            { Move edited data back to original buffer }
            Move(Buf^, FRcvdPtr^, J);
            FRcvdPtr[J] := #0;
            FRcvdCnt := NewCnt;
            Len      := J - FRcvdCnt;
        end;
    finally
        if BufSize > 0 then
            FreeMem(Buf, BufSize);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomLineWSocket.TriggerLineLimitExceeded(
    Cnt           : Integer;
    var ClearData : Boolean);
begin
    if Assigned(FOnLineLimitExceeded) then
        FOnLineLimitExceeded(Self, Cnt, ClearData);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomLineWSocket.TriggerDataAvailable(Error : Word) : Boolean;
var
    Cnt        : Integer;
    Len        : Integer;
    NewSize    : LongInt;
    SearchFrom : LongInt;
    I          : LongInt;
    Found      : Boolean;
begin
{  if (not FLineMode) or (Length(FLineEnd) = 0) then begin }
    if (not FLineMode) or (Length(FLineEnd) = 0) or (FSocksState <> socksData)
    {**ALON** added check so, if data is received while still handshaking }
    { with the socks server, we ask the TCustomSocksWSocket to handle it  }
    then begin
        { We are not in line mode }
        Result := inherited TriggerDataAvailable(Error);
        Exit;
    end;

    { We are in line mode. We receive data ourself }

    Result := TRUE;
    Cnt    := inherited GetRcvdCount;
    { if Cnt <= 0 then }
    {    Exit;         }
    if Cnt < 0 then
        Exit;
    if Cnt = 0 then
        Cnt := 255;

    if (FRcvdCnt + Cnt + 1) > FRcvBufSize then begin
        { Current buffer is too small, allocate larger }
        NewSize := FRcvdCnt + Cnt + 1;
        {$IFDEF DELPHI1}
        FRcvdPtr := ReallocMem(FRcvdPtr, FRcvBufSize, NewSize);
        {$ELSE}
        ReallocMem(FRcvdPtr, NewSize);
        {$ENDIF}
        FRcvBufSize := NewSize;
    end;

    Len := Receive(FRcvdPtr + FRcvdCnt, Cnt);
{$IFDEF OLD_20040117}
    if Len <= 0 then
        Exit;
    FRcvdPtr[FRcvdCnt + Len] := #0;
{$ELSE}
    if Len <= 0 then begin
        if FRcvdCnt <= 0 then
            Exit;
        Len := 0;
    end;
{$ENDIF}

    if Len > 0 then begin
        if FLineEdit then
            EditLine(Len)
        else if FLineEcho then
            Send(FRcvdPtr + FRcvdCnt, Len);
    end;

    SearchFrom := FRcvdCnt - Length(FLineEnd);
    if SearchFrom < 0 then
        SearchFrom := 0;
    FRcvdCnt := FRcvdCnt + Len;
    while FLineMode do begin
        Found := FALSE;
        I := SearchFrom;
        while I < (FRcvdCnt - Length(FLineEnd) + 1) do begin
            if FRcvdPtr[I] = FLineEnd[1] then begin
                Found := (StrLComp(@FRcvdPtr[I], @FLineEnd[1], Length(FLineEnd)) = 0);
                if Found then
                    break;    { Found the end of line marker }
            end;
            Inc(I);
        end;
        if not Found then begin
            if ((FLineLimit > 0) and (FRcvdCnt > FLineLimit)) then begin
                FLineClearData := TRUE;
                TriggerLineLimitExceeded(FRcvdCnt, FLineClearData);
                if FLineClearData then begin
                    FLineLength        := 0;
                    FRcvdCnt           := 0;
                    FLineClearData     := FALSE;
                end;
            end;
            break;
        end;
        FLineLength       := I + Length(FLineEnd);
        FLineReceivedFlag := TRUE;
        FLineFound        := TRUE;
        { We received a complete line. We need to signal it to application }
        { The application may not have a large buffer so we may need       }
        { several events to read the entire line. In the meanwhile, the    }
        { application may turn line mode off.                              }
        while FLineMode and (FLineLength > 0) do begin
            if not inherited TriggerDataAvailable(0) then
                { There is no handler installed }
                FLineLength := 0;
        end;
        { Move remaining data in front of buffer }
        if FLineLength > 0 then begin
            { Line mode was turned off in the middle of a line read. }
            { We preserve unread line and other received data.       }
            Move(FRcvdPtr[I], FRcvdPtr[FLineLength],
                 FRcvdCnt - I);
            FRcvdCnt := FRcvdCnt - I + FLineLength;
        end
        else begin
            Move(FRcvdPtr[I + Length(FLineEnd)], FRcvdPtr[0],
                 FRcvdCnt - I - Length(FLineEnd));
            FRcvdCnt := FRcvdCnt - I - Length(FLineEnd);
        end;
        if FRcvdCnt >= 0 then
            FRcvdPtr[FRcvdCnt] := #0;
        SearchFrom := 0;
        { It is possible the user has turned line mode to off. If data is }
        { still available in the receive buffer, we will deliver it.      }
        while (not FLineMode) and (FRcvdCnt > 0) do            { 26/01/04 }
            inherited TriggerDataAvailable(0);                 { 26/01/04 }
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomLineWSocket.TriggerSessionClosed(Error : Word);
begin
    FLineReceivedFlag := TRUE;
    if FRcvdPtr <> nil then begin
        if FLineMode and (FRcvdCnt > 0) and (not FLineClearData) then begin
            FLineLength       := FRcvdCnt;
            while FLineMode and (FLineLength > 0) do
                inherited TriggerDataAvailable(0);
        end;
        FreeMem(FRcvdPtr, FRcvBufSize);
        FRcvdPtr    := nil;
        FRcvBufSize := 0;
        FRcvdCnt    := 0;
    end;
    inherited TriggerSessionClosed(Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

                 X X      X     X    X       X     X X X
               X     X      X   X    X X     X   X      X
               X              X X    X   X   X   X
                 X X            X    X     X X   X
                     X          X    X       X   X
               X     X    X     X    X       X   X      X
                 X X        X X      X       X     X X X

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCustomSyncWSocket.InternalDataAvailable(
    Sender : TObject;
    Error  : Word);
var
    Len : Integer;
begin
    SetLength(FLinePointer^, FLineLength);
    Len := Receive(@FLinePointer^[1], FLineLength);
    if Len <= 0 then
        FLinePointer^ := ''
    else
        SetLength(FLinePointer^, Len);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TCustomSyncWSocket.WaitUntilReady(var DoneFlag : Boolean) : Integer;
begin
    Result := 0;           { Suppose success }
    FTimeStop := Integer(GetTickCount) + FTimeout;
    while TRUE do begin
        if DoneFlag then begin
            Result := 0;
            break;
        end;

        if ((FTimeout > 0) and (Integer(GetTickCount) > FTimeStop)) or
{$IFNDEF NOFORMS}
           Application.Terminated or
{$ENDIF}
           FTerminated then begin
            { Application is terminated or timeout occured }
            Result := WSA_WSOCKET_TIMEOUT;
            break;
        end;
        MessagePump;
{$IFDEF COMPILER2_UP}
        { Do not use 100% CPU, but slow down transfert on high speed LAN }
        Sleep(0);
{$ENDIF}
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ DEPRECATED: DO NOT USE Synchronize procedure for a new application.       }
{ Instead, use pure event-driven design.                                    }
function TCustomSyncWSocket.Synchronize(
    Proc : TWSocketSyncNextProc;
    var DoneFlag : Boolean) : Integer;
begin
    DoneFlag := FALSE;
    if Assigned(Proc) then
        Proc;
    Result := WaitUntilReady(DoneFlag);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ DEPRECATED: DO NOT USE ReadLine procedure for a new application.          }
{ Instead, use pure event-driven design using OnDataAvailable event.        }
procedure TCustomSyncWSocket.ReadLine(
    Timeout    : Integer;  { seconds if positive, milli-seconds if negative }
    var Buffer : String);
var
    OldDataAvailable : TDataAvailable;
    OldLineMode      : Boolean;
    Status           : Integer;
begin
    Buffer            := '';
    if FState <> wsConnected then begin
        RaiseException('ReadLine failed: not connected');
        Exit;
    end;

    { Positive timeout means seconds. Negative means milli-seconds }
    { Null means 60 seconds.                                       }
    if TimeOut = 0 then
        FTimeOut      := 60000
    else if TimeOut > 0 then
        FTimeOut      := Timeout * 1000
    else
        FTimeOut      := -Timeout;

    FLineReceivedFlag := FALSE;
    FLinePointer      := @Buffer;
    { Save existing OnDataAvailable handler and install our own }
    OldDataAvailable  := FOnDataAvailable;
    FOnDataAvailable  := InternalDataAvailable;
    { Save existing line mode and turn it on }
    OldLineMode       := FLineMode;
    FLineMode         := TRUE;
    try
        Status := Synchronize(nil, FLineReceivedFlag);
        if Status = WSA_WSOCKET_TIMEOUT then begin
             { Sender didn't send line end within allowed time. Get all }
             { data available so far.                                   }
             if FRcvdCnt > 0 then begin
                 SetLength(Buffer, FRcvdCnt);
                 Move(FRcvdPtr^, Buffer[1], FRcvdCnt);
                 FRcvdCnt := 0;
             end;
        end;
        { Should I raise an exception to tell the application that       }
        { some error occured ?                                           }
    finally
        FOnDataAvailable := OldDataAvailable;
        FLineMode        := OldLineMode;
    end;
end;

{ You must define USE_SSL so that SSL code is included in the component.    }
{ To be able to compile the component, you must have the SSL related files  }
{ which are _NOT_ freeware. See http://www.overbyte.be for details.         }
{$IFDEF USE_SSL}
    {$I WSocketImplSsl.inc}
{$ENDIF}

{$IFDEF DELPHI1}
begin
    IPList := TStringList.Create;
    {
      Delphi 1 has no finalization. When your application terminates, you
      should add a call to WSocketUnloadWinsock to unload winsock from memory.
      It is done automatically for you when the last TWSocket component is
      destroyed but if you do any winsock call after that, you must call
      WSocketUnloadWinsock yourself. It is safe to call WSocketUnloadWinsock
      even if it has already been done.
    }
{$ELSE}
initialization
    IPList         := TStringList.Create;
    InitializeCriticalSection(GClassCritSect);
    InitializeCriticalSection(GWSockCritSect);

finalization
    if Assigned(IPList) then begin
        IPList.Destroy;
        IPList := nil;
    end;
    if WSocketGCount <= 0 then begin    { FP 15/09/03 }
        DeleteCriticalSection(GClassCritSect);
        WSocketUnloadWinsock;
        DeleteCriticalSection(GWSockCritSect);
    end;

{$ENDIF}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.


