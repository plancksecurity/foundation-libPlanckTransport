//
//  PEPBlockBasedTransport+Error.h
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 02.02.22.
//

#import <Foundation/Foundation.h>

#import "PEPBlockBasedTransport.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPBlockBasedTransport (Error)

/// Creates an error from a status code, with the matching domain.
- (NSError *)errorWithTransportStatusCode:(PEPTransportStatusCode)statusCode;

@end

NS_ASSUME_NONNULL_END
