//
//  PEPBlockBasedTransportProtocol.h
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import <Foundation/Foundation.h>

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

@protocol PEPBlockBasedTransportProtocol <NSObject>

/// Nullable only for OUT_OF_MEMORY
/// Since there are no delegates anymore, this is the one and only
/// initializer.
/// A PEPBlockBasedTransport wrapper would have in initializer that
/// receives an underlying PEPTransportProtocol in order to wrap it
- (instancetype _Nullable)init;

// NOTE: Not quite true: I think we still need something like the
// existing PEPTransportIncomingMessageDelegate.
// But we could make it receive the message right away in the delegate,
// instead of the quasi-polling nextMessage: (see last spot).
// What do you think? So still one delegate, or can this be avoided?

/// I don't see changes here from PEPTransportProtocol.
/// I assume this is always a sync call, and will therefore not change.
/// Please let me know if you see that differently.
- (BOOL)configureWithConfig:(PEPTransportConfig * _Nullable)config
        transportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
                      error:(NSError * _Nullable * _Nullable)error;

/// Async startup with error and success callback,
/// _both_ also conveying a status code in order to not lose anything
/// from the PEPTransportProtocol, which has similar semantics.
/// Maybe put the success callback in the last spot, so code
/// with supporting languages (like swift) looks a little bit nicer?
/// (IIRC in swift, if you have a block as last parameter, you
/// can put put it into a block outside of the parameter list.)
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
