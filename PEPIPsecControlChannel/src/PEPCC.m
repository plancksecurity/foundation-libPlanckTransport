//
//  PEPCC.m
//  pEpCC_macOS
//
//  Created by Andreas Buff on 16.08.21.
//

#import "PEPIPsecControlChannel.h"

// TODO #import "PEPSCTPTransport.h"
//#import "PEPSession.h"

@interface PEPIPsecControlChannel () <PEPTransportStatusChangeDelegate, PEPTransportSendToResultDelegate, PEPTransportIncomingMessageDelegate>
@property (nonatomic) id<PEPTransportProtocol> pEpSCTPTransport;
@end

@implementation PEPIPsecControlChannel

// synthesize required when properties are declared in protocol.
@synthesize signalIncomingMessageDelegate;
@synthesize signalSendToResultDelegate;
@synthesize signalStatusChangeDelegate;

// MARK: - Init

- (instancetype)init {
    if (self = [super init]) {
    }

    return self;
}

- (instancetype)initWithSignalStatusChangeDelegate:(id<PEPTransportStatusChangeDelegate>)signalStatusChangeDelegate
                        signalSendToResultDelegate:(id<PEPTransportSendToResultDelegate>)signalSendToResultDelegate
                     signalIncomingMessageDelegate:(id<PEPTransportIncomingMessageDelegate>)signalIncomingMessageDelegate
                                             error:(NSError * _Nullable __autoreleasing *)error {
    if (self = [self init]) {
        self.signalStatusChangeDelegate = signalStatusChangeDelegate;
        self.signalSendToResultDelegate = signalSendToResultDelegate;
        self.signalIncomingMessageDelegate = signalIncomingMessageDelegate;

        _pEpSCTPTransport = nil; /* TODO [[PEPSCTPTransport alloc] initWithSignalStatusChangeDelegate:self
                                                              signalSendToResultDelegate:self
                                                           signalIncomingMessageDelegate:self
                                                                                   error:error];*/
    }

    return self;
}

// MARK: - API

- (BOOL)    configure:(PEPTransport *)pEptransport
           withConfig:(PEPTransportConfig *)config
  transportStatusCode:(out PEPTransportStatusCode *)tsc
                error:(NSError * _Nullable __autoreleasing *)error {

    return [self.pEpSCTPTransport configure:pEptransport
                                 withConfig:config
                        transportStatusCode:tsc
                                      error:error];
}

- (BOOL)    startup:(PEPTransport *)pEptransport
transportStatusCode:(out PEPTransportStatusCode *)tsc
              error:(NSError * _Nullable __autoreleasing *)error {

    return [self.pEpSCTPTransport startup:pEptransport transportStatusCode:tsc error:error];
}

- (BOOL)    shutdown:(PEPTransport *)pEptransport
 transportStatusCode:(out PEPTransportStatusCode *)tsc
               error:(NSError * _Nullable __autoreleasing *)error {

    return [self.pEpSCTPTransport shutdown:pEptransport transportStatusCode:tsc error:error];
}

- (BOOL)    sendMessage:(PEPMessage *)msg
             pEpSession:(PEPSession *)pEpSession
    transportStatusCode:(out PEPTransportStatusCode *)tsc
                  error:(NSError * _Nullable __autoreleasing *)error {
//    id<PEPSessionProtocol> encryptingSession = pEpSession;
//    if (!encryptingSession) {
//        encryptingSession = [PEPSession new];
//    }
//    PEPMessage *encryptedMessage = [self encryptMessage:msg session:encryptingSession error:error];
//
//    if (!encryptedMessage) {
//        return NO;
//    }
//
//    return [self.pEpSCTPTransport sendMessage:encryptedMessage
//                                   pEpSession:pEpSession
//                          transportStatusCode:tsc
//                                        error:error];
    return [self.pEpSCTPTransport sendMessage:msg
                                   pEpSession:pEpSession
                          transportStatusCode:tsc
                                        error:error];
}

