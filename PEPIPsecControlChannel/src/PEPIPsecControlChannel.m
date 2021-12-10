//
//  PEPCC.m
//  pEpCC_macOS
//
//  Created by Andreas Buff on 16.08.21.
//

#import "PEPIPsecControlChannel.h"

#import <pEpIPsecRPCObjCAdapter.h>
#import <PEPObjCTypes.h>
#import "NSError+PEPTransportStatusCode.h"

@interface PEPIPsecControlChannel () <PEPRPCConnectorTransportDelegate>
@property (atomic, nonnull) PEPRPCConnector *connector;
@property (atomic, nonnull) PEPRPCConnectorConfig *connectorConfig;
@property (atomic, nullable) PEPRPCSupervisorTransportInterface *supervisorTransportInterface;
@property (atomic, nonnull) NSMutableArray<PEPMessage*> *receivedMessages;
@property (nonatomic) UInt16 defaultPort;
@property (atomic) NSUInteger failedConnectionAttemptCounter;
@end

@implementation PEPIPsecControlChannel

static const NSUInteger maxNumRetry = 3;

// synthesize required when properties are declared in protocol.
@synthesize signalIncomingMessageDelegate = _signalIncomingMessageDelegate;
@synthesize signalSendToResultDelegate = _signalSendToResultDelegate;
@synthesize signalStatusChangeDelegate = _signalStatusChangeDelegate;

- (instancetype _Nullable)init {
    if (self = [super init]) {
        _receivedMessages = [NSMutableArray<PEPMessage*> new];
        _connector = [PEPRPCConnector new];
        _failedConnectionAttemptCounter = 0;
        [self setupDefaultConfig];
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
        transportStatusCode:(out nonnull PEPTransportStatusCode *)transportStatusCode
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if ([self weAreConnected]) {
        NSString *errorMsg = @"We do not allow to reconfigure after calling `startupWithTransportStatusCode:error:`. The connection will keep running. The config passed is ignored.";
        *transportStatusCode = PEPTransportStatusCodeConfigIncompleteOrWrong;
        *error = [NSError errorWithPEPCCTransportStatusCode:PEPTransportStatusCodeConfigIncompleteOrWrong
                                                         errorMessage:errorMsg];
        return NO;
    }
    if (config && config.port == 0) {
        // Incomplete config given
        *transportStatusCode = PEPTransportStatusCodeConfigIncompleteOrWrong;
        *error = [NSError errorWithPEPCCTransportStatusCode:PEPTransportStatusCodeConfigIncompleteOrWrong];
      return NO;
    }

    self.connectorConfig = [[PEPRPCConnectorConfig alloc] initWithPort:config.port];
    *transportStatusCode = PEPTransportStatusCodeReady;

    return YES;
}

- (PEPMessage * _Nullable)nextMessageWithPEPSession:(PEPSession * _Nullable)pEpsession
                                transportStatusCode:(out nonnull PEPTransportStatusCode *)transportStatusCode
                                              error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (![self weAreConnected]) {
        NSString *errorMsg = @"Must not be called before connection has been established (by calling `startupWithTransportStatusCode:error:`";
        *transportStatusCode = PEPTransportStatusCodeConfigIncompleteOrWrong;
        *error = [NSError errorWithPEPCCTransportStatusCode:PEPTransportStatusCodeConnectionDown
                                                         errorMessage:errorMsg];
        return nil;
    }
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

- (BOOL)    sendMessage:(nonnull PEPMessage *)msg
             pEpSession:(PEPSession * _Nullable)pEpSession
    transportStatusCode:(out nonnull PEPTransportStatusCode *)transportStatusCode
                  error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (![self weAreConnected]) {
        NSString *errorMsg = @"Must not be called before connection has been established (by calling `startupWithTransportStatusCode:error:`";
        *transportStatusCode = PEPTransportStatusCodeConfigIncompleteOrWrong;
        *error = [NSError errorWithPEPCCTransportStatusCode:PEPTransportStatusCodeConnectionDown
                                                         errorMessage:errorMsg];
        return NO;
    }
    __weak typeof(self) weakSelf = self;
    [self.supervisorTransportInterface send:msg onSuccess:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.signalStatusChangeDelegate signalStatusChangeWithTransportID:PEPTransportIDTransportCC
                                                                      statusCode:PEPTransportStatusCodeMessageDelivered];
    } onError:^(NSError *error) {
        // Resend once on error
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.signalStatusChangeDelegate signalStatusChangeWithTransportID:PEPTransportIDTransportCC
                                                                      statusCode:PEPTransportStatusCodeCouldNotDeliverResending];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            // Dispatched away as it might be problematic to call supervisorTransportInterface
            // from its own thread.
            [strongSelf.supervisorTransportInterface send:msg onSuccess:^{
                [strongSelf.signalStatusChangeDelegate signalStatusChangeWithTransportID:PEPTransportIDTransportCC
                                                                              statusCode:PEPTransportStatusCodeMessageDelivered];
            } onError:^(NSError *error) {
                [strongSelf.signalStatusChangeDelegate signalStatusChangeWithTransportID:PEPTransportIDTransportCC
                                                                              statusCode:PEPTransportStatusCodeCouldNotDeliverGivingUp];
            }];
        });
    }];
    *transportStatusCode = PEPTransportStatusCodeMessageOnTheWay;
    return YES;
}

