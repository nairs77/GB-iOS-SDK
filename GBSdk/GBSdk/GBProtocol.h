//
//  GBProtocol.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSString * const ACCOUNT_SEQ_KEY;
FOUNDATION_EXPORT NSString * const MARKET_CODE_KEY;
FOUNDATION_EXPORT NSString * const GAME_CODE_KEY;
FOUNDATION_EXPORT NSString * const PRODUCT_ID_KEY;
FOUNDATION_EXPORT NSString * const PRICE_KEY;
FOUNDATION_EXPORT NSString * const PAYMENT_KEY;


//NSString * const AFNetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";

@interface GBProtocol : NSObject

@property (nonatomic, copy) NSString *serverUrl;
@property (nonatomic, copy) NSString *relativePath;
@property (nonatomic, copy) NSString *httpMethod;
@property (nonatomic, copy) NSDictionary *parameter;
@property (nonatomic, copy) NSDictionary *userAgent;
@property (nonatomic, copy) NSString *authorization;
@property (nonatomic, copy) NSString *deviceInfo;
@property (nonatomic, copy) NSDictionary *body;
@property (nonatomic) NSUInteger command;

+ (NSDictionary *)defaultHeader;

@end
