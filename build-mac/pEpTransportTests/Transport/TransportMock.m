//
//  TransportMock.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import "TransportMock.h"

const PEPTransportID g_transportID = PEPTransportIDTransportAuto;
NSString *g_ErrorDomain = @"TransportMockErrorDomain";

@interface TransportMock ()

/// The queue used to simulate async behavior (like async calls to the delegates).
@property (nonatomic) dispatch_queue_t queue;

/// The message to be used in order to simulate receiving messages
@property (nonatomic) PEPMessage *receivedMessage;

@end

@implementation TransportMock

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("TransportMockQueue", NULL);
    }
    return self;
}

#pragma mark - Own API

- (void)pushReceivedMessage:(PEPMessage *)message {
    @synchronized (self) {
        self.receivedMessage = message;
    }

    [self.signalIncomingMessageDelegate
     signalIncomingMessageWithTransportID:g_transportID
     statusCode:PEPTransportStatusCodeMessageDelivered];
}

#pragma mark - PEPTransportProtocol

@synthesize signalIncomingMessageDelegate = _signalIncomingMessageDelegate;

@synthesize signalSendToResultDelegate = _signalSendToResultDelegate;

@synthesize signalStatusChangeDelegate = _signalStatusChangeDelegate;

- (instancetype _Nullable)initWithSignalStatusChangeDelegate:(id<PEPTransportStatusChangeDelegate> _Nullable)signalStatusChangeDelegate
                                  signalSendToResultDelegate:(id<PEPTransportSendToResultDelegate> _Nullable)signalSendToResultDelegate
                               signalIncomingMessageDelegate:(id<PEPTransportIncomingMessageDelegate> _Nullable)signalIncomingMessageDelegate
                                                       error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    self = [self init];
    if (self) {
        _signalStatusChangeDelegate = signalStatusChangeDelegate;
        _signalSendToResultDelegate = signalSendToResultDelegate;
        _signalIncomingMessageDelegate = signalIncomingMessageDelegate;
    }
    return self;
}

- (BOOL)configureWithConfig:(PEPTransportConfig * _Nullable)config
        transportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    *transportStatusCode = PEPTransportStatusCodeReady;
    return YES;
}

- (BOOL)startupWithTransportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
                                 error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self.directStartupErrorCode) {
        // Fail immediately, don't invoke the delegate for a status change.
        *transportStatusCode = self.directStartupErrorCode.integerValue;
        if (error) {
            *error = [NSError errorWithDomain:g_ErrorDomain
                                         code:self.directStartupErrorCode.integerValue
                                     userInfo:nil];
        }
        return NO;
    } else if (self.delayedStartupStatusCode) {
        // Generic status code, we don't know yet if there will be an error or not,
        // the user of this mock decided that with the status code.
        *transportStatusCode = PEPTransportStatusCodeReady;

        dispatch_async(self.queue, ^{
            [self.signalStatusChangeDelegate
             signalStatusChangeWithTransportID:g_transportID
             statusCode:self.delayedStartupStatusCode.integerValue];
        });

        return YES;
    } else {
        // We are able to start up immediately and know it's a success.
        // No message to the delegate.
        *transportStatusCode = PEPTransportStatusCodeConnectionUp;
        return YES;
    }
}

- (BOOL)shutdownWithTransportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
                                  error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    *transportStatusCode = PEPTransportStatusCodeReady;
    
    [self.signalStatusChangeDelegate
     signalStatusChangeWithTransportID:g_transportID
     statusCode:PEPTransportStatusCodeConnectionDown];
    
    return YES;
}

- (PEPMessage * _Nullable)nextMessageWithPEPSession:(PEPSession * _Nullable)pEpsession
                                transportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
                                              error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    PEPMessage *newMessage = nil;

    @synchronized (self) {
        newMessage = self.receivedMessage;
        self.receivedMessage = nil;
    }

    *transportStatusCode = PEPTransportStatusCodeConnectionUp;

    return newMessage;
}

- (BOOL)sendMessage:(nonnull PEPMessage *)msg
         pEpSession:(PEPSession * _Nullable)pEpSession
transportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
              error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return NO;
}

@end
