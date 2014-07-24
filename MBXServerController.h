//
//  MBXServerController.h
//  Freebie
//
//  Created by Mo Bitar on 6/27/14.
//  Copyright (c) 2014 Freebie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBXServer.h"

@interface MBXServerController : NSObject

@property (nonatomic, readonly) MBXServer *server;

- (instancetype)initWithServer:(MBXServer *)server;

@end
