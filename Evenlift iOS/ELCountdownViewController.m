//
//  ELCountdownViewController.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-09.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELCountdownViewController.h"

@interface ELCountdownViewController ()

@property (weak) NSTimer* timer;

@end

int mSeconds;

@implementation ELCountdownViewController

- (id)initWithDurationInSeconds:(int)seconds
{
    self = [super initWithNibName:@"ELCountdownViewController" bundle:nil];
    if (self) {
        mSeconds = seconds;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.countdownLabel.text = [NSString stringWithFormat:@"%d", mSeconds];
    
    [self startTimer];
}

- (void)startTimer
{
    [self.timer invalidate];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}

- (void)updateTimer:(NSTimer*)theTimer
{
    mSeconds--;
    
    if (mSeconds == 0) {
        [self dismissCountdown];
    } else {
        self.countdownLabel.text = [NSString stringWithFormat:@"%d", mSeconds];
    }
}

- (IBAction)skipButtonPressed {
    [self dismissCountdown];
}

- (void)dismissCountdown
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
