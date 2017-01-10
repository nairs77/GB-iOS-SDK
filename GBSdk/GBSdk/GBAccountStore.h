//
//  GBAccountStore.h
//  GBSdk
//
//  Created by Professional on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthService.h"

@interface GBAccountStore : NSObject

@property (nonatomic, readonly, weak) id<AuthAccount> lastAccount;


+ (GBAccountStore *)accountStore;

- (void)registerAccount:(id<AuthAccount>)theAccount switchAccount:(BOOL)isChange;
- (void)unregisterAccount:(id<AuthAccount>)theAccount unlink:(BOOL)isUnlink;
- (void)unregisterAccounts;

- (void)registerAuthService:(id<AuthService>)theService;

- (id<AuthService>)serviceWithType:(JoypleAuthType)type;
- (id<AuthAccount>)accountWithType:(JoypleAuthType)type;

@end
