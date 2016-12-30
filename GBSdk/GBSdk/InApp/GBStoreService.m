//
//  GBStoreService.m
//  GB
//
//  Created by Professional on 2014. 6. 12..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import "GBStoreService.h"
#import "GBStoreHelper.h"
#import "GBAddPaymentAction.h"
#import "NSBundle+GB.h"
#import "GBRequest.h"
#import "GBProtocol+Store.h"
#import "GBDeviceUtil.h"
#import "GBUtil.h"
#import "GBLog.h"
#import "GBError.h"

@implementation GBStoreService

+ (void)startStoreService:(void (^)(BOOL success, GBError *error))resultBlock
{
    if ([GBDeviceUtil isRooting]) {
        resultBlock(NO, [GBError errorWithDomain:GBErrorDomain code:BILLING_ERROR_INVALID_DEVICE userInfo:nil]);
        return;
    }
    
    BOOL result = [GBStoreHelper canMakePayments];
    
    if (!result) {
        resultBlock(NO, [GBError errorWithDomain:GBErrorDomain code:BILLING_ERROR_ALLOWED_PAYMENT userInfo:nil]);
        return;
    }
    
    [[GBStoreHelper defaultStore] requestPaymentsWithMarketInfo:resultBlock];
}

+ (void)startStoreServiceAlone:(NSString *)userKey result:(void (^)(BOOL success, GBError *error))resultBlock
{
    /*
     if ([GBDeviceUtil isRooting]) {
     resultBlock(NO, [GBError errorWithDomain:GBErrorDomain code:BILLING_ERROR_INVALID_DEVICE userInfo:nil]);
     return;
     }
     
     BOOL result = [GBStoreHelper canMakePayments];
     
     if (!result) {
     resultBlock(NO, [GBError errorWithDomain:GBErrorDomain code:BILLING_ERROR_ALLOWED_PAYMENT userInfo:nil]);
     return;
     }
     
     [GBSetting currentSetting].userKey = userKey;
     [[GBStoreHelper defaultStore] requestPaymentsWithMarketInfo:resultBlock];
     */
    [GBSetting currentSetting].userKey = userKey;
    
    [GBStoreService startStoreService:resultBlock];
}

#pragma mark - StoreKit Wrapping

+ (void)requestProducts:(NSSet *)identifiers
                success:(void (^)(NSArray *, NSArray *))successBlock
                failure:(void (^)(GBError *))failureBlock
{
    if (identifiers == nil || [identifiers count] == 0) {
        
        //FIXME: Edit Error Code & Error String
        //NSString *localizeString = GBLocalizedString(@"ui_billing_error_invalid_item", nil);
        GBError *failError = [GBError errorWithDomain:GBErrorDomain
                                                         code:BILLING_ERROR_INVALID_ITEM
                                                     userInfo:nil];
        failureBlock(failError);
        return;
    }
    
    [[GBStoreHelper defaultStore] requestProducts:identifiers success:successBlock failure:failureBlock];
}

+ (void)addPayment:(NSString *)productIdentifier
           success:(void (^)(NSString *paymentKey))successBlock
           failure:(void (^)(GBError *error))failureBlock
{
    [self addPayment:productIdentifier payload:nil subscription:NO success:successBlock failure:failureBlock];
}

+ (void)addPayment:(NSString *)productIdentifier
           payload:(NSString *)payload
      subscription:(BOOL)subscription
           success:(void (^)(NSString *paymentKey))successBlock
           failure:(void (^)(GBError *error))failureBlock
{
    if (productIdentifier == nil || [productIdentifier length] == 0)
        if (failureBlock != nil) {
            //            NSString *localizeString = GBLocalizedString(@"ui_billing_error_invalid_item", nil);
            GBError *failError = [GBError errorWithDomain:GBErrorDomain
                                                             code:BILLING_ERROR_INVALID_ITEM
                                                         userInfo:nil];
            failureBlock(failError);
        }
    
    //TODO: Request payment token
    
    [GBStoreHelper defaultStore].extraData = payload;
    [GBStoreHelper defaultStore].isSubscription = subscription;
    
    //    if ([[GBStoreHelper defaultStore] transactions].count != 0) {
    //        [[GBStoreHelper defaultStore] savedReception:^(NSString *paymentKey, GBError *error) {
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
    
    [[GBStoreHelper defaultStore] preparePayment:^(GBError *error) {
        if (error == nil) {
            GBAddPaymentAction *parameters = [[GBAddPaymentAction alloc] init];
            parameters.successBlock = successBlock;
            parameters.failureBlock = failureBlock;
            
            [[GBStoreHelper defaultStore] excutePayment:productIdentifier parameter:parameters];
        } else {
            failureBlock(error);
        }
    }];
}


