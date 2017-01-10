//
//  GBAuthService.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthService.h"
#import "GBError.h"

@interface GBAuthService : NSObject <AuthService>

//- (void)loginWithAccountBlock:(AuthServiceCompletionHandler)completionHandler;
- (void)openSessionWithServiceHandler:(AuthServiceCompletionHandler)completionHandler;

//- (void)logoutWithAccountBlock:(AuthServiceCompletionHandler)completionHandler;

@end
