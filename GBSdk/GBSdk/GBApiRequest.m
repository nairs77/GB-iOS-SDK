//
//  GBApiRequest.m
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 3..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import "GBApiRequest.h"
#import "GBProtocol.h"
#import "AFNetworking.h"
#import "GBNetworking.h"
#import "AFHTTPRequestOperationManager.h"
#import "GBDeviceUtil.h"
#import "GBError.h"

@interface GBApiRequest()

@property (nonatomic, strong) NSMutableURLRequest     *urlRequest;
@property (nonatomic, assign) NSStringEncoding        stringEncoding;
@property (nonatomic, copy) NSString                *resourcePath;
@property (nonatomic, copy)	NSString                *httpMethod;
@property (nonatomic, readwrite) NSUInteger reqCommand;

- (id)_initWithURL:(NSString *)baseUrl
             path:(NSString *)relativePath
           method:(NSString *)method
          command:(NSUInteger)command;

- (void)_addParameter:(NSDictionary *)parameter;
- (void)_addAuthorization:(NSString *)authorization;
//- (void)_addDeviceInfo:(NSString *)deviceInfo;
- (void)_addBody:(NSDictionary *)body;
@end

@implementation GBApiRequest

+ (GBApiRequest *)makeRequestWithProtocol:(GBProtocol *)protocol
{
    GBApiRequest *apiRequest = [[GBApiRequest alloc] _initWithProtocol:protocol];
    
    if (protocol.parameter != nil)
        [apiRequest _addParameter:protocol.parameter];
    
    if (protocol.authorization != nil)
        [apiRequest _addAuthorization:protocol.authorization];
    
//    if (protocol.deviceInfo != nil)
//        [request addDeviceInfo:protocol.deviceInfo];
    
    if (protocol.body != nil)
        [apiRequest _addBody:protocol.body];
    
    return apiRequest;
}

- (void)excuteRequest
{
    id<GBNetworking> networkingManager = [self _networkingManager];
    [networkingManager HTTPDataRequestWithRequest:self.urlRequest success:^(id operation, id JSON) {
        
        int errorCode = [[JSON objectForKey:@"RESULT"] intValue];
        if (errorCode == ERROR_SUCCESS) {
            [self.delegate handleApiSuccess:self response:JSON];
        } else {
            GBError *error = [GBError errorWithDomain:GBErrorDomain code:errorCode userInfo:nil];
            [self.delegate handleApiFail:self didWithError:error underlyingError:nil];
        }
    } failure:^(id operation, NSError *error) {
        [self.delegate handleApiFail:self didWithError:nil underlyingError:error];
    }];
}

- (void)excuteRequestWithBlock:(void (^)(id JSON))success
                       failure:(void (^)(NSError *error, id JSON))failure
{
    
}

#pragma mark - Private Methods

- (id)_initWithURL:(NSString *)baseUrl path:(NSString *)relativePath method:(NSString *)method command:(NSUInteger)command
{
    if (self = [super init]) {
        
        NSURL *url = nil;
        NSString *tempUrlString = nil;
        
        NSString *urlPathComponent = [baseUrl substringFromIndex:[baseUrl length] - 1];
        
        if (![urlPathComponent isEqualToString:@"/"])
            tempUrlString = [NSString stringWithFormat:@"%@/", baseUrl];
        else
            tempUrlString = baseUrl;
        
        
        if (relativePath == nil)
            url = [NSURL URLWithString:tempUrlString];
        else
            url = [NSURL URLWithString:relativePath relativeToURL:[NSURL URLWithString:tempUrlString]];
        
        self.urlRequest = [NSMutableURLRequest requestWithURL:url];
        [self.urlRequest setHTTPMethod:method];
        [self.urlRequest setAllHTTPHeaderFields:[GBProtocol defaultHeader]];
        self.reqCommand = command;
        self.httpMethod = method;
        self.resourcePath = relativePath;
    }
    
    return self;
}

- (id)_initWithProtocol:(GBProtocol *)protocol
{

    return [self _initWithURL:protocol.serverUrl path:protocol.relativePath method:protocol.httpMethod command:protocol.command];
}

- (void)_addParameter:(NSDictionary *)parameter
{
    if (parameter) {
        NSString *method = [self.urlRequest HTTPMethod];
        
        if ([method isEqualToString:@"GET"] ||
            [method isEqualToString:@"HEAD"] ||
            [method isEqualToString:@"DELETE"]) {
            
            NSString *urlString = [[self.urlRequest URL] absoluteString];
            
            NSURL *url = [NSURL URLWithString:[urlString stringByAppendingFormat:@"?%@", AFQueryStringFromParametersWithEncoding(parameter, NSUTF8StringEncoding)]];
            
            [self.urlRequest setURL:url];
        } else {
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            //            NSError *error = nil;
            [self.urlRequest setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
            [self.urlRequest setHTTPBody:[AFQueryStringFromParametersWithEncoding(parameter, NSUTF8StringEncoding) dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
}

- (void)_addAuthorization:(NSString *)authorization
{
    [self.urlRequest addValue:[@"Bearer " stringByAppendingString:authorization] forHTTPHeaderField:@"Authorization"];
}

//- (void)_addDeviceInfo:(NSString *)deviceInfo
//{
//    [self.urlRequest addValue:deviceInfo forHTTPHeaderField:@"Device-Info"];
//}

- (void)_addBody:(NSDictionary *)body
{
    
    NSData *dataFromDict = [NSJSONSerialization dataWithJSONObject:body
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
    
    [self.urlRequest setHTTPBody:dataFromDict];
}

- (id<GBNetworking>)_networkingManager
{
    if (IS_IOS6_OR_LESS)
        return [AFHTTPRequestOperationManager manager];
    else
        return [AFHTTPSessionManager manager];
}
@end
