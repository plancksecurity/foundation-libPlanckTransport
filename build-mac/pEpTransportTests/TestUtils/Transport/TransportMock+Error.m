//
//  TransportMock+Error.m
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 02.02.22.
//

#import "TransportMock+Error.h"

NSString *s_ErrorDomain = @"TransportMockErrorDomain";

@implementation TransportMock (Error)

- (NSError *)errorWithTransportStatusCode:(PEPTransportStatusCode)statusCode {
    return [NSError errorWithDomain:s_ErrorDomain code:statusCode userInfo:nil];
}

@end
