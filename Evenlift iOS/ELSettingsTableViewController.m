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
    
    self.tableView.backgroundColor = [ELColorUtil evenLiftBlack];
    
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
    if (self.authClient == nil) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
            
        default:
            return 1;
            break;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Units";
            break;
            
        case 1:
            return @"Account";
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView* tableViewHeaderFooterView = (UITableViewHeaderFooterView*)view;
        tableViewHeaderFooterView.textLabel.text = [tableViewHeaderFooterView.textLabel.text capitalizedString];
        tableViewHeaderFooterView.textLabel.textColor = [ELColorUtil evenLiftRed];
        tableViewHeaderFooterView.textLabel.font = [UIFont fontWithName:@"Gotham" size:14];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.tintColor = [ELColorUtil evenLiftRed];
        cell.backgroundColor = [ELColorUtil evenLiftBlack];
        cell.textLabel.font = [UIFont fontWithName:@"Gotham" size:14];
        cell.textLabel.textColor = [ELColorUtil evenLiftWhite];
    }
    
    // Configure the cell...
    if (indexPath.section == 0) {
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
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell.textLabel.text = @"Logout";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [ELColorUtil evenLiftRed];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
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
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self logout];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)logout
{
    [self.authClient logout];
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
