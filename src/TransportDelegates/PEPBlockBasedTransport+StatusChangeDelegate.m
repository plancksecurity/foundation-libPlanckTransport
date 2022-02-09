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
    } else if ([PEPTransportStatusCodeUtil isErrorStatusCode:statusCode]) {
        // If there is any kind of error,
        // try to first deliver it to any pending startup/shutdown callbacks
        delivered = [self signalErrorWithStatusCode:statusCode toCallbacks:self.startupCallbacks];
        delivered |= [self signalErrorWithStatusCode:statusCode toCallbacks:self.shutdownCallbacks];

        if (!delivered) {
            // If not yet delivered to anyone, assume it's fatal and tell the delegate
            [self.transportDelegate connectionStoppedWithtransportID:transportID
                                                          statusCode:statusCode];
        }
    } else {
        // TODO: We know it's not an error, and note one of the codes handled above.
        // What to do with it?
    }
}

@end
