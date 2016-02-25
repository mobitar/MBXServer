//
//  MBXNetworkResponse.m
//  ParkWhiz
//
//  Created by Mo Bitar on 11/23/15.
//  Copyright © 2015 ParkWhiz. All rights reserved.
//

#import "MBXNetworkResponse.h"

@implementation MBXNetworkResponse

- (NSString *)requestBody
{
    return [[NSString alloc] initWithData:[self.request HTTPBody] encoding:NSUTF8StringEncoding];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"URL: %@\n\nBody: %@\n\nResponse String: %@\n\nError: %@", self.request.URL, self.requestBody, self.responseString, self.error];
}

@end
