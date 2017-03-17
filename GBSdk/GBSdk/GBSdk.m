//
//  GBSdk.m
//  GBSdk
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBSdk.h"
#import "GBSettings.h"
#import "GBLog.h"
#import "GBSession+internal.h"
#import "GBAuthService.h"
#import "GBFacebookService.h"
#import "GBInApp+Internal.h"
#import "GBDeviceUtil.h"

int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation GBSdk

+ (void)configureSDKWithInfo:(int)gameCode clientId:(NSString *)secretKey logLevel:(LogLevel)level
{
    ddLogLevel = (level == DEBUG_MODE)? LOG_LEVEL_VERBOSE : LOG_LEVEL_ERROR;

    [[GBAuthService sharedAuthService] registerServiceInfo:nil];
    [[GBFacebookService sharedAuthService] registerServiceInfo:nil];
    
    NSDictionary *plist = [[NSBundle mainBundle] infoDictionary];
    
    [GBSettings currentSettings].fbAuthPrefix = [NSString stringWithFormat:@"fb%@", [plist objectForKey:@"FacebookAppID"]];
    [GBSettings currentSettings].gameCode = gameCode;
    
    [GBSession activeSession];
    [GBInApp initInApp];
    
}

+ (BOOL)application:(UIApplication *)application
            openURL:(nonnull NSURL *)url
            options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    return [GBSdk application:application
                      openURL:url
            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

+ (BOOL)application:(UIApplication *)application
            openURL:(nonnull NSURL *)url
  sourceApplication:(nullable NSString *)sourceApplication
         annotation:(nonnull id)annotation
{
    NSString *fbSceme = [[GBSettings currentSettings] fbAuthPrefix];
    NSString *prefix = [GBSdk _parseUrlScheme:url];
    
    if ([prefix isEqualToString:fbSceme]) {
        return [GBFacebookService handleOpenUrl:url application:application sourceApplication:sourceApplication annotation:annotation];
    }
    
    return NO;
}

#pragma mark - Private Methods
+ (NSString *)_parseUrlScheme:(NSURL *)url
{
	NSString *absoluteString = [url absoluteString];
    NSString *urlScheme = [[absoluteString componentsSeparatedByString:@":"] objectAtIndex:0];
    
    // Check Facebook prefix
//    NSString *prefix = [urlScheme substringWithRange:NSMakeRange(0, 2)];
    
    return urlScheme;
}

@end
