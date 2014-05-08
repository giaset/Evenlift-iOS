//
//  ELAddAndViewSetsViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-24.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELAddAndViewSetsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ELCountdownViewController.h"
#import "SVProgressHUD.h"
#import "ELExerciseAutocompleteTextField.h"
#import "ELSettingsUtil.h"
#import "ELColorUtil.h"
#import "ELSettingsTableViewController.h"
#import "ELSet.h"

#define kEvenliftURL @"https://evenlift.firebaseio.com/"

@interface ELAddAndViewSetsViewController ()

@property (nonatomic, strong) NSMutableArray* completedSets;

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

@implementation ELAddAndViewSetsViewController

- (id)initWithWorkoutRef:(Firebase*)workoutRef andExerciseName:(NSString *)exerciseName
{
    self = [super init];
    if (self) {
        self.workoutRef = workoutRef;
        
        self.workoutId = workoutRef.name;
        
        self.completedSets = [[NSMutableArray alloc] init];
        
        // Set up user's Exercises Firebase
        self.userExercisesRef = [[[Firebase alloc] initWithUrl:kEvenliftURL] childByAppendingPath:[NSString stringWithFormat:@"users/%@/exercises", [ELSettingsUtil getUid]]];
        
        // Set up UITextField for exerciseName
        self.exerciseField = [[ELExerciseAutocompleteTextField alloc] initWithFrame:CGRectMake(0, 0, 200, 22)];
        self.exerciseField.text = exerciseName;
        
        // If no exerciseName provided, put this UITextField in navigationBar's titleView
        if (exerciseName == nil) {
            self.exerciseField.font = [UIFont fontWithName:@"Gotham" size:18];
            self.exerciseField.textColor = [ELColorUtil evenLiftWhite];
            
            self.exerciseField.attributedPlaceholder = [self coloredPlaceholderForString:@"Exercise Name"];
            
            self.exerciseField.tag = 99;
            self.exerciseField.delegate = self;
            
            self.exerciseField.returnKeyType = UIReturnKeyDone;
            self.exerciseField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            
            self.navigationItem.titleView = self.exerciseField;
        } else {
            self.title = exerciseName;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    
    self.tableView.backgroundColor = [ELColorUtil evenLiftBlack];
    
    // Set up rightBarButton to launch Settings viewController
    UIButton* settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(0, 0, 26, 26);
    [settingsButton setImage:[UIImage imageNamed:@"gear"] forState:UIControlStateNormal];
    settingsButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [settingsButton addTarget:self action:@selector(showSettingsViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* settingsButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.rightBarButtonItem = settingsButtonItem;
    
    if ([self.exerciseField.text isEqualToString:@""]) {
        // If exerciseField is blank, add a black overlay to view until user enters an exercise name. Also disable settings button
        UIView* blackOverlay = [[UIView alloc] initWithFrame:self.view.frame];
        blackOverlay.backgroundColor = [ELColorUtil evenLiftBlack];
        blackOverlay.alpha = 0.95;
        blackOverlay.layer.zPosition = 99; // need this so we're on top of footerView
        blackOverlay.tag = 1000;
        [self.view addSubview:blackOverlay];
        
        [self.exerciseField becomeFirstResponder];
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        // If this is an existing exercise, bind to its sets for this workout
        [self bindToSetsOfThisExerciseForThisWorkout];
    }
    
    // Dismiss the keyboard when the user taps outside of a text field
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Refresh the weight in case the user has changed units
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)bindToSetsOfThisExerciseForThisWorkout
{
    Firebase* thisExerciseThisWorkoutRef = [self.userExercisesRef childByAppendingPath:[NSString stringWithFormat:@"%@/sets/%@", self.exerciseField.text, self.workoutId]];
    
    [thisExerciseThisWorkoutRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot* snapshot) {
        NSString* setId = snapshot.name;
        // Bind to each individual set
        Firebase* thisSetRef = [[self.workoutRef childByAppendingPath:@"sets"] childByAppendingPath:setId];
        [thisSetRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary:snapshot.value];
            [dict setObject:setId forKey:@"set_id"];
            ELSet* thisSet = [[ELSet alloc] initWithDictionary:dict];
            [self.completedSets addObject:thisSet];
            [self sortCompletedSetsArray];
            
            [self.tableView reloadData];
        }];
    }];
}

- (void)sortCompletedSetsArray
{
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    NSArray* sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [self.completedSets sortUsingDescriptors:sortDescriptors];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

- (IBAction)showSettingsViewController
{
    ELSettingsTableViewController* settingsViewController = [[ELSettingsTableViewController alloc] init];
    settingsViewController.authClient = nil;
    
    UINavigationController* settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsNavController.navigationBar.translucent = NO;
    
    [self presentViewController:settingsNavController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
            break;
            
        case 1:
            return self.completedSets.count;
            break;
            
        default:
            return 0;
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont* gotham = [UIFont fontWithName:@"Gotham" size:16];
    UIFont* gothamLight = [UIFont fontWithName:@"Gotham-Light" size:16];
    
    BOOL needsTextField = (indexPath.section == 0);
    
    NSString* CellIdentifier = (needsTextField) ? @"CellWithEditText" : @"NormalCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.backgroundColor = [ELColorUtil evenLiftBlack];
        cell.textLabel.font = gotham;
        cell.textLabel.textColor = [ELColorUtil evenLiftWhite];
        
        if (needsTextField) {
            UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 320, 54)];
            textField.font = gothamLight;
            textField.textColor = [ELColorUtil evenLiftWhite];
            textField.delegate = self;
            [cell.contentView addSubview:textField];
        }
    }
    
    // Configure the cell...
    if (needsTextField) {
        // Retrieve the textField already in the cell
        for (UIView* v in [cell.contentView subviews]) {
            if ([v isKindOfClass:[UITextField class]]) {
                UITextField* textField = (UITextField*) v;
                textField.tag = indexPath.row+1;
                
                // Customize the cell and textField
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.text = @"Reps";
                        textField.keyboardType = UIKeyboardTypeNumberPad;
                        textField.attributedPlaceholder = [self coloredPlaceholderForString:@"Required"];
                        self.repsField = textField;
                        break;
                    case 1:
                        cell.textLabel.text = @"Weight";
                        textField.keyboardType = UIKeyboardTypeNumberPad;
                        if ([ELSettingsUtil getUnitType] == ELUnitTypePounds) {
                            textField.attributedPlaceholder = [self coloredPlaceholderForString:@"In lbs. Leave blank for bw"];
                        } else if ([ELSettingsUtil getUnitType] == ELUnitTypeKilos) {
                            textField.attributedPlaceholder = [self coloredPlaceholderForString:@"In kg. Leave blank for bw"];
                        }
                        self.weightField = textField;
                        break;
                    case 2:
                        cell.textLabel.text = @"Rest";
                        textField.keyboardType = UIKeyboardTypeNumberPad;
                        textField.attributedPlaceholder = [self coloredPlaceholderForString:@"In seconds. Optional"];
                        self.restField = textField;
                        break;
                    case 3:
                        cell.textLabel.text = @"Notes";
                        textField.attributedPlaceholder = [self coloredPlaceholderForString:@"Optional"];
                        self.notesField = textField;
                        break;
                }
            }
        }
    } else {
        ELSet* set = [self.completedSets objectAtIndex:indexPath.row];
        cell.textLabel.text = [set description];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Completed Sets";
    } else {
        return nil;
    }
}

