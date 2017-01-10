//
//  GBAuthService.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBAuthService.h"

@implementation GBAuthService

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

}

- (void)loginWithAccountBlock:(AuthServiceCompletionHandler)completionHandler
{
    

}

- (void)logoutWithAccountBlock:(AuthServiceCompletionHandler)completionHandler
{
    
}

- (BOOL)isThrdPartyOn
{
    return false;
}

- (void)openSessionWithServiceHandler:(AuthServiceCompletionHandler)completionHandler {}
@end
