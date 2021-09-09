//
//  PEPSCTPTransportTests.m
//  PEPSCTPTransportTests
//
//  Created by Dirk Zimmermann on 08.09.21.
//

#import <XCTest/XCTest.h>

#import "PEPSCTPTransport.h"
#import "TestConstants.h"

@interface PEPSCTPTransportTests : XCTestCase

@end

@implementation PEPSCTPTransportTests

- (void)testStartupWithoutConfigLeadsToError
{
    NSError *error = nil;
    PEPSCTPTransport *transport = [[PEPSCTPTransport alloc]
                                   initWithSignalStatusChangeDelegate:nil
                                   signalSendToResultDelegate:nil
                                   signalIncomingMessageDelegate:nil
                                   callbackExecutionType:PEPTransportCallbackExcecutionTypePolling
                                   error:&error];

    XCTAssertNil(error);

    PEPTransportStatusCode statusCode = 0;
    [transport startup:NULL transportStatusCode:&statusCode error:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(statusCode, PEPTransportStatusCodeConnectionNoConfig);
}

@end
