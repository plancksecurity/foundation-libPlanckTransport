//
//  PEPBlockBasedTransport+Error.m
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 02.02.22.
//

#import "PEPBlockBasedTransport+Error.h"

/// PEPBlockBasedTransport error domain `NSError`s derived from a transport status code.
static NSString * const s_ErrorDomain = @"PEPBlockBasedTransportStatusCode";

@implementation PEPBlockBasedTransport (Error)

- (NSError *)errorWithTransportStatusCode:(PEPTransportStatusCode)statusCode {
    return [NSError errorWithDomain:s_ErrorDomain code:statusCode userInfo:nil];
}

@end
