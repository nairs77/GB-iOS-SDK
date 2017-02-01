//
//  GBNetworking.h
//  GBSdk
//
//  Created by Professional on 2017. 2. 1..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSError;
@class AFHTTPRequestSerializer;
@class AFHTTPResponseSerializer;
@protocol AFURLRequestSerialization;
@protocol AFURLResponseSerialization;
@protocol GBNetworking <NSObject>

@required
- (void)HTTPDataRequestWithRequest:(NSURLRequest *)request success:(void (^)(id operation, id JSON))success failure:(void (^)(id operation, NSError *error))failure;

@optional
@property (nonatomic, strong) AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer <AFURLResponseSerialization> * responseSerializer;

@end
