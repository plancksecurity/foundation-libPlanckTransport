//
//  TransportMock.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import "TransportMock.h"

const PEPTransportID g_transportID = PEPTransportIDTransportAuto;
NSString *g_ErrorDomain = @"TransportMockErrorDomain";

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
    if (!self.startupShouldSucceed) {
        *transportStatusCode = PEPTransportStatusCodeConnectionDown;
        if (error) {
            *error = [NSError errorWithDomain:g_ErrorDomain
                                         code:PEPTransportStatusCodeConnectionDown
                                     userInfo:nil];
        }
        return NO;
    }

    *transportStatusCode = PEPTransportStatusCodeConnectionUp;

    [self.signalStatusChangeDelegate
     signalStatusChangeWithTransportID:g_transportID
     statusCode:PEPTransportStatusCodeConnectionUp];

    return YES;
}

- (BOOL)shutdownWithTransportStatusCode:(out PEPTransportStatusCode * _Nonnull)transportStatusCode
                                  error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    *transportStatusCode = PEPTransportStatusCodeReady;
    
    [self.signalStatusChangeDelegate
     signalStatusChangeWithTransportID:g_transportID
     statusCode:PEPTransportStatusCodeConnectionDown];
    
    return YES;
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
