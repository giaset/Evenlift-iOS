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
        
        ELExercise* exercise = [[ELExercise alloc] initWithName:set.exercise];
        [self.exercises addObject:exercise];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

@end
