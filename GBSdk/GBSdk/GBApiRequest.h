//
//  GBApiRequest.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 3..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBProtocol, GBError;

@protocol GBApiRequestDelegate;

@interface GBApiRequest : NSObject

@property (nonatomic, readonly) NSUInteger reqCommand;
@property (nonatomic, weak) id<GBApiRequestDelegate> delegate;

+ (GBApiRequest *)makeRequestWithProtocol:(GBProtocol *)protocol;

- (void)excuteRequest;
- (void)excuteRequestWithBlock:(void (^)(id JSON))success
                       failure:(void (^)(NSError *error, id JSON))failure;
@end

@protocol GBApiRequestDelegate <NSObject>

- (void)handleApiSuccess:(GBApiRequest *)request response:(NSDictionary *)response;
- (void)handleApiFail:(GBApiRequest *)request didWithError:(GBError *)error underlyingError:(NSError *)underlyingError;

@end
