//
//  PEPBlockBasedTransport+IncomingMessageDelegate.m
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 03.02.22.
//

#import "PEPBlockBasedTransport+IncomingMessageDelegate.h"

#import "PEPBlockBasedTransport+Internal.h"

@implementation PEPBlockBasedTransport (IncomingMessageDelegate)

- (void)signalIncomingMessageWithTransportID:(PEPTransportID)transportID
                                  statusCode:(PEPTransportStatusCode)statusCode {
    PEPTransportStatusCode statusCodeFromUnderlyingTransport;
    NSError *error = nil;
    PEPMessage *message = [self.transport nextMessageWithPEPSession:nil
                                                transportStatusCode:&statusCodeFromUnderlyingTransport
                                                              error:&error];
    if (message == nil) {
        // Weird case, but nothing to relay to the delegate, so ignore.
        NSAssert(NO, @"Underlying transport signaled new message, but there was none");
    } else {
        [self.transportDelegate signalIncomingMessage:message
                                          transportID:transportID
                                           statusCode:statusCode];
    }
}

@end
