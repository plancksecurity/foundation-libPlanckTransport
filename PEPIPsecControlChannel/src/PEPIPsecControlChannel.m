//
//  PEPCC.m
//  pEpCC_macOS
//
//  Created by Andreas Buff on 16.08.21.
//

#import "PEPIPsecControlChannel.h"

#import <pEpIPsecRPCObjCAdapter.h>
#import <PEPObjCTypes.h>
#import "NSError+PEPCCTransport+internal.h"

@interface PEPIPsecControlChannel () <PEPRPCConnectorTransportDelegate>
@property (atomic, nonnull) PEPRPCConnector *connector;
@property (atomic, nonnull) PEPRPCConnectorConfig *connectorConfig;
@property (atomic, nullable) PEPRPCSupervisorTransportInterface *supervisorTransportInterface;
@property (atomic, nonnull) NSMutableArray<PEPMessage*> *receivedMessages;
@property (atomic) PEPTransportStatusCode state;
@end

@implementation PEPIPsecControlChannel

// synthesize required when properties are declared in protocol.
@synthesize signalIncomingMessageDelegate = _signalIncomingMessageDelegate;
@synthesize signalSendToResultDelegate = _signalSendToResultDelegate;
@synthesize signalStatusChangeDelegate = _signalStatusChangeDelegate;

- (instancetype _Nullable)init {
    if (self = [super init]) {
        _receivedMessages = [NSMutableArray<PEPMessage*> new];
        _connector = [PEPRPCConnector new];
        self.state = PEPTransportStatusCodeReady;
    }
    return self;
}

- (instancetype _Nullable)initWithSignalStatusChangeDelegate:(id<PEPTransportStatusChangeDelegate> _Nullable)signalStatusChangeDelegate
                                  signalSendToResultDelegate:(id<PEPTransportSendToResultDelegate> _Nullable)signalSendToResultDelegate
                               signalIncomingMessageDelegate:(id<PEPTransportIncomingMessageDelegate> _Nullable)signalIncomingMessageDelegate
                                                       error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self = [self init]) {
        _signalStatusChangeDelegate = signalStatusChangeDelegate;
        _signalSendToResultDelegate = signalSendToResultDelegate;
        _signalIncomingMessageDelegate = signalIncomingMessageDelegate;

        _connector = [PEPRPCConnector new];
    }
    return self;
}

- (BOOL)configureWithConfig:(nonnull PEPTransportConfig *)config
        transportStatusCode:(out PEPTransportStatusCode *)transportStatusCode
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error {

    //BUFF: HEEEEEEEERRRRRRRRRRRRRWEEEEEEEEEEEEE
//    if (!config.port) {
//        *transportStatusCode = PEPTransportStatusCodeConfigIncompleteOrWrong;
//      return NO;
//    }
    self.connectorConfig = [[PEPRPCConnectorConfig alloc] initWithPort:config.port];
    return YES;
}

- (PEPMessage * _Nullable)nextMessageWithPEPSession:(PEPSession * _Nullable)pEpsession
                                transportStatusCode:(out PEPTransportStatusCode *)transportStatusCode
                                              error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self.receivedMessages.count == 0) {
        *transportStatusCode = PEPTransportStatusCodeRxQueueUnderrun;
        *error = [NSError errorWithPEPCCTransportStatusCode:PEPTransportStatusCodeRxQueueUnderrun];
        return nil;
    }
    *transportStatusCode = PEPTransportStatusCodeReady;
    PEPMessage *nextMessage = [self.receivedMessages firstObject];
    [self.receivedMessages removeObjectAtIndex:0];
    return nextMessage;
}

- (BOOL)sendMessage:(nonnull PEPMessage *)msg
         pEpSession:(PEPSession * _Nullable)pEpSession
transportStatusCode:(out PEPTransportStatusCode *)transportStatusCode
              error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    __weak typeof(self) weakSelf = self;
    [self.supervisorTransportInterface send:msg onSuccess:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.signalStatusChangeDelegate signalStatusChangeWithTransportID:PEPTransportIDTransportCC
                                                                      statusCode:PEPTransportStatusCodeMessageDelivered];
    } onError:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.signalStatusChangeDelegate signalStatusChangeWithTransportID:PEPTransportIDTransportCC
                                                                      statusCode:PEPTransportStatusCodeCouldNotDeliverResending];
    }];
    *transportStatusCode = PEPTransportStatusCodeMessageOnTheWay;
    return YES;
}

- (BOOL)shutdownWithTransportStatusCode:(out PEPTransportStatusCode *)transportStatusCode
                                  error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    self.supervisorTransportInterface = nil;
    *transportStatusCode = PEPTransportStatusCodeReady;

    return YES;
}

- (BOOL)startupWithTransportStatusCode:(out nonnull PEPTransportStatusCode *)transportStatusCode
                                 error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    [self.connector connectToTransportSupervisor:self.connectorConfig delegate:self];
    self.state = PEPTransportStatusCodeReady; // should be connecting but does not exist
    *transportStatusCode = self.state;
    return YES;
}

// MARK: - PEPRPCConnectorTransportDelegate

- (void)handleRPCConnectFailure:(nonnull NSError *)error {
    self.state = PEPTransportStatusCodeConnectionDown;
    [self.signalStatusChangeDelegate signalStatusChangeWithTransportID:PEPTransportIDTransportCC
                                                            statusCode:self.state];
}

- (void)handleRPCConnectSuccess:(nonnull PEPRPCSupervisorTransportInterface *)supervisor {
    self.supervisorTransportInterface = supervisor;
    self.state = PEPTransportStatusCodeReady;
    [self.signalStatusChangeDelegate signalStatusChangeWithTransportID:PEPTransportIDTransportCC
                                                            statusCode:self.state];
}

- (void)handleReceive:(nonnull PEPMessage *)message
            onSuccess:(nonnull void (^)(void))successCallback
              onError:(nonnull void (^)(NSError * _Nonnull))errorCallback {
    [self.receivedMessages addObject:message];
    self.state = PEPTransportStatusCodeReady;
    [self.signalIncomingMessageDelegate signalIncomingMessageWithTransportID:PEPTransportIDTransportCC
                                                                  statusCode:self.state];
    successCallback();
}

@end
