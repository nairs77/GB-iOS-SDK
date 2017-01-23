//
//  GBSdk.h
//  GBSdk
//
//  Created by nairs77 on 2016. 12. 29..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GBError;
@class GBSession;
@class GBInApp;

//! Project version number for GBSdk.
FOUNDATION_EXPORT double GBSdkVersionNumber;

//! Project version string for GBSdk.
FOUNDATION_EXPORT const unsigned char GBSdkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GBSdk/PublicHeader.h>


typedef NS_ENUM(NSUInteger, LogLevel) {
    DEBUG_MODE,
    RELEASE_MODE,
};

@interface GBSdk : NSObject


// Initailize
//+ (void)InitializeWithClientId:(NSString *)clientId secretKey:(NSString *)secretKey;
+ (void)configureSDKWithInfo:(int)gameCode clientId:(NSString *)secretKey logLevel:(LogLevel)level;

//+ (GBSession *)activeSession;
//
//+ (GBInApp *)inAppManager;

@end
