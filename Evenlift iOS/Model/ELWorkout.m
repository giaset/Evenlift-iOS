//
//  ELWorkout.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-01.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELWorkout.h"

@implementation ELWorkout

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        self.workoutId = [dict objectForKey:@"workout_id"];
        self.title = [dict objectForKey:@"title"];
        self.startTime = (NSNumber*)[dict objectForKey:@"start_time"];
        self.endTime = (NSNumber*)[dict objectForKey:@"end_time"];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict
{
    self.title = [dict objectForKey:@"title"];
    self.startTime = (NSNumber*)[dict objectForKey:@"start_time"];
    self.endTime = (NSNumber*)[dict objectForKey:@"end_time"];
}

@end
