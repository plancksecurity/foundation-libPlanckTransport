//
//  PEPTestControlChannel.m
//  PEPIPsecControlChannel_macOS
//
//  Created by Andreas Buff on 10.12.21.
//

#import "PEPTestControlChannel.h"

#import "PEPIPsecControlChannel.h"
#import <PEPObjCTypes.h>


@interface PEPTestControlChannel()<PEPTransportStatusChangeDelegate, PEPTransportSendToResultDelegate, PEPTransportIncomingMessageDelegate>
@property PEPIPsecControlChannel *cc;
@property NSTimer *sendTimer;
@property BOOL isConnected;
@end

@implementation PEPTestControlChannel

-(instancetype)init {
    if (self = [super init]) {
        _cc = [[PEPIPsecControlChannel alloc] initWithSignalStatusChangeDelegate:self
                                                      signalSendToResultDelegate:self
                                                   signalIncomingMessageDelegate:self
                                                                           error:nil];
        _sendTimer = [self newSendMessageTimer];
        _isConnected = NO;
    }
    return self;
}

- (void)start {
    PEPTransportStatusCode status = 0;
    NSError *error = nil;
    BOOL success = [self.cc startupWithTransportStatusCode:&status error:&error];
    NSAssert(success, error.localizedDescription);
}

// MARK: - PEPTransportStatusChangeDelegate

- (void)signalStatusChangeWithTransportID:(PEPTransportID)transportID
                               statusCode:(PEPTransportStatusCode)statusCode {
    [self log:
         [NSString stringWithFormat:@"signalStatusChange called with PEPTransportID: %lu PEPTransportStatusCode: %lu",
          (unsigned long)transportID, (unsigned long)statusCode]
    ];
    if (statusCode == PEPTransportStatusCodeConnectionUp) {
        self.isConnected = YES;
    } else if (statusCode == PEPTransportStatusCodeShutDown) {
        self.isConnected = NO;
    }
}

// MARK: - PEPTransportSendToResultDelegate

- (void)signalSendToResultWithTransportID:(PEPTransportID)transportID
                                messageID:(nonnull NSString *)messageID
                                  address:(nonnull NSString *)address
                               statusCode:(PEPTransportStatusCode)statusCode {
    [self log:
         [NSString stringWithFormat:@"signalSendToResult called with PEPTransportID: %lu messageID: %@ address: %@",
          (unsigned long)transportID, messageID, address]
    ];
}

// MARK: - PEPTransportIncomingMessageDelegate

- (void)signalIncomingMessageWithTransportID:(PEPTransportID)transportID
                                  statusCode:(PEPTransportStatusCode)statusCode {
    [self log:
         [NSString stringWithFormat:@"signalIncomingMessage called with PEPTransportID: %lu PEPTransportStatusCode: %lu",
          (unsigned long)transportID, (unsigned long)statusCode]
    ];
    statusCode = 0;
    NSError *error = nil;
    // Get it
    PEPMessage *msg = [self.cc nextMessageWithPEPSession:nil transportStatusCode:&statusCode error:&error];
    [self log:
         [NSString stringWithFormat:@"nextMessageWithPEPSession gave me PEPMEssage: %@ error: %@", msg, error.localizedDescription]
    ];
}

// MARK: - PRIVATE

- (void)log:(NSString*)msg {
    NSLog(@"PEPTestControlChannel: %@", msg);
}

- (NSTimer *)newSendMessageTimer {
    __weak typeof(self) weakSelf = self;
    NSTimer *createe = [NSTimer timerWithTimeInterval:1.0 repeats:YES
                                                block:^(NSTimer * _Nonnull timer) {
        if (self.isConnected) {
            __strong typeof(self) strongSelf = weakSelf;
            PEPTransportStatusCode status = 0;
            NSError *error = nil;
            [self log:@"In Timer"];
            PEPMessage *msg = [self newPepMessage];
            BOOL success = [strongSelf.cc sendMessage:msg
                                           pEpSession:nil
                                  transportStatusCode:&status
                                                error:&error];
            [strongSelf log:
                 [NSString stringWithFormat:@"newSendMessageTimer sent message: %@ with success: %hhd PEPTransportStatusCode: %lu error: %@",
                  msg, success, (unsigned long)status, error.localizedDescription]
            ];
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

@end
