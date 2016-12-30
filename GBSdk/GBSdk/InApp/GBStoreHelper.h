//
//  GBStoreHelper.h
//  GB
//
//  Created by Professional on 2014. 6. 12..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "GBRequest.h"
#import "GBProductRequestDelegate.h"
#import "GBAddPaymentAction.h"

#ifdef _JOYPLE_ANALYTICS_
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#endif

@class GBError;

typedef void(^GBErrorHandler)(GBError *error);

@interface GBStoreHelper : NSObject<SKPaymentTransactionObserver>

@property (nonatomic, strong) NSString *userKey;

@property (nonatomic, copy) NSString *extraData;
@property (nonatomic, assign) BOOL isSubscription;

+ (GBStoreHelper *)defaultStore;

+ (BOOL)canMakePayments;

- (void)requestPaymentsWithMarketInfo:(void(^)(BOOL success, GBError *error))resultBlock;
- (void)requestProducts:(NSSet *)identifiers
                success:(GBProductsRequestSuccessBlock)successBlock
                failure:(GBProductsRequestFailureBlock)failureBlock;

- (void)preparePayment:(GBErrorHandler)handler;
- (void)excutePayment:(NSString *)productIdentifier parameter:(GBAddPaymentAction *)parameters;
- (void)restorePayment:(void (^)(NSArray *paymentKeys))resultBlock;
//- (void)retryPayment:(void (^)(NSArray *retryPaymentKeys))resultBlock;
// - GBProductRequestDelegate

- (void)addProduct:(SKProduct *)product;
- (void)removeProductsRequestDelegate:(GBProductRequestDelegate *)delegate;

- (void)savedReception:(void(^)(NSString *paymentKey, GBError *error))resultBlock;
- (NSArray *)transactions;

@end
