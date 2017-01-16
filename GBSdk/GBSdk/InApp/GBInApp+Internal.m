//
//  GBInApp+Internal.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 16..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBInApp+Internal.h"

@implementation GBInApp (Internal)

+ (id)innerInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[GBInApp alloc] init];
    });
    
    return _instance;
}

@end
