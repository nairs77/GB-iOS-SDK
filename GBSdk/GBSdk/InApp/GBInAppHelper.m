//
//  GBStoreHelper.m
//  GB
//
//  Created by Professional on 2014. 6. 12..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import "GBInAppHelper.h"
#import "GBProtocol+Store.h"
#import "GBLog+Store.h"
#import "GBError.h"
//#import "NSBundle+GB.h"
#import "GBDeviceUtil.h"
#import "GBReceiptVerificator.h"
#import "NSData+Formatter.h"
//#import "NSString+Hex.h"
//#import "GBRestoreManager.h"

#define IS_IOS7_OR_MORE ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface GBInAppHelper() <SKRequestDelegate>
@property (nonatomic, copy) NSString *paymentKey;

@end

@implementation GBInAppHelper
{
    NSMutableDictionary     *_validateProducts;
    NSMutableDictionary     *_paymentActions;
    NSMutableSet            *_requestDelegateSet;
    
    SKReceiptRefreshRequest *_refreshReceiptRequest;
    
    void (^refreshReceiptFailureBlock)(GBError *error);
    void (^refreshReceiptSuccessBlock)();
}

+ (GBInAppHelper *)Helper
{
    static id _instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _instance = [[GBInAppHelper alloc] init];
    });
    
    return _instance;
}

+ (BOOL)canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}

+ (GBError *)makeInAppError:(NSDictionary *)errorDictionary underlyingError:(NSError *)underlayingError
{
    if (underlayingError != nil) {
        return [GBError errorWithDomain:GBErrorDomain code:[underlayingError code] userInfo:@{NSUnderlyingErrorKey : underlayingError}];//[underlayingError userInfo]];
        
    } else {
        int errorCode = [[errorDictionary objectForKey:@"errorCode"] intValue];
        
        return [GBError errorWithDomain:GBErrorDomain
                                   code:errorCode
                               userInfo:nil];
    }
}

- (id)init
{
    if (self = [super init]) {
        _validateProducts = [NSMutableDictionary dictionary];
        _paymentActions = [NSMutableDictionary dictionary];
        _requestDelegateSet = [NSMutableSet set];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
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
            GBLogVerbose(@"verifyTranscation is failed!!!");
//            [GBLog sendToGBServerAboutExceptionLog:@{@"GB":@"Restore transactions but still nothing receipt..",@"UserKey":[GBSetting currentSetting].userKey}];
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
    
    GBProtocol *protocol = [GBProtocol makeRequestPayment:GB_SAVE_RECEIPT param:parameter];
    GBApiRequest *request = [GBApiRequest makeRequestWithProtocol:protocol];
    
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
            if ([[errorDictionary objectForKey:@"errorCode"]intValue] + INAPP_ERROR_BASE != INAPP_ERROR_SERVER_INTERNAL) {
                [self finishedTransaction:transaction queue:queue];
            }
            
            GBError *errorResult = [GBInAppHelper makeInAppError:errorDictionary underlyingError:nil];
            
            if (resultBlock != nil) {
                resultBlock(nil, errorResult);
            }
        }
        
    } failure:^(NSError *error, id JSON) {
        
        GBError *errorResult = [GBInAppHelper makeInAppError:[JSON objectForKey:@"error"] underlyingError:error];
        
        if (resultBlock != nil) {
            resultBlock(nil, errorResult);
            
        }
    }];
    
}

- (NSArray *)transactions
{
    return [[SKPaymentQueue defaultQueue]transactions];
}

