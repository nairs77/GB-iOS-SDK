//
//  GBProtocol.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBProtocol.h"

//NSString * const AFNetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";

@implementation GBProtocol

+ (NSDictionary *)defaultHeader
{
    //NSDictionary *pInfo = [[NSBundle mainBundle] infoDictionary];
    
    NSString *defaultAgent = [NSString stringWithFormat:@""];
    
    return [NSDictionary dictionaryWithObject:defaultAgent forKey:@"User-Agent"];
}
@end
