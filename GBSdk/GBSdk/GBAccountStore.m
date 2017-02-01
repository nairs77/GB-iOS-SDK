//
//  GBAccountStore.m
//  GB
//
//  Created by nairs77 on 12/19/13.
//  Copyright (c) 2013 Joycity. All rights reserved.
//

#import "GBAccountStore.h"
#import "GBGlobal.h"
#import "GBAccount.h"
#import "GBLog.h"

NSString * const kGBAccountStoreKey = @"platform.geBros.com.store";


@interface GBAccountStore ()

@property (nonatomic, readwrite, strong) NSMutableArray *services;
@property (nonatomic, readwrite, strong) NSMutableArray *accounts;
@property (nonatomic, weak) id<AuthAccount> lastAccount;
@property (nonatomic, strong) NSDictionary *serviceStoreDictionary;

- (id<AuthService>)_lastAuthService;

@end

@implementation GBAccountStore

+ (GBAccountStore *)accountStore
{
    static GBAccountStore *_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _instance = [[GBAccountStore alloc] init];
    });
    
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.services = [NSMutableArray array];
        self.accounts = [NSMutableArray array];
        
        NSDictionary *servicesDictionary = [self _loadServiceStoreDictionary];
        if (servicesDictionary) {
            GBLogVerbose(@"%@", servicesDictionary);
            [self _saveServiceStoreDictionary:servicesDictionary];
        }
    }
    
    return self;
}

- (id<AuthAccount>)lastServiceAccount
{
    if (self.lastAccount == nil) {
        //
        id<AuthService> lastService = [self _lastAuthService];
        
        if (lastService != nil)
            self.lastAccount = [lastService serviceAccount];
    }
    
    return self.lastAccount;
}

- (void)registerAuthService:(id<AuthService>)theService
{
    [self.services addObject:theService];
    
    //need to initialize the accounts here
    //iterate over the dictionary and register an acccount for each
    
    NSDictionary *accountsDictionary = [self.serviceStoreDictionary objectForKey:@"accounts"];
//    NSString *info = [self.serviceStoreDictionary objectForKey:@"info"];
    
    if (accountsDictionary) {
        NSEnumerator *enumerator = [accountsDictionary objectEnumerator];
        id value;
        
        while ((value = [enumerator nextObject])) {
            
            NSDictionary *theDictionary = (NSDictionary*)value;
            //NSString *service_name = [theDictionary objectForKey:@"providerClassName"];
            AuthType providerType = [[theDictionary objectForKey:@"providerType"] intValue];
            
            //get the service with the give name and then create a local user using the guid
            if (providerType == theService.authType) {
                NSString *info = [theDictionary objectForKey:@"info"];
                
                id<AuthAccount> account = [theService serviceAccountWithInfo:@{@"info" : info}];
                [self saveAccount:account];
                
                BOOL isPrimary = [(NSNumber*)[theDictionary objectForKey:@"lastAccount"] boolValue];
                if (isPrimary) {
                    self.lastAccount = account;
                    theService.lastService = YES;
                }
            }
        }
    }
    
}

- (id<AuthService>)serviceWithType:(AuthType)type//(NSString*)serviceName
{
    id<AuthService> theService = nil;
    for (id<AuthService> service in self.services) {
        if (type == service.authType) {
            theService = service;
            break;
        }
    }
    return theService;
}

//- (id<AuthAccount>)accountWithType:(AuthType)type//(NSString*)accountName
//{
//    id<AuthAccount> theAccount = nil;
//    for (id<AuthAccount> account in self.accounts) {
//        if (type == account.authType) {
//            theAccount = account;
//            break;
//        }
//    }
//    return theAccount;
//}

- (void)saveAccount:(id<AuthAccount>)theAccount
{
    BOOL bFound = NO;
    
    for (id<AuthAccount> account in self.accounts) {
        
        if (theAccount.authType == account.authType) {
            bFound = YES;
            break;
        }
    }
    
    //only add an account once. what to check for? have service name.
    if (!bFound) {
        [self.accounts addObject:theAccount];
    }
}

- (void)registerAccount:(id<AuthAccount>)theAccount switchAccount:(BOOL)isSwitchAccount;
{
    //only add an account once. what to check for? have service name.
    if (theAccount && ![self.accounts containsObject:theAccount])
        [self.accounts addObject:theAccount];
    
    if (isSwitchAccount || (self.lastAccount == nil)) {
        self.lastAccount = theAccount;
        
        for (id<AuthService> service in self.services) {
            if (service.authType == theAccount.authType) {
                service.lastService = YES;
                break;
            }
        }
    }

    NSMutableArray *theAccounts = [NSMutableArray array];
    for (id<AuthAccount> account in self.accounts) {
        BOOL isLastAccount = (self.lastAccount == account);
        
        NSArray *keys = [NSArray arrayWithObjects:@"providerType", @"lastAccount", @"info", nil];
        NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithInt:account.authType], [NSNumber numberWithBool:isLastAccount], [account accountInfo], nil];
        
        NSDictionary *accountDictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        [theAccounts addObject:accountDictionary];
    }

    NSDictionary *servicesDictionary = @{@"accounts" : theAccounts};
