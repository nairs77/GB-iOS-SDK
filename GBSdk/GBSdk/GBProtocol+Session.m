//
//  GBProtocol+Session.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBProtocol+Session.h"

@interface GBProtocol (InnerMethods)

+ (void)_makeLoginProtocol:(NSDictionary *)param;

@end

@implementation GBProtocol (Session)

+ (GBProtocol *)makeSessionProtocolWithCommand:(SessionCommand)command
                                         param:(NSDictionary *)param {
    GBProtocol *protocol = [[GBProtocol alloc] init];
    
//    if (command == SessionCommand.SESSION_GUEST_LOGIN) {
//        
//    }
    
    return nil;
}
@end
