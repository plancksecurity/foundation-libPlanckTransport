//
//  PEPBlockBasedTransport+IncomingMessageDelegate.m
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 03.02.22.
//

#import "PEPBlockBasedTransport+IncomingMessageDelegate.h"

#import "PEPBlockBasedTransport+ForDelegates.h"

@implementation PEPBlockBasedTransport (IncomingMessageDelegate)

- (void)signalIncomingMessageWithTransportID:(PEPTransportID)transportID
                                  statusCode:(PEPTransportStatusCode)statusCode {
    // relay this to the main class
    [self signalIncomingMessageFromDelegateWithTransportID:transportID statusCode:statusCode];
}

@end