// Footer view
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 54;
    } else {
        return 0;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        
        // Create the button
        UIButton* submitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        [submitButton setTitle:@"+ Add Set" forState:UIControlStateNormal];
        [submitButton addTarget:self action:@selector(submitSet) forControlEvents:UIControlEventTouchUpInside];
        
        // Style the button
        submitButton.titleLabel.font = [UIFont fontWithName:@"Gotham" size:22.0];
        [submitButton setTitleColor:[ELColorUtil evenLiftWhite] forState:UIControlStateNormal];
        [submitButton setBackgroundColor:[ELColorUtil evenLiftRed]];
        [submitButton setBackgroundImage:[ELColorUtil imageWithColor:[ELColorUtil evenLiftRedHighlighted]] forState:UIControlStateHighlighted];
        
        self.submitButton = submitButton;
        
        // Enable/disable button based on whether or not we have entered a title
        self.submitButton.enabled = ![self.exerciseField.text isEqualToString:@""];
        
        [footerView addSubview:submitButton];
        
        return footerView;
    } else {
        return nil;
    }
}

- (IBAction)submitSet
{
    // First validate input, and then log the set
    if ([self validateInput]) {
        self.submitButton.enabled = NO;
        
        BOOL userDidSpecifyRestTime = ![self.restField.text isEqualToString:@""];
        
        if (!userDidSpecifyRestTime) {
            [SVProgressHUD setBackgroundColor:[ELColorUtil evenLiftWhite]];
            [SVProgressHUD setForegroundColor:[ELColorUtil evenLiftBlack]];
            [SVProgressHUD show];
        }
        
        // Create a new Set
        Firebase* setRef = [[self.workoutRef childByAppendingPath:@"sets"] childByAutoId];
        
        NSString* setID = setRef.name;
        
        // Add a reference to this Set to the appropriate Exercise
        [[self.userExercisesRef childByAppendingPath:[NSString stringWithFormat:@"%@/sets/%@/%@", self.exerciseField.text, self.workoutId, setID]] setValue:@YES];
        
        // Actually log the Set
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
            if (!userDidSpecifyRestTime) {
                [SVProgressHUD showSuccessWithStatus:@"Set added succesfully!"];
            }
            [self clearAllTextFields];
            [self.view endEditing:YES];
            self.submitButton.enabled = YES;
        }];
        
        // If user specified a rest time, show countdown
        if (userDidSpecifyRestTime) {
            ELCountdownViewController* countdownViewController = [[ELCountdownViewController alloc] initWithDurationInSeconds:[self.restField.text intValue]];
            countdownViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:countdownViewController animated:YES completion:nil];
        }
    }
}

