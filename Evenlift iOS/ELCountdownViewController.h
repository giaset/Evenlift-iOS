//
//  ELCountdownViewController.h
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-09.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELCountdownViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel* countdownLabel;
@property (weak, nonatomic) IBOutlet UILabel* secondsLabel;

- (IBAction)skipButtonPressed;
- (id)initWithDurationInSeconds:(int)seconds;

@end
