//
//  GBStoreHelper.m
//  GB
//
//  Created by Professional on 2014. 6. 12..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import "GBStoreHelper.h"
#import "GBProtocol+Store.h"
#import "GBLog+Store.h"
#import "GBError.h"
#import "NSBundle+GB.h"
#import "GBDeviceUtil.h"
#import "GBReceiptVerificator.h"
#import "NSData+Formatter.h"
#import "NSString+Hex.h"
//#import "GBRestoreManager.h"

#define IS_IOS7_OR_MORE ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface GBStoreHelper() <SKRequestDelegate>
@property (nonatomic, copy) NSString *paymentKey;
- (GBError *)makeBillingError:(NSDictionary *)errorDictionary underlyingError:(NSError *)underlayingError;
@end

@implementation GBStoreHelper
{
    NSMutableDictionary     *validateProducts_;
    NSMutableDictionary     *paymentAction_;
    NSMutableSet            *requestDelegateSet_;
    
    //NSMutableArray          *paymentKeys_;
    
    SKReceiptRefreshRequest *refreshReceiptRequest_;
    
    void (^refreshReceiptFailureBlock)(GBError *error);
    void (^refreshReceiptSuccessBlock)();
}

+ (GBStoreHelper *)defaultStore
{
    static id _instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _instance = [[GBStoreHelper alloc] init];
    });
    
    return _instance;
}

+ (BOOL)canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}

- (id)init
{
    if (self = [super init]) {
        validateProducts_ = [NSMutableDictionary dictionary];
        paymentAction_ = [NSMutableDictionary dictionary];
        requestDelegateSet_ = [NSMutableSet set];
        //paymentKeys_ = [[NSMutableArray alloc] initWithCapacity:0];
        //  [self _requestNewReceipt:^(BOOL success, GBError *error) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        //  }];
        
        
        /*
         __weak typeof(self) weakSelf = self;
         
         self.loadRestoreReceipt = ^(void) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
         [self _checkPurchaseError];
         
         });
         };
         */
    }
    
    return self;
}

- (void)savedReception:(void(^)(NSString *paymentKey, GBError *error))resultBlock;
{
    for (SKPaymentTransaction *transaction in [self transactions]) {
        
        if (transaction == nil || [transaction transactionState] == SKPaymentTransactionStatePurchasing) {
            continue;
        }
        
        if ([transaction transactionState] == SKPaymentTransactionStateFailed){
            [self finishedTransaction:transaction queue:[SKPaymentQueue defaultQueue]];
            continue;
        }
        
        
        GBReceiptVerificator *receiptVerificator = [[GBReceiptVerificator alloc] init];
        
        [receiptVerificator verifyTransaction:transaction success:^(NSString *base64EncodingData) {
            
            [self didRestoreTransaction:transaction queue:[SKPaymentQueue defaultQueue] receipt:base64EncodingData ResultBlock:^(NSString *paymentKey, GBError *error) {
                
                if (resultBlock != nil) {
                    resultBlock(paymentKey, error);
                }
                
            }];
            
        } failure:^(GBError *error) {
            JLogVerbose(@"verifyTranscation is failed!!!");
            [GBLog sendToGBServerAboutExceptionLog:@{@"GB":@"Restore transactions but still nothing receipt..",@"UserKey":[GBSetting currentSetting].userKey}];
        }];
    }
    
}

