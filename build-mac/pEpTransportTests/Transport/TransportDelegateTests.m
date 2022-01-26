//
//  TransportDelegateTests.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import <XCTest/XCTest.h>

#import "MockStatusChangeDelegate.h"
#import "TransportMock.h"

@interface TransportDelegateTests : XCTestCase

@end

@implementation TransportDelegateTests

- (void)setUp {
}

- (void)tearDown {
}

- (void)testStartupSuccess {
    MockStatusChangeDelegate *statusChangeDelegate = [MockStatusChangeDelegate new];
    NSError *error = nil;
    TransportMock *transport = [[TransportMock alloc]
                                initWithSignalStatusChangeDelegate:statusChangeDelegate signalSendToResultDelegate:nil signalIncomingMessageDelegate:nil
                                error:&error];
    XCTAssertNotNil(transport);
    XCTAssertNil(error);

    error = nil;
    transport.startupShouldSucceed = YES;
    PEPTransportStatusCode statusCode;
    BOOL success = [transport startupWithTransportStatusCode:&statusCode error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);
    XCTAssertEqual(statusChangeDelegate.statusChanges.count, 1);
    NSNumber *num = [statusChangeDelegate.statusChanges firstObject];
    XCTAssertNotNil(num);
    XCTAssertEqual(num.integerValue, PEPTransportStatusCodeReady);
}

@end
