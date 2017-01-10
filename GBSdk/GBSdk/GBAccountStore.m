//
//  GBAccountStore.m
//  GBSdk
//
//  Created by Professional on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBAccountStore.h"

@implementation GBAccountStore

+ (GBAccountStore *)store
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
    if (self = [super init];) {
        // Initialization code here.
    
    }
    
    return self;
}
@end
