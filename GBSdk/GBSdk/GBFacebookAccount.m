//
//  GBFacebookAccount.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 12..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBFacebookAccount.h"

@implementation GBFacebookAccount

+ (GBFacebookAccount *)defaultAccount
{
    static id _instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _instance = [[GBFacebookAccount alloc] init];
    });
    
    return _instance;
}

- (void)logIn:(void (^)(id<AuthAccount>, GBError *))accountBlock
{
    
}

- (AuthType)authType
{
    return FACEBOOK;
}
@end
