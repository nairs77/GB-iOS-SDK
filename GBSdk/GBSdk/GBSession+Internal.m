//
//  GBSession+Internal.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBSession+Internal.h"

@implementation GBSession (Internal)

+ (id)innerInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[GBSession alloc] init];
    });
    
    return _instance;
}
@end
