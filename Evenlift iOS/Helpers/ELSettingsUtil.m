//
//  ELSettingsUtil.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-19.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELSettingsUtil.h"

@implementation ELSettingsUtil

+ (ELUnitType)getUnitType
{
    NSString* loadedUnitType = [[NSUserDefaults standardUserDefaults] stringForKey:@"unit_type"];
    
    if (!loadedUnitType) {
        // First time ever loading unitType, set POUNDS by default
        [[NSUserDefaults standardUserDefaults] setObject:@"lbs" forKey:@"unit_type"];
        loadedUnitType = @"lbs";
    }
    
    if ([loadedUnitType isEqualToString:@"lbs"]) {
        return ELUnitTypePounds;
    } else if ([loadedUnitType isEqualToString:@"kg"]) {
        return ELUnitTypeKilos;
    } else {
        return ELUnitTypeUnknown;
    }
}

+ (void)setUnitType:(ELUnitType)unitType
{
    if (unitType == ELUnitTypePounds) {
        [[NSUserDefaults standardUserDefaults] setObject:@"lbs" forKey:@"unit_type"];
    } else if (unitType == ELUnitTypeKilos) {
        [[NSUserDefaults standardUserDefaults] setObject:@"kg" forKey:@"unit_type"];
    }
}

+ (NSString*)getUid
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
}

+ (void)setUid:(NSString*)uid
{
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"uid"];
}

@end
