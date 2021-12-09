//
//  main.m
//  TestMirrorRPCClient_macOS
//
//  Created by Andreas Buff on 06.12.21.
//

#import <Foundation/Foundation.h>

#import "PEPRPCTransportTestConnector.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        PEPRPCTransportTestConnector *connector = [PEPRPCTransportTestConnector new];
        [connector start];

        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop run];
    }
    return 0;
}
