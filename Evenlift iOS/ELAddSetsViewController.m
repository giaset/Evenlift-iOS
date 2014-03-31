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
    return 74;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 74)];
    
    // Create the button and style it
    UIButton* submitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 15, 64, 44)];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    submitButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [submitButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [submitButton addTarget:self action:@selector(submitSet) forControlEvents:UIControlEventTouchUpInside];
    submitButton.layer.cornerRadius = 4;
    submitButton.layer.borderWidth = 1.5;
    submitButton.layer.borderColor = [UIColor redColor].CGColor;
    submitButton.clipsToBounds = YES;
    submitButton.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [submitButton setBackgroundImage:[self imageWithColor:[UIColor redColor]] forState:UIControlStateHighlighted];
    [submitButton sizeToFit];
    
    // Center the button horizontally
    CGPoint newCenter = CGPointMake(submitButton.center.x, submitButton.center.y);
    newCenter.x = 160;
    submitButton.center = newCenter;
    
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
    
    [setRef setValue:@{@"exercise": self.exerciseField.text, @"reps": self.repsField.text, @"weight": self.weightField.text, @"rest": self.restField.text, @"notes": self.notesField.text, @"time": [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] stringValue]} withCompletionBlock:^(NSError *error, Firebase *ref) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.weightField.text = @"";
        self.notesField.text = @"";
    }];
}

@end
