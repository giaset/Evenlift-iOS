//
//  ELAddSetsViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-24.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELAddSetsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ELCountdownViewController.h"
#import "SVProgressHUD.h"
#import "ELExerciseAutocompleteTextField.h"
#import "ELSettingsUtil.h"

#define kEvenliftURL @"https://evenlift.firebaseio.com/"

@interface ELAddSetsViewController ()

@property (unsafe_unretained, nonatomic) ELExerciseAutocompleteTextField* exerciseField;
@property (nonatomic, retain) UITextField* repsField;
@property (nonatomic, retain) UITextField* weightField;
@property (nonatomic, retain) UITextField* restField;
@property (nonatomic, retain) UITextField* notesField;

@property (nonatomic, strong) Firebase* userExercisesRef;

@property (nonatomic, copy) NSString* workoutId;

@property UIButton* submitButton;

@property NSInteger lastSelectedTextField;

@end

@implementation ELAddSetsViewController

- (id)initWithWorkoutRef:(Firebase*)workoutRef
{
    self = [super init];
    if (self) {
        self.workoutRef = workoutRef;
        
        self.workoutId = workoutRef.name;
        
        // Set up user's Exercises Firebase
        self.userExercisesRef = [[[Firebase alloc] initWithUrl:kEvenliftURL] childByAppendingPath:[NSString stringWithFormat:@"users/%@/exercises", [ELSettingsUtil getUid]]];
        
        self.title = @"Current Workout";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    
    // Dismiss the keyboard when the user taps outside of a text field
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Refresh the weight in case the user has changed units
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont* gotham = [UIFont fontWithName:@"Gotham" size:16];
    UIFont* gothamLight = [UIFont fontWithName:@"Gotham-Light" size:16];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 320, 54)];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Exercise";
                self.exerciseField = [[ELExerciseAutocompleteTextField alloc] initWithFrame:CGRectMake(100, 0, 320, 54)];
                self.exerciseField.font = gothamLight;
                self.exerciseField.tag = 1;
                self.exerciseField.delegate = self;
                [cell.contentView addSubview:self.exerciseField];
                break;
            case 1:
                cell.textLabel.text = @"Reps";
                self.repsField = textField;
                self.repsField.keyboardType = UIKeyboardTypeNumberPad;
                break;
            case 2:
                cell.textLabel.text = @"Weight";
                if ([ELSettingsUtil getUnitType] == ELUnitTypePounds) {
                    textField.placeholder = @"In lbs. Leave blank for bw";
                } else if ([ELSettingsUtil getUnitType] == ELUnitTypeKilos) {
                    textField.placeholder = @"In kg. Leave blank for bw";
                }
                self.weightField = textField;
                self.weightField.keyboardType = UIKeyboardTypeNumberPad;
                break;
            case 3:
                cell.textLabel.text = @"Rest";
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
        
        if (indexPath.row != 0) {
            textField.font = gothamLight;
            textField.tag = indexPath.row+1;
            textField.delegate = self;
            [cell.contentView addSubview:textField];
        }
    }
    
    // Configure the cell...
    cell.textLabel.font  = gotham;
    
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
    return 54;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
    
    // Create the button
    UIButton* submitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
    [submitButton setTitle:@"Add Set" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitSet) forControlEvents:UIControlEventTouchUpInside];
    
    // Style the button
    submitButton.titleLabel.font = [UIFont fontWithName:@"Gotham" size:22.0];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setBackgroundColor:[UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1.0]]; // FLAT UI "ALIZARIN"
    [submitButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.753 green:0.224 blue:0.169 alpha:1.0]] forState:UIControlStateHighlighted]; // FLAT UI "POMEGRANATE"
    
    self.submitButton = submitButton;
    
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
    self.submitButton.enabled = NO;
    
    BOOL userSpecifiedRestTime = ![self.restField.text isEqualToString:@""];
    
    if (!userSpecifiedRestTime) {
        [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
        [SVProgressHUD show];
    }
    Firebase* setRef = [[self.workoutRef childByAppendingPath:@"sets"] childByAutoId];
    
    NSString* setID = setRef.name;
    
    // Add a reference to this set to the appropriate Exercise
    [[self.userExercisesRef childByAppendingPath:[NSString stringWithFormat:@"%@/sets/%@/%@", self.exerciseField.text, self.workoutId, setID]] setValue:@YES];
    
    // Actually log the set
    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber* reps = ([f numberFromString:self.repsField.text]) ? [f numberFromString:self.repsField.text] : [NSNumber numberWithInt:-1];
    
    NSNumber* weight = ([f numberFromString:self.weightField.text]) ? [f numberFromString:self.weightField.text] : [NSNumber numberWithInt:-1];
    NSString* unitString = [ELSettingsUtil stringFromUnitType:[ELSettingsUtil getUnitType]];
    if ([weight intValue] == -1) {
        unitString = [ELSettingsUtil stringFromUnitType:ELUnitTypeBodyWeight];
    }
    NSDictionary* weightDict = [[NSDictionary alloc] initWithObjectsAndKeys:weight, @"value", unitString, @"unit", nil];
    
    NSNumber* rest = ([f numberFromString:self.restField.text]) ? [f numberFromString:self.restField.text] : [NSNumber numberWithInt:-1];
    
    [setRef setValue:@{@"exercise": self.exerciseField.text, @"reps": reps, @"weight": weightDict, @"rest": rest, @"notes": self.notesField.text, @"time": [ELDateTimeUtil getCurrentTime]} withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (!userSpecifiedRestTime) {
            [SVProgressHUD showSuccessWithStatus:@"Set added succesfully!"];
        }
        [self clearAllTextFields];
        [self.view endEditing:YES];
        self.submitButton.enabled = YES;
    }];
    
    // If user specified a rest time, show countdown
    if (userSpecifiedRestTime) {
        ELCountdownViewController* countdownViewController = [[ELCountdownViewController alloc] initWithDurationInSeconds:[self.restField.text intValue]];
        countdownViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:countdownViewController animated:YES completion:nil];
    }
}

