//
//  NSError+PEPSCTPTransport.h
//  pEpCC_macOS
//
//  Created by Andreas Buff on 16.08.21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Domain for errors indicated by the pEp engine.
extern NSString *const _Nonnull PEPEngineStatusErrorDomain;

/// Domain for errors indicated by the SCTP transport (see transport.h)
extern NSString *const _Nonnull PEPTransportStatusStatusErrorDomain;

/// Domain for errors indicated by the PEPCC itself.
extern NSString *const _Nonnull PEPErrorDomain;

/**
 Extension for creating `NSError`s from `PEP_STATUS`
 */
@interface NSError (PEPSCTPTransport)

/**
 A possible string representation of the error code if this is a pEp error.
 @return A string representation of the pEp error code, if it's in the pEp domain.
 */
- (NSString * _Nullable)pEpErrorString;

@end

NS_ASSUME_NONNULL_END