- (void)didRestoreTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue receipt:(NSString *)receipt ResultBlock:(void(^)(NSString *paymentKey, GBError *error))resultBlock;
{
    SKPayment *payment = transaction.payment;
    
    NSDictionary *parameter = @{@"payment_key": self.paymentKey /*!=nil?self.paymentKey:[[GBRestoreManager loadRestorePaymentKeysViaNSMutableArray]lastObject]*/,
                                @"product_id" : [payment productIdentifier],
                                @"order_id" : [NSString stringWithFormat:@"%d", (int)transaction.hash],
                                @"receipt" : [transaction transactionIdentifier],
                                @"transaction" : receipt};
    
    GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_SAVE_RECEIPT param:parameter];
    GBRequest *request = [GBRequest makeRequestWithProtocol:protocol];
    
    [request excuteRequestWithBlock:^(id JSON) {
        
        int errorStatus = [[JSON objectForKey:@"status"] intValue];
        NSDictionary *result = [JSON objectForKey:@"result"];
        
        if (errorStatus != 0) {
            [self finishedTransaction:transaction queue:queue];
            
            NSString *paymentKey = [result objectForKey:@"payment_key"];
            
            if (resultBlock != nil) {
                resultBlock(paymentKey, nil);
            }
            
        } else {
            NSDictionary *errorDictionary = [JSON objectForKey:@"error"];
            if ([[errorDictionary objectForKey:@"errorCode"]intValue] + BILLING_ERROR_BASE != BILLING_COMMON_SERVER_DB_ERROR) {
                [self finishedTransaction:transaction queue:queue];
            }
            
            GBError *errorResult = [self makeBillingError:errorDictionary underlyingError:nil];
            
            if (resultBlock != nil) {
                resultBlock(nil, errorResult);
            }
        }
        
    } failure:^(NSError *error, id JSON) {
        
        GBError *errorResult = [self makeBillingError:[JSON objectForKey:@"error"] underlyingError:error];
        
        if (resultBlock != nil) {
            resultBlock(nil, errorResult);
            
        }
    }];
    
}

- (NSArray *)transactions
{
    return [[SKPaymentQueue defaultQueue]transactions];
}

- (void)requestPaymentsWithMarketInfo:(void(^)(BOOL success, GBError *error))resultBlock
{
    GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_MARKET_INFO param:nil];
    GBRequest *request = [GBRequest makeRequestWithProtocol:protocol];
    
    JLogVerbose(@"Request Market Info");
    
    [request excuteRequestWithBlock:^(id JSON) {
        int errorStatus = [[JSON objectForKey:@"status"] intValue];
        NSDictionary *result = [JSON objectForKey:@"result"];
        
        if (errorStatus != 0) {
            NSDictionary *marketInfo = [result objectForKey:@"market_info"];
            
            NSAssert(marketInfo != nil, @"ERROR Initialize");
            
            NSString *xorBundleID = [NSString stringFromHex:[marketInfo objectForKey:@"bundleID"]];
            NSData *encodeBundleData = [xorBundleID dataUsingEncoding:NSUTF8StringEncoding];
            
            NSString *bundleID = [encodeBundleData dataXORWithData:[GBSetting currentSetting].clientSecretKey];
            
            //if ([[GBSetting bundleIdentifier] isEqualToString:bundleID]) {
            NSString *appBundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
            
            if ([appBundleID isEqualToString:bundleID]) {
                resultBlock(YES, nil);
            } else {
                JLogInfo(@"Not Register Bundle ID = %@", bundleID);
                resultBlock(NO, [GBError errorWithDomain:GBErrorDomain code:BILLING_ERROR_INVALID_APP userInfo:nil]);
            }
            
        } else {
            resultBlock(NO, [GBError errorWithDomain:GBErrorDomain code:BILLING_ERROR_INITIALIZE userInfo:nil]);
        }
    } failure:^(NSError *error, id JSON) {
        resultBlock(NO, [GBError errorWithDomain:GBErrorDomain code:BILLING_ERROR_INITIALIZE userInfo:@{NSUnderlyingErrorKey :error}]);
    }];
}

- (void)requestProducts:(NSSet *)identifiers
                success:(GBProductsRequestSuccessBlock)successBlock
                failure:(GBProductsRequestFailureBlock)failureBlock
{
    //TODO: Unit Test
    //[_productsRequestDelegates addObject:requestDelegate];
    
    JLogVerbose(@"Requet Product Information to App Store");
    GBProductRequestDelegate *requestDelegate = [[GBProductRequestDelegate alloc] init];
    requestDelegate.store = self;
    requestDelegate.successBlock = successBlock;
    requestDelegate.failureBlock = failureBlock;
    
    [requestDelegateSet_ addObject:requestDelegate];
    
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
    productsRequest.delegate = requestDelegate;
    
    [productsRequest start];
}

