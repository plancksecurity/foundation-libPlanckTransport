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

/// @return `YES` if at least one callback was informed, `NO` otherwise.
- (BOOL)signalErrorWithStatusCode:(PEPTransportStatusCode)statusCode
                      toCallbacks:(NSMutableSet<PEPTransportStatusCallbacks *> *)callbackSet {
    NSError *error = [self errorWithTransportStatusCode:statusCode];
    NSSet *localCallbacks = nil;

    // Copy the current outstanding callbacks
    @synchronized (callbackSet) {
        localCallbacks = [NSSet setWithSet:callbackSet];
    }

    // Invoke all callbacks
    for (PEPTransportStatusCallbacks *callbacks in localCallbacks) {
        callbacks.errorCallback(statusCode, error);
    }

    // Remove the invoked callbacks
    @synchronized (callbackSet) {
        for (PEPTransportStatusCallbacks *callbacks in localCallbacks) {
            [callbackSet removeObject:callbacks];
        }
    }

    return localCallbacks.count > 0;
}

/// @return `YES` if at least one callback was informed, `NO` otherwise.
- (BOOL)signalSuccessWithStatusCode:(PEPTransportStatusCode)statusCode
                        toCallbacks:(NSMutableSet<PEPTransportStatusCallbacks *> *)callbackSet {
    NSSet *localCallbacks = nil;

    // Copy the current outstanding callbacks
    @synchronized (callbackSet) {
        localCallbacks = [NSSet setWithSet:callbackSet];
    }

    // Invoke all callbacks
    for (PEPTransportStatusCallbacks *callbacks in localCallbacks) {
        callbacks.successCallback(statusCode);
    }

    // Remove the invoked callbacks
    @synchronized (callbackSet) {
        for (PEPTransportStatusCallbacks *callbacks in localCallbacks) {
            [callbackSet removeObject:callbacks];
        }
    }

    return localCallbacks.count > 0;
}

@end

#pragma mark - PEPTransportStatusChangeDelegate

@implementation PEPBlockBasedTransport (PEPTransportStatusChangeDelegate)

- (void)signalStatusChangeWithTransportID:(PEPTransportID)transportID
                               statusCode:(PEPTransportStatusCode)statusCode {
    BOOL delivered1 = NO;
    BOOL delivered2 = NO;

    if (statusCode == PEPTransportStatusCodeConnectionDown) {
        // Connection down is an error for startup, but success for shutdown.
        delivered1 = [self signalErrorWithStatusCode:statusCode toCallbacks:self.startupCallbacks];
        delivered2 = [self signalSuccessWithStatusCode:statusCode toCallbacks:self.shutdownCallbacks];
    } else if (statusCode == PEPTransportStatusCodeConnectionUp) {
        // Connection up is success for any startup, but an error for shutdown.
        delivered1 = [self signalSuccessWithStatusCode:statusCode toCallbacks:self.startupCallbacks];
        delivered2 = [self signalErrorWithStatusCode:statusCode toCallbacks:self.shutdownCallbacks];
    } else if ([PEPTransportStatusCodeUtil isErrorStatusCode:statusCode]) {
        // Consider other errors as errors for either type of pending callbacks.
        delivered1 = [self signalErrorWithStatusCode:statusCode toCallbacks:self.startupCallbacks];
        delivered2 = [self signalErrorWithStatusCode:statusCode toCallbacks:self.shutdownCallbacks];
    } else {
        // Any non-error status code would land here. Nothing to do, since:
        //  * startup only cares for connection up, or errors
        //  * shutdown only cares for connection down, or errors
    }

    if (!delivered1 && !delivered2) {
        // We haven't delivered that status code to anyone.
    }
}

@end
