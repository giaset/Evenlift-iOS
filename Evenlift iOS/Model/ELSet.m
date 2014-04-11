//
//  ELSet.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-11.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELSet.h"

@implementation ELSet

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        self.setId = [dict objectForKey:@"set_id"];
        self.exercise = [dict objectForKey:@"exercise"];
        self.reps = (NSNumber*)[dict objectForKey:@"reps"];
        self.weight = (NSNumber*)[dict objectForKey:@"weight"];
        self.rest = (NSNumber*)[dict objectForKey:@"rest"];
        self.notes = [dict objectForKey:@"notes"];
        self.time = (NSNumber*)[dict objectForKey:@"time"];
    }
    return self;
}

- (NSString*)description
{
    if ([self.rest intValue] == -1) {
        return [NSString stringWithFormat:@"%@ x %@", self.reps, self.weight];
    } else {
        return [NSString stringWithFormat:@"%@ x %@ (%@ sec rest)", self.reps, self.weight, self.rest];
    }
}

@end
