//
//  MBXServer.m
//  Freebie
//
//  Created by Mo Bitar on 6/27/14.
//  Copyright (c) 2014 Freebie. All rights reserved.
//

#import "MBXSessionServer.h"
#import "MBXJSONResponseSerializerWithData.h"

NSString *const MBXServerDidBecomeReachableNotification = @"MBXServerDidBecomeReachableNotification";
NSString *const MBXServerDidBecomeUnreachableNotification = @"MBXServerDidBecomeUnreachableNotification";

@interface MBXSessionServer ()

@end

@implementation MBXSessionServer

- (instancetype)init
{
    if(self = [super init]) {
        [self.sessionManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if(status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
                [[NSNotificationCenter defaultCenter] postNotificationName:MBXServerDidBecomeUnreachableNotification object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:MBXServerDidBecomeReachableNotification object:nil];
            }
        }];

        [self.sessionManager.reachabilityManager startMonitoring];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (NSString *)host
{
    @throw [NSException exceptionWithName:@"Must override" reason:nil userInfo:nil];    
}

- (MBXHTTPSessionManager *)sessionManager
{
    if(!_sessionManager) {
        MBXHTTPSessionManager *manager = [MBXHTTPSessionManager manager];
        manager.responseSerializer = [MBXJSONResponseSerializerWithData serializer];
        [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithArray:@[@"application/json"]]];
        self.sessionManager = manager;
    }
    return _sessionManager;
}

- (NSURL *)absoluteURLForPath:(NSString *)path
{
    return [NSURL URLWithString:[[self host] stringByAppendingPathComponent:path]];
}

- (void)GET:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self GETAbsolute:[self absoluteURLForPath:path].absoluteString parameters:params completion:completion];
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    id JSONObject = [self.sessionManager.responseSerializer responseObjectForResponse:response data:data error:error];
    return (JSONObject);
}

- (void)GETAbsolute:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self.sessionManager GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        id responseObject = [error.userInfo objectForKey:MBXJSONResponseSerializerDataKey];
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            error = [self error:error customUserInfo:responseObject];
        }
        completion(nil, error);
    }];
}

- (void)PATCH:(NSString *)path parameters:(NSDictionary *)params completion:(void (^)(id, NSError *))completion
{
    [self.sessionManager PATCH:[[self host] stringByAppendingPathComponent:path] parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        id responseObject = [error.userInfo objectForKey:MBXJSONResponseSerializerDataKey];
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            error = [self error:error customUserInfo:responseObject];
        }
        completion(nil, error);
    }];
}

- (void)POST:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self POSTAbsolute:[[self host] stringByAppendingPathComponent:path] parameters:params completion:completion];
}

- (void)POSTAbsolute:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self.sessionManager POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        id responseObject = [error.userInfo objectForKey:MBXJSONResponseSerializerDataKey];
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            error = [self error:error customUserInfo:responseObject];
        }
        completion(nil, error);
    }];
}

- (void)DELETE:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self.sessionManager DELETE:[[self host] stringByAppendingPathComponent:path] parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        id responseObject = [error.userInfo objectForKey:MBXJSONResponseSerializerDataKey];
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            error = [self error:error customUserInfo:responseObject];
        }
        completion(nil, error);
    }];
}

- (NSError *)error:(NSError *)error customUserInfo:(NSDictionary *)dictionary
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
    [userInfo addEntriesFromDictionary:dictionary];
    return [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:userInfo];
}

@end
