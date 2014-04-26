//
//  ELMonth.h
//  Evenlift
//
//  Created by Gianni Settino on 2014-04-26.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELMonth : NSObject

- (id)initWithDateComponents:(NSDateComponents*)dateComponents;

@property (nonatomic, copy) NSDateComponents* dateComponents;
@property (nonatomic, strong) NSMutableArray* workouts;

@end
