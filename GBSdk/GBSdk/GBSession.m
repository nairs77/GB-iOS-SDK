//
//  GBSession.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBSession.h"
#import "GBAccountStore.h"
#import "GBSession+internal.h"
#import "GBProtocol+Session.h"
#import "AuthAccount.h"
#import "Reachability.h"

NSString * const kGBAccountStoreKey = @"geBros.platform.Store";

@interface GBSession ()

//@property (nonatomic, strong) GBSessionStore *store;
@property (nonatomic) SessionState currentState;
@property (nonatomic, strong) GBSession *currentSession;
@property (nonatomic, strong) Reachability *networkConnection;
@property (nonatomic, weak) id<AuthAccount> lastAccount;
@property (nonatomic) BOOL isNetworkWifi;
@property (nonatomic) BOOL isNetworkReachable;

@end

@implementation GBSession

+ (GBSession *)activeSession
{
    return [GBSession innerInstance];
}

- (id)init
{
    if (self = [super init]) {
//       [self _setReachability];
//        self.lastAccount = [self _loadAccountFromStore];
//        [self setActiveSession:self];
//        self.currentState = READY;
    }
    
    return self;
}

#pragma mark - Public
- (SessionState)state
{
    return self.lastAccount.currentState;
}

- (void)loginWithAuthType:(AuthType)authType
              withHandler:(AuthCompletionHandler)completionHandler;
{
    id<AuthService>lastService = [[GBAccountStore accountStore] lastService];
    
    if (lastService == nil) {
        lastService = [[GBAccountStore accountStore] serviceWithType:authType];
    }
    
    [lastService loginWithAccountBlock:^(id<AuthService>theService, GBError *error) {
        
    }];

/*
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
*/
}

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
