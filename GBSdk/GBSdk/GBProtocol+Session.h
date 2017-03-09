//
//  GBProtocol+Session.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBProtocol.h"

typedef NS_ENUM(NSUInteger, SessionCommand) {
    SESSION_GUEST_LOGIN,
    SESSION_FB_LOGIN,
    SESSION_CONNECT_CHANNEL,
    SESSION_LOGOUT,
};

@interface GBProtocol (Session)

+ (GBProtocol *)makeSessionProtocolWithCommand:(SessionCommand)command
                                         param:(NSDictionary *)param;
@end
