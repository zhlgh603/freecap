unit rpcrt;

interface
uses Windows;

const
   RPC_S_OK = ERROR_SUCCESS;
   RPC_S_INVALID_ARG = ERROR_INVALID_PARAMETER;
   RPC_S_OUT_OF_MEMORY = ERROR_OUTOFMEMORY;
   RPC_S_OUT_OF_THREADS = ERROR_MAX_THRDS_REACHED;
   RPC_S_INVALID_LEVEL = ERROR_INVALID_PARAMETER;
   RPC_S_BUFFER_TOO_SMALL = ERROR_INSUFFICIENT_BUFFER;
   RPC_S_INVALID_SECURITY_DESC = ERROR_INVALID_SECURITY_DESCR;
   RPC_S_ACCESS_DENIED = ERROR_ACCESS_DENIED;
   RPC_S_SERVER_OUT_OF_MEMORY = ERROR_NOT_ENOUGH_SERVER_MEMORY;
   RPC_X_NO_MEMORY = RPC_S_OUT_OF_MEMORY;
   RPC_X_INVALID_BOUND = RPC_S_INVALID_BOUND;
   RPC_X_INVALID_TAG = RPC_S_INVALID_TAG;
   RPC_X_ENUM_VALUE_TOO_LARGE = RPC_X_ENUM_VALUE_OUT_OF_RANGE;
   RPC_X_SS_CONTEXT_MISMATCH  = ERROR_INVALID_HANDLE;
   RPC_X_INVALID_BUFFER = ERROR_INVALID_USER_BUFFER;

type
  PPUCHAR = ^PUCHAR;


  function UuidCreate(guid: PGUID): LongWord; stdcall;
  function UuidToString(guid: PGUID; StringUuid: PPUCHAR): LongWord; stdcall; 
  function UuidFromString(StringUuid: PPUCHAR; guid: PGUID): LongWord; stdcall; 
  function RpcStringFree(StringUuid: PUCHAR): LongWord; stdcall; 


const
  RPCRTDLL = 'rpcrt4.dll';

implementation


function UuidCreate(guid: PGUID): LongWord; stdcall; external RPCRTDLL;
function UuidToString(guid: PGUID; StringUuid: PPUCHAR): LongWord; stdcall; external RPCRTDLL name 'UuidToStringA';
function UuidFromString(StringUuid: PPUCHAR; guid: PGUID): LongWord; stdcall; external RPCRTDLL name 'UuidFromStringA';
function RpcStringFree(StringUuid: PUCHAR): LongWord; stdcall; external RPCRTDLL name 'RpcStringFreeA';

end.