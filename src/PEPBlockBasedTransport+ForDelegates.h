//
//  PEPBlockBasedTransport+ForDelegates.h
//  pEpTransport
//
//  Created by Dirk Zimmermann on 31.01.22.
//

#ifndef PEPBlockBasedTransport_ForDelegates_h
#define PEPBlockBasedTransport_ForDelegates_h

#import "PEPTransportStatusCallbacks.h"

NS_ASSUME_NONNULL_BEGIN

/// The interface that is used by the various delegate implementations (in class extensions),
/// that need to call back into the mothersip, that is to say, the internal interface for delegates.
///
/// @note These are methods that must be defined in the main compilation unit of PEPBlockBasedTransport
/// since they use internal instance variables. Otherwise a pure class-extension could have been used.
@interface PEPBlockBasedTransport (ForDelegates)

/// Tries to find pending startup callbacks and informs them of the given status code, marking it as a success.
/// @return `YES` if at least one callback was invoked, `NO` otherwise.
- (BOOL)invokePendingStartCallbackWithStatusCode:(PEPTransportStatusCode)statusCode;

/// Tries to find pending shutdown callbacks and informs them of the given status code, marking it as a success.
/// @return `YES` if at least one callback was invoked, `NO` otherwise.
- (BOOL)invokePendingShutdownCallbackWithStatusCode:(PEPTransportStatusCode)statusCode;

/// @return The message callbacks (error and success), if any, defined for the given message ID.
- (PEPTransportStatusCallbacks * _Nullable)callbacksForMessageID:(NSString *)messageID;

@end

NS_ASSUME_NONNULL_END

#endif /* PEPBlockBasedTransport_ForDelegates_h */