/*
- (void)requestPaymentsWithMarketInfo:(void(^)(BOOL success, GBError *error))resultBlock
{
    GBProtocol *protocol = [GBProtocol makeRequestPayment:GB_MARKET_INFO param:nil];
    GBApiRequest *request = [GBApiRequest makeRequestWithProtocol:protocol];
    
    GBLogVerbose(@"Request Market Info");
    
    [request excuteRequestWithBlock:^(id JSON) {
        int errorStatus = [[JSON objectForKey:@"status"] intValue];
        NSDictionary *result = [JSON objectForKey:@"result"];
        
        if (errorStatus != 0) {
            NSDictionary *marketInfo = [result objectForKey:@"market_info"];
            
            NSAssert(marketInfo != nil, @"ERROR Initialize");
            
//            NSString *xorBundleID = [NSString stringFromHex:[marketInfo objectForKey:@"bundleID"]];
//            NSData *encodeBundleData = [xorBundleID dataUsingEncoding:NSUTF8StringEncoding];
//            
//            NSString *bundleID = [encodeBundleData dataXORWithData:[GBSetting currentSetting].clientSecretKey];
//            
//            //if ([[GBSetting bundleIdentifier] isEqualToString:bundleID]) {
//            NSString *appBundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
//            
//            if ([appBundleID isEqualToString:bundleID]) {
//                resultBlock(YES, nil);
//            } else {
//                JLogInfo(@"Not Register Bundle ID = %@", bundleID);
//                resultBlock(NO, [GBError errorWithDomain:GBErrorDomain code:BILLING_ERROR_INVALID_APP userInfo:nil]);
//            }
            resultBlock(YES, nil);
            
        } else {
            resultBlock(NO, [GBError errorWithDomain:GBErrorDomain code:INAPP_ERROR_INITIALIZE userInfo:nil]);
        }
    } failure:^(NSError *error, id JSON) {
        resultBlock(NO, [GBError errorWithDomain:GBErrorDomain code:INAPP_ERROR_INITIALIZE userInfo:@{NSUnderlyingErrorKey :error}]);
    }];
}
*/
- (void)requestProducts:(NSSet *)identifiers
                success:(GBProductsRequestSuccessBlock)successBlock
                failure:(GBProductsRequestFailureBlock)failureBlock
{
    //TODO: Unit Test
    //[_productsRequestDelegates addObject:requestDelegate];
    
    GBLogVerbose(@"Requet Product Information to App Store");
    GBProductRequestDelegate *requestDelegate = [[GBProductRequestDelegate alloc] init];
    requestDelegate.store = self;
    requestDelegate.successBlock = successBlock;
    requestDelegate.failureBlock = failureBlock;
    
    [_requestDelegateSet addObject:requestDelegate];
    
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
    
    GBProtocol *protocol = [GBProtocol makeRequestPayment:GB_GET_IAB_TOKEN param:parameter];
    GBApiRequest *request = [GBApiRequest makeRequestWithProtocol:protocol];
    
    GBLogVerbose(@"Request IAB Token to Billing Server");
    
    [request excuteRequestWithBlock:^(id JSON) {
        
        int errorStatus = [[JSON objectForKey:@"status"] intValue];
        NSDictionary *result = [JSON objectForKey:@"result"];
        
        if (errorStatus != 0) { // TRUE
            NSString *paymentKey = [result objectForKey:@"payment_key"];
            
            self.paymentKey = paymentKey;
            
            GBLogError(@"paymentKeys = %@", self.paymentKey);
            
            if (errorHandler != nil)
                errorHandler(nil);
            
        } else {
            NSDictionary *errorDictionary = [JSON objectForKey:@"error"];
            
            GBError *errorResult = [GBInAppHelper makeInAppError:errorDictionary underlyingError:nil];
            
            
            if (errorHandler != nil) {
                errorHandler(errorResult);
            }
        }
    } failure:^(NSError *error, id JSON) {
        //FIXME:
        GBError *errorResult = [GBInAppHelper makeInAppError:[JSON objectForKey:@"error"] underlyingError:error];
        
        if (errorHandler != nil) {
            errorHandler(errorResult);
        }
    }];
}

- (void)addPayment:(NSString *)productId paymentKey:(NSString *)key result:(GBAddPaymentAction *)resultAction
{
    self.paymentKey = key;
    
    [self excutePayment:productId parameter:resultAction];
}

