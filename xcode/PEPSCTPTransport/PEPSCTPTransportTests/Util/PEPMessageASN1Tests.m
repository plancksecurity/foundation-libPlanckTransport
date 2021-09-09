//
//  PEPMessageASN1Tests.m
//  pEpCCTests
//
//  Created by Dirk Zimmermann on 26.08.21.
//

#import <XCTest/XCTest.h>

#import "PEPMessage+ASN1.h"
#import "PEPIdentity.h"
#import "PEPMessage+SecureCoding.h"

@interface PEPMessageASN1Tests : XCTestCase

@end

@implementation PEPMessageASN1Tests

/// Encodes and decodes a "minimal" message, that is a message with the minimum amount of data
/// needed to get encoded/decoded.
- (void)testBasicAsn1EncodeDecodeRoundTripMinimalMessage
{
    PEPIdentity *fromId = [[PEPIdentity alloc]
                           initWithAddress:@"someone1@example.com"
                           userID:@"1"
                           userName:@"Some One 1"
                           isOwn:NO];
    fromId.fingerPrint = @"0E12343434343434343434EAB3484343434343434";

    PEPIdentity *toId = [[PEPIdentity alloc]
                         initWithAddress:@"someone2@example.com"
                         userID:@"2"
                         userName:@"Some One 2"
                         isOwn:NO];
    toId.fingerPrint = @"123434343434343C3434343434343734349A34344";

    PEPMessage *msg1 = [PEPMessage new];
    msg1.from = fromId;
    msg1.to = @[toId];

    NSData *blob = [msg1 asn1Data];
    XCTAssertNotNil(blob);

    PEPMessage *msg2 = [PEPMessage messageFromAsn1Data:blob];
    XCTAssertNotNil(msg2);

    XCTAssertEqualObjects(msg1, msg2);
}

@end
