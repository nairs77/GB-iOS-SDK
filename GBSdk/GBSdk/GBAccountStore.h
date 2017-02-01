//
//  GBAccountStore.h
//  GBSdk
//
//  Created by Professional on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBGlobal.h"
#import "AuthService.h"


@interface GBAccountStore : NSObject

@property (nonatomic, readonly, weak) id<AuthAccount> lastServiceAccount;

+ (GBAccountStore *)accountStore;

- (void)registerAccount:(id<AuthAccount>)theAccount switchAccount:(BOOL)isChange;
//- (void)unregisterAccount:(id<AuthAccount>)theAccount unlink:(BOOL)isUnlink;
- (void)unregisterAccounts;

- (void)registerAuthService:(id<AuthService>)theService;

- (id<AuthService>)serviceWithType:(AuthType)type;
//- (id<AuthAccount>)accountWithType:(AuthType)type;

@end
