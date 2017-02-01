//
//  GBUnityHelper.m
//  GBForUnity
//
//  Created by nairs77 on 2017. 2. 1..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBUnityHelper.h"

static const char *SuccessMethod = "asyncCallSucceeded";
static const char *FailedMethod = "asyncCallFailed";

char *MakeStringCopy(const char *unityMessage)
{
    if (unityMessage == NULL)
        return NULL;
    
    char *res = (char *)malloc(strlen(unityMessage) + 1);
    strcpy(res, unityMessage);
    
    return res;
}

void SendToUnity(const char *gameObjectName, int success, const char *result)
{
    if (success) {
        UnitySendMessage(gameObjectName, SuccessMethod, result);
    } else {
        UnitySendMessage(gameObjectName, FailedMethod, result);
    }
}
