//
//  ELSettingsUtil.h
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-19.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ELUnitTypePounds,
    ELUnitTypeKilos,
    ELUnitTypeBodyWeight,
    ELUnitTypeUnknown
} ELUnitType;

@interface ELSettingsUtil : NSObject

+ (ELUnitType)getUnitType;
+ (void)setUnitType:(ELUnitType)unitType;
+ (ELUnitType)unitTypeFromString:(NSString*)string;
+ (NSString*)stringFromUnitType:(ELUnitType)unitType;

+ (NSString*)getUid;
+ (void)setUid:(NSString*)uid;

@end
