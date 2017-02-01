//
//  GBUnityHelper.h
//  GBForUnity
//
//  Created by nairs77 on 2017. 2. 1..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

extern char *MakeStringCopy(const char *str);
extern void SendToUnity(const char *callbackObject, int success, const char *result);
