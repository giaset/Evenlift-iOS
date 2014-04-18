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
    ELUnitTypeUnknown
} ELUnitType;

@interface ELSettingsUtil : NSObject

+ (ELUnitType)getUnitType;
+ (void)setUnitType:(ELUnitType)unitType;
+ (NSString*)getUid;

@end
