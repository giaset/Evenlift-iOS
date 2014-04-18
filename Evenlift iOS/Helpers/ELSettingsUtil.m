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
        [[NSUserDefaults standardUserDefaults] synchronize];
        loadedUnitType = @"lbs";
    }
    
    return [self unitTypeFromString:loadedUnitType];
}

+ (void)setUnitType:(ELUnitType)unitType
{
    [[NSUserDefaults standardUserDefaults] setObject:[self stringFromUnitType:unitType] forKey:@"unit_type"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (ELUnitType)unitTypeFromString:(NSString *)string
{
    if ([string isEqualToString:@"lbs"]) {
        return ELUnitTypePounds;
    } else if ([string isEqualToString:@"kg"]) {
        return ELUnitTypeKilos;
    } else {
        return ELUnitTypeUnknown;
    }
}

+ (NSString*)stringFromUnitType:(ELUnitType)unitType
{
    if (unitType == ELUnitTypePounds) {
        return @"lbs";
    } else if (unitType == ELUnitTypeKilos) {
        return @"kg";
    } else {
        return nil;
    }
}

+ (NSString*)getUid
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
}

+ (void)setUid:(NSString*)uid
{
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
