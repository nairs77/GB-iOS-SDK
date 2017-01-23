//
//  GBSettings.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 4..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GBSettings : NSObject

+ (GBSettings *)currentSettings;

@property (nonatomic, copy) NSString *clientSecretKey;
@property (nonatomic, copy) NSString *userKey;
@property (nonatomic) int gameCode;
@property (nonatomic) int marketCode;

@property (nonatomic, readonly) NSString *authServer;
@property (nonatomic, readonly) NSString *inAppServer;

// Device Info
@property (nonatomic, readonly, copy) NSString *deviceVersion;
@property (nonatomic, readonly, copy) NSString *deviceModel;

// App Info
@property (nonatomic, readonly, copy) NSString *appBundleId;
@end
