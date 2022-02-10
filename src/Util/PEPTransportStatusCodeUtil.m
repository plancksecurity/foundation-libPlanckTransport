//
//  PEPTransportStatusCodeUtil.m
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 31.01.22.
//

#import "PEPTransportStatusCodeUtil.h"

@implementation PEPTransportStatusCodeUtil

+ (NSUInteger)severityFromStatusCode:(PEPTransportStatusCode)statusCode {
    return (statusCode >> 16) & 0xff;
}

+ (BOOL)isErrorStatusCode:(PEPTransportStatusCode)statusCode {
    // Treat a set bit of 0x00800000 as an error
    return (statusCode & 0x00800000) != 0;
}

@end
