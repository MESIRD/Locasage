//
//  MTPost.m
//  MotionTracker
//
//  Created by mesird on 08/10/2016.
//  Copyright © 2016 mesird. All rights reserved.
//

#import "MTPost.h"

@implementation MTPost

- (instancetype)initWithText:(NSString *)text longitude:(double)longitude andLatitude:(double)latitude {
    
    if (self = [super init]) {
        self.text = text;
        self.longitude = longitude;
        self.latitude = latitude;
    }
    return self;
}

@end
