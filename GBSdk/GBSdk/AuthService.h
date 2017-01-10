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

typedef void(^AuthServiceCompletionHandler)(GBSession *newSession, GBError *error);

@protocol AuthService <AuthAccount>

@property (nonatomic, readonly, weak) id<AuthAccount> serviceAccount;
@property (nonatomic, readonly, getter=isThirdParty) BOOL thirdParty;
@property (nonatomic, readonly) BOOL lastService;

+ (id<AuthService>)sharedAuthService;

- (void)registerServiceInfo:(NSDictionary *)serviceInfo;

- (void)loginWithAccountBlock:(AuthServiceCompletionHandler)completionHandler;

- (void)logoutWithAccountBlock:(AuthServiceCompletionHandler)completionHandler;

//- (id<AuthAccount>)serviceAccount;
//
//- (id<AuthAccount>)serviceAccountWithInfo:(NSDictionary*)info;

@end
