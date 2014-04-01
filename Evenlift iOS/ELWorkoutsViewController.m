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

@interface ELWorkoutsViewController ()

@property (nonatomic, strong) Firebase* firebase;
@property (nonatomic, strong) Firebase* currentWorkoutRef;

@property (nonatomic, strong) NSMutableArray* workouts;

@end

@implementation ELWorkoutsViewController

- (id)init
{
    self = [super initWithNibName:@"ELWorkoutsViewController" bundle:nil];
    if (self) {
        // Set up the Firebase for this user's workouts
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* uid = [userDefaults stringForKey:@"uid"];
        NSString* userWorkoutsUrl = [NSString stringWithFormat:@"%@%@", @"https://evenlift.firebaseio.com/workouts/", uid];
        self.firebase = [[Firebase alloc] initWithUrl:userWorkoutsUrl];
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
    
    UIBarButtonItem* addWorkoutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(popAddAlert)];
    self.navigationItem.rightBarButtonItem = addWorkoutButton;
    
    // Bind to user's workouts Firebase
    FQuery* lastTenWorkoutsQuery = [self.firebase queryLimitedToNumberOfChildren:10];
    
    [lastTenWorkoutsQuery observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot) {
        NSDictionary* workoutDict = snapshot.value;
        ELWorkout* workoutObject = [[ELWorkout alloc] initWithDictionary:workoutDict];
        // Add a little delay here to prevent new cell popping up at top before addSetsViewController is fully visible
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // code to be executed on the main queue after delay
            [self.workouts addObject:workoutObject];
            [self.tableView reloadData];
        });
    }];
    
    [lastTenWorkoutsQuery observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        ELWorkout* removedWorkout = [[ELWorkout alloc] initWithDictionary:(NSDictionary*)snapshot.value];
        NSMutableArray* toDelete = [NSMutableArray array];
        for (ELWorkout* workout in self.workouts) {
            if (workout.startTime == removedWorkout.startTime) {
                [toDelete addObject:workout];
            }
        }
        [self.workouts removeObjectsInArray:toDelete];
        [self.tableView reloadData];
    }];
    
    [lastTenWorkoutsQuery observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        ELWorkout* modifiedWorkout = [[ELWorkout alloc] initWithDictionary:(NSDictionary*)snapshot.value];
        for (ELWorkout* workout in self.workouts) {
            if (workout.startTime == modifiedWorkout.startTime) {
                workout.endTime = modifiedWorkout.endTime;
                workout.title = modifiedWorkout.title;
            }
        }
        [self.tableView reloadData];
    }];
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

- (void)launchAddSetsViewControllerWithTitle:(NSString*)title
{
    // First create the workout on Firebase
    self.currentWorkoutRef = [self.firebase childByAutoId];
    
    [[self.currentWorkoutRef childByAppendingPath:@"start_time"] setValue:[ELDateTimeUtil getCurrentTime]];
    
    [[self.currentWorkoutRef childByAppendingPath:@"title"] setValue:title];
    
    ELAddSetsViewController* addSetsViewController = [[ELAddSetsViewController alloc] initWithWorkoutRef:self.currentWorkoutRef];
    
    // Set up left Cancel button
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked)];
    addSetsViewController.navigationItem.leftBarButtonItem = cancelButton;
    
    // Set up right Close button
    UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)];
    addSetsViewController.navigationItem.rightBarButtonItem = closeButton;
    
    UINavigationController* addSetsNavController = [[UINavigationController alloc] initWithRootViewController:addSetsViewController];
    [self presentViewController:addSetsNavController animated:YES completion:nil];
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
        [self launchAddSetsViewControllerWithTitle:workoutTitle];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

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
    return 72;
}

@end