- (void)preparePayment:(void(^)(GBError *))errorHandler
{
    NSDictionary *parameter = nil;
    if (self.extraData != nil) {
        parameter = @{@"extra_data" : self.extraData};
    }
    
    GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_GET_IAB_TOKEN param:parameter];
    GBRequest *request = [GBRequest makeRequestWithProtocol:protocol];
    
    JLogVerbose(@"Request IAB Token to Billing Server");
    
    [request excuteRequestWithBlock:^(id JSON) {
        
        int errorStatus = [[JSON objectForKey:@"status"] intValue];
        NSDictionary *result = [JSON objectForKey:@"result"];
        
        if (errorStatus != 0) { // TRUE
            NSString *paymentKey = [result objectForKey:@"payment_key"];
            
            self.paymentKey = paymentKey;
            
            JLogError(@"paymentKeys = %@", self.paymentKey);
            
            if (errorHandler != nil)
                errorHandler(nil);
            
        } else {
            NSDictionary *errorDictionary = [JSON objectForKey:@"error"];
            
            GBError *errorResult = [self makeBillingError:errorDictionary underlyingError:nil];
            
            
            if (errorHandler != nil) {
                errorHandler(errorResult);
            }
        }
    } failure:^(NSError *error, id JSON) {
        //FIXME:
        GBError *errorResult = [self makeBillingError:[JSON objectForKey:@"error"] underlyingError:error];
        
        if (errorHandler != nil) {
            errorHandler(errorResult);
        }
    }];
}

- (void)excutePayment:(NSString *)productIdentifier parameter:(id)parameters
{
    
    paymentAction_[productIdentifier] = parameters;
    
    JLogVerbose(@"Reuqest to buy a item!!!");
    SKProduct *product = [self productForIdentifier:productIdentifier];
    
    if (product == nil) {
        
        GBAddPaymentAction *action = paymentAction_[productIdentifier];
        [paymentAction_ removeObjectForKey:productIdentifier];
        
        
        self.paymentKey = nil;
        //[paymentKeys_ removeLastObject];
        
        if (action.failureBlock != nil) {
            GBError *wrappedError = [GBError errorWithDomain:GBErrorDomain
                                                                code:BILLING_ERROR_INVALID_PRODUCT_ID
                                                            userInfo:nil];
            action.failureBlock(wrappedError);
            
            return;
        }
    } else {
        
    }
    
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    if (IS_IOS7_OR_MORE) {
        payment.applicationUsername = [NSString stringWithFormat:@"%@%@",self.isSubscription?@"sub":@"", self.paymentKey];
    }
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)restorePayment:(void (^)(NSArray *))resultBlock
{
    GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_RESTORE param:nil];
    GBRequest *request = [GBRequest makeRequestWithProtocol:protocol];
    
    JLogVerbose(@"Reuqest to restore a items...");
    
    [request excuteRequestWithBlock:^(id JSON) {
        int errorStatus = [[JSON objectForKey:@"status"] intValue];
        NSDictionary *result = [JSON objectForKey:@"result"];
        
        if (errorStatus != 0) { // TRUE
            NSArray *paymentKeys = [result objectForKey:@"payment_key"];
            
            if (resultBlock != nil)
                resultBlock(paymentKeys);
            
        } else {
            if (resultBlock != nil)
                resultBlock(nil);
        }
    } failure:^(NSError *error, id JSON) {
        if (resultBlock != nil)
            resultBlock(nil);
    }];
}
- (void)retryPayment:(void (^)(NSArray *retryPaymentKeys))resultBlock
{
    //    if ([GBRestoreManager existRestorePaymentkeys]) {
    //        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
    //
    //            NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    //            NSString *appRecPath = [receiptURL path];
    //
    //            if ([[NSFileManager defaultManager] fileExistsAtPath:appRecPath]) {
    //                [self _saveReceipt:receiptURL RetryPaymentKeys:^(NSArray *retryPaymentKeys) {
    //                    if (retryPaymentKeys)
    //                        resultBlock(retryPaymentKeys);
    //                    else
    //                        resultBlock(nil);
    //                }];
    //            } else {
    //                [self _requestNewReceipt:^(BOOL success, GBError *error) {
    //                    if (success) {
    //                        [self _saveReceipt:receiptURL RetryPaymentKeys:^(NSArray *retryPaymentKeys) {
    //                            if (retryPaymentKeys)
    //                                resultBlock(retryPaymentKeys);
    //                            else
    //                                resultBlock(nil);
    //                        }];
    //                    } else {
    //                        JLogVerbose(@"%@",error);
    //                    }
    //                }];
    //            }
    //        }
    //    } else {
    //        JLogVerbose(@"iOS6 Error");
    //    }
}

