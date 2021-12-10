//
//  PEPRPCTransportTestConnector.m
//  TestRPCClient_macOS
//
//  Created by Andreas Buff on 06.12.21.
//

#import "PEPRPCTransportTestConnector.h"

#import <pEpIPsecRPCObjCAdapter.h>
#import <PEPObjCTypes.h>

@interface PEPRPCTransportTestConnector()<PEPRPCConnectorIPsecDelegate, PEPRPCConnectorTransportDelegate>
@property PEPRPCConnector *connector;
@property PEPRPCSupervisorTransportInterface *supervisorTransportInterface;
@property NSTimer *sendTimer;
@end

@implementation PEPRPCTransportTestConnector

- (instancetype)init {
    if (self = [super init]) {
        _connector = [PEPRPCConnector new];
        _sendTimer = [self newSendMessageTimer];
    }
    return self;
}

- (void)start {
    [self.connector connectToTransportSupervisor:[[PEPRPCConnectorConfig alloc] initWithPort:5923] delegate:self];
}

// MARK: - PRIVATE

- (void)log:(NSString*)msg {
    NSLog(@"PEPRPCTransportTestConnector: %@", msg);
}

- (NSTimer *)newSendMessageTimer {
    NSTimer *createe = [NSTimer timerWithTimeInterval:1.0 repeats:YES
                                                block:^(NSTimer * _Nonnull timer) {
        [self log:@"In Timer"];
        if (self.supervisorTransportInterface) {
            [self log:@"Sending message."];
            [self.supervisorTransportInterface send:[self newPepMessage] onSuccess:^{
                [self log:@"Success: Message successfully sent."];
            } onError:^(NSError * error) {
                [self log:[NSString stringWithFormat:@"Error sending message: %@", error]];
            }];
        } else {
            [self log:@"Not connected yet."];
        }
    }];
    [NSRunLoop.currentRunLoop addTimer:createe forMode:NSRunLoopCommonModes];
    return createe;
}

- (PEPMessage *)newPepMessage {
    PEPIdentity *me = [[PEPIdentity alloc] initWithAddress:@"myAddress:myPort"
                                                    userID:@"PEP_OWN_USER_ID"
                                                  userName:@"myUserName"
                                                     isOwn:YES];
    PEPMessage *createe = [PEPMessage new];
    createe.messageID = [[NSUUID new] UUIDString];
    createe.from = me;
    createe.to = @[me];
    createe.shortMessage = @"A shortMessage";
    createe.longMessage = @"A longMessage";
    createe.longMessageFormatted = @"A longMessageFormatted";
    createe.direction = PEPMsgDirectionOutgoing;

    return  createe;
}

// MARK: - PEPRPCConnectorIPsecDelegate

- (void)handleNewConnection:(nonnull PEPConnection *)connection side:(PEPTunnelSide)side onSuccess:(nonnull void (^)(PEPRPCAcceptReject))successCallback onError:(nonnull void (^)(NSError * _Nonnull))errorCallback {
    NSAssert(false, @"PEPRPCConnectorIPsecDelegate handleInstallTunnel called. Unexpected. Only Trasnport related stuff should be called here.");
}

// MARK: - PEPRPCConnectorTransportDelegate

- (void)handleRPCConnectSuccess:(nonnull PEPRPCSupervisorTransportInterface *)supervisor {
    [self log:[NSString stringWithFormat:@"Got handleRPCConnectSuccess with PEPRPCSupervisorTransportInterface: %@",
               supervisor]];
    self.supervisorTransportInterface = supervisor;
}

- (void)handleRPCConnectFailure:(nonnull NSError *)error {
    [self log:[NSString stringWithFormat:@"ConnectFailure called with error: %@", error]];
}


- (void)handleReceive:(nonnull PEPMessage *)message
            onSuccess:(nonnull void (^)(void))successCallback
              onError:(nonnull void (^)(NSError * _Nonnull))errorCallback {
    [self log:[NSString stringWithFormat:@"Got new message ins `handleReceive` from Supervisor: %@", message]];
    successCallback();
}

@end
