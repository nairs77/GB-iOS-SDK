//
//  GBFbAuthService.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBAuthService.h"

@interface GBFbAuthService : GBAuthService <AuthService>

- (void)loginWithAccountBlock:(AuthServiceCompletionHandler)completionHandler;

@end
