//
//  PEPSCTPTransportMock.m
//  pEpCCTests
//
//  Created by David Alarcon on 6/9/21.
//

#import "PEPSCTPTransportMock.h"

#import "NSError+PEPCCTransport+internal.h"

@interface PEPSCTPTransportMock ()
@property (nonatomic) PEPMessage *message;
@end

@implementation PEPSCTPTransportMock

// MARK: - PEPTransportProtocol

@synthesize signalIncomingMessageDelegate;
@synthesize signalStatusChangeDelegate;
@synthesize signalSendToResultDelegate;

- (instancetype _Nullable)initWithSignalStatusChangeDelegate:(id<PEPTransportStatusChangeDelegate> _Nullable)signalStatusChangeDelegate
                                  signalSendToResultDelegate:(id<PEPTransportSendToResultDelegate> _Nullable)signalSendToResultDelegate
                               signalIncomingMessageDelegate:(id<PEPTransportIncomingMessageDelegate> _Nullable)signalIncomingMessageDelegate
                                                       error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    return [super init];
}

- (BOOL)    configure:(PEPTransport * _Nullable)pEptransport
           withConfig:(nonnull PEPTransportConfig *)config
  transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
                error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    *tsc = PEPTransportStatusCodeConnectionUp;
    *error = [NSError errorWithPEPCCTransportStatusCode:*tsc];

    return YES;
}

- (PEPMessage * _Nullable)nextMessageWithPEPSession:(PEPSession * _Nullable)pEpsession
                                transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
                                              error:(NSError * _Nullable __autoreleasing * _Nullable)error {

    return self.message;
}

- (BOOL)sendMessage:(nonnull PEPMessage *)msg
         pEpSession:(PEPSession * _Nullable)pEpSession
transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
              error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    self.message = msg;

    return YES;
}

- (BOOL)    shutdown:(PEPTransport * _Nullable)pEptransport
 transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
               error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    *tsc = PEPTransportStatusCodeConnectionDown;
    *error = [NSError errorWithPEPCCTransportStatusCode:*tsc];

    return NO;
}

- (BOOL)    startup:(PEPTransport * _Nullable)pEptransport
transportStatusCode:(out nonnull PEPTransportStatusCode *)tsc
              error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    *tsc = PEPTransportStatusCodeConnectionUp;
    *error = [NSError errorWithPEPCCTransportStatusCode:*tsc];

    return YES;
}

@end
