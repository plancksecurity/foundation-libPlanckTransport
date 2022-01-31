//
//  PEPBlockBasedTransport+PEPTransportStatusChangeDelegate.h
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 28.01.22.
//

#import <Foundation/Foundation.h>

#import "PEPBlockBasedTransport.h"
#import "PEPTransportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPBlockBasedTransport (PEPTransportStatusChangeDelegate) <PEPTransportStatusChangeDelegate>

@end

NS_ASSUME_NONNULL_END
