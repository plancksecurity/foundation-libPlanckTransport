//
//  NSError+PEPCCTransport+internal.m
//  pEpCC_macOS
//
//  Created by Andreas Buff on 16.08.21.
//
#import <Foundation/Foundation.h>
#import "NSError+PEPTransportStatusCode.h"

NSString *const _Nonnull PEPCCEngineStatusErrorDomain = @"PEPCCEngineStatusErrorDomain";
NSString *const _Nonnull PEPCCTransportStatusStatusErrorDomain = @"PEPCCTransportStatusStatusErrorDomain";
NSString *const _Nonnull PEPCCErrorDomain = @"PEPCCErrorDomain";

@implementation NSError (PEPTransportStatusCode)

+ (BOOL)isErrorCCTransportStatusCode:(PEPTransportStatusCode)statusCode {
    switch (statusCode) {
            // Status that are not an error
        case PEPTransportStatusCodeReady:
        case PEPTransportStatusCodeMessageDelivered:
        case PEPTransportStatusCodeMessageOnTheWay:
        case PEPTransportStatusCodeCouldNotDeliverResending:
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

+ (NSError * _Nullable)errorWithPEPCCTransportStatusCode:(PEPTransportStatusCode)statusCode
                                            errorMessage:(NSString *)errorMessage
{
    if ([self isErrorCCTransportStatusCode:statusCode]) {
        NSString *message = [NSString stringWithFormat:@"%@ - %@",
                             localizedErrorStringFromPEPCCTransportStatusCode(statusCode),
                             errorMessage];
        NSDictionary *dict = @{NSLocalizedDescriptionKey:message};
        return [NSError errorWithDomain:PEPCCTransportStatusStatusErrorDomain
                            code:statusCode
                        userInfo:dict];
    } else {
        return nil;
    }
}

/// Could in theory return a fully localized version of the underlying error.
NSString * _Nonnull localizedErrorStringFromPEPCCTransportStatusCode(PEPTransportStatusCode status) {
    return stringFromPEPCCTransportStatusCode(status);
}

NSString * _Nonnull stringFromPEPCCTransportStatusCode(PEPTransportStatusCode status) {
    return [NSString stringWithFormat:@"PEPCCTransportStatusCode: %ld", (long)status];
}

@end
