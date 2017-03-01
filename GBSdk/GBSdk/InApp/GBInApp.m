//
//  GBInApp.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 16..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBInApp.h"
#import "GBInApp+Internal.h"
#import "GBInAppHelper.h"
#import "GBProtocol+Store.h"
#import "GBApiRequest.h"
#import "GBLog.h"

@interface GBInApp ()

- (void)_requestPaymentkey:(void(^)(NSString *paymentKey, GBError *error))errorHandler;

@end

@implementation GBInApp

- (id)init
{
    if (self = [super init]) {
        [GBInAppHelper Helper];
    }
    
    return self;
}


+ (void)requestProducts:(NSSet *)skus
                success:(void(^)(NSArray *products, NSArray *invalidProducsts))successBlock
                failure:(void(^)(GBError *error))failureBlock
{
    if (skus == nil || [skus count] == 0) {
        GBError *error = [GBError errorWithDomain:GBErrorDomain code:INAPP_ERROR_INVALID_ITEM userInfo:nil];
        
        failureBlock(error);
    }
    
    [[GBInAppHelper Helper] requestProducts:skus success:successBlock failure:failureBlock];
}


+ (void)buyItem:(NSString *)productId
        success:(void (^)(NSString *paymentKey))successBlock
        failure:(void (^)(GBError *error))failureBlock
{
    BOOL isBillingAvailable = [GBInAppHelper canMakePayments];
    
    if (!isBillingAvailable) {
        
        GBError *newError = [GBError errorWithDomain:GBErrorDomain code:INAPP_ERROR_NOT_ALLOWED_PAYMENT userInfo:nil];
        
        failureBlock(newError);
        
        return;
    }
/*
    [[GBInApp innerInstance] _requestPaymentkey:^(NSString *paymentKey, GBError *error) {
        if (error == nil) {
            GBAddPaymentAction *resultAction = [[GBAddPaymentAction alloc] init];
            resultAction.successBlock = successBlock;
            resultAction.failureBlock = failureBlock;
            
            [[GBInApp innerInstance] _tryAddPayment:productId
                                         paymentKey:paymentKey
                                             result:resultAction];
        } else {
            failureBlock(error);
        }
    }];
*/
    GBAddPaymentAction *resultAction = [[GBAddPaymentAction alloc] init];
    resultAction.successBlock = successBlock;
    resultAction.failureBlock = failureBlock;
    
    [[GBInApp innerInstance] _tryAddPayment:productId
                                 paymentKey:@"1111"
                                     result:resultAction];
}

+ (void)restoreItem:(void(^)(NSString *paymentKey, GBError *error))resultBlock
{
    
}


#pragma mark - Private Methods
- (void)_requestPaymentkey:(void(^)(NSString *paymentKey, GBError *error))resultBlock
{
    GBProtocol *protocol = [GBProtocol makeRequestPayment:GB_GET_IAB_TOKEN param:nil];
    GBApiRequest *request = [GBApiRequest makeRequestWithProtocol:protocol];
    
    GBLogVerbose(@"Request IAB Token to Billing Server");
    
    [request excuteRequestWithBlock:^(id JSON) {
        
        int errorStatus = [[JSON objectForKey:@"status"] intValue];
        NSDictionary *result = [JSON objectForKey:@"result"];
        
        if (errorStatus != 0) { // TRUE
            NSString *paymentKey = [result objectForKey:@"payment_key"];
            
            GBLogError(@"paymentKeys = %@", paymentKey);
            
            if (resultBlock != nil)
                resultBlock(paymentKey, nil);
            
        } else {
            NSDictionary *errorDictionary = [JSON objectForKey:@"error"];
            
            GBError *newError = [GBInAppHelper makeInAppError:errorDictionary underlyingError:nil];//[GBInAppHelper makeInAppError:errorDictionary underlyingError:nil];
            
            if (resultBlock != nil) {
                resultBlock(nil, newError);
            }
        }
    } failure:^(NSError *error, id JSON) {
        GBError *errorResult = [GBInAppHelper makeInAppError:[JSON objectForKey:@"error"] underlyingError:error];
        
        if (resultBlock != nil) {
            resultBlock(nil, errorResult);
        }
    }];
}

- (void)_tryAddPayment:(NSString *)productId
            paymentKey:(NSString *)key
                result:(GBAddPaymentAction *)resultAction
{
    [[GBInAppHelper Helper] addPayment:productId paymentKey:key result:resultAction];
}
@end
