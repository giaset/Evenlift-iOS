//
//  ELMonth.m
//  Evenlift
//
//  Created by Gianni Settino on 2014-04-26.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELMonth.h"

@interface ELMonth ()

@property (nonatomic, copy) NSDateComponents* dateComponents;

@end

@implementation ELMonth

- (id)initWithDate:(NSDate*)date
{
    self = [super init];
    if (self) {
        self.dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];;
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

- (NSInteger)month
{
    return [self.dateComponents month];
}

- (NSInteger)year
{
    return [self.dateComponents year];
}

- (BOOL)containsDate:(NSDate*)date
{
    NSDateComponents* dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    return ([self month] == [dateComponents month]) && ([self year] == [dateComponents year]);
}

@end
