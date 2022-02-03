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
/// that need to use, e.g., instance variables of the class, that by nature can only be defined
/// in the class itself.
@interface PEPBlockBasedTransport (ForDelegates)

/// Shadows the definition in the class extension, in order to give the delegate acces to this instance variable.
@property (nonatomic, nullable) PEPTransportStatusCallbacks *startupCallback;

/// Shadows the definition in the class extension, in order to give the delegate acces to this instance variable.
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
