//
//  GBProtocol+Store.h
//  GB
//
//  Created by Professional on 2014. 6. 13..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import "GBProtocol.h"

enum {
    JOYPLE_MARKET_INFO,
    JOYPLE_GET_IAB_TOKEN,
    JOYPLE_SAVE_RECEIPT,
    JOYPLE_RESTORE,
    JOYPLE_CHECK_SUBSCRIPTION,
    
    JOYPLE_TEST_DOWNLOAD,
    JOYPLE_TEST_QUERY,
    JOYPLE_TEST_EXCEPTION,
    JOYPLE_TEST_INFO,
    JOYPLE_TEST_SET_LOG,
    
};

@interface GBProtocol (Store)

+ (GBProtocol *)makeRequestPayment:(NSUInteger)command param:(NSDictionary *)parameter;

@end
