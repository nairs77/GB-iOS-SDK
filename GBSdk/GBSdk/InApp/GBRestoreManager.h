//
//  GBRestoreManager.h
//  GB
//
//  Created by joyuser on 2015. 11. 4..
//  Copyright © 2015년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBRestoreManager : NSObject

+ (void)saveRestorePaymentKey:(NSString *)paymentKey;
+ (void)clearLastRestorePaymentKey;
+ (NSMutableArray *)loadRestorePaymentKeysViaNSMutableArray;
+ (BOOL)existRestorePaymentkeys;
+ (void)clearFirstRestorePaymentKey;

@end