- (BOOL)validateInput
{
    // First check that there is text in the Exercise field
    if ([self.exerciseField.text isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc]
                                    initWithTitle:@"Missing Info"
                                    message:@"Please enter an Exercise name."
                                    delegate:self
                                    cancelButtonTitle:@"Ok"
                                    otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    // Then check the same for the Reps field
    if ([self.repsField.text isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc]
                                           initWithTitle:@"Missing Info"
                                           message:@"Please enter a number of Reps"
                                           delegate:self
                                           cancelButtonTitle:@"Ok"
                                           otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

- (void)clearAllTextFields
{
    self.repsField.text = @"";
    self.weightField.text = @"";
    self.restField.text = @"";
    self.notesField.text = @"";
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag != 99) {
        self.lastSelectedTextField = textField.tag;
        [self setCustomToolBarForTextField:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 99) {
        [self bindToSetsOfThisExerciseForThisWorkout];
        [textField resignFirstResponder];
        self.navigationItem.titleView = nil;
        self.title = self.exerciseField.text;
        [[self.view viewWithTag:1000] removeFromSuperview];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.submitButton.enabled = YES;
    }
    
    return YES;
}

- (void)setCustomToolBarForTextField:(UITextField*)textField
{
    UIToolbar* toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0,0,320,44)];
    
    UIBarButtonItem* previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonClicked:)];
    previousButton.enabled = (textField.tag != 1);
    
    UIBarButtonItem* nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];
    nextButton.enabled = (textField.tag != 4);
    
    UIBarButtonItem* flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)];
    
    NSArray* itemsArray = [NSArray arrayWithObjects:previousButton, nextButton, flexButton, doneButton, nil];
    
    [toolbar setItems:itemsArray];
    
    // Style the toolbar
    toolbar.tintColor = [ELColorUtil evenLiftBlack];
    
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

// HACK: Use an attributedString in order to change placeholder colors
- (NSAttributedString*)coloredPlaceholderForString:(NSString*)string
{
    return [[NSAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
}

@end
