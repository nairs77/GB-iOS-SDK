//
//  GBGlobal.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

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
