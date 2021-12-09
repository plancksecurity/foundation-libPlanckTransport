//
//  main.m
//  asdf
//
//  Created by Andreas Buff on 29.11.21.
//

#import <Foundation/Foundation.h>

#import "PEPTransportRPCMirroringSupervisor.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        PEPTransportRPCMirroringSupervisor *mirroringSupervsor = [PEPTransportRPCMirroringSupervisor new];
        [mirroringSupervsor start];
        
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop run];
    }
    return 0;
}
