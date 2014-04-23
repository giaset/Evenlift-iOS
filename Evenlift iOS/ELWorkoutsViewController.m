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
#import "ELSettingsUtil.h"
#import "SVProgressHUD.h"
#import "ELColorUtil.h"
#import "ELSettingsTableViewController.h"

@interface ELWorkoutsViewController ()

@property (nonatomic, strong) Firebase* allWorkoutsRef;
@property (nonatomic, strong) Firebase* userWorkoutsRef;
@property (nonatomic, strong) Firebase* currentWorkoutRef;

@property (nonatomic, strong) NSMutableArray* workouts;

@property (nonatomic) BOOL initialLoadingComplete;

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
        self.userId = [ELSettingsUtil getUid];
        NSString* userWorkoutsUrl = [NSString stringWithFormat:@"https://evenlift.firebaseio.com/users/%@/workouts/", self.userId];
        self.userWorkoutsRef = [[Firebase alloc] initWithUrl:userWorkoutsUrl];
        
        // Set up our local array that is the data source to our table view
        self.workouts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (IBAction)showSettingsViewController
{
    ELSettingsTableViewController* settingsViewController = [[ELSettingsTableViewController alloc] init];
    settingsViewController.authClient = self.authClient;
    
    UINavigationController* settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsNavController.navigationBar.translucent = NO;
    
    [self presentViewController:settingsNavController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"My Workouts";
    
    // Set up rightBarButton to launch Settings viewController
    UIButton* settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(0, 0, 26, 26);
    [settingsButton setImage:[UIImage imageNamed:@"gear"] forState:UIControlStateNormal];
    settingsButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [settingsButton addTarget:self action:@selector(showSettingsViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* settingsButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.rightBarButtonItem = settingsButtonItem;
    
    // Register ELWorkoutTableViewCell nib for this tableView
    [self.tableView registerNib:[UINib nibWithNibName:@"ELWorkoutTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"WorkoutCell"];
    
    // Since VALUE type events fire after all other events, this is a good
    // place to detect if our initial loading is complete
    self.initialLoadingComplete = NO;
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD showWithStatus:@"Loading your workouts..."];
    [self.userWorkoutsRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (!self.initialLoadingComplete) {
            self.initialLoadingComplete = YES;
            [self.tableView reloadData];
            
            // Dismiss SVProgressHUD after a delay to allow for reloading of tableView
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [SVProgressHUD dismiss];
            });
        }
    }];
    
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
            
            // We do this to prevent cells from appearing one at a time during initial load
            if (self.initialLoadingComplete) {
                [self.tableView reloadData];
            }
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
                             initWithTitle:@"Start New Workout"
                             message:@"Please enter an optional title for this workout.\n(ex: Max-Effort Upper Body)"
                             delegate:self
                             cancelButtonTitle:@"Cancel"
                             otherButtonTitles:@"Ok", nil];
    addAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    addAlert.tag = 3;
    [addAlert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
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
    
    // Finally, launch the viewWorkout viewController for the appropriate workout
    ELViewWorkoutTableViewController* viewWorkout = [[ELViewWorkoutTableViewController alloc] initWithWorkoutId:workoutId andTitle:title];
    [self.navigationController pushViewController:viewWorkout animated:YES];
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1) {
        // Clicked YES on "Cancel" Alert View
        [self cancelWorkout];
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
    
    ELViewWorkoutTableViewController* viewWorkout = [[ELViewWorkoutTableViewController alloc] initWithWorkout:workout];
    [self.navigationController pushViewController:viewWorkout animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Header view
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
    
    // Create the button
    UIButton* startNewWorkoutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
    [startNewWorkoutButton setTitle:@"+ Start New Workout" forState:UIControlStateNormal];
    [startNewWorkoutButton addTarget:self action:@selector(popAddAlert) forControlEvents:UIControlEventTouchUpInside];
    
    // Style the button
    startNewWorkoutButton.titleLabel.font = [UIFont fontWithName:@"Gotham" size:22.0];
    [startNewWorkoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startNewWorkoutButton setBackgroundColor:[ELColorUtil evenLiftRed]];
    [startNewWorkoutButton setBackgroundImage:[ELColorUtil imageWithColor:[ELColorUtil evenLiftRedHighlighted]] forState:UIControlStateHighlighted];
    
    [headerView addSubview:startNewWorkoutButton];
    
    return headerView;
}


@end
