//
//  JoypleAddPaymentAction.h
//  Joyple
//
//  Created by Professional on 2014. 6. 12..
//  Copyright (c) 2014년 Joycity. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JoypleError;

typedef void (^JoyplePaymentTransactionFailureBlock)(JoypleError *error);
typedef void (^JoyplePaymentTransactionSuccessBlock)(NSString *paymentKey);

@interface JoypleAddPaymentAction : NSObject

@property (nonatomic, strong) JoyplePaymentTransactionSuccessBlock successBlock;
@property (nonatomic, strong) JoyplePaymentTransactionFailureBlock failureBlock;

@end
