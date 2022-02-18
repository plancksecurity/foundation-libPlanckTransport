///
/// This file was automatically generated. Don't edit it manually.
///
/// For details, see here:
/// https://gitea.pep.foundation/pEp.foundation/libpEpTransport
///

#ifndef __PEPTransportStatusCode_H__
#define __PEPTransportStatusCode_H__

#import <Foundation/Foundation.h>

typedef NS_CLOSED_ENUM(NSUInteger, PEPTransportStatusCode) {
    PEPTransportStatusCodeReady = 0x00000000,
    
    // non error states
    
    PEPTransportStatusCodeConnectionUp = 0x00000001,
    PEPTransportStatusCodeMessageDelivered = 0x00000002,
    PEPTransportStatusCodeMessageOnTheWay = 0x00000003,
    PEPTransportStatusCodeCouldNotDeliverResending = 0x00000004,
    
    // error states
    
    PEPTransportStatusCodeConnectionDown = 0x00800001, // sent by connection based transports
    PEPTransportStatusCodeSomeRecipientsUnreachable = 0x00800002,
    PEPTransportStatusCodeNoRecipientsReachable = 0x00800003,
    PEPTransportStatusCodeNoConfig = 0x00800004,
    PEPTransportStatusCodeConfigIncompleteOrWrong = 0x00800005,
    PEPTransportStatusCodeNoSendConfig = 0x00800006,
    PEPTransportStatusCodeNoRecvConfig = 0x00800007,
    PEPTransportStatusCodeSendConfigIncompleteOrWrong = 0x00800008,
    PEPTransportStatusCodeRecvConfigIncompleteOrWrong = 0x00800009,
    PEPTransportStatusCodeNetworkTimeout = 0x0080000a,
    PEPTransportStatusCodeCouldNotDeliverGivingUp = 0x0080000b,
    PEPTransportStatusCodeRxQueueUnderrun = 0x0080000c, // no message left to be received
    PEPTransportStatusCodeTxQueueOverflow = 0x0080000d, // transmit queue is full
    
    // transport is shut down
    
    PEPTransportStatusCodeShutDown = 0x00ffffff,
    
    // transport status codes for email (0x01)
    
    PEPTransportStatusCodeCannotReachSmtpServer = 0x01801001,
    PEPTransportStatusCodeUnknownSmtpError = 0x01801fff,
    PEPTransportStatusCodeCannotReachImapServer = 0x01802001,
    PEPTransportStatusCodeUnknownImapError = 0x01802fff,
    
    // transport status codes for RCE (0x02)
    
    PEPTransportStatusCodeRceCannotCreateUser = 0x02800001,
    PEPTransportStatusCodeRceCannotLoginUser = 0x02800002,
    PEPTransportStatusCodeRceCannotFindUser = 0x02800003,
    PEPTransportStatusCodeTorrentHasNoSeeders = 0x02ff0001,
    PEPTransportStatusCodeUnknownTorrentError = 0x02ffffff,
    
    // transport status codes for PDL (0x03)
    
    PEPTransportStatusCodeCannotReachEthNetwork = 0x03800001,
    PEPTransportStatusCodeCannotDecodePdlMessage = 0x03800002,
    PEPTransportStatusCodeUnknownEthError = 0x03ffffff,
    
    // transport status codes for pEp over SCTP (0x04)
    
    PEPTransportStatusCodeSctpCouldNotDecodeAsn1 = 0x04080001,
    PEPTransportStatusCodeSctpErrorReceivingMessage = 0x04080002,
    PEPTransportStatusCodeSctpUnkownError = 0x04ffffff
};

#endif // __PEPTransportStatusCode_H__
