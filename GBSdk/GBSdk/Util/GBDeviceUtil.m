//
//  GBDeviceUtil.m
//  GBSdk
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import "GBDeviceUtil.h"
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "SSKeychain.h"
#import <AdSupport/AdSupport.h>
#import <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

// IDFA
NSString * const kJoypleUpdatedIDFAHashKey = @"com.gebros.idfahash";
#define kJoypleUniqueID		@"com.gebros.joypleID"

@implementation GBDeviceUtil

+ (NSString *)getUUID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef identifier = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    NSString *deviceID = CFBridgingRelease(identifier);
    
    return deviceID;
}

+ (NSString *)uniqueDeviceId
{
    NSString *retrieveuuid = [SSKeychain passwordForService:kJoypleUniqueID account:@"joyple"];
    
    if([retrieveuuid length] > 0) {
        return retrieveuuid;
    } else {
        NSString *vendorIdentifier = [[UIDevice currentDevice].identifierForVendor UUIDString];
        
        if (vendorIdentifier == nil) {
            vendorIdentifier = [GBDeviceUtil getUUID];
        }
        
        [SSKeychain setPassword:vendorIdentifier forService:kJoypleUniqueID account:@"joyple"];
        
        return vendorIdentifier;
    }
}

+ (NSString *)advertisingId
{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

+ (BOOL)advertisingTrackingStatus
{
    return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
}

+ (NSString *)deviceVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)deviceModel
{
    return [[UIDevice currentDevice] model];
}

+ (BOOL)isRooting
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"]){
        return YES;
    }
    
    char *str = "/Application/Cydia.app";
    
    if (open(str, O_RDONLY) != -1) {
        return YES;
    }
    
    NSError *error;
    NSString *stringToBeWritten = @"This is a test.";
    [stringToBeWritten writeToFile:@"/private/jailbreak.txt"
                        atomically:YES
                          encoding:NSUTF8StringEncoding error:&error];
    if(error == nil){
        //Device is jailbroken
        return YES;
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    }
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]){
        //Device is jailbroken
        return YES;
    }
    
    return NO;
}

+ (NSString *)telCarrierName
{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    if (carrier != nil)
        return [carrier carrierName];
    return nil;
}

+ (NSString *)deviceIpAddress
{
    //It was referenced by http://stackoverflow.com/a/10803584
    
    NSArray *searchArray = @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ];
    
    NSDictionary *addresses = [self deviceAllIpAddress];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        address = addresses[key];
        if(address) *stop = YES;
    }];
    
    return address ? address : @"error";
}

+ (NSDictionary *)deviceAllIpAddress
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}
/*
+ (NSString *)deviceInfoForAuth:(NSString *)phoneNumber
{
    NSMutableString *header = [[NSMutableString alloc] initWithString:@"udid="];
    
    // UUID
    [header appendString:[JoypleDeviceUtil uniqueDeviceId]];
    [header appendString:@";"];
    
    // mdn
    if (phoneNumber == nil) {
        [header appendString:@"mdn= -1;"];
    } else {
        [header appendFormat:@"mdn=%@;", phoneNumber];
    }
    // mobile OS
    [header appendString:@"os=iOS;"];
    
    // OS - version
    [header appendString:@"os-version="];
    [header appendString:[JoypleDeviceUtil deviceVersion]];
    [header appendString:@";"];
    
    // Device - Model
    [header appendString:@"device="];
    [header appendString:[JoypleDeviceUtil deviceModel]];
    [header appendString:@";"];
    
    // isRooting
    [header appendString:@"rooting="];
    [header appendString:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:[JoypleDeviceUtil isRooting]]]];
    [header appendString:@";"];
    
    // Telephone Carrier
    [header appendString:@"carrier="];
    
    NSString *carrier = [JoypleDeviceUtil telCarrierName];
    [header appendString:(carrier != nil) ? carrier : @""];
    [header appendString:@";"];
    
    return header;
}
*/
+ (NSString *)currentCountryLanguage
{
    return [[NSLocale preferredLanguages] firstObject];
}

+ (NSString *)currentCountryISO
{
    NSString *systemLanguage = [[NSLocale preferredLanguages] firstObject];
    NSString *currentCountry = nil;
    
    if (systemLanguage != nil)
        currentCountry = [systemLanguage substringToIndex:2];
    else
        currentCountry = @"en";
    
    return currentCountry;
}

+ (NSString *)currentLanguage
{
    NSString *systemLanguage = [[NSLocale preferredLanguages] firstObject];
    NSString *currentCountry = nil;
    
    if (systemLanguage != nil)
        currentCountry = [systemLanguage substringToIndex:2];
    else
        currentCountry = @"en";
    
    if ([currentCountry isEqualToString:@"zh"]) {
        if ([systemLanguage hasPrefix:@"zh-HK"]) {
            return @"zt";
        } else if ([systemLanguage hasPrefix:@"zh-TW"]) {
            return @"zt";
        } else if ([systemLanguage hasPrefix:@"zh-Hant"]) {
            return @"zt";
        } else {
            return @"zh";
        }
    }
    
    /*
     Modify next version.
     Korean = ko
     English = en
     Japanese = ja
     chinese-simplicated = zh
     chinese-traditional = zt
     if ([currentCountry isEqualToString:@"zh"]) {
     if ([systemLanguage hasPrefix:@"zh-HK"]||[systemLanguage hasPrefix:@"zh-Hant"]||[systemLanguage hasPrefix:@"zh-TW"]||[systemLanguage hasPrefix:@"zh-MO"]) {
     return @"zt";
     } else {
     return @"zh";
     }
     }
     */
    
    return currentCountry;
}

+ (NSString *)getMCC
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    
    if (carrier != nil) {
        NSString *mcc = [carrier mobileCountryCode];
        
        if ([mcc length] != 0 && mcc != nil)
            return mcc;
    }
    
    return @"";
}

+ (BOOL)isUpdatedAdvertisingId:(NSString *)userkey //It will be worked about server api call...
{
    NSString *currentAdvertisingId = [GBDeviceUtil advertisingId];
    
    if (!currentAdvertisingId || !userkey) // Must need userkey.
        return NO;
    
    NSUserDefaults *idfaUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([idfaUserDefaults objectForKey:kJoypleUpdatedIDFAHashKey]) {
        
        NSInteger prevIdfaHash = [idfaUserDefaults integerForKey:kJoypleUpdatedIDFAHashKey];
        NSInteger curIdfaHash = [currentAdvertisingId hash];
        
        if (prevIdfaHash == curIdfaHash) {
            
            return NO;
            
        } else {
            
            [idfaUserDefaults setInteger:curIdfaHash forKey:kJoypleUpdatedIDFAHashKey];
            
            return [idfaUserDefaults synchronize];
            
        }
        
    } else {
        
        [idfaUserDefaults setInteger:[currentAdvertisingId hash] forKey:kJoypleUpdatedIDFAHashKey];
        
        return [idfaUserDefaults synchronize];
        
    }
}

@end
