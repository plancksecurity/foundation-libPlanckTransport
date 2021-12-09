#import <Foundation/Foundation.h>

#import "PEPObjCTypes.h"
#import "PEPTransportStatusCode.h"

@class PEPTransportConfig;
@class PEPSession;
@class PEPTransport;
@class PEPMessage;

NS_ASSUME_NONNULL_BEGIN

@protocol PEPTransportSendToResultDelegate <NSObject>

- (void)signalSendToResultWithTransportID:(PEPTransportID)transportID
                                messageID:(NSString *)messageID
                                  address:(NSString *)address
                               statusCode:(PEPTransportStatusCode)statusCode;
@end

@protocol PEPTransportIncomingMessageDelegate <NSObject>

- (void)signalIncomingMessageWithTransportID:(PEPTransportID)transportID
                                  statusCode:(PEPTransportStatusCode)statusCode;
@end

@protocol PEPTransportStatusChangeDelegate <NSObject>

- (void)signalStatusChangeWithTransportID:(PEPTransportID)transportID
                               statusCode:(PEPTransportStatusCode)statusCode;
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
                                                       error:(NSError * _Nullable * _Nullable)error;

- (BOOL)configureWithConfig:(PEPTransportConfig *)config
        transportStatusCode:(out PEPTransportStatusCode * _Nullable)transportStatusCode
                      error:(NSError * _Nullable * _Nullable)error;

- (BOOL)startupWithTtransportStatusCode:(out PEPTransportStatusCode*)transportStatusCode
                                  error:(NSError * _Nullable * _Nullable)error;

- (BOOL)shutdownWithtransportStatusCode:(out PEPTransportStatusCode * _Nullable)transportStatusCode
                                  error:(NSError * _Nullable * _Nullable)error;

- (BOOL)sendMessage:(PEPMessage *)msg
         pEpSession:(PEPSession * _Nullable)pEpSession
transportStatusCode:(out PEPTransportStatusCode * _Nullable)transportStatusCode
              error:(NSError * _Nullable * _Nullable)error;

- (PEPMessage * _Nullable)nextMessageWithPEPSession:(PEPSession * _Nullable)pEpsession
                                transportStatusCode:(out PEPTransportStatusCode * _Nullable)transportStatusCode
                                              error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
