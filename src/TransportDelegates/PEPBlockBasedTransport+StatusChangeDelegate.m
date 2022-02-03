//
//  PEPBlockBasedTransport+StatusChangeDelegate.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 28.01.22.
//

#import "PEPBlockBasedTransport+StatusChangeDelegate.h"

#import "PEPBlockBasedTransport+ForDelegates.h"

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

@end
