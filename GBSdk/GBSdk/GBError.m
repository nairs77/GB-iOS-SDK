//
//  GBError.m
//  GBSdk
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import "GBError.h"

NSString *const GBErrorDomain = @"com.gebros.sdk.error";

@implementation GBError


- (NSString *)localizedDescription {
    
    NSError *underlyingError = [self.userInfo objectForKey:NSUnderlyingErrorKey];
    
    if (underlyingError != nil) {
        return [NSString stringWithFormat:@"%@", [underlyingError localizedDescription]];
    } else {
        // error code
        
//        switch (self.code) {
//            case 0:
//                return GBLocalizedString(@"error_string_key", nil);
//        }
    }
    
    return nil;
}
@end
