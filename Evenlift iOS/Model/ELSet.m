//
//  ELSet.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-11.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELSet.h"
#import "ELDateTimeUtil.h"

@implementation ELSet

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        self.setId = [dict objectForKey:@"set_id"];
        [self updateWithDictionary:dict];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict
{
    self.exercise = [dict objectForKey:@"exercise"];
    self.reps = (NSNumber*)[dict objectForKey:@"reps"];
    
    NSDictionary* weight = (NSDictionary*)[dict objectForKey:@"weight"];
    self.weight = (NSNumber*)[weight objectForKey:@"value"];
    self.unitType = [ELSettingsUtil unitTypeFromString:[weight objectForKey:@"unit"]];
    
    self.rest = (NSNumber*)[dict objectForKey:@"rest"];
    self.notes = [dict objectForKey:@"notes"];
    self.time = (NSNumber*)[dict objectForKey:@"time"];
}

- (NSString*)description
{
    NSString* description = [NSString stringWithFormat:@"%@ - %@ x", [ELDateTimeUtil timeStringFromTimeStamp:self.time], self.reps];
    
    if (self.unitType == ELUnitTypeBodyWeight) {
        description = [NSString stringWithFormat:@"%@ %@", description, [ELSettingsUtil stringFromUnitType:self.unitType]];
    } else {
        description = [NSString stringWithFormat:@"%@ %@ %@", description, self.weight, [ELSettingsUtil stringFromUnitType:self.unitType]];
    }
    
    if ([self.rest intValue] != -1) {
        description = [NSString stringWithFormat:@"%@ (%@ sec rest)", description, self.rest];
    }
    
    return description;
}

@end
