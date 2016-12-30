//
//  GBReceiptVerificator.h
//  GB
//
//  Created by Professional on 2014. 6. 17..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "GBError.h"
@interface GBReceiptVerificator : NSObject

- (void)verifyTransaction:(SKPaymentTransaction*)transaction
                  success:(void (^)(NSString *base64EncodingData))successBlock
                  failure:(void (^)(GBError *error))failureBlock;
- (void)verifyRequestData:(NSData*)requestData
                      url:(NSString*)urlString
                  success:(void (^)())successBlock
                  failure:(void (^)(NSError *error))failureBlock;
@end