- (void)addProduct:(SKProduct *)product
{
    validateProducts_[product.productIdentifier] = product;
}

- (SKProduct *)productForIdentifier:(NSString *)productIdentifier
{
    return validateProducts_[productIdentifier];
}

- (void)removeProductsRequestDelegate:(GBProductRequestDelegate *)delegate
{
    [requestDelegateSet_ removeObject:delegate];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                JLogVerbose(@"Purchase Success!!!");
                [self didPurchaseTransaction:transaction queue:queue];
                break;
            case SKPaymentTransactionStateFailed:
                JLogVerbose(@"Purchase Failed!!!");
                [self didFailTransaction:transaction queue:queue error:transaction.error];
                break;
            case SKPaymentTransactionStateRestored:
                JLogVerbose(@"Purchase Restore!!!");
                [GBLog sendToGBServerAboutExceptionLog:@{@"Apple":@"Apple Purchase Restored",@"UserKey":[GBSetting currentSetting].userKey}];
                [self didRestoreTransaction:transaction queue:queue];
                break;
            default:
                break;
        }
    }
}

#pragma mark Transaction State

- (void)didPurchaseTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue
{
    JLogVerbose(@"transaction purchased with product %@", transaction.payment.productIdentifier);
    
    if (IS_IOS7_OR_MORE) {
        if ([transaction payment].applicationUsername == nil && !self.paymentKey) {
            
            if (transaction.originalTransaction == nil) {
                [self finishedTransaction:transaction queue:queue];
                return;
            }
            
            NSDictionary *transactionIds = @{@"transaction_id" : transaction.transactionIdentifier, @"original_transaction_id" : transaction.originalTransaction.transactionIdentifier};
            
            GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_CHECK_SUBSCRIPTION param:transactionIds];
            GBRequest *request = [GBRequest makeRequestWithProtocol:protocol];
            
            [request excuteRequestWithBlock:^(id JSON) {
                [self finishedTransaction:transaction queue:queue];
                JLogVerbose(@"Sent to server [%@, %@] transaction ids", transaction.transactionIdentifier, transaction.originalTransaction.transactionIdentifier);
            } failure:^(NSError *error, id JSON) {
                JLogVerbose(@"Sent error [%@, %@] transaction ids", transaction.transactionIdentifier, transaction.originalTransaction.transactionIdentifier);
            }];
            
            return;
            
        }
    }
    
    GBReceiptVerificator *receiptVerificator = [[GBReceiptVerificator alloc] init];
    
    [receiptVerificator verifyTransaction:transaction success:^(NSString *base64EncodingData) {
        
        [self didVerifyTransaction:transaction queue:queue receipt:base64EncodingData];
        
    } failure:^(GBError *error) {
        JLogVerbose(@"verifyTranscation is failed!!!");
        
        [self _requestNewReceipt:^(BOOL success, GBError *error) {
            if (success) {
                
                [receiptVerificator verifyTransaction:transaction success:^(NSString *base64EncodingData) {
                    [self didVerifyTransaction:transaction queue:queue receipt:base64EncodingData];
                } failure:^(GBError *error) {
                    [GBLog sendToGBServerAboutExceptionLog:@{@"GB":@"Retryed receipt but still nothing receipt..",@"UserKey":[GBSetting currentSetting].userKey}];
                }];
                
            } else {
                [GBLog sendToGBServerAboutExceptionLog:@{@"GB":@"Retryed receipt but user may cancel that request app store re-login",@"UserKey":[GBSetting currentSetting].userKey}];
            }
        }];
        
    }];
    
}

