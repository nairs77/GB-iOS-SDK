//
//  GBAccountStore.m
//  GBSdk
//
//  Created by Professional on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBAccountStore.h"

@implementation GBAccountStore

+ (GBAccountStore *)accountStore
{
    static GBAccountStore *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[GBAccountStore alloc] init];
    });
    
    return _instance;
}

- (id)init
{
    if (self = [super init]) {
        // Initialization code here.
    }
    
    return self;
}

- (id<AuthAccount>)lastServiceAccount
{
    if (self.lastAccount == nil) {
        //
        id<AuthService> lastService = [self _lastAuthService];
        
        if (lastService != nil)
            self.lastAccount = [lastService serviceAccount];
    }
    
    return self.lastAccount;
}

- (void)registerAccount:(id<AuthAccount>)theAccount switchAccount:(BOOL)isChange
{
    
}

- (void)unregisterAccount:(id<AuthAccount>)theAccount unlink:(BOOL)isUnlink
{
    
}

- (void)unregisterAccounts
{
    
}

- (void)registerAuthService:(id<AuthService>)theService
{
    
}

- (id<AuthService>)serviceWithType:(JoypleAuthType)type
{
    return nil;
}

- (id<AuthAccount>)accountWithType:(JoypleAuthType)type
{
    return nil;
}

#pragma mark - Private Methods

- (void)_lastAuthService
{
    
}
@end
