//
//  MockStatusChangeDelegate.h
//  pEpTransportTests
//
//  Created by Dirk Zimmermann on 26.01.22.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "PEPTransportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MockStatusChangeDelegate : NSObject <PEPTransportStatusChangeDelegate>

/// An (optional) expectation that will be fired _every time_ the status changes.
/// @note Make sure its fulfillment count matches the expectations in case of multiple firings.
@property (nonatomic, nullable) XCTestExpectation *expectationStatusChanged;

/// The last `PEPTransportStatusCode`s from the transport.
@property (nonatomic) NSArray<NSNumber *> *statusChanges;

- (instancetype)initWithStatusChangedExpectation:(XCTestExpectation * _Nullable)expectationStatusChanged;

@end

NS_ASSUME_NONNULL_END
