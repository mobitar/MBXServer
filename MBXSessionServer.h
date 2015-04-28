//
//  MBXServer.h
//  Freebie
//
//  Created by Mo Bitar on 6/27/14.
//  Copyright (c) 2014 Freebie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "MBXHTTPSessionManager.h"
#import "MBXServer.h"

extern NSString *const MBXServerDidBecomeReachableNotification;
extern NSString *const MBXServerDidBecomeUnreachableNotification;

@interface MBXSessionServer : NSObject <MBXServer>

@property (nonatomic, strong) MBXHTTPSessionManager *sessionManager;

+ (instancetype)sharedInstance;

- (NSURL *)absoluteURLForPath:(NSString *)path;

@end
