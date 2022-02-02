//
//  PEPBlockBasedTransport+PEPTransportSendToResultDelegate.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 02.02.22.
//

#import "PEPBlockBasedTransport+PEPTransportSendToResultDelegate.h"

@implementation PEPBlockBasedTransport (PEPTransportSendToResultDelegate)

- (void)signalSendToResultWithTransportID:(PEPTransportID)transportID
                                messageID:(nonnull NSString *)messageID
                                  address:(nonnull NSString *)address
                                pEpRating:(PEPRating)pEpRating
                               statusCode:(PEPTransportStatusCode)statusCode {
}

@end
