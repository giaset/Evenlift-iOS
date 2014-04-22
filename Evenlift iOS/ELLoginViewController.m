//
//  ELLoginViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-21.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELLoginViewController.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>
#import "ELWorkoutsViewController.h"
#import "ELExercisesTableViewController.h"
#import "ELSettingsUtil.h"

#define kEvenliftURL @"https://evenlift.firebaseio.com/"

@interface ELLoginViewController ()

@property (nonatomic, strong) Firebase* firebase;
@property (nonatomic, strong) FirebaseSimpleLogin* authClient;

@end

@implementation ELLoginViewController

- (id)init
{
    self = [super initWithNibName:@"ELLoginViewController" bundle:nil];
    if (self) {
        // Further initialization if needed
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"Gotham" size:14.0];
    self.titleLabel.font = [UIFont fontWithName:@"Gotham-Ultra" size:54.0];
    
    // Do any additional setup after loading the view from its nib.
    self.firebase = [[Firebase alloc] initWithUrl:kEvenliftURL];
    self.authClient = [[FirebaseSimpleLogin alloc] initWithRef:self.firebase];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.loginButton.hidden = YES;
    
    // Check user's auth status
    [self.authClient checkAuthStatusWithBlock:^(NSError *error, FAUser *user) {
        if (error) {
            // there was an error
            NSLog(@"ERROR");
        } else if (!user) {
            // user is not logged in
            self.loginButton.hidden = NO;
        } else {
            // user is logged in
            [self launchApp];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (IBAction)login:(id)sender {
    [self.loginButton setTitle:@"PLEASE WAIT..." forState:UIControlStateNormal];
    
    [self.authClient loginToFacebookAppWithId:@"420007321469839" permissions:nil audience:ACFacebookAudienceFriends withCompletionBlock:^(NSError *error, FAUser *user) {
        [self.loginButton setTitle:@"LOGIN WITH FACEBOOK" forState:UIControlStateNormal];
        if (error) {
            NSLog(@"FB LOGIN ERROR");
        } else {
            // FB login successful. First see if we already had this user in our userDefaults
            if (![[ELSettingsUtil getUid] isEqualToString:user.uid]) {
                // Save user.uid to our userDefaults
                [ELSettingsUtil setUid:user.uid];
                
                // And add this user to our Firebase
                NSString* userPath = [NSString stringWithFormat:@"users/%@", user.uid];
                Firebase* userRef = [self.firebase childByAppendingPath:userPath];
                [[userRef childByAppendingPath:@"first_name"] setValue:[user.thirdPartyUserData valueForKey:@"first_name"]];
                [[userRef childByAppendingPath:@"last_name"] setValue:[user.thirdPartyUserData valueForKey:@"last_name"]];
            }
            
            [self launchApp];
        }
    }];
}

-(IBAction)logout
{
    [self.authClient logout];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)launchApp
{
    // Initialize Workouts viewController
    ELWorkoutsViewController* workouts = [[ELWorkoutsViewController alloc] init];
    workouts.authClient = self.authClient;
    
    UINavigationController* workoutsNavController = [[UINavigationController alloc] initWithRootViewController:workouts];
    
    [self presentViewController:workoutsNavController animated:NO completion:nil];
}

@end
