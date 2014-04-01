//
//  ELWorkoutTableViewCell.h
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-01.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELWorkout.h"

@interface ELWorkoutTableViewCell : UITableViewCell

- (void) configureForWorkout:(ELWorkout*)workout;

@property (weak, nonatomic) IBOutlet UILabel *dateAndTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
