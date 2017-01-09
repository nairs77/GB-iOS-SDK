//
//  GBSdk.m
//  GBSdk
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBSdk.h"
#import "GBSession+internal.h"

@implementation GBSdk

+ (void)initializeWithClientId:(NSString *)clientId secretKey:(NSString *)secretKey {
    
}

+ (GBSession *)activeSession {
    return [GBSession innerInstance];
}

+ (GBInApp *)inAppManager {
    return nil;
}

@end
