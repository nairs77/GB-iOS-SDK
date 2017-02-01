//
//  GBForUnity.h
//  GBForUnity
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#ifndef GBForUnity_h
#define GBForUnity_h

#ifdef __cplusplus
extern "C" {
#endif
    // Init SDK
    void ConfigureSDKWithGameInfo(const char *clientSecretKey, int gameCode, int marketCode, int logLevel);
    
    /* Login */
    void LoginWithAuthType(int loginType, const char *callbackId);
    void Logout(const char *callbackId);
    /* Billing */
    
#ifdef __cplusplus
}
#endif

#endif /* GBForUnity_h */
