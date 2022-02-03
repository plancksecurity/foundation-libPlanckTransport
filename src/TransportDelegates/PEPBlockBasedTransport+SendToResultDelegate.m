//
//  PEPBlockBasedTransport+SendToResultDelegate.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 02.02.22.
//

#import "PEPBlockBasedTransport+SendToResultDelegate.h"

#import "PEPBlockBasedTransport+Error.h"
#import "PEPBlockBasedTransport+ForDelegates.h"
#import "PEPTransportStatusCodeUtil.h"

@implementation PEPBlockBasedTransport (PEPTransportSendToResultDelegate)

- (void)signalSendToResultWithTransportID:(PEPTransportID)transportID
                                messageID:(nonnull NSString *)messageID
                                  address:(nonnull NSString *)address
                                pEpRating:(PEPRating)pEpRating
                               statusCode:(PEPTransportStatusCode)statusCode {
    PEPTransportStatusCallbacks *callbacks = [self findAndRemoveCallbacksForMessageID:messageID];

    // That would look like a developer error.
    NSAssert(callbacks != nil, @"Got called with message send result, but no callback");

    if ([PEPTransportStatusCodeUtil isErrorStatusCode:statusCode]) {
        callbacks.errorCallback(statusCode, [self errorWithTransportStatusCode:statusCode]);
    } else {
        callbacks.successCallback(statusCode);
    }
}

/// Finds the callbacks for a given message ID and removes them.
/// @return The message callbacks (error and success), if any, defined for the given message ID.
- (PEPTransportStatusCallbacks * _Nullable)findAndRemoveCallbacksForMessageID:(NSString *)messageID {
    PEPTransportStatusCallbacks *callbacks = nil;

    @synchronized (self.messageCallbacks) {
        callbacks = [self.messageCallbacks objectForKey:messageID];
        [self.messageCallbacks removeObjectForKey:messageID];
    }

    return callbacks;
}

@end
