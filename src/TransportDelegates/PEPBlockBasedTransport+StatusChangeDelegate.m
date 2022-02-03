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

#pragma mark - PEPTransportStatusChangeDelegate

@implementation PEPBlockBasedTransport (PEPTransportStatusChangeDelegate)

- (void)signalStatusChangeWithTransportID:(PEPTransportID)transportID
                               statusCode:(PEPTransportStatusCode)statusCode {
    if (statusCode == PEPTransportStatusCodeConnectionDown) {
        // TODO: Signal an error to all pending startup callbacks
        // TODO: Signal success to all pending shutdown callbacks
    } else if (statusCode == PEPTransportStatusCodeConnectionUp) {
        // TODO: Signal success to all pending startup callbacks
        // TODO: Signal an error to all pending shutdown callbacks
    } else if ([PEPTransportStatusCodeUtil isErrorStatusCode:statusCode]) {
        // TODO: Signal an error to all pending startup callbacks
        // TODO: Signal an error to all pending shutdown callbacks
    } else {
        // TODO: Signal success to all pending startup callbacks
    }
}

@end
