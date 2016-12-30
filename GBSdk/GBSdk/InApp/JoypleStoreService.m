//
//  JoypleStoreService.m
//  Joyple
//
//  Created by Professional on 2014. 6. 12..
//  Copyright (c) 2014년 Joycity. All rights reserved.
//

#import "JoypleStoreService.h"
#import "JoypleStoreHelper.h"
#import "JoypleAddPaymentAction.h"
#import "NSBundle+Joyple.h"
#import "JoypleRequest.h"
#import "JoypleProtocol+Store.h"
#import "JoypleDeviceUtil.h"
#import "JoypleUtil.h"
#import "JoypleLog.h"
#import "JoypleError.h"

@implementation JoypleStoreService

+ (void)startStoreService:(void (^)(BOOL success, JoypleError *error))resultBlock
{
    if ([JoypleDeviceUtil isRooting]) {
        resultBlock(NO, [JoypleError errorWithDomain:JoypleErrorDomain code:BILLING_ERROR_INVALID_DEVICE userInfo:nil]);
        return;
    }
    
    BOOL result = [JoypleStoreHelper canMakePayments];
    
    if (!result) {
        resultBlock(NO, [JoypleError errorWithDomain:JoypleErrorDomain code:BILLING_ERROR_ALLOWED_PAYMENT userInfo:nil]);
        return;
    }
    
    [[JoypleStoreHelper defaultStore] requestPaymentsWithMarketInfo:resultBlock];
}

+ (void)startStoreServiceAlone:(NSString *)userKey result:(void (^)(BOOL success, JoypleError *error))resultBlock
{
    /*
     if ([JoypleDeviceUtil isRooting]) {
     resultBlock(NO, [JoypleError errorWithDomain:JoypleErrorDomain code:BILLING_ERROR_INVALID_DEVICE userInfo:nil]);
     return;
     }
     
     BOOL result = [JoypleStoreHelper canMakePayments];
     
     if (!result) {
     resultBlock(NO, [JoypleError errorWithDomain:JoypleErrorDomain code:BILLING_ERROR_ALLOWED_PAYMENT userInfo:nil]);
     return;
     }
     
     [JoypleSetting currentSetting].userKey = userKey;
     [[JoypleStoreHelper defaultStore] requestPaymentsWithMarketInfo:resultBlock];
     */
    [JoypleSetting currentSetting].userKey = userKey;
    
    [JoypleStoreService startStoreService:resultBlock];
}

#pragma mark - StoreKit Wrapping

+ (void)requestProducts:(NSSet *)identifiers
                success:(void (^)(NSArray *, NSArray *))successBlock
                failure:(void (^)(JoypleError *))failureBlock
{
    if (identifiers == nil || [identifiers count] == 0) {
        
        //FIXME: Edit Error Code & Error String
        //NSString *localizeString = JoypleLocalizedString(@"ui_billing_error_invalid_item", nil);
        JoypleError *failError = [JoypleError errorWithDomain:JoypleErrorDomain
                                                         code:BILLING_ERROR_INVALID_ITEM
                                                     userInfo:nil];
        failureBlock(failError);
        return;
    }
    
    [[JoypleStoreHelper defaultStore] requestProducts:identifiers success:successBlock failure:failureBlock];
}

+ (void)addPayment:(NSString *)productIdentifier
           success:(void (^)(NSString *paymentKey))successBlock
           failure:(void (^)(JoypleError *error))failureBlock
{
    [self addPayment:productIdentifier payload:nil subscription:NO success:successBlock failure:failureBlock];
}

+ (void)addPayment:(NSString *)productIdentifier
           payload:(NSString *)payload
      subscription:(BOOL)subscription
           success:(void (^)(NSString *paymentKey))successBlock
           failure:(void (^)(JoypleError *error))failureBlock
{
    if (productIdentifier == nil || [productIdentifier length] == 0)
        if (failureBlock != nil) {
            //            NSString *localizeString = JoypleLocalizedString(@"ui_billing_error_invalid_item", nil);
            JoypleError *failError = [JoypleError errorWithDomain:JoypleErrorDomain
                                                             code:BILLING_ERROR_INVALID_ITEM
                                                         userInfo:nil];
            failureBlock(failError);
        }
    
    //TODO: Request payment token
    
    [JoypleStoreHelper defaultStore].extraData = payload;
    [JoypleStoreHelper defaultStore].isSubscription = subscription;
    
    //    if ([[JoypleStoreHelper defaultStore] transactions].count != 0) {
    //        [[JoypleStoreHelper defaultStore] savedReception:^(NSString *paymentKey, JoypleError *error) {
    //
    //            if (paymentKey != nil) {
    //                successBlock(paymentKey);
    //            } else {
    //                failureBlock(error);
    //            }
    //
    //        }];
    //        return;
    //    }
    
    [[JoypleStoreHelper defaultStore] preparePayment:^(JoypleError *error) {
        if (error == nil) {
            JoypleAddPaymentAction *parameters = [[JoypleAddPaymentAction alloc] init];
            parameters.successBlock = successBlock;
            parameters.failureBlock = failureBlock;
            
            [[JoypleStoreHelper defaultStore] excutePayment:productIdentifier parameter:parameters];
        } else {
            failureBlock(error);
        }
    }];
}


