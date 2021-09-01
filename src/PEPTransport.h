#import <Foundation/Foundation.h>

@import PEPObjCTypes_macOS;

@class PEPTransportConfig;
@class PEPSession;
@class PEPTransport;
@class PEPMessage;

NS_ASSUME_NONNULL_BEGIN

@protocol PEPCCSendResultDelegate <NSObject>

- (BOOL)signalSendMessageResultWithTransportID:(PEPCCTransportID)transportID
                                     messageID:(NSString *)messageID
                                       address:(NSString *)address
                                    statusCode:(PEPCCTransportStatusCode *)statusCode
                                         error:(NSError * _Nullable * _Nullable)error;
@end

@protocol PEPCCIncomingMessageDelegate <NSObject>

- (BOOL)signalNewIncomingMessageWithTransportID:(PEPCCTransportID)transportID
                                     statusCode:(PEPCCTransportStatusCode *)statusCode
                                          error:(NSError * _Nullable * _Nullable)error;
@end

@protocol PEPCCStatusChangeDelegate <NSObject>

- (BOOL)statusChangedWithTransportID:(PEPCCTransportID)transportID
                          statusCode:(PEPCCTransportStatusCode *)statusCode
                               error:(NSError * _Nullable * _Nullable)error;
@end

/// Idea in a nutshell:
/// - Init with callbacks and callbackExecutionType
/// - configure
/// - startup
/// - listen to status changes (e.g. connected aka "PEPCCTransportStatusCodeReady"
/// - use it:
///     - send message
///     - listen to- and handle sendMessageResult (e.g. done sending aka "PEPCCTransportStatusCodeMessageDelivered")
///     - listen to newIncommingMessage delegate
///         - call nextMessage to get it
/// shutdown
@protocol PEPTransport <NSObject>

- (instancetype)init;

/// Convenience initializer.
- (_Nullable instancetype)initWithChangeDelegate:(id<PEPCCStatusChangeDelegate> _Nullable)statusChangeDelegate
                        signalSendResultDelegate:(id<PEPCCSendResultDelegate> _Nullable)signalSendResultDelegate
                   signalIncomingMessageDelegate:(id<PEPCCIncomingMessageDelegate> _Nullable)signalIncomingMessageDelegate
                           callbackExecutionType:(PEPCCCallbackExcecutionType)callbackExecutionType
                                           error:(NSError * _Nullable * _Nullable)error;

- (BOOL)configure:(PEPTransport * _Nullable)pEptransport
       withConfig:(PEPTransportConfig *)config
transportStatusCode:(out PEPCCTransportStatusCode * _Nullable)tsc
            error:(NSError * _Nullable * _Nullable)error;

- (BOOL)startup:(PEPTransport * _Nullable)pEptransport
transportStatusCode:(out PEPCCTransportStatusCode*)tsc
          error:(NSError * _Nullable * _Nullable)error;

- (BOOL)shutdown:(PEPTransport * _Nullable)pEptransport
transportStatusCode:(out PEPCCTransportStatusCode * _Nullable)tsc
           error:(NSError * _Nullable * _Nullable)error;

- (BOOL)sendMessage:(PEPMessage *)msg
         pEpSession:(PEPSession * _Nullable)pEpSession
transportStatusCode:(out PEPCCTransportStatusCode * _Nullable)tsc
              error:(NSError * _Nullable * _Nullable)error;

- (PEPMessage * _Nullable)nextMessageWithPEPSession:(PEPSession * _Nullable)pEpsession
                                transportStatusCode:(out PEPCCTransportStatusCode * _Nullable)tsc
                                              error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
