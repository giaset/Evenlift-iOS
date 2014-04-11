//
//  ELSet.h
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-11.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELSet : NSObject

@property (nonatomic, copy) NSString* setId;
@property (nonatomic, copy) NSString* exercise;
@property (nonatomic, strong) NSNumber* reps;
@property (nonatomic, strong) NSNumber* weight;
@property (nonatomic, strong) NSNumber* rest;
@property (nonatomic, copy) NSString* notes;

@end