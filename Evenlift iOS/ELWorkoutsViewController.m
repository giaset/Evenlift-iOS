//
//  ELWorkoutsViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-23.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELWorkoutsViewController.h"
#import <Firebase/Firebase.h>
#import "ELWorkout.h"
#import "ELWorkoutTableViewCell.h"
#import "ELViewWorkoutTableViewController.h"
#import "ELSettingsUtil.h"
#import "SVProgressHUD.h"
#import "ELColorUtil.h"
#import "ELSettingsTableViewController.h"
#import "ELMonth.h"

@interface ELWorkoutsViewController ()

@property (nonatomic, strong) Firebase* allWorkoutsRef;
@property (nonatomic, strong) Firebase* userWorkoutsRef;
@property (nonatomic, strong) Firebase* currentWorkoutRef;

@property (nonatomic, strong) NSMutableArray* months;

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
        self.months = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"My Workouts";
    
    self.tableView.backgroundColor = [ELColorUtil evenLiftBlack];
    
    // Set up rightBarButton to launch Settings viewController
    UIBarButtonItem* addWorkoutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(popAddAlert)];
    self.navigationItem.rightBarButtonItem = addWorkoutButton;
    
    // Register ELWorkoutTableViewCell nib for this tableView
    [self.tableView registerNib:[UINib nibWithNibName:@"ELWorkoutTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"WorkoutCell"];
    
    // Since VALUE type events fire after all other events, this is a good
    // place to detect if our initial loading is complete
    self.initialLoadingComplete = NO;
    [SVProgressHUD setBackgroundColor:[ELColorUtil evenLiftWhite]];
    [SVProgressHUD setForegroundColor:[ELColorUtil evenLiftBlack]];
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
            // If the workout was deleted, delete it from our array
            if(snapshot.value == [NSNull null]) {
                NSMutableArray* toDelete = [NSMutableArray array];
                ELMonth* whichMonth = nil;
                for (ELMonth* month in self.months) {
                    for (ELWorkout* workout in month.workouts) {
                        if (workout.workoutId == workoutId) {
                            whichMonth = month;
                            [toDelete addObject:workout];
                            break;
                        }
                    }
                }
                if (whichMonth != nil) {
                    [whichMonth.workouts removeObjectsInArray:toDelete];
                }
            } else {
                // If not, check if it exists in our array
                BOOL exists = NO;
                
                for (ELMonth* month in self.months) {
                    for (ELWorkout* workout in month.workouts) {
                        if (workout.workoutId == workoutId) {
                            // If it does, update it
                            exists = YES;
                            [workout updateWithDictionary:snapshot.value];
                            break;
                        }
                    }
                }
                
                // If it doesn't, create it
                if (!exists) {
                    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary:snapshot.value];
                    [dict setObject:workoutId forKey:@"workout_id"];
                    ELWorkout* workout = [[ELWorkout alloc] initWithDictionary:dict];
                    
                    // Figure out which month this workout is in
                    NSDate* workoutDate = [workout workoutDate];
                    
                    BOOL monthExists = NO;
                    
                    for (ELMonth* month in self.months) {
                        if ([month containsDate:workoutDate]) {
                            monthExists = YES;
                            [month.workouts addObject:workout];
                            break;
                        }
                    }
                    
                    if (!monthExists) {
                        ELMonth* newMonth = [[ELMonth alloc] initWithDate:workoutDate];
                        [newMonth.workouts addObject:workout];
                        [self.months addObject:newMonth];
                    }
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Clicked OK on "Add" Alert View
        NSString* workoutTitle = [alertView textFieldAtIndex:0].text;
        [self createWorkoutWithTitle:workoutTitle];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.months.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ELMonth* month = [self.months objectAtIndex:(self.months.count - 1 - section)];
    
    return month.workouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WorkoutCell";
    ELWorkoutTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [ELColorUtil evenLiftBlack];
    
    // Configure the cell...
    ELMonth* month = [self.months objectAtIndex:(self.months.count - 1 - indexPath.section)];
    ELWorkout* workout = [month.workouts objectAtIndex:(month.workouts.count - 1 - indexPath.row)];
    [cell configureForWorkout:workout];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ELMonth* month = [self.months objectAtIndex:(self.months.count - 1 - section)];
    return [month description];
    
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView* tableViewHeaderFooterView = (UITableViewHeaderFooterView*)view;
        tableViewHeaderFooterView.textLabel.text = [tableViewHeaderFooterView.textLabel.text capitalizedString];
        tableViewHeaderFooterView.textLabel.textColor = [ELColorUtil evenLiftRed];
        tableViewHeaderFooterView.textLabel.font = [UIFont fontWithName:@"Gotham" size:14];
    }
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
        ELMonth* month = [self.months objectAtIndex:(self.months.count - 1 - indexPath.section)];
        ELWorkout* workout = [month.workouts objectAtIndex:(month.workouts.count - 1 - indexPath.row)];
        
        // Delete workout object
        [[self.allWorkoutsRef childByAppendingPath:workout.workoutId] removeValue];
        
        // Delete reference to workout in user's workouts
        [[self.userWorkoutsRef childByAppendingPath:workout.workoutId] removeValue];
    }
}

// Cell selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the Workout we clicked on
    ELMonth* month = [self.months objectAtIndex:(self.months.count - 1 - indexPath.section)];
    ELWorkout* workout = [month.workouts objectAtIndex:(month.workouts.count - 1 - indexPath.row)];
    
    ELViewWorkoutTableViewController* viewWorkout = [[ELViewWorkoutTableViewController alloc] initWithWorkout:workout];
    [self.navigationController pushViewController:viewWorkout animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
