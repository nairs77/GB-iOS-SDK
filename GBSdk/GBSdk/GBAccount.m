//
//  GBAccount.m
//  GBSdk
//
//  Created by Professional on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBAccount.h"

@implementation GBAccount

#pragma mark - AuthAccount

- (void)loginWithAuthType:(AuthType)authType
             accountBlock:(void (^)(id<AuthAccount>, GBError *))accountBlock
{
    //
    
}

- (void)logOut:(void (^)(id<AuthAccount>, GBError *))accountBlock
{
    
}

- (void)unRegister:(void (^)(id<AuthAccount>, GBError *))accountBlock
{
    
}
@end
