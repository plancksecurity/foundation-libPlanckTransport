# TestAutoSendingControlChannel

Test Control Channel.

Simple executable that:

- starts a connection to the server (aka. Supervisor)
- repeatally calls `send` on the SupervisorInterface in a given time interval.

Note: You can not run and test this (and any other of our RPC servers/clients) using Xcode. It relies on sending and receiving SIGUSR1, which Xcodes LLDB eats up (i.e. does stop, does not pass the signal). Run and debug it from console instead. 
