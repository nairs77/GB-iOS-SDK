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

int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation GBSdk

//+ (void)initializeWithClientId:(NSString *)clientId secretKey:(NSString *)secretKey logLevel:(LogLevel)level {
+ (void)initGBSdK:(int)gameCode clientId:(NSString *)secretKey logLevel:(LogLevel)level
{
    ddLogLevel = (level == DEBUG_MODE)? LOG_LEVEL_VERBOSE : LOG_LEVEL_ERROR;
    
    //NSString *fbAppId = [[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)
    
    [[GBAuthService sharedAuthService] registerServiceInfo:nil];
    [[GBFacebookService sharedAuthService] registerServiceInfo:nil];
}

+ (GBSession *)activeSession {
    return [GBSession innerInstance];
}

+ (GBInApp *)inAppManager {
//    return [GBInApp innerInstance];
    return nil;
}

@end
