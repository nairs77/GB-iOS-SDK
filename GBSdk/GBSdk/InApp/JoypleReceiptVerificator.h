//
//  JoypleReceiptVerificator.h
//  Joyple
//
//  Created by Professional on 2014. 6. 17..
//  Copyright (c) 2014년 Joycity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "JoypleError.h"
@interface JoypleReceiptVerificator : NSObject

- (void)verifyTransaction:(SKPaymentTransaction*)transaction
                  success:(void (^)(NSString *base64EncodingData))successBlock
                  failure:(void (^)(JoypleError *error))failureBlock;
- (void)verifyRequestData:(NSData*)requestData
                      url:(NSString*)urlString
                  success:(void (^)())successBlock
                  failure:(void (^)(NSError *error))failureBlock;
@end