+ (void)restorePayment:(void (^)(NSArray *paymentKeys))resultBlock
{
    [[JoypleStoreHelper defaultStore] restorePayment:resultBlock];
}

+ (void)retryPaymet:(void (^)(NSString *paymentKey))resultBlock
{
    //    [[JoypleStoreHelper defaultStore] retryPayment:resultBlock];
}


#pragma mark Store Test

+ (void)requestDownloadItem:(NSString *)paymentKey result:(void(^)(NSDictionary *itemInfo))resultBlock
{
    JoypleProtocol *protocol = [JoypleProtocol makeRequestPayment:JOYPLE_TEST_DOWNLOAD param:@{@"payment_key": paymentKey}];
    JoypleRequest *request = [JoypleRequest makeRequestWithProtocol:protocol];
    
    [request excuteRequestWithBlock:^(id JSON) {
        int errorStutus = [[JSON objectForKey:@"status"] intValue];
        
        if (errorStutus == ERROR_SUCCESS) {
            NSDictionary *result = [JSON objectForKey:@"result"];
            
            resultBlock(result);
        } else {
            JLogError(@"Download Failed!!!");
            
            resultBlock(nil);
        }
    }
                            failure:^(NSError *error, id JSON) {
                                JLogError(@"Download Failed!!!");
                                resultBlock(nil);
                            }];
}

+ (void)requestItemInventory:(void(^)(NSArray *items))resultBlock
{
    JoypleProtocol *protocol = [JoypleProtocol makeRequestPayment:JOYPLE_TEST_QUERY param:nil];
    JoypleRequest *request = [JoypleRequest makeRequestWithProtocol:protocol];
    
    [request excuteRequestWithBlock:^(id JSON) {
        NSArray *purchaseItems= [[JSON objectForKey:@"result"] objectForKey:@"item_list"];
        
        if ([JoypleUtil isValidate:purchaseItems])
            resultBlock(purchaseItems);
        else
            resultBlock(nil);
    }
                            failure:^(NSError *error, id JSON) {
                                JLogVerbose(@"");
                            }];
}

+ (void)requestPayInfo:(NSString *)paymentKey result:(void(^)(NSDictionary *itemInfo, JoypleError *error))resultBlock
{
    JoypleProtocol *protocol = [JoypleProtocol makeRequestPayment:JOYPLE_TEST_INFO param:@{@"payment_key": paymentKey}];
    JoypleRequest *request = [JoypleRequest makeRequestWithProtocol:protocol];
    
    [request excuteRequestWithBlock:^(id JSON) {
        int errorStutus = [[JSON objectForKey:@"status"] intValue];
        
        if (errorStutus == ERROR_SUCCESS) {
            NSDictionary *result = [JSON objectForKey:@"result"];
            
            resultBlock(result, nil);
        } else {
            
            NSDictionary *errorDictionary = [JSON objectForKey:@"error"];
            JoypleError *failError = [JoypleError errorWithDomain:JoypleErrorDomain
                                                             code:[[errorDictionary objectForKey:@"errorCode"] intValue]
                                                         userInfo:nil];
            resultBlock(nil, failError);
        }
    } failure:^(NSError *error, id JSON) {
        resultBlock(nil, error);
    }];
}

+ (void)requestSetLog:(NSDictionary *)payLog result:(void(^)(NSDictionary *itemInfo, JoypleError *error))resultBlock
{
    JoypleProtocol *protocol = [JoypleProtocol makeRequestPayment:JOYPLE_TEST_SET_LOG param:@{@"payment_key": [payLog objectForKey:@"payment_key"], @"product_price" : [payLog objectForKey:@"product_price"], @"product_name" : [payLog objectForKey:@"product_name"], @"money_type" : [payLog objectForKey:@"money_type"]}];
    JoypleRequest *request = [JoypleRequest makeRequestWithProtocol:protocol];
    
    [request excuteRequestWithBlock:^(id JSON) {
        int errorStutus = [[JSON objectForKey:@"status"] intValue];
        
        if (errorStutus == ERROR_SUCCESS) {
            NSDictionary *result = [JSON objectForKey:@"result"];
            
            resultBlock(result, nil);
        } else {
            NSDictionary *errorDictionary = [JSON objectForKey:@"error"];
            JoypleError *failError = [JoypleError errorWithDomain:JoypleErrorDomain
                                                             code:[[errorDictionary objectForKey:@"errorCode"] intValue]
                                                         userInfo:nil];
            resultBlock(nil, failError);
        }
    } failure:^(NSError *error, id JSON) {
        resultBlock(nil, error);
    }];
}


@end
