//
//  MBXNetworkOperationDependency.m
//  ParkWhiz
//
//  Created by Mo Bitar on 12/10/15.
//  Copyright © 2015 ParkWhiz. All rights reserved.
//

#import "MBXNetworkOperationDependency.h"

@implementation MBXNetworkOperationDependency

+ (instancetype)dependencyOnObject:(id)object
{
    MBXNetworkOperationDependency *dependency = [MBXNetworkOperationDependency new];
    dependency.object = object;
    return dependency;
}

- (BOOL)passes
{
    return self.object != nil;
}

@end
