//
//  ELAddSetsViewController.h
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-24.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface ELAddSetsViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Firebase* workoutRef;

- (id)initWithWorkoutRef:(Firebase*)workoutRef andExerciseName:(NSString*)exerciseName;

@end
