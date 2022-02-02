//
//  PEPBlockBasedTransport.m
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import "PEPBlockBasedTransport.h"

#import "PEPBlockBasedTransport+PEPTransportStatusChangeDelegate.h"
#import "PEPBlockBasedTransport+Callbacks.h"
#import "PEPTransportStatusCallbacks.h"
#import "PEPTransportStatusCodeUtil.h"
#import "PEPBlockBasedTransport+Error.h"

@interface PEPBlockBasedTransport ()

@property (nonatomic, nonnull) id<PEPTransportProtocol> transport;
@property (nonatomic, weak) id<PEPBlockBasedTransportDelegate> transportDelegate;

@property (nonatomic, nullable) PEPTransportStatusCallbacks *startupCallback;

@property (nonatomic, nullable) PEPTransportStatusCallbacks *shutdownCallback;

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

    PEPTransportStatusCallbacks *callback = [PEPTransportStatusCallbacks
                                             callbacksWithSuccessCallback:successCallback
                                             errorCallback:errorCallback];
    self.startupCallback = callback;

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
            // The connection is not yet up, so wait for it, and handle it in the delegate.
            // Nothing to be done here.
        }
    } else {
        // Remove our callback, and inform the caller.
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

    PEPTransportStatusCallbacks *callback = [PEPTransportStatusCallbacks
                                             callbacksWithSuccessCallback:successCallback
                                             errorCallback:errorCallback];
    self.shutdownCallback = callback;

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

- (void)sendMessage:(nonnull PEPMessage *)msg
     withPEPSession:(PEPSession * _Nullable)pEpSession
          onSuccess:(nonnull void (^)(PEPTransportStatusCode))successCallback
            onError:(nonnull void (^)(PEPTransportStatusCode, NSError * _Nonnull))errorCallback {
}

@end

#pragma mark - Internal methods for supporting the delegate callbacks

@implementation PEPBlockBasedTransport (CallbacksInternals)

- (BOOL)invokePendingCallbacks:(NSMutableArray *)callbacks
                    statusCode:(PEPTransportStatusCode)statusCode {
    NSArray *tmpCallbacks = nil;
    @synchronized (callbacks) {
        tmpCallbacks = [NSArray arrayWithArray:callbacks];
    }

    BOOL callbackInvoked = NO;
    for (PEPTransportStatusCallbacks *callback in callbacks) {
        if ([PEPTransportStatusCodeUtil isErrorStatusCode:statusCode]) {
            callback.successCallback(statusCode);
        } else {
            NSError *error = [self errorWithTransportStatusCode:statusCode];
            callback.errorCallback(statusCode, error);
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

@implementation PEPBlockBasedTransport (Callbacks)

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

@end
