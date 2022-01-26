//
//  MockIncomingMessageDelegate.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import "MockIncomingMessageDelegate.h"

@implementation MockIncomingMessageDelegate

- (void)signalIncomingMessageWithTransportID:(PEPTransportID)transportID
                                  statusCode:(PEPTransportStatusCode)statusCode {
    self.messageIsAvailable = YES;
}

@end
