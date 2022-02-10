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
    return [self severityFromStatusCode:statusCode] == 0x80;
}

@end
