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
///
/// Implementaions:
/// - MUST always set the `out nonnull PEPTransportStatusCode *`
/// - IF the PEPTransportStatusCode is an error:
///     - MUST return [nil|NO]
///     - MUST set the error
/// - ELSE:
///     - MUST return [returnval|YES]
///
@protocol PEPTransportProtocol <NSObject>

@property (weak, nonatomic) id<PEPTransportSendToResultDelegate> signalSendToResultDelegate;
@property (weak, nonatomic) id<PEPTransportIncomingMessageDelegate> signalIncomingMessageDelegate;
@property (weak, nonatomic) id<PEPTransportStatusChangeDelegate> signalStatusChangeDelegate;

/// Nullable only for OUT_OF_MEMORY
- (_Nullable instancetype)init;

/// Nullable only for OUT_OF_MEMORY
- (_Nullable instancetype)initWithSignalStatusChangeDelegate:(id<PEPTransportStatusChangeDelegate> _Nullable)signalStatusChangeDelegate
                                  signalSendToResultDelegate:(id<PEPTransportSendToResultDelegate> _Nullable)signalSendToResultDelegate
                               signalIncomingMessageDelegate:(id<PEPTransportIncomingMessageDelegate> _Nullable)signalIncomingMessageDelegate
                                                       error:(NSError * _Nullable * _Nullable)error;

/// @param config Optional config. If none is passed, default config is used.
/// @param transportStatusCode  ConfigIncompleteOrWrong is returend if an invalid config is passed
///                             Otherwize: READY
/// @param error ConfigIncompleteOrWrong
/// @return success
- (BOOL)configureWithConfig:(nonnull PEPTransportConfig *)config
        transportStatusCode:(out nonnull PEPTransportStatusCode *)transportStatusCode
                      error:(NSError * _Nullable * _Nullable)error;

- (BOOL)startupWithTransportStatusCode:(out  nonnull PEPTransportStatusCode *)transportStatusCode
                                  error:(NSError * _Nullable * _Nullable)error;

//BUFF: status code out nullable OK? Also Is inconsistant.
- (BOOL)shutdownWithTransportStatusCode:(out  nonnull PEPTransportStatusCode *)transportStatusCode
                                  error:(NSError * _Nullable * _Nullable)error;

- (BOOL)sendMessage:(PEPMessage *)msg
         pEpSession:(PEPSession * _Nullable)pEpSession
transportStatusCode:(out  nonnull PEPTransportStatusCode *)transportStatusCode
              error:(NSError * _Nullable * _Nullable)error;

- (PEPMessage * _Nullable)nextMessageWithPEPSession:(PEPSession * _Nullable)pEpsession
                                transportStatusCode:(out  nonnull PEPTransportStatusCode *)transportStatusCode
                                              error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
