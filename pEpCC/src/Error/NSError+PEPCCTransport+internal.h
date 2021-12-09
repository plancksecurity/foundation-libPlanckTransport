//
//  NSError+PEPCCTransport+internal.h
//  pEpCC_macOS
//
//  Created by Andreas Buff on 17.08.21.
//

#import <Foundation/Foundation.h>

#import "PEPObjCTypes.h"
#import "PEPTransportStatusCode.h"

NS_ASSUME_NONNULL_BEGIN

 /// Extension for creating `NSError`s from status codes
@interface NSError (Internal)
//
///// Figures out whether or not a given status is indicating an error condition.
///// @param status status to check if it's indicating an error condition.
///// @return YES if the status is indicating an error condition, NO otherwize.
//+ (BOOL)isErrorPEPStatus:(PEP_STATUS)status;
//
//
///// Figures out whether or not a given status indicates an error condition and returns an NSError
///// object representing the error if so.
///// @param status status to create NSError from
///// @return NSError representing the error status if the status is considered an error,
/////         nil otherwize.
//+ (NSError * _Nullable)errorWithPEPStatus:(PEPStatus)status;

/// Figures out whether or not a given status code is indicating an error condition.
/// @param statusCode status code to check if it's considered an error
/// @return YES if the status code is considered an error, NO otherwize.
+ (BOOL)isErrorCCTransportStatusCode:(PEPTransportStatusCode)statusCode;

/// Figures out whether or not a given status indicates an error condition and returns an NSError object
/// representing the error if so.
/// @param statusCode status code to create NSError from
/// @return NSError representing the error status code if the status code is considered an error,
///         nil otherwize.
+ (NSError * _Nullable)errorWithPEPCCTransportStatusCode:(PEPTransportStatusCode)statusCode;
//
///// If the status indicates an error condition, the given [NS]error is updated to represent the
///// error status.
///// If not, nothing is done.
///// @param error error to update according to status
///// @param status status to update error with
///// @return YES if the error object was updated, NO otherwise.
//+ (BOOL)setError:(NSError * _Nullable * _Nullable)error fromPEPStatus:(PEPStatus)status;
//
///// If the status code indicates an error condition, the given [NS]error is updated to represent the
///// error status.
///// If not, nothing is done.
///// @param error error to update according to status code
///// @param statusCode status code to update error with
///// @return YES if the error object was updated, NO otherwise.
//+ (BOOL)setError:(NSError * _Nullable * _Nullable)error fromPEPCCStatusCode:(PEPTransportStatusCode)statusCode;

@end

NS_ASSUME_NONNULL_END
