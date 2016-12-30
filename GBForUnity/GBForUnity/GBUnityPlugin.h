//
//  GBUnityPlugin.h
//  GBForUnity
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#ifndef GBUnityPlugin_h
#define GBUnityPlugin_h

#ifdef __cplusplus
extern "C" {
#endif
    // Init SDK
    
    
    /* Login */
    void Login(int loginType, const char *callbackId);
    void Logout(const char *callbackId);
    /* Billing */
    
    
#ifdef __cplusplus
}
#endif

#endif /* GBUnityPlugin_h */
