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

/// Class extension that is usable by the delegates, which are implemented as categories.
@interface PEPBlockBasedTransport ()

@property (nonatomic, nonnull) id<PEPTransportProtocol> transport;
@property (nonatomic, weak) id<PEPBlockBasedTransportDelegate> transportDelegate;
@property (nonatomic, nonnull) NSMutableSet<PEPTransportStatusCallbacks *> *startupCallbacks;
@property (nonatomic, nonnull) NSMutableSet<PEPTransportStatusCallbacks *> *shutdownCallbacks;

/// Callbacks for message send calls.
@property (nonatomic, nonnull) NSMutableDictionary<NSString *, PEPTransportStatusCallbacks *> *messageCallbacks;

@end

NS_ASSUME_NONNULL_END

#endif /* PEPBlockBasedTransport_ForDelegates_h */
