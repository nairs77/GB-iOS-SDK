//
//  JoypleReceiptVerificator.m
//  Joyple
//
//  Created by Professional on 2014. 6. 17..
//  Copyright (c) 2014년 Joycity. All rights reserved.
//

#import "JoypleReceiptVerificator.h"
#import "NSData+Formatter.h"
#import "JoypleLog.h"

//#define _TEST_VERIFY_

@implementation JoypleReceiptVerificator

- (void)verifyTransaction:(SKPaymentTransaction*)transaction
                  success:(void (^)(NSString *base64EncodingData))successBlock
                  failure:(void (^)(JoypleError *error))failureBlock
{
    BOOL iOS7OrHigher = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1;
    
    NSString *receipt = nil;
    
    if (iOS7OrHigher) {
        NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        
        NSData *rawReceipt = [NSData dataWithContentsOfURL:receiptURL];
        
        if (rawReceipt)
            receipt = [rawReceipt stringByBase64Encoding];
        
    } else {
        receipt = [transaction.transactionReceipt stringByBase64Encoding];
    }
    
#if 0
    if (receipt == nil) {
        JLogVerbose(@"Failed to serialize receipt into JSON");
        if (failureBlock != nil)
        {
            failureBlock(nil);
        }
        return;
    } else {
        static NSString *receiptDataKey = @"receipt-data";
        NSDictionary *jsonReceipt = @{receiptDataKey : receipt};
        
        NSError *error;
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:jsonReceipt options:0 error:&error];
        if (!requestData)
        {
            JLogVerbose(@"Failed to serialize receipt into JSON");
            if (failureBlock != nil)
            {
                failureBlock(nil);
            }
            return;
        }
        
        static NSString *productionURL = @"https://sandbox.itunes.apple.com/verifyReceipt";
        
        [self verifyRequestData:requestData url:productionURL success:nil failure:nil];
    }
#else
    
    if (receipt == nil) {
        if (failureBlock != nil) {
            JoypleError *error = [JoypleError errorWithDomain:JoypleErrorDomain code:0 userInfo:nil];
            failureBlock(error);
        }
        return;
    } else {
        successBlock(receipt);
    }
#endif
}

#if 0
- (void)verifyRequestData:(NSData*)requestData
                      url:(NSString*)urlString
                  success:(void (^)())successBlock
                  failure:(void (^)(NSError *error))failureBlock
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = requestData;
    static NSString *requestMethod = @"POST";
    request.HTTPMethod = requestMethod;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!data)
            {
                JLogVerbose(@"Server Connection Failed");
                JoypleError *wrapperError = [JoypleError errorWithDomain:JoypleErrorDomain code:[error code] userInfo:@{NSUnderlyingErrorKey : error, NSLocalizedDescriptionKey : NSLocalizedString(@"Connection to Apple failed. Check the underlying error for more info.", @"Error description")}];
                if (failureBlock != nil)
                {
                    failureBlock(wrapperError);
                }
                return;
            }
            NSError *jsonError;
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!responseJSON)
            {
                JLogVerbose(@"Failed To Parse Server Response");
                if (failureBlock != nil)
                {
                    failureBlock(jsonError);
                }
            }
            
            static NSString *statusKey = @"status";
            NSInteger statusCode = [responseJSON[statusKey] integerValue];
            
            static NSInteger successCode = 0;
            static NSInteger sandboxCode = 21007;
            if (statusCode == successCode)
            {
                if (successBlock != nil)
                {
                    successBlock();
                }
            }
            else if (statusCode == sandboxCode)
            {
                JLogVerbose(@"Verifying Sandbox Receipt");
                // From: https://developer.apple.com/library/ios/#technotes/tn2259/_index.html
                // See also: http://stackoverflow.com/questions/9677193/ios-storekit-can-i-detect-when-im-in-the-sandbox
                // Always verify your receipt first with the production URL; proceed to verify with the sandbox URL if you receive a 21007 status code. Following this approach ensures that you do not have to switch between URLs while your application is being tested or reviewed in the sandbox or is live in the App Store.
                
                static NSString *sandboxURL = @"https://sandbox.itunes.apple.com/verifyReceipt";
                [self verifyRequestData:requestData url:sandboxURL success:successBlock failure:failureBlock];
            }
            else
            {
                JLogVerbose(@"Verification Failed With Code %ld", (long)statusCode);
                JoypleError *serverError = [JoypleError errorWithDomain:JoypleErrorDomain code:statusCode userInfo:nil];
                if (failureBlock != nil)
                {
                    failureBlock(serverError);
                }
            }
        });
    });
}
#endif
@end
