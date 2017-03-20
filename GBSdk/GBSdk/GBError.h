//
//  GBError.h
//  GBSdk
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>


#define ERROR_SUCCESS                           1
#define ERROR_BASE                              0

#define SESSION_ERROR_BASE                      -100
#define SESSION_ERROR_ACCOUNT_BLOCK             (SESSION_ERROR_BASE - 1)
#define SESSION_ERROR_ACCOUNT_WITHDRAWAL        (SESSION_ERROR_BASE - 2)
#define SESSION_ERROR_ACCOUNT_WITHDRAWAL_END    (SESSION_ERROR_BASE - 3)
#define SESSION_ERROR_ALEADY_CHANNEL            (SESSION_ERROR_BASE - 4)

#define SESSION_ERROR_FB_BASE                   (SESSION_ERROR_BASE - 10)           //-110
#define SESSION_ERROR_FB_USER_CANCELLED         (SESSION_ERROR_FB_BASE - 1)
#define SESSION_ERROR_FB_NOT_TOKEN              (SESSION_ERROR_FB_BASE - 2)

#define INAPP_ERROR_BASE                        -200
#define INAPP_ERROR_INITIALIZE                  (INAPP_ERROR_BASE - 1)
#define INAPP_ERROR_NOT_ALLOWED_PAYMENT         (INAPP_ERROR_BASE - 2)
#define INAPP_ERROR_INVALID_ITEM                (INAPP_ERROR_BASE - 3)
#define INAPP_ERROR_USER_CANCELLED              (INAPP_ERROR_BASE - 4)

#define INAPP_ERROR_SERVER_BASE                 (INAPP_ERROR_BASE - 10)             //-210
#define INAPP_ERROR_SERVER_INTERNAL             (INAPP_ERROR_SERVER_BASE - 1)
#define INAPP_ERROR_SERVER_NO_RESTORE           (INAPP_ERROR_SERVER_BASE - 2)

#define INAPP_ERROR_FROM_STORE_BASE             (INAPP_ERROR_BASE - 20)             //-220
#define INAPP_ERROR_FROM_STORE_UNKNOWN          (INAPP_ERROR_FROM_STORE_BASE - 1)
#define INAPP_ERROR_FROM_STORE_CLIENT_INVALID   (INAPP_ERROR_FROM_STORE_BASE - 2)
#define INAPP_ERROR_FROM_STORE_CANCELED         (INAPP_ERROR_FROM_STORE_BASE - 3)
#define INAPP_ERROR_FROM_STORE_INVALID          (INAPP_ERROR_FROM_STORE_BASE - 4)
#define INAPP_ERROR_FROM_STORE_NOT_ALLOWED      (INAPP_ERROR_FROM_STORE_BASE - 5)
#define INAPP_ERROR_FROM_STORE_NOT_AVAILABLE    (INAPP_ERROR_FROM_STORE_BASE - 6)


extern NSString *const GBErrorDomain;

@interface GBError : NSError

@end
