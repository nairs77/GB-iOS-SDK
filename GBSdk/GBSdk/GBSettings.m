//
//  GBSettings.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 4..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBSettings.h"
#import "GBDeviceUtil.h"

NSString *const kACCOUNT_SERVER = @"https://platform.gebros.com";
NSString *const kBILLING_SERVER = @"https://platform.gebros.com";

@interface GBSettings ()

@property (nonatomic, copy) NSDictionary *pInfo;
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
        
    }
    
    return self;
}

@end
