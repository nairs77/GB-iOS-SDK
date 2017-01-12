//
//  GBProtocol+Store.m
//  GB
//
//  Created by Professional on 2014. 6. 13..
//  Copyright (c) 2014년 GeBros. All rights reserved.
//

#import "GBProtocol+Store.h"
#import "GBDeviceUtil.h"
#import "GBSettings.h"

@interface GBProtocol(StoreMethod)

- (void)_makeProtocolPaymentMarketInfo;
- (void)_makeProtocolPaymentIabToken:(NSDictionary *)parameter;
- (void)_makeProtocolPaymentSaveReceipt:(NSDictionary *)parameter;
- (void)_makeProtocolRestore:(NSDictionary *)parameter;
- (void)_makeProtocolDownload:(NSDictionary *)parameter;
- (void)_makeProtocolQuery:(NSDictionary *)parameter;
- (void)_makeProtocolPaymentErrorInfo:(NSDictionary *)info;
- (void)_makeProtocolCheckSubscription:(NSDictionary *)parameter;
- (void)_makeProtocolPayInfo:(NSDictionary *)parameter;
- (void)_makeProtocolSetLog:(NSDictionary *)parameter;

@end


@implementation GBProtocol (Store)

+ (GBProtocol *)makeRequestPayment:(NSUInteger)command param:(NSDictionary *)parameter
{
    GBProtocol *protocol = [[self alloc] init];
    protocol.command = command;
    
    switch (command) {
        case GB_MARKET_INFO:
            [protocol _makeProtocolPaymentMarketInfo];
            break;
        case GB_GET_IAB_TOKEN:
            [protocol _makeProtocolPaymentIabToken:parameter];
            break;
            
        case GB_SAVE_RECEIPT:
            [protocol _makeProtocolPaymentSaveReceipt:parameter];
            break;
            
        case GB_RESTORE:
            [protocol _makeProtocolRestore:parameter];
            break;
            

        default:
            NSAssert(command > GB_RESTORE, @"Not Support command");
            return nil;
            
    }
    
    return protocol;
}

#pragma mark - Private Methods

- (void)_makeProtocolPaymentMarketInfo
{
    self.serverUrl = [[GBSettings currentSettings] inAppServer];
    self.relativePath = @"pay/init";
    self.httpMethod = @"POST";
    self.parameter = @{@"client_secret" : [GBSettings currentSettings].clientSecretKey,
                       @"market_code" : [NSNumber numberWithInt:[GBSettings currentSettings].marketCode]};
    self.userAgent = [GBProtocol defaultHeader];
}

- (void)_makeProtocolPaymentIabToken:(NSDictionary *)parameter
{
    NSString *userKey = [GBSettings currentSettings].userKey;
    
    self.serverUrl = [[GBSettings currentSettings] inAppServer];
    self.relativePath = @"pay/key";
    self.httpMethod = @"POST";
    
    NSString *extraString = nil;
    
    if (parameter != nil) {
        extraString = [parameter objectForKey:@"extra_data"];
    } else {
        extraString = (id)[NSNull null];
    }
    
    self.parameter = @{@"client_secret" : [GBSettings currentSettings].clientSecretKey,
                       @"userkey" : userKey,
                       @"market_code" : [NSNumber numberWithInt:[GBSettings currentSettings].marketCode],
                       @"ip" : [GBDeviceUtil deviceIpAddress],
                       @"extra_data" : extraString};
    self.userAgent = [GBProtocol defaultHeader];
}

- (void)_makeProtocolPaymentSaveReceipt:(NSDictionary *)parameter
{
    NSString *userKey = [GBSettings currentSettings].userKey;
    
    self.serverUrl = [[GBSettings currentSettings] inAppServer];
    self.relativePath = @"pay/receipt";
    self.httpMethod = @"POST";
    self.parameter = @{@"client_secret" : [GBSettings currentSettings].clientSecretKey,
                       @"userkey" : userKey,
                       @"market_code" : [NSNumber numberWithInt:[GBSettings currentSettings].marketCode],
                       @"ip" : [GBDeviceUtil deviceIpAddress],
                       @"payment_key" : [parameter objectForKey:@"payment_key"],
                       @"product_id" : [parameter objectForKey:@"product_id"],
                       @"order_id" : [parameter objectForKey:@"order_id"],
                       @"receipt" : [parameter objectForKey:@"receipt"],
                       @"transaction" : [parameter objectForKey:@"transaction"],
                       @"is_subscription" : [parameter objectForKey:@"is_subscription"]};
    self.userAgent = [GBProtocol defaultHeader];
}

- (void)_makeProtocolRestore:(NSDictionary *)parameter
{
    NSString *userKey = [GBSettings currentSettings].userKey;
    
    self.serverUrl = [[GBSettings currentSettings] inAppServer];
    self.relativePath = @"pay/fail/restore";
    self.httpMethod = @"POST";
    self.parameter = @{@"client_secret" : [GBSettings currentSettings].clientSecretKey,
                       @"userkey" : userKey};
    self.userAgent = [GBProtocol defaultHeader];
}

@end
