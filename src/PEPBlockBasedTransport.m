//
//  PEPBlockBasedTransport.m
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import "PEPBlockBasedTransport.h"

#import "PEPBlockBasedTransport+PEPTransportStatusChangeDelegate.h"
#import "PEPBlockBasedTransport+PEPTransportSendToResultDelegate.h"
#import "PEPBlockBasedTransport+ForDelegates.h"
#import "PEPTransportStatusCallbacks.h"
#import "PEPTransportStatusCodeUtil.h"
#import "PEPBlockBasedTransport+Error.h"

@interface PEPBlockBasedTransport ()

@property (nonatomic, nonnull) id<PEPTransportProtocol> transport;
@property (nonatomic, weak) id<PEPBlockBasedTransportDelegate> transportDelegate;
@property (nonatomic, nullable) PEPTransportStatusCallbacks *startupCallback;
@property (nonatomic, nullable) PEPTransportStatusCallbacks *shutdownCallback;

/// Callbacks for message send calls.
@property (nonatomic, nonnull) NSMutableDictionary<NSString *, PEPTransportStatusCallbacks *> *messageCallbacks;

@end

@implementation PEPBlockBasedTransport

#pragma mark - PEPBlockBasedTransportProtocol

/// @note The delegate is stored as `weak`.
- (instancetype _Nullable)initWithTransport:(nonnull id<PEPTransportProtocol>)transport
                          transportDelegate:(nonnull id<PEPBlockBasedTransportDelegate>)transportDelegate {
    self = [super init];
    if (self) {
        _transport = transport;
        _transport.signalStatusChangeDelegate = self;
        _transport.signalSendToResultDelegate = self;

        _messageCallbacks = [NSMutableDictionary dictionary];

        _transportDelegate = transportDelegate;
    }
    return self;
}

- (BOOL)configureWithConfig:(PEPTransportConfig * _Nullable)config
        transportStatusCode:(out nonnull PEPTransportStatusCode *)transportStatusCode
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self.transport configureWithConfig:config
                           transportStatusCode:transportStatusCode
                                         error:error];
}

- (void)startupWithOnSuccess:(nonnull void (^)(PEPTransportStatusCode))successCallback
                     onError:(nonnull void (^)(PEPTransportStatusCode,
                                               NSError * _Nonnull))errorCallback {
    // Treat concurrent startups from different threads as a developer error,
    // and also report it in production.
    NSAssert(self.startupCallback == nil, @"startup invoked with callback already set");
    if (self.startupCallback != nil) {
        // TODO: Find a better status code
        PEPTransportStatusCode invalidStateStatusCode = PEPTransportStatusCodeConfigIncompleteOrWrong;
        NSError *error = [self errorWithTransportStatusCode:invalidStateStatusCode];
        errorCallback(invalidStateStatusCode, error);

        return;
    }

    PEPTransportStatusCallbacks *callbacks = [PEPTransportStatusCallbacks
                                              callbacksWithSuccessCallback:successCallback
                                              errorCallback:errorCallback];
    self.startupCallback = callbacks;

    PEPTransportStatusCode statusCode;
    NSError *error = nil;
    BOOL success = [self.transport startupWithTransportStatusCode:&statusCode error:&error];

    if (success) {
        if (statusCode == PEPTransportStatusCodeConnectionUp) {
            // This is already up, so assume there's no need to wait for more.
            // Remove our callback, and inform the caller.
            self.startupCallback = nil;
            successCallback(statusCode);
        } else {
            // Note the assumptions here:
            //   * No error has occurred, but the transport is not yet up.
            //   * We don't report that, since we consider it an intermediate step.
            //   * Instead, we wait for further delegate notifications.
        }
    } else {
        // Immediate error. Remove our callback, and inform the caller.
        self.startupCallback = nil;
        errorCallback(statusCode, error);
    }
}

- (void)shutdownOnSuccess:(nonnull void (^)(PEPTransportStatusCode))successCallback
                  onError:(nonnull void (^)(PEPTransportStatusCode,
                                            NSError * _Nonnull))errorCallback {
    // Treat concurrent shutdowns from different threads as a developer error,
    // and also report it in production.
    NSAssert(self.shutdownCallback == nil, @"shutdown invoked with callback already set");
    if (self.startupCallback != nil) {
        // TODO: Find a better status code
        PEPTransportStatusCode invalidStateStatusCode = PEPTransportStatusCodeConfigIncompleteOrWrong;
        NSError *error = [self errorWithTransportStatusCode:invalidStateStatusCode];
        errorCallback(invalidStateStatusCode, error);

        return;
    }

    PEPTransportStatusCallbacks *callbacks = [PEPTransportStatusCallbacks
                                              callbacksWithSuccessCallback:successCallback
                                              errorCallback:errorCallback];
    self.shutdownCallback = callbacks;

    PEPTransportStatusCode statusCode;
    NSError *error = nil;
    BOOL success = [self.transport shutdownWithTransportStatusCode:&statusCode
                                                             error:&error];

    if (success) {
        if (statusCode == PEPTransportStatusCodeConnectionDown) {
            self.shutdownCallback = nil;
            successCallback(statusCode);
        } else {
            // The connection is not yet shut down, so wait for it, and handle it in the delegate.
            // Nothing to be done here.
        }
    } else {
        // We have to remove our, and only our, callbacks, that we just installed.
        self.shutdownCallback = nil;
        errorCallback(statusCode, error);
    }
}

