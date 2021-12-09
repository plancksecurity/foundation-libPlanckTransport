//
//  PEPCC+Test.m
//  pEpCCTests
//
//  Created by David Alarcon on 6/9/21.
//

#import "PEPCC+Test.h"

@interface PEPCC (Test)
@property (nonatomic) id<PEPTransportProtocol> pEpSCTPTransport;
@end

@implementation PEPCC (Test)

- (instancetype)initWithTransport:(id<PEPTransportProtocol>)transport {
    if (self = [self init]) {
        self.pEpSCTPTransport = transport;
    }

    return self;
}

@end
