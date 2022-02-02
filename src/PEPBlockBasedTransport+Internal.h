//
//  PEPBlockBasedTransport+Internal.h
//  pEpTransport
//
//  Created by Dirk Zimmermann on 02.02.22.
//

#ifndef PEPBlockBasedTransport_Internal_h
#define PEPBlockBasedTransport_Internal_h

NS_ASSUME_NONNULL_BEGIN

/// Internally used methods.
@interface PEPBlockBasedTransport (Internal)

/// Tries to find pending startup callbacks and informs them of the given status code, marking it as a success.
/// @return `YES` if at least one callback was invoked, `NO` otherwise.
- (BOOL)invokePendingStartCallbackWithStatusCode:(PEPTransportStatusCode)statusCode;

/// Tries to find pending shutdown callbacks and informs them of the given status code, marking it as a success.
/// @return `YES` if at least one callback was invoked, `NO` otherwise.
- (BOOL)invokePendingShutdownCallbackWithStatusCode:(PEPTransportStatusCode)statusCode;

@end

NS_ASSUME_NONNULL_END

#endif /* PEPBlockBasedTransport_Internal_h */
