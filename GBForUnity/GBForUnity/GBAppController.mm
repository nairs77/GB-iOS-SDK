//
//  GBAppController.cpp
//  GBForUnity
//
//  Created by nairs77 on 2017. 2. 2..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <UnityAppController.h>
#import <GBSdk/GBSdk.h>
#import <GBSdk/GBSession.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface GBAppController : UnityAppController

@end

@implementation GBAppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BOOL result = [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    //    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
    //        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
    //                                                        UIUserNotificationTypeBadge |
    //                                                        UIUserNotificationTypeSound);
    //        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
    //                                                                                 categories:nil];
    //        [application registerUserNotificationSettings:settings];
    //        [application registerForRemoteNotifications];
    //    } else {
    //        // Register for Push Notifications, if running iOS version &lt; 8
    //        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
    //                                                         UIRemoteNotificationTypeAlert |
    //                                                         UIRemoteNotificationTypeSound)];
    //    }
    
    return result;
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    [super applicationDidBecomeActive:application];
    
    // Facebook 연동
    [FBSDKAppEvents activateApp];
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //GBLogVerbose(@"My token is: %@", deviceToken);
    
    //[super application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    // Prepare the Device Token for Registration (remove spaces and  )
    NSString *devToken = [[[[deviceToken description]
                            stringByReplacingOccurrencesOfString:@"<" withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""]
                          stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    //GBLogVerbose(@"My Device token is: %@", devToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //[super application:application didFailToRegisterForRemoteNotificationsWithError:error];
    //GBLogVerbose(@"Failed to get token, error = %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    //[super application:application didReceiveRemoteNotification:userInfo];
    //GBLogVerbose(@"%s Receive ... %@", __FUNCTION__, userInfo);
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [GBSdk application:application
                      openURL:url
            sourceApplication:sourceApplication
                   annotation:annotation];
    
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options
{
    return [GBSdk application:application openURL:url options:options];
}
@end

IMPL_APP_CONTROLLER_SUBCLASS(GBAppController);
