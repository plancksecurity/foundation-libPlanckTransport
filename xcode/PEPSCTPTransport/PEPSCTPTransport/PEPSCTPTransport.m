//
//  PEPSCTPTransport.m
//  pEpCC_macOS
//
//  Created by Andreas Buff on 19.08.21.
//

#import "PEPSCTPTransport.h"

#import <usrsctp.h>

#import "NSError+PEPSCTPTransport+internal.h"

@interface PEPSCTPTransport ()

@property PEPTransportCallbackExcecutionType callbackExecutionType;
@property (nonatomic) PEPTransportConfig *transportConfig;

@end

@implementation PEPSCTPTransport

@synthesize signalSendToResultDelegate = _signalSendToResultDelegate;
@synthesize signalIncomingMessageDelegate = _signalIncomingMessageDelegate;
@synthesize signalStatusChangeDelegate = _signalStatusChangeDelegate;

- (_Nullable instancetype)initWithSignalStatusChangeDelegate:(id<PEPTransportStatusChangeDelegate> _Nullable)signalStatusChangeDelegate
                                  signalSendToResultDelegate:(id<PEPTransportSendToResultDelegate> _Nullable)signalSendToResultDelegate
                               signalIncomingMessageDelegate:(id<PEPTransportIncomingMessageDelegate> _Nullable)signalIncomingMessageDelegate
                                       callbackExecutionType:(PEPTransportCallbackExcecutionType)callbackExecutionType
                                                       error:(NSError * _Nullable * _Nullable)error
{
    self = [super init];
    if (self) {
        _signalStatusChangeDelegate = signalStatusChangeDelegate;
        _signalSendToResultDelegate = signalSendToResultDelegate;
        _signalIncomingMessageDelegate = signalIncomingMessageDelegate;
        _callbackExecutionType = callbackExecutionType;
    }
    return self;
}

- (BOOL)configure:(PEPTransport * _Nullable)pEptransport
       withConfig:(nonnull PEPTransportConfig *)config
transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
            error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    self.transportConfig = config;
    return YES;
}

/// Sets the given `PEPTransportStatusCode` as error to the given error pointer, and the given `PEPTransportStatusCode`
/// pointer, _if_ it's an error condition.
///
/// @return `YES` if the given transport status code is indeed an error, `NO` otherwise.
BOOL setTransportStatusCodeError(PEPTransportStatusCode transportStatusCode,
                                 PEPTransportStatusCode * _Nonnull targetTransportStatusCode,
                                 NSError * _Nullable __autoreleasing * _Nullable error)
{
    if ([NSError isErrorTransportStatusCode:transportStatusCode]) {
        if (error != nil) {
            *error = [NSError errorWithPEPTransportStatusCode:transportStatusCode];
        }

        *targetTransportStatusCode = transportStatusCode;
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)startup:(PEPTransport * _Nullable)pEptransport
transportStatusCode:(out nonnull PEPTransportStatusCode *)tsc
          error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (self.transportConfig == nil) {
        setTransportStatusCodeError(PEPTransportStatusCodeConnectionNoConfig, tsc, error);
        return NO;
    }
    NSAssert(false, @"unimplemented");
    return false;
}

- (BOOL)shutdown:(PEPTransport * _Nullable)pEptransport
transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
           error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSAssert(false, @"unimplemented");
    return false;
}

- (BOOL)sendMessage:(nonnull PEPMessage *)msg
         pEpSession:(PEPSession * _Nullable)pEpSession
transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
              error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSAssert(false, @"unimplemented");
    return false;
}

- (PEPMessage * _Nullable)nextMessageWithPEPSession:(PEPSession * _Nullable)pEpsession
                                transportStatusCode:(out PEPTransportStatusCode * _Nullable)tsc
                                              error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSAssert(false, @"unimplemented");
    return nil;
}

@end
