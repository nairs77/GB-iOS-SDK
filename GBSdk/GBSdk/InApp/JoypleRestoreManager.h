//
//  JoypleRestoreManager.h
//  Joyple
//
//  Created by joyuser on 2015. 11. 4..
//  Copyright © 2015년 Joycity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JoypleRestoreManager : NSObject

+ (void)saveRestorePaymentKey:(NSString *)paymentKey;
+ (void)clearLastRestorePaymentKey;
+ (NSMutableArray *)loadRestorePaymentKeysViaNSMutableArray;
+ (BOOL)existRestorePaymentkeys;
+ (void)clearFirstRestorePaymentKey;

@end