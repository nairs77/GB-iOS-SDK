//
//  GBUnityPlugin.m
//  GBForUnity
//
//  Created by Professional on 2017. 1. 12..
//  Copyright (c) 2017년 Gebros. All rights reserved.
//

#import "GBUnityPlugin.h"
#import "GBUnityHelper.h"
#import <GBSdk/GBSdk.h>
#import <GBSdk/GBGlobal.h>
#import <GBSdk/GBSession.h>
#import <GBSdk/GBDeviceUtil.h>

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

const char* getActiveSession()
{
    return NULL;//return [GBSession activeSession].userInfo;
}

void Login(const char *callbackId)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackId];
    
    [GBSession login:^(GBSession *newSession, GBError *error) {
        
    }];
}

void LoginWithAuthType(int loginType, const char *callbackId)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackId];
    
    [GBSession loginWithAuthType:(AuthType)loginType withHandler:^(GBSession *newSession, GBError *error) {
        
    }];
}

void ConnectChannel(int loginType, const char *callbackId)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackId];
    
}

void Logout(const char *callbackId)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackId];
    
//    [GBSession logout:^(GBSession *newSessoin, GBError *error) {
//        
//    }];
}

#pragma mark - InApp

void StartStoreService(int userKey, const char *callbackObjectName)
{
    
}
void RequestProductsInfo(const char *skus, const char *callbackObjectName)
{
    
}

void BuyItem(const char *sku, int price, const char *callbackObjectName)
{
    
}

