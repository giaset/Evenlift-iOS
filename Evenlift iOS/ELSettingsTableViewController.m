//
//  ELSettingsTableViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-18.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELSettingsTableViewController.h"
#import "ELSettingsUtil.h"

@interface ELSettingsTableViewController ()

@end

@implementation ELSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    // Set up close button at top right
    UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewController)];
    self.navigationItem.rightBarButtonItem = closeButton;
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

@end
