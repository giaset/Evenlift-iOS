//
//  ELWorkoutsViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-23.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELWorkoutsViewController.h"

@interface ELWorkoutsViewController ()

@end

@implementation ELWorkoutsViewController

- (id)init
{
    self = [super initWithNibName:@"ELWorkoutsViewController" bundle:nil];
    if (self) {
        // Further initialization if needed
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem* addWorkoutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(launchAddWorkoutViewController)];
    self.navigationItem.rightBarButtonItem = addWorkoutButton;
}

- (IBAction)launchAddWorkoutViewController
{
    UIViewController* addWorkoutViewController = [[UIViewController alloc] init];
    addWorkoutViewController.view.backgroundColor = [UIColor redColor];
    addWorkoutViewController.title = @"Add Workout";
    
    // Set up close button
    UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissAddWorkoutViewController)];
    addWorkoutViewController.navigationItem.rightBarButtonItem = closeButton;
    
    UINavigationController* addWorkoutNavController = [[UINavigationController alloc] initWithRootViewController:addWorkoutViewController];
    [self presentViewController:addWorkoutNavController animated:YES completion:nil];
}

- (IBAction)dismissAddWorkoutViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
