#import <Foundation/Foundation.h>

@import PEPObjCTypes_macOS;

@class PEPTransportConfig;
@class PEPTransport;
@class PEPMessage;

NS_ASSUME_NONNULL_BEGIN

@protocol PEPSendResultDelegate <NSObject>

- (BOOL)signalSendMessageResultWithTransportID:(PEPTransportID)transportID
                                     messageID:(NSString *)messageID
                                       address:(NSString *)address
                                    statusCode:(PEPTransportStatusCode *)statusCode
                                         error:(NSError * _Nullable * _Nullable)error;
@end

@protocol PEPIncomingMessageDelegate <NSObject>

- (BOOL)signalNewIncomingMessageWithTransportID:(PEPTransportID)transportID
                                     statusCode:(PEPTransportStatusCode *)statusCode
                                          error:(NSError * _Nullable * _Nullable)error;
@end

@protocol PEPStatusChangeDelegate <NSObject>

- (BOOL)statusChangedWithTransportID:(PEPTransportID)transportID
                          statusCode:(PEPTransportStatusCode *)statusCode
                               error:(NSError * _Nullable * _Nullable)error;
@end

/// Idea in a nutshell:
/// - Init with callbacks and callbackExecutionType
/// - configure
/// - startup
/// - listen to status changes (e.g. connected aka "PEPTransportStatusCodeReady"
/// - use it:
///     - send message
///     - listen to- and handle sendMessageResult (e.g. done sending aka "PEPTransportStatusCodeMessageDelivered")
///     - listen to newIncommingMessage delegate
///         - call nextMessage to get it
/// shutdown
@protocol PEPTransport <NSObject>

- (instancetype)init;

/// Convenience initializer.
- (_Nullable instancetype)initWithChangeDelegate:(id<PEPStatusChangeDelegate> _Nullable)statusChangeDelegate
                        signalSendResultDelegate:(id<PEPSendResultDelegate> _Nullable)signalSendResultDelegate
                   signalIncomingMessageDelegate:(id<PEPIncomingMessageDelegate> _Nullable)signalIncomingMessageDelegate
                           callbackExecutionType:(PEPCallbackExcecutionType)callbackExecutionType
                                           error:(NSError * _Nullable * _Nullable)error;

- (BOOL)configure:(PEPTransport * _Nullable)pEptransport
       withConfig:(PEPTransportConfig *)config
transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
            error:(NSError * _Nullable * _Nullable)error;

- (BOOL)startup:(PEPTransport * _Nullable)pEptransport
transportStatusCode:(out PEPTransportStatusCode*)tsc
          error:(NSError * _Nullable * _Nullable)error;

- (BOOL)shutdown:(PEPTransport * _Nullable)pEptransport
transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
           error:(NSError * _Nullable * _Nullable)error;

- (BOOL)sendMessage:(PEPMessage *)msg
transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
              error:(NSError * _Nullable * _Nullable)error;

- (PEPMessage * _Nullable)nextMessageWithTransportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
                                                       error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
