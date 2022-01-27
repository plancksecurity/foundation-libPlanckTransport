//
//  TransportMock.h
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import <Foundation/Foundation.h>

#import "PEPTransportProtocol.h"

@class PEPMessage;

NS_ASSUME_NONNULL_BEGIN

/// A mock of `PEPTransportProtocol`.
@interface TransportMock : NSObject <PEPTransportProtocol>

/// If this is set, startup will fail immediately with this status code and corresponding error.
@property (nonatomic, nullable) NSNumber *directStartupErrorCode;

/// If this is set, startup will first succed and then fail asynchronously with this status code and corresponding error.
@property (nonatomic, nullable) NSNumber *delayedStartupErrorCode;

/// Simulate the case that a message is received by this transport, and offered to the client.
- (void)pushReceivedMessage:(PEPMessage *)message;

@end

NS_ASSUME_NONNULL_END