+ (void)restorePayment:(void (^)(NSArray *paymentKeys))resultBlock
{
    [[GBStoreHelper defaultStore] restorePayment:resultBlock];
}

+ (void)retryPaymet:(void (^)(NSString *paymentKey))resultBlock
{
    //    [[GBStoreHelper defaultStore] retryPayment:resultBlock];
}


#pragma mark Store Test

+ (void)requestDownloadItem:(NSString *)paymentKey result:(void(^)(NSDictionary *itemInfo))resultBlock
{
    GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_TEST_DOWNLOAD param:@{@"payment_key": paymentKey}];
    GBRequest *request = [GBRequest makeRequestWithProtocol:protocol];
    
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
    GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_TEST_QUERY param:nil];
    GBRequest *request = [GBRequest makeRequestWithProtocol:protocol];
    
    [request excuteRequestWithBlock:^(id JSON) {
        NSArray *purchaseItems= [[JSON objectForKey:@"result"] objectForKey:@"item_list"];
        
        if ([GBUtil isValidate:purchaseItems])
            resultBlock(purchaseItems);
        else
            resultBlock(nil);
    }
                            failure:^(NSError *error, id JSON) {
                                JLogVerbose(@"");
                            }];
}

+ (void)requestPayInfo:(NSString *)paymentKey result:(void(^)(NSDictionary *itemInfo, GBError *error))resultBlock
{
    GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_TEST_INFO param:@{@"payment_key": paymentKey}];
    GBRequest *request = [GBRequest makeRequestWithProtocol:protocol];
    
    [request excuteRequestWithBlock:^(id JSON) {
        int errorStutus = [[JSON objectForKey:@"status"] intValue];
        
        if (errorStutus == ERROR_SUCCESS) {
            NSDictionary *result = [JSON objectForKey:@"result"];
            
            resultBlock(result, nil);
        } else {
            
            NSDictionary *errorDictionary = [JSON objectForKey:@"error"];
            GBError *failError = [GBError errorWithDomain:GBErrorDomain
                                                             code:[[errorDictionary objectForKey:@"errorCode"] intValue]
                                                         userInfo:nil];
            resultBlock(nil, failError);
        }
    } failure:^(NSError *error, id JSON) {
        resultBlock(nil, error);
    }];
}

+ (void)requestSetLog:(NSDictionary *)payLog result:(void(^)(NSDictionary *itemInfo, GBError *error))resultBlock
{
    GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_TEST_SET_LOG param:@{@"payment_key": [payLog objectForKey:@"payment_key"], @"product_price" : [payLog objectForKey:@"product_price"], @"product_name" : [payLog objectForKey:@"product_name"], @"money_type" : [payLog objectForKey:@"money_type"]}];
    GBRequest *request = [GBRequest makeRequestWithProtocol:protocol];
    
    [request excuteRequestWithBlock:^(id JSON) {
        int errorStutus = [[JSON objectForKey:@"status"] intValue];
        
        if (errorStutus == ERROR_SUCCESS) {
            NSDictionary *result = [JSON objectForKey:@"result"];
            
            resultBlock(result, nil);
        } else {
            NSDictionary *errorDictionary = [JSON objectForKey:@"error"];
            GBError *failError = [GBError errorWithDomain:GBErrorDomain
                                                             code:[[errorDictionary objectForKey:@"errorCode"] intValue]
                                                         userInfo:nil];
            resultBlock(nil, failError);
        }
    } failure:^(NSError *error, id JSON) {
        resultBlock(nil, error);
    }];
}


@end