- (void)didFailTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue error:(NSError*)error
{
    
    SKPayment *payment = [transaction payment];
    
    GBAddPaymentAction *action = paymentAction_[payment.productIdentifier];
    
    [GBLog sendToGBServerAboutExceptionLog:@{@"Apple":@"Apple Purchase Failed",@"UserKey":[GBSetting currentSetting].userKey,@"Error Code":[NSNumber numberWithInteger:[error code]]}];
    
    //[GBRestoreManager clearRestorePaymentKeyViaTransactionId:transaction.transactionIdentifier];
    
    [queue finishTransaction:transaction];
    
    if (error != nil) {
        
        int errorCode = (int)[error code];
        
        GBError *wrappedError = nil;
        
        if (errorCode == SKErrorPaymentCancelled) {
            wrappedError = [GBError errorWithDomain:GBErrorDomain code:BILLING_ERROR_FROM_STORE_CANCELED userInfo:nil];
        } else {
            wrappedError = [GBError errorWithDomain:GBErrorDomain code:[error code] userInfo:@{NSUnderlyingErrorKey : error}];
        }
        
        //[paymentAction_ removeObjectForKey:payment.productIdentifier];
        
        if (action.failureBlock != nil) {
            action.failureBlock(wrappedError);
        }
        
        return;
    } else {
        NSError *transactionError = [transaction error];
        
        if (action.failureBlock != nil) {
            action.failureBlock([GBError errorWithDomain:GBErrorDomain
                                                        code:[transactionError code]
                                                    userInfo:@{NSUnderlyingErrorKey : transactionError}]);
        }
        
        JLogError(@"Error Code = %ld, Error Description = %@", (long)[transactionError code], [transactionError localizedDescription]);
    }
    
    JLogError(@"Transaction Error is NULL!!!!");
    
    /*
     GBReceiptVerificator *receiptVerificator = [[GBReceiptVerificator alloc] init];
     
     [receiptVerificator verifyTransaction:transaction
     success:^(NSString *base64EncodingData) {
     [self didVerifyTransaction:transaction queue:queue receipt:base64EncodingData];
     } failure:^(GBError *error) {
     if (action.failureBlock != nil)
     action.failureBlock([GBError errorWithDomain:GBErrorDomain code:[error code] userInfo:@{NSUnderlyingErrorKey : error}]);
     }];
     */
}

- (void)didRestoreTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue
{
    JLogVerbose(@"transaction restored with product %@", transaction.originalTransaction.payment.productIdentifier);
    
    SKPayment *payment = [transaction payment];
    
    GBAddPaymentAction *action = paymentAction_[payment.productIdentifier];
    
    NSError *transactionError = [transaction error];
    
    if (transactionError != nil) {
        if (action.failureBlock != nil) {
            action.failureBlock([GBError errorWithDomain:GBErrorDomain
                                                        code:[transactionError code]
                                                    userInfo:@{NSUnderlyingErrorKey : transactionError}]);
        }
        
        JLogError(@"Error Code = %ld, Error Description = %@", (long)[transactionError code], [transactionError localizedDescription]);
        
        return;
    }
    
    GBReceiptVerificator *receiptVerificator = [[GBReceiptVerificator alloc] init];
    
    [receiptVerificator verifyTransaction:transaction success:^(NSString *base64EncodingData) {
        [self didVerifyTransaction:transaction queue:queue receipt:base64EncodingData];
    } failure:^(GBError *error) {
        JLogVerbose(@"didRestoreTransaction - verifyTranscation is failed!!!");
        [GBLog sendToGBServerAboutExceptionLog:@{@"GB":@"Retryed receipt but still nothing receipt...",@"UserKey":[GBSetting currentSetting].userKey}];
        if (action.failureBlock != nil){
            action.failureBlock([GBError errorWithDomain:GBErrorDomain code:[error code] userInfo:@{NSUnderlyingErrorKey : error}]);
        }
    }];
    
    //[GBRestoreManager clearRestorePaymentKeyViaTransactionId:transaction.transactionIdentifier];
    
    [queue finishTransaction: transaction];
    
}

