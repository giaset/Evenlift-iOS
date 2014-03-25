//
//  ELAddSetsViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-24.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELAddSetsViewController.h"

@interface ELAddSetsViewController ()

@property (nonatomic, retain) UITextField* exerciseField;
@property (nonatomic, retain) UITextField* repsField;
@property (nonatomic, retain) UITextField* weightField;
@property (nonatomic, retain) UITextField* restField;
@property (nonatomic, retain) UITextField* notesField;

@end

@implementation ELAddSetsViewController

- (id)initWithWorkoutRef:(Firebase*)workoutRef
{
    self = [super init];
    if (self) {
        self.workoutRef = workoutRef;
        self.title = @"Add Set";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 320, 44)];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Exercise";
                self.exerciseField = textField;
                break;
            case 1:
                cell.textLabel.text = @"Reps";
                self.repsField = textField;
                break;
            case 2:
                cell.textLabel.text = @"Weight";
                textField.placeholder = @"In kilos. Leave blank for bw";
                self.weightField = textField;
                break;
            case 3:
                cell.textLabel.text = @"Rest after";
                textField.placeholder = @"In seconds. Optional";
                self.restField = textField;
                break;
            case 4:
                cell.textLabel.text = @"Notes";
                textField.placeholder = @"Optional";
                self.notesField = textField;
                break;
        }
        
        textField.tag = indexPath.row;
        [cell.contentView addSubview:textField];
    }
    
    // Configure the cell...
    
    return cell;
}

// Footer view
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIButton* submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    submitButton.tintColor = [UIColor redColor];
    [submitButton addTarget:self action:@selector(submitSet) forControlEvents:UIControlEventTouchUpInside];
    
    return submitButton;
}

- (IBAction)submitSet
{
    Firebase* setRef = [[self.workoutRef childByAppendingPath:@"sets"] childByAutoId];
    
    [setRef setValue:@{@"exercise": self.exerciseField.text, @"reps": self.repsField.text, @"weight": self.weightField.text, @"rest": self.restField.text, @"notes": self.notesField.text, @"time": [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] stringValue]} withCompletionBlock:^(NSError *error, Firebase *ref) {
        //
    }];
}

@end
