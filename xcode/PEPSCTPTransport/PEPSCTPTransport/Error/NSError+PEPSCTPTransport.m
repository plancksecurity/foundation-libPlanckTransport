//
//  NSError+PEPSCTPTransport.m
//  pEpCC_macOS
//
//  Created by Andreas Buff on 16.08.21.
//
#import <Foundation/Foundation.h>
#import "NSError+PEPSCTPTransport.h"
#import "NSError+PEPSCTPTransport+internal.h"
#import "NSError+PEPStatus.h"

NSString *const _Nonnull PEPEngineStatusErrorDomain = @"PEPCCEngineStatusErrorDomain";
NSString *const _Nonnull PEPTransportStatusStatusErrorDomain = @"PEPCCTransportStatusStatusErrorDomain";
NSString *const _Nonnull PEPErrorDomain = @"PEPCCErrorDomain";

@implementation NSError (PEPSCTPTransport)

// MARK: - API

+ (BOOL)isErrorPEPStatus:(PEP_STATUS)status {
    switch (status) {
        case PEP_ILLEGAL_VALUE:
        case PEP_OUT_OF_MEMORY: {
            return YES;
            break;
        }
        default: {
            return NO;
            break;
        }
    }
}

+ (NSError * _Nullable)errorWithPEPStatus:(PEP_STATUS)status
{
    if ([self isErrorPEPStatus:status]) {
        NSDictionary *dict = [NSDictionary
                              dictionaryWithObjectsAndKeys:localizedErrorStringFromPEPStatus(status),
                              NSLocalizedDescriptionKey, nil];
        return [NSError errorWithDomain:PEPEngineStatusErrorDomain
                                   code:status
                               userInfo:dict];
    } else {
        return nil;
    }
}

+ (BOOL)isErrorTransportStatusCode:(PEPTransportStatusCode)statusCode
{
    switch (statusCode) {
            // Status that are not an error
        case PEPTransportStatusCodeReady:
        case PEPTransportStatusCodeMessageDelivered:
        case PEPTransportStatusCodeMessageOnTheWay:
        case PEPTransportStatusCodeCouldNotDeliver_Resending:
        {
            return NO;
            break;
        }
        default:
        {
            return YES;
            break;
        }
    }
}

+ (NSError * _Nullable)errorWithPEPTransportStatusCode:(PEPTransportStatusCode)statusCode
{
    if ([self isErrorTransportStatusCode:statusCode]) {
        NSDictionary *dict = [NSDictionary
                              dictionaryWithObjectsAndKeys:localizedErrorStringFromPEPTransportStatusCode(statusCode),
                              NSLocalizedDescriptionKey, nil];
        return [NSError
                errorWithDomain:PEPTransportStatusStatusErrorDomain
                code:statusCode
                userInfo:dict];
    } else {
        return nil;
    }
}

+ (BOOL)setError:(NSError * _Nullable * _Nullable)error fromPEPStatus:(PEPStatus)status
{
    // Determine if the given status is an error.
    NSError *errorFromStatus = [self errorWithPEPStatus:status];

    // Set caller's error, if given
    if (error) {
        *error = errorFromStatus;
    }

    // Indicate error status.
    if (errorFromStatus) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)setError:(NSError * _Nullable * _Nullable)error fromPEPStatusCode:(PEPTransportStatusCode)statusCode
{
    // Determine if the given status is an error.
    NSError *errorFromStatusCode = [self errorWithPEPTransportStatusCode:statusCode];

    // Set caller's error, if given
    if (error) {
        *error = errorFromStatusCode;
    }

    // Indicate error status.
    return errorFromStatusCode ? YES : NO;
}

/// Could in theory return a fully localized version of the underlying error.
NSString * _Nonnull localizedErrorStringFromPEPTransportStatusCode(PEPTransportStatusCode status) {
    return stringFromPEPTransportStatusCode(status);
}

NSString * _Nonnull stringFromPEPTransportStatusCode(PEPTransportStatusCode status) {
    return [NSString stringWithFormat:@"PEPCCTransportStatusCode: %ld", (long)status];
}

- (NSString * _Nullable)pEpErrorString
{
    if ([self.domain isEqualToString:PEPEngineStatusErrorDomain]) {
        return stringFromPEPStatus((PEP_STATUS) self.code);
    } else {
        return nil;
    }
}

@end
