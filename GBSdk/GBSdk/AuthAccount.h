//
//  AuthAccount.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBGlobal.h"

@protocol AuthAccount <NSObject>

@property (nonatomic, readonly) SessionState currentState;
@property (nonatomic, readonly) NSString *userKey;

@end
