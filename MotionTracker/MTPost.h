//
//  MTPost.h
//  MotionTracker
//
//  Created by mesird on 08/10/2016.
//  Copyright © 2016 mesird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTPost : NSObject

@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, copy) NSString *text;

- (instancetype)initWithText:(NSString *)text longitude:(double)longitude andLatitude:(double)latitude;

@end
