# TestRPCClient

Test RPC client (aka. Connector).

Simple executable that:

- starts a connection to the server (aka. Supervisor)
- repeatally calls `send` on the SupervisorInterface in a given time interval
