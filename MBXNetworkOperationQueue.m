//
//  MBXNetworkOperationQueue.m
//  ParkWhiz
//
//  Created by Mo Bitar on 10/27/15.
//  Copyright © 2015 ParkWhiz. All rights reserved.
//

#import "MBXNetworkOperationQueue.h"
#import "MBXOperationServer.h"

@interface MBXNetworkOperationQueue () <MBXNetworkOperationDelegate>

@property (nonatomic) MBXOperationServer *server;

@property (nonatomic) NSMutableArray *queuedOperations;

@property (nonatomic) NSMutableArray *executingOperations;

@end

@implementation MBXNetworkOperationQueue

- (instancetype)initWithServer:(MBXOperationServer *)server
{
    if(self = [super init]) {
        self.server = server;
        self.queuedOperations = [NSMutableArray new];
        self.executingOperations = [NSMutableArray new];
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
    NSLog(@"Beginning operation: %@", operation);
    
    [self.queuedOperations removeObject:operation];
    
    [self.executingOperations addObject:operation];
    
    [operation prepareToBegin];
    [operation begin];
}

- (void)cancelOperation:(MBXNetworkOperation *)operation
{
    if(operation.running) {
        NSLog(@"Cancelling running operation: %@", operation);
        [operation cancel];
        NSAssert([self.executingOperations containsObject:operation], nil);
        [self.executingOperations removeObject:operation];
    } else {
        NSLog(@"Cancelling queued operation: %@", operation);
        NSAssert([self.queuedOperations containsObject:operation], nil);
        [self.queuedOperations removeObject:operation];
    }
}

#pragma mark - Network Operation Delegate

- (void)networkOperation:(MBXNetworkOperation *)operation didCompleteWithResponse:(MBXNetworkResponse *)response
{
    if(response.error) {
        if(response.error.code == NSURLErrorCancelled) {
            NSLog(@"Operation cancelled: %@", operation);
        } else {
            NSLog(@"Completed operation: %@ with error: %@", operation, response.error);
        }
    } else {
        NSLog(@"Completed operation successfully: %@", operation);
    }
    
    [self.executingOperations removeObject:operation];
    
    if(self.queuedOperations.count > 0 && [self canRunNextRequest]) {
        [self beginOperation:self.queuedOperations.firstObject];
    }
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
            NSLog(@"Cancelling queued operation that failed dependency: %@", operation);
            [self cancelOperation:operation];
        }
    }
    
    for(MBXNetworkOperation *operation in self.executingOperations) {
        if([operation passesDependencies] == NO) {
            NSLog(@"Cancelling running operation that failed dependency: %@", operation);
            [self cancelOperation:operation];
        }
    }
}

@end
