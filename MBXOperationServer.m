//
//  MBXOperationServer.m
//  ParkWhiz
//
//  Created by Mo Bitar on 4/28/15.
//  Copyright (c) 2015 ParkWhiz. All rights reserved.
//

#import "MBXOperationServer.h"
#import "MBXSessionServer.h"

@implementation MBXOperationServer

- (instancetype)init
{
    if(self = [super init]) {
//        __weak typeof(self) weakself = self;
//        [self.operationManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//            if(![weakself isReachable]) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:MBXServerDidBecomeUnreachableNotification object:nil];
//            } else {
//                [[NSNotificationCenter defaultCenter] postNotificationName:MBXServerDidBecomeReachableNotification object:nil];
//            }
//        }];
//        
//        [self.operationManager.reachabilityManager startMonitoring];
    }
    return self;
}

- (void)isReachable:(void(^)(BOOL reachable))completion
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://www.google.com"]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(error == nil);
                });
            }] resume];
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

- (void)GETAbsoluteData:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(NSData *responseData, NSError *error))completion
{
    [self.operationManager GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(operation.responseData, nil);
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

- (AFHTTPRequestOperation *)performRequestForURL:(NSURL *)url HTTPMethod:(NSString *)method parameters:(NSDictionary *)params completion:(void(^)(MBXNetworkResponse *response))completion
{
    NSMutableURLRequest *request = [self.operationManager.requestSerializer requestWithMethod:method URLString:url.absoluteString parameters:params error:nil];
    
    AFHTTPRequestOperation *operation = [self.operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        MBXNetworkResponse *response = [MBXNetworkResponse new];
        response.responseObject = responseObject;
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            response.responseDictionary = responseObject;
        } else if([responseObject isKindOfClass:[NSArray class]]) {
            response.responseArray = responseObject;
        }
        response.responseData = operation.responseData;
        response.request = operation.request;
        response.responseString = operation.responseString;
        completion(response);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if([operation.responseObject isKindOfClass:[NSDictionary class]]) {
            error = [self error:error customUserInfo:operation.responseObject];
        }
        MBXNetworkResponse *response = [MBXNetworkResponse new];
        response.error = error;
        response.request = operation.request;
        response.responseString = operation.responseString;
        NSLog(@"%@", response.debugDescription);
        completion(response);
    }];
    
    [self.operationManager.operationQueue addOperation:operation];
    
    return operation;
}

- (NSError *)error:(NSError *)error customUserInfo:(NSDictionary *)dictionary
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
    [userInfo addEntriesFromDictionary:dictionary];
    return [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:userInfo];
}

@end
