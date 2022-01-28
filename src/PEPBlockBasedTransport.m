//
//  PEPBlockBasedTransport.m
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import "PEPBlockBasedTransport.h"

#import "PEPBlockBasedTransport+PEPTransportStatusChangeDelegate.h"
#import "PEPTransportStatusCallbacks.h"

@interface PEPBlockBasedTransport ()

@property (nonatomic, nonnull) id<PEPTransportProtocol> transport;
@property (nonatomic, weak) id<PEPBlockBasedTransportDelegate> transportDelegate;

// TODO: Use on ordered mutable set? We sometimes have to remove a callback just added,
// and can't rely on it being the last (async modifications by other threads etc.)
@property (nonatomic, nonnull) NSMutableArray<PEPTransportStatusCallbacks *> *startupCallbacks;

@end

@implementation PEPBlockBasedTransport

/// @note The delegate is stored as `weak`.
- (instancetype _Nullable)initWithTransport:(nonnull id<PEPTransportProtocol>)transport
                          transportDelegate:(nonnull id<PEPBlockBasedTransportDelegate>)transportDelegate {
    self = [super init];
    if (self) {
        _startupCallbacks = [NSMutableArray new];

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
    // This is slightly awkward:
    // We have to add our callbacks before invoking the transport,
    // just in case its async implementation
    // is so fast that it "overtakes" us and wants to report something before
    // we even left this method.
    PEPTransportStatusCallbacks *callback = [PEPTransportStatusCallbacks
                                             callbacksWithSuccessCallback:successCallback
                                             errorCallback:errorCallback];
    @synchronized (self.startupCallbacks) {
        [self.startupCallbacks addObject:callback];
    }

    PEPTransportStatusCode statusCode;
    NSError *error = nil;
    BOOL success = [self.transport startupWithTransportStatusCode:&statusCode error:&error];

    if (!success) {
        // We have to remove our, and only our, callbacks, that we just installed.
        // Awkward, because it's an array.
        @synchronized (self.startupCallbacks) {
            [self.startupCallbacks removeObject:callback];
        }
    }
}

- (void)shutdownOnSuccess:(nonnull void (^)(PEPTransportStatusCode))successCallback
                  onError:(nonnull void (^)(PEPTransportStatusCode,
                                            NSError * _Nonnull))errorCallback {
}

- (void)sendMessage:(nonnull PEPMessage *)msg
     withPEPSession:(PEPSession * _Nullable)pEpSession
          onSuccess:(nonnull void (^)(PEPTransportStatusCode))successCallback
            onError:(nonnull void (^)(PEPTransportStatusCode, NSError * _Nonnull))errorCallback {
}

@end
