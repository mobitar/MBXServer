//
//  MBXNetworkOperationDependency.h
//  ParkWhiz
//
//  Created by Mo Bitar on 12/10/15.
//  Copyright © 2015 ParkWhiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBXNetworkOperationDependency : NSObject

/** require this object to be alive to evaluate to true*/
@property (nonatomic, weak) id object;

- (BOOL)passes;

+ (instancetype)dependencyOnObject:(id)object;

@end
