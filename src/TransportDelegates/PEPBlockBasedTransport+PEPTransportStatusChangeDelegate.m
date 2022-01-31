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
    if (statusCode == PEPTransportStatusCodeConnectionUp) {
        [self invokePendingStartSuccessCallbacksWithStatusCode:statusCode];
    } else if (statusCode == PEPTransportStatusCodeConnectionDown) {
        // TODO: Try to inform pending callbacks from shutdown
    } else {
        // TODO: What could this mean? Inform the general delegate
    }
}

@end
