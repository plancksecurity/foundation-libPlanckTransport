//
//  PEPBlockBasedTransport+IncomingMessageDelegate.h
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 03.02.22.
//

#import <Foundation/Foundation.h>

#import "PEPBlockBasedTransport.h"
#import "PEPTransportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPBlockBasedTransport (IncomingMessageDelegate) <PEPTransportIncomingMessageDelegate>

@end

NS_ASSUME_NONNULL_END
