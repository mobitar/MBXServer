//
//  MBXServerController.h
//  Freebie
//
//  Created by Mo Bitar on 6/27/14.
//  Copyright (c) 2014 Freebie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBXOperationServer.h"

@interface MBXServerController : NSObject

@property (nonatomic, readonly) MBXOperationServer *server;

- (instancetype)initWithServer:(MBXOperationServer *)server;

@end
