//
//  GBInApp.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 16..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBError.h"

@interface GBInApp : NSObject

- (void)initInApp:(void(^)(BOOL success, GBError *error))resultBlock;

//- (void)reuqestProductInfo:(NSSet *)skus
//                   success:(void(^)(NSArray *products, NSArray *invalidProducsts))successBlock
//                   failure:(void(^)(GBError *error))failureBlock;

- (void)requestProducts:(NSSet *)skus
                success:(void(^)(NSArray *products, NSArray *invalidProducsts))successBlock
                failure:(void(^)(GBError *error))failureBlock;

- (void)buyItem:(NSString *)productId
        success:(void (^)(NSString *paymentKey))successBlock
        failure:(void (^)(GBError *error))failureBlock;

- (void)restoreItem:(void(^)(NSString *paymentKey, GBError *error))resultBlock;

@end
