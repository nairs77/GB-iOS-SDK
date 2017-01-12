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
- (id)initWithAccountInfo:(NSDictionary *)info;

- (void)logIn:(void(^)(id<AuthAccount> localAccount, GBError *error))accountBlock;

//- (void)linkServiceWithParameter:(void(^)(id<AuthAccount> localAccount, GBError *error))accountBlock;

- (void)logOut:(void(^)(id<AuthAccount> localAccount, GBError *error))accountBlock;

- (void)unRegister:(void(^)(id<AuthAccount> localAccount, GBError *error))accountBlock;
@end
