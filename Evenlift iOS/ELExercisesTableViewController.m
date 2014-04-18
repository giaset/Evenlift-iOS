//
//  ELExercisesTableViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-02.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELExercisesTableViewController.h"
#import <Firebase/Firebase.h>

@interface ELExercisesTableViewController ()

@property (nonatomic, strong) Firebase* exercisesRef;

@property (nonatomic, strong) NSMutableArray* exercises;

@end

@implementation ELExercisesTableViewController

- (id) init
{
    self = [super initWithNibName:@"ELExercisesTableViewController" bundle:nil];
    if (self) {
        // Set up the Firebase for this user's exercises
        NSString* uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
        self.exercisesRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://evenlift.firebaseio.com/users/%@/exercises", uid]];
        
        // Init the empty Exercises array
        self.exercises = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    
    // Download exercises (added/removed/changed)
    [self.exercisesRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSString* exercise = snapshot.name;
        [self.exercises addObject:exercise];
        // Keep array sorted alphabetically
        [self.exercises sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.font = [UIFont fontWithName:@"Gotham" size:16];
    cell.textLabel.text = [self.exercises objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
