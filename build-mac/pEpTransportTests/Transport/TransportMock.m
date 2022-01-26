//
//  TransportMock.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import "TransportMock.h"

@implementation TransportMock

@synthesize signalIncomingMessageDelegate = _signalIncomingMessageDelegate;

@synthesize signalSendToResultDelegate = _signalSendToResultDelegate;

@synthesize signalStatusChangeDelegate = _signalStatusChangeDelegate;

- (instancetype _Nullable)initWithSignalStatusChangeDelegate:(id<PEPTransportStatusChangeDelegate> _Nullable)signalStatusChangeDelegate
                                  signalSendToResultDelegate:(id<PEPTransportSendToResultDelegate> _Nullable)signalSendToResultDelegate
                               signalIncomingMessageDelegate:(id<PEPTransportIncomingMessageDelegate> _Nullable)signalIncomingMessageDelegate
                                                       error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    self = [self init];
    if (self) {
        _signalStatusChangeDelegate = signalStatusChangeDelegate;
        _signalSendToResultDelegate = signalSendToResultDelegate;
        _signalIncomingMessageDelegate = signalIncomingMessageDelegate;
    }
    return self;
}

- (BOOL)configureWithConfig:(PEPTransportConfig * _Nullable)config
        transportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
                      error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    *transportStatusCode = PEPTransportStatusCodeReady;
    return YES;
}

- (BOOL)startupWithTransportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
                                 error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return NO;
}

- (BOOL)shutdownWithTransportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
                                  error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return NO;
}

- (PEPMessage * _Nullable)nextMessageWithPEPSession:(PEPSession * _Nullable)pEpsession
                                transportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
                                              error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return nil;
}

- (BOOL)sendMessage:(nonnull PEPMessage *)msg
         pEpSession:(PEPSession * _Nullable)pEpSession
transportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
              error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return NO;
}

@end
