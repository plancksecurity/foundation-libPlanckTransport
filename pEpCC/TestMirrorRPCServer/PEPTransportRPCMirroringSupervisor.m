//
//  PEPTransportRPCMirroringSupervisor.m
//  TestMirrorRPCServer_macOS
//
//  Created by Andreas Buff on 29.11.21.
//

#import "PEPTransportRPCMirroringSupervisor.h"

#import <pEpIPsecRPCObjCAdapter.h>

@interface PEPTransportRPCMirroringSupervisor ()
@property PEPRPCSupervisor *supervisor;
@property PEPRPCConnectorTransportInterface *connectorTransportInterface;
@end

@implementation PEPTransportRPCMirroringSupervisor

- (instancetype)init {
    if (self = [super init]) {
        _supervisor = [PEPRPCSupervisor new];
    }
    return self;
}

///BUFF: default port! fix!
///TODO:
-(void)start {
    [self log:@"Starting"];
    [self.supervisor startServerWithIPsecDelegate:self transportDelegate:self config:[[PEPRPCSupervisorConfig alloc] initWithPort:5923]];
}

// MARK: - PRIVATE

- (void)log:(NSString*)msg {
    NSLog(@"PEPTransportRPCMirroringSupervisor: %@", msg);
}

// MARK: - PEPRPCSupervisorIPsecDelegate

- (void)handleInstallTunnel:(nonnull PEPRPCConnectorIPsecInterface *)connector tunnelParameters:(nonnull PEPTunnelParameters *)tunnelParameters onSuccess:(nonnull void (^)(void))successCallback onError:(nonnull void (^)(NSError * _Nonnull))errorCallback {
    NSAssert(false, @"PEPRPCSupervisorIPsecDelegate handleInstallTunnel called. Unexpected. Only Trasnport related stuff should be called here.");
}

- (void)handleRemoveTunnel:(nonnull PEPRPCConnectorIPsecInterface *)connector tunnelParameters:(nonnull PEPTunnelParameters *)tunnelParameters onSuccess:(nonnull void (^)(void))successCallback onError:(nonnull void (^)(NSError * _Nonnull))errorCallback {
    NSAssert(false, @"PEPRPCSupervisorIPsecDelegate handleRemoveTunnel called. Unexpected. Only Trasnport related stuff should be called here.");
}

// MARK: - PEPRPCSupervisorTransportDelegate

- (void)handleRPCConnectSuccess:(nonnull PEPRPCConnectorTransportInterface *)connector onSuccess:(nonnull void (^)(PEPRPCAcceptReject))successCallback {
    
    self.connectorTransportInterface = connector;
    [self log:@"Accepting connection."];
    successCallback(PEPRPCAcceptReject_Accept);
}

- (void)handleRPCConnectFailure:(nonnull NSError *)error {
    [self log:[NSString stringWithFormat:@"ConnectFailure called with error: %@", error]];
}

- (void)handleSend:(nonnull PEPRPCConnectorTransportInterface *)connector
           message:(nonnull PEPMessage *)message
         onSuccess:(nonnull void (^)(void))successCallback
           onError:(nonnull void (^)(NSError * _Nonnull))errorCallback {
    successCallback();
    [self log:@"Received message in `handleSend`. Now pinging back to `connectorTransportInterface:receive`."];
    
    [self.connectorTransportInterface receive:message onSuccess:^{
        [self log:@"Receive succeeded."];
    } onError:^(NSError *error) {
        [self log:[NSString stringWithFormat:@"Receive failed with error: %@", error]];
    }];
}

@end
