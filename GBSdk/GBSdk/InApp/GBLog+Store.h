//
//  GBLog+Store.h
//  GB
//
//  Created by niars77 on 2016. 3. 15..
//  Copyright © 2016년 Joycity. All rights reserved.
//

#import "GBLog.h"

@interface GBLog (Store)
+ (void)sendToGBServerAboutExceptionLog:(NSDictionary *)exceptionLog;
@end
