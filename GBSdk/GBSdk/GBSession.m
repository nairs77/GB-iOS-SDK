//
//  GBSession.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 9..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBSession.h"
#import "GBSession+internal.h"
#import "GBProtocol.h"
#import "Reachability.h"

@interface GBSession ()

@property (nonatomic) SessionState currentState;
@property (nonatomic, strong) GBSession *currentSession;

@end

@implementation GBSession

+ (GBSession *)activeSession {
    return [GBSession innerInstance];
}

- (id)init {
    if (self = [super init]) {
        [self _setReachability];
        
        //self.currentState = SessionState.READY;
        [self currentState] = SessionState.READY;
    }
    
    return self;
}

#pragma mark -
- (SessionState)state {
    return self.currentState;
}

- (void)setActiveSession:(GBSession *)aSession
{
    self.currentSession = aSession;
}

- (void)login:(int)authType
  withHandler:(AuthCompletionHandler)completionHandler {

    GBSession *activeSession = self.currentSession;
    
    BOOL isTryLogin = false;
    if (activeSession.state != SessionState.OPEN) {
        // Try Login
        //[activeSession loginWithAuthType:authType withHandler:completionHandler];
        isTryLogin = true;
    } else {
        // Check State
        if (activeSession.state == SessionState.OPEN) {
            // Alreay Opened
            //completionHandler();
        } else {
            // Try Login
            //[activeSession loginWithAuthType:authType withHandler:completionHandler];
            isTryLogin = true;
        }
    }
    
    if (isTryLogin) {
        [activeSession _openSessionWithAuthType:authType withHandler:completionHandler];
    }
    
}

#pragma mark - Private Methods
- (void)_openSessionWithAuthType:(AuthType)authType withHandler:(AuthCompletionHandler)completionHandler {

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
