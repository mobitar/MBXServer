//
//  MBXNetworkResponse.h
//  ParkWhiz
//
//  Created by Mo Bitar on 11/23/15.
//  Copyright © 2015 ParkWhiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBXNetworkResponse : NSObject

@property (nonatomic) id responseObject;
@property (nonatomic) NSData *responseData;
@property (nonatomic) NSError *error;
@property (nonatomic) NSDictionary *responseDictionary;
@property (nonatomic) NSArray *responseArray;

@property (nonatomic) NSURLRequest *request;
@end
