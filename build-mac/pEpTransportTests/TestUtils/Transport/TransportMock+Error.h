//
//  TransportMock+Error.h
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 02.02.22.
//

#import <Foundation/Foundation.h>

#import "TransportMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface TransportMock (Error)

- (NSError *)errorWithTransportStatusCode:(PEPTransportStatusCode)statusCode;

@end

NS_ASSUME_NONNULL_END
