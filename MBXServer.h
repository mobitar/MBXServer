//
//  MBXServer.h
//  Freebie
//
//  Created by Mo Bitar on 6/27/14.
//  Copyright (c) 2014 Freebie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBXServer : NSObject

+ (instancetype)sharedInstance;

- (void)GET:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion;
- (void)GETAbsolute:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion;
- (void)PATCH:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion;
- (void)POST:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion;
- (void)POSTAbsolute:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion;
- (void)DELETE:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion;

@end
