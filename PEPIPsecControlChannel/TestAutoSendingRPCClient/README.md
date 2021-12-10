# TestRPCClient

Test RPC client (aka. RPCConnector).

Simple executable that:

- starts a connection to the server (aka. RPCSupervisor)
- repeatally calls `send` on the SupervisorInterface in a given time interval
