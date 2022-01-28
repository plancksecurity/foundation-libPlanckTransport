//
//  MockBlockBasedTransportDelegate.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 28.01.22.
//

#import "MockBlockBasedTransportDelegate.h"

@implementation MockBlockBasedTransportDelegate

- (void)connectionStoppedWithtransportID:(PEPTransportID)transportID
                              statusCode:(PEPTransportStatusCode)statusCode {
}

- (void)signalIncomingMessage:(nonnull PEPMessage *)message
                  transportID:(PEPTransportID)transportID
                   statusCode:(PEPTransportStatusCode)statusCode {
}

@end
