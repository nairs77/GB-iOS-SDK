//
//  JoypleProductRequestDelegate.h
//  Joyple
//
//  Created by Professional on 2014. 6. 16..
//  Copyright (c) 2014년 Joycity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class JoypleError;
@class JoypleStoreHelper;

typedef void (^JoypleProductsRequestSuccessBlock)(NSArray *products, NSArray *invalidIdentifiers);
typedef void (^JoypleProductsRequestFailureBlock)(JoypleError *error);

@interface JoypleProductRequestDelegate : NSObject <SKProductsRequestDelegate>

@property (nonatomic, strong) JoypleProductsRequestSuccessBlock successBlock;
@property (nonatomic, strong) JoypleProductsRequestFailureBlock failureBlock;
@property (nonatomic, weak) JoypleStoreHelper *store;
@end
