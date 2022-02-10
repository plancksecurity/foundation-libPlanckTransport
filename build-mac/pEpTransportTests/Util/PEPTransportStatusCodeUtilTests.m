//
//  PEPTransportStatusCodeUtilTests.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 10.02.22.
//

#import <XCTest/XCTest.h>

#import "PEPTransportStatusCodeUtil.h"

@interface PEPTransportStatusCodeUtilTests : XCTestCase

@end

@implementation PEPTransportStatusCodeUtilTests

- (void)testSeverity {
    XCTAssertEqual([PEPTransportStatusCodeUtil
                    severityFromStatusCode:PEPTransportStatusCodeConnectionDown],
                   0x80);
    XCTAssertEqual([PEPTransportStatusCodeUtil
                    severityFromStatusCode:PEPTransportStatusCodeRxQueueUnderrun],
                   0x80);
    XCTAssertEqual([PEPTransportStatusCodeUtil
                    severityFromStatusCode:PEPTransportStatusCodeShutDown],
                   0xff);
    XCTAssertEqual([PEPTransportStatusCodeUtil
                    severityFromStatusCode:PEPTransportStatusCodeMessageOnTheWay],
                   0x00);
}

@end
