//
//  GBInAppManager
//  InApp
//
//  Created by nairs77 on 2016. 12. 29..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBError;

@interface GBStoreService : NSObject

+ (void)startStoreService:(void (^)(BOOL success, GBError *error))resultBlock;

+ (void)startStoreServiceAlone:(NSString *)userKey result:(void (^)(BOOL success, GBError *error))resultBlock;

/**
 *  Request information about a set of products from App Store.
 *
 *  @param identifiers The identifier of the product
 *  @param successBlock The block to be called if request is sucessful.
 *  @param failureBlock The block to be called if request is fail.
 */
+ (void)requestProducts:(NSSet *)identifiers
                success:(void (^)(NSArray *products, NSArray *invalidProductIdentifiers))successBlock
                failure:(void (^)(GBError *error))failureBlock;

/**
 *  Request payment of the product with the given product identifier.
 *
 *  @param identifiers  The identifier of the product
 *  @param successBlock The block to be called if the payment is sucessful. Can be `nil`.
 *  @param failureBlock The block to be called if the payment is fail or there isn't any product with the given identifier. Can be `nil`.
 */
+ (void)addPayment:(NSString *)productIdentifier
           success:(void (^)(NSString *paymentKey))successBlock
           failure:(void (^)(GBError *error))failureBlock;


+ (void)addPayment:(NSString *)productIdentifier
           payload:(NSString *)payload
      subscription:(BOOL)subscription
           success:(void (^)(NSString *paymentKey))successBlock
           failure:(void (^)(GBError *error))failureBlock;


+ (void)restorePayment:(void(^)(NSArray *paymentKeys))resultBlock;

+ (void)retryPaymet:(void(^)(NSString *paymentKey))resultBlock;

// - Test API

+ (void)requestDownloadItem:(NSString *)paymentKey
                     result:(void(^)(NSDictionary *itemInfo))resltBlock;

+ (void)requestItemInventory:(void(^)(NSArray *items))resultBlock;

+ (void)requestPayInfo:(NSString *)paymentKey result:(void(^)(NSDictionary *itemInfo, GBError *error))resultBlock;
+ (void)requestSetLog:(NSDictionary *)payLog result:(void(^)(NSDictionary *itemInfo, GBError *error))resultBlock;
@end
