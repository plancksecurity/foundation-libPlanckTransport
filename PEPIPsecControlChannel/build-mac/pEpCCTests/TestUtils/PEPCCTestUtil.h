//
//  PEPCCTestUtil.h
//  pEpCCTests
//
//  Created by David Alarcon on 6/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PEPIdentity, PEPAttachment, PEPLanguage, PEPMessage;
@interface PEPCCTestUtil : NSObject

+ (PEPIdentity *)pEpIdentityWithAllFieldsFilled;
+ (PEPMessage *)pEpMessageWithAllFieldsFilled;

@end

NS_ASSUME_NONNULL_END
