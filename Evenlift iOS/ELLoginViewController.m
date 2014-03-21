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
    Firebase* f = [[Firebase alloc] initWithUrl:kEvenliftURL];
    self.authClient = [[FirebaseSimpleLogin alloc] initWithRef:f];
}

- (IBAction)login:(id)sender {
    [self.authClient loginToFacebookAppWithId:@"420007321469839" permissions:nil audience:ACFacebookAudienceFriends withCompletionBlock:^(NSError *error, FAUser *user) {
        if (error) {
            NSLog(@"FB LOGIN ERROR");
        } else {
            NSLog(@"FB LOGIN SUCCESS");
        }
    }];
}
@end