- (void)excutePayment:(NSString *)productIdentifier parameter:(id)parameters
{
    _paymentActions[productIdentifier] = parameters;
    
    GBLogVerbose(@"Reuqest to buy a item!!!");
    SKProduct *product = [self productForIdentifier:productIdentifier];
    
    if (product == nil) {
        
        GBAddPaymentAction *action = _paymentActions[productIdentifier];
        [_paymentActions removeObjectForKey:productIdentifier];
        
        
        self.paymentKey = nil;
        //[paymentKeys_ removeLastObject];
        
        if (action.failureBlock != nil) {
            GBError *wrappedError = [GBError errorWithDomain:GBErrorDomain
                                                        code:INAPP_ERROR_INVALID_ITEM
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
    GBProtocol *protocol = [GBProtocol makeRequestPayment:GB_RESTORE param:nil];
    GBApiRequest *request = [GBApiRequest makeRequestWithProtocol:protocol];
    
    GBLogVerbose(@"Reuqest to restore a items...");
    
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
    //                        GBLogVerbose(@"%@",error);
    //                    }
    //                }];
    //            }
    //        }
    //    } else {
    //        GBLogVerbose(@"iOS6 Error");
    //    }
}

- (void)addProduct:(SKProduct *)product
{
    _validateProducts[product.productIdentifier] = product;
}

- (SKProduct *)productForIdentifier:(NSString *)productIdentifier
{
    return _validateProducts[productIdentifier];
}

- (void)removeProductsRequestDelegate:(GBProductRequestDelegate *)delegate
{
    [_requestDelegateSet removeObject:delegate];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                GBLogVerbose(@"Purchase Success!!!");
                [self didPurchaseTransaction:transaction queue:queue];
                break;
            case SKPaymentTransactionStateFailed:
                GBLogVerbose(@"Purchase Failed!!!");
                [self didFailTransaction:transaction queue:queue error:transaction.error];
                break;
            case SKPaymentTransactionStateRestored:
                GBLogVerbose(@"Purchase Restore!!!");
//                [GBLog sendToGBServerAboutExceptionLog:@{@"Apple":@"Apple Purchase Restored",@"UserKey":[GBSetting currentSetting].userKey}];
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
    GBLogVerbose(@"transaction purchased with product %@", transaction.payment.productIdentifier);
    
    //- Commented subscription
/*
    if (IS_IOS7_OR_MORE) {
        if ([transaction payment].applicationUsername == nil && !self.paymentKey) {
            
            if (transaction.originalTransaction == nil) {
                [self finishedTransaction:transaction queue:queue];
                return;
            }
            
            NSDictionary *transactionIds = @{@"transaction_id" : transaction.transactionIdentifier, @"original_transaction_id" : transaction.originalTransaction.transactionIdentifier};
            
            GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_CHECK_SUBSCRIPTION param:transactionIds];
            GBApiRequest *request = [GBApiRequest makeRequestWithProtocol:protocol];
            
            [request excuteRequestWithBlock:^(id JSON) {
                [self finishedTransaction:transaction queue:queue];
                GBLogVerbose(@"Sent to server [%@, %@] transaction ids", transaction.transactionIdentifier, transaction.originalTransaction.transactionIdentifier);
            } failure:^(NSError *error, id JSON) {
                GBLogVerbose(@"Sent error [%@, %@] transaction ids", transaction.transactionIdentifier, transaction.originalTransaction.transactionIdentifier);
            }];
            
            return;
            
        }
    }
*/
    GBReceiptVerificator *receiptVerificator = [[GBReceiptVerificator alloc] init];
    
    [receiptVerificator verifyTransaction:transaction success:^(NSString *base64EncodingData) {
        
        [self didVerifyTransaction:transaction queue:queue receipt:base64EncodingData];
        
    } failure:^(GBError *error) {
        GBLogVerbose(@"verifyTranscation is failed!!!");
        
        [self _requestNewReceipt:^(BOOL success, GBError *error) {
            if (success) {
                
                [receiptVerificator verifyTransaction:transaction success:^(NSString *base64EncodingData) {
                    [self didVerifyTransaction:transaction queue:queue receipt:base64EncodingData];
                } failure:^(GBError *error) {
//                    [GBLog sendToGBServerAboutExceptionLog:@{@"GB":@"Retryed receipt but still nothing receipt..",@"UserKey":[GBSetting currentSetting].userKey}];
                }];
                
            } else {
//                [GBLog sendToGBServerAboutExceptionLog:@{@"GB":@"Retryed receipt but user may cancel that request app store re-login",@"UserKey":[GBSetting currentSetting].userKey}];
            }
        }];
        
    }];
    
}

- (void)didFailTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue error:(NSError*)error
{
    
    SKPayment *payment = [transaction payment];
    
    GBAddPaymentAction *action = _paymentActions[payment.productIdentifier];
    
//    [GBLog sendToGBServerAboutExceptionLog:@{@"Apple":@"Apple Purchase Failed",@"UserKey":[GBSetting currentSetting].userKey,@"Error Code":[NSNumber numberWithInteger:[error code]]}];
    
    //[GBRestoreManager clearRestorePaymentKeyViaTransactionId:transaction.transactionIdentifier];
    
    [queue finishTransaction:transaction];
    
    if (error != nil) {
        
        int errorCode = (int)[error code];
        
        GBError *wrappedError = nil;
        
        if (errorCode == SKErrorPaymentCancelled) {
            wrappedError = [GBError errorWithDomain:GBErrorDomain code:INAPP_ERROR_FROM_STORE_CANCELED userInfo:nil];
        } else {
            wrappedError = [GBError errorWithDomain:GBErrorDomain code:[error code] userInfo:@{NSUnderlyingErrorKey : error}];
        }
        
        //[_paymentActions removeObjectForKey:payment.productIdentifier];
        
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
        
        GBLogError(@"Error Code = %ld, Error Description = %@", (long)[transactionError code], [transactionError localizedDescription]);
    }
    
    GBLogError(@"Transaction Error is NULL!!!!");
    
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
    GBLogVerbose(@"transaction restored with product %@", transaction.originalTransaction.payment.productIdentifier);
    
    SKPayment *payment = [transaction payment];
    
    GBAddPaymentAction *action = _paymentActions[payment.productIdentifier];
    
    NSError *transactionError = [transaction error];
    
    if (transactionError != nil) {
        if (action.failureBlock != nil) {
            action.failureBlock([GBError errorWithDomain:GBErrorDomain
                                                        code:[transactionError code]
                                                    userInfo:@{NSUnderlyingErrorKey : transactionError}]);
        }
        
        GBLogError(@"Error Code = %ld, Error Description = %@", (long)[transactionError code], [transactionError localizedDescription]);
        
        return;
    }
    
    GBReceiptVerificator *receiptVerificator = [[GBReceiptVerificator alloc] init];
    
    [receiptVerificator verifyTransaction:transaction success:^(NSString *base64EncodingData) {
        [self didVerifyTransaction:transaction queue:queue receipt:base64EncodingData];
    } failure:^(GBError *error) {
        GBLogVerbose(@"didRestoreTransaction - verifyTranscation is failed!!!");
//        [GBLog sendToGBServerAboutExceptionLog:@{@"GB":@"Retryed receipt but still nothing receipt...",@"UserKey":[GBSetting currentSetting].userKey}];
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
    
    GBLogVerbose(@"payment Key = %@", self.paymentKey);
    
    GBProtocol *protocol = [GBProtocol makeRequestPayment:GB_SAVE_RECEIPT param:parameter];
    GBApiRequest *request = [GBApiRequest makeRequestWithProtocol:protocol];
    
    [request excuteRequestWithBlock:^(id JSON) {
        
        int errorStatus = [[JSON objectForKey:@"status"] intValue];
        NSDictionary *result = [JSON objectForKey:@"result"];
        
//        [GBLog sendToGBServerAboutExceptionLog:@{@"GB":@"Received GB Purchase Success Callback!!!",@"UserKey":[GBSetting currentSetting].userKey,@"Callback JSON":JSON!=nil?JSON:@"null"}];
        
        if (errorStatus != 0) {
            [self finishedTransaction:transaction queue:queue];
            
            NSString *paymentKey = [result objectForKey:@"payment_key"];
            
            GBAddPaymentAction *action = _paymentActions[payment.productIdentifier];
            [_paymentActions removeObjectForKey:payment.productIdentifier];
            
            if (action.successBlock != nil) {
                action.successBlock(paymentKey);
            }
            
        } else {
            // Between SDK and Server failed
            NSDictionary *errorDictionary = [JSON objectForKey:@"error"];
            
            //if ([[errorDictionary objectForKey:@"errorCode"] intValue] == -106) {
            //     NSLog(@"영수증: [%@], 트랜잭션아이디: [%@]",receipt, transaction.transactionIdentifier);
            //}
            
            if ([[errorDictionary objectForKey:@"errorCode"] intValue] + INAPP_ERROR_BASE != INAPP_ERROR_SERVER_INTERNAL) {
                [self finishedTransaction:transaction queue:queue];
            }
            
            GBAddPaymentAction *action = _paymentActions[payment.productIdentifier];
            [_paymentActions removeObjectForKey:payment.productIdentifier];
            
            GBError *errorResult = [GBInAppHelper makeInAppError:errorDictionary underlyingError:nil];
            
            if (action.failureBlock != nil) {
                action.failureBlock(errorResult);
            }
            // Retry...
        }
        
    } failure:^(NSError *error, id JSON) {
        
//        [GBLog sendToGBServerAboutExceptionLog:@{@"GB":@"Received GB Purchase Failed Callback!!!",@"UserKey":[GBSetting currentSetting].userKey,@"Callback JSON":JSON!=nil?JSON:@"null"}];
        // Retry...
        
        GBAddPaymentAction *action = _paymentActions[payment.productIdentifier];
        [_paymentActions removeObjectForKey:payment.productIdentifier];
        
        GBError *errorResult = [GBInAppHelper makeInAppError:[JSON objectForKey:@"error"] underlyingError:error];
        
        if (action.failureBlock != nil) {
            action.failureBlock(errorResult);
            
        }
    }];
    
}

#pragma mark - SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request
{
    GBLogVerbose(@"refresh receipt finished");
    
    _refreshReceiptRequest = nil;
    
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
    GBLogVerbose(@"refresh receipt failed with error %@", error.debugDescription);
    _refreshReceiptRequest = nil;
    
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
    _refreshReceiptRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
    _refreshReceiptRequest.delegate = self;
    [_refreshReceiptRequest start];
}

- (void)finishedTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue
{
    self.paymentKey = nil;
    //    [GBRestoreManager clearRestorePaymentKeyViaTransactionId:transaction.transactionIdentifier];
    [queue finishTransaction:transaction];
    GBLogError(@"Delete PaymentKey!!!");
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
     GBApiRequest *request = [GBApiRequest makeRequestWithProtocol:protocol];
     
     GBLogVerbose(@"Reuqest to restore a items...");
     
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

