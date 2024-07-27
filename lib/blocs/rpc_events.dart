abstract class RPCEvents {}

class StartServer extends RPCEvents {
  final String address;
  final String ignoreMethods;
  final String whiteList;
  StartServer(this.address, this.ignoreMethods, this.whiteList);
}

class StopServer extends RPCEvents {}

class ExitServer extends RPCEvents {}

class InitBlocRPC extends RPCEvents {}