//
//  PEPTransportStatusCodeUtil.h
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 31.01.22.
//

#import <Foundation/Foundation.h>

#import "PEPTransportStatusCode.h"

NS_ASSUME_NONNULL_BEGIN

/// @see https://dev.pep.foundation/Engine/TransportStatusCode
@interface PEPTransportStatusCodeUtil : NSObject

/// @retun The severity octet of the given status code.
+ (NSUInteger)severityFromStatusCode:(PEPTransportStatusCode)statusCode;

/// Is the given status code an error?
/// @note A transport emitting this is supposed to "heal itself".
/// @return `YES` if  the given status code is an error, `NO` if it isn't.
+ (BOOL)isErrorStatusCode:(PEPTransportStatusCode)statusCode;

/// Is the given status code a critical error?
/// @note A transport emitting this is _not_ supposed to be able to "heal itself".
/// @return `YES` if  the given status code is a critical error, `NO` if it isn't.
+ (BOOL)isCriticalErrorStatusCode:(PEPTransportStatusCode)statusCode;

@end

NS_ASSUME_NONNULL_END
