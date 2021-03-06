//
//  GBUnityPlugin.m
//  GBForUnity
//
//  Created by Professional on 2017. 1. 12..
//  Copyright (c) 2017년 Gebros. All rights reserved.
//

#import "GBUnityPlugin.h"
#import "GBUnityHelper.h"
#import "GBForUnity.h"
#import <GBSdk/GBSdk.h>
#import <GBSdk/GBGlobal.h>
#import <GBSdk/GBSession.h>
#import <GBSdk/GBDeviceUtil.h>
#import <GBSdk/GBInApp.h>
#import <StoreKit/StoreKit.h>

#pragma mark - Common

void ConfigureSDKWithGameInfo(const char *clientSecretKey, int gameCode, int marketCode, int logLevel)
{
    [GBSdk configureSDKWithInfo:gameCode clientId:@"" logLevel:(LogLevel)logLevel];
}

#pragma mark - Session

bool isOpened()
{
    return ([GBSession activeSession].state == OPEN) ? YES : NO;
}

bool isReady()
{
    return ([GBSession activeSession].state == READY) ? YES : NO;
}

bool isAllowedEULA()
{
    return true;
}

bool isConnectedChannel()
{
    return [GBSession activeSession].isConnectedChannel;
}

void Login(const char *callbackId)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackId];
    
    [GBSession login:^(GBSession *newSession, GBError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [GBForUnity makeSessionResponse:OPEN data:[newSession sessionInfo] error:error];
            SendToUnity([objectName UTF8String], (error == nil) ? 1 : 0, [result UTF8String]);
        });
    }];
}

void LoginWithAuthType(int loginType, const char *callbackId)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackId];
    
    [GBSession loginWithAuthType:(AuthType)loginType withHandler:^(GBSession *newSession, GBError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [GBForUnity makeSessionResponse:OPEN data:[newSession sessionInfo] error:error];
            SendToUnity([objectName UTF8String], (error == nil) ? 1 : 0, [result UTF8String]);
        });
    }];
}

void ConnectChannel(int loginType, const char *callbackId)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackId];
    
    [GBSession connectChannel:(AuthType)loginType withHandler:^(GBSession *newSession, GBError *error) {
        NSString *resultJson = nil;
        if (error != nil) {
            resultJson = [GBForUnity makeSessionResponse:ACCESS_FAILED data:nil error:error];
            SendToUnity([objectName UTF8String], 0, [resultJson UTF8String]);
        } else {
            resultJson = [GBForUnity makeSessionResponse:OPEN data:[newSession sessionInfo] error:nil];
            SendToUnity([objectName UTF8String], 1, [resultJson UTF8String]);
        }
    }];
    
}

void Logout(const char *callbackId)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackId];
    
    [GBSession logout:^(GBSession *newSession, GBError *error) {
        NSString *result = [GBForUnity makeSessionResponse:CLOSED data:[newSession sessionInfo] error:error];
        SendToUnity([objectName UTF8String], (error == nil) ? 1 : 0, [result UTF8String]);
    }];
}

#pragma mark - InApp

void StartStoreService(int userKey, const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    NSString *userKeyString = [NSString stringWithFormat:@"%d", userKey];
    
    [GBInApp initInApp:userKeyString
           resultBlock:^(BOOL success, GBError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSString *resultJson = [GBForUnity makeStatusResponse:error];
                        
                        SendToUnity([objectName UTF8String], (error == nil) ? 1 : 0, [resultJson UTF8String]);
                    });
                }];
}

void RequestProducts(const char *skus, const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    NSString *prouductIds = [NSString stringWithUTF8String:skus];
    
    NSArray *identifiers = [prouductIds componentsSeparatedByString:@","];
    
    [GBInApp requestProducts:[NSSet setWithArray:identifiers]
                     success:^(NSArray *products, NSArray *invalidProducsts) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             NSInteger count = [products count];
                             
                             if (count == 0) {
                                 // BILLING_ERROR_INVALID_PRODUCT_ID
                                 NSString *resultJson = [GBForUnity makeStatusResponse:[GBError errorWithDomain:GBErrorDomain code:-1 userInfo:nil]];
                                 SendToUnity([objectName UTF8String], 0, [resultJson UTF8String]);
                             } else {
                                 NSMutableString *validateProductIds = [[NSMutableString alloc] initWithCapacity:0];
                                 
                                 for (int i=0; i < count; i++) {
                                     //NSString *productID = [[products objectAtIndex:i] productIdentifier];
                                     SKProduct *product = [products objectAtIndex:i];
                                     
                                     if (i != 0)
                                         [validateProductIds appendString:@","];
                                     else
                                         [validateProductIds appendString:[product productIdentifier]];
                                 }
                                 NSString *resultJson = [GBForUnity makeDataResponse:@{@"valid" : validateProductIds} error:nil];
                                 SendToUnity([objectName UTF8String], 1, [resultJson UTF8String]);
                             }
                         });
                     }
                     failure:^(GBError *error) {
                         NSString *resultJson = [GBForUnity makeStatusResponse:error];
                        
                         SendToUnity([objectName UTF8String], 0, [resultJson UTF8String]);
                     }];

}

