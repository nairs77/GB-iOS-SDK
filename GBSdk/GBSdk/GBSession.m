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
@property (nonatomic, readwrite) SessionState state;
@property (nonatomic, readwrite, copy) NSString *userKey;
@property (nonatomic, strong) Reachability *networkConnection;
@property (nonatomic, weak) id<AuthAccount> lastAccount;
@property (nonatomic) BOOL isNetworkWifi;
@property (nonatomic) BOOL isNetworkReachable;

@end

@implementation GBSession

+ (GBSession *)activeSession
{
    return [[GBSession innerInstance] currentSession];
}

+ (void)loginWithAuthType:(AuthType)type withHandler:(AuthCompletionHandler)completionHandler
{
    id<AuthAccount>lastAccount = [[GBAccountStore accountStore] lastAccount];
    
    if (lastAccount == nil) {
        lastAccount = [[[GBAccountStore accountStore] serviceWithType:type] serviceAccount];
        
    }
    
    [lastAccount logIn:^(id<AuthAccount> localAccount, GBError *error) {
        if (localAccount != nil && error == nil) {
            [[GBAccountStore accountStore] registerAccount:localAccount switchAccount:YES];
            
            if (completionHandler != nil) {
//                [GBSession activeSession].lastAccount = localAccount;
                GBSession *newSession = [[GBSession alloc] initWithAccount:localAccount];
                newSession.state = OPEN;
                newSession.userKey = [localAccount userKey];
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

- (id)init
{
    if (self = [super init]) {
//       [self _setReachability];
//        self.lastAccount = [self _loadAccountFromStore];
//        [self setActiveSession:self];
//        self.currentState = READY;
        
        self.currentSession = nil;
    }
    
    return self;
}

- (id)initWithAccount:(id<AuthAccount>)account
{
    if (self = [self init]) {
        self.lastAccount = account;
    }
    
    return self;
}

#pragma mark - Public
- (SessionState)state
{
    if (self.currentSession == nil) {
        return READY;
    } else {
        return self.currentSession.state;
    }
}

/*
- (void)loginWithAuthType:(AuthType)authType
              withHandler:(AuthCompletionHandler)completionHandler;
{
    id<AuthAccount>lastAccount = [self _lastAccount];
    
    if (lastAccount == nil) {
        lastAccount = [[[GBAccountStore accountStore] serviceWithType:authType] serviceAccount];
        
    }
    
    [lastAccount logIn:^(id<AuthAccount> localAccount, GBError *error) {
        
    }];


    GBAccountStore *accountStore = [GBAccountStore accountStore];
    id<AuthAccount> lastAccount = [accountStore lastAccount];
    
    if (lastAccount == nil) {
        lastAccount = [accountStore serviceWithType:type];
    } else {
        
    }
    
    
    GBSession *activeSession = self.currentSession;
    
    BOOL isTryLogin = false;
    if (activeSession.state != OPEN) {
        // Try Login
        //[activeSession loginWithAuthType:authType withHandler:completionHandler];
        isTryLogin = true;
    } else {
        // Check State
        if (activeSession.state == OPEN) {
            // Alreay Opened
            //completionHandler();
        } else {
            // Try Login
            //[activeSession loginWithAuthType:authType withHandler:completionHandler];
            isTryLogin = true;
        }
    }
    
    if (isTryLogin) {
        
        //[activeSession _openSessionWithAuthType:authType withHandler:completionHandler];
    }

}
*/
#pragma mark - Private Methods

- (void)_setActiveSession:(GBSession *)aSession
{
    self.currentSession = aSession;
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
