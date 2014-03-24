//
//  ELWorkoutsViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-23.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELWorkoutsViewController.h"
#import <Firebase/Firebase.h>

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
        NSLog(@"%@", userWorkoutsUrl);
        self.firebase = [[Firebase alloc] initWithUrl:userWorkoutsUrl];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* addWorkoutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(launchAddWorkoutViewController)];
    self.navigationItem.rightBarButtonItem = addWorkoutButton;
}

- (IBAction)launchAddWorkoutViewController
{
    // First create the workout on Firebase
    self.currentWorkoutRef = [self.firebase childByAutoId];
    
    [[self.currentWorkoutRef childByAppendingPath:@"start_time"] setValue:[self getCurrentTime]];
    
    //- (id)initWithWorkoutRef:(Firebase*)workoutRef;
    
    UIViewController* addWorkoutViewController = [[UIViewController alloc] init];
    addWorkoutViewController.view.backgroundColor = [UIColor redColor];
    addWorkoutViewController.title = @"Add Workout";
    
    // Set up left Cancel button
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked)];
    addWorkoutViewController.navigationItem.leftBarButtonItem = cancelButton;
    
    // Set up right Close button
    UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)];
    addWorkoutViewController.navigationItem.rightBarButtonItem = closeButton;
    
    UINavigationController* addWorkoutNavController = [[UINavigationController alloc] initWithRootViewController:addWorkoutViewController];
    [self presentViewController:addWorkoutNavController animated:YES completion:nil];
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
    }
}

- (void)cancelWorkout
{
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
