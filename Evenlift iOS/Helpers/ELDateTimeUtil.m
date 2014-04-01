//
//  ELDateTimeUtil.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-01.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELDateTimeUtil.h"

@implementation ELDateTimeUtil

+ (NSNumber*)getCurrentTime
{
    return [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
}

+ (NSString*)timeStringFromTimeStamp:(NSNumber*)timeStamp {
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeStamp doubleValue]];
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"h:mm a"];
    
    return [timeFormat stringFromDate:date];
}

@end
