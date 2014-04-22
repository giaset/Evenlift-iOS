//
//  ELViewWorkoutTableViewController.h
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-11.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELWorkout.h"

@interface ELViewWorkoutTableViewController : UITableViewController <UIAlertViewDelegate>

- (id)initWithWorkout:(ELWorkout*)workout;
- (id)initWithWorkoutId:(NSString*)workoutId andTitle:(NSString*)title;

@end
