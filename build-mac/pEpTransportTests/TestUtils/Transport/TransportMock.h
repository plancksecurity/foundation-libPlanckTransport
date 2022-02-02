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

/// If this is set, startup will _fail immediately_ with this status code and corresponding error.
@property (nonatomic, nullable) NSNumber *directStartupStatusCode;

/// If this is set, startup will first return a generic "ready" status code and then later invoke the delegate with
/// the given status code.
@property (nonatomic, nullable) NSNumber *delayedStartupStatusCode;

/// If this is set, sending a message will _fail immediately_ with this status code and corresponding error.
@property (nonatomic, nullable) NSNumber *directMessageSendStatusCode;

/// If this is set, startup will first return a generic "ready" status code and then later invoke the delegate with
/// the given status code.
@property (nonatomic, nullable) NSNumber *delayedMessageSendStatusCode;

/// Simulate the case that a message is received by this transport, and offered to the client.
- (void)pushReceivedMessage:(PEPMessage *)message;

@end

NS_ASSUME_NONNULL_END
