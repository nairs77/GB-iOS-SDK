//
//  GBForUnity.mm
//  GBForUnity
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import "GBForUnity.h"
#import <GBSdk/GBGlobal.h>
#import <GBSdk/GBError.h>

@implementation GBForUnity

+ (NSString *)makeSessionResponse:(SessionState)state data:(NSDictionary *)aInfo error:(GBError *)error
{
    NSDictionary *sessionResponse = nil;
    
    if (error != nil) {
        // error
        NSDictionary *dicError = [GBForUnity _makeErrorResponse:error];
        sessionResponse = @{@"result" : @{@"status" : [NSNumber numberWithBool:NO],
                                          @"error" : dicError, @"state" : SessionString(state)}};
    } else {
        // success
        sessionResponse = @{@"result" : @{@"status" : [NSNumber numberWithBool:YES], @"data" : aInfo, @"state" : SessionString(state)}};
    }
    
    return [GBForUnity _makeResponse:sessionResponse];
}

+ (NSString *)makeStatusResponse:(GBError *)error
{
    NSDictionary *responseData = nil;
    
    if (error == nil)
        responseData = @{@"result" : @{@"status" : [NSNumber numberWithBool:YES]}};
    else
        responseData = [GBForUnity _makeErrorResponse:error];
    
    return [GBForUnity _makeResponse:responseData];
}

#pragma mark - Private

+ (NSString *)_makeResponse:(NSDictionary *)responseData
{
    NSError *jsonError = nil;
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseData options:0 error:&jsonError];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

+ (NSDictionary *)_makeErrorResponse:(GBError *)error
{
    return @{@"errorCode" : [NSNumber numberWithInteger:[error code]], @"errorMessage" : [error localizedDescription]};
}
@end
