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

#pragma mark - Setup, Teardown

- (void)setUp {
}

- (void)tearDown {
}

#pragma mark - Tests

- (void)testStartupSuccess {
    MockStatusChangeDelegate *statusChangeDelegate = [MockStatusChangeDelegate new];
    NSError *error = nil;
    TransportMock *transport = [[TransportMock alloc]
                                initWithSignalStatusChangeDelegate:statusChangeDelegate
                                signalSendToResultDelegate:nil
                                signalIncomingMessageDelegate:nil
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
    XCTAssertEqual(num.integerValue, PEPTransportStatusCodeConnectionUp);
}

- (void)testStartupDirectError {
    MockStatusChangeDelegate *statusChangeDelegate = [MockStatusChangeDelegate new];
    NSError *error = nil;
    TransportMock *transport = [[TransportMock alloc]
                                initWithSignalStatusChangeDelegate:statusChangeDelegate
                                signalSendToResultDelegate:nil
                                signalIncomingMessageDelegate:nil
                                error:&error];
    XCTAssertNotNil(transport);
    XCTAssertNil(error);

    error = nil;
    transport.startupShouldSucceed = NO;
    PEPTransportStatusCode statusCode;
    BOOL success = [transport startupWithTransportStatusCode:&statusCode error:&error];
    XCTAssertFalse(success);
    XCTAssertNotNil(error);
    XCTAssertEqual(statusCode, PEPTransportStatusCodeConnectionDown);
    XCTAssertEqual(statusChangeDelegate.statusChanges.count, 0);
    NSNumber *num = [statusChangeDelegate.statusChanges firstObject];
    XCTAssertNil(num);
}

- (void)testShutdownSuccess {
    MockStatusChangeDelegate *statusChangeDelegate = [MockStatusChangeDelegate new];
    NSError *error = nil;
    TransportMock *transport = [[TransportMock alloc]
                                initWithSignalStatusChangeDelegate:statusChangeDelegate
                                signalSendToResultDelegate:nil
                                signalIncomingMessageDelegate:nil
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
    XCTAssertEqual(num.integerValue, PEPTransportStatusCodeConnectionUp);

    error = nil;
    BOOL success2 = [transport shutdownWithTransportStatusCode:&statusCode error:&error];
    XCTAssertTrue(success2);
    NSArray *expectedStatus = @[[NSNumber numberWithInteger:PEPTransportStatusCodeConnectionUp],
                                [NSNumber numberWithInteger:PEPTransportStatusCodeConnectionDown]];
    XCTAssertEqualObjects(statusChangeDelegate.statusChanges, expectedStatus);
}

#pragma mark - Helpers

@end
