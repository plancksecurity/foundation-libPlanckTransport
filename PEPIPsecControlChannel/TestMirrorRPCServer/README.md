# TestMirrorRPCServer

Mirrors all it gets. Made for Engine team for testing the CC transport.

Simple executable that:

- starts an IPsecRPCServer
- pings back (mirrors) everything that arrives via RPCTrasport (i.e. calls receive() on the client with the message from a called `send()` )
