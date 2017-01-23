//
//  GBAccount.h
//  GBSdk
//
//  Created by Professional on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthAccount.h"
#import "Singletone.h"

@class GBError;

@interface GBAccount : NSObject <AuthAccount>

@property (nonatomic, readonly) SessionState currentState;
@property (nonatomic, readonly, copy) NSString *userKey;
@property (nonatomic, readonly) AuthType authType;

@property (nonatomic, copy) void (^accountBlock)(id<AuthAccount> localAccount, GBError *error);


- (void)loginGB;

- (void)logoutGB;

- (void)unRegisterGB;

@end