- (PEPMessage *)nextMessageWithPEPSession:(PEPSession *)pEpsession
                      transportStatusCode:(out PEPTransportStatusCode *)tsc
                                    error:(NSError * _Nullable __autoreleasing *)error {
//    id<PEPSessionProtocol> decryptingSession = pEpsession;
//    if (!decryptingSession) {
//        decryptingSession = [PEPSession new];
//    }
//    PEPMessage *encryptedMessage = [self.pEpSCTPTransport nextMessageWithPEPSession:pEpsession
//                                                                transportStatusCode:tsc
//                                                                              error:error];
//    if (!encryptedMessage) {
//        return nil;
//    }
//
//    return [self decryptMessage:encryptedMessage session:decryptingSession error:error];
    return [self.pEpSCTPTransport nextMessageWithPEPSession:pEpsession
                                                                transportStatusCode:tsc
                                                                              error:error];
}

// MARK: - PEPTransportStatusChangeDelegate

- (void)signalStatusChangeWithTransportID:(PEPTransportID)transportID
                               statusCode:(PEPTransportStatusCode)statusCode {

    [self.signalStatusChangeDelegate signalStatusChangeWithTransportID:transportID
                                                            statusCode:statusCode];
}

// MARK: - PEPTransportSendToResultDelegate

- (void)signalSendToResultWithTransportID:(PEPTransportID)transportID
                                messageID:(NSString *)messageID
                                  address:(NSString *)address
                               statusCode:(PEPTransportStatusCode)statusCode {

    [self.signalSendToResultDelegate signalSendToResultWithTransportID:transportID
                                                             messageID:messageID
                                                               address:address
                                                            statusCode:statusCode];
}

// MARK: - PEPTransportIncomingMessageDelegate

- (void)signalIncomingMessageWithTransportID:(PEPTransportID)transportID
                                  statusCode:(PEPTransportStatusCode)statusCode {

    [self.signalIncomingMessageDelegate signalIncomingMessageWithTransportID:transportID
                                                                  statusCode:statusCode];
}

//// MARK: - Encryption
//
//- (PEPMessage *)decryptMessage:(PEPMessage *)message
//                       session:(PEPSession *)session
//                         error:(NSError * _Nullable __autoreleasing *)error {
//    __block NSError *decryptError = error ? *error : nil;
//    __block PEPMessage *decryptedPEPMessage;
//
//    dispatch_group_t decrypt_group = dispatch_group_create();
//    dispatch_group_enter(decrypt_group);
//
//    [session decryptMessage:message
//                      flags:0
//                  extraKeys:@[]
//              errorCallback:^(NSError * _Nonnull error) {
//        decryptError = error;
//
//        dispatch_group_leave(decrypt_group);
//    } successCallback:^(PEPMessage * _Nonnull srcMessage,
//                        PEPMessage * _Nonnull dstMessage,
//                        PEPStringList * _Nonnull keyList,
//                        PEPRating rating,
//                        PEPDecryptFlags flags,
//                        BOOL isFormerlyEncryptedReuploadedMessage) {
//        decryptedPEPMessage = dstMessage;
//
//        dispatch_group_leave(decrypt_group);
//    }];
//
//    dispatch_group_wait(decrypt_group, DISPATCH_TIME_FOREVER);
//
//    return decryptedPEPMessage;
//}
//
//- (PEPMessage *)encryptMessage:(PEPMessage *)message
//                       session:(PEPSession *)session
//                         error:(NSError * _Nullable __autoreleasing *)error {
//    __block NSError *encryptionError = error ? *error : nil;
//    __block PEPMessage *encryptedPEPMessage;
//
//    dispatch_group_t encrypt_group = dispatch_group_create();
//    dispatch_group_enter(encrypt_group);
//
//    [session encryptMessage:message
//                  extraKeys:@[]
//                  encFormat:PEPEncFormatPEP
//              errorCallback:^(NSError * _Nonnull error) {
//        encryptionError = error ? : nil;
//
//        dispatch_group_leave(encrypt_group);
//    } successCallback:^(PEPMessage * _Nonnull srcMessage,
//                        PEPMessage * _Nonnull destMessage) {
//        encryptedPEPMessage = destMessage;
//
//        dispatch_group_leave(encrypt_group);
//    }];
//
//    dispatch_group_wait(encrypt_group, DISPATCH_TIME_FOREVER);
//
//    return encryptedPEPMessage;
//}

@end
