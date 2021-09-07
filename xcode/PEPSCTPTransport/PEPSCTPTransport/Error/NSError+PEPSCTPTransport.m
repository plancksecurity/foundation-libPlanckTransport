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

NSString *const _Nonnull PEPCCEngineStatusErrorDomain = @"PEPCCEngineStatusErrorDomain";
NSString *const _Nonnull PEPCCTransportStatusStatusErrorDomain = @"PEPCCTransportStatusStatusErrorDomain";
NSString *const _Nonnull PEPCCErrorDomain = @"PEPCCErrorDomain";

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
        return [NSError errorWithDomain:PEPCCEngineStatusErrorDomain
                                   code:status
                               userInfo:dict];
    } else {
        return nil;
    }
}

+ (BOOL)isErrorCCTransportStatusCode:(PEPTransportStatusCode)statusCode {
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
        default: {
            return YES;
            break;
        }
    }
}

+ (NSError * _Nullable)errorWithPEPCCTransportStatusCode:(PEPTransportStatusCode)statusCode
{
    if ([self isErrorCCTransportStatusCode:statusCode]) {
        NSDictionary *dict = [NSDictionary
                              dictionaryWithObjectsAndKeys:localizedErrorStringFromPEPCCTransportStatusCode(statusCode),
                              NSLocalizedDescriptionKey, nil];
        return [NSError
                errorWithDomain:PEPCCTransportStatusStatusErrorDomain
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

+ (BOOL)setError:(NSError * _Nullable * _Nullable)error fromPEPCCStatusCode:(PEPTransportStatusCode)statusCode
{
    // Determine if the given status is an error.
    NSError *errorFromStatusCode = [self errorWithPEPCCTransportStatusCode:statusCode];

    // Set caller's error, if given
    if (error) {
        *error = errorFromStatusCode;
    }

    // Indicate error status.
    return errorFromStatusCode ? YES : NO;
}

/// Could in theory return a fully localized version of the underlying error.
NSString * _Nonnull localizedErrorStringFromPEPCCTransportStatusCode(PEPTransportStatusCode status) {
    return stringFromPEPCCTransportStatusCode(status);
}

NSString * _Nonnull stringFromPEPCCTransportStatusCode(PEPTransportStatusCode status) {
    return [NSString stringWithFormat:@"PEPCCTransportStatusCode: %ld", (long)status];
}

- (NSString * _Nullable)pEpErrorString
{
    if ([self.domain isEqualToString:PEPCCEngineStatusErrorDomain]) {
        return stringFromPEPStatus((PEP_STATUS) self.code);
    } else {
        return nil;
    }
}

@end
