//
//  pEpCCTests.m
//  pEpCCTests
//
//  Created by Andreas Buff on 17.08.21.
//

#import <XCTest/XCTest.h>

#import "PEPCC+Test.h"
#import "PEPSCTPTransportMock.h"
#import "PEPTransportConfig.h"
#import "PEPCCTestUtil.h"

@interface pEpCCTests : XCTestCase
@end

@implementation pEpCCTests

// MARK: - Configure

- (void)testPEPCCConfigure {
    id<PEPTransportProtocol> sCTPTransport = [PEPSCTPTransportMock new];
    id<PEPTransportProtocol> pEpCC = [[PEPCC alloc] initWithTransport:sCTPTransport];
    PEPTransportConfig *config = [PEPTransportConfig new];
    PEPTransportStatusCode status;
    NSError *error;

    XCTAssertTrue([pEpCC configure:nil withConfig:config transportStatusCode:&status error:&error]);
}

- (void)testPEPCCConfigureStatusCode {
    id<PEPTransportProtocol> sCTPTransport = [PEPSCTPTransportMock new];
    id<PEPTransportProtocol> pEpCC = [[PEPCC alloc] initWithTransport:sCTPTransport];
    PEPTransportConfig *config = [PEPTransportConfig new];
    PEPTransportStatusCode status;
    NSError *error;

    [pEpCC configure:nil withConfig:config transportStatusCode:&status error:&error];

    XCTAssertEqual(status, PEPTransportStatusCodeConnectionUp);
}

- (void)testPEPCCConfigureError {
    id<PEPTransportProtocol> sCTPTransport = [PEPSCTPTransportMock new];
    id<PEPTransportProtocol> pEpCC = [[PEPCC alloc] initWithTransport:sCTPTransport];
    PEPTransportConfig *config = [PEPTransportConfig new];
    PEPTransportStatusCode status;
    NSError *error;

    [pEpCC configure:nil withConfig:config transportStatusCode:&status error:&error];

    XCTAssertNotNil(error);
}

// MARK: - Start/Stop

- (void)testPEPCCStartup {
    id<PEPTransportProtocol> sCTPTransport = [PEPSCTPTransportMock new];
    id<PEPTransportProtocol> pEpCC = [[PEPCC alloc] initWithTransport:sCTPTransport];
    PEPTransportStatusCode status;
    NSError *error;

    XCTAssertTrue([pEpCC startup:nil transportStatusCode:&status error:&error]);
}

- (void)testPEPCCStartupStatusCode {
    id<PEPTransportProtocol> sCTPTransport = [PEPSCTPTransportMock new];
    id<PEPTransportProtocol> pEpCC = [[PEPCC alloc] initWithTransport:sCTPTransport];
    PEPTransportStatusCode status;
    NSError *error;

    [pEpCC startup:nil transportStatusCode:&status error:&error];

    XCTAssertEqual(status, PEPTransportStatusCodeConnectionUp);

}

- (void)testPEPCCStartupError {
    id<PEPTransportProtocol> sCTPTransport = [PEPSCTPTransportMock new];
    id<PEPTransportProtocol> pEpCC = [[PEPCC alloc] initWithTransport:sCTPTransport];
    PEPTransportStatusCode status;
    NSError *error;

    [pEpCC startup:nil transportStatusCode:&status error:&error];

    XCTAssertNotNil(error);
}

- (void)testPEPCCShutdown {
    id<PEPTransportProtocol> sCTPTransport = [PEPSCTPTransportMock new];
    id<PEPTransportProtocol> pEpCC = [[PEPCC alloc] initWithTransport:sCTPTransport];
    PEPTransportStatusCode status;
    NSError *error;

    XCTAssertFalse([pEpCC shutdown:nil transportStatusCode:&status error:&error]);
}

- (void)testPEPCCShutdownStatusCode {
    id<PEPTransportProtocol> sCTPTransport = [PEPSCTPTransportMock new];
    id<PEPTransportProtocol> pEpCC = [[PEPCC alloc] initWithTransport:sCTPTransport];
    PEPTransportStatusCode status;
    NSError *error;

    [pEpCC shutdown:nil transportStatusCode:&status error:&error];

    XCTAssertEqual(status, PEPTransportStatusCodeConnectionDown);

}

- (void)testPEPCCShutdownError {
    id<PEPTransportProtocol> sCTPTransport = [PEPSCTPTransportMock new];
    id<PEPTransportProtocol> pEpCC = [[PEPCC alloc] initWithTransport:sCTPTransport];
    PEPTransportStatusCode status;
    NSError *error;

    [pEpCC shutdown:nil transportStatusCode:&status error:&error];

    XCTAssertNotNil(error);
}

// MARK: - Message

- (void)testEncryptionDecryptionMessage {
    id<PEPTransportProtocol> sCTPTransport = [PEPSCTPTransportMock new];
    id<PEPTransportProtocol> pEpCC = [[PEPCC alloc] initWithTransport:sCTPTransport];
    __block PEPTransportStatusCode status;
    __block NSError *error;
    PEPMessage *message = [PEPCCTestUtil pEpMessageWithAllFieldsFilled];
    __block PEPMessage *testMessage;

    XCTestExpectation *encExp = [self expectationWithDescription:@"EncryptionDecription"];
    // Get background session
    dispatch_queue_t backgroundQueue = dispatch_queue_create("PEPSessionEncryptionTest.peptest1", 0);
    dispatch_async(backgroundQueue, ^{

        BOOL send = [pEpCC sendMessage:message pEpSession:nil transportStatusCode:&status error:&error];

        XCTAssertTrue(send);
        XCTAssertNil(error);

        testMessage = [pEpCC nextMessageWithPEPSession:nil transportStatusCode:&status error:&error];

        XCTAssertNotNil(testMessage);
        XCTAssertNil(error);

        [encExp fulfill];
    });

    [self waitForExpectationsWithTimeout:10000 handler:^(NSError * _Nullable error) {
        if (error) { XCTFail(@"timeout: %@", error); }
    }];
    
    XCTAssertEqualObjects(message.shortMessage, testMessage.shortMessage);
    XCTAssertEqualObjects(message.longMessage, testMessage.longMessage);
    XCTAssertEqualObjects(message.longMessageFormatted, testMessage.longMessageFormatted);
}

@end
