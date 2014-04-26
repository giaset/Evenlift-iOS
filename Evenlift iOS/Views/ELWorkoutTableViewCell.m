//
//  ELWorkoutTableViewCell.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-01.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELWorkoutTableViewCell.h"
#import "ELColorUtil.h"

@implementation ELWorkoutTableViewCell

- (void)awakeFromNib
{
    // Initialization code, set custom fonts
    self.dayLabel.font = [UIFont fontWithName:@"Gotham" size:10];
    self.dateLabel.font = [UIFont fontWithName:@"Gotham" size:20];
    self.titleLabel.font = [UIFont fontWithName:@"Gotham" size:16];
    self.inProgressLabel.font = [UIFont fontWithName:@"Gotham" size:10];
}

- (void)configureForWorkout:(ELWorkout *)workout
{
    NSDate* workoutDate = [workout workoutDate];
    
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
