//
//  AuthAccount.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBGlobal.h"

@class GBError;

@protocol AuthAccount <NSObject>

@property (nonatomic, readonly) AuthType authType;
@property (nonatomic, readonly, copy) NSString *userKey;
@property (nonatomic, readonly, copy) NSDictionary *accountInfo;

- (id)initWithAccountInfo:(NSDictionary *)info;

- (void)logIn:(void(^)(id<AuthAccount> localAccount, GBError *error))accountBlock;

- (void)connectChannel:(NSDictionary *)param accountBlock:(void(^)(id<AuthAccount> localAccount, GBError *error))accountBlock;

- (void)logOut:(void(^)(id<AuthAccount> localAccount, GBError *error))accountBlock;

- (void)unRegister:(void(^)(id<AuthAccount> localAccount, GBError *error))accountBlock;
@end
