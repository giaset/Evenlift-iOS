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

@implementation ELAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = [[ELLoginViewController alloc] init];
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
