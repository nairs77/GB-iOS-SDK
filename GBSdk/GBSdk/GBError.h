//
//  GBError.h
//  GBSdk
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>


#define ERROR_SUCCESS           1
#define ERROR_BASE              0

#define INAPP_ERROR_BASE        -100
#define INAPP_ERROR_NOT_ALLOWED_PAYMENT     (INAPP_ERROR_BASE - 2)
#define INAPP_ERROR_INVALID_ITEM            (INAPP_ERROR_BASE - 3)

extern NSString *const GBErrorDomain;

@interface GBError : NSError

@end
