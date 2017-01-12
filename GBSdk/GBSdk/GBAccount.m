//
//  GBAccount.m
//  GBSdk
//
//  Created by Professional on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBAccount.h"

@implementation GBAccount

- (id)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

#pragma mark - AuthAccount

- (id)initWithAccountInfo:(NSDictionary *)info
{
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)logIn:(void (^)(id<AuthAccount>, GBError *))accountBlock
{
    // Override Each Account
}

- (void)logOut:(void (^)(id<AuthAccount>, GBError *))accountBlock
{
    // All Account
}

- (void)unRegister:(void (^)(id<AuthAccount>, GBError *))accountBlock
{
    // All Account
}

- (void)loginGB
{
    
}

- (void)logoutGB
{
    
}

- (void)unRegisterGB
{
    
}

- (AuthType)authType
{
    return GUEST;
}
@end
