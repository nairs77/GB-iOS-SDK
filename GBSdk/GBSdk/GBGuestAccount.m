//
//  GBGuestAccount.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 12..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBGuestAccount.h"

@implementation GBGuestAccount

+ (GBGuestAccount *)defaultAccount
{
    static id _instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _instance = [[GBGuestAccount alloc] init];
    });
    
    return _instance;
}


@end
