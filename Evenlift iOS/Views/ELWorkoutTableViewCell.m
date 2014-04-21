//
//  ELWorkoutTableViewCell.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-01.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELWorkoutTableViewCell.h"

@implementation ELWorkoutTableViewCell

- (void)awakeFromNib
{
    // Initialization code, set custom fonts
    self.dayLabel.font = [UIFont fontWithName:@"Gotham" size:10];
    self.dayLabel.textColor = [UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1.0];
    self.dateLabel.font = [UIFont fontWithName:@"Gotham" size:24];
    self.titleLabel.font = [UIFont fontWithName:@"Gotham" size:16];
    self.inProgressLabel.font = [UIFont fontWithName:@"Gotham" size:10];
}

- (void)configureForWorkout:(ELWorkout *)workout
{
    NSDate* workoutDate = [NSDate dateWithTimeIntervalSince1970:[workout.startTime doubleValue]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.locale = locale;
    
    // Set day label
    [dateFormatter setDateFormat:@"EEE"];
    self.dayLabel.text = [[dateFormatter stringFromDate:workoutDate] uppercaseString];
    
    // Set date label
    [dateFormatter setDateFormat:@"dd"];
    self.dateLabel.text = [dateFormatter stringFromDate:workoutDate];
    
    // Set title label
    self.titleLabel.text = [workout.title uppercaseString];
    
    // Show/hide "IN PROGRESS" label depending on whether
    // or not this Workout has an end_time
    self.inProgressLabel.hidden = (workout.endTime == nil) ? 0 : 1;
}

@end
