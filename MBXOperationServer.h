//
//  MBXOperationServer.h
//  ParkWhiz
//
//  Created by Mo Bitar on 4/28/15.
//  Copyright (c) 2015 ParkWhiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "MBXServer.h"

@interface MBXOperationServer : NSObject <MBXServer>

@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

- (NSURL *)absoluteURLForPath:(NSString *)path;

@end