- (void)sendMessage:(nonnull PEPMessage *)message
     withPEPSession:(PEPSession * _Nullable)pEpSession
          onSuccess:(nonnull void (^)(PEPTransportStatusCode))successCallback
            onError:(nonnull void (^)(PEPTransportStatusCode, NSError * _Nonnull))errorCallback {
    NSString *messageID = message.messageID;

    // Messages without a message ID cannot be correctly sent by this transport
    NSAssert(messageID != nil, @"A message to send must have an ID");
    if (messageID == nil) {
        // TODO: Find a better status code
        PEPTransportStatusCode invalidStateStatusCode = PEPTransportStatusCodeConfigIncompleteOrWrong;
        NSError *error = [self errorWithTransportStatusCode:invalidStateStatusCode];
        errorCallback(invalidStateStatusCode, error);

        return;
    }

    // Message IDs must be unique, or we'll have problems. Let's find out rather sooner,
    // during development, than later.
    PEPTransportStatusCallbacks *existingCallbacks = [self.messageCallbacks objectForKey:messageID];
    NSAssert(existingCallbacks == nil,
             @"Sending a message with a message ID that is currently in the process of sending is not supported");
    if (existingCallbacks != nil) {
        // TODO: Find a better status code
        PEPTransportStatusCode invalidStateStatusCode = PEPTransportStatusCodeConfigIncompleteOrWrong;
        NSError *error = [self errorWithTransportStatusCode:invalidStateStatusCode];
        errorCallback(invalidStateStatusCode, error);

        return;
    }

    PEPTransportStatusCallbacks *callbacks = [PEPTransportStatusCallbacks
                                              callbacksWithSuccessCallback:successCallback
                                              errorCallback:errorCallback];
    [self.messageCallbacks setObject:callbacks forKey:messageID];

    NSError *error = nil;
    PEPTransportStatusCode statusCode;
    BOOL success = [self.transport sendMessage:message
                                    pEpSession:pEpSession
                           transportStatusCode:&statusCode
                                         error:&error];
    if (!success) {
        [self.messageCallbacks removeObjectForKey:messageID];
        errorCallback(statusCode, error);
        return;
    }
}

@end

#pragma mark - Internal helper methods for _supporting_ the delegate callbacks

@implementation PEPBlockBasedTransport (HelpersForDelegates)

- (BOOL)invokePendingCallbacks:(NSMutableArray *)callbacks
                    statusCode:(PEPTransportStatusCode)statusCode {
    NSArray *tmpCallbacks = nil;
    @synchronized (callbacks) {
        tmpCallbacks = [NSArray arrayWithArray:callbacks];
    }

    BOOL callbackInvoked = NO;
    for (PEPTransportStatusCallbacks *theCallbacks in callbacks) {
        if ([PEPTransportStatusCodeUtil isErrorStatusCode:statusCode]) {
            theCallbacks.successCallback(statusCode);
        } else {
            NSError *error = [self errorWithTransportStatusCode:statusCode];
            theCallbacks.errorCallback(statusCode, error);
        }
        callbackInvoked = YES;
    }

    @synchronized (callbacks) {
        [callbacks removeObjectsInArray:tmpCallbacks];
    }

    return callbackInvoked;
}

@end

#pragma mark - Internal methods, called by delegate implementations from class extensions

@implementation PEPBlockBasedTransport (ForDelegates)

- (BOOL)invokePendingStartCallbackWithStatusCode:(PEPTransportStatusCode)statusCode {
    if (self.startupCallback) {
        if (![PEPTransportStatusCodeUtil isStartupErrorStatusCode:statusCode]) {
            self.startupCallback.successCallback(statusCode);
        } else {
            NSError *error = [self errorWithTransportStatusCode:statusCode];
            self.startupCallback.errorCallback(statusCode, error);
        }
        self.startupCallback = nil;
        return YES;
    }

    return NO;
}

- (BOOL)invokePendingShutdownCallbackWithStatusCode:(PEPTransportStatusCode)statusCode {
    if (self.shutdownCallback) {
        if (![PEPTransportStatusCodeUtil isShutdownErrorStatusCode:statusCode]) {
            self.shutdownCallback.successCallback(statusCode);
        } else {
            NSError *error = [self errorWithTransportStatusCode:statusCode];
            self.shutdownCallback.errorCallback(statusCode, error);
        }
        self.shutdownCallback = nil;
        return YES;
    }

    return NO;
}

- (PEPTransportStatusCallbacks * _Nullable)findAndRemoveCallbacksForMessageID:(NSString *)messageID {
    PEPTransportStatusCallbacks *callbacks = nil;

    @synchronized (self.messageCallbacks) {
        callbacks = [self.messageCallbacks objectForKey:messageID];
        [self.messageCallbacks removeObjectForKey:messageID];
    }

    return callbacks;
}

@end
