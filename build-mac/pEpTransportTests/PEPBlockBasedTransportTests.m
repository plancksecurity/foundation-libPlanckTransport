//
//  PEPBlockBasedTransportTests.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 28.01.22.
//

#import <XCTest/XCTest.h>

#import "PEPBlockBasedTransport.h"
#import "TransportMock.h"
#import "MockBlockBasedTransportDelegate.h"
#import "TestUtils.h"
#import "PEPObjCTypes.h"

@interface PEPBlockBasedTransportTests : XCTestCase

@property (nonatomic) TransportMock *transport;
@property (nonatomic) MockBlockBasedTransportDelegate *transportDelegate;
@property (nonatomic) PEPBlockBasedTransport *blockTransport;

@end

@implementation PEPBlockBasedTransportTests

#pragma mark - Setup, Teardown

- (void)setUp {
    NSError *error = nil;
    self.transport = [[TransportMock alloc]
                      initWithSignalStatusChangeDelegate:nil
                      signalSendToResultDelegate:nil
                      signalIncomingMessageDelegate:nil
                      error:&error];
    XCTAssertNotNil(self.transport);
    XCTAssertNil(error);

    self.transportDelegate = [MockBlockBasedTransportDelegate new];

    self.blockTransport = [[PEPBlockBasedTransport alloc]
                           initWithTransport:self.transport
                           transportDelegate:self.transportDelegate];

    XCTestExpectation *expStartup = [self expectationWithDescription:@"expStartup"];
    [self.blockTransport startupWithOnSuccess:^(PEPTransportStatusCode statusCode) {
        [expStartup fulfill];
    } onError:^(PEPTransportStatusCode statusCode, NSError * _Nonnull error) {
        [expStartup fulfill];
        XCTFail();
    }];

    [self waitForExpectations:@[expStartup] timeout:TestUtilsDefaultTimeout];
}

- (void)tearDown {
    XCTestExpectation *expShutdown = [self expectationWithDescription:@"expShutdown"];
    [self.blockTransport shutdownOnSuccess:^(PEPTransportStatusCode statusCode) {
        [expShutdown fulfill];
    } onError:^(PEPTransportStatusCode statusCode, NSError * _Nonnull error) {
        XCTFail();
        [expShutdown fulfill];
    }];

    [self waitForExpectations:@[expShutdown] timeout:TestUtilsDefaultTimeout];
}

#pragma mark - Tests

- (void)testSuccessfulStartupAndShutdown {
    // Basically handled by setUp and tearDown,
    // covers the simplest possible startup and shutdown without issues.
}

- (void)testStartupWithDirectError {
    PEPTransportStatusCode expectedStatusCode = PEPTransportStatusCodeConnectionDown;

    NSError *error = nil;
    TransportMock *transport = [[TransportMock alloc]
                                initWithSignalStatusChangeDelegate:nil
                                signalSendToResultDelegate:nil
                                signalIncomingMessageDelegate:nil
                                error:&error];
    XCTAssertNotNil(transport);
    XCTAssertNil(error);
    transport.directStartupStatusCode = [NSNumber numberWithInteger:expectedStatusCode];

    self.transportDelegate = [MockBlockBasedTransportDelegate new];

    PEPBlockBasedTransport *blockTransport = [[PEPBlockBasedTransport alloc]
                                              initWithTransport:transport
                                              transportDelegate:self.transportDelegate];

    XCTestExpectation *expStartup = [self expectationWithDescription:@"expStartup"];
    [blockTransport startupWithOnSuccess:^(PEPTransportStatusCode statusCode) {
        [expStartup fulfill];
        XCTFail();
    } onError:^(PEPTransportStatusCode statusCode, NSError * _Nonnull error) {
        XCTAssertEqual(statusCode, expectedStatusCode);
        [expStartup fulfill];
    }];

    [self waitForExpectations:@[expStartup] timeout:TestUtilsDefaultTimeout];
}

- (void)testStartupWithDelayedError {
    PEPTransportStatusCode expectedStatusCode = PEPTransportStatusCodeConnectionDown;

    NSError *error = nil;
    TransportMock *transport = [[TransportMock alloc]
                                initWithSignalStatusChangeDelegate:nil
                                signalSendToResultDelegate:nil
                                signalIncomingMessageDelegate:nil
                                error:&error];
    XCTAssertNotNil(transport);
    XCTAssertNil(error);
    transport.delayedStartupStatusCode = [NSNumber numberWithInteger:expectedStatusCode];

    self.transportDelegate = [MockBlockBasedTransportDelegate new];

    PEPBlockBasedTransport *blockTransport = [[PEPBlockBasedTransport alloc]
                                              initWithTransport:transport
                                              transportDelegate:self.transportDelegate];

    XCTestExpectation *expStartup = [self expectationWithDescription:@"expStartup"];
    [blockTransport startupWithOnSuccess:^(PEPTransportStatusCode statusCode) {
        [expStartup fulfill];
        XCTFail();
    } onError:^(PEPTransportStatusCode statusCode, NSError * _Nonnull error) {
        XCTAssertEqual(statusCode, expectedStatusCode);
        [expStartup fulfill];
    }];

    [self waitForExpectations:@[expStartup] timeout:TestUtilsDefaultTimeout];
}

