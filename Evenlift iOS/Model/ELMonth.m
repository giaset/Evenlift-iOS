//
//  ELMonth.m
//  Evenlift
//
//  Created by Gianni Settino on 2014-04-26.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELMonth.h"

@implementation ELMonth

- (id)initWithDateComponents:(NSDateComponents *)dateComponents
{
    self = [super init];
    if (self) {
        self.dateComponents = dateComponents;
        self.workouts = [[NSMutableArray alloc] init];;
    }
    return self;
}

- (NSString*)description
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    NSString* monthName = [[formatter monthSymbols] objectAtIndex:([self.dateComponents month]-1)];
    return [NSString stringWithFormat:@"%@ %ld", monthName, (long)[self.dateComponents year]];
}

@end
