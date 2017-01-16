//
//  GBProductRequestDelegate.h
//  GB
//
//  Created by Professional on 2014. 6. 16..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class GBError;
@class GBInAppHelper;

typedef void (^GBProductsRequestSuccessBlock)(NSArray *products, NSArray *invalidIdentifiers);
typedef void (^GBProductsRequestFailureBlock)(GBError *error);

@interface GBProductRequestDelegate : NSObject <SKProductsRequestDelegate>

@property (nonatomic, strong) GBProductsRequestSuccessBlock successBlock;
@property (nonatomic, strong) GBProductsRequestFailureBlock failureBlock;
@property (nonatomic, weak) GBInAppHelper *store;
@end
