//
//  ELWorkout.h
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-01.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELWorkout : NSObject

- (id)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, copy) NSString* title;
@property (nonatomic) double startTime;
@property (nonatomic) double endTime;

@end
