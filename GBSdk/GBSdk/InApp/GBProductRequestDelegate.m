//
//  GBProductRequestDelegate.m
//  GB
//
//  Created by Professional on 2014. 6. 16..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import "GBProductRequestDelegate.h"
#import "GBLog.h"
#import "GBStoreHelper.h"
#import "GBError.h"
#import "NSBundle+GB.h"

@implementation GBProductRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    JLogVerbose(@"products request received response");
    
    NSArray *products = [NSArray arrayWithArray:response.products];
    NSArray *invalidProductIdentifiers = [NSArray arrayWithArray:response.invalidProductIdentifiers];
    //NSMutableArray *product_ids= [[NSMutableArray alloc] initWithCapacity:0];
    
    for (SKProduct *product in products) {
        JLogVerbose(@"received product with id %@", product.productIdentifier);
        
        [self.store addProduct:product];
        
        //[product_ids addObject:[product productIdentifier]];
    }
    
    [invalidProductIdentifiers enumerateObjectsUsingBlock:^(NSString *invalid, NSUInteger idx, BOOL *stop) {
        JLogVerbose(@"invalid product with id %@", invalid);
    }];
    
    if (self.successBlock) {
        //self.successBlock(product_ids, invalidProductIdentifiers);
        self.successBlock(products, invalidProductIdentifiers);
    }
    
    //TODO: Unit Test
}

#pragma mark - SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request
{
    [self.store removeProductsRequestDelegate:self];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    JLogVerbose(@"products request failed with error %@", error.debugDescription);

    
    if (self.failureBlock) {
        GBError*wrappedError = [GBError errorWithDomain:GBErrorDomain code:[error code] userInfo:@{NSUnderlyingErrorKey : error}];
        self.failureBlock(wrappedError);
    }

    [self.store removeProductsRequestDelegate:self];
}
@end
