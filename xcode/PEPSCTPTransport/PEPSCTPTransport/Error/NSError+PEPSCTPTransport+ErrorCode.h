//
//  NSError+PEPSCTPTransport+ErrorCode.h
//  pEpCC_macOS
//
//  Created by Andreas Buff on 17.08.21.
//

#import <Foundation/Foundation.h>

#pragma mark - PEPCC Errors (error codes)

/// Possible errors from adapter without involvement from the engine.
typedef NS_CLOSED_ENUM(NSInteger, PEPSCTPTransportError) {
    /// The priviced URL scheme is not supported.
    PEPCCErrorUnsupportedURLScheme = 0
};

