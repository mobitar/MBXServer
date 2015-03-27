//
//  MBXJSONResponseSerializerWithData.m
//  ParkWhiz
//
//  Created by Mo Bitar on 3/27/15.
//  Copyright (c) 2015 ParkWhiz. All rights reserved.
//

#import "MBXJSONResponseSerializerWithData.h"

@implementation MBXJSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (*error != nil) {
            NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
            userInfo[MBXJSONResponseSerializerWithDataKey] = data;
            NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
            (*error) = newError;
        }
        
        return (nil);
    }
    
    return ([super responseObjectForResponse:response data:data error:error]);
}

@end
