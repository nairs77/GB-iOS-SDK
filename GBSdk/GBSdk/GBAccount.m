//
//  GBAccount.m
//  GBSdk
//
//  Created by Professional on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBAccount.h"
#import "GBProtocol+Session.h"

@interface GBAccount ()

@property (nonatomic, readwrite, copy) NSString *userKey;
@property (nonatomic, copy) NSDictionary *_account_Info;

@end

@implementation GBAccount

+ (GBAccount *)defaultAccount
{
    static id _instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _instance = [[GBAccount alloc] init];
    });
    
    return _instance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

#pragma mark - AuthAccount

- (id)initWithAccountInfo:(NSDictionary *)info
{
    if (self = [self init]) {
        
    }
    
    return self;
}

- (NSDictionary *)accountInfo
{
   return self._account_Info;
}

- (void)logIn:(void (^)(id<AuthAccount>, GBError *))accountBlock
{
    // Override Each Account
    [self requestWithCommand:SESSION_GUEST_LOGIN param:nil];
}

- (void)logOut:(void (^)(id<AuthAccount>, GBError *))accountBlock
{
    // All Account
}

- (void)unRegister:(void (^)(id<AuthAccount>, GBError *))accountBlock
{
    // All Account
}

- (AuthType)authType
{
    return GUEST;
}

- (void)requestWithCommand:(SessionCommand)command param:(NSDictionary *)parameter
{
    GBProtocol *protocol = [GBProtocol makeSessionProtocolWithCommand:command param:parameter];
    GBApiRequest *apiRequest = [GBApiRequest makeRequestWithProtocol:protocol];
    apiRequest.delegate = self;

    [apiRequest excuteRequest];
}

#pragma mark - GBApiRequestDelegate
- (void)handleApiSuccess:(GBApiRequest *)request response:(NSDictionary *)response
{
    SessionCommand command = request.reqCommand;
    
    if (command == SESSION_FB_LOGIN ||
        command == SESSION_GUEST_LOGIN) {
        self.userKey = [response objectForKey:@"userKey"];
    }
    
    
}

- (void)handleApiFail:(GBApiRequest *)request didWithError:(GBError *)error underlyingError:(NSError *)underlyingError
{
    
}
@end
