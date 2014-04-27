//
//  ELAppDelegate.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-03-20.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELAppDelegate.h"
#import "ELLoginViewController.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>
#import "ELColorUtil.h"

@implementation ELAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Stylin' (navBar)
    [UINavigationBar appearance].barTintColor = [ELColorUtil evenLiftBlack];
    [UINavigationBar appearance].tintColor = [ELColorUtil evenLiftWhite];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[ELColorUtil evenLiftWhite], NSForegroundColorAttributeName, [UIFont fontWithName:@"Gotham" size:18], NSFontAttributeName, nil]];
    
    // Launch the app
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = [[ELLoginViewController alloc] init];
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
