//
//  GBAccountStore.m
//  GBSdk
//
//  Created by Professional on 2017. 1. 10..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBAccountStore.h"
#import "GBLog.h"

@interface GBAccountStore ()

@property (nonatomic, readwrite, weak) id<AuthService> lastService;
@property (nonatomic, strong) NSMutableArray *authServices;
@property (nonatomic, strong) NSMutableArray *accounts;

@end

@implementation GBAccountStore

+ (GBAccountStore *)accountStore
{
    static GBAccountStore *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[GBAccountStore alloc] init];
    });
    
    return _instance;
}

- (id)init
{
    if (self = [super init]) {
        // Initialization code here.
        self.authServices = [NSMutableArray array];
        self.accounts = [NSMutableArray array];
        
        NSDictionary *servicesDictionary = [self _loadServiceStoreDictionary];
        if (servicesDictionary) {
            GBLogVerbose(@"%@", servicesDictionary);
            [self _saveServiceStoreDictionary:servicesDictionary];
        }
    }
    
    return self;
}

- (id<AuthService>)lastService
{
    id<AuthService> theService = nil;
    
    for (id<AuthService> service in self.authServices) {
        if (service.lastService == YES) {
            theService = service;
            break;
        }
    }
    
    self.lastService = theService;
    
    return theService;
}

- (void)registerAccount:(id<AuthAccount>)theAccount switchAccount:(BOOL)isSwitchAccount
{
    if (theAccount && ![self.accounts containsObject:theAccount])
        [self.accounts addObject:theAccount];
    
    if (isSwitchAccount || (self.lastAccount == nil)) {
        self.lastAccount = theAccount;
        
        for (id<AuthProvider> service in self.authServices) {
            if (service.providerType == theAccount.providerType) {
                service.lastService = YES;
                break;
            }
        }
    }
    
    NSMutableArray *theAccounts = [NSMutableArray array];
    for (id<AuthAccount> account in self.accounts) {
        BOOL isLastAccount = (self.lastAccount == account);
        
        NSArray *keys = [NSArray arrayWithObjects:@"providerType", @"lastAccount", @"sns_access_token", @"sns_refresh_token", nil];
        NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithInt:account.providerType], [NSNumber numberWithBool:isLastAccount], [account sns_access_token], [account sns_refresh_token], nil];
        
        NSDictionary *accountDictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        [theAccounts addObject:accountDictionary];
    }
    
    //NSDictionary *servicesDictionary = [NSDictionary dictionaryWithObject:theAccounts forKey:@"accounts"];
    NSDictionary *servicesDictionary = @{@"accounts" : theAccounts, @"access_token" : [self.lastAccount accessToken], @"refresh_token" : [self.lastAccount refreshToken]};
    
    [self _saveServiceStoreDictionary:servicesDictionary];
}

//- (void)unregisterAccount:(id<AuthAccount>)theAccount unlink:(BOOL)isUnlink
//{
//    
//}

- (void)unregisterAccounts
{
    for (id<AuthService> service in self.authServices) {
        service.lastService = NO;
    }
    
    [self.accounts removeAllObjects];
    
    self.lastAccount = nil;
    
    NSDictionary *servicesDictionary = [NSDictionary dictionaryWithObject:self.accounts forKey:@"accounts"];
    //[self setServicesStoreDictionary:servicesDictionary];
    [self _saveServiceStoreDictionary:servicesDictionary];
}

- (void)registerAuthService:(id<AuthService>)theService
{
    
}

- (id<AuthService>)serviceWithType:(JoypleAuthType)type
{
    id<AuthProvider> theService = nil;
    for (id<AuthProvider> service in self.authProviders) {
        if (service.lastService == YES) {
            theService = service;
            break;
        }
    }
    return theService;
}

#pragma mark - Private Methods

- (NSDictionary *)_loadServiceStoreDictionary
{
return [[NSUserDefaults standardUserDefaults] objectForKey:kJoypleAccountStoreKey];
}

- (void)_saveServiceStoreDictionary:(NSDictionary *)theServiceStoreDictionary
{
    self.serviceStoreDictionary = theServiceStoreDictionary;
    
    [[NSUserDefaults standardUserDefaults] setObject:theServiceStoreDictionary forKey:kJoypleAccountStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    JLogVerbose(@"%@", theServiceStoreDictionary);
}

@end
