//
//  GBLog+Store.m
//  GB
//
//  Created by joyuser on 2016. 3. 15..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import "GBLog+Store.h"
#import "GBRequest.h"
#import "GBProtocol+Store.h"

@implementation GBLog (Store)
+ (void)sendToGBServerAboutExceptionLog:(NSDictionary *)exceptionLog
{
    GBLogVerbose(@"Billing Log: %@",exceptionLog);
//    GBProtocol *protocol = [GBProtocol makeRequestPayment:JOYPLE_TEST_EXCEPTION param:exceptionLog];
//    GBRequest *request = [GBRequest makeRequestWithProtocol:protocol];
//    [request excuteRequestWithBlock:^(id JSON) {
//        
//    } failure:^(NSError *error, id JSON) {
//        
//    }];
}
@end
