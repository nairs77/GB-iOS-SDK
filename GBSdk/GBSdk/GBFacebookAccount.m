//
//  GBFacebookAccount.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 12..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBFacebookAccount.h"
#import "GBFacebookService.h"
#import "GBDeviceUtil.h"
#import "GBLog.h"

#define FBSDK_CANOPENURL_FACEBOOK @"fbauth2"

@interface GBFacebookAccount ()

@property (nonatomic, copy) NSArray *_permissions;
@property (nonatomic, copy) NSDictionary *_account_Info;
@property (nonatomic) BOOL isConnectedChannel;
@property (nonatomic, copy) NSString *userKey;
@property (nonatomic, copy) NSString *checkSum;

- (void)_handleLoginResult:(FBSDKLoginManagerLoginResult *)result withError:(NSError *)error;

@end

@implementation GBFacebookAccount

+ (GBFacebookAccount *)defaultAccount
{
    static id _instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _instance = [[GBFacebookAccount alloc] init];
    });
    
    return _instance;
}

- (id)init
{
    if (self = [super init]) {
        self._permissions = [NSArray arrayWithObjects:@"public_profile", @"email", @"user_friends", nil];
    }
    
    return self;
}

- (id)initWithAccountInfo:(NSDictionary *)info
{
    if (self = [self init]) {
        self._account_Info = [info objectForKey:@"info"];
    }
    
    return self;
}

- (void)logIn:(void (^)(id<AuthAccount>, GBError *))accountBlock
{
    if (accountBlock != nil)
        self.accountBlock = accountBlock;
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    
    if ([self _isFacebookAppInstalled]) {
        loginManager.loginBehavior = FBSDKLoginBehaviorNative;
    } else {
        if (IS_IOS9_OR_MORE) {
            loginManager.loginBehavior = FBSDKLoginBehaviorBrowser;
        } else {
            loginManager.loginBehavior = FBSDKLoginBehaviorWeb;
        }
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [loginManager logInWithReadPermissions:self._permissions
                        fromViewController:nil
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                       [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                                       [self _handleLoginResult:result withError:error];
                                   }];
}

- (void)connectChannel:(NSDictionary *)param accountBlock:(void (^)(id<AuthAccount>, GBError *))accountBlock
{
    self.isConnectedChannel = YES;
    
    self.userKey = (NSString *)param[@"accountSeq"];
    self.checkSum = (NSString *)param[@"checksum"];
    
    
    [self logIn:accountBlock];
}

- (NSDictionary *)accountInfo
{
    return self._account_Info;
}

- (AuthType)authType
{
    return FACEBOOK;
}

#pragma mark - Private Methods

- (BOOL)_isFacebookAppInstalled
{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = FBSDK_CANOPENURL_FACEBOOK;
    components.path = @"/";
    return [[UIApplication sharedApplication]
            canOpenURL:components.URL];
}

- (void)_handleLoginResult:(FBSDKLoginManagerLoginResult *)result withError:(NSError *)error
{
    if (error != nil) {
        // Underliying Error
        if (self.accountBlock != nil) {
            self.accountBlock(nil, [GBError errorWithDomain:GBErrorDomain code:ERROR_BASE userInfo:@{NSUnderlyingErrorKey : error}]);
        }
        
        self.accountBlock = nil;
        return;
    }
    
    // - User Cancelled
    if (result.isCancelled) {
        if (self.accountBlock != nil) {
            self.accountBlock(nil, [GBError errorWithDomain:GBErrorDomain code:SESSION_ERROR_FB_USER_CANCELLED userInfo:nil]);
        }
        
        self.accountBlock = nil;
        return;
    }
    
    if (result.token == nil) {
        if (self.accountBlock != nil) {
            self.accountBlock(nil, [GBError errorWithDomain:GBErrorDomain code:SESSION_ERROR_FB_NOT_TOKEN userInfo:nil]);
        }
        
        self.accountBlock = nil;
        return;
        
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:@"id,email" forKey:@"fields"];
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id userInfo, NSError *error) {
/*
            NSString *emailInfo = [userInfo objectForKey:@"email"];
            NSDictionary *paramInfo = nil;
            
            if (emailInfo == nil) {
                paramInfo = @{@"login_type" : [NSNumber numberWithInteger:JoypleThirdPartyAuthTypeFacebook], @"id" : [userInfo objectForKey:@"id"]};
            } else {
                paramInfo = @{@"login_type" : [NSNumber numberWithInteger:JoypleThirdPartyAuthTypeFacebook], @"email" : [userInfo objectForKey:@"email"], @"id" : [userInfo objectForKey:@"id"]};
            }
            
            if (userInfo == nil) {
                paramInfo = nil;
            }
*/
            GBLogVerbose(@"FB Info = %@", userInfo);
            
            NSDictionary *fb_param = nil;
            
            if (self.isConnectedChannel) {
                fb_param = @{@"channel": [NSNumber numberWithInteger:FACEBOOK],
                             @"channelID" : [userInfo objectForKey:@"id"],
                             @"gameCode" : [NSNumber numberWithInt:1],
                             @"accountSeq" : self.userKey,
                             @"checksum" : self.checkSum};
                
                [self requestWithCommand:SESSION_CONNECT_CHANNEL param:fb_param];
            } else {
                fb_param = @{@"channel": [NSNumber numberWithInteger:FACEBOOK],
                             @"channelID" : [userInfo objectForKey:@"id"],
                             @"gameCode" : [NSNumber numberWithInt:1]};
                
                [self requestWithCommand:SESSION_FB_LOGIN param:fb_param];
            }

        }];
        
    }
}


@end
