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
#import "TestUtils.h"

@interface TransportDelegateTests : XCTestCase

@property (nonatomic) MockStatusChangeDelegate *statusChangeDelegate;
@property (nonatomic) MockIncomingMessageDelegate *incomingMessageDelegate;
@property (nonatomic) TransportMock *transport;

@end

@implementation TransportDelegateTests

#pragma mark - Setup, Teardown

- (void)setUp1 {
    XCTestExpectation *expectationStatusChanged = [self expectationWithDescription:@"expectationStatusChange"];
    self.statusChangeDelegate = [MockStatusChangeDelegate new];
    self.statusChangeDelegate.expectationStatusChanged = expectationStatusChanged;

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
    PEPTransportStatusCode statusCode;
    BOOL success = [self.transport startupWithTransportStatusCode:&statusCode error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);

    [self waitForExpectations:@[expectationStatusChanged] timeout:TestUtilsDefaultTimeout];

    NSArray *expectedStatus = @[[NSNumber numberWithInteger:PEPTransportStatusCodeConnectionUp]];
    XCTAssertEqualObjects(self.statusChangeDelegate.statusChanges, expectedStatus);
}

- (void)tearDown1 {
    NSError *error = nil;
    PEPTransportStatusCode statusCode;

    // not interested in that for the successful shut down
    self.statusChangeDelegate.expectationStatusChanged = nil;

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

    // Make it fail directly on startup.
    PEPTransportStatusCode errorCode = PEPTransportStatusCodeConnectionDown;
    transport.directStartupErrorCode = [NSNumber numberWithInteger:errorCode];

    PEPTransportStatusCode statusCode;
    BOOL success = [transport startupWithTransportStatusCode:&statusCode error:&error];
    XCTAssertFalse(success);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, errorCode);
    XCTAssertEqual(statusCode, errorCode);
    XCTAssertEqual(statusChangeDelegate.statusChanges.count, 0);
    NSNumber *num = [statusChangeDelegate.statusChanges firstObject];
    XCTAssertNil(num);
}

- (void)testStartupDelayedError {
    // Use local variables, note that there was already a successful startup in setUp,
    // that we simply ignore.

    MockStatusChangeDelegate *statusChangeDelegate = [MockStatusChangeDelegate new];
    XCTestExpectation *expectationStatusChanged = [self expectationWithDescription:@"expectationStatusChange"];
    expectationStatusChanged.expectedFulfillmentCount = 2;
    statusChangeDelegate.expectationStatusChanged = expectationStatusChanged;

    NSError *error = nil;
    TransportMock *transport = [[TransportMock alloc]
                                initWithSignalStatusChangeDelegate:statusChangeDelegate
                                signalSendToResultDelegate:nil
                                signalIncomingMessageDelegate:nil
                                error:&error];
    XCTAssertNotNil(transport);
    XCTAssertNil(error);

    error = nil;

    PEPTransportStatusCode errorCode = PEPTransportStatusCodeConnectionDown;
    transport.delayedStartupErrorCode = [NSNumber numberWithInteger:errorCode];

    // Directly on return, all looks good

    PEPTransportStatusCode statusCode;
    BOOL success = [transport startupWithTransportStatusCode:&statusCode error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);
    XCTAssertEqual(statusCode, PEPTransportStatusCodeConnectionUp);

    [self waitForExpectations:@[expectationStatusChanged] timeout:TestUtilsDefaultTimeout];

    // But later connection problems appeared

    NSArray *expectedStatus = @[[NSNumber numberWithInteger:PEPTransportStatusCodeConnectionUp],
                                [NSNumber numberWithInteger:errorCode]];
    XCTAssertEqualObjects(self.statusChangeDelegate.statusChanges, expectedStatus);
}

- (void)testMessageReceived {
    NSString *subject = @"Some Subject";
    PEPMessage *msg = [[PEPMessage alloc] init];
    msg.shortMessage = subject;

    [self.transport pushReceivedMessage:msg];
    XCTAssertTrue(self.incomingMessageDelegate.messageIsAvailable);

    PEPTransportStatusCode statusCode;
    NSError *error = nil;
    PEPMessage *msg2 = [self.transport nextMessageWithPEPSession:nil
                                             transportStatusCode:&statusCode
                                                           error:&error];
    XCTAssertNotNil(msg2);
    XCTAssertNil(error);
    XCTAssertEqual(statusCode, PEPTransportStatusCodeConnectionUp);

    XCTAssertEqualObjects(msg, msg2);
}

- (void)testNoMessageReceived {
    XCTAssertFalse(self.incomingMessageDelegate.messageIsAvailable);

    PEPTransportStatusCode statusCode;
    NSError *error = nil;
    PEPMessage *msg = [self.transport nextMessageWithPEPSession:nil
                                            transportStatusCode:&statusCode
                                                          error:&error];
    XCTAssertNil(msg);
    XCTAssertNil(error);
    XCTAssertEqual(statusCode, PEPTransportStatusCodeConnectionUp);
}

@end
