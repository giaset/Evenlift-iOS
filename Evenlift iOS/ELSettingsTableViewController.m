//
//  ELSettingsTableViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-18.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELSettingsTableViewController.h"
#import "ELSettingsUtil.h"
#import "ELColorUtil.h"

@interface ELSettingsTableViewController ()

@end

@implementation ELSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    // Set up close button at top right
    UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 0, 18, 18);
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    closeButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    [closeButton addTarget:self action:@selector(dismissModalViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.rightBarButtonItem = closeButtonItem;
}

- (IBAction)dismissModalViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Units";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Pounds";
            if ([ELSettingsUtil getUnitType] == ELUnitTypePounds) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        
        case 1:
            cell.textLabel.text = @"Kilograms";
            if ([ELSettingsUtil getUnitType] == ELUnitTypeKilos) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [ELSettingsUtil setUnitType:ELUnitTypePounds];
            break;
        case 1:
            [ELSettingsUtil setUnitType:ELUnitTypeKilos];
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Added a little delay before reloading data because it was messing with the
    // fading out of the cell's selection background otherwise...
    double delayInSeconds = 0.15;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [tableView reloadData];
    });
}

// Footer view
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.authClient == nil) {
        return 0;
    } else {
        return 54;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.authClient == nil) {
        return nil;
    } else {
        UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        
        // Create the button
        UIButton* logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
        
        // Style the button
        logoutButton.titleLabel.font = [UIFont fontWithName:@"Gotham" size:22.0];
        [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [logoutButton setBackgroundColor:[ELColorUtil evenLiftRed]];
        [logoutButton setBackgroundImage:[ELColorUtil imageWithColor:[ELColorUtil evenLiftRedHighlighted]] forState:UIControlStateHighlighted];
        
        [footerView addSubview:logoutButton];
        
        return footerView;
    }
}

- (IBAction)logout
{
    [self.authClient logout];
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