void RequestProductsInfo(const char *skus, const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    NSString *prouductIds = [NSString stringWithUTF8String:skus];
    
    NSArray *identifiers = [prouductIds componentsSeparatedByString:@","];
    
    [GBInApp requestProducts:[NSSet setWithArray:identifiers]
                     success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            NSInteger count = [products count];
                            
                            if (count == 0) {
                                NSString *resultJson = [GBForUnity makeStatusResponse:[GBError errorWithDomain:GBErrorDomain code:-1 userInfo:nil]];
                                SendToUnity([objectName UTF8String], 0, [resultJson UTF8String]);
                            } else {
                                
                                NSMutableDictionary *items = [NSMutableDictionary dictionary];
                                [items setObject:[NSNumber numberWithInteger:count] forKey:@"count"];
                                
                                for (int i = 0; i < count; i++) {
                                    SKProduct *product = [products objectAtIndex:i];
                                    
                                    NSString *itemName = [NSString stringWithFormat:@"item%d", i];
                                    NSDictionary *item = @{@"description":[product localizedDescription],
                                                           @"title" : [product localizedTitle],
                                                           @"product_id": [product productIdentifier],
                                                           @"price" : [[product price] stringValue],
                                                           @"currency" : [[product priceLocale] objectForKey:NSLocaleCurrencyCode],
                                                           @"currency_symbol" : [[product priceLocale] objectForKey:NSLocaleCurrencySymbol]};
                                    
                                    [items setObject:item forKey:itemName];
                                }
                                
                                NSString *resultJson = [GBForUnity makeDataResponse:items error:nil];
                                SendToUnity([objectName UTF8String], 1, [resultJson UTF8String]);
                            }
                            
                            
                        });
                    }
                    failure:^(GBError *error) {
                        NSString *resultJson = [GBForUnity makeStatusResponse:error];
                        
                        SendToUnity([objectName UTF8String], 0, [resultJson UTF8String]);
                    }];
    
}

void BuyItem(const char *sku, int price, const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    NSString *productId = [NSString stringWithUTF8String:sku];
    
    [GBInApp buyItem:productId
               price:price
             success:^(NSString *paymentKey) {
                 NSString *resultJson = [GBForUnity makeDataResponse:@{@"payment_key": paymentKey} error:nil];
                 SendToUnity([objectName UTF8String], 1, [resultJson UTF8String]);
             } failure:^(GBError *error) {
                 NSString *resultJson = [GBForUnity makeStatusResponse:error];
                 SendToUnity([objectName UTF8String], 0, [resultJson UTF8String]);
             }];
    
}

void ReStoreItems(const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    [GBInApp restoreItem:^(NSArray *paymentKeys) {
        
        NSInteger count = [paymentKeys count];
        
        if (count > 0) {
            NSMutableString *keys = [[NSMutableString alloc] initWithCapacity:0];
            
            for (int i = 0; i < count; i++) {
                NSString *key = [paymentKeys objectAtIndex:i];
                
                [keys appendString:key];
                
                if (i != count - 1)
                    [keys appendString:@","];
            }
            
            NSString *resultJson = [GBForUnity makeDataResponse:@{@"restore_keys" : keys} error:nil];
            SendToUnity([objectName UTF8String], 1, [resultJson UTF8String]);
        } else {
            NSString *resultJson = [GBForUnity makeStatusResponse:[GBError errorWithDomain:GBErrorDomain
                                                                                      code:INAPP_ERROR_SERVER_NO_RESTORE
                                                                                  userInfo:nil]];
            SendToUnity([objectName UTF8String], 0, [resultJson UTF8String]);
        }
        
    }];
}

#pragma mark - Utility

const char* GetMobileCountryCode()
{
    return MakeStringCopy([[GBDeviceUtil getMCC] UTF8String]);
}

const char* GetLanguage()
{
    return MakeStringCopy([[GBDeviceUtil currentLanguage] UTF8String]);
}

const char* GetDeviceUniqueId()
{
    return MakeStringCopy([[GBDeviceUtil uniqueDeviceId] UTF8String]);
}

const char* GetDeviceModelName()
{
    return MakeStringCopy([[GBDeviceUtil deviceModel] UTF8String]);
}
