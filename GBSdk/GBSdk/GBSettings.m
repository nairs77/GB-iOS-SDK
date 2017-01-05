//
//  GBSettings.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 4..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBSettings.h"

@implementation GBSettings

+ (GBSettings *)currentSettings {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[GBSettings alloc] init];
    });
    
    return _instance;
}


@end
