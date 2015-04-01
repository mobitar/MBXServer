//
//  MBXJSONResponseSerializerWithData.h
//  ParkWhiz
//
//  Created by Mo Bitar on 3/27/15.
//  Copyright (c) 2015 ParkWhiz. All rights reserved.
//

#import "AFURLResponseSerialization.h"

/// NSError userInfo key that will contain response data
static NSString * const MBXJSONResponseSerializerDataKey = @"MBXJSONResponseSerializerDataKey";
static NSString * const MBXJSONResponseSerializerStringKey = @"MBXJSONResponseSerializerStringKey";


@interface MBXJSONResponseSerializerWithData : AFJSONResponseSerializer

@end
