//
//  ELDateTimeUtil.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-01.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELDateTimeUtil.h"

@implementation ELDateTimeUtil

+ (NSString*)getCurrentTime
{
    return [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] stringValue];
}

@end
