//
//  GBProtocol+Store.h
//  GB
//
//  Created by Professional on 2014. 6. 13..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import "GBProtocol.h"

enum {
    GB_MARKET_INFO,
    GB_GET_IAB_TOKEN,
    GB_SAVE_RECEIPT,
    GB_RESTORE,
};

@interface GBProtocol (Store)

+ (GBProtocol *)makeRequestPayment:(NSUInteger)command param:(NSDictionary *)parameter;

@end
