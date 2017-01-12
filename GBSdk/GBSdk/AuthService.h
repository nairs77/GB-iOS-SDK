//
//  AuthService.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBError;
@class GBSession;
@protocol AuthAccount;

@protocol AuthService <AuthAccount>

@property (nonatomic, readonly) BOOL lastService;

+ (id<AuthService>)sharedAuthService;

- (void)registerServiceInfo:(NSDictionary *)serviceInfo;

- (id<AuthAccount>)serviceAccount;

- (id<AuthAccount>)serviceAccountWithInfo:(NSDictionary*)info;

@end
