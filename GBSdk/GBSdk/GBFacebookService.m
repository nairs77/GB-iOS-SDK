//
//  GBFacebookService.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBFacebookService.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation GBFacebookService

+ (GBFacebookService *)sharedAuthService
{
    static id _instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _instance = [[GBFacebookService alloc] init];
    });
    
    return _instance;
}

+ (BOOL)handleOpenUrl:(NSURL *)theUrl
          application:(UIApplication *)application
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:theUrl
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
}


- (id)init
{
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)registerServiceInfo:(NSDictionary *)serviceInfo
{
    [[GBAccountStore accountStore] registerAuthService:self];
}

@end