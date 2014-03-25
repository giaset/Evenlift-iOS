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

@interface ELWorkoutsViewController ()

@property (nonatomic, strong) Firebase* firebase;
@property (nonatomic, strong) Firebase* currentWorkoutRef;

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* addWorkoutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(popAddAlert)];
    self.navigationItem.rightBarButtonItem = addWorkoutButton;
}

- (IBAction)popAddAlert
{
    UIAlertView* addAlert = [[UIAlertView alloc]
                             initWithTitle:@"Create Workout"
                             message:@"Please enter a title for this workout. (ex: Max-Effort Upper Body)"
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
    
    [[self.currentWorkoutRef childByAppendingPath:@"start_time"] setValue:[self getCurrentTime]];
    
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
    [[self.currentWorkoutRef childByAppendingPath:@"end_time"] setValue:[self getCurrentTime]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)getCurrentTime
{
    return [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] stringValue];
}

@end
