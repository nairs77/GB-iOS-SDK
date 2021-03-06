//
//  GBSettings.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 4..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBSettings.h"
#import "GBDeviceUtil.h"

NSString *const kACCOUNT_SERVER = @"http://sys.gebros.com:8000";
NSString *const kBILLING_SERVER = @"http://sys.gebros.com:7000";

@interface GBSettings ()

@property (nonatomic, copy) NSDictionary *pInfo;
@property (nonatomic, readwrite) int _marketCode;
@property (nonatomic, readwrite, copy) NSString *deviceVersion;
@property (nonatomic, readwrite, copy) NSString *deviceModel;
@property (nonatomic, readwrite, copy) NSString *appBundleId;

@end

@implementation GBSettings

+ (GBSettings *)currentSettings {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[GBSettings alloc] init];
    });
    
    return _instance;
}

- (id)init
{
    if (self = [super init]) {
        self.pInfo = [[NSBundle mainBundle] infoDictionary];
        self.deviceModel = [GBDeviceUtil deviceModel];
        self.deviceVersion = [GBDeviceUtil deviceVersion];
        
        self.appBundleId = [self.pInfo objectForKey:(NSString *)kCFBundleIdentifierKey];
        self._marketCode = 2;
        
    }
    
    return self;
}

- (NSString *)deviceVersion
{
    return self.deviceVersion;
}

- (NSString *)deviceModel
{
    return self.deviceModel;
}

- (NSString *)appBundleId
{
    return self.appBundleId;
}

- (int)marketCode
{
    return self._marketCode;
}

- (NSString *)authServer
{
    return kACCOUNT_SERVER;
}

- (NSString *)inAppServer
{
    return kBILLING_SERVER;
}
@end
