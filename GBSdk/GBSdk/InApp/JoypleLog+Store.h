//
//  JoypleLog+Store.h
//  Joyple
//
//  Created by joyuser on 2016. 3. 15..
//  Copyright © 2016년 Joycity. All rights reserved.
//

#import "JoypleLog.h"

@interface JoypleLog (Store)
+ (void)sendToJoypleServerAboutExceptionLog:(NSDictionary *)exceptionLog;
@end
