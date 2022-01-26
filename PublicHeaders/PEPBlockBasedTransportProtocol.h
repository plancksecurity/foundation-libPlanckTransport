//
//  PEPBlockBasedTransportProtocol.h
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import <Foundation/Foundation.h>

#import "PEPTransportProtocol.h"
#import "PEPTransportStatusCode.h"
#import "PEPObjCTypes.h"

@class PEPTransportConfig;
@class PEPSession;

NS_ASSUME_NONNULL_BEGIN

@protocol PEPBlockBasedTransportIncomingMessageDelegate <NSObject>

- (void)signalIncomingMessage:(PEPMessage *)message
                  transportID:(PEPTransportID)transportID
                   statusCode:(PEPTransportStatusCode)statusCode;
@end

/// Wraps any `id<PEPTransportProtocol>` into a version with callbacks instead of delegates,
/// wherever possible.
@protocol PEPBlockBasedTransportProtocol <NSObject>

/// Initializes the block based wrapper for the given `PEPTransportProtocol` and with a
/// `PEPBlockBasedTransportIncomingMessageDelegate` delegate.
/// @note Nullable only for OUT_OF_MEMORY
- (instancetype _Nullable)initWithTransport:(id<PEPTransportProtocol>)transport
                    incomingMessageDelegate:(id<PEPBlockBasedTransportIncomingMessageDelegate>)incomingMessageDelegate;

/// Exact behavior as with `PEPTransportProtocol`, please see documentation there.
- (BOOL)configureWithConfig:(PEPTransportConfig * _Nullable)config
        transportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
                      error:(NSError * _Nullable * _Nullable)error;

/// Async startup with error and success callback, _both_ also conveying a status code in order to not lose anything
/// from `PEPTransportProtocol`, which has similar semantics.
- (BOOL)startupWithOnSuccess:(nonnull void (^)(PEPTransportStatusCode statusCode))successCallback
                     onError:(nonnull void (^)(PEPTransportStatusCode statusCode,
                                               NSError * _Nonnull))errorCallback;

/// Like the startup method before, only for shut down.
/// Same comments apply.
- (void)shutdownOnSuccess:(void (^)(PEPTransportStatusCode))successCallback
                  onError:(void (^)(PEPTransportStatusCode, NSError *))errorCallback;

/// The good old send message, only with direct error and
/// success callbacks.
- (BOOL)sendMessage:(PEPMessage *)msg
     withPEPSession:(PEPSession * _Nullable)pEpSession
          onSuccess:(void (^)(PEPTransportStatusCode))successCallback
            onError:(void (^)(PEPTransportStatusCode, NSError *))errorCallback;

@end

NS_ASSUME_NONNULL_END
