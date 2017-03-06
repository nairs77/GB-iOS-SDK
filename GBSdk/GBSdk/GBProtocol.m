//
//  GBProtocol.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBProtocol.h"

NSString * const ACCOUNT_SEQ_KEY = @"accountSeq";
NSString * const MARKET_CODE_KEY = @"marketCode";
NSString * const GAME_CODE_KEY = @"gameCode";
NSString * const PRODUCT_ID_KEY = @"productID";
NSString * const PRICE_KEY = @"price";
NSString * const PAYMENT_KEY = @"paymentKey";


@implementation GBProtocol

+ (NSDictionary *)defaultHeader
{
    //NSDictionary *pInfo = [[NSBundle mainBundle] infoDictionary];
    
    NSString *defaultAgent = [NSString stringWithFormat:@""];
    
    return [NSDictionary dictionaryWithObject:defaultAgent forKey:@"User-Agent"];
}
@end
