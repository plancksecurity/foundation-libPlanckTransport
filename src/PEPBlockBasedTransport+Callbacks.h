//
//  PEPBlockBasedTransport+Callbacks.h
//  pEpTransport
//
//  Created by Dirk Zimmermann on 31.01.22.
//

#ifndef PEPBlockBasedTransport_Callbacks_h
#define PEPBlockBasedTransport_Callbacks_h

NS_ASSUME_NONNULL_BEGIN

/// The interface that is used by the various delegate implementations (in class extensions),
/// that need to call back into the mothersip.
@interface PEPBlockBasedTransport (Callbacks)

/// Tries to find pending startup callbacks and informs them of the given status code, marking it as a success.
- (void)invokePendingStartSuccessCallbacksWithStatusCode:(PEPTransportStatusCode)statusCode;

@end

NS_ASSUME_NONNULL_END

#endif /* PEPBlockBasedTransport_Callbacks_h */