void RestoreItems(const char *callbackObjectName)
{
    
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
/*
#pragma mark - Common
void ConfigureSDKWithGameInfo(const char *secretKey, int gCode, int marketCode, int lLevel)
{
    NSString *clientSecretKey = [NSString stringWithUTF8String:secretKey];
    
    [[JoypleForUnity sharedInstance] initSDKWithGameInfo:clientSecretKey gameCode:gCode logLevel:(LogLevel)lLevel];
    //    [Joyple configureSDKWithGlobalInfo:clientSecretKey gameCode:gCode logLevel:lLevel];
}


#pragma mark - Session
bool isOpened()
{
    JoypleSession *session = [[Joyple accountService] activeSession];
    
    if (session != nil)
        return [session isOpened];
    else
        return false;
}

bool hasAccount()
{
    JoypleSession *session = [[Joyple accountService] activeSession];
    
    if (session != nil)
        return [session hasToken];
    else
        return false;
}

const char* getActiveSession()
{
//    JoypleSession *session = [[Joyple accountService] activeSession];
//
//    if (session != nil) {
//        return MakeStringCopy([[session access_token] UTF8String]);
//    } else {
//        NSString *emptyStrig = @"";
//        return MakeStringCopy([emptyStrig UTF8String]);
//    }
}

void Login(int authType, const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];

    JoypleAuthType type = (JoypleAuthType)authType;
    
    if (type == JoypleNotSupportedAuthType) {
        [[Joyple accountService] authenticateWithCompletionHandler:^(BOOL success, JoypleError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *resultJson = nil;
                
                if (success) {
                    resultJson = [[JoypleForUnity sharedInstance] makeSessionResponse:OPEN error:nil];
                    
                } else {
                    resultJson = [[JoypleForUnity sharedInstance] makeSessionResponse:ACCESS_FAILED error:error];
                }
                
                SendToUnity([objectName UTF8String], (success == YES) ? 1 : 0, [resultJson UTF8String]);
            });
        }];
    } else {
        [[Joyple accountService] authenticateWithAuthType:(JoypleAuthType)authType parameter:nil
                                              authHandler:^(BOOL success, JoypleError *error) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      NSString *resultJson = nil;
                                                      
                                                      if (success) {
                                                          resultJson = [[JoypleForUnity sharedInstance] makeSessionResponse:OPEN error:nil];
                                                          
                                                      } else {
                                                          resultJson = [[JoypleForUnity sharedInstance] makeSessionResponse:ACCESS_FAILED error:error];
                                                      }
                                                      
                                                      SendToUnity([objectName UTF8String], (success == YES) ? 1 : 0, [resultJson UTF8String]);
                                                  });
                                              }];
    }
}

void LoginByNativeUI(const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    [[Joyple accountService] authenticateByUIWithCompletionHandler:^(BOOL success, JoypleError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *resultJson = nil;
            
            if (success) {
                resultJson = [[JoypleForUnity sharedInstance] makeSessionResponse:OPEN error:nil];
                
            } else {
                resultJson = [[JoypleForUnity sharedInstance] makeSessionResponse:ACCESS_FAILED error:error];
            }
            
            SendToUnity([objectName UTF8String], (success == YES) ? 1 : 0, [resultJson UTF8String]);
        });
    }];
}

void Logout(const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    [[Joyple accountService] logout:^(BOOL success, JoypleError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *resultJson = nil;
            
            if (success) {
                resultJson = [[JoypleForUnity sharedInstance] makeSessionResponse:CLOSED error:nil];
            } else {
                resultJson = [[JoypleForUnity sharedInstance] makeSessionResponse:ACCESS_FAILED error:error];
            }
            
            SendToUnity([objectName UTF8String], (success == YES) ? 1 : 0, [resultJson UTF8String]);
        });
    }];
    
}

void Withdraw(const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    [[Joyple accountService] unRegister:^(BOOL success, JoypleError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *resultJson = nil;
            
            if (success) {
                resultJson = [[JoypleForUnity sharedInstance] makeSessionResponse:WITHDRAW error:nil];
            } else {
                resultJson = [[JoypleForUnity sharedInstance] makeSessionResponse:ACCESS_FAILED error:error];
            }
            
            SendToUnity([objectName UTF8String], (success == YES) ? 1 : 0, [resultJson UTF8String]);
        });
    }];
}

void RequestProfile(const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    [[Joyple accountService] loadUserInfoWithHandler:^(NSDictionary *userInfo, JoypleError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *resultJson = [[JoypleForUnity sharedInstance] makeProfileResponse:userInfo error:error];
            
            SendToUnity([objectName UTF8String], (error == nil) ? 1 : 0, [resultJson UTF8String]);
        });
    }];
}

#pragma mark - Friends
void ReqeustFriends(const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    JoypleUser *currentUser = [[Joyple accountService] currentUser];
    
    [currentUser loadAllFriendsWithCompletionHandler:^(NSDictionary *friends, JoypleError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *resultJson = [[JoypleForUnity sharedInstance] makeFriendsResponse:friends error:error];
            
            SendToUnity([objectName UTF8String], (error == nil) ? 1 : 0, [resultJson UTF8String]);
        });
    }];
}

void RequestAddFriend(int userKey, const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    JoypleUser *currentUser = [[Joyple accountService] currentUser];
    
    [currentUser requestCommandWithParameter:JOYPLE_ADD_FRIEND
                                   parameter:@{@"f_userkey" : [NSNumber numberWithInt:userKey]}
                           completionHandler:^(BOOL success, JoypleError *error) {
        
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    NSString *resultJson = [[JoypleForUnity sharedInstance] makeStatusResponse:error];
                                    
                                    SendToUnity([objectName UTF8String], (error == nil) ? 1 : 0, [resultJson UTF8String]);
                                });
                           }];
}

void RequestUpdateFriendStatus(int userKey, int status, const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    JoypleUser *currentUser = [[Joyple accountService] currentUser];
    
    [currentUser requestCommandWithParameter:JOYPLE_UPDATE_FRIEND_STATUS
                                   parameter:@{@"f_userkey" : [NSNumber numberWithInt:userKey], @"f_status" : [NSNumber numberWithInt:status]}
                           completionHandler:^(BOOL success, JoypleError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                   NSString *resultJson = [[JoypleForUnity sharedInstance] makeStatusResponse:error];
                                   
                                   SendToUnity([objectName UTF8String], (error == nil) ? 1 : 0, [resultJson UTF8String]);
                               });
                           }];
}

void RequestSearchUsers(const char *nickName, const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    NSString *friendNickName = [NSString stringWithUTF8String:nickName];
    JoypleUser *currentUser = [[Joyple accountService] currentUser];
    
    [currentUser onSearchFriendsWithSearchText:friendNickName
                             completionHandler:^(NSDictionary *searchFriends, JoypleError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    NSString *resultJson = [[JoypleForUnity sharedInstance] makeFriendsResponse:searchFriends error:error];
                                    
                                    SendToUnity([objectName UTF8String], (error == nil) ? 1 : 0, [resultJson UTF8String]);
                                });
                            }];
}

#pragma mark - In App
void StartStoreService(int userKey, const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    NSString *userKeyString = [NSString stringWithFormat:@"%d", userKey];
    
    [JoypleStoreService startStoreServiceAlone:userKeyString
                                        result:^(BOOL success, JoypleError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                NSString *resultJson = [[JoypleForUnity sharedInstance] makeStatusResponse:error];
                                                
                                                SendToUnity([objectName UTF8String], (error == nil) ? 1 : 0, [resultJson UTF8String]);
                                            });
                                        }];
}

void RequestProducts(const char *skus, const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    NSString *prouductIds = [NSString stringWithUTF8String:skus];
    
    NSArray *identifiers = [prouductIds componentsSeparatedByString:@","];
    
    [JoypleStoreService requestProducts:[NSSet setWithArray:identifiers]
                                success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        int count = [products count];
                                        
                                        if (count == 0) {
                                            NSString *resultJson = [[JoypleForUnity sharedInstance] makeStatusResponse:[JoypleError errorWithDomain:JoypleErrorDomain code:BILLING_ERROR_INVALID_PRODUCT_ID userInfo:nil]];
                                            
                                            SendToUnity([objectName UTF8String], 0, [resultJson UTF8String]);
                                        } else {
                                            NSMutableString *validateProductIds = [[NSMutableString alloc] initWithCapacity:0];

                                            for (int i=0; i < count; i++) {
                                                NSString *productID = [[products objectAtIndex:i] productIdentifier];

                                                if (i != 0)
                                                    [validateProductIds appendString:@","];
                                                else
                                                    [validateProductIds appendString:productID];
                                            }
                                            
                                            SendToUnity([objectName UTF8String], 1, [validateProductIds UTF8String]);
                                        }
                                            
                                        
                                    });
                                }
                                failure:^(JoypleError *error) {
                                    NSString *resultJson = [[JoypleForUnity sharedInstance] makeStatusResponse:error];
                                    
                                    SendToUnity([objectName UTF8String], 0, [resultJson UTF8String]);
                                }];

}

void AddPayment(const char *sku, int price, const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    NSString *productId = [NSString stringWithUTF8String:sku];
    
    [JoypleStoreService addPayment:productId
                           success:^(NSString *paymentKey) {
                               SendToUnity([objectName UTF8String], 0, [paymentKey UTF8String]);
                           }
                           failure:^(JoypleError *error) {
                               NSString *resultJson = [[JoypleForUnity sharedInstance] makeStatusResponse:error];
                               
                               SendToUnity([objectName UTF8String], 0, [resultJson UTF8String]);
                           }];
}

void RestoreItem(const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    [JoypleStoreService restorePayment:^(NSArray *paymentKeys) {
        int count = [paymentKeys count];
        
        if (count > 0) {
            NSMutableString *keys = [[NSMutableString alloc] initWithCapacity:0];
            
            for (int i = 0; i < count; i++) {
                NSString *key = [paymentKeys objectAtIndex:i];
                if (i != 0)
                    [keys appendString:@","];
                else
                    [keys appendString:key];
            }
            
            SendToUnity([objectName UTF8String], 1, [keys UTF8String]);
        } else {
            SendToUnity([objectName UTF8String], 0, NULL);
        }
        
    }];
}

#pragma mark - App

void ShowMain()
{
    [[Joyple accountService] showProfile];
}

void ShowEULA()
{
    [[Joyple accountService] showEULA];
}

void ShowViewByType(int aViewType)
{
    JoypleProfileViewType type = (JoypleProfileViewType)aViewType;
    
    [[Joyple accountService] showProfile:type];
}

void ShowClickWrap(const char *callbackObjectName)
{
    __block NSString *objectName = [[NSString alloc] initWithUTF8String:callbackObjectName];
    
    [JoypleAccountService showClickWrapWithCompletionHandler:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *resultJson = [[JoypleForUnity sharedInstance] makeStatusResponse:nil];
            SendToUnity([objectName UTF8String], 1, [resultJson UTF8String]);
        });
    }];
}

void SetAllowedEULA(bool isAllowed)
{
    [[Joyple accountService] setAllowedEULA:isAllowed];
}

bool isAllowedEULA()
{
    return [JoypleAccountService isAllowedEULA];
}

#pragma mark - Utility

void ShowToastMessage(const char *message)
{
}

void ShowAlertMessage()
{
    
}


*/
