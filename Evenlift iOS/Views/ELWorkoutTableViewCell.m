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
    // Set date & title label
    NSString* dateString = [ELDateTimeUtil dateStringFromTimeStamp:workout.startTime];
    if (![workout.title isEqualToString:@""]) {
        NSString* titleString = [NSString stringWithFormat:@" - %@", workout.title];
        dateString = [dateString stringByAppendingString:titleString];
    }
    self.dateAndTitleLabel.text = dateString;
    
    // Set time label
    NSString* timeString = [NSString stringWithFormat:@"%@ - %@", [ELDateTimeUtil timeStringFromTimeStamp:workout.startTime], [ELDateTimeUtil timeStringFromTimeStamp:workout.endTime]];
    self.timeLabel.text = timeString;
}

@end
