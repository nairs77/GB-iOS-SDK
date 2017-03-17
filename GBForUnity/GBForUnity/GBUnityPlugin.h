//
//  GBUnityPlugin.h
//  GBForUnity
//
//  Created by nairs77 on 2017. 3. 13..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#ifndef GBUnityPlugin_h
#define GBUnityPlugin_h

#ifdef __cplusplus
extern "C" {
#endif
    // Init SDK
    void ConfigureSDKWithGameInfo(const char *clientSecretKey, int gameCode, int marketCode, int logLevel);
    
    bool isOpened();
    bool isReady();
    bool isAllowedEULA();
    bool isConnectedChannel();
    
    /* Login */
    void Login(const char *callbackId);
    void LoginWithAuthType(int loginType, const char *callbackId);
    void ConnectChannel(int loginType, const char *callbackId);
    void Logout(const char *callbackId);
    /* Billing */
    void StartStoreService(int userKey, const char *callbackObjectName);
    void RequestProducts(const char *skus, const char *callbackObjectName);
    void RequestProductsInfo(const char *skus, const char *callbackObjectName);
    void BuyItem(const char *userkey, const char *sku, int price, const char *callbackObjectName);
    void ReStoreItems(const char *callbackObjectName);
    
    /* Utility */
    const char* GetMobileCountryCode();
    const char* GetLanguage();
    const char* GetDeviceUniqueId();
    const char* GetDeviceModelName();
    
#ifdef __cplusplus
}
#endif

#endif /* GBUnityPlugin_h */