- (void)clearAllTextFields
{
    self.exerciseField.text = @"";
    self.repsField.text = @"";
    self.weightField.text = @"";
    self.restField.text = @"";
    self.notesField.text = @"";
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.lastSelectedTextField = textField.tag;
    [self setCustomToolBarForTextField:textField];
}

- (void)setCustomToolBarForTextField:(UITextField*)textField
{
    UIToolbar* toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0,0,320,44)];
    
    UIBarButtonItem* previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonClicked:)];
    previousButton.enabled = (textField.tag != 1);
    
    UIBarButtonItem* nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];
    nextButton.enabled = (textField.tag != 5);
    
    UIBarButtonItem* flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)];
    
    NSArray* itemsArray = [NSArray arrayWithObjects:previousButton, nextButton, flexButton, doneButton, nil];
    
    [toolbar setItems:itemsArray];
    
    // Style the toolbar
    toolbar.barTintColor = [UIColor blackColor];
    previousButton.tintColor = [UIColor whiteColor];
    nextButton.tintColor = [UIColor whiteColor];
    doneButton.tintColor = [UIColor whiteColor];
    
    NSDictionary* gotham = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Gotham" size:14], NSFontAttributeName, nil];
    NSDictionary* gothamLight = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Gotham-Light" size:14], NSFontAttributeName, nil];
    
    [previousButton setTitleTextAttributes:gothamLight forState:UIControlStateNormal];
    [nextButton setTitleTextAttributes:gothamLight forState:UIControlStateNormal];
    [doneButton setTitleTextAttributes:gotham forState:UIControlStateNormal];
    
    textField.inputAccessoryView = toolbar;
}

- (IBAction)previousButtonClicked:(id)sender
{
    [[self.view viewWithTag:self.lastSelectedTextField-1] becomeFirstResponder];
}

- (IBAction)nextButtonClicked:(id)sender
{
    [[self.view viewWithTag:self.lastSelectedTextField+1] becomeFirstResponder];
}

- (IBAction)doneButtonClicked:(id)sender
{
    [self.view endEditing:YES];
}

@end
