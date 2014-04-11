//
//  ELExercise.h
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-11.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELExercise : NSObject

- (id)initWithName:(NSString*)name;

@property (nonatomic, copy) NSString* name;
@property (nonatomic, strong) NSMutableArray* sets;

@end
