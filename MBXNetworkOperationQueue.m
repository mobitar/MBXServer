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
    
    [self.queuedOperations addObject:operation];
    
    if([self canRunNextRequest]) {
        [self beginOperation:operation];
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

#pragma mark - Network Operation Delegate

- (void)networkOperation:(MBXNetworkOperation *)operation didCompleteWithResponseObject:(id)responseObject error:(NSError *)error
{
    NSLog(@"Completed operation: %@", operation);
    
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

@end
