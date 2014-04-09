//
//  ELAddSetsViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-24.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELAddSetsViewController.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "ELCountdownViewController.h"

#define kEvenliftURL @"https://evenlift.firebaseio.com/"

@interface ELAddSetsViewController ()

@property (nonatomic, retain) UITextField* exerciseField;
@property (nonatomic, retain) UITextField* repsField;
@property (nonatomic, retain) UITextField* weightField;
@property (nonatomic, retain) UITextField* restField;
@property (nonatomic, retain) UITextField* notesField;

@property (nonatomic, strong) Firebase* userExercisesRef;

@property (nonatomic, copy) NSString* workoutId;

@end

@implementation ELAddSetsViewController

- (id)initWithWorkoutRef:(Firebase*)workoutRef
{
    self = [super init];
    if (self) {
        self.workoutRef = workoutRef;
        
        self.workoutId = workoutRef.name;
        
        // Set up user's Exercises Firebase
        NSString* uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
        self.userExercisesRef = [[[Firebase alloc] initWithUrl:kEvenliftURL] childByAppendingPath:[NSString stringWithFormat:@"users/%@/exercises", uid]];
        
        self.title = @"Current Workout";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont* futura = [UIFont fontWithName:@"Futura" size:16];
    
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
                self.repsField.keyboardType = UIKeyboardTypeNumberPad;
                break;
            case 2:
                cell.textLabel.text = @"Weight";
                textField.placeholder = @"In kilos. Leave blank for bw";
                self.weightField = textField;
                self.weightField.keyboardType = UIKeyboardTypeNumberPad;
                break;
            case 3:
                cell.textLabel.text = @"Rest after";
                textField.placeholder = @"In seconds. Optional";
                self.restField = textField;
                self.restField.keyboardType = UIKeyboardTypeNumberPad;
                break;
            case 4:
                cell.textLabel.text = @"Notes";
                textField.placeholder = @"Optional";
                self.notesField = textField;
                break;
        }
        
        textField.font = futura;
        textField.tag = indexPath.row;
        [cell.contentView addSubview:textField];
    }
    
    // Configure the cell...
    cell.textLabel.font  = futura;
    
    return cell;
}

// Header view
/*- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Create header view
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 320, 60)];
    headerLabel.numberOfLines = 0;
    
    [headerView addSubview:headerLabel];
    
    // Bind its text to the previous set
    Firebase* setsRef = [self.workoutRef childByAppendingPath:@"sets"];
    FQuery* setsQuery = [setsRef queryLimitedToNumberOfChildren:1];
    
    [setsQuery observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSDictionary* setInfo = snapshot.value;
        NSString* headerString = [NSString stringWithFormat:@"Previous set:\n%@, %@ x %@ (%@ sec rest)", setInfo[@"exercise"], setInfo[@"reps"], setInfo[@"weight"], setInfo[@"rest"]];
        headerLabel.text = headerString;
    }];
    
    return headerView;
}*/

// Footer view
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 64;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    
    // Create the button
    UIButton* submitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    [submitButton setTitle:@"Add Set" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitSet) forControlEvents:UIControlEventTouchUpInside];
    
    // Style the button
    submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setBackgroundColor:[UIColor redColor]];
    [submitButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.792 green:0.024 blue:0.024 alpha:1.0]] forState:UIControlStateHighlighted];
    
    [footerView addSubview:submitButton];
    
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

- (IBAction)submitSet
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    Firebase* setRef = [[self.workoutRef childByAppendingPath:@"sets"] childByAutoId];
    
    NSString* setID = setRef.name;
    
    // Add a reference to this set to the appropriate Exercise
    [[self.userExercisesRef childByAppendingPath:[NSString stringWithFormat:@"%@/sets/%@/%@", self.exerciseField.text, self.workoutId, setID]] setValue:@YES];
    
    // Actually log the set
    [setRef setValue:@{@"exercise": self.exerciseField.text, @"reps": self.repsField.text, @"weight": self.weightField.text, @"rest": self.restField.text, @"notes": self.notesField.text, @"time": [ELDateTimeUtil getCurrentTime]} withCompletionBlock:^(NSError *error, Firebase *ref) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.weightField.text = @"";
        self.notesField.text = @"";
    }];
    
    // If user specified a rest time, show countdown
    if (![self.restField.text isEqualToString:@""]) {
        ELCountdownViewController* countdownViewController = [[ELCountdownViewController alloc] initWithDurationInSeconds:[self.restField.text intValue]];
        [self presentViewController:countdownViewController animated:NO completion:nil];
    }
}

@end