- (void)didVerifyTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue receipt:(NSString *)receipt
{
    SKPayment *payment = transaction.payment;
    
    NSString *paymentKey = self.paymentKey;
    BOOL is_subscription = self.isSubscription;
    
    if (IS_IOS7_OR_MORE) {
        if (paymentKey == nil) {
            if (![payment.applicationUsername hasPrefix:@"sub"]) {
                paymentKey = payment.applicationUsername;
            } else {
                NSMutableString *paymentUsrName = [NSMutableString stringWithString:[payment applicationUsername]];
                paymentKey = [paymentUsrName stringByReplacingOccurrencesOfString:@"sub" withString:@""];
                is_subscription = YES;
            }
        }
    } else {
        if (paymentKey == nil) {
            paymentKey = (id)[NSNull null];
        }
    }
    
    NSDictionary *parameter = @{@"payment_key": paymentKey,
                                @"product_id" : [payment productIdentifier],
                                @"order_id" : [NSString stringWithFormat:@"%d", (int)transaction.hash],
                                @"receipt" : [transaction transactionIdentifier],
                                @"transaction" : receipt,
                                @"is_subscription" : [NSNumber numberWithBool:is_subscription]};
    
    JLogVerbose(@"payment Key = %@", self.paymentKey);
    
    GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_SAVE_RECEIPT param:parameter];
    GBRequest *request = [GBRequest makeRequestWithProtocol:protocol];
    
    [request excuteRequestWithBlock:^(id JSON) {
        
        int errorStatus = [[JSON objectForKey:@"status"] intValue];
        NSDictionary *result = [JSON objectForKey:@"result"];
        
        [GBLog sendToGBServerAboutExceptionLog:@{@"GB":@"Received GB Purchase Success Callback!!!",@"UserKey":[GBSetting currentSetting].userKey,@"Callback JSON":JSON!=nil?JSON:@"null"}];
        
        if (errorStatus != 0) {
            [self finishedTransaction:transaction queue:queue];
            
            NSString *paymentKey = [result objectForKey:@"payment_key"];
            
            GBAddPaymentAction *action = paymentAction_[payment.productIdentifier];
            [paymentAction_ removeObjectForKey:payment.productIdentifier];
            
            if (action.successBlock != nil) {
                action.successBlock(paymentKey);
            }
            
        } else {
            // Between SDK and Server failed
            NSDictionary *errorDictionary = [JSON objectForKey:@"error"];
            
            //if ([[errorDictionary objectForKey:@"errorCode"] intValue] == -106) {
            //     NSLog(@"영수증: [%@], 트랜잭션아이디: [%@]",receipt, transaction.transactionIdentifier);
            //}
            
            if ([[errorDictionary objectForKey:@"errorCode"] intValue] + BILLING_ERROR_BASE != BILLING_COMMON_SERVER_DB_ERROR) {
                [self finishedTransaction:transaction queue:queue];
            }
            
            GBAddPaymentAction *action = paymentAction_[payment.productIdentifier];
            [paymentAction_ removeObjectForKey:payment.productIdentifier];
            
            GBError *errorResult = [self makeBillingError:errorDictionary underlyingError:nil];
            
            if (action.failureBlock != nil) {
                action.failureBlock(errorResult);
            }
            // Retry...
        }
        
    } failure:^(NSError *error, id JSON) {
        
        [GBLog sendToGBServerAboutExceptionLog:@{@"GB":@"Received GB Purchase Failed Callback!!!",@"UserKey":[GBSetting currentSetting].userKey,@"Callback JSON":JSON!=nil?JSON:@"null"}];
        // Retry...
        
        GBAddPaymentAction *action = paymentAction_[payment.productIdentifier];
        [paymentAction_ removeObjectForKey:payment.productIdentifier];
        
        GBError *errorResult = [self makeBillingError:[JSON objectForKey:@"error"] underlyingError:error];
        
        if (action.failureBlock != nil) {
            action.failureBlock(errorResult);
            
        }
    }];
    
}

