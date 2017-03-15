//
//  GBUnityHelper.h
//  GBForUnity
//
//  Created by nairs77 on 2017. 2. 1..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    char *MakeStringCopy(const char *str);
    void SendToUnity(const char *callbackObject, int success, const char *result);
#ifdef __cplusplus
}
#endif
