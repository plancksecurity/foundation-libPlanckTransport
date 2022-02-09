//
//  PEPTransportStatusCodeUtil.h
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 31.01.22.
//

#import <Foundation/Foundation.h>

#import "PEPTransportStatusCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPTransportStatusCodeUtil : NSObject

/// Is the given status code an error?
/// @return `YES` if  the given status code is an error, `NO` if it isn't.
+ (BOOL)isErrorStatusCode:(PEPTransportStatusCode)statusCode;

@end

NS_ASSUME_NONNULL_END
