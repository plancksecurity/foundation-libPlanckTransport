#import <Foundation/Foundation.h>

@import PEPObjCTypes_macOS;

@class PEPTransportConfig;
@class PEPSession;
@class PEPTransport;
@class PEPMessage;

NS_ASSUME_NONNULL_BEGIN

@protocol PEPTransportSendToResultDelegate <NSObject>

- (BOOL)signalSendToResultWithTransportID:(PEPTransportID)transportID
                                messageID:(NSString *)messageID
                                  address:(NSString *)address
                               statusCode:(PEPTransportStatusCode *)statusCode
                                    error:(NSError * _Nullable * _Nullable)error;
@end

@protocol PEPTransportIncomingMessageDelegate <NSObject>

- (BOOL)signalIncomingMessageWithTransportID:(PEPTransportID)transportID
                                  statusCode:(PEPTransportStatusCode *)statusCode
                                       error:(NSError * _Nullable * _Nullable)error;
@end

@protocol PEPTransportStatusChangeDelegate <NSObject>

- (BOOL)signalStatusChangeWithTransportID:(PEPTransportID)transportID
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
///     - listen to incomingMessage delegate
///         - call nextMessage to get it
/// shutdown
@protocol PEPTransportProtocol <NSObject>

@property (weak, nonatomic) id<PEPTransportSendToResultDelegate> signalSendToResultDelegate;
@property (weak, nonatomic) id<PEPTransportIncomingMessageDelegate> signalIncomingMessageDelegate;
@property (weak, nonatomic) id<PEPTransportStatusChangeDelegate> signalStatusChangeDelegate;

- (instancetype)init;

/// Convenience initializer.
- (_Nullable instancetype)initWithSignalStatusChangeDelegate:(id<PEPTransportStatusChangeDelegate> _Nullable)signalStatusChangeDelegate
                                  signalSendToResultDelegate:(id<PEPTransportSendToResultDelegate> _Nullable)signalSendToResultDelegate
                               signalIncomingMessageDelegate:(id<PEPTransportIncomingMessageDelegate> _Nullable)signalIncomingMessageDelegate
                                       callbackExecutionType:(PEPTransportCallbackExcecutionType)callbackExecutionType
                                                       error:(NSError * _Nullable * _Nullable)error;

- (BOOL)     configure:(PEPTransport * _Nullable)pEptransport
            withConfig:(PEPTransportConfig *)config
   transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
                 error:(NSError * _Nullable * _Nullable)error;

- (BOOL)     startup:(PEPTransport * _Nullable)pEptransport
 transportStatusCode:(out PEPTransportStatusCode*)tsc
               error:(NSError * _Nullable * _Nullable)error;

- (BOOL)     shutdown:(PEPTransport * _Nullable)pEptransport
  transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
                error:(NSError * _Nullable * _Nullable)error;

- (BOOL)     sendMessage:(PEPMessage *)msg pEpSession:(PEPSession * _Nullable)pEpSession
     transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
                   error:(NSError * _Nullable * _Nullable)error;

- (PEPMessage * _Nullable)nextMessageWithPEPSession:(PEPSession * _Nullable)pEpsession
                                transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
                                              error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END