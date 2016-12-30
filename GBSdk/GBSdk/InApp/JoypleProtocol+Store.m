//
//  JoypleProtocol+Store.m
//  Joyple
//
//  Created by Professional on 2014. 6. 13..
//  Copyright (c) 2014년 Joycity. All rights reserved.
//

#import "JoypleProtocol+Store.h"
#import "JoypleDeviceUtil.h"

@interface JoypleProtocol(StoreMethod)

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


@implementation JoypleProtocol (Store)

+ (JoypleProtocol *)makeRequestPayment:(NSUInteger)command param:(NSDictionary *)parameter
{
    JoypleProtocol *protocol = [[self alloc] init];
    protocol.command = command;
    
    switch (command) {
        case JOYPLE_MARKET_INFO:
            [protocol _makeProtocolPaymentMarketInfo];
            break;
        case JOYPLE_GET_IAB_TOKEN:
            [protocol _makeProtocolPaymentIabToken:parameter];
            break;
            
        case JOYPLE_SAVE_RECEIPT:
            [protocol _makeProtocolPaymentSaveReceipt:parameter];
            break;
            
        case JOYPLE_RESTORE:
            [protocol _makeProtocolRestore:parameter];
            break;
            
        case JOYPLE_CHECK_SUBSCRIPTION:
            [protocol _makeProtocolCheckSubscription:parameter];
            break;
            
        case JOYPLE_TEST_DOWNLOAD:
            [protocol _makeProtocolDownload:parameter];
            break;
        case JOYPLE_TEST_QUERY:
            [protocol _makeProtocolQuery:parameter];
            break;
        case JOYPLE_TEST_EXCEPTION:
            [protocol _makeProtocolPaymentErrorInfo:parameter];
            break;
        case JOYPLE_TEST_INFO:
            [protocol _makeProtocolPayInfo:parameter];
            break;
        case JOYPLE_TEST_SET_LOG:
            [protocol _makeProtocolSetLog:parameter];
            break;
        default:
            NSAssert(command > JOYPLE_RESTORE, @"Not Support command");
            return nil;
            
    }
    
    return protocol;
}

#pragma mark - Private Methods

- (void)_makeProtocolPaymentMarketInfo
{
    self.serverURL = [[JoypleSetting currentSetting] billingServer];
    self.relativePath = @"pay/init";
    self.httpMethod = @"POST";
    self.parameter = @{@"client_secret" : [JoypleSetting currentSetting].clientSecretKey,
                       @"market_code" : [NSNumber numberWithInt:[JoypleSetting currentSetting].marketCode]};
    self.userAgent = [JoypleProtocol defaultHeader];
}

- (void)_makeProtocolPaymentIabToken:(NSDictionary *)parameter
{
    NSString *userKey = [JoypleSetting currentSetting].userKey;
    
    self.serverURL = [[JoypleSetting currentSetting] billingServer];
    self.relativePath = @"pay/key";
    self.httpMethod = @"POST";
    
    NSString *extraString = nil;
    
    if (parameter != nil) {
        extraString = [parameter objectForKey:@"extra_data"];
    } else {
        extraString = (id)[NSNull null];
    }
    
    self.parameter = @{@"client_secret" : [JoypleSetting currentSetting].clientSecretKey,
                       @"userkey" : userKey,
                       @"market_code" : [NSNumber numberWithInt:[JoypleSetting currentSetting].marketCode],
                       @"ip" : [JoypleDeviceUtil deviceIpAddress],
                       @"extra_data" : extraString};
    self.userAgent = [JoypleProtocol defaultHeader];
}

- (void)_makeProtocolPaymentSaveReceipt:(NSDictionary *)parameter
{
    NSString *userKey = [JoypleSetting currentSetting].userKey;
    
    self.serverURL = [[JoypleSetting currentSetting] billingServer];
    self.relativePath = @"pay/receipt";
    self.httpMethod = @"POST";
    self.parameter = @{@"client_secret" : [JoypleSetting currentSetting].clientSecretKey,
                       @"userkey" : userKey,
                       @"market_code" : [NSNumber numberWithInt:[JoypleSetting currentSetting].marketCode],
                       @"ip" : [JoypleDeviceUtil deviceIpAddress],
                       @"payment_key" : [parameter objectForKey:@"payment_key"],
                       @"product_id" : [parameter objectForKey:@"product_id"],
                       @"order_id" : [parameter objectForKey:@"order_id"],
                       @"receipt" : [parameter objectForKey:@"receipt"],
                       @"transaction" : [parameter objectForKey:@"transaction"],
                       @"is_subscription" : [parameter objectForKey:@"is_subscription"]};
    self.userAgent = [JoypleProtocol defaultHeader];
}

