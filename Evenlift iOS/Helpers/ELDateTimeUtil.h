//
//  ELDateTimeUtil.h
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-01.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELDateTimeUtil : NSObject

+ (NSNumber*)getCurrentTime;
+ (NSString*)timeStringFromTimeStamp:(NSNumber*)timeStamp;
+ (NSString*)dateStringFromTimeStamp:(NSNumber*)timeStamp;

@end
