//
//  MBXOperationServer.m
//  ParkWhiz
//
//  Created by Mo Bitar on 4/28/15.
//  Copyright (c) 2015 ParkWhiz. All rights reserved.
//

#import "MBXOperationServer.h"

@implementation MBXOperationServer

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


- (AFHTTPRequestOperationManager *)operationManager
{
    if(!_operationManager) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithArray:@[@"application/json"]]];
        self.operationManager = manager;
    }
    return _operationManager;
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
    [self.operationManager.operationQueue addOperation:request];
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    id JSONObject = [self.operationManager.responseSerializer responseObjectForResponse:response data:data error:error];
    return (JSONObject);
}

- (void)GETAbsolute:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self.operationManager GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.responseObject isKindOfClass:[NSDictionary class]]) {
            error = [self error:error customUserInfo:operation.responseObject];
        }
        completion(nil, error);
    }];
}

- (void)PATCH:(NSString *)path parameters:(NSDictionary *)params completion:(void (^)(id, NSError *))completion
{
    [self.operationManager PATCH:[[self host] stringByAppendingPathComponent:path] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.responseObject isKindOfClass:[NSDictionary class]]) {
            error = [self error:error customUserInfo:operation.responseObject];
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
    [self.operationManager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.responseObject isKindOfClass:[NSDictionary class]]) {
            error = [self error:error customUserInfo:operation.responseObject];
        }
        completion(nil, error);
    }];
}

- (void)DELETE:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self.operationManager DELETE:[[self host] stringByAppendingPathComponent:path] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.responseObject isKindOfClass:[NSDictionary class]]) {
            error = [self error:error customUserInfo:operation.responseObject];
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