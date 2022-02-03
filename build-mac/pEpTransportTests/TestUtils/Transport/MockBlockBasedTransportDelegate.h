//
//  MockBlockBasedTransportDelegate.h
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 28.01.22.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "PEPBlockBasedTransport.h"

NS_ASSUME_NONNULL_BEGIN

@interface MockBlockBasedTransportDelegate : NSObject <PEPBlockBasedTransportDelegate>

@property (nonatomic, nullable) XCTestExpectation *expConnectionStopped;
@property (nonatomic, nullable) XCTestExpectation *expIncomingMessage;

@property (nonatomic, readonly) PEPMessage *lastMessageReceived;
@property (nonatomic) PEPTransportStatusCode lastMessageReceivedStatusCode;
@property (nonatomic) PEPTransportStatusCode lastConnectionDownStatusCode;

@end

NS_ASSUME_NONNULL_END
