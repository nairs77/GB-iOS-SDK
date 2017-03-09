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
    
    if (command == SESSION_GUEST_LOGIN || SESSION_FB_LOGIN) {
        [protocol _makeGuestLoginWithParam:param];
    } else if (command == SESSION_CONNECT_CHANNEL) {
        [protocol _makeConnectChannelWithParam:param];
    }
    
    return protocol;
}

#pragma mark - Private Methods
- (void)_makeGuestLoginWithParam:(NSDictionary *)param
{
    self.serverUrl = [[GBSettings currentSettings] authServer];
    self.relativePath = @"/User/Login";
    self.httpMethod = @"POST";
    self.parameter = @{@"channel":[param objectForKey:@"channel"], @"channelID":[param objectForKey:@"channelID"], @"gameCode" : [NSNumber numberWithInt:1]};
    self.userAgent = [GBProtocol defaultHeader];
}

- (void)_makeConnectChannelWithParam:(NSDictionary *)param
{
    self.serverUrl = [[GBSettings currentSettings] authServer];
    self.relativePath = @"/User/ConnectChannel";
    self.httpMethod = @"POST";
    self.parameter = @{@"accouneSeq":[param objectForKey:@"accountSeq"], @"channel":[param objectForKey:@"channel"], @"channelID":[param objectForKey:@"channelID"], @"gameCode" : [NSNumber numberWithInt:1], @"checksum" : [param objectForKey:@"checksum"]};
    self.userAgent = [GBProtocol defaultHeader];
}
@end
