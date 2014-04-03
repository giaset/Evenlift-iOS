//
//  ELWorkout.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-01.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELWorkout.h"
#import <Firebase/Firebase.h>

#define kWorkoutsURL @"https://evenlift.firebaseio.com/workouts"

@interface ELWorkout ()

@property (nonatomic, strong) Firebase* workoutRef;

@end

@implementation ELWorkout

- (id)initWithWorkoutId:(NSString*)workoutId
{
    self = [super init];
    if (self) {
        self.workoutId = workoutId;
        
        // Set up the Firebase for this workout
        self.workoutRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://evenlift.firebaseio.com/workouts/%@", self.workoutId]];
        
        // Bind to the workout on Firebase
        [self.workoutRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
            self.title = snapshot.value[@"title"];
            self.startTime = snapshot.value[@"start_time"];
            self.endTime = snapshot.value[@"end_time"];
        }];
    }
    return self;
}

@end
