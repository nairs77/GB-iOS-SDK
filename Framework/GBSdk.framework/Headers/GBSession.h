//
//  GBSession.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBGlobal.h"

@class GBError;
@class GBSession;

typedef void(^AuthCompletionHandler)(GBSession *newSession, GBError *error);

@interface GBSession : NSObject

@property (nonatomic, readonly) SessionState state;
@property (nonatomic, readonly) NSString *userKey;
@property (nonatomic, readonly) NSDictionary *sessionInfo;
@property (nonatomic, readonly) NSString *userInfo;
@property (nonatomic, readonly, getter = isOpened) BOOL opened;
@property (nonatomic, readonly, getter = isConnectedChannel) BOOL connectedChannel;

+ (GBSession *)activeSession;

+ (void)loginWithAuthType:(AuthType)type withHandler:(AuthCompletionHandler)completionHandler;

+ (void)login:(AuthCompletionHandler)completionHandler;

+ (void)connectChannel:(AuthType)type withHandler:(AuthCompletionHandler)completionHandler;

+ (void)logout:(AuthCompletionHandler)completionHandler;
@end
