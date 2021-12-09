//
//  PEPRPCTransportTestConnector.h
//  TestRPCClient_macOS
//
//  Created by Andreas Buff on 06.12.21.
//

#import <Foundation/Foundation.h>

#import <pEpIPsecRPCObjCAdapter.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPRPCTransportTestConnector : NSObject<PEPRPCConnectorIPsecDelegate, PEPRPCConnectorTransportDelegate>

- (void)start;

@end

NS_ASSUME_NONNULL_END
