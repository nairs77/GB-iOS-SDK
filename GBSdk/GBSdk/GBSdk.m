//
//  GBSdk.m
//  GBSdk
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBSdk.h"

@implementation GBSdk

+ (void)initializeWithClientId:(NSString *)clientId secretKey:(NSString *)secretKey {
    
}

+ (void)Login:(int)authType
  withHandler:(AuthCompletionHandler)completionHandler {
    GBSession *session = [GBSession lastSession];
    
    
    
    [session login:authType];
    
}

+ (void)Logout {
    
}

+ (void)Unregister:(AuthCompletionHandler)completionHandler {
    
}

// InApp
+ (void)BuyItem:(NSString *)sku
        success:(void (^)(NSString *paymentKey))successBlock
           fail:(void(^)(GBError *error))failureBlock {
    
}

@end
