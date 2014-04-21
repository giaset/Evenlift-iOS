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

@interface ELViewWorkoutTableViewController ()

@property (nonatomic, strong) ELWorkout* workout;
@property (nonatomic, strong) NSMutableArray* exercises;

@end

@implementation ELViewWorkoutTableViewController

- (id)initWithWorkout:(ELWorkout *)workout
{
    self = [super init];
    if (self) {
        self.workout = workout;
        self.exercises = [[NSMutableArray alloc] init];
        self.title = workout.title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    
    Firebase* setsRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://evenlift.firebaseio.com/workouts/%@/sets", self.workout.workoutId]];
    
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
    }
    
    // Configure the cell...
    ELExercise* exercise = (ELExercise*)[self.exercises objectAtIndex:indexPath.row];
    cell.textLabel.text = exercise.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu sets", (unsigned long)exercise.sets.count];
    
    return cell;
}

// Footer view
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 54;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
    
    // Create the button
    UIButton* addExerciseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
    [addExerciseButton setTitle:@"+ Add Exercise" forState:UIControlStateNormal];
    [addExerciseButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    
    // Style the button
    addExerciseButton.titleLabel.font = [UIFont fontWithName:@"Gotham" size:22.0];
    [addExerciseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addExerciseButton setBackgroundColor:[UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1.0]]; // FLAT UI "ALIZARIN"
    [addExerciseButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.753 green:0.224 blue:0.169 alpha:1.0]] forState:UIControlStateHighlighted]; // FLAT UI "POMEGRANATE"
    
    [footerView addSubview:addExerciseButton];
    
    return footerView;
}

- (UIImage*)imageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
