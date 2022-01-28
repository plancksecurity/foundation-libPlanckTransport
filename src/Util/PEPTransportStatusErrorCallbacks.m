//
//  PEPTransportStatusErrorCallbacks.m
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 25.01.22.
//

#import "PEPTransportStatusErrorCallbacks.h"

@implementation PEPTransportStatusErrorCallbacks

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
