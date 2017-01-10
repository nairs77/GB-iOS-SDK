//
//  GBSession.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GBError;

typedef NS_ENUM(NSUInteger, AuthType) {
    GUEST,
    GOOGLE,     //Not Supported
    FACEBOOK,
};


typedef NS_ENUM(NSUInteger, SessionState) {
    READY,
    OPEN,
    CLOSED,
};

typedef void(^AuthCompletionHandler)(BOOL success, GBError *error);


@interface GBSession : NSObject

@property (nonatomic, readonly) SessionState state;
@property (nonatomic, copy, readonly) NSString *userKey;
@property (nonatomic, readonly, getter = isOpened) BOOL opened;

- (void)setActiveSession:(GBSession *)aSession;

- (void)loginWithAuthType:(AuthType)type withHandler:(AuthCompletionHandler)completionHandler;

@end
