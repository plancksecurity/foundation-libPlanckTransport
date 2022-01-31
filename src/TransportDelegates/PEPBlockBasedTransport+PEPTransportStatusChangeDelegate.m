//
//  PEPBlockBasedTransport+PEPTransportStatusChangeDelegate.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 28.01.22.
//

#import "PEPBlockBasedTransport+PEPTransportStatusChangeDelegate.h"

#import "PEPBlockBasedTransport+Callbacks.h"

@implementation PEPBlockBasedTransport (PEPTransportStatusChangeDelegate)

- (void)signalStatusChangeWithTransportID:(PEPTransportID)transportID
                               statusCode:(PEPTransportStatusCode)statusCode {
    BOOL invoked = NO;
    invoked = [self invokePendingStartCallbacksWithStatusCode:statusCode];

    if (!invoked) {
        invoked = [self invokePendingShutdownCallbacksWithStatusCode:statusCode];
    }

    if (!invoked) {
        // TODO: What could this mean? Inform the general delegate.
    }
}

@end
