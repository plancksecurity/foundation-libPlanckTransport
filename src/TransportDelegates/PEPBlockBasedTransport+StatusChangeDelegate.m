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

@implementation PEPBlockBasedTransport (PEPTransportStatusChangeDelegate)

- (void)signalStatusChangeWithTransportID:(PEPTransportID)transportID
                               statusCode:(PEPTransportStatusCode)statusCode {
    // The general idea here is, that a transport is either in "startup mode"
    // (that is, the user is waiting for the startup to succeed or fail),
    // or it is in "shutdown mode" (like "startup mode", but when shutting down,
    // or "in the middle".
    // That's the basis for figuring out which stored callbacks to call, if any.
    BOOL invoked = NO;
    invoked = [self invokePendingStartCallbackWithStatusCode:statusCode];

    if (!invoked) {
        invoked = [self invokePendingShutdownCallbackWithStatusCode:statusCode];
    }

    if (!invoked) {
        // TODO: What could this mean? Inform the general delegate.
    }
}

/// Tries to find pending startup callbacks and informs them of the given status code, marking it as a success.
/// @return `YES` if at least one callback was invoked, `NO` otherwise.
- (BOOL)invokePendingStartCallbackWithStatusCode:(PEPTransportStatusCode)statusCode {
    if (self.startupCallback) {
        if (![PEPTransportStatusCodeUtil isStartupErrorStatusCode:statusCode]) {
            self.startupCallback.successCallback(statusCode);
        } else {
            NSError *error = [self errorWithTransportStatusCode:statusCode];
            self.startupCallback.errorCallback(statusCode, error);
        }
        self.startupCallback = nil;
        return YES;
    }

    return NO;
}

/// Tries to find pending shutdown callbacks and informs them of the given status code, marking it as a success.
/// @return `YES` if at least one callback was invoked, `NO` otherwise.
- (BOOL)invokePendingShutdownCallbackWithStatusCode:(PEPTransportStatusCode)statusCode {
    if (self.shutdownCallback) {
        if (![PEPTransportStatusCodeUtil isShutdownErrorStatusCode:statusCode]) {
            self.shutdownCallback.successCallback(statusCode);
        } else {
            NSError *error = [self errorWithTransportStatusCode:statusCode];
            self.shutdownCallback.errorCallback(statusCode, error);
        }
        self.shutdownCallback = nil;
        return YES;
    }

    return NO;
}


@end
