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

//NSString * const AFNetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";
NSString * const ACCOUNT_SEQ_KEY = @"accountSeq";
NSString * const MARKET_CODE_KEY = @"marketCode";
NSString * const GAME_CODE_KEY = @"gameCode";
NSString * const PRODUCT_ID_KEY = @"productID";
NSString * const PRICE_KEY = @"price";


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
    self.relativePath = @"Pay/init";
    self.httpMethod = @"POST";

    self.userAgent = [GBProtocol defaultHeader];
}

- (void)_makeProtocolPaymentIabToken:(NSDictionary *)parameter
{
    self.serverUrl = [[GBSettings currentSettings] inAppServer];
    self.relativePath = @"/Pay/BuyIntent";
    self.httpMethod = @"POST";
    
    self.parameter = @{ACCOUNT_SEQ_KEY : [parameter objectForKey:@"userKey"],
                       MARKET_CODE_KEY : [NSNumber numberWithInt:[GBSettings currentSettings].marketCode],
                       GAME_CODE_KEY : [NSNumber numberWithInt:[GBSettings currentSettings].gameCode],
                       PRODUCT_ID_KEY : [parameter objectForKey:@"productID"],
                       PRICE_KEY : [parameter objectForKey:@"price"]};

    self.userAgent = [GBProtocol defaultHeader]; 
}

- (void)_makeProtocolPaymentSaveReceipt:(NSDictionary *)parameter
{
    self.serverUrl = [[GBSettings currentSettings] inAppServer];
    self.relativePath = @"Pay/SaveReceipt";
    self.httpMethod = @"POST";
    self.parameter = @{
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
    
    self.serverUrl = [[GBSettings currentSettings] inAppServer];
    self.relativePath = @"Pay/RestoreReceipt";
    self.httpMethod = @"POST";
//    self.parameter = @{@"client_secret" : [GBSettings currentSettings].clientSecretKey,
//                       @"userkey" : userKey};
    self.userAgent = [GBProtocol defaultHeader];
}

@end
