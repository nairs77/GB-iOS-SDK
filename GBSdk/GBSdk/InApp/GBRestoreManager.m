//
//  GBRestoreManager.m
//  GB
//
//  Created by niars77 on 2015. 11. 4..
//  Copyright © 2015년 GeBros. All rights reserved.
//

#import "GBRestoreManager.h"

#define JOYPLE_RESTORE_INFORAMTION @"joyple.restore.inforamtion"

@implementation GBRestoreManager

+ (BOOL)existRestorePaymentkeys
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:JOYPLE_RESTORE_INFORAMTION])
        return YES;
    else
        return NO;
}

+ (void)saveRestorePaymentKey:(NSString *)paymentKey
{
    NSMutableArray *paymentRestoreArray  = [self loadRestorePaymentKeysViaNSMutableArray];
    [paymentRestoreArray addObject:paymentKey];
    [[NSUserDefaults standardUserDefaults]setObject:paymentRestoreArray forKey:JOYPLE_RESTORE_INFORAMTION];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (void)clearLastRestorePaymentKey
{
    NSMutableArray *paymentRestoreArray = [self loadRestorePaymentKeysViaNSMutableArray];
    if (paymentRestoreArray.count != 0) {
        [paymentRestoreArray removeLastObject];
    }
    [[NSUserDefaults standardUserDefaults]setObject:paymentRestoreArray forKey:JOYPLE_RESTORE_INFORAMTION];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if (paymentRestoreArray.count == 0) {
        [self clearAllRestoreInformation];
    }
}

+ (void)clearFirstRestorePaymentKey
{
    NSMutableArray *paymentRestoreArray = [self loadRestorePaymentKeysViaNSMutableArray];
    if (paymentRestoreArray.count != 0) {
        [paymentRestoreArray removeObjectAtIndex:0];
    }

    [[NSUserDefaults standardUserDefaults]setObject:paymentRestoreArray forKey:JOYPLE_RESTORE_INFORAMTION];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if (paymentRestoreArray.count == 0) {
        [self clearAllRestoreInformation];
    }
}

+ (NSMutableArray *)loadRestorePaymentKeysViaNSMutableArray
{
    NSMutableArray *paymentRestoreArray = [NSMutableArray arrayWithArray:[[[NSUserDefaults standardUserDefaults]objectForKey:JOYPLE_RESTORE_INFORAMTION]mutableCopy]];
    return paymentRestoreArray;
}

+ (void)clearAllRestoreInformation
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:JOYPLE_RESTORE_INFORAMTION];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
@end
