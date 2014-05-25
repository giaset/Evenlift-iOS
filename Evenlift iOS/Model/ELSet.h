//
//  ELSet.h
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-11.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELSettingsUtil.h"

@interface ELSet : NSObject

- (id)initWithDictionary:(NSDictionary*)dict;
- (void)updateWithDictionary:(NSDictionary *)dict;

@property (nonatomic, copy) NSString* setId;
@property (nonatomic, copy) NSString* exercise;
@property (nonatomic, strong) NSNumber* reps;
@property (nonatomic, strong) NSNumber* weight;
@property (nonatomic) ELUnitType unitType;
@property (nonatomic, strong) NSNumber* rest;
@property (nonatomic, copy) NSString* notes;
@property (nonatomic, strong) NSNumber* time;

@end
