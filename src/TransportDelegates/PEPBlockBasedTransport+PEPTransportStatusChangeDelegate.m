//
//  PEPBlockBasedTransport+PEPTransportStatusChangeDelegate.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 28.01.22.
//

#import "PEPBlockBasedTransport+PEPTransportStatusChangeDelegate.h"

@implementation PEPBlockBasedTransport (PEPTransportStatusChangeDelegate)

- (void)signalStatusChangeWithTransportID:(PEPTransportID)transportID
                               statusCode:(PEPTransportStatusCode)statusCode {
    if (statusCode == PEPTransportStatusCodeConnectionUp) {
        // TODO: Try to inform pending callbacks from startup
    } else if (statusCode == PEPTransportStatusCodeConnectionDown) {
        // TODO: Try to inform pending callbacks from shutdown
    } else {
        // TODO: What could this mean? Inform the general delegate
    }
}

@end
