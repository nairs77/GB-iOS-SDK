//
//  GBSession.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBSession.h"
#import "GBAccountStore.h"
#import "GBError.h"
#import "GBLog.h"
#import "GBSession+internal.h"
#import "GBProtocol+Session.h"
#import "AuthAccount.h"
#import "Reachability.h"

@interface GBSession ()

@property (nonatomic, strong) GBSession *currentSession;
@property (nonatomic, readwrite) SessionState session_state;
@property (nonatomic, copy) NSString *userKey;
@property (nonatomic, copy) NSDictionary *accountInfo;

@property (nonatomic, strong) Reachability *networkConnection;
//@property (nonatomic, weak) id<AuthAccount> lastAccount;
@property (nonatomic) BOOL isNetworkWifi;
@property (nonatomic) BOOL isNetworkReachable;

@end

@implementation GBSession

+ (GBSession *)activeSession
{
    return [[GBSession innerInstance] currentSession];
}

+ (void)login:(AuthCompletionHandler)completionHandler
{
    id<AuthAccount>lastAccount = [[GBAccountStore accountStore] lastServiceAccount];
    
    if (lastAccount == nil) {
        lastAccount = [[[GBAccountStore accountStore] serviceWithType:GUEST] serviceAccount];
        
    }
    
    [lastAccount logIn:^(id<AuthAccount> localAccount, GBError *error) {
        if (localAccount != nil && error == nil) {
            [[GBAccountStore accountStore] registerAccount:localAccount switchAccount:YES];
            
            if (completionHandler != nil) {
                GBSession *newSession = [[GBSession alloc] initWithAccount:localAccount];
                newSession.session_state = OPEN;
//                newSession.userKey = [localAccount userKey];
                [[GBSession activeSession] _setActiveSession:newSession];
                completionHandler(newSession, nil);
                
            }
        } else {
            
            GBLogError(@"error = %@", [error localizedDescription]);
            
            if (completionHandler != nil) {
                completionHandler(nil, error);
            }
        }
    }];
}

+ (void)loginWithAuthType:(AuthType)type withHandler:(AuthCompletionHandler)completionHandler
{
    id<AuthAccount>lastAccount = [[GBAccountStore accountStore] lastServiceAccount];
    
    if (lastAccount == nil) {
        lastAccount = [[[GBAccountStore accountStore] serviceWithType:type] serviceAccount];
        
    }
    
    [lastAccount logIn:^(id<AuthAccount> localAccount, GBError *error) {
        if (localAccount != nil && error == nil) {
            [[GBAccountStore accountStore] registerAccount:localAccount switchAccount:YES];
            
            if (completionHandler != nil) {
//                [GBSession activeSession].lastAccount = localAccount;
                GBSession *newSession = [[GBSession alloc] initWithAccount:localAccount];
                newSession.session_state = OPEN;
                newSession.userKey = [localAccount userKey];
                [[GBSession innerInstance] _setActiveSession:newSession];
                completionHandler(newSession, nil);
                
            }
        } else {
            
            GBLogError(@"error = %@", [error localizedDescription]);
            
            if (completionHandler != nil) {
                completionHandler(nil, error);
            }
        }
    }];
}

+ (void)connectChannel:(AuthType)type withHandler:(AuthCompletionHandler)completionHandler
{
    id<AuthAccount> channelAccount = [[[GBAccountStore accountStore] serviceWithType:type] serviceAccount];
    
    
    NSDictionary *param = @{@"accountSeq" : [[GBSession activeSession] userKey], @"checksum" : [[GBSession activeSession] _getCheckSum]};

    [channelAccount connectChannel:param accountBlock:^(id<AuthAccount> localAccount, GBError *error) {
        if (localAccount != nil && error == nil) {
            [[GBAccountStore accountStore] registerAccount:localAccount switchAccount:YES];
            
            if (completionHandler != nil) {
                //                [GBSession activeSession].lastAccount = localAccount;
                GBSession *newSession = [[GBSession alloc] initWithAccount:localAccount];
                newSession.session_state = OPEN;
                newSession.userKey = [localAccount userKey];
                [[GBSession innerInstance] _setActiveSession:newSession];
                completionHandler(newSession, nil);
                
            }
        } else {
            
            GBLogError(@"error = %@", [error localizedDescription]);
            
            if (completionHandler != nil) {
                completionHandler(nil, error);
            }
        }
    }];
}


- (id)init
{
    if (self = [super init]) {
        
        id<AuthAccount> lastAccount = [[GBAccountStore accountStore] lastServiceAccount];
        
        if (lastAccount != nil) {
            self.accountInfo = [lastAccount accountInfo];
            self.session_state = READY;
            [self _setActiveSession:self];
        } else {
            self.session_state = NONE;
        }
        
        //self.currentSession = nil;
    }
    
    return self;
}

- (id)initWithAccount:(id<AuthAccount>)account
{
    if (self = [super init]) {
        self.userKey = [account userKey];
        self.accountInfo = [account accountInfo];
    }
    
    return self;
}

#pragma mark - Public
- (SessionState)state
{
    if (self.currentSession == nil) {
        return NONE;
    } else {
        return self.session_state;
    }
}

- (NSString *)userInfo
{
    return [self.accountInfo objectForKey:@"CHANNEL_USER_ID"];
}

#pragma mark - Private Methods

- (void)_setActiveSession:(GBSession *)aSession
{
    self.currentSession = aSession;
}

- (NSString *)_getCheckSum
{
    return [self.accountInfo objectForKey:@"CHECKSUM"];
}

#pragma mark - Reachability

- (void)_updateInterfaceWithReachability:(Reachability *)curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    switch (netStatus) {
        case NotReachable:
            self.isNetworkWifi = NO;
            self.isNetworkReachable = NO;
            break;
        case ReachableViaWiFi:
            self.isNetworkWifi = YES;
            self.isNetworkReachable = YES;
            break;
        case ReachableViaWWAN:
            self.isNetworkWifi = NO;
            self.isNetworkReachable = YES;
            break;
    }
}

- (void)_reachabilityChanged:(NSNotification *)note
{
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self _updateInterfaceWithReachability:curReach];
}

- (void)_setReachability
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.networkConnection = [Reachability reachabilityForInternetConnection];
    [self.networkConnection startNotifier];
    [self _updateInterfaceWithReachability:self.networkConnection];
}
@end
