//
//  GBForUnity.mm
//  GBForUnity
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import "GBUnityPlugin.h"
#import <GBSdk/GBSdk.h>

void ConfigureSDKWithGameInfo(const char *clientSecretKey, int gameCode, int marketCode, int logLevel)
{
    [GBSdk configureSDKWithInfo:gameCode clientId:"" logLevel:(LogLevel)logLevel];
}

void LoginWithAuthType(int loginType, const char *callbackId)
{
    
}

void Logout(const char *callbackId)
{
    
}
