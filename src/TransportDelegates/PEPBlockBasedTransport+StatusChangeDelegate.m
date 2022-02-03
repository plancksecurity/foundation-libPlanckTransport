//
//  PEPBlockBasedTransport+StatusChangeDelegate.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 28.01.22.
//

#import "PEPBlockBasedTransport+StatusChangeDelegate.h"

#import "PEPBlockBasedTransport+ForDelegates.h"
#import "PEPTransportStatusCodeUtil.h"
#import "PEPBlockBasedTransport+Error.h"

#pragma mark - PEPTransportStatusChangeDelegate Helpers

@implementation PEPBlockBasedTransport (PEPTransportStatusChangeDelegateHelpers)

- (void)signalErrorWithStatusCode:(PEPTransportStatusCode)statusCode
                      toCallbacks:(NSMutableSet<PEPTransportStatusCallbacks *> *)callbackSet {
    NSError *error = [self errorWithTransportStatusCode:statusCode];
    NSSet *allCallbacks = [NSSet setWithSet:callbackSet];

    @synchronized (callbackSet) {
        for (PEPTransportStatusCallbacks *callbacks in allCallbacks) {
            callbacks.errorCallback(statusCode, error);
        }
    }

    @synchronized (callbackSet) {
        for (PEPTransportStatusCallbacks *callbacks in allCallbacks) {
            [callbackSet removeObject:callbacks];
        }
    }
}

- (void)signalSuccessWithStatusCode:(PEPTransportStatusCode)statusCode
                        toCallbacks:(NSMutableSet<PEPTransportStatusCallbacks *> *)callbackSet {
    NSSet *allCallbacks = [NSSet setWithSet:callbackSet];

    @synchronized (callbackSet) {
        for (PEPTransportStatusCallbacks *callbacks in allCallbacks) {
            callbacks.successCallback(statusCode);
        }
    }

    @synchronized (callbackSet) {
        for (PEPTransportStatusCallbacks *callbacks in allCallbacks) {
            [callbackSet removeObject:callbacks];
        }
    }
}

@end

#pragma mark - PEPTransportStatusChangeDelegate

@implementation PEPBlockBasedTransport (PEPTransportStatusChangeDelegate)

- (void)signalStatusChangeWithTransportID:(PEPTransportID)transportID
                               statusCode:(PEPTransportStatusCode)statusCode {
    if (statusCode == PEPTransportStatusCodeConnectionDown) {
        [self signalErrorWithStatusCode:statusCode toCallbacks:self.startupCallbacks];
        [self signalSuccessWithStatusCode:statusCode toCallbacks:self.shutdownCallbacks];
    } else if (statusCode == PEPTransportStatusCodeConnectionUp) {
        [self signalSuccessWithStatusCode:statusCode toCallbacks:self.startupCallbacks];
        [self signalErrorWithStatusCode:statusCode toCallbacks:self.shutdownCallbacks];
    } else if ([PEPTransportStatusCodeUtil isErrorStatusCode:statusCode]) {
        [self signalErrorWithStatusCode:statusCode toCallbacks:self.startupCallbacks];
        [self signalErrorWithStatusCode:statusCode toCallbacks:self.shutdownCallbacks];
    } else {
        [self signalSuccessWithStatusCode:statusCode toCallbacks:self.startupCallbacks];
    }
}

@end
