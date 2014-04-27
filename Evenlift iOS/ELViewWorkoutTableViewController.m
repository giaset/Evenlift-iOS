//
//  ELViewWorkoutTableViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-11.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELViewWorkoutTableViewController.h"
#import <Firebase/Firebase.h>
#import "ELSet.h"
#import "ELExercise.h"
#import "ELColorUtil.h"
#import <Firebase/Firebase.h>
#import "ELAddSetsViewController.h"

@interface ELViewWorkoutTableViewController ()

@property (nonatomic) NSString* workoutId;
@property (nonatomic, strong) NSMutableArray* exercises;

@property (nonatomic, strong) Firebase* workoutRef;

@property BOOL workoutIsFinished;

@end

@implementation ELViewWorkoutTableViewController

- (id)initWithWorkout:(ELWorkout *)workout
{
    return [self initWithWorkoutId:workout.workoutId andTitle:workout.title];
}

- (id)initWithWorkoutId:(NSString *)workoutId andTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.workoutId = workoutId;
        self.exercises = [[NSMutableArray alloc] init];
        self.title = title;
        self.workoutRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://evenlift.firebaseio.com/workouts/%@", workoutId]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    
    // Set up right Finish button
    UIBarButtonItem* finishButton = [[UIBarButtonItem alloc] initWithTitle:@"Finish" style:UIBarButtonItemStyleBordered target:self action:@selector(finishButtonClicked)];
    self.navigationItem.rightBarButtonItem = finishButton;
    
    // Bind on the workout being finished or not
    Firebase* endTimeRef = [self.workoutRef childByAppendingPath:@"end_time"];
    [endTimeRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value != [NSNull null]) {
            self.workoutIsFinished = YES;
            self.navigationItem.rightBarButtonItem = nil;
            [self.tableView reloadData];
        } else {
            self.workoutIsFinished = NO;
        }
    }];
    
    // Bind on this workout's sets
    Firebase* setsRef = [self.workoutRef childByAppendingPath:@"sets"];
    
    [setsRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSString* setId = snapshot.name;
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary:snapshot.value];
        [dict setObject:setId forKey:@"set_id"];
        ELSet* set = [[ELSet alloc] initWithDictionary:dict];
        
        NSMutableArray* sets = [[NSMutableArray alloc] initWithObjects:set, nil];
        
        ELExercise* exercise = [[ELExercise alloc] initWithName:set.exercise andSets:sets];
        
        // Check if exercise exists in our array
        BOOL exists = NO;
        
        for (ELExercise* exerciseInArray in self.exercises) {
            if ([exerciseInArray.name isEqualToString:exercise.name]) {
                exists = YES;
                // Add this set to the already existing exercise
                [exerciseInArray.sets addObject:set];
                break;
            }
        }
        
        // If it doesn't, add it
        if (!exists) {
            [self.exercises addObject:exercise];
        }
        
        [self.tableView reloadData];
    }];
    
    // Customize the back button title for the next viewController on the stack...
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
}

- (IBAction)finishButtonClicked{
    UIAlertView* finishAlert = [[UIAlertView alloc]
                              initWithTitle:@"Finish Workout?"
                              message:@"Finishing this workout will cause all entered data to be saved forever, without possibility for later modification. Are you sure?"
                              delegate:self
                              cancelButtonTitle:@"No"
                              otherButtonTitles:@"Yes", nil];
    [finishAlert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[self.workoutRef childByAppendingPath:@"end_time"] setValue:[ELDateTimeUtil getCurrentTime]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.exercises.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    ELExercise* exercise = (ELExercise*)[self.exercises objectAtIndex:indexPath.row];
    cell.textLabel.text = exercise.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu sets", (unsigned long)exercise.sets.count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELExercise* exercise = (ELExercise*)[self.exercises objectAtIndex:indexPath.row];
    
    if (!self.workoutIsFinished) {
        ELAddSetsViewController* addSetsViewController = [[ELAddSetsViewController alloc] initWithWorkoutRef:self.workoutRef andExerciseName:exercise.name];
        [self.navigationController pushViewController:addSetsViewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Footer view
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.workoutIsFinished) {
        return 0;
    } else {
        return 54;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.workoutIsFinished) {
        return nil;
    } else {
        UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        
        // Create the button
        UIButton* addExerciseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        [addExerciseButton setTitle:@"+ Add Exercise" forState:UIControlStateNormal];
        [addExerciseButton addTarget:self action:@selector(addExerciseButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        // Style the button
        addExerciseButton.titleLabel.font = [UIFont fontWithName:@"Gotham" size:22.0];
        [addExerciseButton setTitleColor:[ELColorUtil evenLiftWhite] forState:UIControlStateNormal];
        [addExerciseButton setBackgroundColor:[ELColorUtil evenLiftRed]];
        [addExerciseButton setBackgroundImage:[ELColorUtil imageWithColor:[ELColorUtil evenLiftRedHighlighted]] forState:UIControlStateHighlighted];
        
        [footerView addSubview:addExerciseButton];
        
        return footerView;
    }
}

- (IBAction)addExerciseButtonClicked
{
    ELAddSetsViewController* addSetsViewController = [[ELAddSetsViewController alloc] initWithWorkoutRef:self.workoutRef andExerciseName:nil];
    
    [self.navigationController pushViewController:addSetsViewController animated:YES];
}

@end
