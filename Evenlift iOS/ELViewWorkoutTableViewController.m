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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.exercises.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    ELExercise* exercise = (ELExercise*)[self.exercises objectAtIndex:section];
    return exercise.sets.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ELExercise* exercise = (ELExercise*)[self.exercises objectAtIndex:section];
    return exercise.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = @"CACA";
    
    return cell;
}

@end
