//
//  MockStatusChangeDelegate.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import "MockStatusChangeDelegate.h"

@implementation MockStatusChangeDelegate

- (void)signalStatusChangeWithTransportID:(PEPTransportID)transportID
                               statusCode:(PEPTransportStatusCode)statusCode {
    @synchronized (self) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.statusChanges];
        [array addObject:[NSNumber numberWithInteger:statusCode]];
        self.statusChanges = [NSArray arrayWithArray:array];
    }

    [self.expectationStatusChanged fulfill];
}

@end
