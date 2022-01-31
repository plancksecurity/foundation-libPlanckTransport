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
    if (statusCode == PEPTransportStatusCodeConnectionUp) {
        invoked = [self invokePendingStartSuccessCallbacksWithStatusCode:statusCode];
    } else if (statusCode == PEPTransportStatusCodeConnectionDown) {
        invoked = [self invokePendingShutdownSuccessCallbacksWithStatusCode:statusCode];
    } else {
        // TODO: What could this mean? Inform the general delegate
    }
}

@end