- (BOOL)shutdownWithTransportStatusCode:(out nonnull PEPTransportStatusCode *)transportStatusCode
                                  error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (![self weAreConnected]) {
        NSString *errorMsg = @"`shutdown`called before `startup`. We ignore it";
        *transportStatusCode = PEPTransportStatusCodeConfigIncompleteOrWrong;
        *error = [NSError errorWithPEPCCTransportStatusCode:PEPTransportStatusCodeConfigIncompleteOrWrong
                                                         errorMessage:errorMsg];
        return NO;
    }
    [self shutdown];
    // Thought about resetting here, but decided to keep received messages in
    // queue before next startup.
    *transportStatusCode = PEPTransportStatusCodeConnectionDown;
    [self.signalStatusChangeDelegate signalStatusChangeWithTransportID:PEPTransportIDTransportCC
                                                            statusCode:PEPTransportStatusCodeConnectionDown];
    return YES;
}

- (BOOL)startupWithTransportStatusCode:(out nonnull PEPTransportStatusCode *)transportStatusCode
                                 error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if ([self weAreConnected]) {
        NSString *errorMsg = @"We are already started. You must not call `startupWithTransportStatusCode:error:` on a conneted transport";
        *transportStatusCode = PEPTransportStatusCodeConfigIncompleteOrWrong;
        *error = [NSError errorWithPEPCCTransportStatusCode:PEPTransportStatusCodeConfigIncompleteOrWrong
                                                         errorMessage:errorMsg];
        return NO;
    }
    [self reset];
    [self.connector connectToTransportSupervisor:self.connectorConfig delegate:self];
    *transportStatusCode = PEPTransportStatusCodeReady;  // should be connecting but does not exist
    return YES;
}

// MARK: - PRIVATE

- (void)reset {
    [self.receivedMessages removeAllObjects];
    self.failedConnectionAttemptCounter = 0;
}

- (void)setupDefaultConfig {
    self.connectorConfig = [[PEPRPCConnectorConfig alloc] initWithPort:self.defaultPort];
}

- (BOOL)weAreConnected {
    return self.supervisorTransportInterface != nil;
}

- (void)shutdown {
    self.supervisorTransportInterface = nil;
}

// MARK: - PEPRPCConnectorTransportDelegate

- (void)handleRPCConnectFailure:(nonnull NSError *)error {

    if (self.failedConnectionAttemptCounter > maxNumRetry) {
        [self reset];
        [self.signalStatusChangeDelegate signalStatusChangeWithTransportID:PEPTransportIDTransportCC
                                                                statusCode:PEPTransportStatusCodeShutDown];
    } else {
        // Retry!
        self.failedConnectionAttemptCounter++;
        [self.connector connectToTransportSupervisor:self.connectorConfig delegate:self];
        return;
    }
}

- (void)handleRPCConnectSuccess:(nonnull PEPRPCSupervisorTransportInterface *)supervisor {
    self.supervisorTransportInterface = supervisor;
    [self.signalStatusChangeDelegate signalStatusChangeWithTransportID:PEPTransportIDTransportCC
                                                            statusCode:PEPTransportStatusCodeConnectionUp];
}

- (void)handleReceive:(nonnull PEPMessage *)message
            onSuccess:(nonnull void (^)(void))successCallback
              onError:(nonnull void (^)(NSError * _Nonnull))errorCallback {
    [self.receivedMessages addObject:message];
    [self.signalIncomingMessageDelegate signalIncomingMessageWithTransportID:PEPTransportIDTransportCC
                                                                  statusCode:PEPTransportStatusCodeReady];
    successCallback();
}

@end
