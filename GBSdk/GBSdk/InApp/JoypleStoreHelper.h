//
//  JoypleStoreHelper.h
//  Joyple
//
//  Created by Professional on 2014. 6. 12..
//  Copyright (c) 2014년 Joycity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "JoypleRequest.h"
#import "JoypleProductRequestDelegate.h"
#import "JoypleAddPaymentAction.h"

#ifdef _JOYPLE_ANALYTICS_
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#endif

@class JoypleError;

typedef void(^JoypleErrorHandler)(JoypleError *error);

@interface JoypleStoreHelper : NSObject<SKPaymentTransactionObserver>

@property (nonatomic, strong) NSString *userKey;

@property (nonatomic, copy) NSString *extraData;
@property (nonatomic, assign) BOOL isSubscription;

+ (JoypleStoreHelper *)defaultStore;

+ (BOOL)canMakePayments;

- (void)requestPaymentsWithMarketInfo:(void(^)(BOOL success, JoypleError *error))resultBlock;
- (void)requestProducts:(NSSet *)identifiers
                success:(JoypleProductsRequestSuccessBlock)successBlock
                failure:(JoypleProductsRequestFailureBlock)failureBlock;

- (void)preparePayment:(JoypleErrorHandler)handler;
- (void)excutePayment:(NSString *)productIdentifier parameter:(JoypleAddPaymentAction *)parameters;
- (void)restorePayment:(void (^)(NSArray *paymentKeys))resultBlock;
//- (void)retryPayment:(void (^)(NSArray *retryPaymentKeys))resultBlock;
// - JoypleProductRequestDelegate

- (void)addProduct:(SKProduct *)product;
- (void)removeProductsRequestDelegate:(JoypleProductRequestDelegate *)delegate;

- (void)savedReception:(void(^)(NSString *paymentKey, JoypleError *error))resultBlock;
- (NSArray *)transactions;

@end