#pragma mark - SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request
{
    JLogVerbose(@"refresh receipt finished");
    
    refreshReceiptRequest_ = nil;
    
    if (refreshReceiptSuccessBlock) {
        refreshReceiptSuccessBlock();
        refreshReceiptSuccessBlock = nil;
    } else {
        refreshReceiptFailureBlock([GBError errorWithDomain:GBErrorDomain code:0 userInfo:nil]);
        refreshReceiptFailureBlock = nil;
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    JLogVerbose(@"refresh receipt failed with error %@", error.debugDescription);
    refreshReceiptRequest_ = nil;
    
    if (refreshReceiptFailureBlock) {
        //TODO: Error code & Error Message
        refreshReceiptFailureBlock([GBError errorWithDomain:GBErrorDomain code:[error code] userInfo:@{NSUnderlyingErrorKey : error}]);
        refreshReceiptFailureBlock = nil;
    }
}

#pragma mark - Private Methods
- (void)refreshReceiptOnSuccess:(void (^)())successBlock
                        failure:(void (^)(GBError *error))failureBlock
{
    refreshReceiptFailureBlock = failureBlock;
    refreshReceiptSuccessBlock = successBlock;
    refreshReceiptRequest_ = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
    refreshReceiptRequest_.delegate = self;
    [refreshReceiptRequest_ start];
}

- (void)finishedTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue
{
    self.paymentKey = nil;
    //    [GBRestoreManager clearRestorePaymentKeyViaTransactionId:transaction.transactionIdentifier];
    [queue finishTransaction:transaction];
    JLogError(@"Delete PaymentKey!!!");
}

- (GBError *)makeBillingError:(NSDictionary *)errorDictionary underlyingError:(NSError *)underlayingError
{
    if (underlayingError != nil) {
        return [GBError errorWithDomain:GBErrorDomain code:[underlayingError code] userInfo:@{NSUnderlyingErrorKey : underlayingError}];//[underlayingError userInfo]];
        
    } else {
        int errorCode = [[errorDictionary objectForKey:@"errorCode"] intValue];
        
        NSString *localizedStringKey = nil;
        
        int newErrorCode = BILLING_ERROR_BASE + errorCode;
        
        if (newErrorCode == BILLING_ERROR_PAY_BLOCK_USER) {
            localizedStringKey = GBLocalizedString(@"ui_billing_pay_block_user", nil);
        } else {
            localizedStringKey = [NSString stringWithFormat:GBLocalizedString(@"ui_billing_common_error (%d)", nil), newErrorCode];
        }
        
        return [GBError errorWithDomain:GBErrorDomain
                                       code:newErrorCode
                                   userInfo:nil];
    }
    
}

- (void)_saveReceipt:(NSURL *)aReceiptURL RetryPaymentKeys:(void (^)(NSArray *))resultBlock
{
    /*
     NSData *rawReceipt = [NSData dataWithContentsOfURL:aReceiptURL];
     
     NSString *receipt = [rawReceipt stringByBase64Encoding];
     
     NSMutableArray *restoreInfoArray = [GBRestoreManager loadRestorePaymentKeysViaNSMutableArray];
     
     for (NSDictionary *restoreDic in restoreInfoArray) {
     
     NSDictionary *parameter = @{@"payment_key": [restoreDic objectForKey:@"payment_key"],
     @"product_id" : [restoreDic objectForKey:@"product_id"],
     @"order_id" : [GBSetting currentSetting].userKey,
     @"receipt" : [restoreDic objectForKey:@"payment_key"],
     @"transaction" : receipt};
     
     GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_SAVE_RECEIPT param:parameter];
     GBRequest *request = [GBRequest makeRequestWithProtocol:protocol];
     
     JLogVerbose(@"Reuqest to restore a items...");
     
     [request excuteRequestWithBlock:^(id JSON) {
     [GBRestoreManager clearFirstRestorePaymentKey];
     int errorStatus = [[JSON objectForKey:@"status"] intValue];
     NSDictionary *result = [JSON objectForKey:@"result"];
     
     [self sendToGBServerAboutExceptionLog:@{@"GB Restore":@"Received GB Restore Success Callback!!!",@"UserKey":[GBSetting currentSetting].userKey,@"Callback JSON":JSON!=nil?JSON:@"null"}];
     if (errorStatus != 0) {
     NSArray *paymentKeys = [result objectForKey:@"payment_key"];
     if (resultBlock != nil)
     resultBlock(paymentKeys);
     } else {
     if (resultBlock != nil)
     resultBlock(nil);
     }
     } failure:^(NSError *error, id JSON) {
     [GBRestoreManager clearFirstRestorePaymentKey];
     [self sendToGBServerAboutExceptionLog:@{@"GB Restore":@"Received GB Restore Fail Callback!!!",@"UserKey":[GBSetting currentSetting].userKey,@"Callback JSON":JSON!=nil?JSON:@"null"}];
     if (resultBlock != nil)
     resultBlock(nil);
     }];
     }
     */
}

- (void)_requestNewReceipt:(void(^)(BOOL success, GBError *error))resultBlock;
{
    [self refreshReceiptOnSuccess:^{
        if (resultBlock != nil)
            resultBlock(YES, nil);
    } failure:^(GBError *error) {
        if (resultBlock != nil)
            resultBlock(NO, error);
    }];
}

@end

