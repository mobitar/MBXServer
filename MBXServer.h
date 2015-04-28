//
//  MBXServer.h
//  ParkWhiz
//
//  Created by Mo Bitar on 4/28/15.
//  Copyright (c) 2015 ParkWhiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MBXServer <NSObject>

- (NSString *)host;

- (void)GET:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion;
- (void)GETAbsolute:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion;
- (void)PATCH:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion;
- (void)POST:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion;
- (void)POSTAbsolute:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion;
- (void)DELETE:(NSString *)path parameters:(NSDictionary *)params completion:(void(^)(id responseObject, NSError *error))completion;

@end
