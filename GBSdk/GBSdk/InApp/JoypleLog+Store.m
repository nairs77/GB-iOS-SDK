//
//  JoypleLog+Store.m
//  Joyple
//
//  Created by joyuser on 2016. 3. 15..
//  Copyright © 2016년 Joycity. All rights reserved.
//

#import "JoypleLog+Store.h"
#import "JoypleRequest.h"
#import "JoypleProtocol+Store.h"

@implementation JoypleLog (Store)
+ (void)sendToJoypleServerAboutExceptionLog:(NSDictionary *)exceptionLog
{
    JLogVerbose(@"Billing Log: %@",exceptionLog);
    JoypleProtocol *protocol = [JoypleProtocol makeRequestPayment:JOYPLE_TEST_EXCEPTION param:exceptionLog];
    JoypleRequest *request = [JoypleRequest makeRequestWithProtocol:protocol];
    [request excuteRequestWithBlock:^(id JSON) {
        
    } failure:^(NSError *error, id JSON) {
        
    }];
}
@end
