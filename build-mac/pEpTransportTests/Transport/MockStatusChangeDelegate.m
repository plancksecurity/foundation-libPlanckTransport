//
//  MockStatusChangeDelegate.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import "MockStatusChangeDelegate.h"

@implementation MockStatusChangeDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        _statusChanges = [NSArray new];
    }
    return self;
}

- (void)signalStatusChangeWithTransportID:(PEPTransportID)transportID
                               statusCode:(PEPTransportStatusCode)statusCode {
    @synchronized (self) {
        self.statusChanges = [self.statusChanges arrayByAddingObject:[NSNumber numberWithInteger:statusCode]];
    }

    [self.expectationStatusChanged fulfill];
}

@end
