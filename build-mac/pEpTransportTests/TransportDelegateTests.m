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
    PEPTransportStatusCode statusCode;
    BOOL success = [self.transport startupWithTransportStatusCode:&statusCode error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);
}

- (void)tearDown {
    NSError *error = nil;
    PEPTransportStatusCode statusCode;

    XCTestExpectation *expShutDown = [self expectationWithDescription:@"expShutDown"];
    self.statusChangeDelegate.expectationStatusChanged = expShutDown;

    BOOL success = [self.transport shutdownWithTransportStatusCode:&statusCode error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);
    XCTAssertEqual(statusCode, PEPTransportStatusCodeReady);

    [self waitForExpectations:@[expShutDown] timeout:TestUtilsDefaultTimeout];

    NSArray *expectedStatus = @[[NSNumber numberWithInteger:PEPTransportStatusCodeConnectionDown]];
    XCTAssertEqualObjects(self.statusChangeDelegate.statusChanges, expectedStatus);
}

#pragma mark - Tests

- (void)testSuccessfulStartupAndShutdown {
    // Basically handled by setUp and tearDown.
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

    // Make it fail directly on startup.
    PEPTransportStatusCode errorCode = PEPTransportStatusCodeConnectionDown;
    transport.directStartupStatusCode = [NSNumber numberWithInteger:errorCode];

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

/// Immediate startup looks good/neutral, error comes asynchronously via delegate.
/// Note that from the view of the used mock it doesn't matter if the delayed response is an error status
/// code or success, the test sets the desired response.
- (void)testStartupDelayedError {
    MockStatusChangeDelegate *statusChangeDelegate = [MockStatusChangeDelegate new];
    XCTestExpectation *expectationStatusChanged = [self expectationWithDescription:@"expectationStatusChange"];
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
    transport.delayedStartupStatusCode = [NSNumber numberWithInteger:errorCode];

    PEPTransportStatusCode statusCode;
    BOOL success = [transport startupWithTransportStatusCode:&statusCode error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);
    XCTAssertEqual(statusCode, PEPTransportStatusCodeReady);

    [self waitForExpectations:@[expectationStatusChanged] timeout:TestUtilsDefaultTimeout];

    NSArray *expectedStatus = @[[NSNumber numberWithInteger:errorCode]];
    XCTAssertEqualObjects(statusChangeDelegate.statusChanges, expectedStatus);
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
