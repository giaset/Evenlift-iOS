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
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    [dateFormatter setDateFormat:@"MM/dd"];
    self.dateLabel.text = [dateFormatter stringFromDate:workoutDate];
    
    // Set title label
    NSString* titleString = @"UNTITLED WORKOUT";
    if (![workout.title isEqualToString:@""]) {
        titleString = [workout.title uppercaseString];
    }
    self.titleLabel.text = titleString;
}

@end