//    NSDictionary *servicesDictionary = @{@"accounts" : theAccounts, @"access_token" : [self.lastAccount accessToken], @"refresh_token" : [self.lastAccount refreshToken]};

//    NSMutableArray *theAccounts = [NSMutableArray array];
//    NSDictionary *servicesDictionary = [NSDictionary dictionaryWithObject:theAccounts forKey:@"accounts"];
    [self _saveServiceStoreDictionary:servicesDictionary];
}

- (void)unregisterAccounts
{
    //    for (id<AuthAccount> account in self.accounts)
    //        [account logout:nil];
    
    for (id<AuthService> service in self.services) {
        service.lastService = NO;
    }
    
    [self.accounts removeAllObjects];
    
    self.lastAccount = nil;
    
    NSDictionary *servicesDictionary = [NSDictionary dictionaryWithObject:self.accounts forKey:@"accounts"];
    //[self setServicesStoreDictionary:servicesDictionary];
    [self _saveServiceStoreDictionary:servicesDictionary];
}


- (void)unregisterAccount:(id<AuthAccount>)theAccount unlink:(BOOL)isUnlink
{
    if (self.lastAccount != nil) {
        
        id<AuthService> lastSerivce = [self _lastAuthService];
        
        if (lastSerivce.authType == lastSerivce.authType) {
            self.lastAccount = nil;
            lastSerivce.lastService = NO;
        }
    }
    
    [self.accounts removeObject:theAccount];
    /*
     //build the array of account dictionaries and then set the accounts dictionary
     
     NSMutableArray *theAccounts = [NSMutableArray array];
     for (id<AuthAccount> account in self.accounts) {
     NSArray *keys = [NSArray arrayWithObjects:@"providerType", @"lastAccount", @"sns_access_token", @"sns_refresh_token", nil];
     
     NSString *accessToken = ([account accessToken] !=nil) ? [account accessToken] : @"";
     NSDictionary *accountDictionary = [NSDictionary
     dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:account.providerType], [NSNumber numberWithBool:NO], [account accessToken], [account refreshToken], nil]
     forKeys:keys];
     [theAccounts addObject:accountDictionary];
     }
     
     NSDictionary *servicesDictionary = @{@"accounts" : theAccounts, @"access_token" : @"", @"refresh_token" :@""};
     
     
     [self _saveServiceStoreDictionary:servicesDictionary];
     */
}

#pragma mark - Private Methods
- (NSDictionary *)removeDuplicatedDataWithDictionary:(NSMutableDictionary *)storeDictionary
{
    if (storeDictionary != nil) {
        
        NSArray *findLastAccounts = [storeDictionary objectForKey:@"accounts"];
        NSMutableArray *foundLastAccount = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *findLastAccount in findLastAccounts) {
            if ([[findLastAccount objectForKey:@"lastAccount"]boolValue] == YES) {
                [foundLastAccount addObject:findLastAccount];
            }
        }
        [storeDictionary setObject:[foundLastAccount copy] forKey:@"accounts"];
    }
    
    NSDictionary *convertDictionary = [NSDictionary dictionaryWithDictionary:storeDictionary];
    
    return convertDictionary;
}
- (NSDictionary *)_loadServiceStoreDictionary
{
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"Bugfix_0.8.2"]) {
        NSMutableDictionary *duplicatedDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:kGBAccountStoreKey]mutableCopy];
        [[NSUserDefaults standardUserDefaults]setObject:@"Duplicatied accounts cleaned" forKey:@"Bugfix_0.8.2"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return [self removeDuplicatedDataWithDictionary:duplicatedDictionary];
        
        /* After do remove this construction */
        
    } else {
        return [[NSUserDefaults standardUserDefaults] objectForKey:kGBAccountStoreKey];
    }
}

- (void)_saveServiceStoreDictionary:(NSDictionary *)theServiceStoreDictionary
{
    self.serviceStoreDictionary = theServiceStoreDictionary;
    
    [[NSUserDefaults standardUserDefaults] setObject:theServiceStoreDictionary forKey:kGBAccountStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    GBLogVerbose(@"%@", theServiceStoreDictionary);
}

- (id<AuthService>)_lastAuthService
{
    id<AuthService> theService = nil;
    for (id<AuthService> service in self.services) {
        if (service.lastService == YES) {
            theService = service;
            break;
        }
    }
    return theService;
}

@end
