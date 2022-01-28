//
//  PEPTransportStatusErrorCallbacks.m
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 25.01.22.
//

#import "PEPTransportStatusCallbacks.h"

@implementation PEPTransportStatusCallbacks

+ (instancetype)callbacksWithSuccessCallback:(void (^)(PEPTransportStatusCode))successCallback
                               errorCallback:(void (^)(PEPTransportStatusCode, NSError *))errorCallback {
    return [[self alloc] initWithSuccessCallback:successCallback
                                   errorCallback:errorCallback];
}

- (instancetype)initWithSuccessCallback:(void (^)(PEPTransportStatusCode))successCallback
                          errorCallback:(void (^)(PEPTransportStatusCode, NSError *))errorCallback {
    self = [super init];
    if (self) {
        _successCallback = successCallback;
        _errorCallback = errorCallback;
    }
    return self;
}

@end
