//
//  PEPCC+Test.h
//  pEpCCTests
//
//  Created by David Alarcon on 6/9/21.
//

#import "PEPCC.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPCC (Test)

- (instancetype)initWithTransport:(id<PEPTransportProtocol>)transport;

@end

NS_ASSUME_NONNULL_END
