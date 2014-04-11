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
@property CAShapeLayer* circle;

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
    
    [self createCircle];
    
    // Apply custom fonts to both labels
    self.countdownLabel.font = [UIFont fontWithName:@"Gotham" size:60];
    self.secondsLabel.font = [UIFont fontWithName:@"Gotham" size:14];
    self.secondsLabel.textColor = [UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1.0];
    
    self.countdownLabel.text = [NSString stringWithFormat:@"%d", mSeconds];
    
    [self startTimer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self animateCircle];
}

- (void)createCircle
{
    int radius = 100;
    
    // Set up the circle shape
    CAShapeLayer* circle = [CAShapeLayer layer];
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius) cornerRadius:radius].CGPath;
    
    // Center the circle
    circle.position = CGPointMake(CGRectGetMidX(self.view.frame)-radius, CGRectGetMidY(self.view.frame)-radius);
    
    // Configure circle's appearance
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1.0].CGColor;
    circle.lineWidth = 10;
    
    // Add to parent layer
    self.circle = circle;
    [self.view.layer addSublayer:self.circle];
}

- (void)animateCircle
{
    // Configure animation
    CABasicAnimation* drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    drawAnimation.duration = mSeconds;
    drawAnimation.repeatCount = 1.0;
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.delegate = self;
    
    // Add the animation to the circle
    [self.circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.circle removeFromSuperlayer];
}

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}

- (void)updateTimer:(NSTimer*)theTimer
{
    mSeconds--;
    
    self.countdownLabel.text = [NSString stringWithFormat:@"%d", mSeconds];
    
    if (mSeconds <= 0) {
        [self dismissCountdownAfterDelay:1];
    }
}

- (IBAction)skipButtonPressed {
    [self dismissCountdownAfterDelay:0];
}

- (void)dismissCountdownAfterDelay:(double)delayInSeconds
{
    [self.timer invalidate];
    
    // Dismiss viewController after a given delay
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
