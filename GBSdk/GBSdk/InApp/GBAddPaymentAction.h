//
//  GBAddPaymentAction.h
//  GB
//
//  Created by Professional on 2014. 6. 12..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBError;

typedef void (^GBPaymentTransactionFailureBlock)(GBError *error);
typedef void (^GBPaymentTransactionSuccessBlock)(NSString *paymentKey);

@interface GBAddPaymentAction : NSObject

@property (nonatomic, strong) GBPaymentTransactionSuccessBlock successBlock;
@property (nonatomic, strong) GBPaymentTransactionFailureBlock failureBlock;

@end
