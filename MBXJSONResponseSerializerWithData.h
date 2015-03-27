//
//  MBXJSONResponseSerializerWithData.h
//  ParkWhiz
//
//  Created by Mo Bitar on 3/27/15.
//  Copyright (c) 2015 ParkWhiz. All rights reserved.
//

#import "AFURLResponseSerialization.h"

/// NSError userInfo key that will contain response data
static NSString * const MBXJSONResponseSerializerWithDataKey = @"MBXJSONResponseSerializerWithDataKey";

@interface MBXJSONResponseSerializerWithData : AFJSONResponseSerializer

@end
