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

@property (nonnull, copy) NSString *userKey;

- (void)_requestPaymentkey:(void(^)(NSString *paymentKey, GBError *error))errorHandler;
- (void)_restoreItems:(void(^)(NSArray *paymentKeys))resultBlock;

@end

@implementation GBInApp

@synthesize userKey;

#pragma mark Static Method
+ (void)initInApp:(NSString *)userKey resultBlock:(void (^)(BOOL success, GBError *error))resultBlock
{
    
    [[GBInApp innerInstance] setUserKey:userKey];
    
    BOOL result = [GBInAppHelper canMakePayments];
    
    if (!result) {
        resultBlock(NO, [GBError errorWithDomain:GBErrorDomain code:INAPP_ERROR_NOT_ALLOWED_PAYMENT userInfo:nil]);
        return;
    };
    
    resultBlock(YES, nil);
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
          price:(int)price
        success:(void (^)(NSString *paymentKey))successBlock
        failure:(void (^)(GBError *error))failureBlock
{
    BOOL isBillingAvailable = [GBInAppHelper canMakePayments];
    
    if (!isBillingAvailable) {
        
        GBError *newError = [GBError errorWithDomain:GBErrorDomain code:INAPP_ERROR_NOT_ALLOWED_PAYMENT userInfo:nil];
        
        failureBlock(newError);
        
        return;
    }

    NSDictionary *item = @{@"userKey" : [[GBInApp innerInstance] userKey], @"productID" : productId, @"price" : [NSString stringWithFormat:@"%d", price]};
    
    [[GBInApp innerInstance] _requestPaymentkey:item result:^(NSString *paymentKey, GBError *error) {
        if (error == nil) {
            GBAddPaymentAction *resultAction = [[GBAddPaymentAction alloc] init];
            resultAction.successBlock = successBlock;
            resultAction.failureBlock = failureBlock;
            
            [[GBInApp innerInstance] _tryAddPayment:[[GBInApp innerInstance] userKey]
                                                sku:productId
                                         paymentKey:paymentKey
                                             result:resultAction];
        } else {
            failureBlock(error);
        }
    }];
}

+ (void)restoreItem:(void(^)(NSArray *paymentKeys))resultBlock;
{
    [[GBInApp innerInstance] _restoreItems:resultBlock];
}

#pragma mark - Public

- (id)init
{
    if (self = [super init]) {
        [GBInAppHelper Helper];
    }
    
    return self;
}
#pragma mark - Private Methods
- (void)_requestPaymentkey:(NSDictionary *)parameter result:(void(^)(NSString *paymentKey, GBError *error))resultBlock
{
    GBProtocol *protocol = [GBProtocol makeRequestPayment:GB_GET_IAB_TOKEN param:parameter];
    GBApiRequest *request = [GBApiRequest makeRequestWithProtocol:protocol];
    
    GBLogVerbose(@"Request IAB Token to Billing Server");
    
    [request excuteRequestWithBlock:^(id JSON) {
        
        int errorStatus = [[JSON objectForKey:@"RESULT"] intValue];
        
        if (errorStatus != 0) { // TRUE
            NSString *paymentKey = [JSON objectForKey:@"PAYMENT_KEY"];
            
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

- (void)_tryAddPayment:(NSString *)aUserKey
                   sku:(NSString *)productId
            paymentKey:(NSString *)key
                result:(GBAddPaymentAction *)resultAction
{
    [[GBInAppHelper Helper] addPayment:aUserKey sku:productId paymentKey:key result:resultAction];
}

- (void)_restoreItems:(void(^)(NSArray *paymentKeys))resultBlock
{
    GBProtocol *protocol = [GBProtocol makeRequestPayment:GB_RESTORE param:@{@"userKey" : userKey}];
    GBApiRequest *request = [GBApiRequest makeRequestWithProtocol:protocol];
    
    GBLogVerbose(@"Request Restore to Billing Server");
    
    [request excuteRequestWithBlock:^(id JSON) {
        
        NSArray *result = JSON;
        
        NSInteger count = [result count];
        
        NSMutableArray *paymentKeys = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger i = 0; i < count; i++) {
            [paymentKeys addObject:[[result objectAtIndex:i] objectForKey:@"PAYMENT_KEY"]];
        }
        
        resultBlock(paymentKeys);
        
    } failure:^(NSError *error, id JSON) {
        if (resultBlock != nil) {
            resultBlock(nil);
        }
    }];
}

@end
