//
//  GBFbAuthService.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBFbAuthService.h"
#import "GBAccountStore.h"

@implementation GBFbAuthService

+ (GBFbAuthService *)sharedAuthService
{
    static id _instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _instance = [[GBFbAuthService alloc] init];
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
    [[GBAccountStore  accountStore] registerAuthProvider:self];
}
@end
