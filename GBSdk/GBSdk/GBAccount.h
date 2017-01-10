//
//  GBAccount.h
//  GBSdk
//
//  Created by Professional on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthAccount.h"

@class GBError;

@interface GBAccount : NSObject <AuthAccount>

@property (nonatomic, copy) void (^accountBlock)(id<AuthAccount> localAccount, GBError *error);


//- (void)tryAuthenticateByProvider:(NSDictionary *)parameter;
//- (void)linkServiceByProvider:(NSDictionary *)parameter;
//- (void)logoutByProvider:(BOOL)isDeepLink;
//- (void)unRegisterByProvider;
@end
