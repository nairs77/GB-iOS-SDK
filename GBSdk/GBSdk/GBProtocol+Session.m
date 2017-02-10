//
//  GBProtocol+Session.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBProtocol+Session.h"
#import "GBSettings.h"
#import "GBDeviceUtil.h"

@interface GBProtocol (InnerMethods)

- (void)_makeGuestLoginWithParam:(NSDictionary *)param;
- (void)_makeFBLoginWithParam:(NSDictionary *)param;

@end

@implementation GBProtocol (Session)

+ (GBProtocol *)makeSessionProtocolWithCommand:(SessionCommand)command
                                         param:(NSDictionary *)param {
    GBProtocol *protocol = [[GBProtocol alloc] init];
    protocol.command = command;
    
    if (command == SESSION_GUEST_LOGIN) {
        [protocol _makeGuestLoginWithParam:param];
    } else if (command == SESSION_FB_LOGIN) {
        [protocol _makeFBLoginWithParam:param];
    }
    
    return protocol;
}

#pragma mark - Private Methods
- (void)_makeGuestLoginWithParam:(NSDictionary *)param
{
    self.serverUrl = [[GBSettings currentSettings] authServer];
    self.relativePath = @"/Login";
    self.httpMethod = @"POST";
    
//    self.parameter = @{@"channel":[param objectForKey:@"channel"], @"channelID":[param objectForKey:@"channelID"], @"gameCode" : [NSNumber numberWithInt:1], @"mcc" : [GBDeviceUtil getMCC]};
    self.parameter = @{@"channel":[param objectForKey:@"channel"], @"channelID":[param objectForKey:@"channelID"], @"gameCode" : [NSNumber numberWithInt:1]};
    self.userAgent = [GBProtocol defaultHeader];
}

- (void)_makeFBLoginWithParam:(NSDictionary *)param
{
    self.serverUrl = [[GBSettings currentSettings] authServer];
    self.relativePath = @"/login";
    self.httpMethod = @"POST";
    
    
    self.parameter = @{@"type":[param objectForKey:@"type"], @"userInfo":[param objectForKey:@"info"], @"mcc" : [GBDeviceUtil getMCC]};
    self.userAgent = [GBProtocol defaultHeader];
}
@end
