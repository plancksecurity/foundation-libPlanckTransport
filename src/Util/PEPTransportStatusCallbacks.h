//
//  PEPTransportStatusErrorCallbacks.h
//  pEpTransport_macOS
//
//  Created by Dirk Zimmermann on 25.01.22.
//

#import <Foundation/Foundation.h>

#import "PEPTransportStatusCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPTransportStatusCallbacks : NSObject

@property (nonatomic, nonnull, readonly) void (^successCallback)(PEPTransportStatusCode);
@property (nonatomic, nonnull, readonly) void (^errorCallback)(PEPTransportStatusCode, NSError *);

- (instancetype)initWithSuccessCallback:(void (^)(PEPTransportStatusCode))successCallback
                          errorCallback:(void (^)(PEPTransportStatusCode, NSError *))errorCallback;

@end

NS_ASSUME_NONNULL_END
