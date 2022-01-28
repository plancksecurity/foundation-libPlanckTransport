//
//  MockBlockBasedTransportDelegate.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 28.01.22.
//

#import "MockBlockBasedTransportDelegate.h"

@interface MockBlockBasedTransportDelegate ()

@property (nonatomic) PEPMessage *lastMessageReceived;

@end

@implementation MockBlockBasedTransportDelegate

- (void)connectionStoppedWithtransportID:(PEPTransportID)transportID
                              statusCode:(PEPTransportStatusCode)statusCode {
    self.lastConnectionDownStatusCode = statusCode;
    [self.expConnectionDown fulfill];
}

- (void)signalIncomingMessage:(nonnull PEPMessage *)message
                  transportID:(PEPTransportID)transportID
                   statusCode:(PEPTransportStatusCode)statusCode {
    self.lastMessageReceived = message;
    self.lastMessageReceivedStatusCode = statusCode;
    [self.expIncomingMessage fulfill];
}

@end
