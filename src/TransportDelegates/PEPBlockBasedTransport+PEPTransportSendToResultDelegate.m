//
//  PEPBlockBasedTransport+PEPTransportSendToResultDelegate.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 02.02.22.
//

#import "PEPBlockBasedTransport+PEPTransportSendToResultDelegate.h"

#import "PEPBlockBasedTransport+ForDelegates.h"

@implementation PEPBlockBasedTransport (PEPTransportSendToResultDelegate)

- (void)signalSendToResultWithTransportID:(PEPTransportID)transportID
                                messageID:(nonnull NSString *)messageID
                                  address:(nonnull NSString *)address
                                pEpRating:(PEPRating)pEpRating
                               statusCode:(PEPTransportStatusCode)statusCode {
    PEPTransportStatusCallbacks *callbacks = [self findAndRemoveCallbacksForMessageID:messageID];

    // That would look like a developer error.
    NSAssert(callbacks != nil, @"Got called with message send result, but no callback");
}

@end
