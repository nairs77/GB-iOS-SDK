//
//  GBDeviceUtil.h
//  GBSdk
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//
#import <Foundation/Foundation.h>

#define IS_IOS6_OR_LESS                 ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
#define IS_IOS9_OR_MORE                 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)


@interface GBDeviceUtil : NSObject

+ (NSString *)getUUID;
+ (NSString *)uniqueDeviceId;
//+ (NSString *)deviceInfoForAuth:(NSString *)phoneNumber;
+ (NSString *)deviceVersion;
+ (NSString *)deviceModel;
+ (NSString *)deviceIpAddress;
//+ (NSString *)deviceIpAddress:(BOOL)preferIPv4;
+ (BOOL)isRooting;
+ (NSString *)currentCountryISO;
+ (NSString *)currentLanguage;
+ (NSString *)currentCountryLanguage;
+ (NSString *)getMCC;
+ (NSString *)advertisingId;
+ (BOOL)advertisingTrackingStatus;
+ (BOOL)isUpdatedAdvertisingId:(NSString *)userkey;
@end
