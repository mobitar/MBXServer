//
//  MBXServerController.m
//  Freebie
//
//  Created by Mo Bitar on 6/27/14.
//  Copyright (c) 2014 Freebie. All rights reserved.
//

#import "MBXServerController.h"

@interface MBXServerController ()

@end

@implementation MBXServerController

- (instancetype)initWithServer:(MBXSessionServer *)server
{
    if(self = [super init]) {
        _server = server;
    }
    
    return self;
}

@end
