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
    
    // Do any additional setup after loading the view from its nib.
    self.firebase = [[Firebase alloc] initWithUrl:kEvenliftURL];
    self.authClient = [[FirebaseSimpleLogin alloc] initWithRef:self.firebase];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Check user's auth status
    [self.authClient checkAuthStatusWithBlock:^(NSError *error, FAUser *user) {
        if (error) {
            // there was an error
            NSLog(@"ERROR");
        } else if (!user) {
            // user is not logged in
        } else {
            // user is logged in
            [self launchApp];
        }
    }];
}

- (IBAction)login:(id)sender {
    UIButton* loginButton = (UIButton*)sender;
    [loginButton setTitle:@"Please wait..." forState:UIControlStateNormal];
    
    [self.authClient loginToFacebookAppWithId:@"420007321469839" permissions:nil audience:ACFacebookAudienceFriends withCompletionBlock:^(NSError *error, FAUser *user) {
        if (error) {
            NSLog(@"FB LOGIN ERROR");
        } else {
            // FB login successful. Add this user to our databse
            NSString* userPath = [NSString stringWithFormat:@"users/%@", user.uid];
            Firebase* userRef = [self.firebase childByAppendingPath:userPath];
            [[userRef childByAppendingPath:@"first_name"] setValue:[user.thirdPartyUserData valueForKey:@"first_name"]];
            [[userRef childByAppendingPath:@"last_name"] setValue:[user.thirdPartyUserData valueForKey:@"last_name"]];
            
            [self launchApp];
        }
    }];
}

- (void)launchApp
{
    UIViewController* loggedIn = [[UIViewController alloc] init];
    loggedIn.view.backgroundColor = [UIColor blueColor];
    [self presentViewController:loggedIn animated:NO completion:nil];
}
@end
