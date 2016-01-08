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

/** If true, will execute requests concurrently (rather than serially) */
@property (nonatomic) BOOL concurrent;

/** Default is YES */
@property (nonatomic) BOOL runsOnBackgroundThread;

- (void)cancelOperationsWhichFailDependencies;

- (void)clearCache;

@property (nonatomic) BOOL loggingEnabled;

// Latching
/** Returns true if a request isEqual: exists in queued or running operations */
- (BOOL)isEqualRequestQueuedOrRunning:(MBXNetworkOperation *)request;

/** Instead of running duplicate requests, you can latch one request onto another to be notified when the original completes, and be able to handle its response without actually performing the second network request. First check if isEqualRequestQueuedOrRunning: before latching */
- (void)latchOperationOntoExistingOperation:(MBXNetworkOperation *)operationToLatch;

@end
