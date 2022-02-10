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
    BOOL delivered = NO;

    if (statusCode == PEPTransportStatusCodeConnectionUp) {
        // Expected success for any startup, but an error for shutdown.
        delivered = [self signalSuccessWithStatusCode:statusCode toCallbacks:self.startupCallbacks];
        delivered |= [self signalErrorWithStatusCode:statusCode toCallbacks:self.shutdownCallbacks];
    } else if (statusCode == PEPTransportStatusCodeShutDown) {
        // Expected success for shutdown, but an error for startup.
        delivered = [self signalSuccessWithStatusCode:statusCode toCallbacks:self.shutdownCallbacks];
        delivered |= [self signalErrorWithStatusCode:statusCode toCallbacks:self.startupCallbacks];

        if (!delivered) {
            // If not yet delivered to anyone, tell the delegate (it's critical after all).
            [self.transportDelegate connectionStoppedWithtransportID:transportID
                                                          statusCode:statusCode];
        }
    } else if ([PEPTransportStatusCodeUtil isCriticalErrorStatusCode:statusCode]) {
        // The special critical error, PEPTransportStatusCodeShutDown, is handled above.
        // Handle any other critical error.
        delivered = [self signalErrorWithStatusCode:statusCode toCallbacks:self.startupCallbacks];
        delivered |= [self signalErrorWithStatusCode:statusCode toCallbacks:self.shutdownCallbacks];

        if (!delivered) {
            // If not yet delivered to anyone, tell the delegate (it's critical after all).
            [self.transportDelegate connectionStoppedWithtransportID:transportID
                                                          statusCode:statusCode];
        }
    } else {
        // We received a status code that was _not_ a critical error, and not directly
        // related to start or stop.
        // Even if it's a non-critical error, the transport is supposed to "heal itself".
        // Ignore.
    }
}

@end
