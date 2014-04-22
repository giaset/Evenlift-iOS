//
//  ELWorkoutsViewController.h
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-23.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

@interface ELWorkoutsViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, strong) FirebaseSimpleLogin* authClient;

@end
