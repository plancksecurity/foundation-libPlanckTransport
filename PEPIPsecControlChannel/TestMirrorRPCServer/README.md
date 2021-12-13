# TestMirrorRPCServer

Mirrors all it gets. Made for Engine team for testing the CC transport.

Simple executable that:

- starts an IPsecRPCServer
- pings back (mirrors) everything that arrives via RPCTrasport (i.e. calls receive() on the client with the message from a called `send()`).

Note: You can not run and test this (and any other of our RPC servers/clients) using Xcode. It relies on sending and receiving SIGUSR1, which Xcodes LLDB eats up (i.e. does stop, does not pass the signal). Run and debug it from console instead.