- (void)_makeProtocolRestore:(NSDictionary *)parameter
{
    NSString *userKey = [JoypleSetting currentSetting].userKey;
    
    self.serverURL = [[JoypleSetting currentSetting] billingServer];
    self.relativePath = @"pay/fail/restore";
    self.httpMethod = @"POST";
    self.parameter = @{@"client_secret" : [JoypleSetting currentSetting].clientSecretKey,
                       @"userkey" : userKey};
    self.userAgent = [JoypleProtocol defaultHeader];
}

- (void)_makeProtocolDownload:(NSDictionary *)parameter
{
    NSString *userKey = [JoypleSetting currentSetting].userKey;
    
    self.serverURL = [[JoypleSetting currentSetting] gameServer];
    self.relativePath = @"item/provide";
    self.httpMethod = @"POST";
    self.parameter = @{@"client_secret" : [JoypleSetting currentSetting].clientSecretKey,
                       @"payment_key" : [parameter objectForKey:@"payment_key"],
                       @"userkey" : [NSNumber numberWithInt:[userKey intValue]]};
    self.userAgent = [JoypleProtocol defaultHeader];
}

- (void)_makeProtocolQuery:(NSDictionary *)parameter
{
    NSString *userKey = [JoypleSetting currentSetting].userKey;
    
    self.serverURL = [[JoypleSetting currentSetting] gameServer];
    self.relativePath = @"item/info";
    self.httpMethod = @"POST";
    self.parameter = @{@"client_secret" : [JoypleSetting currentSetting].clientSecretKey,
                       @"userkey" : [NSNumber numberWithInt:[userKey intValue]]};
    self.userAgent = [JoypleProtocol defaultHeader];
}

- (void)_makeProtocolCheckSubscription:(NSDictionary *)parameter
{
    NSString *userKey = [JoypleSetting currentSetting].userKey;
    NSString *originalTransactionId = nil;
    
    if ([parameter objectForKey:@"original_transaction_id"] != nil) {
        originalTransactionId = [parameter objectForKey:@"original_transaction_id"];
    } else {
        originalTransactionId = (id)[NSNull null];
    }
    
    self.serverURL = [[JoypleSetting currentSetting] billingServer];
    self.relativePath = @"pay/subscription/check";
    self.httpMethod = @"POST";
    self.parameter = @{@"client_secret" : [JoypleSetting currentSetting].clientSecretKey,
                       @"userkey" : userKey,
                       @"market_code" : [NSNumber numberWithInt:[JoypleSetting currentSetting].marketCode],
                       @"transaction_id" : [parameter objectForKey:@"transaction_id"],
                       @"original_transaction_id" : originalTransactionId};
    self.userAgent = [JoypleProtocol defaultHeader];
}

- (void)_makeProtocolPaymentErrorInfo:(NSDictionary *)info
{
    self.serverURL = [[JoypleSetting currentSetting] contentAPIServer];
    self.relativePath = @"logs/client/add";
    self.httpMethod = @"POST";
    self.body = info;
    //    self.parameter = @{@"client_secret" : [JoypleSetting currentSetting].clientSecretKey,
    //                       @"market_code" : [NSNumber numberWithInt:[JoypleSetting currentSetting].marketCode]};
    self.userAgent = [JoypleProtocol defaultHeader];
}

#pragma mark Subscription Test

- (void)_makeProtocolPayInfo:(NSDictionary *)parameter
{
    self.serverURL = [[JoypleSetting currentSetting] billingServer];
    self.relativePath = @"pay/info";
    self.httpMethod = @"POST";
    self.parameter = @{@"client_secret" : [JoypleSetting currentSetting].clientSecretKey,
                       @"payment_key" : [parameter objectForKey:@"payment_key"],
                       @"userkey" : [JoypleSetting currentSetting].userKey};
    self.userAgent = [JoypleProtocol defaultHeader];
}

- (void)_makeProtocolSetLog:(NSDictionary *)parameter
{
    self.serverURL = [[JoypleSetting currentSetting] billingServer];
    self.relativePath = @"pay/set-log";
    self.httpMethod = @"POST";
    self.parameter = @{@"client_secret" : [JoypleSetting currentSetting].clientSecretKey,
                       @"payment_key" : [parameter objectForKey:@"payment_key"],
                       @"product_price" : [parameter objectForKey:@"product_price"],
                       @"product_name" : [parameter objectForKey:@"product_name"],
                       @"money_type" : [parameter objectForKey:@"money_type"]};
    self.userAgent = [JoypleProtocol defaultHeader];
}

@end
