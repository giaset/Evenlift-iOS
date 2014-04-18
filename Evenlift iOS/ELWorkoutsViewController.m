//
//  ELWorkoutsViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-23.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELWorkoutsViewController.h"
#import <Firebase/Firebase.h>
#import "ELAddSetsViewController.h"
#import "ELWorkout.h"
#import "ELWorkoutTableViewCell.h"
#import "ELViewWorkoutTableViewController.h"

@interface ELWorkoutsViewController ()

@property (nonatomic, strong) Firebase* allWorkoutsRef;
@property (nonatomic, strong) Firebase* userWorkoutsRef;
@property (nonatomic, strong) Firebase* currentWorkoutRef;

@property (nonatomic, strong) NSMutableArray* workouts;

@property NSString* userId;

@end

@implementation ELWorkoutsViewController

- (id)init
{
    self = [super initWithNibName:@"ELWorkoutsViewController" bundle:nil];
    if (self) {
        // Set up the Firebase for all workouts
        self.allWorkoutsRef = [[Firebase alloc] initWithUrl:@"https://evenlift.firebaseio.com/workouts/"];
        
        // Set up the Firebase for this user's workouts
        self.userId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
        NSString* userWorkoutsUrl = [NSString stringWithFormat:@"https://evenlift.firebaseio.com/users/%@/workouts/", self.userId];
        self.userWorkoutsRef = [[Firebase alloc] initWithUrl:userWorkoutsUrl];
        
        // Set up our local array that is the data source to our table view
        self.workouts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    
    // Register ELWorkoutTableViewCell nib for this tableView
    [self.tableView registerNib:[UINib nibWithNibName:@"ELWorkoutTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"WorkoutCell"];
    
    // Set up leftBarButtonItem
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // Set up rightBarButtonItem
    UIBarButtonItem* addWorkoutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(popAddAlert)];
    self.navigationItem.rightBarButtonItem = addWorkoutButton;
    
    // Bind to user's workouts Firebase
    [self.userWorkoutsRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot) {
        NSString* workoutId = snapshot.name;
        // Bind to each individual workout's Firebase
        [[self.allWorkoutsRef childByAppendingPath:workoutId] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            // Check if the workout was deleted
            if(snapshot.value == [NSNull null]) {
                NSMutableArray* toDelete = [NSMutableArray array];
                for (ELWorkout* workout in self.workouts) {
                    if (workout.workoutId == workoutId) {
                        [toDelete addObject:workout];
                    }
                }
                [self.workouts removeObjectsInArray:toDelete];
            } else {
                // If not, check if it exists in our array
                BOOL exists = NO;
                
                for (ELWorkout* workout in self.workouts) {
                    if (workout.workoutId == workoutId) {
                        // If it does, update it
                        exists = YES;
                        [workout updateWithDictionary:snapshot.value];
                        break;
                    }
                }
                
                // If it doesn't, create it
                if (!exists) {
                    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary:snapshot.value];
                    [dict setObject:workoutId forKey:@"workout_id"];
                    ELWorkout* workout = [[ELWorkout alloc] initWithDictionary:dict];
                    [self.workouts addObject:workout];
                }
            }
            [self.tableView reloadData];
        }];
    }];
    
    // Customize the back button title for the next viewController on the stack...
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil];
}

- (IBAction)popAddAlert
{
    UIAlertView* addAlert = [[UIAlertView alloc]
                             initWithTitle:@"Create Workout"
                             message:@"Please enter an optional title for this workout.\n(ex: Max-Effort Upper Body)"
                             delegate:self
                             cancelButtonTitle:@"Cancel"
                             otherButtonTitles:@"Ok", nil];
    addAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    addAlert.tag = 3;
    [addAlert show];
}

