//
//  GBFbAuthService.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBAuthService.h"

@interface GBFacebookService : GBAuthService <AuthService>

+ (BOOL)handleOpenUrl:(NSURL *)theUrl
          application:(UIApplication *)application
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation;
+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end
