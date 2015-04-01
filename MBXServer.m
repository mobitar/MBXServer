//
//  MBXServer.m
//  Freebie
//
//  Created by Mo Bitar on 6/27/14.
//  Copyright (c) 2014 Freebie. All rights reserved.
//

#import "MBXServer.h"
#import "MBXJSONResponseSerializerWithData.h"

NSString *const MBXServerDidBecomeReachableNotification = @"MBXServerDidBecomeReachableNotification";
NSString *const MBXServerDidBecomeUnreachableNotification = @"MBXServerDidBecomeUnreachableNotification";

@interface MBXServer ()

@end

@implementation MBXServer

- (instancetype)init
{
    if(self = [super init]) {
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if(status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
                [[NSNotificationCenter defaultCenter] postNotificationName:MBXServerDidBecomeUnreachableNotification object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:MBXServerDidBecomeReachableNotification object:nil];
            }
        }];

        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
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

- (MBXHTTPSessionManager *)manager
{
    if(!_manager) {
        MBXHTTPSessionManager *manager = [MBXHTTPSessionManager manager];
        manager.responseSerializer = [MBXJSONResponseSerializerWithData serializer];
        [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithArray:@[@"application/json"]]];
        self.manager = manager;
    }
    return _manager;
}

- (NSURL *)absoluteURLForPath:(NSString *)path
{
    return [NSURL URLWithString:[[self host] stringByAppendingPathComponent:path]];
}

- (void)GET:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self GETAbsolute:[self absoluteURLForPath:path].absoluteString parameters:params completion:completion];
}

- (void)performRequest:(AFHTTPRequestOperation *)request
{
    [self.manager.operationQueue addOperation:request];
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    id JSONObject = [self.manager.responseSerializer responseObjectForResponse:response data:data error:error];
    return (JSONObject);
}

- (void)GETAbsolute:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self.manager GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
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
    [self.manager PATCH:[[self host] stringByAppendingPathComponent:path] parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
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
    [self.manager POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
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
    [self.manager DELETE:[[self host] stringByAppendingPathComponent:path] parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
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
