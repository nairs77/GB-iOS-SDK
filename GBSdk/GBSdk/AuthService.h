//
//  AuthService.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBGlobal.h"

@class GBError;
@class GBSession;
@protocol AuthAccount;

@protocol AuthService <NSObject>

@property (nonatomic) BOOL lastService;
@property (nonatomic, readonly) AuthType authType;

+ (id<AuthService>)sharedAuthService;

- (void)registerServiceInfo:(NSDictionary *)serviceInfo;

- (id<AuthAccount>)serviceAccount;

- (id<AuthAccount>)serviceAccountWithInfo:(NSDictionary*)info;

@end
