//
//  ELHomeViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-22.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELHomeViewController.h"
#import <Firebase/Firebase.h>

#define kEvenliftURL @"https://evenlift.firebaseio.com/"

@interface ELHomeViewController ()

@end

@implementation ELHomeViewController

- (id)init
{
    self = [super initWithNibName:@"ELHomeViewController" bundle:nil];
    if (self) {
        // Further initialization if needed
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the welcome label to greet the user
    self.welcomeLabel.hidden = YES;
    NSString* defaultString = self.welcomeLabel.text;
    
    // Read user's first name from Firebase
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* uid = [userDefaults stringForKey:@"uid"];
    
    Firebase* f = [[Firebase alloc] initWithUrl:kEvenliftURL];
    NSString* firstNamePath = [NSString stringWithFormat:@"users/%@/first_name", uid];
    Firebase* firstNameRef = [f childByAppendingPath:firstNamePath];
    [firstNameRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSString* firstName = (NSString*)snapshot.value;
        self.welcomeLabel.text = [NSString stringWithFormat:defaultString, firstName];
        self.welcomeLabel.hidden = NO;
    }];
}

@end
