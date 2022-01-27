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

/// Delegate for receiving messages.
@protocol PEPBlockBasedTransportIncomingMessageDelegate <NSObject>

/// Gets called with the latest message whenever the underlying transport has a new message available.
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
        transportStatusCode:(out PEPTransportStatusCode *)transportStatusCode
                      error:(NSError * _Nullable * _Nullable)error;

/// Async startup with error and success callback, _both_ also conveying a status code in order to not lose anything
/// from `PEPTransportProtocol`, which has similar semantics.
/// For details, please see `PEPTransportProtocol` or the transport that is wrapped.
- (void)startupWithOnSuccess:(void (^)(PEPTransportStatusCode statusCode))successCallback
                     onError:(void (^)(PEPTransportStatusCode statusCode, NSError *))errorCallback;

/// Async shut down with error and success callback, _both_ also conveying a status code in order to not lose anything
/// from `PEPTransportProtocol`, which has similar semantics.
/// For details, please see `PEPTransportProtocol` or the transport that is wrapped.
- (void)shutdownOnSuccess:(void (^)(PEPTransportStatusCode))successCallback
                  onError:(void (^)(PEPTransportStatusCode, NSError *))errorCallback;

/// Async send message with error and success callback, _both_ also conveying a status code in order to not lose anything
/// from `PEPTransportProtocol`, which has similar semantics.
/// For details, please see `PEPTransportProtocol` or the transport that is wrapped.
- (void)sendMessage:(PEPMessage *)msg
     withPEPSession:(PEPSession * _Nullable)pEpSession
          onSuccess:(void (^)(PEPTransportStatusCode))successCallback
            onError:(void (^)(PEPTransportStatusCode, NSError *))errorCallback;

@end

NS_ASSUME_NONNULL_END
