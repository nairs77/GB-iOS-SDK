//
//  GBAuthService.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBAuthService.h"
#import "GBGuestAccount.h"

@implementation GBAuthService
@synthesize lastService;

+ (id<AuthService>)sharedAuthService
{
    static id _instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        _instance = [[GBAuthService alloc] init];
    });
    
    return _instance;
}

- (id)init
{
    if (self = [super init]) {
    }
    
    return self;
}

- (void)registerServiceInfo:(NSDictionary *)serviceInfo
{
    [[GBAccountStore accountStore] registerAuthService:nil];
}

- (id<AuthAccount>)serviceAccount
{
    return [GBGuestAccount defaultAccount];
}

- (id<AuthAccount>)serviceAccountWithInfo:(NSDictionary *)info
{
    GBGuestAccount *account = [[GBGuestAccount alloc] initWithAccountInfo:info];
    
    return account;
}

- (AuthType)authType
{
    return GUEST;
}


@end
