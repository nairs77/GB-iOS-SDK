//
//  GBInAppHelper.h
//  GB
//
//  Created by Professional on 2014. 6. 12..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "GBApiRequest.h"
#import "GBProductRequestDelegate.h"
#import "GBAddPaymentAction.h"

#ifdef _JOYPLE_ANALYTICS_
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#endif

@class GBError;

typedef void(^GBErrorHandler)(GBError *error);

@interface GBInAppHelper : NSObject<SKPaymentTransactionObserver>

@property (nonatomic, strong) NSString *userKey;

@property (nonatomic, copy) NSString *extraData;
@property (nonatomic, assign) BOOL isSubscription;

+ (GBInAppHelper *)Helper;

+ (BOOL)canMakePayments;
+ (GBError *)makeInAppError:(NSDictionary *)errorDictionary underlyingError:(NSError *)underlayingError;

//- (void)requestPaymentsWithMarketInfo:(void(^)(BOOL success, GBError *error))resultBlock;
- (void)requestProducts:(NSSet *)identifiers
                success:(GBProductsRequestSuccessBlock)successBlock
                failure:(GBProductsRequestFailureBlock)failureBlock;

//- (void)preparePayment:(GBErrorHandler)handler;
- (void)addPayment:(NSString *)productId paymentKey:(NSString *)key result:(GBAddPaymentAction *)resultAction;

- (void)excutePayment:(NSString *)productIdentifier parameter:(GBAddPaymentAction *)parameters;
- (void)restorePayment:(void (^)(NSArray *paymentKeys))resultBlock;
//- (void)retryPayment:(void (^)(NSArray *retryPaymentKeys))resultBlock;
// - GBProductRequestDelegate

- (void)addProduct:(SKProduct *)product;
- (void)removeProductsRequestDelegate:(GBProductRequestDelegate *)delegate;

- (void)savedReception:(void(^)(NSString *paymentKey, GBError *error))resultBlock;
- (NSArray *)transactions;

@end
