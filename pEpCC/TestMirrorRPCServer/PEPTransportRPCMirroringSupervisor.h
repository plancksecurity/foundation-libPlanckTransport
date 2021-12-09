//
//  PEPTransportRPCMirroringSupervisor.h
//  TestMirrorRPCServer_macOS
//
//  Created by Andreas Buff on 29.11.21.
//

#import <Foundation/Foundation.h>

#import <pEpIPsecRPCObjCAdapter.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPTransportRPCMirroringSupervisor : NSObject <PEPRPCSupervisorIPSecDelegate, PEPRPCSupervisorTransportDelegate>

-(void)start;

@end

NS_ASSUME_NONNULL_END
