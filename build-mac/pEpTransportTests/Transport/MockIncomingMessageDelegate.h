//
//  MockIncomingMessageDelegate.h
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import <Foundation/Foundation.h>

#import "PEPTransportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MockIncomingMessageDelegate : NSObject <PEPTransportIncomingMessageDelegate>

@property (nonatomic) BOOL messageIsAvailable;

@end

NS_ASSUME_NONNULL_END
