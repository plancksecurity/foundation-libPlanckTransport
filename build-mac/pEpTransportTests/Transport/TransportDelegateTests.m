//
//  TransportDelegateTests.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import <XCTest/XCTest.h>

#import "MockStatusChangeDelegate.h"
#import "MockIncomingMessageDelegate.h"
#import "TransportMock.h"

@interface TransportDelegateTests : XCTestCase

@property (nonatomic) MockStatusChangeDelegate *statusChangeDelegate;
@property (nonatomic) MockIncomingMessageDelegate *incomingMessageDelegate;
@property (nonatomic) TransportMock *transport;

@end

@implementation TransportDelegateTests

#pragma mark - Setup, Teardown

- (void)setUp {
    self.statusChangeDelegate = [MockStatusChangeDelegate new];
    self.incomingMessageDelegate = [MockIncomingMessageDelegate new];

    NSError *error = nil;
    self.transport = [[TransportMock alloc]
                      initWithSignalStatusChangeDelegate:self.statusChangeDelegate
                      signalSendToResultDelegate:nil
                      signalIncomingMessageDelegate:self.incomingMessageDelegate
                      error:&error];
    XCTAssertNotNil(self.transport);
    XCTAssertNil(error);

    error = nil;
    self.transport.startupShouldSucceed = YES;
    PEPTransportStatusCode statusCode;
    BOOL success = [self.transport startupWithTransportStatusCode:&statusCode error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);

    NSArray *expectedStatus = @[[NSNumber numberWithInteger:PEPTransportStatusCodeConnectionUp]];
    XCTAssertEqualObjects(self.statusChangeDelegate.statusChanges, expectedStatus);
}

- (void)tearDown {
    NSError *error = nil;
    PEPTransportStatusCode statusCode;
    BOOL success = [self.transport shutdownWithTransportStatusCode:&statusCode error:&error];
    XCTAssertTrue(success);
    NSArray *expectedStatus = @[[NSNumber numberWithInteger:PEPTransportStatusCodeConnectionUp],
                                [NSNumber numberWithInteger:PEPTransportStatusCodeConnectionDown]];
    XCTAssertEqualObjects(self.statusChangeDelegate.statusChanges, expectedStatus);
}

#pragma mark - Tests

- (void)testSuccessfulStartupAndShutdown {
    // Basically handled by setUp and tearDown.
}

- (void)testStartupDirectError {
    // Use local variables, note that there was already a successful startup in setUp,
    // that we simply ignore.

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

@end
