//
//  MBXNetworkOperationQueue.h
//  ParkWhiz
//
//  Created by Mo Bitar on 10/27/15.
//  Copyright © 2015 ParkWhiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBXNetworkOperation.h"
#import "MBXServer.h"

@interface MBXNetworkOperationQueue : NSObject <MBXNetworkOperationDelegate>

- (instancetype)initWithServer:(MBXOperationServer *)server;

- (void)addOperation:(MBXNetworkOperation *)operation;

/** If true, will execute requests serially */
@property (nonatomic) BOOL concurrent;

- (void)cancelOperationsWhichFailDependencies;

- (void)clearCache;

@property (nonatomic) BOOL loggingEnabled;

@end