- (void)createWorkoutWithTitle:(NSString*)title
{
    // First create the workout on Firebase
    self.currentWorkoutRef = [self.allWorkoutsRef childByAutoId];
    
    [[self.currentWorkoutRef childByAppendingPath:@"start_time"] setValue:[ELDateTimeUtil getCurrentTime]];
    
    [[self.currentWorkoutRef childByAppendingPath:@"title"] setValue:title];
    
    [[self.currentWorkoutRef childByAppendingPath:@"user_id"] setValue:self.userId];
    
    // Next, add a reference to this workout to the user's workout list
    NSString* workoutId = self.currentWorkoutRef.name;
    [[self.userWorkoutsRef childByAppendingPath:workoutId] setValue:@YES];
    
    // Finally, create the addSetsViewController
    [self launchAddSetsViewControllerForCurrentWorkoutRef];
}

- (void)launchAddSetsViewControllerForCurrentWorkoutRef
{
    ELAddSetsViewController* addSetsViewController = [[ELAddSetsViewController alloc] initWithWorkoutRef:self.currentWorkoutRef];
    
    // Set up left Cancel button
    /*UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked)];
     addSetsViewController.navigationItem.leftBarButtonItem = cancelButton;*/
    
    // Set up right Done button
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)];
    addSetsViewController.navigationItem.rightBarButtonItem = doneButton;
    
    [self.navigationController pushViewController:addSetsViewController animated:YES];
}

- (IBAction)cancelButtonClicked{
    UIAlertView* cancelAlert = [[UIAlertView alloc]
                                initWithTitle:@"Cancel Workout?"
                                message:@"Cancelling this workout will cause all entered data to be discarded. Are you sure?"
                                delegate:self
                                cancelButtonTitle:@"No"
                                otherButtonTitles:@"Yes", nil];
    cancelAlert.tag = 1;
    [cancelAlert show];
}

- (IBAction)doneButtonClicked{
    UIAlertView* doneAlert = [[UIAlertView alloc]
                                initWithTitle:@"Finish Workout?"
                                message:@"Finishing this workout will cause all entered data to be saved forever, without possibility for later modification. Are you sure?"
                                delegate:self
                                cancelButtonTitle:@"No"
                                otherButtonTitles:@"Yes", nil];
    doneAlert.tag = 2;
    [doneAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1) {
        // Clicked YES on "Cancel" Alert View
        [self cancelWorkout];
    } else if (alertView.tag == 2 && buttonIndex == 1) {
        // Clicked YES on "Done" Alert View
        [self finishWorkout];
    } else if (alertView.tag == 3 && buttonIndex == 1) {
        // Clicked OK on "Add" Alert View
        NSString* workoutTitle = [alertView textFieldAtIndex:0].text;
        [self createWorkoutWithTitle:workoutTitle];
    }
}

- (void)cancelWorkout
{
    [self.currentWorkoutRef removeValue];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)finishWorkout
{
    [[self.currentWorkoutRef childByAppendingPath:@"end_time"] setValue:[ELDateTimeUtil getCurrentTime]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.workouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WorkoutCell";
    ELWorkoutTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    ELWorkout* workout = [self.workouts objectAtIndex:(self.workouts.count - 1 - indexPath.row)];
    [cell configureForWorkout:workout];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

// Editing of cells! (in our case, deletion)
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        ELWorkout* workout = [self.workouts objectAtIndex:(self.workouts.count - 1 - indexPath.row)];
        [[self.allWorkoutsRef childByAppendingPath:workout.workoutId] removeValue];
    }
}

// Cell selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the Workout we clicked on
    ELWorkout* workout = [self.workouts objectAtIndex:(self.workouts.count - 1 - indexPath.row)];
    
    if (workout.endTime == nil) {
        // If the clicked workout is still in progress, go back to the Add Sets screen
        self.currentWorkoutRef = [self.allWorkoutsRef childByAppendingPath:workout.workoutId];
        [self launchAddSetsViewControllerForCurrentWorkoutRef];
    } else {
        // If we have clicked a completed workout
        ELViewWorkoutTableViewController* viewWorkout = [[ELViewWorkoutTableViewController alloc] initWithWorkout:workout];
        [self.navigationController pushViewController:viewWorkout animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
