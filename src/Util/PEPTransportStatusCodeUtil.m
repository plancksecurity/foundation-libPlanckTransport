//
//  PEPTransportStatusCodeUtil.m
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 31.01.22.
//

#import "PEPTransportStatusCodeUtil.h"

@implementation PEPTransportStatusCodeUtil

+ (BOOL)isErrorStatusCode:(PEPTransportStatusCode)statusCode {
    // Treat a set 0x00800000 as an error
    return (statusCode & 0x00800000) != 0;
}

+ (BOOL)isStartupErrorStatusCode:(PEPTransportStatusCode)statusCode {
    return [self isErrorStatusCode:statusCode];
}

+ (BOOL)isShutdownErrorStatusCode:(PEPTransportStatusCode)statusCode {
    // Treat all status codes as errors, except the shutdown one.
    return [self isErrorStatusCode:statusCode] &&
    statusCode != PEPTransportStatusCodeConnectionDown;
}

@end
