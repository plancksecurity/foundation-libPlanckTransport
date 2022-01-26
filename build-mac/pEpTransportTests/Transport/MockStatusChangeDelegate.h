//
//  MockStatusChangeDelegate.h
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import <Foundation/Foundation.h>

#import "PEPTransportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MockStatusChangeDelegate : NSObject <PEPTransportStatusChangeDelegate>

/// The last `PEPTransportStatusCode`s from the transport.
@property (nonatomic) NSArray<NSNumber *> *statusChanges;

@end

NS_ASSUME_NONNULL_END
