//
//  PEPBlockBasedTransport+PEPTransportStatusChangeDelegate.h
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 28.01.22.
//

#import <Foundation/Foundation.h>

#import "PEPBlockBasedTransport.h"
#import "PEPTransportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPBlockBasedTransport (PEPTransportStatusChangeDelegate) <PEPTransportStatusChangeDelegate>

/// Tries to find pending startup callbacks and informs them of the given status code, marking it as a success.
/// @return `YES` if there was a least one callback invoked, `NO` if there was none.
- (BOOL)invokePendingStartSuccessCallbacksWithStatusCode:(PEPTransportStatusCode)statusCode;

@end

NS_ASSUME_NONNULL_END
