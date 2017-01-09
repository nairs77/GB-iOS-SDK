//
//  Reachability.h
//  Joyple
//
//  Created by nairs77 on 1/17/14.
//  Copyright (c) 2014 Joycity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef NS_ENUM(NSUInteger, NetworkStatus) {
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN
};

extern NSString *kReachabilityChangedNotification;

@interface Reachability: NSObject


//reachabilityWithHostName- Use to check the reachability of a particular host name.
+ (instancetype) reachabilityWithHostName: (NSString*) hostName;

//reachabilityWithAddress- Use to check the reachability of a particular IP address.
+ (instancetype) reachabilityWithAddress: (const struct sockaddr_in*) hostAddress;

//reachabilityForInternetConnection- checks whether the default route is available.
//  Should be used by applications that do not connect to a particular host
+ (instancetype) reachabilityForInternetConnection;

//reachabilityForLocalWiFi- checks whether a local wifi connection is available.
+ (instancetype) reachabilityForLocalWiFi;

//Start listening for reachability notifications on the current run loop
- (BOOL) startNotifier;
- (void) stopNotifier;

- (NetworkStatus) currentReachabilityStatus;
//WWAN may be available, but not active until a connection has been established.
//WiFi may require a connection for VPN on Demand.
- (BOOL) connectionRequired;
@end