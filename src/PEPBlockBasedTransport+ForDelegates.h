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

/// Instance variable declared in the class that need to be accessed by delegates, implemented in category extensions.
///
/// @note All instance variables declared here shadow the real ones declared in the class itself.
@interface PEPBlockBasedTransport (ForDelegates)

@property (nonatomic, nonnull, readonly) id<PEPTransportProtocol> transport;
@property (nonatomic, nonnull, readonly) id<PEPBlockBasedTransportDelegate> transportDelegate;
@property (nonatomic, nonnull, readonly) NSMutableSet<PEPTransportStatusCallbacks *> *startupCallbacks;
@property (nonatomic, nonnull,readonly) NSMutableSet<PEPTransportStatusCallbacks *> *shutdownCallbacks;
@property (nonatomic, nonnull, readonly) NSMutableDictionary<NSString *, PEPTransportStatusCallbacks *> *messageCallbacks;

@end

NS_ASSUME_NONNULL_END

#endif /* PEPBlockBasedTransport_ForDelegates_h */
