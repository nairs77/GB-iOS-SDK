//
//  GBProtocol.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SessionCommand) {
    SESSION_GUEST_LOGIN,
    SESSION_FB_LOGIN,
};

@interface GBProtocol : NSObject

@property (nonatomic, copy) NSString *serverUrl;
@property (nonatomic, copy) NSString *relativePath;
@property (nonatomic, copy) NSString *httpMethod;
@property (nonatomic, copy) NSDictionary *parameter;
@property (nonatomic, copy) NSDictionary *userAgent;
@property (nonatomic, copy) NSString *authorization;
@property (nonatomic, copy) NSString *deviceInfo;
@property (nonatomic, copy) NSDictionary *body;
@property (nonatomic) NSUInteger command;

+ (NSDictionary *)defaultHeader;

@end
