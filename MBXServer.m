//
//  MBXServer.m
//  Freebie
//
//  Created by Mo Bitar on 6/27/14.
//  Copyright (c) 2014 Freebie. All rights reserved.
//

#import "MBXServer.h"

@interface MBXServer ()

@end

@implementation MBXServer

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

- (AFHTTPRequestOperationManager *)manager
{
    if(!_manager) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithArray:@[@"application/json"]]];
        self.manager = manager;
    }
    return _manager;
}

- (void)GET:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self GETAbsolute:[[self host] stringByAppendingPathComponent:path] parameters:params completion:completion];
}

- (void)GETAbsolute:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self.manager GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *customError = [self error:error customUserInfo:operation.responseObject];
        completion(nil, customError);
    }];
}

- (void)PATCH:(NSString *)path parameters:(NSDictionary *)params completion:(void (^)(id, NSError *))completion
{
    [self.manager PATCH:[[self host] stringByAppendingPathComponent:path] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *customError = [self error:error customUserInfo:operation.responseObject];
        completion(nil, customError);
    }];
}

- (void)POST:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self POSTAbsolute:[[self host] stringByAppendingPathComponent:path] parameters:params completion:completion];
}

- (void)POSTAbsolute:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self.manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *customError = [self error:error customUserInfo:operation.responseObject];
        completion(nil, customError);
    }];
}

- (void)DELETE:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion
{
    [self.manager DELETE:[[self host] stringByAppendingPathComponent:path] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *customError = [self error:error customUserInfo:operation.responseObject];
        completion(nil, customError);
    }];
}

- (NSError *)error:(NSError *)error customUserInfo:(NSDictionary *)dictionary
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
    [userInfo addEntriesFromDictionary:dictionary];
    return [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:userInfo];
}

@end
