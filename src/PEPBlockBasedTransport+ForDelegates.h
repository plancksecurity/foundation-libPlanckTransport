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

@property (nonatomic, nullable) PEPTransportStatusCallbacks *startupCallback;
@property (nonatomic, nullable) PEPTransportStatusCallbacks *shutdownCallback;

/// Finds the callbacks for a given message ID and removes them.
/// @return The message callbacks (error and success), if any, defined for the given message ID.
- (PEPTransportStatusCallbacks * _Nullable)findAndRemoveCallbacksForMessageID:(NSString *)messageID;

/// Signals an incoming message to the delegate.
- (void)signalIncomingMessageFromDelegateWithTransportID:(PEPTransportID)transportID
                                              statusCode:(PEPTransportStatusCode)statusCode;
@end

NS_ASSUME_NONNULL_END

#endif /* PEPBlockBasedTransport_ForDelegates_h */
