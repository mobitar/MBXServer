//
//  MBXNetworkOperationQueue.m
//  ParkWhiz
//
//  Created by Mo Bitar on 10/27/15.
//  Copyright © 2015 ParkWhiz. All rights reserved.
//

#import "MBXNetworkOperationQueue.h"
#import "MBXOperationServer.h"

@interface MBXNetworkOperationQueue ()

@property (nonatomic) MBXOperationServer *server;

@property (nonatomic) NSMutableArray *queuedOperations;

@property (nonatomic) NSMutableArray *executingOperations;

@property (nonatomic) NSMutableSet *cachedOperations;

@end

@implementation MBXNetworkOperationQueue

- (instancetype)initWithServer:(MBXOperationServer *)server
{
    if(self = [super init]) {
        self.server = server;
        self.queuedOperations = [NSMutableArray new];
        self.executingOperations = [NSMutableArray new];
        self.cachedOperations = [NSMutableSet new];
    }
    return self;
}

- (void)addOperation:(MBXNetworkOperation *)operation
{
    NSAssert(operation.delegate == nil, @"An operation cannot use the delegate property if using operation queues");
    
    operation.delegate = self;
    
    operation.server = self.server;
    
    if(operation.isExclusive) {
        [self cancelExistingRequestsForExclusiveRequest:operation];
    }
    
    [self.queuedOperations addObject:operation];
    
    if([self canRunNextRequest]) {
        [self beginOperation:operation];
    }
}

- (void)cancelExistingRequestsForExclusiveRequest:(MBXNetworkOperation *)request
{
    for(MBXNetworkOperation *operation in self.executingOperations) {
        if([request isMutuallyExclusiveToRequest:operation]) {
            [self cancelOperation:operation];
        }
    }
    
    for(MBXNetworkOperation *operation in self.queuedOperations) {
        if([request isMutuallyExclusiveToRequest:operation]) {
            [self cancelOperation:operation];
        }
    }
}

- (void)beginOperation:(MBXNetworkOperation *)operation
{
    if(self.loggingEnabled) {
        NSLog(@"Beginning operation: %@", operation);
    }
    
    [self.queuedOperations removeObjectIdenticalTo:operation];
    
    [self.executingOperations addObject:operation];
    
    [operation prepareToBegin];
    
    if(operation.cache) {
        MBXNetworkOperation *cachedOperation = [self.cachedOperations objectsPassingTest:^BOOL(MBXNetworkOperation *candidateOperation, BOOL * _Nonnull stop) {
            return [candidateOperation isEqual:operation];
        }].anyObject;

        if(cachedOperation) {
            NSAssert(cachedOperation.response, nil);
            if(self.loggingEnabled) {
                NSLog(@"Completing operation %@ with cached response: %@", operation, cachedOperation.response);
            }
            [operation finishWithResponse:cachedOperation.response];
            return;
        }
    }
    
    [operation begin];
}

- (void)cancelOperation:(MBXNetworkOperation *)operation
{
    if(operation.running) {
        if(self.loggingEnabled) {
            NSLog(@"Cancelling running operation: %@", operation);
        }
        [operation cancel];
        NSAssert([self.executingOperations containsObject:operation], nil);
        [self.executingOperations removeObjectIdenticalTo:operation];
    } else {
        if(self.loggingEnabled) {
            NSLog(@"Cancelling queued operation: %@", operation);
        }
        NSAssert([self.queuedOperations containsObject:operation], nil);
        [self.queuedOperations removeObjectIdenticalTo:operation];
    }
}

- (void)clearCache
{
    if(self.loggingEnabled) {
        NSLog(@"Clearing %li cached requests", self.cachedOperations.count);
    }
    
    [self.cachedOperations removeAllObjects];
}

#pragma mark - Network Operation Delegate

- (void)networkOperation:(MBXNetworkOperation *)operation didCompleteWithResponse:(MBXNetworkResponse *)response
{
    NSAssert(response != nil, nil);
    
    if(self.loggingEnabled) {
        if(response.error) {
            if(response.error.code == NSURLErrorCancelled) {
                NSLog(@"Operation cancelled: %@", operation);
            } else {
                NSLog(@"Completed operation: %@ with error: %@ URL: %@", operation, response.error, response.request.URL);
            }
        } else {
            NSLog(@"Completed operation successfully: %@ duration: %fs URL: %@", operation, operation.responseDuration, response.request.URL);
        }
    }
    
    [self.executingOperations removeObjectIdenticalTo:operation];
    
    if(operation.cache) {
        // first remove old one so that only the newest one can be inserted
        [self.cachedOperations removeObject:operation];
        [self.cachedOperations addObject:operation];

        if(self.loggingEnabled) {
            NSLog(@"Adding operation to cache: %@", operation);
            NSLog(@"Total cache count: %li", self.cachedOperations.count);
        }
    }
    
    if(self.queuedOperations.count > 0 && [self canRunNextRequest]) {
        [self beginOperation:self.queuedOperations.firstObject];
    }
    
    // latching
    for(MBXNetworkOperation *latchedOperation in operation.latchedOperations) {
        if(self.loggingEnabled) {
            NSLog(@"Performing latched operation: %@", latchedOperation);
        }
        [latchedOperation finishWithResponse:response];
    }

    [operation.latchedOperations removeAllObjects];
}

- (BOOL)canRunNextRequest
{
    if(self.concurrent) {
        return YES;
    } else {
        return self.executingOperations.count == 0;
    }
}


#pragma mark - Dependencies

- (void)cancelOperationsWhichFailDependencies
{
    for(MBXNetworkOperation *operation in self.queuedOperations) {
        if([operation passesDependencies] == NO) {
            if(self.loggingEnabled) {
                NSLog(@"Cancelling queued operation that failed dependency: %@", operation);
            }
            [self cancelOperation:operation];
        }
    }
    
    for(MBXNetworkOperation *operation in self.executingOperations) {
        if([operation passesDependencies] == NO) {
            if(self.loggingEnabled) {
                NSLog(@"Dependency failed for request: %@", operation);
            }
            [self cancelOperation:operation];
        }
    }
}

#pragma mark - Latching

- (MBXNetworkOperation *)operationSimilarTo:(MBXNetworkOperation *)operation fromQueue:(NSArray *)queue
{
    NSInteger index = [queue indexOfObject:operation];
    if(index != NSNotFound) {
        return  queue[index];
    }
    return nil;
}

- (BOOL)isEqualRequestQueuedOrRunning:(MBXNetworkOperation *)request
{
    return [self.queuedOperations containsObject:request] || [self.executingOperations containsObject:request];
}

- (void)latchOperationOntoExistingOperation:(MBXNetworkOperation *)operationToLatch
{
    MBXNetworkOperation *latchOntoOperation = [self operationSimilarTo:operationToLatch fromQueue:self.executingOperations];
    if(!latchOntoOperation) {
        latchOntoOperation = [self operationSimilarTo:operationToLatch fromQueue:self.queuedOperations];
    }
    
    NSAssert(latchOntoOperation, nil);
    
    if(self.loggingEnabled) {
        NSLog(@"Latching operation: %@ onto operation: %@", operationToLatch, latchOntoOperation);
    }
    
    [latchOntoOperation.latchedOperations addObject:operationToLatch];
}

@end
