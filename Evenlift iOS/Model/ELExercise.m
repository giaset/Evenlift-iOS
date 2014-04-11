//
//  ELExercise.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-11.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELExercise.h"

@implementation ELExercise

- (id)initWithName:(NSString*)name
{
    self = [super init];
    if (self) {
        self.name = name;
        self.sets = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
