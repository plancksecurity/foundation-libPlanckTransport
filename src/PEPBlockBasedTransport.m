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
    PEPTransportStatusCallbacks *callback = [[PEPTransportStatusCallbacks alloc]
                                             initWithSuccessCallback:successCallback
                                             errorCallback:errorCallback];
    @synchronized (self.startupCallbacks) {
        [self.startupCallbacks addObject:callback];
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
