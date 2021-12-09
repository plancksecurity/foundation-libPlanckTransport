//
//  PEPCCTestUtil.m
//  pEpCCTests
//
//  Created by David Alarcon on 6/9/21.
//

#import "PEPCCTestUtil.h"

#import "PEPIdentity.h"
#import "PEPAttachment.h"
#import "PEPLanguage.h"
#import "PEPMessage.h"

@implementation PEPCCTestUtil

+ (PEPIdentity *)pEpIdentityWithAllFieldsFilled {
    PEPIdentity *identity = [PEPIdentity new];

    identity.address = @"test@host.com";
    identity.userID = @"pEp_own_userId";
    identity.isOwn = YES;

    return identity;
}

+ (PEPMessage *)pEpMessageWithAllFieldsFilled {
    PEPMessage *message = [PEPMessage new];
    PEPIdentity *identity = [PEPCCTestUtil pEpIdentityWithAllFieldsFilled];

    message.messageID = [NSString stringWithFormat: @"19980506192030.26456.%@", identity.address];

    message.from = identity;
    message.to = @[identity];

    message.shortMessage = @"shortMessage";
    message.longMessage = @"longMessage";
    message.longMessageFormatted = @"longMessageFormatted";

    NSDate *yesterday = [NSCalendar.currentCalendar dateByAddingUnit:NSCalendarUnitDay
                                                               value:-1 toDate:[NSDate now]
                                                             options:NSCalendarWrapComponents];
    message.sentDate = yesterday;
    message.receivedDate = [NSDate now];

    message.direction = PEPMsgDirectionOutgoing;

    return message;
}

@end
