//
//  GBSdk.h
//  GBSdk
//
//  Created by nairs77 on 2016. 12. 29..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBError.h"

//! Project version number for GBSdk.
FOUNDATION_EXPORT double GBSdkVersionNumber;

//! Project version string for GBSdk.
FOUNDATION_EXPORT const unsigned char GBSdkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GBSdk/PublicHeader.h>


@interface GBSdk : NSObject


// Initailize
+ (void)InitializeWithClientId:(NSString *)clientId secretKey:(NSString *)secretKey;

// Logiin
+ (void)Login:(int)authType;

+ (void)Logout;

// InApp
+ (void)BuyItem:(NSString *)sku
        success:(void (^)(NSString *paymentKey))successBlock
           fail:(void(^)(GBError *error))failureBlock;

@end
