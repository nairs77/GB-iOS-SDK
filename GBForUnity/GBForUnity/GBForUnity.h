//
//  GBForUnity.h
//  GBForUnity
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <GBSdk/GBGlobal.h>

@class GBError;

@interface GBForUnity : NSObject

+ (NSString *)makeSessionResponse:(SessionState)state data:(NSDictionary *)aInfo error:(GBError *)error;
+ (NSString *)makeStatusResponse:(GBError *)error;
+ (NSString *)makeDataResponse:(NSDictionary *)data error:(GBError *)error;
@end