- (void)testSendMessageImmediateError {
    PEPTransportStatusCode expectedStatusCode = PEPTransportStatusCodeConnectionDown;
    self.transport.directMessageSendStatusCode = [NSNumber numberWithInteger:expectedStatusCode];

    PEPIdentity *to = [[PEPIdentity alloc] initWithAddress:@"blarg1@home"];
    PEPMessage *msg = [PEPMessage new];
    msg.messageID = @"blarg11";
    msg.to = @[to];

    XCTestExpectation *expMessageSent = [self expectationWithDescription:@"expMessageSent"];
    [self.blockTransport sendMessage:msg
                      withPEPSession:nil
                           onSuccess:^(PEPTransportStatusCode statusCode) {
        XCTFail();
        [expMessageSent fulfill];
    } onError:^(PEPTransportStatusCode statusCode, NSError * _Nonnull error) {
        XCTAssertEqual(statusCode, expectedStatusCode);
        [expMessageSent fulfill];
    }];

    [self waitForExpectations:@[expMessageSent] timeout:TestUtilsDefaultTimeout];
}

- (void)testSendMessageDelayedError {
    PEPTransportStatusCode expectedStatusCode = PEPTransportStatusCodeSomeRecipientsUnreachable;
    self.transport.delayedMessageSendStatusCode = [NSNumber numberWithInteger:expectedStatusCode];

    PEPIdentity *to = [[PEPIdentity alloc] initWithAddress:@"blarg1@home"];
    PEPMessage *msg = [PEPMessage new];
    msg.messageID = @"blarg11";
    msg.to = @[to];

    XCTestExpectation *expMessageSent = [self expectationWithDescription:@"expMessageSent"];
    [self.blockTransport sendMessage:msg
                      withPEPSession:nil
                           onSuccess:^(PEPTransportStatusCode statusCode) {
        XCTFail();
        [expMessageSent fulfill];
    } onError:^(PEPTransportStatusCode statusCode, NSError * _Nonnull error) {
        XCTAssertEqual(statusCode, expectedStatusCode);
        [expMessageSent fulfill];
    }];

    [self waitForExpectations:@[expMessageSent] timeout:TestUtilsDefaultTimeout];
}

- (void)testSendMessageDelayedSuccess {
    PEPTransportStatusCode expectedStatusCode = PEPTransportStatusCodeMessageDelivered;
    self.transport.delayedMessageSendStatusCode = [NSNumber numberWithInteger:expectedStatusCode];

    PEPIdentity *to = [[PEPIdentity alloc] initWithAddress:@"blarg1@home"];
    PEPMessage *msg = [PEPMessage new];
    msg.messageID = @"blarg11";
    msg.to = @[to];

    XCTestExpectation *expMessageSent = [self expectationWithDescription:@"expMessageSent"];
    [self.blockTransport sendMessage:msg
                      withPEPSession:nil
                           onSuccess:^(PEPTransportStatusCode statusCode) {
        XCTAssertEqual(statusCode, expectedStatusCode);
        [expMessageSent fulfill];
    } onError:^(PEPTransportStatusCode statusCode, NSError * _Nonnull error) {
        XCTFail();
        [expMessageSent fulfill];
    }];

    [self waitForExpectations:@[expMessageSent] timeout:TestUtilsDefaultTimeout];
}

- (void)testGeneralProblems {
    XCTestExpectation *expConnectionStopped = [self expectationWithDescription:@"expConnectionStopped"];
    self.transportDelegate.expConnectionStopped = expConnectionStopped;

    PEPTransportStatusCode expectedStatusCode = PEPTransportStatusCodeNetworkTimeout;
    [self.transport pushStatusChange:expectedStatusCode];

    [self waitForExpectations:@[expConnectionStopped] timeout:TestUtilsDefaultTimeout];

    XCTAssertEqual(self.transportDelegate.lastConnectionStoppedStatusCode, expectedStatusCode);
}

@end
