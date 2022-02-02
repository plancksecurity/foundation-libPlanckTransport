//
//  TransportMock.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import "TransportMock.h"
#import "TransportMock+Error.h"

const PEPTransportID g_transportID = PEPTransportIDTransportAuto;

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
    if (self.directStartupStatusCode) {
        // Fail immediately, don't invoke the delegate for a status change.
        *transportStatusCode = self.directStartupStatusCode.integerValue;
        if (error) {
            *error = [self errorWithTransportStatusCode:self.directStartupStatusCode.integerValue];
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
    
    dispatch_async(self.queue, ^{
        [self.signalStatusChangeDelegate
         signalStatusChangeWithTransportID:g_transportID
         statusCode:PEPTransportStatusCodeConnectionDown];
    });

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

- (BOOL)sendMessage:(nonnull PEPMessage *)message
         pEpSession:(PEPSession * _Nullable)pEpSession
transportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
              error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self.directMessageSendStatusCode) {
        *transportStatusCode = self.directMessageSendStatusCode.integerValue;

        if (error) {
            *error = [self errorWithTransportStatusCode:self.directStartupStatusCode.integerValue];
        }

        return NO;
    } else if (self.delayedMessageSendStatusCode) {
        *transportStatusCode = PEPTransportStatusCodeReady;

        // For tests, for now we assume that all messages have an existing TO defined
        PEPIdentity * _Nonnull destination = [message.to firstObject];

        dispatch_async(self.queue, ^{
            [self.signalSendToResultDelegate
             signalSendToResultWithTransportID:g_transportID
             messageID:message.messageID
             address:destination.address
             pEpRating:PEPRatingUndefined
             statusCode:self.delayedMessageSendStatusCode.integerValue];
        });

        return YES;
    } else {
        if (error) {
            *error = [self errorWithTransportStatusCode:PEPTransportStatusCodeConfigIncompleteOrWrong];
        }
        return NO;
    }
}

@end
