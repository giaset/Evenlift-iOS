//
//  ELSettingsTableViewController.h
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-18.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

@interface ELSettingsTableViewController : UITableViewController

@property (nonatomic, strong) FirebaseSimpleLogin* authClient;

@end
