//
//  GBSdk.m
//  GBSdk
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBSdk.h"
#import "GBLog.h"
#import "GBSession+internal.h"
#import "GBAuthService.h"
#import "GBFacebookService.h"
#import "GBInApp+Internal.h"

int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation GBSdk

//+ (void)initializeWithClientId:(NSString *)clientId secretKey:(NSString *)secretKey logLevel:(LogLevel)level {
+ (void)configureSDKWithInfo:(int)gameCode clientId:(NSString *)secretKey logLevel:(LogLevel)level
{
    ddLogLevel = (level == DEBUG_MODE)? LOG_LEVEL_VERBOSE : LOG_LEVEL_ERROR;

    [[GBAuthService sharedAuthService] registerServiceInfo:nil];
    [[GBFacebookService sharedAuthService] registerServiceInfo:nil];
}

//+ (GBSession *)activeSession {
//    return [GBSession innerInstance];
//}
//
//+ (GBInApp *)inAppManager {
//    return [GBInApp innerInstance];
//}

@end
