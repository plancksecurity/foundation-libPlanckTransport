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
}

- (void)tearDown {
}

#pragma mark - Tests

- (void)testSuccessfulStartupAndShutdown {
    // Basically handled by setUp and tearDown.
}

@end
