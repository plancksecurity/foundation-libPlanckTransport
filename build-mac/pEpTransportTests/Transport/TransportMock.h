//
//  TransportMock.h
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import <Foundation/Foundation.h>

#import "PEPTransportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// A mock of `PEPTransportProtocol`.
@interface TransportMock : NSObject <PEPTransportProtocol>

/// If this is `NO`, startup will simulate a failure.
@property (nonatomic) BOOL startupShouldSucceed;

@end

NS_ASSUME_NONNULL_END
